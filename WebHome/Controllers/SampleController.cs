using CommonLib.DataAccess;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using WebHome.Models.DataEntity;
using Microsoft.AspNetCore.Mvc.Infrastructure;

namespace WebHome.Controllers
{

    public class SampleController<TEntity> : Controller
        where TEntity : class, new()
    {
        protected internal ModelSource<TEntity> _dataSource;

        protected internal bool _dbInstance;
        protected internal GenericManager<BFDataContext> models;

        protected SampleController(IServiceProvider serviceProvider) : base()
        {
            ServiceProvider = serviceProvider;
        }

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);
            models.Dispose();
        }

        public ModelSource<TEntity> DataSource => _dataSource;

        public IServiceProvider ServiceProvider
        {
            get;
            private set;
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            models = HttpContext.Items["__DB_Instance"] as GenericManager<BFDataContext>;
            if (models == null)
            {
                models = new GenericManager<BFDataContext>();
                _dbInstance = true;
                HttpContext.Items["__DB_Instance"] = models;
            }

            _dataSource = new ModelSource<TEntity>(models);
            HttpContext.Items["Models"] = DataSource;

            var lang = Request.Cookies["cLang"];
            if (lang != null)
            {
                var cultureInfo = new CultureInfo(lang);
                Thread.CurrentThread.CurrentUICulture = cultureInfo;
                Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(cultureInfo.Name);
                ViewBag.Lang = lang;
            }
        }

        private IViewRenderService _viewRenderService;

        public async Task<string> RenderViewToStringAsync(String viewName,object model)
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
    }
}