using System;
using System.Collections.Generic;
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

using CommonLib.MvcExtension;
using Utility;
using WebHome.Helper;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Security.Authorization;

namespace WebHome.Controllers
{
    [Authorize]
    public class CoachFacetController : SampleController<UserProfile>
    {
        // GET: CoachFacet
        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult Index(DailyBookingQueryViewModel viewModel,bool? showTodoTab)
        {

            if(viewModel.KeyID!=null)
            {
                viewModel.CoachID = viewModel.DecryptKeyValue();
            }

            var profile = HttpContext.GetUser();
            //if (!viewModel.CoachID.HasValue && !profile.IsAssistant())
            //{
            //    viewModel.CoachID = profile.UID;
            //}

            ViewBag.ViewModel = viewModel;
            ViewBag.CurrentCoach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            ViewBag.ShowTodoTab = showTodoTab;
            var item = models.GetTable<UserProfile>().Where(s => s.UID == profile.UID).FirstOrDefault();

            if (ViewBag.CurrentCoach == null)
            {
                if (!item.IsAuthorized(new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer, (int)Naming.RoleID.Manager }))
                {
                    ViewBag.CurrentCoach = item.ServingCoach;
                    viewModel.CoachID = item.UID;
                }
            }

            return View("~/Views/CoachFacet/Index.aspx", item);
        }

        public ActionResult CoachCalendar(FullCalendarViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            return View("~/Views/CoachFacet/Module/CoachCalendar.ascx");
        }

        public ActionResult CalendarEvents(FullCalendarViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;

            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonTime>(i => i.GroupingLesson);
            ops.LoadWith<LessonTime>(i => i.RegisterLesson);
            ops.LoadWith<GroupingLesson>(i => i.RegisterLesson);
            ops.LoadWith<RegisterLesson>(i => i.UserProfile);
            ops.LoadWith<RegisterLesson>(i => i.LessonPriceType);
            models.GetDataContext().LoadOptions = ops;


            IQueryable<LessonTime> dataItems = models.GetTable<LessonTime>();
            IQueryable<UserEvent> eventItems = models.GetTable<UserEvent>().Where(e => e.EventType == 1);
            if(viewModel.DateFrom.HasValue && viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value
                    && t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t => 
                    (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate >= viewModel.DateFrom.Value && t.StartDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.EndDate >= viewModel.DateFrom.Value && t.EndDate < viewModel.DateTo.Value.AddDays(1))
                    || (t.StartDate < viewModel.DateFrom.Value && t.EndDate >= viewModel.DateTo.Value));
            }
            else if (viewModel.DateFrom.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
                eventItems = eventItems.Where(t => t.StartDate >= viewModel.DateFrom.Value);
            }
            else if (viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
                eventItems = eventItems.Where(t => t.EndDate < viewModel.DateTo.Value.AddDays(1));
            }
            if (viewModel.BranchID.HasValue)
            {
                dataItems = dataItems.Where(t => t.BranchID == viewModel.BranchID);
                eventItems = eventItems.Where(t => t.BranchID == viewModel.BranchID);
            }
            if (viewModel.CoachID.HasValue)
            {
                dataItems = dataItems.Where(t => t.AttendingCoach == viewModel.CoachID);
                eventItems = eventItems.Where(t => t.UID == viewModel.CoachID
                    || t.GroupEvent.Any(g => g.UID == viewModel.CoachID));
            }
            else
            {
                eventItems = eventItems.Where(f => false);
            }

            IEnumerable<CalendarEvent> items;
            if (viewModel.DefaultView == "month")
            {
                items = dataItems.ToFullCalendarEventMonthView()
                    .Concat(eventItems.ToFullCalendarCustomizedEventMonthView());
            }
            else
            {
                items = dataItems.ToFullCalendarEventWeekView()
                    .Concat(eventItems.ToFullCalendarCustomizedEventWeekView());
            }

