using System;
using System.Collections.Generic;
using System.Data;

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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

using WebHome.Security.Authorization;
using CommonLib.Core.Utility;

namespace WebHome.Controllers
{
    public class CommonHelperController : SampleController<UserProfile>
    {
        public CommonHelperController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
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

        public async Task<ActionResult> ChangeThemeAsync(LoginViewModel viewModel)
        {
            //await Request.SaveAsAsync("G:\\temp\\request.txt");
            var profile = await HttpContext.GetUserAsync();
            Response.Cookies.Append("_theme", viewModel.Theme ?? "", new Microsoft.AspNetCore.Http.CookieOptions
            {
                Expires = DateTime.MaxValue,
            });

            return Json(new { result = true, message = viewModel.Theme });
        }

        public ActionResult SetAuthCode(QueryViewModel viewModel)
        {
            viewModel.AuthCode = viewModel.AuthCode.GetEfficientString();
            if (viewModel.AuthCode == null)
            {
                viewModel.AuthCode = $"{DateTime.Now.Ticks % 100000000:00000000}";
            }
            AppSettings.Default.AuthorizationCode = viewModel.AuthCode;
            return Content(new { result = true, viewModel.AuthCode }.JsonStringify(), "application/json");
        }
    }
}