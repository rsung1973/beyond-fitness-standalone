using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Policy;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace WebHome
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            routes.IgnoreRoute("");

            //routes.MapRoute(
            //    name: "Blog",
            //    url: "single-post",
            //    defaults: new { controller = "MainActivity", action = "BlogSingle" }
            //);

            routes.MapRoute(
                name: "Official",
                url: "Official/{action}/{id}/{keyID}",
                defaults: new { controller = "MainActivity", action = "Index", id = UrlParameter.Optional, keyID = UrlParameter.Optional }
            );

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Account", action = "Index", id = UrlParameter.Optional }
            );

        }
    }
}
