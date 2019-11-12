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
    public class BusinessConsoleController : SampleController<UserProfile>
    {
        // GET: BusinessConsole
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult PrepareRevenueGoal(MonthlyIndicatorQueryViewModel viewModel,bool? forcedPrepare)
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

            item.UpdateMonthlyAchievement(models);
            item.UpdateMonthlyAchievementGoal(models);

            return Json(new { result = true, message = "OK" }, JsonRequestBehavior.AllowGet);
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
                return Json(new { result = true }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { result = false, message = "刪除失敗!!" }, JsonRequestBehavior.AllowGet);
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

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
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

            return Json(new { result = true }, JsonRequestBehavior.AllowGet);
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

    }
}