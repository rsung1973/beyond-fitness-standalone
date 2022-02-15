using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using CommonLib.Core.Utility;
using System.Text.RegularExpressions;

namespace WebHome.Controllers
{
    public class AccountController : SampleController<UserProfile>
    {
        public AccountController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        
        // GET: Account
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Sample()
        {
            return View();
        }

        [AllowAnonymous]
        public ActionResult Login(bool? autoLogin = true)
        {
            return new RedirectToActionResult("Login", "CornerKick", null);
            //return RedirectToAction("Index", "CornerKick");
        }

        
        public ActionResult LoginByMail()
        {
            this.HttpContext.Logout();
            this.HttpContext.Session.Clear();

            return View();
        }

        
        public ActionResult Register()
        {
            return View("Register");
        }


        private String createMemberCode()
        {
            Thread.Sleep(1);
            Random rnd = new Random();

            return (new StringBuilder()).Append((char)((int)'A' + rnd.Next(26)))
                .Append((char)((int)'A' + rnd.Next(26)))
                .Append(String.Format("{0:00000000}",rnd.Next(100000000)))
                .ToString();
        }

        
        public ActionResult CheckMemberCode(String memberCode)
        {
            try
            {
                if (models.GetTable<UserProfile>().Any(u => u.MemberCode == memberCode))
                {
                    return Json(new { result = true });
                }

                return Json(new { result = false, message = "學員編號錯誤!!" });

            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<AccountController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
            
        }

        public ActionResult UpdateMemberPicture(String memberCode, String imgUrl)
        {
            try
            {
                    UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == memberCode).FirstOrDefault();

                    if (item == null)
                        return Json(new { result = false, message = "學員編號錯誤!!" });

                    String storePath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + ".dat");
                    if (Request.Form.Files.Count > 0)
                    {
                        Request.Form.Files[0].SaveAs(storePath);
                    }
                    else
                    {
                        if (String.IsNullOrEmpty(imgUrl))
                        {
                            return Json(new { result = false, message = "來源網址錯誤!!" });
                        }
                        using (WebClient client = new WebClient())
                        {
                            client.DownloadFile(imgUrl, storePath);
                        }
                    }

                    item.Attachment = new Attachment
                    {
                        StoredPath = storePath
                    };

                    models.SubmitChanges();
                    return Json(new { result = true,pictureID = item.PictureID });
                
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<AccountController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

        public ActionResult FetchPicture(String imgUrl)
        {
            try
            {

                    String storePath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + ".dat");
                    if (Request.Form.Files.Count > 0)
                    {
                        Request.Form.Files[0].SaveAs(storePath);
                    }
                    else
                    {
                        if (String.IsNullOrEmpty(imgUrl))
                        {
                            return Json(new { result = false, message = "來源網址錯誤!!" });
                        }
                        using (WebClient client = new WebClient())
                        {
                            client.DownloadFile(imgUrl, storePath);
                        }
                    }

                    Attachment item = new Attachment
                    {
                        StoredPath = storePath
                    };

                    models.GetTable<Attachment>().InsertOnSubmit(item);

                    models.SubmitChanges();
                    return Json(new { result = true, pictureID = item.AttachmentID });
                
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<AccountController>().LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }


        [ValidateAntiForgeryToken]
        public ActionResult RegisterByFB(FBRegisterViewModel viewModel)
        {
            
            
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "學員編號錯誤!!";
                return View("Register");
            }

            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                ViewBag.Message = "學員編號已註冊!!";
                return View("Register");
            }

            viewModel.UserID = viewModel.UserID.GetEfficientString();
            if (viewModel.UserID == null)
            {
                ViewBag.Message = "無法取得您的FaceBook帳號識別碼!!";
                return View("Register");
            }

