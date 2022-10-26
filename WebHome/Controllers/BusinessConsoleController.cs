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
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using Microsoft.Extensions.Logging;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class BusinessConsoleController : SampleController<UserProfile>
    {
        public BusinessConsoleController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: BusinessConsole
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult PrepareRevenueGoal(MonthlyIndicatorQueryViewModel viewModel,bool? forcedPrepare, bool? forcedUpdate,bool? calcAverage)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            if (!viewModel.Year.HasValue || !viewModel.Month.HasValue)
            {
                viewModel.Year = DateTime.Today.Year;
                viewModel.Month = DateTime.Today.Month;
            }

            var item = models.GetTable<MonthlyIndicator>().Where(i => i.PeriodID == viewModel.PeriodID).FirstOrDefault();

            if (item == null)
            {
                item = models.GetTable<MonthlyIndicator>().Where(i => (i.Year == viewModel.Year && i.Month == viewModel.Month)).FirstOrDefault();
            }

            if (item == null || forcedPrepare == true)
            {
                item = models.InitializeMonthlyIndicator(viewModel.Year.Value, viewModel.Month.Value, true);
            }

            item.UpdateMonthlyAchievement(models, forcedUpdate, calcAverage);
            item.UpdateMonthlyAchievementGoal(models);

            return Json(new { result = true, message = "OK" });
        }

        public ActionResult SelectMonth(MonthlySelectorViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.RecentCount.HasValue)
            {
                viewModel.RecentCount = 6;
            }
            return View("~/Views/Common/SelectMonth.cshtml");
        }

        public ActionResult SelectMonthPeriod(MonthlySelectorViewModel viewModel)
        {
            ViewResult result = (ViewResult)SelectMonth(viewModel);
            result.ViewName = "~/Views/Common/SelectMonthPeriod.cshtml";
            return result;
        }


        public ActionResult BranchCoachAchievement(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            IQueryable<MonthlyCoachRevenueIndicator> items = models.GetTable<MonthlyCoachRevenueIndicator>()
                        .Where(c => c.PeriodID == viewModel.PeriodID && c.BranchID == viewModel.BranchID);

            return View("~/Views/BusinessConsole/Module/BranchCoachAchievement.cshtml", items);
        }

        public ActionResult ApplyCoachAchievement(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            if (!viewModel.Year.HasValue || !viewModel.Month.HasValue)
            {
                viewModel.Year = DateTime.Today.Year;
                viewModel.Month = DateTime.Today.Month;
            }

            var item = viewModel.AssertMonthlyIndicator(models);

            return View("~/Views/BusinessConsole/Module/SelectCoachAchievementGoal.cshtml", item);
        }

        public ActionResult EditCoachRevenueIndicator(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var indicator = models.GetTable<MonthlyIndicator>().Where(c => c.PeriodID == viewModel.PeriodID).FirstOrDefault();
            if (indicator == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            var item = models.GetTable<MonthlyCoachRevenueIndicator>()
                .Where(c => c.PeriodID == viewModel.PeriodID && c.CoachID == viewModel.CoachID).FirstOrDefault();

            if (item != null)
            {
                viewModel.AchievementGoal = item.AchievementGoal;
                viewModel.CompleteLessonsGoal = item.CompleteLessonsGoal;
                viewModel.BRCount = item.BRCount;
                viewModel.AverageLessonPrice = item.AverageLessonPrice;
            }
            else
            {
                viewModel.AverageLessonPrice = indicator.CalculateAverageLessonPrice(models, viewModel.CoachID);
            }

            return View("~/Views/BusinessConsole/Module/SelectCoachAchievementGoal.cshtml", indicator);
        }

        public ActionResult LoadMonthlyIndicator(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var indicator = models.GetTable<MonthlyIndicator>().Where(c => c.PeriodID == viewModel.PeriodID).FirstOrDefault();
            if (indicator == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("", indicator);
        }

        public ActionResult AchievementIntervalReview(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            DateTime? startDate = viewModel.DateFrom;
            DateTime? endDate = viewModel.DateTo?.AddMonths(1);

            var monthlyItems = models.GetTable<MonthlyIndicator>().Where(i => i.StartDate >= startDate && i.StartDate < endDate);

            if (monthlyItems.Count() == 0)
            {
                return Json(new { result = false, message = "資料錯誤!!" });
            }

            return View("~/Views/BusinessConsole/Module/AchievementIntervalReview.cshtml", monthlyItems);
        }

        public ActionResult CommitAchievementIntervalReview(MonthlyIndicatorQueryViewModel viewModel)
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
                    ModelState.AddModelError("DateTo", "查詢月數區間錯誤");
                }
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            return Json(new { result = true });
        }



        public ActionResult DeleteCoachRevenueIndicator(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var count = models.ExecuteCommand("delete [KPI].MonthlyCoachRevenueIndicator where PeriodID={0} and CoachID={1}", viewModel.PeriodID, viewModel.CoachID);

            if(count>0)
            {
                return Json(new { result = true });
            }

            return Json(new { result = false, message = "刪除失敗!!" });
        }

        public ActionResult ProcessCoachRevenueIndicator(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<MonthlyCoachRevenueIndicator>().Where(c => c.PeriodID == viewModel.PeriodID && c.CoachID == viewModel.CoachID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/BusinessConsole/Module/ProcessCoachRevenueIndicator.cshtml", item);
        }

        public ActionResult MakeStrategyAnalysis(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<MonthlyBranchIndicator>().Where(c => c.PeriodID == viewModel.PeriodID && c.BranchID == viewModel.BranchID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            viewModel.RiskPrediction = item.RiskPrediction;
            viewModel.Strategy = item.Strategy;
            viewModel.Comment = item.Comment;

            return View("~/Views/BusinessConsole/Module/MakeStrategyAnalysis.cshtml", item);
        }

        public ActionResult SelectAchievementReviewInterval()
        {
            return View("~/Views/BusinessConsole/Module/SelectAchievementReviewInterval.cshtml");
        }

        public ActionResult CommitStrategyAnalysis(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            var item = models.GetTable<MonthlyBranchIndicator>().Where(c => c.PeriodID == viewModel.PeriodID && c.BranchID == viewModel.BranchID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            item.RiskPrediction = viewModel.RiskPrediction;
            item.Strategy = viewModel.Strategy;
            //item.Comment = viewModel.Comment;

            models.SubmitChanges();

            return Json(new { result = true });
        }


        public ActionResult CommitCoachRevenueIndicator(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)LoadMonthlyIndicator(viewModel);
            MonthlyIndicator indicator = result.Model as MonthlyIndicator;
            if (indicator == null)
            {
                return result;
            }

            var coach = models.GetTable<ServingCoach>().Where(c => c.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "請選擇教練!!");
            }

            if (!viewModel.BranchID.HasValue)
            {
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "請選擇分店!!");
            }

            if (!viewModel.AchievementGoal.HasValue)
            {
                ModelState.AddModelError("AchievementGoal", "請輸收款業績");
            }

            if (viewModel.DataOperation != Naming.DataOperationMode.Create)
            {
                if (!viewModel.AverageLessonPrice.HasValue)
                {
                    ModelState.AddModelError("AverageLessonPrice", "請輸平均單價");
                }
            }

            if (!viewModel.CompleteLessonsGoal.HasValue)
            {
                ModelState.AddModelError("CompleteLessonsGoal", "請輸入課數");
            }

            if (!viewModel.BRCount.HasValue)
            {
                ModelState.AddModelError("BRCount", "請輸BR堂數");
            }

            if(!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            var item = models.GetTable<MonthlyCoachRevenueIndicator>()
                .Where(c => c.PeriodID == viewModel.PeriodID && c.CoachID == viewModel.CoachID).FirstOrDefault();

            if (item == null)
            {
                item = new MonthlyCoachRevenueIndicator
                {
                    PeriodID = indicator.PeriodID,
                    CoachID = viewModel.CoachID.Value,
                    BranchID = viewModel.BranchID,
                    LevelID = coach.LevelID,
                };
                models.GetTable<MonthlyCoachRevenueIndicator>().InsertOnSubmit(item);

                models.GetTable<MonthlyCoachLearnerReview>()
                    .InsertOnSubmit(new MonthlyCoachLearnerReview
                    {
                        PeriodID = indicator.PeriodID,
                        CoachID = viewModel.CoachID.Value,
                    });
            }

            item.AchievementGoal = viewModel.AchievementGoal;
            item.CompleteLessonsGoal = viewModel.CompleteLessonsGoal;
            if (viewModel.DataOperation == Naming.DataOperationMode.Create)
            {
                item.AverageLessonPrice = indicator.CalculateAverageLessonPrice(models, viewModel.CoachID); ;
            }
            else
            {
                item.AverageLessonPrice = viewModel.AverageLessonPrice;
            }
            item.BRCount = viewModel.BRCount;
            item.LessonTuitionGoal = item.AverageLessonPrice * item.CompleteLessonsGoal;

            models.SubmitChanges();

            indicator.UpdateMonthlyAchievementGoal(models);

            return Json(new { result = true });
        }

        public ActionResult LoadCoachRevenueIndicatorList(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)LoadMonthlyIndicator(viewModel);
            if (!(result.Model is MonthlyIndicator item))
                return result;
            result.ViewName = "~/Views/BusinessConsole/Module/MonthlyCoachRevenueIndicatorList.cshtml";
            return result;
        }

        public ActionResult LoadStrategyAnalysis(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)LoadMonthlyIndicator(viewModel);
            if (!(result.Model is MonthlyIndicator item))
                return result;
            result.ViewName = "~/Views/BusinessConsole/Module/StrategyAnalysis.cshtml";
            return result;
        }

        public async Task<ActionResult> CommitInvoiceTrackNoIntervalAsync(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.BookletBranchID == null || viewModel.BookletBranchID.Length == 0 || viewModel.BookletBranchID.Any(c => !c.HasValue))
            {
                ModelState.AddModelError("BookletBranchID", "請選擇分店!!");
            }

            if (viewModel.KeyID != null)
            {
                viewModel.TrackID = viewModel.DecryptKeyValue();
            }

            var trackCode = models.GetTable<InvoiceTrackCode>()
                                .Where(t => t.TrackID == viewModel.TrackID).FirstOrDefault();

            if (trackCode == null)
            {
                viewModel.TrackCode = viewModel.TrackCode.GetEfficientString();
                if (viewModel.TrackCode == null || !Regex.IsMatch(viewModel.TrackCode, "[A-Z]{2}"))
                {
                    ModelState.AddModelError("TrackCode", "請輸入字軌");
                }

                if (!viewModel.Year.HasValue)
                {
                    ModelState.AddModelError("Year", "請選擇發票年度");
                }

                if (!viewModel.PeriodNo.HasValue)
                {
                    ModelState.AddModelError("PeriodNo", "請選擇期別");
                }
            }

            int? range = 0, assignedBooklet = 0; ;
            if (!viewModel.StartNo.HasValue || !(viewModel.StartNo >= 0 && viewModel.StartNo < 100000000))
            {
                ModelState.AddModelError("StartNo", "請輸入起號");
            }
            else if (!viewModel.EndNo.HasValue || !(viewModel.EndNo >= 0 && viewModel.EndNo < 100000000))
            {
                ModelState.AddModelError("EndNo", "請輸入迄號");
            }
            else if (viewModel.EndNo <= viewModel.StartNo || (((range = viewModel.EndNo - viewModel.StartNo + 1)) % 50 != 0))
            {
                ModelState.AddModelError("StartNo", "不符號碼大小順序與差距為50之倍數原則");
            }
            else if ((assignedBooklet = viewModel.BookletCount.Where(c => c.HasValue && c > 0).Sum(c => c)) > (range / 50))
            {
                ModelState.AddModelError("BookletCount", "輸入總本數超過配號區間");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            if (trackCode == null)
            {
                trackCode = models.GetTable<InvoiceTrackCode>()
                    .Where(t => t.TrackCode == viewModel.TrackCode && t.Year == viewModel.Year && t.PeriodNo == viewModel.PeriodNo).FirstOrDefault();
            }

            if (trackCode == null)
            {
                trackCode = new InvoiceTrackCode
                {
                    TrackCode = viewModel.TrackCode,
                    Year = viewModel.Year.Value,
                    PeriodNo = viewModel.PeriodNo.Value,
                };
                models.GetTable<InvoiceTrackCode>().InsertOnSubmit(trackCode);
            }

            int? startNo = trackCode.StartNo = viewModel.StartNo;
            trackCode.EndNo = viewModel.EndNo;

            foreach (var b in viewModel.BookletBranchID)
            {
                if (!trackCode.InvoiceTrackCodeAssignment.Any(t => t.SellerID == b))
                {
                    trackCode.InvoiceTrackCodeAssignment.Add(new InvoiceTrackCodeAssignment
                    {
                        SellerID = b.Value
                    });
                }
            }

            models.SubmitChanges();

            for (int idx = 0; idx < viewModel.BookletBranchID.Length; idx++)
            {
                var interval = models.GetTable<InvoiceNoInterval>()
                    .Where(i => i.SellerID == viewModel.BookletBranchID[idx])
                    .Where(i => i.TrackID == trackCode.TrackID).FirstOrDefault();

                if (interval == null)
                {
                    if (!viewModel.BookletCount[idx].HasValue || viewModel.BookletCount[idx] <= 0)
                        continue;

                    interval = new InvoiceNoInterval
                    {
                        TrackID = trackCode.TrackID,
                        SellerID = viewModel.BookletBranchID[idx].Value,
                    };

                    models.GetTable<InvoiceNoInterval>().InsertOnSubmit(interval);
                }
                else
                {
                    if(interval.InvoiceNoAssignment.Any())
                    {
                        if (interval.StartNo != startNo
                            || !viewModel.BookletCount[idx].HasValue
                            || viewModel.BookletCount[idx] <= 0)
                        {
                            ModelState.AddModelError($"BranchID_{viewModel.BookletBranchID[idx]}", "字軌配號已使用，無法修改");
                            continue;
                        }
                        else if ((startNo + viewModel.BookletCount[idx] * 50 - 1) < interval.EndNo)
                        {
                            ModelState.AddModelError($"BranchID_{viewModel.BookletBranchID[idx]}", "字軌配號已使用本組數，只允許增加");
                            continue;
                        }
                    }
                    else if (!viewModel.BookletCount[idx].HasValue || viewModel.BookletCount[idx] <= 0)
                    {
                        models.GetTable<InvoiceNoInterval>().DeleteOnSubmit(interval);
                        continue;
                    }
                }

                interval.StartNo = startNo.Value;
                startNo += viewModel.BookletCount[idx] * 50;
                interval.EndNo = startNo.Value - 1;

            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View(ConsoleHomeController.InputErrorView);
            }

            try
            {
                models.SubmitChanges();
                if (assignedBooklet > 0)
                {
                    return Json(new { result = true, message = $"總本數:{range / 50}，已配置本數:{assignedBooklet}" });
                }
                else
                {
                    models.ExecuteCommand("delete InvoiceTrackCode where TrackID = {0}", trackCode.TrackID);
                    return Json(new { result = true, message = "未配置本組數。" });
                }
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<BusinessConsoleController>()
                    .LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }

        }

    }
}