            return Json(items, JsonRequestBehavior.AllowGet);

        }

        public ActionResult VipLessonEvents(FullCalendarViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;

            DataLoadOptions ops = new DataLoadOptions();
            ops.LoadWith<LessonTime>(i => i.GroupingLesson);
            ops.LoadWith<LessonTime>(i => i.RegisterLesson);
            ops.LoadWith<GroupingLesson>(i => i.RegisterLesson);
            ops.LoadWith<RegisterLesson>(i => i.UserProfile);
            ops.LoadWith<RegisterLesson>(i => i.LessonPriceType);
            models.GetDataContext().LoadOptions = ops;

            IQueryable<LessonTime> dataItems = models.GetTable<LessonTime>()
                .Join(models.GetTable<GroupingLesson>()
                    .Join(models.GetTable<RegisterLesson>().Where(r => r.UID == viewModel.UID),
                        g => g.GroupID, r => r.RegisterGroupID, (g, r) => g),
                    l => l.GroupID, g => g.GroupID, (l, g) => l);
            if (viewModel.DateFrom.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime >= viewModel.DateFrom.Value);
            }
            if (viewModel.DateTo.HasValue)
            {
                dataItems = dataItems.Where(t => t.ClassTime < viewModel.DateTo.Value.AddDays(1));
            }
            if (viewModel.BranchID.HasValue)
            {
                dataItems = dataItems.Where(t => t.BranchID == viewModel.BranchID);
            }
            //if (viewModel.CoachID.HasValue)
            //{
            //    dataItems = dataItems.Where(t => t.AttendingCoach == viewModel.CoachID);
            //}

            IEnumerable<CalendarEvent> items;
            if (viewModel.DefaultView == "month")
            {
                items = dataItems.ToFullCalendarEventMonthView();
            }
            else
            {
                items = dataItems.ToFullCalendarEventWeekView();
            }

            return Json(items, JsonRequestBehavior.AllowGet);

        }


        public ActionResult DailyBookingList(FullCalendarViewModel viewModel)
        {

            IQueryable<LessonTime> items = models.GetTable<LessonTime>();

            if(viewModel.LessonDate.HasValue)
            {
                items = items.Where(l => l.ClassTime >= viewModel.LessonDate && l.ClassTime < viewModel.LessonDate.Value.AddDays(1));
            }
            else
            {
                items = items.Where(t => false);
            }

            //if (viewModel.Category == "coach")
            //{
            //    items = items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI);
            //}
            //else if (viewModel.Category == "trial")
            //{
            //    items = items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程);
            //}

            if (viewModel.BranchID.HasValue)
            {
                items = items.Where(l => l.BranchID == viewModel.BranchID);
            }

            if(viewModel.QueryType=="attendee")
            {
                items = items.Join(models.GetTable<GroupingLesson>()
                    .Join(models.GetTable<RegisterLesson>().Where(r => r.UID == viewModel.UID),
                        g => g.GroupID, r => r.RegisterGroupID, (g, r) => g),
                    l => l.GroupID, g => g.GroupID, (l, g) => l);
            }
            else
            {

                if (viewModel.CoachID.HasValue)
                {
                    items = items.Where(l => l.AttendingCoach == viewModel.CoachID);
                }
            }

            return View("~/Views/CoachFacet/Module/DailyBookingList.ascx", items);

        }

        public ActionResult BookingEventDialog(int? lessonID)
        {
            var item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();
            if (item == null)
                return View("~/Views/Shared/MessageView.ascx", model: "課程資料錯誤!!");
            else
                return View("~/Views/CoachFacet/Module/BookingEventDialog.ascx", item);
        }

        public ActionResult UserEventDialog(int? eventID, int? uid)
        {
            var item = models.GetTable<UserEvent>().Where(l => l.EventID == eventID).FirstOrDefault();
            if (item == null)
                return View("~/Views/Shared/MessageView.ascx", model: "行事曆資料錯誤!!");
            else
            {
                ViewBag.ModeratorID = uid;
                return View("~/Views/CoachFacet/Module/UserEventDialog.ascx", item);
            }
        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult RevokeBooking(int lessonID)
        {
            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == lessonID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/MessageView.ascx", model: "課程資料錯誤!!");
            }
            else if(item.ContractTrustTrack.Any(t=>t.SettlementID.HasValue))
            {
                return View("~/Views/Shared/MessageView.ascx", model: "課程資料已信託，不可取消!!");
            }
            //else if (item.LessonPlan != null || item.TrainingPlan.Count > 0)
            //{
            //    ViewBag.Message = "請先刪除預編課程!!";
            //    return RedirectToAction("Coach", "Account", new { lessonDate = lessonDate, message= "請先刪除預編課程!!" });
            //}
            var registerLesson = item.RegisterLesson;
            var contract = registerLesson.RegisterLessonContract?.CourseContract;
            if (contract != null && contract.CourseContractType.ContractCode == "CFA")
            {
                models.ExecuteCommand(@"UPDATE RegisterLesson
                    SET                Attended = {2}
                    FROM            RegisterLessonContract INNER JOIN
                                                RegisterLesson ON RegisterLessonContract.RegisterID = RegisterLesson.RegisterID
                    WHERE        (RegisterLesson.Attended = {1}) AND (RegisterLessonContract.ContractID = {0})", contract.ContractID, (int)Naming.LessonStatus.課程結束, (int)Naming.LessonStatus.上課中);
            }
            else
            {
                models.ExecuteCommand(@"UPDATE RegisterLesson
                    SET        Attended = {2}
                    FROM     LessonTime INNER JOIN
                                   GroupingLesson ON LessonTime.GroupID = GroupingLesson.GroupID INNER JOIN
                                   RegisterLesson ON GroupingLesson.GroupID = RegisterLesson.RegisterGroupID
                    WHERE   (LessonTime.LessonID = {0}) AND (RegisterLesson.Attended = {1})", lessonID, (int)Naming.LessonStatus.課程結束, (int)Naming.LessonStatus.上課中);
            }

            models.DeleteAny<LessonTime>(l => l.LessonID == lessonID);
            if (registerLesson.UserProfile.LevelID == (int)Naming.MemberStatusDefinition.Anonymous //團體課
                || registerLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練  /*自主訓練*/
                || registerLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI
                || registerLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
            {
                models.DeleteAny<RegisterLesson>(l => l.RegisterID == item.RegisterID);
            }

            return View("~/Views/Shared/MessageView.ascx", model: "課程預約已取消!!");

        }

        [RoleAuthorize(RoleID = new int[] { (int)Naming.RoleID.Administrator, (int)Naming.RoleID.Assistant, (int)Naming.RoleID.Officer,(int)Naming.RoleID.Coach })]
        public ActionResult RevokeCoachEvent(int eventID,int uid)
        {
            UserEvent item = models.DeleteAny<UserEvent>(l => l.EventID == eventID && l.UID == uid);
            if (item == null)
            {
                return View("~/Views/Shared/MessageView.ascx", model: "行事曆資料錯誤!!");
            }

            return View("~/Views/Shared/MessageView.ascx", model: "行事曆已刪除!!");

        }

        public ActionResult BookingByCoach(FullCalendarViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var item = models.GetTable<CoachWorkplace>().Where(w => w.CoachID == viewModel.CoachID).FirstOrDefault();
            if(item!=null)
            {
                viewModel.BranchID = item.BranchID;
            }
            return View("~/Views/CoachFacet/Module/BookingByCoach.ascx");
        }

        public ActionResult AttendeeSelector(String userName)
        {
            IEnumerable<RegisterLesson> items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸學員名稱!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }
            else
            {
                items = models.GetTable<RegisterLesson>()
                    .Where(r => r.RegisterLessonContract != null)
                    .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                        && (l.UserProfile.RealName.Contains(userName) || l.UserProfile.Nickname.Contains(userName))
                        && (l.UserProfile.UserProfileExtension != null && !l.UserProfile.UserProfileExtension.CurrentTrial.HasValue))
                    .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                    .Where(l => l.RegisterGroupID.HasValue)
                    .OrderBy(l => l.UID).ThenBy(l => l.ClassLevel).ThenBy(l => l.Lessons);
            }

            return View("~/Views/Lessons/AttendeeSelector.ascx", items);
        }

        public ActionResult BonusLessonSelector(String userName)
        {
            IQueryable<RegisterLesson> items = models.GetTable<RegisterLesson>()
                    .Where(r => r.LessonPriceType.Status == (int)Naming.LessonPriceStatus.點數兌換課程)
                    .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束)
                    .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                    .Where(l => l.RegisterGroupID.HasValue)
                    .OrderBy(l => l.UID);

            userName = userName.GetEfficientString();
            if (userName == null)
            {
                //this.ModelState.AddModelError("userName", "請輸學員名稱!!");
                //ViewBag.ModelState = this.ModelState;
                //return View("~/Views/Shared/ReportInputError.ascx");
            }
            else
            {
                items = items.Where(l => l.UserProfile.RealName.Contains(userName) || l.UserProfile.Nickname.Contains(userName));
            }

            return View("~/Views/Lessons/BonusLessonSelector.ascx", items);
        }

        public ActionResult GiftLessonSelector(String userName)
        {
            IEnumerable<RegisterLesson> items;
            //userName = userName.GetEfficientString();
            //if (userName == null)
            //{
            //    this.ModelState.AddModelError("userName", "請輸學員名稱!!");
            //    ViewBag.ModelState = this.ModelState;
            //    return View("~/Views/Shared/ReportInputError.ascx");
            //}
            //else
            //{
            //    items = models.GetTable<RegisterLesson>()
            //        .Join(models.GetTable<LessonPriceType>()
            //                .Join(models.GetTable<IsWelfareGiftLesson>(), p => p.PriceID, w => w.PriceID, (p, w) => p),
            //            r => r.ClassLevel, p => p.PriceID, (r, p) => r)
            //        .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
            //            && (l.UserProfile.RealName.Contains(userName) || l.UserProfile.Nickname.Contains(userName)))
            //        .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
            //        .Where(l => l.RegisterGroupID.HasValue)
            //        .OrderBy(l => l.UID);
            //}

            items = models.GetTable<RegisterLesson>()
                .Join(models.GetTable<LessonPriceType>()
                        .Join(models.GetTable<IsWelfareGiftLesson>(), p => p.PriceID, w => w.PriceID, (p, w) => p),
                    r => r.ClassLevel, p => p.PriceID, (r, p) => r)
                .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束)
                .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                .Where(l => l.RegisterGroupID.HasValue)
                .OrderBy(l => l.UID);


            return View("~/Views/Lessons/GiftLessonSelector.ascx", items);
        }

        public ActionResult TrialLearnerSelector(String userName)
        {
            IEnumerable<UserProfile> items;

            userName = userName.GetEfficientString();
            if (userName == null)
            {
                //this.ModelState.AddModelError("userName", "請輸學員名稱!!");
                //ViewBag.ModelState = this.ModelState;
                //return View("~/Views/Shared/ReportInputError.ascx");
                items = models.GetTable<UserProfile>().Where(u => u.UserProfileExtension.CurrentTrial.HasValue)
                    .OrderBy(l => l.RealName);

            }
            else
            {
                items = models.GetTable<UserProfile>().Where(u => u.UserProfileExtension.CurrentTrial.HasValue)
                    .Where(l => l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                    .OrderBy(l => l.RealName);
            }

            ViewBag.EnableNew = true;

            return View("~/Views/Lessons/Module/TrialLearnerSelector.ascx", items);
        }

        public ActionResult VipSelector(String userName,bool? forCalendar)
        {

            IEnumerable<UserProfile> items;
            userName = userName.GetEfficientString();
            if (userName == null)
            {
                this.ModelState.AddModelError("userName", "請輸學員名稱!!");
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }
            else
            {
                items = models.GetTable<UserProfile>()
                    .Where(u => u.LevelID != (int)Naming.MemberStatusDefinition.Deleted
                        && u.LevelID != (int)Naming.MemberStatusDefinition.Anonymous)
                    .Where(l => l.RealName.Contains(userName) || l.Nickname.Contains(userName))
                    .Where(l => l.UserRole.Any(r => r.RoleID == (int)Naming.RoleID.Learner)
                        || l.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Learner))
                    .Where(l => l.UserProfileExtension != null && !l.UserProfileExtension.CurrentTrial.HasValue)
                    .OrderBy(l => l.UID);
            }
            if (forCalendar == true)
            {
                return View("~/Views/CoachFacet/Module/VipSelector.ascx", items);
            }
            else
            {
                return View("~/Views/Lessons/VipSelector.ascx", items);
            }
        }

        public ActionResult CommitTrialLesson(LessonTimeViewModel viewModel, TrialLearnerViewModel newTrialLearner)
        {

            ViewBag.ViewModel = viewModel;

            if (viewModel.ClassDate < DateTime.Today)
            {
                ModelState.AddModelError("ClassDate", "預約時間不可早於今天!!");
            }

            if (!this.ModelState.IsValid)
            {
                ViewBag.ModelState = this.ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                ViewBag.Message = "未指定體能顧問!!";
                return View("~/Views/Shared/ViewMessage.ascx");
            }

            RegisterLesson lesson;
            if (!viewModel.UID.HasValue)
            {
                newTrialLearner.RealName = newTrialLearner.RealName.GetEfficientString();
                if (newTrialLearner.RealName == null)
                {
                    this.ModelState.AddModelError("realName", "請輸入學員姓名!!");
                    ViewBag.ModelState = this.ModelState;
                    return View("~/Views/Shared/ReportInputError.ascx");
                }
                else
                {
                    var profile = models.CreateLearner(new LearnerViewModel
                    {
                        RealName = newTrialLearner.RealName,
                        Phone = newTrialLearner.Phone.GetEfficientString(),
                        Gender = newTrialLearner.Gender,
                        CurrentTrial = 1,
                        RoleID = Naming.RoleID.Preliminary
                    });

                    if (profile == null)
                    {
                        return View("~/Views/Shared/MessageView.ascx", model: "無法新增體驗學員!!");
                    }
                    viewModel.UID = profile.UID;
                }
            }

            var priceType = models.CurrentTrialLessonPrice();

            lesson = new RegisterLesson
            {
                UID = viewModel.UID.Value,
                RegisterDate = DateTime.Now,
                GroupingMemberCount = 1,
                Lessons = 1,
                ClassLevel = priceType != null ? priceType.PriceID : (int?)null,
                IntuitionCharge = new IntuitionCharge
                {
                    ByInstallments = 1,
                    Payment = "Cash",
                    FeeShared = 0
                },
                AdvisorID = viewModel.CoachID,
                GroupingLesson = new GroupingLesson { }
            };
            //var installment = new TuitionInstallment
            //{
            //    PayoffDate = viewModel.ClassDate,
            //    PayoffAmount = priceType.ListPrice,
            //    Payment = new Payment
            //    {
            //        PayoffAmount = priceType.ListPrice,
            //        PayoffDate = viewModel.ClassDate
            //    }
            //};
            //installment.Payment.TuitionAchievement.Add(new TuitionAchievement
            //{
            //    CoachID = lesson.AdvisorID.Value,
            //    ShareAmount = installment.PayoffAmount
            //});

            //lesson.IntuitionCharge.TuitionInstallment.Add(installment);
            models.GetTable<RegisterLesson>().InsertOnSubmit(lesson);
            models.SubmitChanges();


            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = priceType.DurationInMinutes,
                TrainingBySelf = viewModel.TrainingBySelf,
                RegisterID = lesson.RegisterID,
                LessonPlan = new LessonPlan
                {

                },
                BranchID = viewModel.BranchID,
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.LevelID.HasValue ? coach.ProfessionalLevel.GradeIndex : null
                }
            };

            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Hour;

            timeItem.GroupID = lesson.RegisterGroupID;
            timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
            {
                UID = lesson.UID
            });
            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);
            //models.SubmitChanges();

            var timeExpansion = models.GetTable<LessonTimeExpansion>();

            for (int i = 0; i <= (timeItem.DurationInMinutes + timeItem.ClassTime.Value.Minute - 1) / 60; i++)
            {
                timeExpansion.InsertOnSubmit(new LessonTimeExpansion
                {
                    ClassDate = timeItem.ClassTime.Value.Date,
                    //LessonID = timeItem.LessonID,
                    LessonTime = timeItem,
                    Hour = timeItem.ClassTime.Value.Hour + i,
                    RegisterID = lesson.RegisterID
                });
            }


            try
            {
                models.SubmitChanges();
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
                ViewBag.Message = "預約未完成，請重新預約!!";
                return View("~/Views/Shared/MessageView.ascx");
            }

            return Json(new { result = true, message = "上課時間預約完成!!" });
        }

        public ActionResult UpdateBookingByCoach(LessonTimeBookingViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/MessageView.ascx", model: "修改上課時間資料不存在!!");
            }

            if (item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                return View("~/Views/Shared/MessageView.ascx", model: "課程資料已信託，不可修改!!");
            }

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = item.InvitedCoach,
                AttendingCoach = item.AttendingCoach,
                ClassTime = viewModel.ClassTimeStart,
                DurationInMinutes = item.DurationInMinutes
                //DurationInMinutes = (int)(viewModel.ClassTimeEnd.Value - viewModel.ClassTimeStart.Value).TotalMinutes
            };

            if(models.GetTable<Settlement>().Any(s=>s.StartDate<=viewModel.ClassTimeStart && s.EndExclusiveDate>viewModel.ClassTimeStart))
            {
                ViewBag.Message = "修改上課時間(" + String.Format("{0:yyyy/MM/dd}",viewModel.ClassTimeStart) + "已信託結算!!";
                return View("~/Views/Shared/MessageView.ascx");
            }

            var users = models.CheckOverlappingBooking(timeItem, item);
            if (users.Count() > 0)
            {
                ViewBag.Message = "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!";
                return View("~/Views/Shared/MessageView.ascx");
            }

            models.DeleteAll<LessonTimeExpansion>(t => t.LessonID == item.LessonID);

            //item.InvitedCoach = viewModel.CoachID;
            //item.AttendingCoach = viewModel.CoachID;
            item.ClassTime = viewModel.ClassTimeStart;
            item.DurationInMinutes = timeItem.DurationInMinutes;
            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassTimeStart.Value.Hour))
                item.HourOfClassTime = viewModel.ClassTimeStart.Value.Hour;
            //item.BranchID = viewModel.BranchID;
            //item.TrainingBySelf = viewModel.TrainingBySelf;
            foreach (var t in item.ContractTrustTrack)
            {
                t.EventDate = viewModel.ClassTimeStart.Value;
            }

            models.SubmitChanges();

            var timeExpansion = models.GetTable<LessonTimeExpansion>();
            if (item.RegisterLesson.GroupingMemberCount > 1)
            {
                for (int i = 0; i <= (item.DurationInMinutes + item.ClassTime.Value.Minute - 1) / 60; i++)
                {
                    foreach (var regles in item.RegisterLesson.GroupingLesson.RegisterLesson)
                    {
                        timeExpansion.InsertOnSubmit(new LessonTimeExpansion
                        {
                            ClassDate = item.ClassTime.Value.Date,
                            LessonID = item.LessonID,
                            Hour = item.ClassTime.Value.Hour + i,
                            RegisterID = regles.RegisterID
                        });
                    }
                }
            }
            else
            {
                for (int i = 0; i <= (item.DurationInMinutes + item.ClassTime.Value.Minute - 1) / 60; i++)
                {
                    timeExpansion.InsertOnSubmit(new LessonTimeExpansion
                    {
                        ClassDate = item.ClassTime.Value.Date,
                        LessonID = item.LessonID,
                        Hour = item.ClassTime.Value.Hour + i,
                        RegisterID = item.RegisterID
                    });
                }
            }

            models.SubmitChanges();

            if(item.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練)
            {
                models.ExecuteCommand("update TuitionInstallment set PayoffDate = {0} where RegisterID = {1} ", item.ClassTime, item.RegisterID);
            }

            return Json(new { result = true, message = "上課時間修改完成!!" });

        }

        public ActionResult LessonsSummary(LessonQueryViewModel viewModel)
        {
            var profile = HttpContext.GetUser();
            //if (!viewModel.CoachID.HasValue && !profile.IsSysAdmin())
            //{
            //    viewModel.CoachID = profile.UID;
            //}

            ViewBag.ViewModel = viewModel;
            ViewBag.CurrentCoach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            var item = models.GetTable<UserProfile>().Where(s => s.UID == profile.UID).FirstOrDefault();

            return View("~/Views/CoachFacet/Module/LessonsSummary.ascx", item);
        }

        public ActionResult QueryLesson(LessonQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            IQueryable<LessonTime> items = models.GetTable<LessonTime>();
            if (viewModel.CoachID.HasValue)
                items = items.Where(t => t.AttendingCoach == viewModel.CoachID);
            if (viewModel.QueryStart.HasValue)
                items = items.Where(t => t.ClassTime >= viewModel.QueryStart && t.ClassTime < viewModel.QueryStart.Value.AddMonths(1));
            if (viewModel.ClassTime.HasValue)
                items = items.Where(t => t.ClassTime >= viewModel.ClassTime && t.ClassTime < viewModel.ClassTime.Value.AddDays(1));

            return View("~/Views/CoachFacet/Module/LessonsSummaryReport.ascx", items);
        }

        public ActionResult ShowCoachToCommit(LessonQueryViewModel viewModel,Naming.LessonQueryType? query )
        {
            ViewResult result = (ViewResult)QueryLesson(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            items = items
                .Where(t => t.LessonAttendance == null);

            items = items.ByLessonQueryType(query);

            return View("~/Views/CoachFacet/Module/DailyBookingList.ascx", items);
        }

        public ActionResult ShowLearnerMarkAttended(LessonQueryViewModel viewModel, Naming.LessonQueryType? query)
        {
            ViewResult result = (ViewResult)QueryLesson(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            items = items
                .Where(l => l.LessonPlan.CommitAttendance.HasValue);

            items = items.ByLessonQueryType(query);

            return View("~/Views/CoachFacet/Module/DailyBookingList.ascx", items);
        }

        public ActionResult ShowLearnerToCommit(LessonQueryViewModel viewModel, Naming.LessonQueryType? query)
        {
            ViewResult result = (ViewResult)QueryLesson(viewModel);
            IQueryable<LessonTime> items = (IQueryable<LessonTime>)result.Model;
            items = items
                .Where(l => !l.LessonPlan.CommitAttendance.HasValue);

            items = items.ByLessonQueryType(query);

            return View("~/Views/CoachFacet/Module/DailyBookingList.ascx", items);
        }

        public ActionResult QueryQuestionnaire(LessonQueryViewModel viewModel,bool? committed)
        {
            ViewBag.ViewModel = viewModel;

            IQueryable<QuestionnaireRequest> items = models.GetTable<QuestionnaireRequest>();
            if(committed==true)
            {
                items = items.Where(q => q.PDQTask.Any());
            }
            else
            {
                items = items.Where(q => !q.PDQTask.Any());
            }

            if (viewModel.QueryStart.HasValue)
            {
                items = items.Where(q => q.RequestDate >= viewModel.QueryStart && q.RequestDate < viewModel.QueryStart.Value.AddMonths(1));
            }
            if (viewModel.CoachID.HasValue)
            {
                var uid = models.GetTable<LearnerFitnessAdvisor>().Where(l => l.CoachID == viewModel.CoachID).Select(l => l.UID);
                items = items.Where(q => uid.Contains(q.UID));
            }

            return View("~/Views/CoachFacet/Module/QuestionnaireList.ascx", items);
        }

        public ActionResult LearnerQuestionnaire(int id)
        {
            var model = models.GetTable<QuestionnaireRequest>().Where(l => l.QuestionnaireID == id).FirstOrDefault();

            if (model == null)
            {
                ViewBag.Message = "問卷資料不存在!!";
                return View("~/Views/Shared/MessageView.ascx");
            }

            return View("~/Views/CoachFacet/Module/LearnerQuestionnaire.ascx", model);

        }

        public ActionResult LessonComments(int? commentID)
        {
            var model = models.GetTable<LessonComment>().Where(l => l.CommentID == commentID).FirstOrDefault();

            if (model == null)
            {
                ViewBag.Message = "留言資料不存在!!";
                return View("~/Views/Shared/MessageView.ascx");
            }

            return View("~/Views/CoachFacet/Module/LessonComments.ascx", model);

        }

        public ActionResult PushComment(int hearerID,String comment)
        {
            var profile = HttpContext.GetUser();
            LessonComment item = new LessonComment
            {
                Comment = comment,
                HearerID = hearerID,
                SpeakerID = profile.UID,
                CommentDate = DateTime.Now,
                Status = (int)Naming.IncommingMessageStatus.未讀
            };

            models.GetTable<LessonComment>().InsertOnSubmit(item);
            models.SubmitChanges();

            return View("~/Views/CoachFacet/Module/LessonCommentItem.ascx", item);

        }

        public ActionResult EditCoachEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (profile == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            var item = models.GetTable<UserEvent>().Where(u => u.EventID == viewModel.EventID).FirstOrDefault();
            if (item != null)
            {
                viewModel.StartDate = item.StartDate;
                viewModel.EndDate = item.EndDate;
                viewModel.Title = item.Title;
                viewModel.Accompanist = item.Accompanist;
                viewModel.ActivityProgram = item.ActivityProgram;
                viewModel.MemberID = item.GroupEvent.Select(v => v.UID).ToArray();
                viewModel.BranchID = item.BranchID;
            }

            return View("~/Views/CoachFacet/Module/EditCoachEvent.ascx");
        }

        public ActionResult EditCoachEventDialog(UserEventViewModel viewModel)
        {
            ViewResult result = (ViewResult)EditCoachEvent(viewModel);
            result.ViewName = "~/Views/CoachFacet/Module/EditCoachEventDialog.ascx";
            return result;
        }


        public ActionResult CommitCoachEvent(UserEventViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;

            var profile = models.GetTable<UserProfile>().Where(u => u.UID == viewModel.UID).FirstOrDefault();
            if (profile == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            if (!viewModel.StartDate.HasValue)
            {
                ModelState.AddModelError("StartDate", "請選擇開始時間!!");
            }
            if (!viewModel.EndDate.HasValue)
            {
                ModelState.AddModelError("EndDate", "請選擇結束時間!!");
            }
            if (String.IsNullOrEmpty(viewModel.Title) && String.IsNullOrEmpty(viewModel.ActivityProgram))
            {
                ModelState.AddModelError("ActivityProgram", "請輸入行事曆內容!!");
            }

            if (!ModelState.IsValid)
            {
                ViewBag.ModelState = ModelState;
                return View("~/Views/Shared/ReportInputError.ascx");
            }

            var item = models.GetTable<UserEvent>().Where(u => u.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                item = new UserEvent
                {
                    UID = profile.UID
                };
                models.GetTable<UserEvent>().InsertOnSubmit(item);
            }

            item.StartDate = viewModel.StartDate.Value;
            item.EndDate = viewModel.EndDate.Value;
            item.Title = viewModel.Title;
            item.ActivityProgram = viewModel.ActivityProgram;
            item.Accompanist = viewModel.Accompanist;
            item.EventType = 1;
            item.BranchID = viewModel.BranchID;

            models.SubmitChanges();

            models.ExecuteCommand("delete GroupEvent where EventID = {0} ", item.EventID);
            if (viewModel.MemberID != null && viewModel.MemberID.Length > 0)
            {
                foreach (var memberID in viewModel.MemberID)
                {
                    models.ExecuteCommand("insert GroupEvent(EventID,UID) values ({0},{1}) ", item.EventID, memberID);
                }
            }

            return Json(new { result = true, message = "行事曆已儲存!!" });
        }

        public ActionResult UpdateCoachEvent(UserEventBookingViewModel viewModel)
        {

            ViewBag.ViewModel = viewModel;
            if (viewModel.KeyID != null)
            {
                viewModel.UID = viewModel.DecryptKeyValue();
            }

            UserEvent item = models.GetTable<UserEvent>().Where(l => l.EventID == viewModel.EventID).FirstOrDefault();
            if (item == null)
            {
                return View("~/Views/Shared/MessageView.ascx", model: "修改行事曆資料不存在!!");
            }

            if (item.UID != viewModel.UID)
            {
                return View("~/Views/Shared/MessageView.ascx", model: "原行事曆發起人才可以修改時間!!");
            }

            item.StartDate = viewModel.StartDate.Value;
            item.EndDate = viewModel.EndDate.Value;

            models.SubmitChanges();
            return Json(new { result = true, message = "行事曆時間修改完成!!" });

        }

        public ActionResult CoachToday(int coachID)
        {
            var item = models.GetTable<ServingCoach>().Where(s => s.CoachID == coachID).FirstOrDefault();
            if (item == null)
                return new EmptyResult();
            else
                return View("~/Views/CoachFacet/Module/CoachToday.ascx", item);
        }

        public ActionResult QueryAttendee()
        {
            return View("~/Views/CoachFacet/Module/QueryAttendee.ascx");
        }

        public ActionResult ShowAttenderListByCoach(int coachID)
        {

            ServingCoach item = models.GetTable<ServingCoach>().Where(u => u.CoachID == coachID).FirstOrDefault();

            if (item == null)
            {
                return View("~/Views/Shared/JsAlert.ascx", model: "資料錯誤!!");
            }

            return View("~/Views/CoachFacet/Module/ShowAttenderListByCoach.ascx", item);

        }

        public ActionResult SelectCoachFacet(DailyBookingQueryViewModel viewModel)
        {
            ViewBag.ViewModel = viewModel;
            var profile = HttpContext.GetUser();
            var item = profile.LoadInstance(models);

            return View("~/Views/CoachFacet/Module/SelectCoachFacet.ascx", item);
        }

    }
}