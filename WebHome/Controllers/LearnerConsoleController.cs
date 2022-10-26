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
    public class LearnerConsoleController : SampleController<UserProfile>
    {
        public LearnerConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
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

        public ActionResult ProcessCoachLearner(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || !viewModel.UID.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/LearnerConsole/Module/ProcessCoachLearner.cshtml");
        }

        public ActionResult CommitPrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || !viewModel.UID.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            var result = models.ExecuteCommand(@"INSERT INTO LearnerCoachProperty
                                                   (CoachID, UID, PropertyID)
                                    SELECT  {0} AS CoachID, {1} AS UID, {2} AS PropertyID
                                    WHERE   (NOT EXISTS
                                                       (SELECT  NULL
                                                       FROM     LearnerCoachProperty
                                                       WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})))",
                                    viewModel.CoachID, viewModel.UID, 
                                    (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

            return Json(new { result = true, count = result });
        }

        public ActionResult BatchCommitPrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || viewModel.LearnerID == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            int result = 0;
            foreach(var id in viewModel.LearnerID)
            {
                result += models.ExecuteCommand(@"INSERT INTO LearnerCoachProperty
                                                   (CoachID, UID, PropertyID)
                                    SELECT  {0} AS CoachID, {1} AS UID, {2} AS PropertyID
                                    WHERE   (NOT EXISTS
                                                       (SELECT  NULL
                                                       FROM     LearnerCoachProperty
                                                       WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})))",
                                        viewModel.CoachID, id,
                                        (int)LearnerCoachProperty.PropertyType.PrimaryCoach);
            }


            return Json(new { result = true, count = result });
        }

        public ActionResult DeletePrimaryCoach(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            var result = models.ExecuteCommand(@"DELETE  LearnerCoachProperty
                                                    WHERE   (CoachID = {0}) AND (UID = {1}) AND (PropertyID = {2})",
                                    viewModel.CoachID, viewModel.UID,
                                    (int)LearnerCoachProperty.PropertyType.PrimaryCoach);

            return Json(new { result = true, count = result });
        }

        public ActionResult DeleteAdvisor(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel = viewModel.Deserialize<CoachLearnerQueryViewModel>();
            }

            ViewBag.ViewModel = viewModel;

            var result = models.ExecuteCommand(@"DELETE  LearnerFitnessAdvisor
                                                    WHERE   (CoachID = {0}) AND (UID = {1})",
                                    viewModel.CoachID, viewModel.UID);

            return Json(new { result = true, count = result });
        }

        public ActionResult BatchDeleteAdvisor(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;

            if (!viewModel.CoachID.HasValue || viewModel.LearnerID == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            int result = 0;
            foreach(var id in viewModel.LearnerID)
            {
                result += models.ExecuteCommand(@"DELETE  LearnerFitnessAdvisor
                                                    WHERE   (CoachID = {0}) AND (UID = {1})",
                                        viewModel.CoachID, id);
            }

            return Json(new { result = true, count = result });
        }

        public ActionResult ShowCoachLearnerList(CoachLearnerQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            ViewBag.ViewModel = viewModel;
            ServingCoach coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();

            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/AlertMessage.cshtml", model: "資料錯誤!!");
            }

            ViewBag.DataItem = coach;

            IQueryable<UserProfile> items = models.GetTable<UserProfile>();

            var effectiveItems = models.PromptEffectiveContract();
            var effectiveLearners = models.GetTable<CourseContractMember>()
                                        .Join(effectiveItems, m => m.ContractID, c => c.ContractID, (m, c) => m);
            if (viewModel.ForPrimary == true)
            {
                items = items.Join(
                    models.GetTable<LearnerCoachProperty>().Where(p => p.PropertyID == (int)LearnerCoachProperty.PropertyType.PrimaryCoach)
                        .Where(p => p.CoachID == coach.CoachID),
                                u => u.UID, p => p.UID, (u, p) => u)
                    .Where(u => effectiveLearners.Any(l => l.UID == u.UID));
            }
            else if(viewModel.ForAdvisor == true)
            {
                items = items.Join(models.GetTable<LearnerFitnessAdvisor>().Where(a => a.CoachID == coach.CoachID),
                                u => u.UID, a => a.UID, (u, a) => u);
                if(viewModel.WithContract == true)
                {
                    items = items.Where(u => effectiveLearners.Any(l => l.UID == u.UID));
                }
                else
                {
                    items = items.Where(u => !effectiveLearners.Any(l => l.UID == u.UID));
                }
            }
            else
            {
                items = items.Where(u => false);
            }

            return View("~/Views/LearnerConsole/Module/CoachLearnerList.cshtml", items);
        }

    }
}
