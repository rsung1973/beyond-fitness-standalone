using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;
using Utility;

namespace WebHome
{
    public class MvcApplication : System.Web.HttpApplication
    {
        public MvcApplication() :base()
        {
            this.AuthenticateRequest += Global_AuthenticateRequest;
            this.AuthorizeRequest += Global_AuthorizeRequest;
        }

        private void Global_AuthorizeRequest(object sender, EventArgs e)
        {

        }

        private void Global_AuthenticateRequest(object sender, EventArgs e)
        {
            if (Context.User == null)
            {
                HttpCookie cookie = Context.Request.Cookies[FormsAuthentication.FormsCookieName];
                if (cookie != null && !String.IsNullOrEmpty(cookie.Value))
                {
                    FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(cookie.Value);
                    FormsIdentity identity = new FormsIdentity(ticket);
                    Context.User = new ClaimsPrincipal(identity);
                }
            }
        }

        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs
            var ex = Server.GetLastError();
            if (ex != null)
                Logger.Error(ex);
        }
    }
}
