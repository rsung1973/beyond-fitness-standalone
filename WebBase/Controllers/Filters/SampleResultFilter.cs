using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebHome.Controllers.Filters
{
    public class SampleResultFilter : IResultFilter
    {
        public void OnResultExecuted(ResultExecutedContext context)
        {
            //var urlHelperFactory = context.HttpContext.RequestServices.GetRequiredService<IUrlHelperFactory>();
            //var actionContext = context.HttpContext.RequestServices.GetRequiredService<IActionContextAccessor>().ActionContext;
            //var urlHelper = urlHelperFactory.GetUrlHelper(actionContext);
        }

        public void OnResultExecuting(ResultExecutingContext context)
        {
            //var urlHelper = context.HttpContext.RequestServices.GetRequiredService<IUrlHelper>();
        }
    }
}
