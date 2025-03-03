﻿using System;
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
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class AchievementConsoleController : SampleController<UserProfile>
    {
        public AchievementConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
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

        public ActionResult InquireMonthlySalary(LessonQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            var salaryItems = models.GetTable<MonthlySalary>()
                .Where(t => t.Payday <= DateTime.Today);

            if(viewModel.DateFrom.HasValue)
            {
                salaryItems = salaryItems.Where(t => t.Payday >= viewModel.DateFrom);
            }
            if(viewModel.DateTo.HasValue)
            {
                salaryItems = salaryItems.Where(t => t.Payday < viewModel.DateTo.Value.AddMonths(1));
            }

            IQueryable<MonthlySalaryDetails> items = models.GetTable<MonthlySalaryDetails>()
                //.Where(t => t.SettlementID.HasValue)
                .Where(c => c.UID == viewModel.UID)
                .Join(salaryItems, s => s.SalaryID, m => m.SalaryID, (s, m) => s);

            return View("~/Views/ConsoleHome/Salary/MonthlySalaryList.cshtml", items);
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

        public ActionResult SelectQueryInterval(LessonQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/AchievementConsole/Module/SelectQueryInterval.cshtml");
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

            return Json(new { result = true });

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

            return Json(new { result = true });

        }

        public ActionResult ShowMonthlySalary(LessonQueryViewModel viewModel)
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
                if (!(viewModel.DateFrom <= viewModel.DateTo.Value && viewModel.DateTo.Value <= viewModel.DateFrom.Value.AddMonths(12)))
                {
                    ModelState.AddModelError("DateFrom", "查詢月數區間錯誤");
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            return Json(new { result = true });

        }

        public ActionResult ShowSalaryDetails(CoachBonusViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            CoachBonusViewModel tmpModel = viewModel;
            if (viewModel.KeyID != null)
            {
                tmpModel = JsonConvert.DeserializeObject<CoachBonusViewModel>(viewModel.KeyID.DecryptKey());
            }

            var salary = models.GetTable<MonthlySalaryDetails>()
                .Where(s => s.SalaryID == tmpModel.SalaryID)
                .Where(s => s.UID == tmpModel.UID).FirstOrDefault();

            if (salary == null)
            {
                ModelState.AddModelError("Message", "資料錯誤!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.AlertError = true;
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            if (viewModel.DialogID != null)
            {
                return View("~/Views/ConsoleHome/Salary/SalaryDetailsModal.cshtml", salary);
            }
            else
            {
                return View("~/Views/ConsoleHome/Salary/SalaryDetails.cshtml", salary);
            }

        }

        public async Task<ActionResult> SelectCoachAsync(ServingCoachQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            ViewBag.SelectAll = viewModel.SelectAll;
            ViewBag.Allotment = viewModel.Allotment;
            ViewBag.AllotmentCoach = viewModel.AllotmentCoach;

            var profile = await HttpContext.GetUserAsync();
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

        public ActionResult SelectAchievementCatelog(QueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/BusinessConsole/Module2021/SelectAchievementCatelog.cshtml");
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

        public ActionResult ShowAchievementRankingList(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<MonthlyCoachRevenueIndicator> items = viewModel.InquireDataForCoachRanking(models, out IQueryable<MonthlyIndicator> indicators);
            ViewBag.Indicators = indicators;
            return View("~/Views/AchievementConsole/Module/ShowAchievementRankingList.cshtml", items);
        }

        public ActionResult ShowLessonCountRankingList(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ShowAchievementRankingList(viewModel);
            result.ViewName = "~/Views/AchievementConsole/Module/ShowLessonCountRankingList.cshtml";
            return result;
        }

        public ActionResult ShowPICountRankingList(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ShowAchievementRankingList(viewModel);
            result.ViewName = "~/Views/AchievementConsole/Module/ShowPICountRankingList.cshtml";
            return result;
        }

        public ActionResult ShowBRCountRankingList(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ShowAchievementRankingList(viewModel);
            result.ViewName = "~/Views/AchievementConsole/Module/ShowBRCountRankingList.cshtml";
            return result;
        }

        public ActionResult ShowFinalsRankingList(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ShowAchievementRankingList(viewModel);
            result.ViewName = "~/Views/AchievementConsole/Module/ShowFinalsRankingList.cshtml";
            return result;
        }


    }
}