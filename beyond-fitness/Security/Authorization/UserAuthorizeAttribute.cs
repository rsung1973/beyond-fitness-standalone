using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;

using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

namespace WebHome.Security.Authorization
{
    public class UserAuthorizeAttribute : AuthorizeAttribute
    {
        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            base.OnAuthorization(filterContext);
            if (HttpContext.Current.User.Identity.IsAuthenticated)
            {
                //用父類別的驗證，判斷是否在角色內
                if (!AuthorizeCore(filterContext.HttpContext))
                {
                    filterContext.Result = new RedirectToRouteResult(
                        new RouteValueDictionary
                        {
                                { "controller", "Account" },
                                { "action", "Login" },
                                { "id", UrlParameter.Optional }
                        });
                }
            }
            else
            {
                // 未登入，轉至登入頁面
                string rtURL = "";
                rtURL = filterContext.HttpContext.Request.RawUrl;
                filterContext.Result = new RedirectToRouteResult(new RouteValueDictionary
                {
                    { "controller", "Account" },
                    { "action", "Login" },
                    { "ReturnUrl", rtURL }
                });
            }
        }

        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            filterContext.Result = new RedirectToRouteResult(
                new RouteValueDictionary
                {
                                { "controller", "Account" },
                                { "action", "Login" },
                                { "id", UrlParameter.Optional }
                });
        }
    }

    public class AuthorizedSysAdminAttribute : UserAuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if(!base.AuthorizeCore(httpContext))
            {
                return false;
            }

            return httpContext.GetUser().IsAuthorizedSysAdmin();

        }
    }

    public class CoachAuthorizeAttribute : UserAuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (!base.AuthorizeCore(httpContext))
            {
                return false;
            }

            return httpContext.GetUser().IsCoach();

        }
    }

    public class LearnerAuthorizeAttribute : UserAuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (!base.AuthorizeCore(httpContext))
            {
                return false;
            }

            return httpContext.GetUser().IsLearner();

        }
    }

    public class CoachOrSysAdminAuthorizeAttribute : UserAuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (!base.AuthorizeCore(httpContext))
            {
                return false;
            }
            var profile = httpContext.GetUser();
            return profile.IsSysAdmin() || profile.IsCoach();

        }
    }

    public class CoachOrAssistantAuthorizeAttribute : UserAuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (!base.AuthorizeCore(httpContext))
            {
                return false;
            }
            var profile = httpContext.GetUser();
            return profile.IsAssistant() || profile.IsCoach();

        }
    }

    public class AssistantOrSysAdminAuthorizeAttribute : UserAuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (!base.AuthorizeCore(httpContext))
            {
                return false;
            }
            var profile = httpContext.GetUser();
            return profile.IsSysAdmin() || profile.IsAssistant();

        }
    }

    public class RoleAuthorizeAttribute : UserAuthorizeAttribute
    {
        public int[] RoleID { get; set;}
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (!base.AuthorizeCore(httpContext))
            {
                return false;
            }

            return httpContext.GetUser().IsAuthorized(RoleID);

        }
    }

}