using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;
using System;
using System.Globalization;
using System.IO;
using System.Threading.Tasks;

namespace CommonLib.Core.Controllers
{
    public class SampleController : Controller
    {
        protected SampleController(IServiceProvider serviceProvider) : base()
        {
            ServiceProvider = serviceProvider;
        }

        public IServiceProvider ServiceProvider
        {
            get;
            private set;
        }

        private IViewRenderService? _viewRenderService;

        public async Task<string> RenderViewToStringAsync(String viewName, object model)
        {
            if (_viewRenderService == null)
            {
                _viewRenderService = ServiceProvider.GetRequiredService<IViewRenderService>();
                _viewRenderService.HttpContext = this.HttpContext;
                //_viewRenderService.ActionContext = ServiceProvider.GetRequiredService<IActionContextAccessor>().ActionContext;
            }
            return await _viewRenderService.RenderToStringAsync(viewName, model);
        }

        protected async Task<string> DumpAsync(bool includeHeader = true)
        {
            String fileName = Path.Combine(FileLogger.Logger.LogDailyPath, $"request{DateTime.Now.Ticks}.txt");
            await Request.SaveAsAsync(fileName, includeHeader);
            return fileName;
        }

        String? _reqeustBody;
        public String RequestBody
        {
            get
            {
                if (_reqeustBody == null)
                {
                    var t = Request.GetRequestBodyAsync();
                    t.Wait();
                    _reqeustBody = t.Result;
                }
                return _reqeustBody;
            }
        }

        public async Task<T> PrepareViewModelAsync<T>()
            where T : class
        {
            T? viewModel = null;

            if (Request.Method == HttpMethods.Post)
            {
                if (Request.ContentType?.Contains("application/json", StringComparison.InvariantCultureIgnoreCase) == true)
                {
                    // 嘗試 JSON body
                    //try
                    //{
                    //    viewModel = await Request.ReadFromJsonAsync<T>();
                    //}
                    //catch (Exception ex)
                    //{
                    //    FileLogger.Logger.Error(ex);
                    //    // 若不是 JSON，嘗試 form
                    //}
                    viewModel = JsonConvert.DeserializeObject<T>(RequestBody)!;
                }

                if (viewModel == null)
                {
                    viewModel = Activator.CreateInstance<T>();
                    await TryUpdateModelAsync(viewModel, prefix: "", valueProvider: new FormValueProvider(BindingSource.Form, Request.Form, CultureInfo.CurrentCulture));
                }
            }
            else if (Request.Method == HttpMethods.Get)
            {
                // GET 用 query string
                viewModel = Activator.CreateInstance<T>();
                await TryUpdateModelAsync(viewModel, prefix: "", valueProvider: new QueryStringValueProvider(BindingSource.Query, Request.Query, CultureInfo.CurrentCulture));
            }

            //if (Request.ContentType?.Contains("application/json", StringComparison.InvariantCultureIgnoreCase) == true)
            //{
            //    viewModel = JsonConvert.DeserializeObject<T>(RequestBody)!;
            //}
            //else
            //{
            //    viewModel = Activator.CreateInstance<T>();
            //    await this.TryUpdateModelAsync<T>(viewModel);
            //}

            ViewBag.ViewModel = viewModel;
            return viewModel!;
        }

        public T? FromJsonBody<T>()
            where T : class
        {
            return JsonConvert.DeserializeObject<T>(RequestBody);
        }

        public void BuildViewModel(object viewModel)
        {
            var t = this.TryUpdateModelAsync(viewModel, viewModel.GetType(), String.Empty);
            t.Wait();
        }

        protected ViewEngineResult CheckView(String actionName)
        {
            ICompositeViewEngine viewEngine = ServiceProvider.GetRequiredService<ICompositeViewEngine>();
            ViewEngineResult viewResult = viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/{actionName}.cshtml", isMainPage: false);
            if (!viewResult.Success)
            {
                viewResult = viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Module/{actionName}.cshtml", isMainPage: false);
            }
            if (!viewResult.Success)
            {
                viewResult = viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Page/{actionName}.cshtml", isMainPage: false);
            }
            if (!viewResult.Success)
            {
                viewResult = viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Page/Module/{actionName}.cshtml", isMainPage: false);
            }
            return viewResult;
        }

        [AllowAnonymous]
        public ActionResult HandleUnknownAction(string actionName, IFormCollection forms)
        {
            ViewEngineResult viewResult = CheckView(actionName);

            if (viewResult.Success)
            {
                // 视图存在
                return View(viewResult.ViewName, forms);
            }
            else
            {
                return NotFound();
            }
            //this.View(actionName).ExecuteResult(this.ControllerContext);
        }

        public IHtmlHelper<dynamic> GetHtmlHelper(String viewName)
        {
            var htmlHelper = ServiceProvider.GetRequiredService<IHtmlHelper<dynamic>>();
            
            // 設置 ViewContext 以便 HtmlHelper 能正常工作
            if (htmlHelper is IViewContextAware viewContextAware)
            {
                viewContextAware.Contextualize(CreateViewContext(viewName));
            }
            
            return htmlHelper;
        }

        public ViewContext CreateViewContext(String viewName)
        {
            // 獲取必要的服務
            var tempDataProvider = ServiceProvider.GetRequiredService<ITempDataProvider>();
            var viewEngine = ServiceProvider.GetRequiredService<ICompositeViewEngine>();

            if (viewName.StartsWith("~/Views/", StringComparison.CurrentCultureIgnoreCase))
            {
                viewName = viewName.Replace("~/Views/", "", StringComparison.CurrentCultureIgnoreCase);
            }

            if (viewName.EndsWith(".cshtml", StringComparison.CurrentCultureIgnoreCase))
            {
                viewName = viewName.Replace(".cshtml", "", StringComparison.CurrentCultureIgnoreCase);
            }

            var viewResult = viewEngine.FindView(ControllerContext, viewName, false);

            if (viewResult.View == null)
            {
                throw new ArgumentNullException($"{viewName} does not match any available view");
            }
            // 創建 ViewData 字典
            var viewData = new ViewDataDictionary(
                metadataProvider: new EmptyModelMetadataProvider(),
                modelState: new ModelStateDictionary());
            
            // 創建 TempData 字典
            var tempData = new TempDataDictionary(
                HttpContext,
                tempDataProvider);
            
            // 創建 ViewContext
            var viewContext = new ViewContext(
                actionContext: ControllerContext,
                view: viewResult.View, // 可以通過 viewEngine.GetView 或 viewEngine.FindView 設置具體視圖
                viewData: viewData,
                tempData: tempData,
                writer: new System.IO.StringWriter(),
                htmlHelperOptions: new HtmlHelperOptions());
            
            return viewContext;
        }
    }

}
