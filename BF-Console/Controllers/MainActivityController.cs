using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

using CommonLib.DataAccess;
using CommonLib.MvcExtension;
using Newtonsoft.Json;
using Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace BFConsole.Controllers
{
    public class MainActivityController : SampleController<UserProfile>
    {
        public const String DefaultLanguage = "zh-TW";
        // GET: MainActivity
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult ChangeLanguate(String lang)
        {
            Response.SetCookie(new HttpCookie("cLang", lang));
            return Json(new { result = true, message = System.Globalization.CultureInfo.CurrentCulture.Name }, JsonRequestBehavior.AllowGet);
        }

        protected override void HandleUnknownAction(string actionName)
        {
            this.View(actionName).ExecuteResult(this.ControllerContext);
        }

        public ActionResult CoachDetails(CoachItem viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult Team(String branchName)
        {
            ViewBag.BranchName = branchName = branchName.GetEfficientString();
            CoachData model = null;
            String jsonFile = Server.MapPath($"~/MainActivity/Portfolio/{branchName}.json");
            if (System.IO.File.Exists(jsonFile))
            {
                var jsonData = System.IO.File.ReadAllText(jsonFile);
                model = JsonConvert.DeserializeObject<CoachData>(jsonData);
            }

            if (model == null)
            {
                return Index();
            }
            else
            {
                return View(model);
            }
        }

        public ActionResult BlogArticleList(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var items = models.GetTable<BlogArticle>()
                .Where(b => b.BlogTag.Any(c => c.CategoryID == viewModel.CategoryID));
            return View(items);
        }

        public ActionResult BlogSingle(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(viewModel.KeyID!=null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<BlogArticle>().Where(b => b.DocID == viewModel.DocID).FirstOrDefault();
            if (item == null)
            {
                return View("Index");
            }
            return View(item);
        }
    }
}