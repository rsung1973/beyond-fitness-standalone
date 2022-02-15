using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Security.Claims;
using System.Text;
using System.Web;
using Microsoft.AspNetCore.Http;  //System.Web.Mvc;
using Microsoft.Extensions.Logging;
//using Microsoft.AspNetCore.Authorization;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
//using WebHome.Models.Security;
using WebHome.Models.ViewModel;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace WebHome.Helper
{
    public static class LoginExtension
    {
        public static async Task SignOnAsync(this HttpContext context, UserProfile profile, bool remeberMe = true)
        {
            //帳密都輸入正確，ASP.net Core要多寫三行程式碼 
            Claim[] claims = new[] { new Claim("Name", profile.PID) }; //Key取名"Name"，在登入後的頁面，讀取登入者的帳號會用得到，自己先記在大腦
            ClaimsIdentity claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);//Scheme必填
            ClaimsPrincipal principal = new ClaimsPrincipal(claimsIdentity);

            //從組態讀取登入逾時設定
            double loginExpireMinute = Startup.Properties.GetValue<double>("LoginExpireMinute");
            //執行登入，相當於以前的FormsAuthentication.SetAuthCookie()
            await context.SignInAsync(principal,
                new AuthenticationProperties()
                {
                    IsPersistent = true, //IsPersistent = false：瀏覽器關閉立馬登出；IsPersistent = true 就變成常見的Remember Me功能
                                         //用戶頁面停留太久，逾期時間，在此設定的話會覆蓋Startup.cs裡的逾期設定
                    ExpiresUtc = DateTime.UtcNow.AddMinutes(loginExpireMinute)
                });

            context.ClearCache();
            context.SetCacheValue("userProfile", profile);

            if (remeberMe)
            {
                context.Response.Cookies.Append("userID", profile.PID.EncryptKey(),
                    new CookieOptions
                    {
                        MaxAge = TimeSpan.FromDays(14),
                    });
            }
            else
            {
                context.Response.Cookies.Append("userID", profile.PID.EncryptKey(),
                    new CookieOptions
                    {
                        MaxAge = TimeSpan.FromHours(24),
                    });
            }

            //switch ((Naming.RoleID)profile.CurrentUserRole.RoleID)
            //{
            //    case Naming.RoleID.Administrator:
            //    case Naming.RoleID.Assistant:
            //    case Naming.RoleID.Coach:
            //    case Naming.RoleID.FreeAgent:
            //        cookie = new HttpCookie("userID", profile.PID);
            //        if (remeberMe)
            //        {
            //            cookie.Expires = DateTime.Now.AddDays(14);
            //        }
            //        else
            //        {
            //            cookie.Expires = DateTime.Now.AddHours(24);
            //        }
            //        context.Response.SetCookie(cookie);
            //        break;
            //    case Naming.RoleID.Learner:
            //        if (remeberMe)
            //        {
            //            cookie = new HttpCookie("userID", profile.PID);
            //            cookie.Expires = DateTime.Now.AddDays(14);
            //        }
            //        else
            //        {
            //            cookie = new HttpCookie("userID", "");
            //            cookie.Expires = DateTime.Now.AddHours(24);
            //        }
            //        context.Response.SetCookie(cookie);
            //        break;
            //}


            /// process sign-on user profile
            /// 
            var roles = profile.UserRole.Select(r => r.UserRoleDefinition).ToArray();
            var roleAuth = profile.UserRoleAuthorization.ToArray();
            var auth = profile.UserRoleAuthorization.Select(r => r.UserRoleDefinition).ToArray();
        }


        public static void ClearCache(this HttpContext context)
        {
            HttpContextDataModelCache caching = new(context);
            caching.Clear();
        }


        public static void RemoveCache(this HttpContext context, String keyName)
        {
            context.SetCacheValue(keyName, null);
        }


        public static Object GetCacheValue(this HttpContext context, String keyName)
        {
            HttpContextDataModelCache caching = new(context);
            return caching[keyName];
        }

        public static void SetCacheValue(this HttpContext context, String keyName, Object value)
        {
            HttpContextDataModelCache caching = new(context);
            caching[keyName] = value;
        }


        public static bool CreatePassword(this Controller controller,PasswordViewModel viewModel)
        {
            if (String.IsNullOrEmpty(viewModel.lockPattern))
            {
                if (String.IsNullOrEmpty(viewModel.Password))
                {
                    controller.ModelState.AddModelError("Password", "請輸入密碼!!");
                    controller.ModelState.AddModelError("lockPattern", "請設定圖形密碼!!");
                    return false;
                }
                else if (viewModel.Password != viewModel.Password2)
                {
                    controller.ModelState.AddModelError("Password2", "密碼確認錯誤!!");
                    return false;
                }
            }
            else
            {
                if (viewModel.lockPattern.Length < 9)
                {
                    controller.ModelState.AddModelError("lockPattern", "設定圖形的密碼過短!!");
                }
                else
                {
                    viewModel.Password = viewModel.lockPattern;
                }
            }
            return true;
        }

        public static String MakePassword(this String password)
        {
            if (String.IsNullOrEmpty(password))
                return null;
            return Convert.ToBase64String(MD5.Create().ComputeHash(Encoding.Default.GetBytes(password)));
        }

        public static async void Logout(this HttpContext context)
        {
            context.Response.Cookies.Delete("userID");
            await context.SignOutAsync();
            context.ClearCache();
        }

        public static async Task<UserProfile> GetUserAsync(this HttpContext context)
        {
            UserProfile profile = (UserProfile)context.GetCacheValue("userProfile");
            //Logger.Debug("profile cache:" + (profile != null));
            if (profile == null)
            {
                if (context.User.Identity.IsAuthenticated)
                {
                    //Logger.Debug("Has Identity:" + context.User.Identity.Name);
                    profile = (context.User.Identity as ClaimsIdentity)?
                        .Claims.FirstOrDefault()?.Value.getLoginUser();
                }
                else
                {
                    var cookie = context.Request.Cookies["userID"];
                    if (!String.IsNullOrEmpty(cookie))
                    {
                        try
                        {
                            profile = cookie.DecryptKey().getLoginUser();
                            if (profile != null)
                            {
                                await context.SignOnAsync(profile);
                            }
                        }
                        catch (Exception ex)
                        {
                            ApplicationLogging.LoggerFactory.CreateLogger(typeof(LoginExtension))
                                .LogError(ex, ex.Message);
                            profile = null;
                        }
                    }
                }
                context.SetCacheValue("userProfile", profile);
            }
            return profile;
        }

        private static UserProfile getLoginUser(this String pid)
        {
            using ModelSource<UserProfile> Models = new();
            UserProfile profile = Models.EntityList.Where(u => u.PID == pid).FirstOrDefault();
            if (profile != null)
            {
                var roles = profile.UserRole.Select(r => r.UserRoleDefinition).ToArray();
                var roleAuth = profile.UserRoleAuthorization.ToArray();
                var auth = profile.UserRoleAuthorization.Select(r => r.UserRoleDefinition).ToArray();
            }
            return profile;
        }

        public static bool IsFreeAgent(this UserProfile profile)
        {
            return profile != null && profile.CurrentUserRole.RoleID == (int)Naming.RoleID.FreeAgent;
        }

        public static bool IsOfficer(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Officer ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Officer));
        }

        public static bool IsSysAdmin(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Administrator ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Administrator));
        }

        public static bool IsCoach(this UserProfile profile)
        {
            return profile != null
                && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Coach
                    || profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Coach 
                        || r.RoleID == (int)Naming.RoleID.Manager
                        || r.RoleID == (int)Naming.RoleID.ViceManager));
        }
        public static bool IsAssistant(this UserProfile profile)
        {
            return profile != null
                && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Assistant
                    || profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Assistant));
        }

        public static bool IsLearner(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Learner || profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Learner));
        }

        public static bool IsServitor(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Servitor || profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Servitor));
        }

        public static bool IsHealthCare(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.HealthCare ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.HealthCare));
        }

        public static bool IsFES(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.FES ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.FES));
        }


        public static bool IsAuthorizedSysAdmin(this UserProfile profile)
        {
            return profile!=null && profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Administrator);
        }

        public static bool IsAccounting(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Accounting ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Accounting));
        }

        public static bool IsManager(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Manager ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Manager));
        }
        public static bool IsViceManager(this UserProfile profile)
        {
            return profile != null && (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.ViceManager ||
                profile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.ViceManager));
        }

        public static bool IsAuthorized(this UserProfile profile,int[] roleID)
        {
            return profile != null && (roleID.Contains(profile.CurrentUserRole.RoleID)
                || profile.UserRoleAuthorization.Any(r => roleID.Contains(r.RoleID)));
        }

        public static bool IsTrialLearner(this UserProfile profile)
        {
            return profile.UserProfileExtension?.CurrentTrial == 1;
        }

        public static bool IsEmployee(this UserProfile profile)
        {
            return profile.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Coach)
                || profile.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Assistant);
        }

    }
}