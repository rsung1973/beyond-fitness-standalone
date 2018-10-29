using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.Http;
using Utility;
using System.Security.Claims;
using WebHome.Helper.Jobs;

namespace WebHome
{
    public class Global : HttpApplication
    {

        public Global() : base()
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

        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }

        void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs
            var ex = Server.GetLastError();
            if (ex != null)
                Logger.Error(ex);
        }
    }
}