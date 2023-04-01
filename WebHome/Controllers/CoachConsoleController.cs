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
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.Extensions.DependencyInjection;

using CommonLib.DataAccess;
using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using CommonLib.Core.Utility;
using Microsoft.AspNetCore.Http;
namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class CoachConsoleController : SampleController<UserProfile>
    {
        public CoachConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        public async Task<ActionResult> ShowCoachPerformanceListAsync(CoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            if (viewModel.Employed == false)
            {
                return View("~/Views/CoachConsole/Module/LeavedCoachList.cshtml", profile.LoadInstance(models));
            }
            else
            {
                return View("~/Views/CoachConsole/Module/CoachMonthlyPerformance.cshtml", profile.LoadInstance(models));
            }
        }

        public async Task<ActionResult> ShowCoachCertificateReadyListAsync(CoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/CoachConsole/Module/CoachCertificateReady.cshtml", profile.LoadInstance(models));
        }

        public ActionResult ProcessCoachView(CoachQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "合約資料錯誤!!");
            }

            return View("~/Views/CoachConsole/Module/ProcessCoachView.cshtml", item);
        }

        public ActionResult ProcessCoachCertificateView(CoachCertificateViewModel viewModel)
        {
            CoachCertificateViewModel tmpModel = ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                tmpModel = JsonConvert.DeserializeObject<CoachCertificateViewModel>(viewModel.KeyID.DecryptKey());
            }

            var item = models.GetTable<CoachCertificate>()
                    .Where(c => c.CoachID == tmpModel.CoachID)
                    .Where(c=>c.CertificateID == tmpModel.CertificateID)
                    .FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/CoachConsole/Module/ProcessCoachCertificateView.cshtml", item);
        }

        public ActionResult ShowCoachCertificate(CoachCertificateViewModel viewModel)
        {
            ViewResult result = (ViewResult)ProcessCoachCertificateView(viewModel);
            CoachCertificate model = result.Model as CoachCertificate;
            if (model != null) 
            {
                result.ViewName = "~/Views/CoachConsole/Module/CoachCertificateView.cshtml";
            }
            return result;
        }


        public ActionResult AddCoachCertificate(CoachCertificateViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null) 
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return View("~/Views/CoachConsole/Module/AddCoachCertificate.cshtml", coach);
        }

        public ActionResult LoadCoachCertificate(CoachCertificateViewModel viewModel)
        {
            ActionResult result = AddCoachCertificate(viewModel);

            if (result is ViewResult)
            {
                ((ViewResult)result).ViewName = "~/Views/CoachConsole/Module/CoachCertificateList.cshtml";
            }

            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Manager, (int)Naming.RoleID.ViceManager })]
        public async Task<ActionResult> ApproveCoachCertificateAsync(CoachCertificateViewModel viewModel)
        {
            CoachCertificateViewModel tmpModel = ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                tmpModel = JsonConvert.DeserializeObject<CoachCertificateViewModel>(viewModel.KeyID.DecryptKey());
            }

            var item = models.GetTable<CoachCertificate>()
                    .Where(c => c.CoachID == tmpModel.CoachID)
                    .Where(c => c.CertificateID == tmpModel.CertificateID)
                    .FirstOrDefault();

            if (item == null) 
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            var profile = await HttpContext.GetUserAsync();
            item.Status = (int)CoachCertificate.CertificateStatusDefinition.已核准;
            item.ApprovedBy = profile.UID;
            item.ApprovedDate = DateTime.Now;
            models.SubmitChanges();

            return Json(new { result = true });

        }


        public async Task<ActionResult> ShowCoachMonthlyPerformanceAsync(CoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/CoachConsole/Module/CoachMonthlyPerformanceList.cshtml", profile.LoadInstance(models));
        }

        public ActionResult CommitMonthlyAssessment(MonthlyAssessmentViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var indicator = models.GetTable<MonthlyIndicator>()
                            .Where(m => m.PeriodID == viewModel.PeriodID)
                            .FirstOrDefault();

            if (indicator == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            if (viewModel.PersonID != null)
            {
                for (int i = 0; i < viewModel.PersonID.Length; i++)
                {
                    var coachID = viewModel.PersonID[i];
                    var item = indicator.MonthlyCoachRevenueIndicator.Where(m => m.CoachID == coachID)
                                    .FirstOrDefault();
                    if (item != null)
                    {
                        item.AcademicGrades = viewModel.AcademicGrades[i];
                        item.TechnicalGrades = viewModel.TechnicalGrades[i];
                    }
                }
                models.SubmitChanges();
            }

            return Json(new { result = true });
        }

        public ActionResult SelectCertificate(CoachCertificateViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<ProfessionalCertificate> items = models.GetTable<ProfessionalCertificate>()
                    .Where(c => !c.Status.HasValue || c.Status != (int)ProfessionalCertificate.ProfessionalCertificateStatus.已下架);

            return View("~/Views/CoachConsole/Module/SelectCertificate.cshtml", items);
        }

    }
}