            if (item.ExternalID != viewModel.UserID && models.GetTable<UserProfile>().Any(u => u.ExternalID == viewModel.UserID))
            {
                ViewBag.Message = "您的FaceBook帳號已經是註冊使用者!!請直接登入系統!!";
                return View("Register");
            }
            item.ExternalID = viewModel.UserID;

            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail != null)
            {
                if(item.PID!=viewModel.EMail && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.EMail))
                {
                    ViewBag.Message = "您的FaceBook電子郵件已經是註冊使用者!!請直接登入系統!!";
                    return View("Register");
                }
                item.PID = viewModel.EMail;
            }
            item.UserName = viewModel.UserName.GetEfficientString();
            item.PictureID = viewModel.PictureID;
            models.SubmitChanges();

            HttpContext.SetCacheValue("UID", item.UID);

            return View(item);
        }


        
        public ActionResult RegisterByMail(RegisterViewModel viewModel)
        {
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.MemberCode == viewModel.MemberCode).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("memberCode", "學員編號錯誤!!");
                ViewBag.ModelState = ModelState;
                return View("Register", model: viewModel.MemberCode);
            }

            if (item.LevelID != (int)Naming.MemberStatusDefinition.ReadyToRegister)
            {
                ModelState.AddModelError("memberCode", "學員編號已註冊!!");
                ViewBag.ModelState = ModelState;
                return View("Register", model: viewModel.MemberCode);
            }

            HttpContext.SetCacheValue("UID", item.UID);

            ViewBag.ViewModel = viewModel;
            return View("RegisterByMail", item);
        }

        [Authorize]
        public async Task<ActionResult> ViewProfileAsync(int? id)
        {
            UserProfile item = await HttpContext.GetUserAsync();

            var profile = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (profile == null)
                profile = models.GetTable<UserProfile>().Where(u => u.UID == item.UID).First();

            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            if (profile.CurrentUserRole.RoleID == (int)Naming.RoleID.Learner)
                return View("ViewLearner", profile);
            else
                return View("ViewCoach", profile);
        }


        public async Task<ActionResult> CompleteRegisterAsync(RegisterViewModel viewModel)
        {
            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("RegisterByMail");
            }
            
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("UID")).FirstOrDefault();

            if (item == null)
            {
                this.ModelState.AddModelError("MemberCode", "會員編號錯誤!!");
                ViewBag.ModelState = ModelState;
                HttpContext.RemoveCache("UID");
                return View("Register");
            }

            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail == null)
            {
                this.ModelState.AddModelError("EMail", "請輸入Email");
                ViewBag.ModelState = ModelState;
                ViewBag.ViewModel = viewModel;
                return View("RegisterByMail", item);
            }

            if (models.GetTable<UserProfile>().Any(u => u.PID == viewModel.EMail && u.UID!=item.UID))
            {
                HttpContext.SetCacheValue("UID", null);
                ModelState.AddModelError("EMail", "您的Email已經是註冊使用者!!請直接登入系統!!");
                ViewBag.ModelState = ModelState;
                ViewBag.ViewModel = viewModel;
                return View("RegisterByMail", item);
            }

            item.PID = viewModel.EMail;
            item.UserName = viewModel.UserName.GetEfficientString();
            item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            item.UserProfileExtension.RegisterStatus = true;

            if(!this.CreatePassword(viewModel))
            {
                ViewBag.ModelState = ModelState;
                ViewBag.ViewModel = viewModel;
                return View("RegisterByMail", item);
            }

            if (!String.IsNullOrEmpty(viewModel.Password))
            {
                item.Password = (viewModel.Password).MakePassword();
            }

            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);
            
            return View(item);
        }

        public async Task<ActionResult> FBCompleteRegisterAsync(String email)
        {
            email = email.GetEfficientString();
            if (email==null)
            {
                ModelState.AddModelError("email", "請輸入Email");
                ViewBag.ModelState = ModelState;
                return View("RegisterByFB");
            }

            
            
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == (int?)HttpContext.GetCacheValue("UID")).FirstOrDefault();

            if (item == null)
            {
                ViewBag.Message = "會員編號錯誤!!";
                HttpContext.SetCacheValue("UID", null);
                return View("Register");
            }

            if (item.PID != email && models.GetTable<UserProfile>().Any(u => u.PID == email))
            {
                ViewBag.Message = "您的FaceBook電子郵件已經是註冊使用者!!請直接登入系統!!";
                return View("Register");
            }
            item.PID = email;
            item.LevelID = (int)Naming.MemberStatusDefinition.Checked;
            item.UserProfileExtension.RegisterStatus = true;

            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            return View("CompleteRegister",item);
        }


        //[CoachOrAssistantAuthorize]
        //public ActionResult CreateNew()
        //{
            

        //        try
        //        {
        //            String memberCode;

        //            while (true)
        //            {
        //                memberCode = createMemberCode();
        //                if (!models.GetTable<UserProfile>().Any(u => u.MemberCode == memberCode))
        //                {
        //                    break;
        //                }
        //            }

        //            UserProfile item = new UserProfile
        //            {
        //                PID = memberCode,
        //                MemberCode = memberCode,
        //                LevelID = (int)Naming.MemberStatusDefinition.ReadyToRegister
        //            };

        //            models.GetTable<UserProfile>().InsertOnSubmit(item);
        //            models.SubmitChanges();
        //            return Json(new { result = true, message = "新增完成!!", memberCode = memberCode });

        //        }
        //        catch (Exception ex)
        //        {
        //            ApplicationLogging.CreateLogger<AccountController>().LogError(ex, ex.Message);
        //            return Json(new { result = false, message = ex.Message });
        //        }
            
        //}

        public async Task<ActionResult> LoginByFBAsync(String accessToken,String userId)
        {
                UserProfile item = models.GetTable<UserProfile>().Where(u => u.ExternalID == userId
                    && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

                if (item != null)
                {
                    await HttpContext.SignOnAsync(item);
                    return processLogin(item, true);
                }

                return Json(new { result = false, message = "登入資料錯誤!!" });
            
        }


        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Login(LoginViewModel viewModel, string returnUrl)
        {
            //if (!ModelState.IsValid)
            //{
            //    return Json(new
            //    {
            //        result = false,
            //        errors = ModelState.Keys.Where(k => ModelState[k].Errors.Count > 0)
            //                .Select(k => new { name = k, message = ModelState[k].Errors.Select(r => r.ErrorMessage) }).ToArray()
            //    });
            //}

            //if(viewModel.PID=="**********" && Request.Cookies["userID"]!=null)
            //{
            //    viewModel.PID = Request.Cookies["userID"].Value;
            //}
            
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.PID
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("pid", "登入資料錯誤!!");
                ViewBag.ModelState = ModelState;
                return View("LoginByMail");
            }

            if (item.Password != (viewModel.Password).MakePassword())
            {
                ModelState.AddModelError("pid", "登入資料錯誤!!");
                ViewBag.ModelState = ModelState;
                return View("LoginByMail");
            }

            await HttpContext.SignOnAsync(item, viewModel.RememberMe);

            if (!String.IsNullOrEmpty(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return processLogin(item);

        }

        public async Task<ActionResult> QuickLoginAsync(LoginViewModel viewModel, string returnUrl)
        {

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.PID
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("pid", "登入資料錯誤!!");
                ViewBag.ModelState = ModelState;
                return RedirectToAction("Login", "CornerKick");
            }

            await HttpContext.SignOnAsync(item, viewModel.RememberMe);

            if (!String.IsNullOrEmpty(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return Redirect(this.ProcessLogin(item, false));

        }

        private ActionResult processLogin(UserProfile item,bool isJson = false)
        {
            switch ((Naming.RoleID)item.UserRole[0].RoleID)
            {
                case Naming.RoleID.Administrator:
                    //return RedirectToAction("Index", "CoachFacet");

                case Naming.RoleID.Coach:
                case Naming.RoleID.Manager:
                case Naming.RoleID.ViceManager:
                case Naming.RoleID.Assistant:
                    return RedirectToAction("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });

                case Naming.RoleID.Officer:
                    if (item.UserRole.Count == 1 && item.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Officer))
                    {
                        return Redirect("~/ConsoleHome/Index");
                    }
                    else
                    {
                        return RedirectToAction("Index", "CoachFacet", new { KeyID = item.UID.EncryptKey() });
                    }
                //case Naming.RoleID.Assistant:
                //    return RedirectToAction("Index", "CoachFacet");

                case Naming.RoleID.Accounting:
                    return RedirectToAction("TrustIndex", "Accounting");

                case Naming.RoleID.Learner:
                    if (isJson)
                        return Json(new { result = true, url = VirtualPathUtility.ToAbsolute("~/Account/Vip") });
                    else
                        return RedirectToAction("TimeLine", "Activity", new { uid = item.UID });

                case Naming.RoleID.Servitor:
                    return Redirect("~/ConsoleHome/Index");
                    //return RedirectToAction("PaymentIndex", "Payment");


                case Naming.RoleID.FreeAgent:
                    if (isJson)
                        return Json(new { result = true, url = VirtualPathUtility.ToAbsolute("~/Account/FreeAgent") });
                    else
                        return RedirectToAction("FreeAgent", "Account");

            }

            return View();
        }

        public ActionResult Logout(String message = null)
        {
            this.HttpContext.Logout();
            //Session.Abandon();    //=> 清除所有cookie
            ViewBag.Message = message;
            return View();
        }

        public ActionResult AlertTimeout()
        {
            return Logout();
        }


        [HttpGet]
        public ActionResult ForgetPassword()
        {
            return View();
        }

        [HttpPost]
        public ActionResult ForgetPassword(String email)
        {
            if(String.IsNullOrEmpty(email))
            {
                ModelState.AddModelError("email", "請輸入您的 email address");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            
            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == email.Trim()
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked).FirstOrDefault();

            if (item == null)
            {
                ModelState.AddModelError("email", "您提供的email資料不存在!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            ResetPassword toReset = new ResetPassword
            {
                ResetID = Guid.NewGuid(),
                UserProfile = item
            };

            models.GetTable<ResetPassword>().InsertOnSubmit(toReset);
            models.SubmitChanges();

            toReset.NotifyResetPassword();

            ViewBag.Success = "重設密碼通知郵件已寄出。";

            return View("~/Views/Shared/Success.ascx");

        }

        [HttpGet]
        public ActionResult ResetPass(Guid id)
        {
            
            UserProfile item = models.GetTable<ResetPassword>().Where(r => r.ResetID == id)
                .Select(r => r.UserProfile)
                .Where(u => u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                .FirstOrDefault();

            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            PasswordViewModel viewModel = new PasswordViewModel
            {
                PID = item.PID
            };

            ViewBag.ViewModel = viewModel;
            return View(item);

        }

        [HttpPost]
        public ActionResult ResetPass(PasswordViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.PID == viewModel.PID
                && u.LevelID == (int)Naming.MemberStatusDefinition.Checked)
                .FirstOrDefault();

            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }
            ViewBag.ModelState = this.ModelState;

            if (!this.CreatePassword(viewModel))
                return View(item);

            item.Password = (viewModel.Password).MakePassword();
            //models.DeleteAllOnSubmit<ResetPassword>(r => r.UID == item.UID);
            models.SubmitChanges();

            return View("CompleteResetPass", item);

        }

        //private bool CreatePassword(PasswordViewModel viewModel)
        //{
        //    if (String.IsNullOrEmpty(viewModel.lockPattern))
        //    {
        //        if (String.IsNullOrEmpty(viewModel.Password))
        //        {
        //            ModelState.AddModelError("password", "請輸入密碼!!");
        //            return false;
        //        }
        //        else if (viewModel.Password != viewModel.Password2)
        //        {
        //            ModelState.AddModelError("password2", "密碼確認錯誤!!");
        //            return false;
        //        }
        //    }
        //    else
        //    {
        //        viewModel.Password = viewModel.lockPattern;
        //    }
        //    return true;
        //}

        public async Task<ActionResult> VipAsync(DateTime? lessonDate,DateTime? endQueryDate)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }
            if (!lessonDate.HasValue)
                lessonDate = DateTime.Today.AddYears(-1);
            if (!endQueryDate.HasValue)
                endQueryDate = lessonDate.Value.AddYears(1);

            ViewBag.LessonDate = lessonDate;
            ViewBag.EndQueryDate = endQueryDate;

            return View(item);
        }

        public async Task<ActionResult> EditVipAsync(int id,DateTime? lessonDate)
        {
            UserProfile profile = await HttpContext.GetUserAsync();
            if (profile == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == id).FirstOrDefault();
            if (item == null)
            {
                ViewBag.Message = "學員資料不存在!!";
                return RedirectToAction("Coach");
            }

            RegisterViewModel model = new RegisterViewModel
            {
                EMail = item.PID.Contains("@") ? item.PID : null,
                MemberCode = item.MemberCode,
                PictureID = item.PictureID,
                UserName = item.UserName
            };

            ViewBag.LessonDate = lessonDate.HasValue ? lessonDate : DateTime.Today;
            return View("EditMySelf", model);
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public async Task<ActionResult> CoachAsync(DailyBookingQueryViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            //if (item == null)
            //{
            //    return Redirect($"~{Startup.Properties["LoginUrl"]}");
            //}

            ViewBag.ViewModel = viewModel;

            if (!viewModel.LessonDate.HasValue)
            {
                viewModel.LessonDate = DateTime.Today;
            }

            return View("Coach", item);
        }

        public async Task<ActionResult> FreeAgentAsync(DateTime? lessonDate, DateTime? endQueryDate,String message=null)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            if (ViewBag.LessonDate == null)
            {
                if (!lessonDate.HasValue)
                    lessonDate = DateTime.Today;

                ViewBag.LessonDate = lessonDate;
            }
            ViewBag.EndQueryDate = endQueryDate;
            ViewBag.Message = message;

            return View(item);
        }

        public async Task<ActionResult> FreeAgentClockInAsync()
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return new EmptyResult();
            }

            return View(item);
        }



        [HttpGet]
        public async Task<ActionResult> EditMySelfAsync()
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            RegisterViewModel model = new RegisterViewModel
            {
                EMail = item.PID.Contains("@") ? item.PID : null,
                MemberCode = item.MemberCode,
                PictureID = item.PictureID,
                UserName = item.UserName,
                Birthday = item.Birthday,
                UID = item.UID
            };

            return View(model);
        }


        public async Task<ActionResult> EditMySelfAsync(RegisterViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("EditMySelf");
            }

            int uid = item.UID;
            item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();

            if (item == null)
            {
                return Redirect($"~{Startup.Properties["LoginUrl"]}");
            }
            viewModel.PictureID = item.PictureID;
            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail == null)
            {
                this.ModelState.AddModelError("email", "請輸入Email");
                ViewBag.ModelState = ModelState;
                return View(viewModel);
            }

            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail != null)
            {
                if (item.PID != viewModel.EMail && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.EMail))
                {
                    ViewBag.Message = "您的Email已經是註冊使用者!!請重新設定Email!!";
                    return View(viewModel);
                }
                item.PID = viewModel.EMail;
            }

            item.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.Birthday.HasValue)
            {
                item.Birthday = viewModel.Birthday;
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;
            }

            if (!this.CreatePassword(viewModel))
                return View(viewModel);
            item.Password = (viewModel.Password).MakePassword();

            models.SubmitChanges();

            await HttpContext.SignOnAsync(item);

            return View("CompleteRegister", item);
        }

        public ActionResult NotifyResetPassword(String resetID)
        {
            return View("NotifyResetPassword", (object)resetID);
        }

        public ActionResult GetLoginPhoto()
        {
            return View("~/Views/Html/Module/LoginPhoto.ascx");
        }

        [Authorize]
        public ActionResult CheckProfessionalLevel(int? coachID)
        {
            var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == coachID).FirstOrDefault();
            if (coach == null)
            {
                foreach (var item in models.PromptEffectiveCoach())
                {
                    models.CheckProfessionalLevel2020(item);
                }
            }
            else
            {
                models.CheckProfessionalLevel2020(coach);
            }
            return new EmptyResult();
        }

        public ActionResult UserSignature(UserSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<UserProfileExtension>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            return View("~/Views/Account/Module/UserSignature.ascx", item);
        }
        public ActionResult UserSignaturePanel(UserSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/Account/Module/UserSignaturePanel.ascx");
        }

        public ActionResult CommitSignature(UserSignatureViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<UserProfileExtension>().Where(s => s.UID == viewModel.UID).FirstOrDefault();

            if (item != null)
            {
                item.Signature = viewModel.Signature;
                models.SubmitChanges();
            }

            return Json(new { result = true });
        }

        public ActionResult ResetPassword(PasswordViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = null;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
                item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            }

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            item.Password = (viewModel.Password).MakePassword();
            models.SubmitChanges();

            return Json(new { result = true });

        }

        public async Task<ActionResult> ToEditPaymentForContractAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null && item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
            {
                await HttpContext.SignOnAsync(item);
                return Redirect(Url.Action("EditPaymentForContract", "ConsoleHome", viewModel));
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }

        }
        public async Task<ActionResult> ToSignCourseContractAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null && item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
            {
                await HttpContext.SignOnAsync(item);
                return Redirect(Url.Action("SignCourseContract", "ConsoleHome", viewModel));
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }

        public async Task<ActionResult> ToSignContractServiceAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null && item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
            {
                await HttpContext.SignOnAsync(item);
                return Redirect(Url.Action("SignContractService", "ConsoleHome", viewModel));
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }

        public async Task<ActionResult> ToApplyContractServiceAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null && item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
            {
                await HttpContext.SignOnAsync(item);
                return Redirect(Url.Action("ApplyContractService", "ConsoleHome", viewModel));
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }

        public async Task<ActionResult> ToEditCourseContractAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null && item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
            {
                await HttpContext.SignOnAsync(item);
                return Redirect(Url.Action("EditCourseContract", "ConsoleHome", viewModel));
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }

        public async Task<ActionResult> ToConsoleCalendarAsync(DailyBookingQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null && item.LevelID == (int)Naming.MemberStatusDefinition.Checked)
            {
                await HttpContext.SignOnAsync(item);
                return Redirect(Url.Action("Calendar", "ConsoleHome", viewModel));
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }

        public async Task<ActionResult> UpdateProfileImageAsync(CoachViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();

            if (item == null)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            String storePath = Path.Combine(FileLogger.Logger.LogDailyPath, Guid.NewGuid().ToString() + ".dat");
            if (Request.Form.Files.Count > 0)
            {
                Request.Form.Files[0].SaveAs(storePath);
            }
            else
            {
                return Json(new { result = false, message = "請選擇圖像檔!!" });
            }

            item = item.LoadInstance(models);
            if (item.Attachment == null)
            {
                item.Attachment = new Attachment
                {

                };
            }

            item.Attachment.StoredPath = storePath;
            models.SubmitChanges();

            return Json(new { result = true, pictureID = item.PictureID });
        }

        public async Task<ActionResult> CommitProfileAsync(RegisterViewModel viewModel)
        {
            UserProfile item = await HttpContext.GetUserAsync();
            ModelState.Clear();
            if (item == null)
            {
                ModelState.AddModelError("Message", "資料錯誤!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            viewModel.EMail = viewModel.EMail.GetEfficientString();
            if (viewModel.EMail == null)
            {
                ModelState.AddModelError("EMail", "請輸入EMAIL");
            }
            else if (!Regex.IsMatch(viewModel.EMail, @"^([\w-]+\.)*?[\w-]+@[\w-]+\.([\w-]+\.)*?[\w]+$"))
            {
                ModelState.AddModelError("EMail", "EMAIL格式錯誤");
            }

            if (ModelState.IsValid)
            {
                if (item.PID != viewModel.EMail && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.EMail))
                {
                    ModelState.AddModelError("EMail", "EMAIL重複");
                }
            }

            this.CreatePassword(viewModel);

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            item = item.LoadInstance(models);
            item.PID = viewModel.EMail;
            item.Password = (viewModel.Password).MakePassword();

            models.SubmitChanges();

            return Json(new { result = true });
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant })]
        public ActionResult CommitPID(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            UserProfile item = null;
            viewModel.PID = viewModel.PID.GetEfficientString();
            if (viewModel.PID == null || !viewModel.PID.IsEmail())
            {
                ModelState.AddModelError("PID", "請輸入正確email!!");
            }
            else
            {
                if (viewModel.KeyID != null)
                {
                    viewModel.UID = viewModel.DecryptKeyValue();
                }

                item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
                if (item == null)
                {
                    ViewBag.AlertError = true;
                    ModelState.AddModelError("Message", "資料錯誤!!");
                }
            }


            if (ModelState.IsValid)
            {
                if (item.PID != viewModel.PID && models.GetTable<UserProfile>().Any(u => u.PID == viewModel.PID))
                {
                    ModelState.AddModelError("PID", "EMAIL重複");
                }
            }

            if (!ModelState.IsValid)
            {
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            item.PID = viewModel.PID;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant })]
        public ActionResult CommitToResetPassword(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if(viewModel.KeyID!=null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                ViewBag.AlertError = true;
                ModelState.AddModelError("Message", "資料錯誤!!");
            }

            if (!ModelState.IsValid)
            {
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            item.Password = ("BEYOND").MakePassword();
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant })]
        public ActionResult CommitToUnbind(RegisterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null)
            {
                ViewBag.AlertError = true;
                ModelState.AddModelError("Message", "資料錯誤!!");
            }

            if (!ModelState.IsValid)
            {
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            item.UserProfileExtension.LineID = null;
            models.SubmitChanges();

            return Json(new { result = true });
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Assistant })]
        public ActionResult CommitUserStatus(UserProfileViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile item = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (item == null || !viewModel.LevelID.HasValue)
            {
                ViewBag.AlertError = true;
                ModelState.AddModelError("Message", "資料錯誤!!");
            }

            if (!ModelState.IsValid)
            {
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            item.LevelID = viewModel.LevelID;
            if (viewModel.LevelID == (int)Naming.MemberStatusDefinition.Deleted)
            {
                item.UserProfileExtension.LineID = null;
            }
            models.SubmitChanges();

            return Json(new { result = true });
        }


    }
}