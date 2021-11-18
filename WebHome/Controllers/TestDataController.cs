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
using WebHome.Helper.MessageOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;

using WebHome.Security.Authorization;
using CommonLib.Core.Utility;
using Microsoft.Extensions.Logging;

namespace WebHome.Controllers
{
    public class TestDataController : SampleController<UserProfile>
    {
        public TestDataController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        // GET: TestData
        public ActionResult Demo()
        {
            return View();
        }

        public ActionResult RestoreCoachRevenueIndicator(MonthlyCoachRevenueIndicatorQueryViewModel viewModel,int[] exclusiveCoach = null)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<MonthlyIndicator> indicatorItems = models.GetTable<MonthlyIndicator>();
            if(viewModel.DateFrom.HasValue)
            {
                viewModel.DateFrom = viewModel.DateFrom.Value.FirstDayOfMonth();
                indicatorItems.Where(i => i.StartDate >= viewModel.DateFrom);
            }
            if(viewModel.DateTo.HasValue)
            {
                viewModel.DateTo = viewModel.DateTo.Value.FirstDayOfMonth().AddMonths(1);
                indicatorItems.Where(i => i.StartDate < viewModel.DateTo);
            }

            IQueryable<ServingCoach> coachItems = models.GetTable<ServingCoach>();
            if(viewModel.CoachID.HasValue)
            {
                coachItems = coachItems.Where(c => c.CoachID == viewModel.CoachID);
            }

            if (exclusiveCoach != null && exclusiveCoach.Length > 0)
            {
                coachItems = coachItems
                    .Where(c => !exclusiveCoach.Contains(c.CoachID))
                    .Where(c => c.CoachWorkplace.Any());
            }

            var forCoaches = coachItems.ToArray();
            foreach(MonthlyIndicator indicator in indicatorItems)
            {
                AchievementQueryViewModel queryModel = new AchievementQueryViewModel
                {
                    AchievementDateFrom = indicator.StartDate,
                    BypassCondition = true,
                };

                IQueryable<V_Tuition> lessonItems = queryModel.InquireAchievement(models);
                lessonItems = lessonItems.Where(l => l.SettlementID.HasValue);
                IQueryable<V_Tuition> tuitionItems = lessonItems;

                PaymentQueryViewModel paymentQuery = new PaymentQueryViewModel
                {
                    PayoffDateFrom = indicator.StartDate,
                    PayoffDateTo = indicator.EndExclusiveDate.AddDays(-1),
                    BypassCondition = true,
                };

                IQueryable<Payment> paymentItems = paymentQuery.InquirePayment(models);
                IQueryable<TuitionAchievement> achievementItems = paymentItems.GetPaymentAchievement(models);

                CourseContractQueryViewModel contractQuery = new CourseContractQueryViewModel
                {
                    ContractQueryMode = Naming.ContractServiceMode.ContractOnly,
                    Status = (int)Naming.CourseContractStatus.已生效,
                    EffectiveDateFrom = indicator.StartDate,
                    EffectiveDateTo = indicator.EndExclusiveDate,
                };
                IQueryable<CourseContract> contractItems = contractQuery.InquireContract(models);

                void calcCoachAchievement(MonthlyCoachRevenueIndicator coachIndicator)
                {
                    int lessonAchievement, tuitionAchievement;

                    var coachTuitionItems = tuitionItems.Where(t => t.AttendingCoach == coachIndicator.CoachID);
                    var coachAchievementItems = achievementItems.Where(t => t.CoachID == coachIndicator.CoachID);
                    var coachContractItems = contractItems.Where(c => c.FitnessConsultant == coachIndicator.CoachID);

                    lessonAchievement = coachTuitionItems.Where(t => BusinessConsoleExtensions.SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                    lessonAchievement += (coachTuitionItems.Where(t => BusinessConsoleExtensions.SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);
                    tuitionAchievement = coachAchievementItems.Sum(a => a.ShareAmount) ?? 0;

                    coachIndicator.ActualCompleteLessonCount = coachTuitionItems.Where(t => BusinessConsoleExtensions.SessionScopeForComleteLessonCount.Contains(t.PriceStatus)).Count()
                                    + coachTuitionItems.Where(t => BusinessConsoleExtensions.SessionScopeForComleteLessonCount.Contains(t.ELStatus)).Count();
                    coachIndicator.ActualLessonAchievement = lessonAchievement;
                    coachIndicator.ActualRenewContractAchievement = coachContractItems.Where(c => c.Renewal == true).Count();
                    coachIndicator.ActualNewContractAchievement = coachContractItems.Count() - coachIndicator.ActualRenewContractAchievement;
                    coachIndicator.ActualCompleteTSCount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程).Count()
                                    + coachTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.體驗課程).Count();
                    coachIndicator.ActualCompletePICount = coachTuitionItems.Where(t => t.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練).Count()
                                    + coachTuitionItems.Where(t => t.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();

                    models.SubmitChanges();
                }

                foreach (var coach in forCoaches)
                {
                    var item = models.GetTable<MonthlyCoachRevenueIndicator>()
                        .Where(c => c.PeriodID == indicator.PeriodID && c.CoachID == coach.CoachID).FirstOrDefault();

                    if (item == null)
                    {
                        var attendingLessons = models.GetTable<LessonTime>()
                            .Where(l => l.AttendingCoach == coach.CoachID)
                            .Where(l => l.ClassTime >= indicator.StartDate)
                            .Where(l => l.ClassTime < indicator.EndExclusiveDate);

                        if(attendingLessons.Any())
                        {
                            item = new MonthlyCoachRevenueIndicator
                            {
                                PeriodID = indicator.PeriodID,
                                CoachID = coach.CoachID,
                                BranchID = coach.CoachWorkplace.First().BranchID,
                                LevelID = coach.LevelID,
                            };
                            models.GetTable<MonthlyCoachRevenueIndicator>().InsertOnSubmit(item);

                            item.AchievementGoal = 0;
                            item.CompleteLessonsGoal = 0;
                            item.AverageLessonPrice = indicator.CalculateAverageLessonPrice(models, coach.CoachID);
                            item.BRCount = 0;
                            item.LessonTuitionGoal = 0;

                            models.SubmitChanges();

                            calcCoachAchievement(item);
                        }
                    }
                }
            }

            return Json(new { result = true });
        }

        public ActionResult TestMessage()
        {
            return Json(new { result = true, message = "資料處理完成!!" });
        }

        public async Task<ActionResult> DumpAsync()
        {
            String fileName = Path.Combine(FileLogger.Logger.LogDailyPath, $"request{DateTime.Now.Ticks}.txt");
            await Request.SaveAsAsync(fileName);
            return Content(System.IO.File.ReadAllText(fileName), "text/plain");
        }

        public async Task<ActionResult> CurrentAsync(int? contractID)
        {
            System.Diagnostics.Debugger.Launch();
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == contractID).FirstOrDefault();
            //if (item.CourseContractExtension.SignOnline == true)
            {
                String jsonData = await RenderViewToStringAsync("~/Views/LineEvents/Message/NotifyManagerToApproveContract.cshtml", item);
                jsonData.PushLineMessage();
                //item.CreateLineReadyToSignContract(models).PushLineMessage();
            }

            return Content("OK!!");
        }

        public ActionResult SpecialGivingLesson(CourseContractViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            try
            {
                models.RegisterSpecialGivingLesson2021(viewModel.UID);
                return Json(new { result = true });
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<TestDataController>()
                    .LogError(ex, ex.Message);
                return Json(new { result = false, message = ex.Message });
            }
        }

    }
}