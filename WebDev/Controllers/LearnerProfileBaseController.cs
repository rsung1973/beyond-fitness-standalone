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
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using System.Data.Linq;
using DocumentFormat.OpenXml.Spreadsheet;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class LearnerProfileBaseController : SampleController<UserProfile>
    {
        public LearnerProfileBaseController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: LearnerProfile
        public async Task<ActionResult> SearchLearnerAsync(LearnerViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.UserName = viewModel.UserName.GetEfficientString();
            if (viewModel.UserName == null)
            {
                this.ModelState.AddModelError("userName", "請輸入查詢學員!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/ConsoleHome/Shared/ReportInputError.cshtml");
            }

            var profile = await HttpContext.GetUserAsync();

            var items = viewModel.UserName.PromptUserProfileByName(models);

            if (items.Any())
            {
                return View("~/Views/LearnerProfile/ProfileModal/SelectLearnerProfile.cshtml", items);
            }
            else
            {
                if (viewModel.UserName.IsMobilPhone() && (profile.IsAssistant() || profile.IsManager() || profile.IsViceManager()))
                {
                    viewModel.Phone = viewModel.UserName;
                    viewModel.CurrentTrial = 1;
                    return View("~/Views/LearnerProfile/ProfileModal/CreateLearnerProfile.cshtml");
                }
                else if ((String.Compare(viewModel.UserName, "null", true) == 0 && profile.IsAssistant()))
                {
                    viewModel.CurrentTrial = 1;
                    return View("~/Views/LearnerProfile/ProfileModal/CreateLearnerProfile.cshtml");
                }
                //return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "Opps！您確定您輸入的資料正確嗎！？");
                return Json(new { result = false, message = "Opps！您確定您輸入的資料正確嗎！？" });
            }

        }

        public async Task<ActionResult> SearchPayerAsync(LearnerViewModel viewModel)
        {
            var result = await SearchLearnerAsync(viewModel);
            ViewResult viewResult = result as ViewResult;
            if (viewResult?.Model as IQueryable<UserProfile> != null)
            {
                viewResult.ViewName = "~/Views/LearnerProfile/ProfileModal/SelectPayer.cshtml";
                return viewResult;
            }

            return result;
        }


    }
}