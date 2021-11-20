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
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

using CommonLib.DataAccess;

using Newtonsoft.Json;
using CommonLib.Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer,(int)Naming.RoleID.ViceManager, (int)Naming.RoleID.Assistant,
        (int)Naming.RoleID.Accounting, (int)Naming.RoleID.Manager,(int)Naming.RoleID.Coach })]
    public class AchievementController : SampleController<UserProfile>
    {
        public AchievementController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }
        // GET: Achievement
        public ActionResult LessonIndex(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            viewModel.AchievementDateFrom = viewModel.AchievementDateTo = DateTime.Today;
            viewModel.AchievementYearMonthTo = viewModel.AchievementYearMonthFrom = String.Format("{0:yyyy/MM}", viewModel.AchievementDateFrom);
            return View();
        }

        public ActionResult PerformanceIndex(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.AchievementDateFrom = viewModel.AchievementDateTo = DateTime.Today;
            viewModel.AchievementYearMonthTo = viewModel.AchievementYearMonthFrom = String.Format("{0:yyyy/MM}", viewModel.AchievementDateFrom);
            return View();
        }

        public ActionResult ContributionIndex(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.AchievementDateFrom = viewModel.AchievementDateTo = DateTime.Today;
            viewModel.AchievementYearMonthTo = viewModel.AchievementYearMonthFrom = String.Format("{0:yyyy/MM}", viewModel.AchievementDateFrom);
            return View();
        }

        public ActionResult BranchContributionIndex(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.AchievementDateFrom = viewModel.AchievementDateTo = DateTime.Today;
            viewModel.AchievementYearMonthTo = viewModel.AchievementYearMonthFrom = String.Format("{0:yyyy/MM}", viewModel.AchievementDateFrom);
            return View();
        }


        public ActionResult BranchStoreIndex(AchievementQueryViewModel viewModel)
        {
            viewModel.AchievementDateFrom = viewModel.AchievementDateTo = DateTime.Today;
            viewModel.QueryInterval = Naming.QueryIntervalDefinition.今日;
            ViewBag.ViewModel = viewModel;
            return View();
        }

        public ActionResult LoadQueryInterval(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.QueryInterval.HasValue)
            {
                switch (viewModel.QueryInterval)
                {
                    case Naming.QueryIntervalDefinition.今日:
                        viewModel.AchievementDateFrom = viewModel.AchievementDateTo = DateTime.Today;
                        break;
                    case Naming.QueryIntervalDefinition.本週:
                        viewModel.AchievementDateFrom = DateTime.Today.AddDays((7 - (int)DateTime.Today.DayOfWeek) % 7 - 6);
                        viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddDays(6);
                        break;
                    case Naming.QueryIntervalDefinition.本月:
                        viewModel.AchievementDateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                        viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1).AddDays(-1);
                        break;
                    case Naming.QueryIntervalDefinition.本季:
                        viewModel.AchievementDateFrom = new DateTime(DateTime.Today.Year, ((DateTime.Today.Month - 1) / 3) * 3 + 1, 1);
                        viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(3).AddDays(-1);
                        break;
                    case Naming.QueryIntervalDefinition.近半年:
                        viewModel.AchievementDateFrom = DateTime.Today.AddMonths(-6);
                        viewModel.AchievementDateTo = DateTime.Today;
                        break;
                    case Naming.QueryIntervalDefinition.近一年:
                        viewModel.AchievementDateFrom = DateTime.Today.AddYears(-1);
                        viewModel.AchievementDateTo = DateTime.Today;
                        break;
                }
                return View("~/Views/Achievement/Module/LessonQueryInterval.ascx");
            }
            return new EmptyResult { };
        }

        public ActionResult InquireLesson(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<LessonTime> items = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= viewModel.AchievementDateFrom)
                .Where(t => t.ClassTime < viewModel.AchievementDateTo.Value.AddDays(1));

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                items = items.Where(t => viewModel.ByCoachID.Contains(t.AttendingCoach));
            }

            if (viewModel.CoachID.HasValue)
            {
                items = items.Where(t => t.AttendingCoach == viewModel.CoachID);
            }

            if (viewModel.ClassTime.HasValue)
            {
                items = items.Where(t => t.ClassTime >= viewModel.ClassTime && t.ClassTime < viewModel.ClassTime.Value.AddDays(1));
            }

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(t => t.BranchID == viewModel.BranchID);
            }

            if (viewModel.QueryType.HasValue)
                items = items.ByLessonQueryType(viewModel.QueryType);

            return View("~/Views/Achievement/Module/DailyLessonList.ascx", items);
        }


        public ActionResult InquireDailyLesson(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            checkCommonQuery(viewModel);

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            return InquireLesson(viewModel);
        }

        private void checkCommonQuery(AchievementQueryViewModel viewModel)
        {
            if (!viewModel.AchievementDateFrom.HasValue)
            {
                ModelState.AddModelError("AchievementDateFrom", "請選擇查詢起日");
            }

            if (!viewModel.AchievementDateTo.HasValue)
            {
                ModelState.AddModelError("AchievementDateTo", "請選擇查詢迄日");
            }

            if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue
                && (viewModel.AchievementDateTo.Value - viewModel.AchievementDateFrom.Value).TotalDays > 31)
            {
                ModelState.AddModelError("AchievementDateFrom", "查詢區間只能是一個月內");
                ModelState.AddModelError("AchievementDateTo", "查詢區間只能是一個月內");
            }

            if (viewModel.ByCoachID == null || viewModel.ByCoachID.Length == 0)
            {
                ModelState.AddModelError("ByCoachID", "請勾選一位");
            }
        }

        public ActionResult ShowLessonList(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireLesson(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            if (items == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            return View("~/Views/CoachFacet/Module/DailyBookingList.ascx", items);
        }

        public ActionResult ShowBranchLessonList(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireLesson(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            if (items == null)
            {
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            items = items.PTLesson()
                .Union(items.Where(l => l.TrainingBySelf == 1))
                .Union(items.TrialLesson());

            return View("~/Views/CoachFacet/Module/DailyBookingList.ascx", items);
        }

        public ActionResult CheckLearnerAttendance(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ShowLearnerToComplete(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            if (items == null)
            {
                return result;
            }

            items = items.PTLesson();

            foreach (var item in items)
            {
                item.LessonPlan.CommitAttendance = DateTime.Now;
            }

            models.SubmitChanges();

            return Json(new { result = true });

        }

        public ActionResult InquireBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireDailyLesson(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/LessonBarChartData.ascx", items);
        }

        public ActionResult InquireCoachLesson(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireDailyLesson(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            return View("~/Views/Achievement/Module/CoachLessonList.ascx", items);
        }

        public ActionResult InquireCoachBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireDailyLesson(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/CoachLessonBarChartData.ascx", items);
        }

        class _ClassTimeGroupKey
        {
            public DateTime? ClassTime { get; set; }
            public int? Hour { get; set; }
        }
        public async Task<ActionResult> CreateLessonListXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireDailyLesson(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            DataTable dailyTable = new DataTable();
            dailyTable.Columns.Add(new DataColumn("日期", typeof(String)));
            dailyTable.Columns.Add(new DataColumn("P.T已完成", typeof(int)));
            dailyTable.Columns.Add(new DataColumn("P.T未完成", typeof(int)));
            dailyTable.Columns.Add(new DataColumn("P.I已完成", typeof(int)));
            dailyTable.Columns.Add(new DataColumn("P.I未完成", typeof(int)));
            dailyTable.Columns.Add(new DataColumn("S.T", typeof(int)));
            dailyTable.Columns.Add(new DataColumn("體驗課程", typeof(int)));
            dailyTable.Columns.Add(new DataColumn("教練P.I", typeof(int)));


            DataTable dailyCoachTable = new DataTable();
            dailyCoachTable.Columns.Add(new DataColumn("日期", typeof(String)));
            dailyCoachTable.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            dailyCoachTable.Columns.Add(new DataColumn("P.T已完成", typeof(int)));
            dailyCoachTable.Columns.Add(new DataColumn("P.T未完成", typeof(int)));
            dailyCoachTable.Columns.Add(new DataColumn("P.I已完成", typeof(int)));
            dailyCoachTable.Columns.Add(new DataColumn("P.I未完成", typeof(int)));
            dailyCoachTable.Columns.Add(new DataColumn("S.T", typeof(int)));
            dailyCoachTable.Columns.Add(new DataColumn("體驗課程", typeof(int)));
            dailyCoachTable.Columns.Add(new DataColumn("教練P.I", typeof(int)));

            Expression<Func<LessonTime, _ClassTimeGroupKey>> groupBy;
            bool byHour = false;
            if (viewModel.AchievementDateFrom == viewModel.AchievementDateTo)
            {
                byHour = true;
                groupBy = l => new _ClassTimeGroupKey
                {
                    ClassTime = l.ClassTime.Value.Date,
                    Hour = l.HourOfClassTime
                };
            }
            else
            {
                groupBy = l => new _ClassTimeGroupKey
                {
                    ClassTime = l.ClassTime.Value.Date,
                    Hour = 0
                };
            }

            foreach (var g in items.GroupBy(groupBy)
                .OrderBy(g => g.Key.ClassTime).ThenBy(g => g.Key.Hour))
            {
                var r = dailyTable.NewRow();
                r[0] = byHour ? $"{g.Key.ClassTime:yyyy/MM/dd} {g.Key.Hour:00}:00" : $"{g.Key.ClassTime:yyyy/MM/dd}";
                var lessons = g.PTLesson();
                r[1] = lessons.Where(l => l.LessonAttendance != null).Count();
                r[2] = lessons.Where(l => l.LessonAttendance == null).Count();
                lessons = g.Where(l => l.TrainingBySelf == 1);
                r[3] = lessons.Where(l => l.LessonAttendance != null).Count();
                r[4] = lessons.Where(l => l.LessonAttendance == null).Count();
                r[5] = g.Where(l => l.TrainingBySelf == 2).Count();
                r[6] = g.TrialLesson().Count();
                r[7] = g.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI).Count();
                dailyTable.Rows.Add(r);

                foreach (var c in g.GroupBy(l => l.AttendingCoach))
                {
                    var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == c.Key).First();
                    var t = dailyCoachTable.NewRow();
                    t[0] = byHour ? $"{g.Key.ClassTime:yyyy/MM/dd} {g.Key.Hour:00}:00" : $"{g.Key.ClassTime:yyyy/MM/dd}";
                    t[1] = coach.UserProfile.FullName();
                    var lessonItems = c.PTLesson();
                    t[2] = lessonItems.Where(l => l.LessonAttendance != null).Count();
                    t[3] = lessonItems.Where(l => l.LessonAttendance == null).Count();
                    lessonItems = c.Where(l => l.TrainingBySelf == 1);
                    t[4] = lessonItems.Where(l => l.LessonAttendance != null).Count();
                    t[5] = lessonItems.Where(l => l.LessonAttendance == null).Count();
                    t[6] = c.Where(l => l.TrainingBySelf == 2).Count();
                    t[7] = c.TrialLesson().Count();
                    t[8] = c.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI).Count();
                    dailyCoachTable.Rows.Add(t);
                }
            }

            DataTable coachTable = new DataTable();
            coachTable.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            coachTable.Columns.Add(new DataColumn("P.T已完成", typeof(int)));
            coachTable.Columns.Add(new DataColumn("P.T未完成", typeof(int)));
            coachTable.Columns.Add(new DataColumn("P.I已完成", typeof(int)));
            coachTable.Columns.Add(new DataColumn("P.I未完成", typeof(int)));
            coachTable.Columns.Add(new DataColumn("S.T", typeof(int)));
            coachTable.Columns.Add(new DataColumn("體驗課程", typeof(int)));
            coachTable.Columns.Add(new DataColumn("教練P.I", typeof(int)));

            foreach (var c in items.GroupBy(l => l.AttendingCoach))
            {
                var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == c.Key).First();
                var r = coachTable.NewRow();
                r[0] = coach.UserProfile.FullName();
                var lessons = c.PTLesson();
                r[1] = lessons.Where(l => l.LessonAttendance != null).Count();
                r[2] = lessons.Where(l => l.LessonAttendance == null).Count();
                lessons = c.Where(l => l.TrainingBySelf == 1);
                r[3] = lessons.Where(l => l.LessonAttendance != null).Count();
                r[4] = lessons.Where(l => l.LessonAttendance == null).Count();
                r[5] = c.Where(l => l.TrainingBySelf == 2).Count();
                r[6] = c.TrialLesson().Count();
                r[7] = c.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI).Count();
                coachTable.Rows.Add(r);
            }

            DataTable achievement = models.CreateLessonAchievementDetails(items.Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI));

            using (DataSet ds = new DataSet())
            {
                if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                {
                    dailyTable.TableName = "上課統計表（日）" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                    dailyCoachTable.TableName = "上課體能顧問彙總表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                    coachTable.TableName = "上課彙總表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                }
                ds.Tables.Add(dailyTable);
                ds.Tables.Add(dailyCoachTable);
                ds.Tables.Add(coachTable);
                ds.Tables.Add(achievement);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("LessonReport"), DateTime.Now), viewModel.FileDownloadToken);

            }

            dailyTable.Dispose();
            dailyCoachTable.Dispose();
            coachTable.Dispose();
            achievement.Dispose();

            return new EmptyResult();
        }

        public ActionResult ShowLearnerToComplete(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireDailyLesson(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");

            items = items.GetLearnerUncheckedLessons();

            return View("~/Views/Achievement/Module/LearnerToComplete.ascx", items);
        }

        public ActionResult InquireLearnerToCompleteBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)ShowLearnerToComplete(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/LearnerToCompleteBarChartData.ascx", items);
        }

        public ActionResult InquireBranchDonut(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchLessonList(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/BranchDonutData.ascx", items);
        }

        public ActionResult InquireBranchLessonList(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.AchievementDateFrom.HasValue)
            {
                ModelState.AddModelError("AchievementDateFrom", "請選擇查詢起日");
            }

            if (!viewModel.AchievementDateTo.HasValue)
            {
                ModelState.AddModelError("AchievementDateTo", "請選擇查詢迄日");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            ViewResult result = (ViewResult)InquireLesson(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            if (items == null)
            {
                return result;
            }

            return View("~/Views/Achievement/Module/BranchLessonList.ascx", items);
        }

        public ActionResult InquireBranchLessonCount(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchLessonList(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            if (items == null)
            {
                return new EmptyResult { };
            }

            return View("~/Views/Achievement/Module/BranchLessonCount.ascx", items);
        }

        public ActionResult InquireBranchLessonBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchLessonList(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            if (items == null)
            {
                return new EmptyResult { };
            }

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/BranchLessonBarChartData.ascx", items);
        }

        public async Task<ActionResult> CreateBranchLessonListXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchLessonList(viewModel);
            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            DataTable ratioTable = new DataTable();
            ratioTable.Columns.Add(new DataColumn("分店	", typeof(String)));
            ratioTable.Columns.Add(new DataColumn("P.T總堂數", typeof(decimal)));
            ratioTable.Columns.Add(new DataColumn("P.T比例(%)", typeof(decimal)));
            ratioTable.Columns.Add(new DataColumn("P.I總堂數", typeof(decimal)));
            ratioTable.Columns.Add(new DataColumn("P.I比例(%)", typeof(decimal)));
            ratioTable.Columns.Add(new DataColumn("體驗課程總堂數	", typeof(decimal)));
            ratioTable.Columns.Add(new DataColumn("體驗課程比例(%)", typeof(decimal)));
            ratioTable.Columns.Add(new DataColumn("總計", typeof(decimal)));


            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("分店", typeof(String)));
            table.Columns.Add(new DataColumn("時間", typeof(String)));
            table.Columns.Add(new DataColumn("P.T", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I", typeof(decimal)));
            table.Columns.Add(new DataColumn("體驗課程", typeof(decimal)));
            table.Columns.Add(new DataColumn("總計", typeof(decimal)));

            int rangeType = 0;
            if (viewModel.AchievementDateFrom == viewModel.AchievementDateTo)
            {
                rangeType = 0;
            }
            else
            {
                var interval = viewModel.AchievementDateTo - viewModel.AchievementDateFrom;
                if (interval.HasValue)
                {
                    if (interval.Value.TotalDays > 31)
                    {
                        rangeType = 2;
                    }
                    else
                    {
                        rangeType = 1;
                    }
                }
            }

            foreach (var b in models.GetTable<BranchStore>())
            {
                var lessons = items.Where(t => t.BranchID == b.BranchID);
                int PTCount = lessons.PTLesson().Count();

                int PICount = lessons.Where(l => l.TrainingBySelf == 1).Count();

                int trialCount = lessons.TrialLesson().Count();
                int totalCount = PTCount + PICount + trialCount;

                var r = ratioTable.NewRow();
                r[0] = b.BranchName;
                r[1] = PTCount;
                r[3] = PICount;
                r[5] = trialCount;
                r[7] = totalCount;

                if (totalCount > 0)
                {
                    r[2] = Math.Round(PTCount * 100m / totalCount);
                    r[4] = Math.Round(PICount * 100m / totalCount);
                    r[6] = Math.Round(trialCount * 100m / totalCount);
                }

                ratioTable.Rows.Add(r);

                switch (rangeType)
                {
                    case 0:
                        foreach (var h in models.GetTable<DailyWorkingHour>())
                        {
                            var scopeItems = lessons.Where(t => t.HourOfClassTime == h.Hour);
                            r = table.NewRow();
                            r[0] = b.BranchName;
                            r[1] = $"{viewModel.AchievementDateFrom:yyyy/MM/dd} {h.Hour:00}:00~{h.Hour + 1:00}:00";
                            r[2] = scopeItems.PTLesson().Count();
                            r[3] = scopeItems.Where(l => l.TrainingBySelf == 1).Count();
                            r[4] = scopeItems.TrialLesson().Count();
                            r[5] = (decimal)r[2] + (decimal)r[3] + (decimal)r[4];
                            table.Rows.Add(r);
                        }
                        break;
                    case 1:
                        for (DateTime g = viewModel.AchievementDateFrom.Value; g <= viewModel.AchievementDateTo.Value; g = g.AddDays(1))
                        {
                            var scopeItems = lessons.Where(t => t.ClassTime >= g && t.ClassTime < g.AddDays(1));
                            r = table.NewRow();
                            r[0] = b.BranchName;
                            r[1] = $"{g:yyyy/MM/dd}";
                            r[2] = scopeItems.PTLesson().Count();
                            r[3] = scopeItems.Where(l => l.TrainingBySelf == 1).Count();
                            r[4] = scopeItems.TrialLesson().Count();
                            r[5] = (decimal)r[2] + (decimal)r[3] + (decimal)r[4];
                            table.Rows.Add(r);
                        }
                        break;
                    case 2:
                        for (DateTime g = viewModel.AchievementDateFrom.Value; g <= viewModel.AchievementDateTo.Value; g = g.AddMonths(1))
                        {
                            var scopeItems = lessons.Where(t => t.ClassTime >= g && t.ClassTime < g.AddMonths(1));
                            r = table.NewRow();
                            r[0] = b.BranchName;
                            r[1] = $"{g:yyyy/MM}";
                            r[2] = scopeItems.PTLesson().Count();
                            r[3] = scopeItems.Where(l => l.TrainingBySelf == 1).Count();
                            r[4] = scopeItems.TrialLesson().Count();
                            r[5] = (decimal)r[2] + (decimal)r[3] + (decimal)r[4];
                            table.Rows.Add(r);
                        }
                        break;
                }

            }

            using (DataSet ds = new DataSet())
            {
                if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                {
                    ratioTable.TableName = "分店上課總覽" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                    table.TableName = "每日每月分店上課總覽" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                }
                ds.Tables.Add(ratioTable);
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("LessonBranchReport"), DateTime.Now), viewModel.FileDownloadToken);
            }

            ratioTable.Dispose();
            table.Dispose();

            return new EmptyResult();
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Accounting, (int)Naming.RoleID.Manager})]
        public ActionResult InquireMonthlyPerformance(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
            {
                ModelState.AddModelError("AchievementYearMonthFrom", "請選擇查詢月份");
            }

            if (viewModel.ByCoachID == null || viewModel.ByCoachID.Length == 0)
            {
                ModelState.AddModelError("ByCoachID", "請勾選一位");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthFrom))
            {
                viewModel.AchievementDateFrom = DateTime.ParseExact(viewModel.AchievementYearMonthFrom, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture);
                viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1).AddDays(-1);
            }

            if (!String.IsNullOrEmpty(viewModel.AchievementYearMonthTo))
            {
                viewModel.AchievementDateTo = DateTime.ParseExact(viewModel.AchievementYearMonthTo, "yyyy/MM", System.Globalization.CultureInfo.CurrentCulture)
                    .AddMonths(1).AddDays(-1);
            }

            return InquirePerformance(viewModel);
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Accounting, (int)Naming.RoleID.Manager})]
        public ActionResult InquirePerformance(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<V_Tuition> lessons = models.GetTable<V_Tuition>()
                .Where(v => v.PriceStatus != (int)Naming.DocumentLevelDefinition.教練PI)
                .FilterByCompleteLesson();
            IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>()
                .FilterByEffective();

            if (viewModel.BranchID.HasValue)
            {
                lessons = lessons.Where(c => c.BranchID == viewModel.BranchID);
                items = items.Where(c => c.Payment.PaymentTransaction.BranchID == viewModel.BranchID);
            }

            if (viewModel.CoachID.HasValue)
            {
                lessons = lessons.Where(c => c.AttendingCoach == viewModel.CoachID);
                items = items.Where(c => c.CoachID == viewModel.CoachID);
            }

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                lessons = lessons.Where(c => viewModel.ByCoachID.Contains(c.AttendingCoach));
                items = items.Where(t => viewModel.ByCoachID.Contains(t.CoachID));
            }

            if (viewModel.AchievementDateFrom.HasValue)
            {
                lessons = lessons.Where(c => c.ClassTime >= viewModel.AchievementDateFrom);
                items = items.Where(c => c.Payment.PayoffDate >= viewModel.AchievementDateFrom);
            }

            if (viewModel.AchievementDateTo.HasValue)
            {
                lessons = lessons.Where(c => c.ClassTime < viewModel.AchievementDateTo.Value.AddDays(1));
                items = items.Where(c => c.Payment.PayoffDate < viewModel.AchievementDateTo.Value.AddDays(1));
            }

            ViewBag.TuitionItems = items;

            return View("~/Views/Achievement/Module/PerformanceList.ascx", lessons);
        }

        public ActionResult GetCoachCurrentQuarterPerformance(AchievementQueryViewModel viewModel)
        {
            viewModel.AchievementDateFrom = new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1);
            viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(3).AddDays(-1);
            ViewResult result = (ViewResult)InquirePerformance(viewModel);
            result.ViewName = "~/Views/Achievement/Module/CoachCurrentQuarterPerformance.cshtml";
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Accounting, (int)Naming.RoleID.Manager})]
        public ActionResult InquireCoachContribution(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            checkCommonQuery(viewModel);

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            IQueryable<TuitionAchievement> items = InquireTuitionAchievement(viewModel);

            return View("~/Views/Achievement/Module/CoachContributionList.ascx", items);

        }

        private IQueryable<TuitionAchievement> InquireTuitionAchievement(AchievementQueryViewModel viewModel)
        {
            //IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>()
            //    .Where(t => t.Payment.VoidPayment == null || t.Payment.AllowanceID.HasValue);

            IQueryable<TuitionAchievement> items = models.GetTable<Payment>().GetPaymentAchievement(models);

            if (viewModel.CoachID.HasValue)
            {
                items = items.Where(c => c.CoachID == viewModel.CoachID);
            }

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(c => c.Payment.PaymentTransaction.BranchID == viewModel.BranchID);
            }

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                items = items.Where(t => viewModel.ByCoachID.Contains(t.CoachID));
            }

            if (viewModel.AchievementDateFrom.HasValue)
            {
                items = items.Where(c => c.Payment.PayoffDate >= viewModel.AchievementDateFrom);
            }

            if (viewModel.AchievementDateTo.HasValue)
            {
                items = items.Where(c => c.Payment.PayoffDate < viewModel.AchievementDateTo.Value.AddDays(1));
            }

            return items;
        }

        private IQueryable<CourseContract> inquireContract(AchievementQueryViewModel viewModel)
        {
            IQueryable<CourseContract> items = models.GetTable<CourseContract>()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效);

            if (viewModel.CoachID.HasValue)
            {
                items = items.Where(c => c.FitnessConsultant == viewModel.CoachID);
            }

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(c => c.CourseContractExtension.BranchID == viewModel.BranchID);
            }

            if (viewModel.ByCoachID != null && viewModel.ByCoachID.Length > 0)
            {
                items = items.Where(t => viewModel.ByCoachID.Contains(t.FitnessConsultant));
            }

            if (viewModel.AchievementDateFrom.HasValue)
            {
                items = items.Where(c => c.EffectiveDate >= viewModel.AchievementDateFrom);
            }

            if (viewModel.AchievementDateTo.HasValue)
            {
                items = items.Where(c => c.EffectiveDate < viewModel.AchievementDateTo.Value.AddDays(1));
            }

            return items;
        }

        public ActionResult InquireCoachContributionBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireCoachContribution(viewModel);
            IQueryable<TuitionAchievement> items = result.Model as IQueryable<TuitionAchievement>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/CoachContributionBarChartData.ascx", items);
        }

        public async Task<ActionResult> CreateContributionXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireCoachContribution(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;

            using (DataSet ds = new DataSet())
            {
                var table = createContributionDetailsXlsx(items);
                if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                {
                    table.TableName = "業績統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                }
                ds.Tables.Add(table);
                table = models.CreateTuitionAchievementDetails(items);
                ds.Tables.Add(table);
                table = createContributionContractXlsx(inquireContract(viewModel));
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContributionReport"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        private DataTable createContributionDetailsXlsx(IQueryable<TuitionAchievement> items)
        {

            var details = items.GroupBy(t => t.CoachID)
                .Select(g => g.Key);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            table.Columns.Add(new DataColumn("續約合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("續約合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("續約合約數", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約數", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("總計金額", typeof(decimal)));

            foreach (var c in details)
            {
                var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == c).First();

                var coachItems = items.Where(t => t.CoachID == coach.CoachID);
                var count = items.Count();

                var coachAchievement = coachItems.Sum(t => t.ShareAmount) ?? 0m;

                var contractItems = coachItems.Where(t => t.Payment.ContractPayment != null);
                var newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
                var renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                            || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
                var piSessionItems = coachItems.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                var otherItems = coachItems.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                                                && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);
                var r = table.NewRow();
                r[0] = coach.UserProfile.RealName;
                var achievement = renewalContractItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[1] = Math.Round(achievement * 100 / coachAchievement);
                    r[2] = achievement;
                    r[3] = renewalContractItems.Select(t => t.Payment.ContractPayment.CourseContract)
                        .Where(n => n.FitnessConsultant == coach.CoachID)
                        .Select(n => n.ContractID)
                        .Distinct().Count();
                }
                achievement = newContractItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[4] = Math.Round(achievement * 100 / coachAchievement);
                    r[5] = achievement;
                    r[6] = newContractItems.Select(t => t.Payment.ContractPayment.CourseContract)
                        .Where(n => n.FitnessConsultant == coach.CoachID)
                        .Select(n => n.ContractID)
                        .Distinct().Count();
                }
                achievement = piSessionItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[7] = Math.Round(achievement * 100 / coachAchievement);
                    r[8] = achievement;
                }
                achievement = otherItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[9] = Math.Round(achievement * 100 / coachAchievement);
                    r[10] = achievement;
                }

                r[11] = coachAchievement;
                table.Rows.Add(r);
            }

            table.TableName = "業績統計表";

            return table;
        }

        private DataTable createContributionContractXlsx(IQueryable<CourseContract> items)
        {

            var details = items.GroupBy(t => t.FitnessConsultant)
                .Select(g => g.Key);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("體能顧問", typeof(String)));
            table.Columns.Add(new DataColumn("續約合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("續約合約張數", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約張數", typeof(decimal)));
            table.Columns.Add(new DataColumn("總計", typeof(decimal)));

            foreach (var c in details)
            {
                var coach = models.GetTable<ServingCoach>().Where(u => u.CoachID == c).First();

                var coachItems = items.Where(t => t.FitnessConsultant == coach.CoachID);
                var count = coachItems.Count();

                var newContractItems = coachItems.Where(t => t.Renewal == false);
                var renewalContractItems = coachItems.Where(t => t.Renewal == true
                                            || !t.Renewal.HasValue);

                var r = table.NewRow();
                r[0] = coach.UserProfile.RealName;
                var calcCount = renewalContractItems.Count();
                if (calcCount > 0)
                {
                    r[1] = Math.Round(calcCount * 100m / count);
                    r[2] = calcCount;

                }
                calcCount = newContractItems.Count();
                if (calcCount > 0)
                {
                    r[3] = Math.Round(calcCount * 100m / count);
                    r[4] = calcCount;
                }

                r[5] = count;
                table.Rows.Add(r);
            }

            table.TableName = "簽訂合約數統計";

            return table;
        }

        private DataTable createBranchContributionDetailsXlsx(IQueryable<TuitionAchievement> items)
        {

            var details = items.GroupBy(t => t.Payment.PaymentTransaction.BranchID)
                .Select(g => g.Key);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("分店", typeof(String)));
            table.Columns.Add(new DataColumn("續約合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("續約合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("總計金額", typeof(decimal)));

            foreach (var c in details)
            {
                var branch = models.GetTable<BranchStore>().Where(u => u.BranchID == c).First();

                var branchItems = items.Where(t => t.Payment.PaymentTransaction.BranchID == branch.BranchID);

                var branchAchievement = branchItems.Sum(t => t.ShareAmount) ?? 0m;

                var contractItems = branchItems.Where(t => t.Payment.ContractPayment != null);
                var newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
                var renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                            || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
                var piSessionItems = branchItems.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                var otherItems = branchItems.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                                                && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);
                var r = table.NewRow();
                r[0] = branch.BranchName;
                var achievement = renewalContractItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[1] = Math.Round(achievement * 100 / branchAchievement);
                    r[2] = achievement;
                }
                achievement = newContractItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[3] = Math.Round(achievement * 100 / branchAchievement);
                    r[4] = achievement;
                }
                achievement = piSessionItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[5] = Math.Round(achievement * 100 / branchAchievement);
                    r[6] = achievement;
                }
                achievement = otherItems.Sum(t => t.ShareAmount) ?? 0;
                if (achievement > 0)
                {
                    r[7] = Math.Round(achievement * 100 / branchAchievement);
                    r[8] = achievement;
                }

                r[9] = branchAchievement;
                table.Rows.Add(r);
            }

            table.TableName = "業績統計表";

            return table;
        }

        private DataTable createBranchContributionDetailsByDayXlsx(IQueryable<TuitionAchievement> items, AchievementQueryViewModel viewModel)
        {

            var details = items.GroupBy(t => t.Payment.PaymentTransaction.BranchID)
                .Select(g => g.Key);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("分店", typeof(String)));
            table.Columns.Add(new DataColumn("日期", typeof(String)));
            table.Columns.Add(new DataColumn("續約合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("續約合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("總計金額", typeof(decimal)));

            foreach (var c in details)
            {
                var branch = models.GetTable<BranchStore>().Where(u => u.BranchID == c).First();

                for (DateTime g = viewModel.AchievementDateFrom.Value; g <= viewModel.AchievementDateTo.Value; g = g.AddDays(1))
                {
                    var branchItems = items
                                .Where(t => t.Payment.PaymentTransaction.BranchID == branch.BranchID)
                                .Where(t => t.Payment.PayoffDate >= g && t.Payment.PayoffDate < g.AddDays(1));

                    var branchAchievement = branchItems.Sum(t => t.ShareAmount) ?? 0m;

                    var contractItems = branchItems.Where(t => t.Payment.ContractPayment != null);
                    var newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
                    var renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                                || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
                    var piSessionItems = branchItems.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                    var otherItems = branchItems.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                                                    && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);
                    var r = table.NewRow();
                    r[0] = branch.BranchName;
                    r[1] = $"{g:yyyy/MM/dd}";
                    var achievement = renewalContractItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[2] = Math.Round(achievement * 100 / branchAchievement);
                        r[3] = achievement;
                    }
                    achievement = newContractItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[4] = Math.Round(achievement * 100 / branchAchievement);
                        r[5] = achievement;
                    }
                    achievement = piSessionItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[6] = Math.Round(achievement * 100 / branchAchievement);
                        r[7] = achievement;
                    }
                    achievement = otherItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[8] = Math.Round(achievement * 100 / branchAchievement);
                        r[9] = achievement;
                    }

                    r[10] = branchAchievement;
                    table.Rows.Add(r);
                }

            }

            table.TableName = "業績統計表-日期明細";

            return table;
        }

        private DataTable createBranchContributionDetailsByMonthXlsx(IQueryable<TuitionAchievement> items, AchievementQueryViewModel viewModel)
        {

            var details = items.GroupBy(t => t.Payment.PaymentTransaction.BranchID)
                .Select(g => g.Key);

            DataTable table = new DataTable();
            table.Columns.Add(new DataColumn("分店", typeof(String)));
            table.Columns.Add(new DataColumn("日期", typeof(String)));
            table.Columns.Add(new DataColumn("續約合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("續約合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("新合約總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("P.I總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他比例(%)", typeof(decimal)));
            table.Columns.Add(new DataColumn("其他總金額", typeof(decimal)));
            table.Columns.Add(new DataColumn("總計金額", typeof(decimal)));

            foreach (var c in details)
            {
                var branch = models.GetTable<BranchStore>().Where(u => u.BranchID == c).First();

                for (DateTime g = viewModel.AchievementDateFrom.Value; g <= viewModel.AchievementDateTo.Value; g = g.AddMonths(1))
                {
                    var branchItems = items
                                .Where(t => t.Payment.PaymentTransaction.BranchID == branch.BranchID)
                                .Where(t => t.Payment.PayoffDate >= g && t.Payment.PayoffDate < g.AddMonths(1));

                    var branchAchievement = branchItems.Sum(t => t.ShareAmount) ?? 0m;

                    var contractItems = branchItems.Where(t => t.Payment.ContractPayment != null);
                    var newContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == false);
                    var renewalContractItems = contractItems.Where(t => t.Payment.ContractPayment.CourseContract.Renewal == true
                                                || !t.Payment.ContractPayment.CourseContract.Renewal.HasValue);
                    var piSessionItems = branchItems.Where(t => t.Payment.TransactionType == (int)Naming.PaymentTransactionType.自主訓練);
                    var otherItems = branchItems.Where(t => t.Payment.TransactionType != (int)Naming.PaymentTransactionType.體能顧問費
                                                    && t.Payment.TransactionType != (int)Naming.PaymentTransactionType.自主訓練);
                    var r = table.NewRow();
                    r[0] = branch.BranchName;
                    r[1] = $"{g:yyyy/MM}";
                    var achievement = renewalContractItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[2] = Math.Round(achievement * 100 / branchAchievement);
                        r[3] = achievement;
                    }
                    achievement = newContractItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[4] = Math.Round(achievement * 100 / branchAchievement);
                        r[5] = achievement;
                    }
                    achievement = piSessionItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[6] = Math.Round(achievement * 100 / branchAchievement);
                        r[7] = achievement;
                    }
                    achievement = otherItems.Sum(t => t.ShareAmount) ?? 0;
                    if (achievement > 0)
                    {
                        r[8] = Math.Round(achievement * 100 / branchAchievement);
                        r[9] = achievement;
                    }

                    r[10] = branchAchievement;
                    table.Rows.Add(r);
                }

            }

            table.TableName = "業績統計表-月份明細";

            return table;
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Accounting, (int)Naming.RoleID.Manager})]
        public ActionResult InquireBranchContribution(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (!viewModel.AchievementDateFrom.HasValue)
            {
                ModelState.AddModelError("AchievementDateFrom", "請選擇查詢起日");
            }

            if (!viewModel.AchievementDateTo.HasValue)
            {
                ModelState.AddModelError("AchievementDateTo", "請選擇查詢迄日");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            IQueryable<TuitionAchievement> items = InquireTuitionAchievement(viewModel);

            return View("~/Views/Achievement/Module/BranchContributionList.ascx", items);

        }

        public ActionResult InquireBranchContributionDonut(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchContribution(viewModel);
            IQueryable<TuitionAchievement> items = result.Model as IQueryable<TuitionAchievement>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/BranchContributionDonutData.ascx", items);
        }

        public ActionResult InquireBranchContributionCount(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchContribution(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;
            if (items == null)
            {
                return new EmptyResult { };
            }

            return View("~/Views/Achievement/Module/BranchContributionCount.ascx", items);
        }

        public ActionResult InquireBranchContributionBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchContribution(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;
            if (items == null)
            {
                return new EmptyResult { };
            }

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/BranchContributionBarChartData.ascx", items);
        }

        public async Task<ActionResult> CreateBranchContributionXlsxAsync(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireBranchContribution(viewModel);
            IQueryable<TuitionAchievement> items = (IQueryable<TuitionAchievement>)result.Model;

            if (items == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/Shared/JsAlert.cshtml", model: "資料錯誤!!");
            }

            using (DataSet ds = new DataSet())
            {
                var table = createBranchContributionDetailsXlsx(items);
                if (viewModel.AchievementDateFrom.HasValue && viewModel.AchievementDateTo.HasValue)
                {
                    table.TableName = "業績統計表" + String.Format("{0:yyyy-MM-dd}~{1:yyyy-MM-dd}", viewModel.AchievementDateFrom, viewModel.AchievementDateTo);
                }
                ds.Tables.Add(table);
                var interval = (viewModel.AchievementDateTo - viewModel.AchievementDateFrom).Value;
                if (interval.TotalDays > 31)
                {
                    table = createBranchContributionDetailsByMonthXlsx(items, viewModel);
                }
                else
                {
                    table = createBranchContributionDetailsByDayXlsx(items, viewModel);
                }
                ds.Tables.Add(table);

                await ds.SaveAsExcelAsync(Response, String.Format("attachment;filename={0}({1:yyyy-MM-dd HH-mm-ss}).xlsx", HttpUtility.UrlEncode("ContributionReport"), DateTime.Now), viewModel.FileDownloadToken);

            }

            return new EmptyResult();
        }

        public ActionResult InquireCoachContract(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            checkCommonQuery(viewModel);

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            IQueryable<CourseContract> items = inquireContract(viewModel);

            return View("~/Views/Achievement/Module/CoachContributionContractList.ascx", items);
        }

        public ActionResult InquireCoachContributionContractBarChart(AchievementQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireCoachContract(viewModel);
            IQueryable<CourseContract> items = result.Model as IQueryable<CourseContract>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/Achievement/Module/CoachContributionContractBarChartData.ascx", items);
        }


    }
}