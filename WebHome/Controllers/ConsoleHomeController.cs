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
using WebHome.Properties;
using System.Data.Linq;
using Microsoft.Extensions.DependencyInjection;

namespace WebHome.Controllers
{
    [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
    public class ConsoleHomeController : SampleController<UserProfile>
    {
        static ConsoleHomeController()
        {
            BusinessExtensionMethods.ContractViewUrl = item => 
            {
                return $"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CommonHelper/ViewContract")}?pdf=1&contractID={item.ContractID}&t={DateTime.Now.Ticks}";
            };

            BusinessExtensionMethods.ContractServiceViewUrl = item =>
            {
                return $"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CommonHelper/ViewContractService")}?pdf=1&revisionID={item.RevisionID}&t={DateTime.Now.Ticks}";
            };

        }

        public ConsoleHomeController(IServiceProvider serviceProvider) : base(serviceProvider)
        {

        }

        public const String InputErrorView = "~/Views/ConsoleHome/Shared/ReportInputError.cshtml";

        public Task<ActionResult> MainAsync(LessonTimeBookingViewModel viewModel)
        {
            return IndexAsync(viewModel);
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> IndexAsync(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.ClassTimeStart.HasValue)
            {
                viewModel.ClassTimeStart = DateTime.Today;
            }

            var profile = await HttpContext.GetUserAsync();
            if(!viewModel.BranchID.HasValue)
            {
                var branch = models.GetTable<CoachWorkplace>().Where(c => c.CoachID == profile.UID)
                        .Select(c => c.BranchStore).FirstOrDefault();
                if (branch != null)
                {
                    viewModel.BranchID = branch.BranchID;
                    viewModel.BranchName = branch.BranchName;
                }
            }

            return View("~/Views/ConsoleHome/Index.cshtml", profile.LoadInstance(models));
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> CrossBranchIndexAsync(ExerciseBillboardQueryViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();
            return View(profile.LoadInstance(models));
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer })]
        public async Task<ActionResult> CoachBonusIndexAsync(AchievementQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.AchievementDateFrom.HasValue)
            {
                viewModel.AchievementDateFrom = DateTime.Today.FirstDayOfMonth();
            }

            viewModel.AchievementDateTo = viewModel.AchievementDateFrom.Value.AddMonths(1);
            ViewBag.DataItems = viewModel.InquireMonthlySalary(models);

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/BonusCredit/CoachBonusIndex.cshtml", profile.LoadInstance(models));
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> CalendarAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();
            viewModel.KeyID = profile.UID.EncryptKey();
            //return View(profile.LoadInstance(models));
            return View("~/Views/ConsoleHome/SimpleCalendar.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> ContractIndexAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            viewModel.ContractDateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            viewModel.ContractDateTo = viewModel.ContractDateFrom.Value.AddMonths(1).AddDays(-1);

            var profile = await HttpContext.GetUserAsync();
            viewModel.KeyID = profile.UID.EncryptKey();
            return View(profile.LoadInstance(models));
        }

        public async Task<ActionResult> ReportIndexAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            viewModel.KeyID = profile.UID.EncryptKey();
            return View("~/Views/ConsoleHome/ReportIndex.cshtml", profile.LoadInstance(models));

        }

        public async Task<ActionResult> EditBlogArticleAsync(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.DocID = viewModel.DecryptKeyValue();
            }

            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);

            var item = models.GetTable<BlogArticle>().Where(b => b.DocID == viewModel.DocID).FirstOrDefault();
            if (item != null)
            {
                viewModel.AuthorID = item.AuthorID;
                viewModel.Title = item.Title;
                viewModel.Subtitle = item.Subtitle;
                viewModel.DocDate = item.Document.DocDate;
                viewModel.TagID = item.BlogTag.Select(t => (int?)t.CategoryID).ToArray();
            }
            ViewBag.BlogArticle = item;
            return View(profile);
        }

        public async Task<ActionResult> BlogIndexAsync(BlogArticleQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            viewModel.KeyID = profile.UID.EncryptKey();
            return View(profile.LoadInstance(models));
        }

        public async Task<ActionResult> BlogArticleListAsync(BlogArticleQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await BlogIndexAsync(viewModel);

            var items = models.GetTable<BlogArticle>()
                .Where(b => b.BlogTag.Any(c => c.CategoryID == viewModel.CategoryID));

            viewModel.RecordCount = items.Count();
            viewModel.PageSize = viewModel.PageSize ?? 12;
            viewModel.PagingSize = viewModel.PagingSize ?? 5;
            viewModel.CurrentIndex = viewModel.CurrentIndex ?? 0;
            ViewBag.DataItems = items;

            result.ViewName = "BlogArticleList";
            return result;
        }


        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> EditCourseContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }
            viewModel.Version = Naming.ContractVersion.Ver2019;
            var profile = await HttpContext.GetUserAsync();
            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();
            if (item != null)
            {
                viewModel.AgentID = item.AgentID;
                viewModel.ContractType = (CourseContractType.ContractTypeDefinition?)item.ContractType;
                viewModel.ContractDate = item.ContractDate;
                viewModel.Subject = item.Subject;
                viewModel.ValidFrom = item.ValidFrom;
                viewModel.Expiration = item.Expiration;
                viewModel.OwnerID = item.OwnerID;
                viewModel.SequenceNo = item.SequenceNo;
                viewModel.Lessons = item.Lessons;
                viewModel.PriceID = item.PriceID;
                viewModel.DurationInMinutes = item.LessonPriceType.DurationInMinutes;
                var priceType = item.LessonPriceType;
                viewModel.PriceName = $"{priceType.PriceTypeBundle()}{(priceType.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.舊會員續約) ? "(舊會員續約)" : null)}{string.Format("{0,5:##,###,###,###}", priceType.ListPrice)}";
                viewModel.Remark = item.Remark;
                viewModel.FitnessConsultant = item.FitnessConsultant;
                viewModel.Status = item.Status;
                viewModel.UID = item.CourseContractMember.Select(m => m.UID).ToArray();
                viewModel.BranchID = priceType.BranchStore.IsVirtualClassroom() ? priceType.BranchID : item.CourseContractExtension.BranchID;
                viewModel.Renewal = item.Renewal;
                viewModel.TotalCost = item.TotalCost;
                if (item.InstallmentID.HasValue)
                {
                    viewModel.InstallmentPlan = true;
                    viewModel.Installments = item.ContractInstallment.Installments;
                    viewModel.PartialEffectiive = item.PartialEffective(models).Any();
                }
                viewModel.UID = item.CourseContractMember.Select(m => m.UID).ToArray();
                if (item.CourseContractExtension.PaymentMethod != null)
                {
                    viewModel.PaymentMethod = item.CourseContractExtension.PaymentMethod.Split('/');
                }
                viewModel.SignOnline = item.CourseContractExtension.SignOnline;
            }
            else
            {
                viewModel.UID = new int[] { };
                viewModel.AgentID = profile.UID;
                if(profile.IsCoach())
                {
                    viewModel.FitnessConsultant = profile.UID;
                }
                viewModel.ContractType = null;
            }
            if(profile.IsManager() || profile.IsViceManager())
            {
                viewModel.ManagerID = profile.UID;
            }
            ViewBag.ViewModel = viewModel;
            return View(profile.LoadInstance(models));
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> SignCourseContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await LoadCourseContractAsync(viewModel);
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return View("~/Views/Error/ErrorMessage.cshtml", model: "資料錯誤!!");
            }

            if (!(item.Status == (int)Naming.CourseContractStatus.待審核 || item.Status == (int)Naming.CourseContractStatus.待簽名))
            {
                return View("~/Views/Error/ErrorMessage.cshtml", model: "資料錯誤!!");
                //return RedirectToAction("Index");
            }

            result.ViewName = "~/Views/ConsoleHome/SignCourseContract.cshtml";
            return result;
        }

        public async Task<ActionResult> ToSignCourseContractAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return await SignCourseContractAsync (viewModel);
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> SignContractServiceAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await LoadCourseContractAsync(viewModel);
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return View("~/Views/Error/ErrorMessage.cshtml", model: "資料錯誤!!");
            }

            if (!(item.Status == (int)Naming.CourseContractStatus.待確認 || item.Status == (int)Naming.CourseContractStatus.待簽名))
            {
                return View("~/Views/Error/ErrorMessage.cshtml", model: "資料錯誤!!");
            }

            result.ViewName = "~/Views/ConsoleHome/SignContractService.cshtml";

            return result;
        }

        public ActionResult CalendarEventItems(FullCalendarViewModel viewModel)
        {
            ViewResult result = (ViewResult)CalendarEvents(viewModel, true);
            if(viewModel.MasterVer == Naming.MasterVersion.Ver2020)
            {
                result.ViewName = "~/Views/ConsoleHome/Index/Coach/EventItems.cshtml";
            }
            else
            {
                result.ViewName = "~/Views/ConsoleHome/Module/EventItems.cshtml";
            }
            return result;
        }


        public ActionResult CalendarEvents(FullCalendarViewModel viewModel,bool? toHtml = false)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonTime>(i => i.GroupingLesson);
            ops.LoadWith<LessonTime>(i => i.RegisterLesson);
            ops.LoadWith<GroupingLesson>(i => i.RegisterLesson);
            ops.LoadWith<RegisterLesson>(i => i.UserProfile);
            ops.LoadWith<RegisterLesson>(i => i.LessonPriceType);
            models.DataContext.LoadOptions = ops;


            IQueryable<LessonTime> learnerLessons = models.PromptLearnerLessons();
            IQueryable<LessonTime> coachPI = models.PromptCoachPILessons();
            IQueryable<UserEvent> eventItems = models.GetTable<UserEvent>().Where(e => !e.SystemEventID.HasValue);
            if (viewModel.DateFrom.HasValue && viewModel.DateTo.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                coachPI = coachPI.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t =>
                    (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.EndDate >= viewModel.DateFrom.Value && t.EndDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate < viewModel.DateFrom.Value && t.EndDate >= viewModel.DateTo.Value));
            }
            else if (viewModel.DateFrom.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                coachPI = coachPI.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                eventItems = eventItems.Where(t => t.StartDate >= viewModel.DateFrom.Value);
            }
            else if (viewModel.DateTo.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                coachPI = coachPI.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t => t.EndDate < viewModel.DateTo.Value.AddDays(1));
            }
            if (viewModel.BranchID.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.BranchID == viewModel.BranchID);
                coachPI = coachPI.Where(t => t.BranchID == viewModel.BranchID);
                eventItems = eventItems.Where(t => t.BranchID == viewModel.BranchID);
            }
            if (viewModel.UID.HasValue)
            {
                learnerLessons = learnerLessons.Where(t => t.AttendingCoach == viewModel.UID
                                        || t.RegisterLesson.UID == viewModel.UID);
                coachPI = coachPI.Where(t => t.RegisterLesson.UID == viewModel.UID);
                eventItems = eventItems.Where(t => t.UID == viewModel.UID
                    || t.GroupEvent.Any(g => g.UID == viewModel.UID));
            }
            else
            {
                eventItems = eventItems.Where(f => false);
            }

            var items = learnerLessons
                .Select(d => new CalendarEventItem
                {
                    EventTime = d.ClassTime,
                    EventItem = d
                }).ToList();

            items.AddRange(coachPI.GroupBy(l => l.GroupID)
                .ToList()
                .Select(d => new CalendarEventItem
                {
                    EventTime = d.First().ClassTime,
                    EventItem = d.First()
                }));

            items.AddRange(eventItems.Select(v => new CalendarEventItem
            {
                EventTime = v.StartDate,
                EventItem = v
            }));

            if (toHtml == true)
            {

            }
            else
            {
                Response.ContentType = "application/json";
            }
            return View("~/Views/ConsoleHome/Module/CalendarEvents.cshtml", items);

        }



        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> ExerciseBillboardAsync()
        {
            var profile = (await HttpContext.GetUserAsync()).LoadInstance(models);
            return View(profile);
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult InquireExerciseBillboard(ExerciseBillboardQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if(!viewModel.StartDate.HasValue)
            {
                viewModel.StartDate = DateTime.Today.FirstDayOfMonth();
            }
            if(!viewModel.EndDate.HasValue)
            {
                viewModel.EndDate = DateTime.Today;
            }

            IQueryable<RegisterLesson> lessons = models.PromptMemberExerciseRegisterLesson();
            if(viewModel.BranchID.HasValue)
            {
                lessons = lessons.Join(models.GetTable<CoachWorkplace>().Where(w => w.BranchID == viewModel.BranchID), 
                    r => r.UID, w => w.CoachID, (r, w) => r);
            }

            IQueryable<LessonTime> items = lessons.TotalRegisterLessonItems(models)
                    .Where(l => l.LessonAttendance != null)
                    .Where(l => l.ClassTime >= viewModel.StartDate)
                    .Where(l => l.ClassTime < viewModel.EndDate.Value.AddDays(1));

            return View("~/Views/ConsoleHome/Module/CurrentExerciseBillboard.cshtml", items);
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult InquireExerciseBillboardLastMonth(ExerciseBillboardQueryViewModel viewModel)
        {
            var queryDate = DateTime.Today.FirstDayOfMonth();
            viewModel.StartDate = queryDate.AddMonths(-1);
            viewModel.EndDate = queryDate.AddDays(-1);
            ViewResult result = (ViewResult)InquireExerciseBillboard(viewModel);
            result.ViewName = "~/Views/ConsoleHome/Module/ExerciseBillboard.cshtml";
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public ActionResult GetExerciseBillboardDetails(ExerciseBillboardQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)InquireExerciseBillboard(viewModel);

            IQueryable<LessonTime> items = result.Model as IQueryable<LessonTime>;
            if (items == null)
                return new EmptyResult { };

            Response.ContentType = "application/json";
            return View("~/Views/ConsoleHome/Module/ExerciseBillboardDetails.cshtml", items);
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> ApplyContractServiceAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await LoadCourseContractAsync(viewModel);
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return result;
            }

            result.ViewName = "ApplyContractService";
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> ReassignFitnessConsultantAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await LoadCourseContractAsync(viewModel);
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return result;
            }

            result.ViewName = "ReassignFitnessConsultant";
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> PostponeContractExpirationAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await LoadCourseContractAsync(viewModel));
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return result;
            }

            result.ViewName = "PostponeContractExpiration";
            viewModel.Version = (Naming.ContractVersion?)item.CourseContractExtension.Version;
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> TransferContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await LoadCourseContractAsync(viewModel));
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return result;
            }

            result.ViewName = "TransferContract";
            viewModel.Version = (Naming.ContractVersion?)item.CourseContractExtension.Version;
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> TerminateContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await LoadCourseContractAsync(viewModel));
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return result;
            }

            result.ViewName = "TerminateContract";
            viewModel.Version = (Naming.ContractVersion?)item.CourseContractExtension.Version;
            return result;
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> QuickTerminateContractAsync(CourseContractQueryViewModel viewModel)
        {
            var profile = await HttpContext.GetUserAsync();
            ViewResult result = (ViewResult)(await LoadCourseContractAsync(viewModel));
            CourseContract item = (CourseContract)ViewBag.DataItem;

            if (item == null)
            {
                return result;
            }

            if (profile.IsCoach())
                viewModel.FitnessConsultant = profile.UID;
            else
                viewModel.FitnessConsultant = item.FitnessConsultant;

            viewModel.OperationMode = Naming.OperationMode.快速終止;
            viewModel.Status = (int)Naming.CourseContractStatus.待確認;
            result.ViewName = "QuickTerminateContract";

            return result;
        }

        public async Task<ActionResult> DailyLessonsBarChartAsync(LessonTimeBookingViewModel viewModel, String chartType)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.ClassTimeStart.HasValue)
            {
                viewModel.ClassTimeStart = DateTime.Today;
            }

            var profile = await HttpContext.GetUserAsync();
            if (chartType == "Echart")
            {
                return View("~/Views/ConsoleHome/Module/TodayLessonsBarEChart.cshtml", profile.LoadInstance(models));
            }
            else
            {
                return View("~/Views/ConsoleHome/Module/TodayLessonsBarChartC3.cshtml", profile.LoadInstance(models));
            }
        }

        public async Task<ActionResult> ShowLessonSummaryAsync(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.ClassTimeStart.HasValue)
            {
                viewModel.ClassTimeStart = DateTime.Today;
            }

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/ConsoleHome/Module/AboutLessonSummary.cshtml", profile.LoadInstance(models));
        }

        [RoleAuthorize(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Coach, (int)Naming.RoleID.Servitor })]
        public async Task<ActionResult> LearnerProfileAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            int? tmpID = viewModel.LearnerID;
            if (viewModel.KeyID != null)
            {
                tmpID = viewModel.DecryptKeyValue();
            }

            var item = ViewBag.DataItem = models.GetTable<UserProfile>().Where(u => u.UID == tmpID).First();

            //if (item.UserProfileExtension.VipStatus == (int)UserProfileExtension.VipStatusDefinition.VVIP)
            //{
            //    viewModel.AuthCode = viewModel.AuthCode.GetEfficientString();
            //    if (viewModel.AuthCode != AppSettings.Default.AuthorizationCode)
            //    {
            //        viewModel.UrlAction = Url.Action("LearnerProfile", "ConsoleHome");
            //        return View("~/Views/ConsoleHome/PromptAuthorization.cshtml", profile.LoadInstance(models));
            //    }
            //}

            return View("~/Views/ConsoleHome/LearnerProfile2020-1.cshtml", profile.LoadInstance(models));
            //return View("~/Views/ConsoleHome/LearnerProfile2020.cshtml", profile.LoadInstance(models));
            //return View("~/Views/ConsoleHome/LearnerProfile.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> AuthLearnerProfileAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            int? tmpID = viewModel.LearnerID;
            if (viewModel.KeyID != null)
            {
                tmpID = viewModel.DecryptKeyValue();
            }

            var item = ViewBag.DataItem = models.GetTable<UserProfile>().Where(u => u.UID == tmpID).First();

            if (item.UserProfileExtension.VipStatus == (int)UserProfileExtension.VipStatusDefinition.VVIP)
            {
                viewModel.AuthCode = viewModel.AuthCode.GetEfficientString();
                if (viewModel.AuthCode == null)
                {
                    return View("~/Views/LearnerProfile/ProfileModal/PromptAuthorization.cshtml", item);
                }

                if (viewModel.AuthCode != AppSettings.Default.AuthorizationCode)
                {
                    return View("~/Views/LearnerProfile/ProfileModal/FailedAuthorization.cshtml");
                }
            }

            return View("~/Views/LearnerProfile/ProfileModal/PassAuthorization.cshtml", item);
        }


        public async Task<ActionResult> LessonTrainingContentAsync(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = ViewBag.DataItem = models.GetTable<LessonTime>().Where(u => u.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsGoback.cshtml", model: "資料錯誤!!");
            }

            UserProfile learner = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.LearnerID).FirstOrDefault();
            if (learner == null)
            {
                learner = item.GroupingLesson.RegisterLesson.First().UserProfile;
            }

            ViewBag.Learner = learner;

            models.ExecuteCommand("delete QuestionnaireRequest where Status is null and UID = {0} and GroupID = {1}", learner.UID, (int)Naming.QuestionnaireGroup.身體心靈密碼);

            QuestionnaireRequest questionnaire = models.GetEffectiveQuestionnaireRequest(learner).FirstOrDefault();
            if (questionnaire == null)
            {
                if (!learner.IsTrialLearner() && !models.GetTable<QuestionnaireRequest>()
                    .Where(q => q.UID == learner.UID)
                    .Where(q => q.GroupID == (int)Naming.QuestionnaireGroup.身體心靈密碼).Any())
                {
                    questionnaire = learner.UID.AssertQuestionnaire(models, profile, Naming.QuestionnaireGroup.身體心靈密碼, QuestionnaireRequest.PartIDEnum.PartA);
                }
            }
            ViewBag.CurrentQuestionnaire = questionnaire;

            ViewBag.ToCommitLessons = (new LessonOverviewQueryViewModel
            {
                CoachID = profile.UID,
                DateTo = DateTime.Today,
                CoachAttended = false,
                CombinedStatus = new Naming.LessonPriceStatus[]
                        {
                            Naming.LessonPriceStatus.一般課程,
                            Naming.LessonPriceStatus.團體學員課程,
                            Naming.LessonPriceStatus.已刪除,
                            Naming.LessonPriceStatus.點數兌換課程,
                            Naming.LessonPriceStatus.員工福利課程,
                            Naming.LessonPriceStatus.自主訓練,
                            Naming.LessonPriceStatus.體驗課程,
                            Naming.LessonPriceStatus.企業合作方案,
                        },
            }).InquireLesson(models);

            return View("~/Views/ConsoleHome/LessonTrainingContent.cshtml", profile.LoadInstance(models));
        }

        //public ActionResult EditLearnerCharacter(LearnerCharacterViewModel viewModel)
        //{
        //    ViewBag.ViewModel = viewModel;
        //    var profile = await HttpContext.GetUserAsync();

        //    if (viewModel.KeyID != null)
        //    {
        //        viewModel.UID = viewModel.DecryptKeyValue();
        //    }

        //    UserProfile item = ViewBag.DataItem = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).First();

        //    if (viewModel.ToPrepare != true)
        //    {
        //        return View("~/Views/ConsoleHome/PrepareLearnerCharacter.cshtml", profile.LoadInstance(models));
        //    }

        //    QuestionnaireRequest quest = models.GetTable<QuestionnaireRequest>()
        //            .Where(r => r.UID == viewModel.UID)
        //            .Where(r => r.QuestionnaireID == viewModel.QuestionnaireID).FirstOrDefault();

        //    if (quest == null)
        //    {
        //        quest = item.UID.AssertQuestionnaire(models, Naming.QuestionnaireGroup.身體心靈密碼);
        //        viewModel.QuestionnaireID = quest.QuestionnaireID;
        //    }

        //    ViewBag.CurrentQuestionnaire = quest;

        //    return View(profile.LoadInstance(models));
        //}

        public async Task<ActionResult> EditLearnerCharacterAsync(LearnerCharacterViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = await HttpContext.GetUserAsync();

            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserProfile item = ViewBag.DataItem = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).First();

            QuestionnaireRequest quest = models.GetTable<QuestionnaireRequest>()
                    .Where(r => r.UID == item.UID)
                    .Where(r => r.QuestionnaireID == viewModel.QuestionnaireID).FirstOrDefault();

            if (quest == null)
            {
                quest = models.GetEffectiveQuestionnaireRequest(item).FirstOrDefault();
            }

            if (quest == null)
            {
                quest = item.UID.AssertQuestionnaire(models, profile, Naming.QuestionnaireGroup.身體心靈密碼, QuestionnaireRequest.PartIDEnum.PartA);
            }

            if (!quest.Status.HasValue)
            {
                ViewBag.ReferredTo = models.GetLastCompleteQuestionnaireRequest(item.UID, (Naming.QuestionnaireGroup)quest.GroupID);
            }

            viewModel.QuestionnaireID = quest.QuestionnaireID;
            ViewBag.CurrentQuestionnaire = quest;

            if (quest.PartID.HasValue || quest.GroupID == (int)Naming.QuestionnaireGroup.滿意度問卷調查_2017)
            {
                viewModel.ToPrepare = true;
            }
            else
            {
                if (viewModel.ToPrepare == true)
                {
                    models.ExecuteCommand("delete PDQTask where QuestionnaireID = {0}", quest.QuestionnaireID);
                    quest.PartID = (int)QuestionnaireRequest.PartIDEnum.PartA;
                    models.SubmitChanges();
                }
            }

            return View("~/Views/ConsoleHome/PrepareLearnerCharacter2021.cshtml", profile.LoadInstance(models));
        }


        public async Task<ActionResult> EditPaymentForContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await LoadCourseContractAsync(viewModel));
            CourseContract item = (CourseContract)ViewBag.DataItem;
            if (item != null && item.IsPayable(models))
            {
                result.ViewName = "~/Views/PaymentConsole/EditPaymentForContract.cshtml";
            }
            else
            {
                return View("~/Views/Error/ErrorMessage.cshtml", model: "資料錯誤!!");
            }
            return result;

        }

        public async Task<ActionResult> ToEditPaymentForContractAsync(CourseContractQueryViewModel viewModel, String encUID)
        {
            int? uid = null;
            if (encUID != null)
            {
                uid = encUID.DecryptKeyValue();
            }

            var item = models.GetTable<UserProfile>().Where(u => u.UID == uid).FirstOrDefault();
            if (item != null)
            {
                await HttpContext.SignOnAsync(item);
                return await EditPaymentForContractAsync(viewModel);
            }
            else
            {
                return RedirectToAction("Login", "Account");
            }

        }

        public async Task<ActionResult> EditPaymentForPISessionAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await PaymentIndexAsync(viewModel));
            result.ViewName = "~/Views/PaymentConsole/EditPaymentForPISession.cshtml";
            return result;
        }

        public async Task<ActionResult> EditPaymentForSessionAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await PaymentIndexAsync(viewModel));
            result.ViewName = "~/Views/PaymentConsole/EditPaymentForSession.cshtml";
            return result;
        }

        public async Task<ActionResult> EditPaymentForShoppingAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)(await PaymentIndexAsync(viewModel));
            result.ViewName = "~/Views/PaymentConsole/EditPaymentForShopping.cshtml";
            return result;
        }



        public async Task<ActionResult> PaymentIndexAsync(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            viewModel.ScrollToView = false;
            return View(profile.LoadInstance(models));
        }

        public async Task<ActionResult> InquirePaymentIndexAsync(PaymentQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            IQueryable<Payment> items = await viewModel.InquirePaymentAsync(this);
            ViewBag.DataItems = items;

            var profile = await HttpContext.GetUserAsync();
            viewModel.ScrollToView = true;

            return View("~/Views/ConsoleHome/PaymentIndex.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> VoidPaymentAsync(PaymentQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.PaymentID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<Payment>().Where(c => c.PaymentID == viewModel.PaymentID).FirstOrDefault();

            if (item == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "收款資料錯誤!!");
            }

            ViewBag.DataItem = item;

            return View(profile.LoadInstance(models));
        }

        public async Task<ActionResult> ApplyPaymentAchievementAsync(PaymentQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await VoidPaymentAsync(viewModel);
            if (ViewBag.DataItem is Payment item)
            {
                result.ViewName = "~/Views/PaymentConsole/ApplyPaymentAchievement.cshtml";
            }

            return result;
        }

        public async Task<ActionResult> AchievementOverviewAsync(MonthlyIndicatorQueryViewModel viewModel)
        {
            if (viewModel.KeyID != null)
            {
                viewModel.PeriodID = viewModel.DecryptKeyValue();
            }

            if(!viewModel.Year.HasValue || !viewModel.Month.HasValue)
            {
                viewModel.Year = DateTime.Today.Year;
                viewModel.Month = DateTime.Today.Month;
            }

            var item = viewModel.GetAlmostMonthlyIndicator(models, true);

            if (item == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsGoback.cshtml", model: "資料尚未設定!!");
            }

            //if (item == null)
            //{
            //    item = models.InitializeMonthlyIndicator(viewModel.Year.Value, viewModel.Month.Value);
            //}

            //if (viewModel.Year == DateTime.Today.Year && viewModel.Month == DateTime.Today.Month)
            //{
            //    item.UpdateMonthlyAchievement(this);
            //    item.UpdateMonthlyAchievementGoal(models);
            //}

            ViewBag.ViewModel = viewModel;
            ViewBag.DataItem = item;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/BusinessConsole/AchievementOverview.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> ApplyAchievementGoalAsync(MonthlyIndicatorQueryViewModel viewModel)
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

            var item = viewModel.AssertMonthlyIndicator(models);

            ViewBag.ViewModel = viewModel;
            ViewBag.DataItem = item;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/BusinessConsole/ApplyAchievementGoal.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> AchievementReviewAsync(MonthlyIndicatorQueryViewModel viewModel)
        {
            ViewResult result = (ViewResult)await AchievementOverviewAsync(viewModel);
            if (ViewBag.DataItem != null)
            {
                result.ViewName = "~/Views/BusinessConsole/AchievementReview.cshtml";
            }
            return result;
        }

        public async Task<ActionResult> InvoiceOverviewAsync(InvoiceQueryViewModel viewModel)
        {
            if(viewModel.Year.HasValue && viewModel.Month.HasValue)
            {
                viewModel.DateFrom = new DateTime(viewModel.Year.Value, viewModel.Month.Value, 1);
                if (viewModel.DateFrom.Value.Month % 2 == 0)
                {
                    viewModel.DateFrom = viewModel.DateFrom.Value.AddMonths(-1);
                }
                viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(2);
            }
            else if (!viewModel.DateFrom.HasValue || !viewModel.DateTo.HasValue)
            {
                viewModel.DateFrom = DateTime.Today.FirstDayOfMonth();
                if (viewModel.DateFrom.Value.Month % 2 == 0)
                {
                    viewModel.DateFrom = viewModel.DateFrom.Value.AddMonths(-1);
                }
                viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(2);
            }

            var items = models.GetTable<InvoiceItem>()
                .Where(i => i.InvoiceType == (int)Naming.InvoiceTypeDefinition.一般稅額計算之電子發票)
                .Where(i => i.InvoiceDate >= viewModel.DateFrom && i.InvoiceDate < viewModel.DateTo);

            ViewBag.ViewModel = viewModel;
            ViewBag.DataItems = items;

            var cancellationItems = models.GetTable<InvoiceCancellation>().Where(i => i.CancelDate >= viewModel.DateFrom && i.CancelDate < viewModel.DateTo);
            ViewBag.CancellationItems = cancellationItems;

            var allowanceItems = models.GetTable<InvoiceAllowance>().Where(a => a.AllowanceDate >= viewModel.DateFrom && a.AllowanceDate < viewModel.DateTo);
            ViewBag.AllowanceItems = allowanceItems;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/InvoiceConsole/InvoiceOverview.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> InvoiceNoIndexAsync(InvoiceQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.TrackID = viewModel.DecryptKeyValue();
            }

            IQueryable<InvoiceTrackCode> items = models.GetTable<InvoiceTrackCode>();

            if (viewModel.TrackID.HasValue)
            {
                items = items.Where(t => t.TrackID == viewModel.TrackID);
            }
            else
            {
                if (!viewModel.DateFrom.HasValue)
                {
                    viewModel.DateFrom = DateTime.Today.FirstDayOfMonth();
                    if (viewModel.DateFrom.Value.Month % 2 == 0)
                    {
                        viewModel.DateFrom = viewModel.DateFrom.Value.AddMonths(-1);
                    }
                }
                items = items.Where(t => t.Year == viewModel.DateFrom.Value.Year)
                            .Where(t => t.PeriodNo == viewModel.TrackPeriodNo);
            }

            viewModel.TrackCode = viewModel.TrackCode.GetEfficientString();
            if (viewModel.TrackCode != null)
            {
                items = items.Where(t => t.TrackCode == viewModel.TrackCode);
            }

            ViewBag.DataItems = items;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/InvoiceConsole/InvoiceNoIndex.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> LessonOverviewAsync(LessonOverviewQueryViewModel viewModel)
        {

            if (!viewModel.Year.HasValue || !viewModel.Month.HasValue)
            {
                viewModel.Year = DateTime.Today.Year;
                viewModel.Month = DateTime.Today.Month;
            }

            ViewBag.ViewModel = viewModel;

            var items = viewModel.InquireLesson(models, true);
            ViewBag.DataItems = items;


            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/LessonConsole/LessonOverview.cshtml", profile.LoadInstance(models));
        }

        public ActionResult ShowEventDate(LessonTimeBookingViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.ClassTimeStart.HasValue)
            {
                viewModel.ClassTimeStart = DateTime.Today;
            }

            return View("~/Views/ConsoleHome/Index/Coach/Part_1/EventDate.cshtml");
        }

        public async Task<ActionResult> CoachAchievementAsync(MonthlyCoachRevenueIndicatorQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            if (viewModel.KeyID != null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            DateTime idx = DateTime.Today.FirstDayOfMonth();

            var coachItem = models.GetTable<MonthlyIndicator>()
                .Where(m => m.StartDate == idx)
                .Join(models.GetTable<MonthlyCoachRevenueIndicator>().Where(c => c.CoachID == viewModel.CoachID),
                    m => m.PeriodID, c => c.PeriodID, (m, c) => c)
                .FirstOrDefault();

            if (coachItem == null)
            {
                return View("~/Views/ConsoleHome/Shared/JsGoback.cshtml", model: "資料尚未設定!!");
            }

            if (!viewModel.ChartType.HasValue)
            {
                viewModel.ChartType = 1;
            }
            if(!viewModel.DateFrom.HasValue || !viewModel.DateTo.HasValue)
            {
                viewModel.DateFrom = idx.AddMonths(-3);
                viewModel.DateTo = idx;
            }

            ViewBag.DataItem = coachItem;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/AchievementConsole/CoachAchievement.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> LoadCourseContractAsync(CourseContractQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.ContractID = viewModel.DecryptKeyValue();
            }

            var profile = await HttpContext.GetUserAsync();

            var item = models.GetTable<CourseContract>().Where(c => c.ContractID == viewModel.ContractID).FirstOrDefault();

            if (item == null)
            {
                ViewBag.GoBack = true;
                return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "合約資料錯誤!!");
            }

            ViewBag.DataItem = item;

            return View(profile.LoadInstance(models));
        }

        public async Task<ActionResult> RevenueReviewAsync(MonthlyIndicatorQueryViewModel viewModel)
        {
            if(!viewModel.DateFrom.HasValue)
            {
                if (viewModel.Year > 0 && viewModel.Month > 0)
                {
                    viewModel.DateTo = (new DateTime(viewModel.Year.Value, viewModel.Month.Value, 1)).AddMonths(-1);
                    viewModel.DateFrom = viewModel.DateTo.Value.AddMonths(-2);
                }
                else
                {
                    viewModel.DateFrom = DateTime.Today.AddMonths(-3).FirstDayOfMonth();
                }
            }

            if (!viewModel.DateTo.HasValue)
            {
                viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(2);
            }

            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            return View("~/Views/BusinessConsole/RevenueReview.cshtml", profile.LoadInstance(models));

        }

        public async Task<ActionResult> LessonIndexAsync(LessonOverviewQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            if (!viewModel.DateFrom.HasValue)
            {
                viewModel.DateFrom = DateTime.Today.FirstDayOfMonth();
            }
            if (!viewModel.DateTo.HasValue)
            {
                viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(1);
            }

            var profile = await HttpContext.GetUserAsync();
            if (!viewModel.CoachID.HasValue)
            {
                viewModel.CoachID = profile.UID;
            }

            var items = viewModel.InquireLesson(models, true);
            ViewBag.DataItems = items;

            return View("~/Views/LessonConsole/LessonIndex.cshtml", profile.LoadInstance(models));
        }

        public async Task<ActionResult> ProfileIndexAsync(CoachViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = await HttpContext.GetUserAsync();
            if (!viewModel.UID.HasValue)
            {
                viewModel.UID = profile.UID;
            }

            return View("~/Views/ConsoleHome/ProfileIndex.cshtml", profile.LoadInstance(models));
        }


    }
}