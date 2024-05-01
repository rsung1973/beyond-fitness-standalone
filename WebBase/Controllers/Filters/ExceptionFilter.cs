using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;
using WebHome.Helper;

namespace WebHome.Controllers.Filters
{
    public class ExceptionFilter : IExceptionFilter
    {
        public void OnException(ExceptionContext filterContext)
        {
            var actionContext = filterContext.HttpContext.RequestServices.GetRequiredService<IActionContextAccessor>().ActionContext;
            var urlHelper = new UrlHelper(actionContext);
            //IUrlHelper urlHelper = new UrlHelper(new ActionContext(filterContext.HttpContext, filterContext.RouteData, filterContext.ActionDescriptor));
            //var urlHelper = filterContext.HttpContext.RequestServices.GetRequiredService<IUrlHelper>();

            if (filterContext.Exception is CryptographicException)
            {
                filterContext.Result = new RedirectToActionResult("InvalidCrypto", "Error", null);
            }
            else
            {
                if (filterContext.Exception != null)
                {
                    ApplicationLogging.CreateLogger<ExceptionFilter>().LogError(filterContext.Exception, filterContext.Exception.Message);
                }
                filterContext.Result = new RedirectToActionResult("Error", "CornerKick", null);
                //filterContext.HttpContext.Response.Redirect(urlHelper.Action("Error", "CornerKick"));
            }
        }
    }
}
