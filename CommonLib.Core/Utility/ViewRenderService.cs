using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Abstractions;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace CommonLib.Core.Utility
{
    public interface IViewRenderService
    {
        Task<string> RenderToStringAsync(string viewName, object model);
        HttpContext? HttpContext { get; set; }
        ActionContext? ActionContext { get; set; }
    }

    public class ViewRenderService : IViewRenderService
    {
        private readonly IRazorViewEngine _razorViewEngine;
        private readonly ITempDataProvider _tempDataProvider;
        private readonly IServiceProvider _serviceProvider;
        private readonly IActionContextAccessor _contextAccessor;

        public ViewRenderService(IRazorViewEngine razorViewEngine,
            ITempDataProvider tempDataProvider,
            IServiceProvider serviceProvider,
            IActionContextAccessor contextAccessor)
        {
            _razorViewEngine = razorViewEngine;
            _tempDataProvider = tempDataProvider;
            _serviceProvider = serviceProvider;
            _contextAccessor = contextAccessor;

            ActionContext = _contextAccessor.ActionContext;
            HttpContext = _contextAccessor.ActionContext?.HttpContext;
        }

        public ActionContext? ActionContext { get; set; }
        public HttpContext? HttpContext { get; set; }

        public async Task<string> RenderToStringAsync(string viewName, object model)
        {
            if (HttpContext == null)
            {
                HttpContext = new DefaultHttpContext { RequestServices = _serviceProvider };
            }

            if (ActionContext == null)
            {
                ActionContext = new ActionContext(HttpContext, new RouteData(), new ActionDescriptor());
            }

            using (var sw = new StringWriter())
            {

                var viewResult = _razorViewEngine.GetView("", viewName, false);

                if (viewResult.View == null)
                {
                    throw new ArgumentNullException($"{viewName} does not match any available view");
                }

                var viewDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), ActionContext.ModelState ?? new ModelStateDictionary())
                {
                    Model = model
                };

                var factory = HttpContext?.RequestServices?.GetRequiredService<ITempDataDictionaryFactory>();
                var tempData = factory?.GetTempData(HttpContext) ?? new TempDataDictionary(HttpContext!, _tempDataProvider);

                var viewContext = new ViewContext(
                    ActionContext,
                    viewResult.View,
                    viewDictionary,
                    tempData,
                    sw,
                    new HtmlHelperOptions()
                );

                viewContext.HttpContext = HttpContext;

                await viewResult.View.RenderAsync(viewContext);
                return sw.ToString();
            }
        }
    }

    //public class ViewRenderService : IViewRenderService
    //{
    //    private readonly IRazorViewEngine _razorViewEngine;
    //    private readonly ITempDataProvider _tempDataProvider;
    //    private readonly IServiceProvider _serviceProvider;


    //    public ViewRenderService(IRazorViewEngine razorViewEngine,
    //        ITempDataProvider tempDataProvider,
    //        IServiceProvider serviceProvider)
    //    {
    //        _razorViewEngine = razorViewEngine;
    //        _tempDataProvider = tempDataProvider;
    //        _serviceProvider = serviceProvider;
    //    }

    //    public ActionContext ActionContext { get; set; }
    //    public HttpContext HttpContext { get; set; } 

    //    public async Task<string> RenderToStringAsync(string viewName, object model)
    //    {
    //        if (HttpContext == null)
    //        {
    //            HttpContext = new DefaultHttpContext { RequestServices = _serviceProvider };
    //        }

    //        if (ActionContext == null)
    //        {
    //            ActionContext = new ActionContext(HttpContext, new RouteData(), new ActionDescriptor());
    //        }

    //        using (var sw = new StringWriter())
    //        {
    //            if (viewName.StartsWith("~/Views/", StringComparison.CurrentCultureIgnoreCase))
    //            {
    //                viewName = viewName.Replace("~/Views/", "", StringComparison.CurrentCultureIgnoreCase);
    //            }

    //            if (viewName.EndsWith(".cshtml", StringComparison.CurrentCultureIgnoreCase))
    //            {
    //                viewName = viewName.Replace(".cshtml", "", StringComparison.CurrentCultureIgnoreCase);
    //            }

    //            var viewResult = _razorViewEngine.FindView(ActionContext, viewName, false);

    //            if (viewResult.View == null)
    //            {
    //                throw new ArgumentNullException($"{viewName} does not match any available view");
    //            }

    //            var viewDictionary = new ViewDataDictionary(new EmptyModelMetadataProvider(), new ModelStateDictionary())
    //            {
    //                Model = model
    //            };

    //            var viewContext = new ViewContext(
    //                ActionContext,
    //                viewResult.View,
    //                viewDictionary,
    //                new TempDataDictionary(HttpContext, _tempDataProvider),
    //                sw,
    //                new HtmlHelperOptions()
    //            );

    //            viewContext.HttpContext = HttpContext;

    //            await viewResult.View.RenderAsync(viewContext);
    //            return sw.ToString();
    //        }
    //    }
    //}
}