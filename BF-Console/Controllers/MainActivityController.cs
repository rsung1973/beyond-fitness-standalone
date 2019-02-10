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

    }
}