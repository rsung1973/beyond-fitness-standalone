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
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    public class CommonHelperController : SampleController<UserProfile>
    {
        // GET: CommonHelper
        [AllowAnonymous]
        public ActionResult ViewContract(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
                return View("~/Views/ConsoleHome/ViewCourseContract.cshtml", item);
            else
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約資料錯誤!!");
            }
        }

        [AllowAnonymous]
        public ActionResult ViewContractService(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.RevisionID = viewModel.DecryptKeyValue();
            }
            var item = models.GetTable<CourseContractRevision>().Where(c => c.RevisionID == viewModel.RevisionID).FirstOrDefault();
            if (item != null)
                return View("~/Views/ConsoleHome/ViewContractService.cshtml", item);
            else
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約資料錯誤!!");
        }

        public ActionResult ViewBranchStore(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.Other = viewModel.BranchName;
            var item = models.GetTable<BranchStore>().Where(b => b.BranchID == viewModel.BranchID).FirstOrDefault();
            return View("~/Views/Common/BranchStoreWithOther.cshtml", item);
        }

        public ActionResult ChangeTheme(LoginViewModel viewModel)
        {
            HttpCookie cookie = new HttpCookie("_theme", viewModel.Theme);
            cookie.Expires = DateTime.MaxValue;
            Response.SetCookie(cookie);

            return Json(new { result = true, message = viewModel.Theme }, JsonRequestBehavior.AllowGet);
        }

        public ActionResult SetAuthCode(QueryViewModel viewModel)
        {
            viewModel.AuthCode = viewModel.AuthCode.GetEfficientString();
            if (viewModel.AuthCode == null)
            {
                viewModel.AuthCode = $"{DateTime.Now.Ticks % 100000000:00000000}";
            }
            AppSettings.Default.AuthorizationCode = viewModel.AuthCode;
            return Json(new { result = true, viewModel.AuthCode }, JsonRequestBehavior.AllowGet);
        }
    }
}