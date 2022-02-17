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

namespace WebHome.Controllers
{
    [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class AchievementConsoleController : SampleController<UserProfile>
    {
        // GET: AchievementConsole
        public ActionResult InquireMonthlyCoachRevenue(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            int? coachID = viewModel.CoachID;
            if (viewModel.KeyID != null)
            {
                coachID = viewModel.DecryptKeyValue();
            }

            IQueryable<MonthlyIndicator> indicatorItems = viewModel.InquireMonthlyIndicator(models);

            IQueryable<MonthlyCoachRevenueIndicator> items = models.GetTable<MonthlyCoachRevenueIndicator>()
                .Where(c => c.CoachID == viewModel.CoachID)
                .Join(indicatorItems, c => c.PeriodID, m => m.PeriodID, (c, m) => c);

            return View("~/Views/AchievementConsole/Module/InquireMonthlyCoachRevenue.cshtml", items);
        }

        public ActionResult SelectChartModal(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/AchievementConsole/Module/SelectChartModal.cshtml");
        }

        public ActionResult SelectCurveCondition(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/AchievementConsole/Module/SelectCurveCondition.cshtml");
        }

        public ActionResult SelectLessonCurve(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/AchievementConsole/Module/SelectLessonCurve.cshtml");
        }


        public ActionResult SelectChartCondition(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/AchievementConsole/Module/SelectChartCondition.cshtml");
        }

        public ActionResult SelectQueryCondition(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/AchievementConsole/Module/SelectQueryCondition.cshtml");
        }



        public ActionResult ShowMonthlyRevenueCurve(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.DateFrom.HasValue)
            {
                ModelState.AddModelError("DateFrom", "請選擇起月");
            }

            if (!viewModel.DateTo.HasValue)
            {
                ModelState.AddModelError("DateTo", "請選擇迄月");
            }

            if (ModelState.IsValid)
            {
                if (!(viewModel.DateFrom.Value.AddMonths(2) <= viewModel.DateTo.Value && viewModel.DateTo.Value <= viewModel.DateFrom.Value.AddMonths(12)))
                {
                    ModelState.AddModelError("DateFrom", "查詢月數區間錯誤");
                }
            }

            if (viewModel.SessionType == null || viewModel.SessionType.Length == 0)
            {
                ModelState.AddModelError("SessionType", "請勾選顯示設定");
            }


            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult ShowMonthlyRevenueChart(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.DateFrom.HasValue)
            {
                ModelState.AddModelError("DateFrom", "請選擇起月");
            }

            if (!viewModel.DateTo.HasValue)
            {
                ModelState.AddModelError("DateTo", "請選擇迄月");
            }

            if (ModelState.IsValid)
            {
                if (!(viewModel.DateFrom.Value.AddMonths(2) <= viewModel.DateTo.Value && viewModel.DateTo.Value <= viewModel.DateFrom.Value.AddMonths(12)))
                {
                    ModelState.AddModelError("DateFrom", "查詢月數區間錯誤");
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);

        }

        public ActionResult SelectCoach(ServingCoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.SelectAll = viewModel.SelectAll;
            ViewBag.Allotment = viewModel.Allotment;
            ViewBag.AllotmentCoach = viewModel.AllotmentCoach;

            var profile = HttpContext.GetUser();
            var indicators = models.GetTable<MonthlyCoachRevenueIndicator>();
            IQueryable<ServingCoach> items = models.PromptEffectiveCoach()
                    .Where(c => indicators.Any(i => i.CoachID == c.CoachID));

            if (profile.IsOfficer() || profile.IsAssistant() || profile.IsSysAdmin())
            {

            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                items = profile.GetServingCoachInSameStore(models, items);
            }
            else if (profile.IsCoach())
            {
                items = items.Where(c => c.CoachID == profile.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return View("~/Views/ContractConsole/ContractModal/SelectCoach.cshtml", items);
        }

        public ActionResult InquireMonthlyIndicator(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<MonthlyIndicator> items = viewModel.InquireMonthlyIndicator(models);

            return View("~/Views/BusinessConsole/Module2021/InquireMonthlyIndicator.cshtml", items);
        }

        public ActionResult InquireAttendancePerformance(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<MonthlyIndicator> items = viewModel.InquireMonthlyIndicator(models);

            return View("~/Views/BusinessConsole/Module2021/InquireAttendancePerformance.cshtml", items);
        }

        public ActionResult InquireContractAchievement(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireAttendancePerformance(viewModel);
            result.ViewName = "~/Views/BusinessConsole/Module2021/InquireContractAchievement.cshtml";
            return result;
        }

        public ActionResult selectAchievementCatelog(QueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/BusinessConsole/Module2021/selectAchievementCatelog.cshtml");
        }

        public ActionResult InquireBreakEvent(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<MonthlyIndicator> items = viewModel.InquireYearlyIndicator(models);

            return View("~/Views/BusinessConsole/Module2021/InquireBreakEvent.cshtml", items);
        }

        public ActionResult SelectBreakEventCondition(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/BusinessConsole/Module2021/SelectBreakEventCondition.cshtml");
        }


    }
}