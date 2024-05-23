using System;
using System.Collections.Generic;
using System.Data;

using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using WebHome.Properties;
using System.Net.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Http;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Mvc.ViewEngines;

namespace WebHome.Controllers
{
    public class ActivityBaseController : SampleController<UserProfile>
    {
        public const String DefaultLanguage = "zh-TW";
        protected readonly ICompositeViewEngine _viewEngine;
        public ActivityBaseController(IServiceProvider serviceProvider) : base(serviceProvider)
        {
            _viewEngine = serviceProvider.GetService<ICompositeViewEngine>();
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            base.OnActionExecuting(context);

            var lang = Request.Cookies["cLang"];
            if (lang == null)
            {
                lang = AppSettings.Default.Language;
                //lang = Request.Headers.AcceptLanguage.Contains("zh")
                //                ? "zh-TW"
                //                : Request.Headers.AcceptLanguage.Contains("en")
                //                    ? "en-US"
                //                    : Request.Headers.AcceptLanguage.Contains("ja")
                //                        ? "ja"
                //                        : AppSettings.Default.Language;
                lang.SelectUICulture();
            }
            ViewBag.Lang = lang;
        }

        public ActionResult ChangeLanguage(String lang)
        {
            Response.Cookies.Append("cLang", lang);
            Response.Cookies.Append("setLang", lang);
            return Json(new { result = true, message = System.Globalization.CultureInfo.CurrentCulture.Name });
        }

        protected ViewEngineResult CheckView(String actionName)
        {
            ViewEngineResult viewResult = _viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Page.{Lang}/{actionName}.cshtml", isMainPage: false);
            if (!viewResult.Success)
            {
                viewResult = _viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Module/{actionName}.cshtml", isMainPage: false);
            }
            if (!viewResult.Success)
            {
                viewResult = _viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Page.zh-TW/{actionName}.cshtml", isMainPage: false);
            }
            if (!viewResult.Success)
            {
                viewResult = _viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/Page.zh-TW/Module/{actionName}.cshtml", isMainPage: false);
            }
            return viewResult;
        }

        protected ActionResult CheckLanguageRoute()
        {
            var lang = RouteData.Values["lang"] as String;
            if (lang == "tw" || lang == "en" || lang == "ja")
            {
                if ((ViewBag.Lang as String).Contains(lang))
                {
                    return null;
                }
                else
                {
                    if (Request.Cookies["setLang"] != null)
                    {
                        Response.Cookies.Delete("setLang");
                        lang = ViewBag.Lang == "zh-TW"
                                ? "tw"
                                : ViewBag.Lang == "en-US"
                                    ? "en"
                                    : "ja";
                    }
                    else
                    {
                        ViewBag.Lang = lang == "tw"
                                ? "zh-TW"
                                : lang == "en"
                                    ? "en-US"
                                    : "ja";
                    }

                    Response.Cookies.Append("cLang", (String)ViewBag.Lang);
                    return null;

                }
            }
            else
            {
                if (ViewBag.Lang != null)
                {
                    return null;
                }

                lang = "tw";
                //lang = Request.Headers.AcceptLanguage.Contains("zh")
                //                    ? "tw"
                //                    : Request.Headers.AcceptLanguage.Contains("en")
                //                        ? "en"
                //                        : Request.Headers.AcceptLanguage.Contains("ja")
                //                            ? "ja"
                //                            : "tw";

            }

            return Redirect($"~/{(RouteData.Values["controller"] as String == "MainActivity" ? "Official" : RouteData.Values["controller"])}/{lang}/{RouteData.Values["actionName"] ?? RouteData.Values["action"]}{Request.QueryString}");
        }

        public ActionResult HandleUnknownAction(string actionName, IFormCollection forms, QueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            //string viewName = "YourViewName"; // 替换为你要检查的视图名称
            //string viewPath = "/Views/YourFolder/" + viewName + ".cshtml"; // 替换为你的视图路径

            //ViewEngineResult viewResult = _viewEngine.GetView("~/", $"/Views/{RouteData.Values["controller"]}/{actionName}.cshtml", isMainPage: false);
            ViewEngineResult viewResult = CheckView(actionName);

            if (viewResult.Success)
            {
                // 视图存在
                return CheckLanguageRoute() ?? View(viewResult.ViewName, forms);
            }
            else
            {
                if (actionName != null && System.IO.Path.GetExtension(actionName).Length > 0)
                {
                    return NotFound();
                }
                else
                {
                    // 视图不存在
                    return Index();
                }
            }

            //this.View(actionName).ExecuteResult(this.ControllerContext);
        }

        // GET: MainActivity
        public ActionResult Index()
        {
            ViewEngineResult viewResult = CheckView("Index");
            return CheckLanguageRoute() ?? View(viewResult.ViewName);
        }

        protected String Lang
        {
            get
            {
                return ViewBag.Lang ?? "zh-TW";
            }
        }

    }
}