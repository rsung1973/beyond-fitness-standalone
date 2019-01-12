using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Web;
using Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class BusinessExtensionMethods
    {
        public static void AttendLesson<TEntity>(this ModelSource<TEntity> models, LessonTime item)
                    where TEntity : class, new()
        {
            if (!item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                LessonAttendance attendance = item.LessonAttendance;
                if (attendance == null)
                    attendance = item.LessonAttendance = new LessonAttendance { };
                attendance.CompleteDate = DateTime.Now;

                models.SubmitChanges();
            }

            var lesson = item.RegisterLesson;
            if (lesson.Lessons - (lesson.AttendedLessons ?? 0) <= lesson.GroupingLesson.LessonTime.Count(t => t.LessonAttendance != null))
            {
                foreach (var r in lesson.GroupingLesson.RegisterLesson)
                {
                    r.Attended = (int)Naming.LessonStatus.課程結束;
                }
                models.SubmitChanges();
            }

            var contract = lesson.RegisterLessonContract?.CourseContract;
            if (contract != null && contract.RemainedLessonCount() == 0)
            {
                foreach(var r in contract.RegisterLessonContract)
                {
                    r.RegisterLesson.Attended = (int)Naming.LessonStatus.課程結束;
                }
                contract.Status = (int)Naming.CourseContractStatus.已履行;
                models.SubmitChanges();
            }
        }

        public static void CheckLearnerQuestionnaireRequest<TEntity>(this ModelSource<TEntity> models, RegisterLesson item)
            where TEntity : class, new()
        {
            if (item.LessonPriceType.ExcludeQuestionnaire.HasValue)
                return;

            if (item.Lessons <= 10)
                return;

            int countBase;
            //if (item.Lessons <= 10)
            //{
            //    countBase = item.Lessons;
            //}
            //else 
            if (item.Lessons <= 51)
            {
                countBase = item.Lessons / 2;
            }
            else
            {
                countBase = item.Lessons / 3;
            }

            int totalAttendance =
                models.GetTable<LessonTime>().Where(l => l.GroupID == item.RegisterGroupID && l.LessonAttendance != null).Count()
                    + (item.AttendedLessons ?? 0);
            int checkAttendance = totalAttendance;
            bool underCount = true;
            if (item.QuestionnaireRequest.Count > 0)
            {
                var questItem = item.QuestionnaireRequest.OrderByDescending(q => q.QuestionnaireID).First();
                checkAttendance = models.GetTable<LessonTime>().Where(l => l.GroupID == item.RegisterGroupID
                    && l.LessonAttendance != null && l.LessonAttendance.CompleteDate > questItem.RequestDate).Count();
                underCount = totalAttendance < countBase * (item.QuestionnaireRequest.Count + 1)
                    && item.Lessons >= countBase * (item.QuestionnaireRequest.Count + 1);
            }

            if (((item.Lessons - totalAttendance >= countBase && checkAttendance >= countBase) || (totalAttendance + 1) == item.Lessons) && underCount)
            {
                CreateQuestionnaire(models, item);
            }

        }

        public static QuestionnaireRequest CreateQuestionnaire<TEntity>(this ModelSource<TEntity> models, RegisterLesson item) where TEntity : class, new()
        {
            var group = models.GetTable<QuestionnaireGroup>().OrderByDescending(q => q.GroupID).FirstOrDefault();
            if (group != null && !item.QuestionnaireRequest.Any(q => q.PDQTask.Count == 0))
            {
                var questionnaire = new QuestionnaireRequest
                {
                    GroupID = group.GroupID,
                    RegisterID = item.RegisterID,
                    RequestDate = DateTime.Now,
                    UID = item.UID
                };
                models.GetTable<QuestionnaireRequest>().InsertOnSubmit(questionnaire);
                models.SubmitChanges();

                return questionnaire;
            }
            return null;
        }

        public static bool CheckCurrentQuestionnaireRequest<TEntity>(this ModelSource<TEntity> models, RegisterLesson item)
            where TEntity : class, new()
        {
            if (item.LessonPriceType.ExcludeQuestionnaire.HasValue)
                return false;

            if (item.Lessons <= 10)
                return false;

            int countBase;
            //if (item.Lessons <= 10)
            //{
            //    countBase = item.Lessons;
            //}
            //else 
            if (item.Lessons <= 51)
            {
                countBase = item.Lessons / 2;
            }
            else
            {
                countBase = item.Lessons / 3;
            }

            int totalAttendance =
                models.GetTable<LessonTime>().Where(l => l.GroupID == item.RegisterGroupID && l.LessonAttendance != null).Count()
                    + (item.AttendedLessons ?? 0) + 1;
            int checkAttendance = totalAttendance;
            bool underCount = true;
            if (item.QuestionnaireRequest.Count > 0)
            {
                var questItem = item.QuestionnaireRequest.OrderByDescending(q => q.QuestionnaireID).First();
                checkAttendance = models.GetTable<LessonTime>().Where(l => l.GroupID == item.RegisterGroupID
                    && l.LessonAttendance != null && l.LessonAttendance.CompleteDate > questItem.RequestDate).Count();
                underCount = totalAttendance < countBase * (item.QuestionnaireRequest.Count + 1)
                        && item.Lessons >= countBase * (item.QuestionnaireRequest.Count + 1);
            }

            if (((item.Lessons - totalAttendance >= countBase && checkAttendance >= countBase) || (totalAttendance + 1) == item.Lessons) && underCount)
            {
                var group = models.GetTable<QuestionnaireGroup>().OrderByDescending(q => q.GroupID).FirstOrDefault();
                if (group != null && !item.QuestionnaireRequest.Any(q => q.PDQTask.Count == 0))
                {
                    return true;
                }
            }

            return false;
        }

        public static bool CouldMarkToAttendLesson<TEntity>(this ModelSource<TEntity> models, LessonTime item)
            where TEntity : class, new()
        {
            if (models.IsAttendanceOverdue(item))
                return false;

            return !item.LessonFitnessAssessment.Any(f => f.LessonFitnessAssessmentReport.Count(r => r.FitnessAssessmentItem.ItemID == 16) == 0
                    || f.LessonFitnessAssessmentReport.Count(r => r.FitnessAssessmentItem.ItemID == 17) == 0
                    || f.LessonFitnessAssessmentReport.Count(r => r.FitnessAssessmentItem.GroupID == 3) == 0);
        }

        public static bool IsAttendanceOverdue<TEntity>(this ModelSource<TEntity> models, LessonTime item)
            where TEntity : class, new()
        {
            var due = models.GetTable<LessonAttendanceDueDate>().OrderByDescending(d => d.DueDate).FirstOrDefault();
            return due != null && item.ClassTime < due.DueDate;
        }

        public static DailyBookingQueryViewModel InitializeBookingQuery(this HttpContextBase context, string userName, int? branchID, UserProfile item)
        {
            DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)context.GetCacheValue(CachingKey.DailyBookingQuery);
            if (viewModel == null)
            {
                viewModel = new DailyBookingQueryViewModel
                {
                    //DateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1),
                    UserName = userName,
                    MonthInterval = 1,
                    BranchID = branchID,
                    CoachID = item.UID,
                    HasQuery = false
                };
                //viewModel.DateTo = viewModel.DateFrom.Value.AddMonths(1);
                context.SetCacheValue(CachingKey.DailyBookingQuery, viewModel);
            }


            return viewModel;
        }

        public static IEnumerable<CalendarEvent> ToFullCalendarEventMonthView(this IEnumerable<LessonTime> dataItems)
        {
            var today = DateTime.Today;

            IEnumerable<CalendarEvent> items;

            items = dataItems.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null)
                    .GroupBy(t => t.ClassTime.Value.Date)
                    .Select(g => new CalendarEvent
                    {
                        id = "course",
                        title = g.Count().ToString(),
                        start = g.Key.ToString("yyyy-MM-dd"),
                        description = "企業方案",
                        allDay = true,
                        className = g.Key < today ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-yellow" },
                        icon = /*g.Key < today ? "fa-check" :*/ "fa-clock-o"
                    });

            dataItems = dataItems.Where(l => l.RegisterLesson.RegisterLessonEnterprise == null);

            items = items.Concat(dataItems
                .Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0)
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.正常
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.已刪除
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.點數兌換課程)
                .GroupBy(t => t.ClassTime.Value.Date)
                .Select(g => new CalendarEvent
                {
                    id = "course",
                    title = g.Count().ToString(),
                    start = g.Key.ToString("yyyy-MM-dd"),
                    description = "P.T session",
                    allDay = true,
                    className = g.Key < today ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-blue" },
                    icon = /*g.Key < today ? "fa-check" :*/ "fa-clock-o"
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
                .GroupBy(t => t.ClassTime.Value.Date)
                .Select(g => new CalendarEvent
                {
                    id = "coach",
                    title = g.Count().ToString(),
                    start = g.Key.ToString("yyyy-MM-dd"),
                    description = "教練P.I",
                    allDay = true,
                    className = g.Key < today ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-teal" },
                    icon = /*g.Key < today ? "fa-check" :*/ "fa-university"
                }));

            items = items.Concat(dataItems
                .Where(t => t.TrainingBySelf == 1)
                .GroupBy(t => t.ClassTime.Value.Date)
                .Select(g => new CalendarEvent
                {
                    id = "self",
                    title = g.Count().ToString(),
                    start = g.Key.ToString("yyyy-MM-dd"),
                    description = "P.I session",
                    allDay = true,
                    className = g.Key < today ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-red" },
                    icon = "fa-child" // g.Key < today ? "fa-ckeck" : "fa-clock-o"
                }));

            items = items.Concat(dataItems
                .Where(t => t.TrainingBySelf == 2)
                .GroupBy(t => t.ClassTime.Value.Date)
                .Select(g => new CalendarEvent
                {
                    id = "home",
                    title = g.Count().ToString(),
                    start = g.Key.ToString("yyyy-MM-dd"),
                    description = "S.T session",
                    allDay = true,
                    className = g.Key < today ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-yellow" },
                    icon = "fa-child" // g.Key < today ? "fa-ckeck" : "fa-clock-o"
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
                .GroupBy(t => t.ClassTime.Value.Date)
                .Select(g => new CalendarEvent
                {
                    id = "trial",
                    title = g.Count().ToString(),
                    start = g.Key.ToString("yyyy-MM-dd"),
                    description = "體驗課程",
                    allDay = true,
                    className = g.Key < today ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-pink" },
                    icon = "fa-magic" // g.Key < today ? "fa-ckeck" : "fa-clock-o"
                }));

            return items;
        }

        public static IEnumerable<CalendarEvent> ToFullCalendarCustomizedEventMonthView(this IEnumerable<UserEvent> dataItems)
        {
            var today = DateTime.Today;

            IEnumerable<CalendarEvent> items;
            items = dataItems
                    .Select(g => new CalendarEvent
                    {
                        id = "my" + g.EventID,
                        title = g.Title ?? g.ActivityProgram,
                        start = g.StartDate.ToString("yyyy-MM-dd"),
                        end = g.EndDate.ToString("yyyy-MM-dd"),
                        description = g.Title == null ? "" : g.ActivityProgram,
                        lessonID = g.EventID,
                        allDay = true,
                        className = new string[] { "event", "bg-color-greenLight" },  //g.StartDate < today ? g.EndDate < today ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pink" },
                        icon = ""   //"fa-magic"
                    });

            return items;
        }

        public static IEnumerable<CalendarEvent> ToFullCalendarEventWeekView(this IQueryable<LessonTime> sourceItems)
        {
            var today = DateTime.Today;

            IEnumerable<CalendarEvent> items;

            IQueryable<LessonTime> dataItems = sourceItems.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null);
            items = dataItems
                    .Select(g => new CalendarEvent
                    {
                        id = g.LessonID.ToString(),
                        lessonID = g.LessonID,
                        title = String.Join("、", g.GroupingLesson.RegisterLesson.Select(r => r.UserProfile.RealName)),
                        start = String.Format("{0:O}", g.ClassTime),
                        end = String.Format("{0:O}", g.ClassTime.Value.AddMinutes(g.DurationInMinutes.Value)),
                        //description = "自由教練",
                        allDay = false,
                        className = g.LessonAttendance == null ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-grayDark" },
                        editable = g.LessonAttendance == null,
                    });

            dataItems = sourceItems.Where(l => l.RegisterLesson.RegisterLessonEnterprise == null);
            items = items.Concat(dataItems
                .Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0)
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.正常
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.已刪除
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.點數兌換課程)
                .Select(g => new CalendarEvent
                {
                    id = g.LessonID.ToString(),
                    lessonID = g.LessonID,
                    title = String.Join("、", g.GroupingLesson.RegisterLesson.Select(r => r.UserProfile.RealName)),
                    start = String.Format("{0:O}", g.ClassTime),
                    end = String.Format("{0:O}", g.ClassTime.Value.AddMinutes(g.DurationInMinutes.Value)),
                    //description = "P.T session",
                    allDay = false,
                    className = g.LessonAttendance == null ? new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-grayDark" },
                    editable = g.LessonAttendance == null,
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
                .Select(g => new CalendarEvent
                {
                    id = g.LessonID.ToString(),
                    lessonID = g.LessonID,
                    title = g.AsAttendingCoach.UserProfile.RealName,
                    start = String.Format("{0:O}", g.ClassTime),
                    end = String.Format("{0:O}", g.ClassTime.Value.AddMinutes(g.DurationInMinutes.Value)),
                    //description = "教練P.I",
                    allDay = false,
                    className = g.LessonAttendance == null ? new string[] { "event", "bg-color-teal" } : new string[] { "event", "bg-color-grayDark" },
                    editable = g.LessonAttendance == null,
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null
                }));

            items = items.Concat(dataItems
                .Where(t => t.TrainingBySelf == 1)
                .Select(g => new CalendarEvent
                {
                    id = g.LessonID.ToString(),
                    lessonID = g.LessonID,
                    title = g.RegisterLesson.UserProfile.RealName,
                    start = String.Format("{0:O}", g.ClassTime),
                    end = String.Format("{0:O}", g.ClassTime.Value.AddMinutes(g.DurationInMinutes.Value)),
                    //description = "自主訓練",
                    allDay = false,
                    className = g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-grayDark" },
                    editable = g.LessonAttendance == null,
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null
                }));

            items = items.Concat(dataItems
                .Where(t => t.TrainingBySelf == 2)
                .Select(g => new CalendarEvent
                {
                    id = g.LessonID.ToString(),
                    lessonID = g.LessonID,
                    title = g.RegisterLesson.UserProfile.RealName,
                    start = String.Format("{0:O}", g.ClassTime),
                    end = String.Format("{0:O}", g.ClassTime.Value.AddMinutes(g.DurationInMinutes.Value)),
                    //description = "自主訓練",
                    allDay = false,
                    className = new string[] { "event", "bg-color-yellow" },
                    editable = true,
                    icon = null,
                }));


            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
                .Select(g => new CalendarEvent
                {
                    id = g.LessonID.ToString(),
                    lessonID = g.LessonID,
                    title = g.RegisterLesson.UserProfile.RealName,
                    start = String.Format("{0:O}", g.ClassTime),
                    end = String.Format("{0:O}", g.ClassTime.Value.AddMinutes(g.DurationInMinutes.Value)),
                    //description = "體驗課程",
                    allDay = false,
                    className = g.LessonAttendance == null ? new string[] { "event", "bg-color-pink" } : new string[] { "event", "bg-color-grayDark" },
                    editable = g.LessonAttendance == null,
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null
                }));

            //items = items.Concat(dataItems
            //    .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.正常
            //        || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.已刪除
            //|| t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.點數兌換課程)
            //    .GroupBy(t => t.ClassTime.Value.Date)
            //    .Select(g => new CalendarEvent
            //    {
            //        id = "all",
            //        title = g.Sum(v => v.RegisterLesson.GroupingMemberCount).ToString(),
            //        start = g.Key.ToString("yyyy-MM-dd"),
            //        description = "P.T session",
            //        allDay = true,
            //        className = new string[] { "event", "bg-color-blue" },
            //        icon = /*g.Key < today ? "fa-check" :*/ "fa-clock-o"
            //    }));
            items = items.Concat(dataItems.ToFullCalendarEventMonthView());

            return items;
        }

        public static IEnumerable<CalendarEvent> ToFullCalendarCustomizedEventWeekView(this IEnumerable<UserEvent> dataItems)
        {
            var today = DateTime.Today;

            IEnumerable<CalendarEvent> items;

            items = dataItems
                    .Select(g => new CalendarEvent
                    {
                        id = "my" + g.EventID,
                        title = g.Title ?? g.ActivityProgram,
                        start = String.Format("{0:O}", g.StartDate),
                        end = String.Format("{0:O}", g.EndDate),
                        description = g.Title == null ? "" : g.ActivityProgram,
                        lessonID = g.EventID,
                        allDay = false,
                        editable = true,
                        className = new string[] { "event", "bg-color-greenLight" },  //g.StartDate < today ? g.EndDate < today ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pink" },
                        icon = ""   //"fa-magic"
                    });

            return items;
        }


        public static IEnumerable<UserProfile> CheckOverlappingBooking<TEntity>(this ModelSource<TEntity> models, LessonTime intendedBooking, LessonTime originalBooking)
                    where TEntity : class, new()
        {
            int durationHours = (intendedBooking.ClassTime.Value.Minute + intendedBooking.DurationInMinutes.Value + 59) / 60;

            var oriUID = originalBooking.GroupingLesson.RegisterLesson.Select(r => r.UID).ToArray();

            var overlappingItems = models.GetTable<LessonTimeExpansion>().Where(t => t.ClassDate == intendedBooking.ClassTime.Value.Date
                    && t.Hour >= intendedBooking.ClassTime.Value.Hour
                    && t.Hour < (intendedBooking.ClassTime.Value.Hour + durationHours)
                    && t.LessonID != originalBooking.LessonID)
                .Select(r => r.RegisterLesson.UserProfile).Where(u => oriUID.Contains(u.UID));

            return overlappingItems;

        }

        public static UserProfile CreateLearner<TEntity>(this ModelSource<TEntity> models, LearnerViewModel viewModel)
                    where TEntity : class, new()
        {
            String memberCode;

            while (true)
            {
                memberCode = createMemberCode();
                if (!models.GetTable<UserProfile>().Any(u => u.MemberCode == memberCode))
                {
                    break;
                }
            }

            UserProfile item = new UserProfile
            {
                PID = memberCode,
                MemberCode = memberCode,
                LevelID = (int)Naming.MemberStatusDefinition.ReadyToRegister,
                RealName = viewModel.RealName,
                Phone = viewModel.Phone,
                Birthday = viewModel.Birthday,
                UserProfileExtension = new UserProfileExtension
                {
                    Gender = viewModel.Gender,
                    AthleticLevel = viewModel.AthleticLevel,
                    CurrentTrial = viewModel.CurrentTrial
                }
            };
            if (viewModel.Birthday.HasValue)
                item.BirthdateIndex = viewModel.Birthday.Value.Month * 100 + viewModel.Birthday.Value.Day;


            item.UserRole.Add(new UserRole
            {
                RoleID = viewModel.RoleID.HasValue ? (int)viewModel.RoleID.Value : (int)Naming.RoleID.Preliminary
            });


            models.GetTable<UserProfile>().InsertOnSubmit(item);
            models.SubmitChanges();

            item.InitializeSystemAnnouncement(models);

            return item;
        }

        private static String createMemberCode()
        {
            Thread.Sleep(1);
            Random rnd = new Random();

            return (new StringBuilder()).Append((char)((int)'A' + rnd.Next(26)))
                .Append((char)((int)'A' + rnd.Next(26)))
                .Append(rnd.Next(100000000))
                .ToString();
        }

        public static IQueryable<QuestionnaireRequest> GetQuestionnaireRequest<TEntity>(this ModelSource<TEntity> models, UserProfile profile)
            where TEntity : class, new()
        {
            return models.GetTable<QuestionnaireRequest>().Where(q => q.UID == profile.UID
                && q.PDQTask.Count == 0 && !q.Status.HasValue);
        }

        public static int? BonusPoint<TEntity>(this UserProfile item, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<PDQTaskBonus>()
                .Where(t => t.PDQTask.UID == item.UID)
                .Where(t => !t.BonusExchange.Any())
                .Sum(x => x.PDQTask.PDQQuestion.PDQQuestionExtension.BonusPoint);
        }

        public static IEnumerable<PDQTaskBonus> BonusPointList<TEntity>(this UserProfile item, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<PDQTaskBonus>()
                .Where(t => t.PDQTask.UID == item.UID)
                .Where(t => !t.BonusExchange.Any());
        }

        public static IQueryable<LessonTime> GetLessonAttendance<TEntity>(this ModelSource<TEntity> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month, int? branchID)
            where TEntity : class, new()
        {
            DateTime? queryDateTo = dateTo;

            var items = models.GetTable<LessonTime>()
                //.Where(t => t.LessonAttendance != null)
                .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自由教練預約)
                .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                //.Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.體驗課程)
                //.Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.點數兌換課程)
                .Where(t => t.RegisterLesson.RegisterLessonEnterprise == null
                    || t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                .Where(t => t.LessonAttendance != null || t.LessonPlan.CommitAttendance.HasValue);

            if (coachID.HasValue)
            {
                items = items.Where(t => t.AttendingCoach == coachID);
            }

            if (dateFrom.HasValue)
            {
                items = items.Where(t => t.ClassTime >= dateFrom);
            }

            if (queryDateTo.HasValue)
            {
                items = items.Where(t => t.ClassTime < queryDateTo.Value.AddDays(1));
            }
            else if (month.HasValue)
            {
                queryDateTo = dateFrom.Value.AddMonths(month.Value);
                items = items.Where(t => t.ClassTime < queryDateTo);
                queryDateTo = queryDateTo.Value.AddDays(-1);
                dateTo = queryDateTo;
            }

            if (branchID.HasValue)
            {
                items = items.Where(t => t.BranchID == branchID);
            }

            return items;
        }

        public static IQueryable<LessonTime> GetPISessionAttendance<TEntity>(this ModelSource<TEntity> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month, int? branchID)
            where TEntity : class, new()
        {
            DateTime? queryDateTo = dateTo;

            var items = models.GetTable<LessonTime>()
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練
                    || (t.RegisterLesson.RegisterLessonEnterprise != null && t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練))
                .Where(t => t.LessonAttendance != null || t.LessonPlan.CommitAttendance.HasValue);

            if (coachID.HasValue)
            {
                items = items.Where(t => t.AttendingCoach == coachID);
            }

            if (dateFrom.HasValue)
            {
                items = items.Where(t => t.ClassTime >= dateFrom);
            }

            if (queryDateTo.HasValue)
            {
                items = items.Where(t => t.ClassTime < queryDateTo.Value.AddDays(1));
            }
            else if (month.HasValue)
            {
                queryDateTo = dateFrom.Value.AddMonths(month.Value);
                items = items.Where(t => t.ClassTime < queryDateTo);
                queryDateTo = queryDateTo.Value.AddDays(-1);
                dateTo = queryDateTo;
            }

            if (branchID.HasValue)
            {
                items = items.Where(t => t.BranchID == branchID);
            }

            return items;
        }

        public static int CalcAchievement<TEntity>(this ModelSource<TEntity> models, IEnumerable<LessonTime> items)
            where TEntity : class, new()
        {
            var lessons = items.Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue)
                .Select(l => l.GroupingLesson)
                        .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                        .Where(r => r.IntuitionCharge != null);

            //Utility.Logger.Debug(
            //String.Join("\r\n", lessons.Select(r => r.RegisterID + "\t"
            //    + r.IntuitionCharge.Payment + "\t"
            //    + r.IntuitionCharge.FeeShared + "\t"
            //    + r.LessonPriceType.CoachPayoff + "\t"
            //    + r.LessonPriceType.CoachPayoffCreditCard + "\t"
            //    + r.GroupingLessonDiscount.PercentageOfDiscount + "\t"
            //    )));


            var fullAchievement = lessons.Where(r => r.IntuitionCharge.Payment == "Cash" || r.IntuitionCharge.FeeShared == 0).Sum(l => l.LessonPriceType.CoachPayoff * l.GroupingLessonDiscount.PercentageOfDiscount / 100)
                + lessons.Where(r => r.IntuitionCharge.Payment == "CreditCard" && r.IntuitionCharge.FeeShared == 1).Sum(l => l.LessonPriceType.CoachPayoffCreditCard * l.GroupingLessonDiscount.PercentageOfDiscount / 100);

            //if (items.First().AttendingCoach == 2089)
            //{
            //    Utility.Logger.Debug(items.First().AttendingCoach + "=>" + lessons.Sum(l => l.LessonPriceType.ListPrice * l.GroupingLessonDiscount.PercentageOfDiscount / 100) + ":" + fullAchievement);
            //    foreach(var t in lessons.Where(r => r.IntuitionCharge.Payment == "Cash" || r.IntuitionCharge.FeeShared == 0))
            //    {
            //        Utility.Logger.Debug(t.LessonPriceType.PriceID + ":" + t.LessonPriceType.ListPrice + ":CoachPayoff:" + t.LessonPriceType.CoachPayoff);
            //    }
            //    foreach (var t in lessons.Where(r => r.IntuitionCharge.Payment == "CreditCard" && r.IntuitionCharge.FeeShared == 1))
            //    {
            //        Utility.Logger.Debug(t.LessonPriceType.PriceID + ":" + t.LessonPriceType.ListPrice + ":CoachPayoffCreditCard:" + t.LessonPriceType.CoachPayoffCreditCard);
            //    }

            //}

            lessons = items.Where(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue)
                .Select(l => l.GroupingLesson)
                        .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                        .Where(r => r.IntuitionCharge != null);

            var halfAchievement = lessons.Where(r => r.IntuitionCharge.Payment == "Cash" || r.IntuitionCharge.FeeShared == 0).Sum(l => l.LessonPriceType.CoachPayoff * l.GroupingLessonDiscount.PercentageOfDiscount / 100) / 2
                + lessons.Where(r => r.IntuitionCharge.Payment == "CreditCard" && r.IntuitionCharge.FeeShared == 1).Sum(l => l.LessonPriceType.CoachPayoffCreditCard * l.GroupingLessonDiscount.PercentageOfDiscount / 100) / 2;

            return (fullAchievement ?? 0) + (halfAchievement ?? 0);
        }

        public static int CalcAchievement<TEntity>(this ModelSource<TEntity> models, IEnumerable<LessonTime> items, out int shares)
            where TEntity : class, new()
        {
            shares = 0;
            var allLessons = items
                .Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue)
                .Select(l => l.GroupingLesson)
                        .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);

            var lessons = allLessons.Where(r => r.RegisterLessonEnterprise == null);
            var enterpriseLessons = allLessons.Where(r => r.RegisterLessonEnterprise != null);

            var fullAchievement = lessons
                .Sum(l => l.LessonPriceType.CoachPayoffCreditCard
                    * l.GroupingLessonDiscount.PercentageOfDiscount / 100)
                + enterpriseLessons
                    .Sum(l => l.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
                        * l.GroupingLessonDiscount.PercentageOfDiscount / 100);

            allLessons = items.Where(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue)
                .Select(l => l.GroupingLesson)
                        .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);

            lessons = allLessons.Where(r => r.RegisterLessonEnterprise == null);
            enterpriseLessons = allLessons.Where(r => r.RegisterLessonEnterprise != null);

            var halfAchievement = (lessons
                .Sum(l => l.LessonPriceType.CoachPayoffCreditCard
                    * l.GroupingLessonDiscount.PercentageOfDiscount / 100)
                + enterpriseLessons
                    .Sum(l => l.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
                        * l.GroupingLessonDiscount.PercentageOfDiscount / 100)) / 2;

            var courseItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise == null);
            var enterpriseItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null);

            shares = ((int?)courseItems.Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue)
                .Sum(l => l.RegisterLesson.LessonPriceType.CoachPayoffCreditCard
                    * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
                    * l.LessonTimeSettlement.MarkedGradeIndex / 100) ?? 0)
                + ((int?)courseItems.Where(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue)
                .Sum(l => l.RegisterLesson.LessonPriceType.CoachPayoffCreditCard
                    * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
                    * l.LessonTimeSettlement.MarkedGradeIndex / 100) / 2 ?? 0)
                + ((int?)enterpriseItems.Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue)
                .Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
                    * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
                    * l.LessonTimeSettlement.MarkedGradeIndex / 100) ?? 0)
                + ((int?)enterpriseItems.Where(t => t.LessonAttendance == null || !t.LessonPlan.CommitAttendance.HasValue)
                .Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
                    * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
                    * l.LessonTimeSettlement.MarkedGradeIndex / 100) / 2 ?? 0);

            return (fullAchievement ?? 0) + (halfAchievement ?? 0);
        }


        public static IQueryable<TuitionAchievement> GetTuitionAchievement<TEntity>(this ModelSource<TEntity> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month)
            where TEntity : class, new()
        {
            IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>()
                .Where(t => t.Payment.VoidPayment == null || t.Payment.AllowanceID.HasValue);
            Expression<Func<TuitionAchievement, bool>> queryExpr = c => true;

            DateTime? queryDateTo = dateTo;

            if (dateFrom.HasValue)
            {
                queryExpr = queryExpr.And(i => i.Payment.PayoffDate >= dateFrom);
            }
            if (queryDateTo.HasValue)
            {
                queryExpr = queryExpr.And(i => i.Payment.PayoffDate < queryDateTo.Value.AddDays(1));
            }
            else if (month.HasValue)
            {
                queryDateTo = dateFrom.Value.AddMonths(month.Value);
                queryExpr = queryExpr.And(i => i.Payment.PayoffDate < queryDateTo);
                queryDateTo = queryDateTo.Value.AddDays(-1);
                dateTo = queryDateTo;
            }

            items = items.Where(queryExpr);

            if (coachID.HasValue)
            {
                items = items.Where(t => t.CoachID == coachID);
            }

            return items;
        }

        public static void CheckProfessionalLeve<TEntity>(this ModelSource<TEntity> models, ServingCoach item)
            where TEntity : class, new()
        {
            if (!item.LevelID.HasValue || item.ProfessionalLevel.ProfessionalLevelReview == null)
                return;

            DateTime? quarterEnd = new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1);
            DateTime quarterStart = quarterEnd.Value.AddMonths(-3);

            if (models.GetTable<CoachRating>().Any(g => g.CoachID == item.CoachID && g.RatingDate >= quarterEnd))
                return;

            var attendanceCount = models.GetLessonAttendance(item.CoachID, quarterStart, ref quarterEnd, null, null).Count();
            var PISessionCount = models.GetPISessionAttendance(item.CoachID, quarterStart, ref quarterEnd, null, null).Count();
            attendanceCount += ((PISessionCount + 1) / 2);

            var tuition = models.GetTuitionAchievement(item.CoachID, quarterStart, ref quarterEnd, null);
            var summary = tuition.Sum(t => t.ShareAmount) ?? 0;
            bool qualifiedCert = item.CoachCertificate.Count(c => c.Expiration >= quarterStart) >= 2;

            CoachRating ratingItem = new CoachRating
            {
                AttendanceCount = attendanceCount,
                CoachID = item.CoachID,
                RatingDate = DateTime.Now,
                TuitionSummary = summary,
                LevelID = item.LevelID.Value,
            };
            item.CoachRating.Add(ratingItem);

            if (!qualifiedCert)
            {
                if (item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.HasValue)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
                }
            }
            else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == 4)
            {
                if (attendanceCount >= 165 && summary >= 240000)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
                }
            }
            else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == 5)
            {
                if (attendanceCount >= 185 && summary >= 320000)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
                }
                else if (!(attendanceCount >= 165 && summary >= 240000))
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
                }

            }
            else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == 3)
            {
                if (attendanceCount < 280 || summary < 440000)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
                }
            }
            else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == 2)
            {
                if (attendanceCount >= 280 && summary >= 500000)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
                }
                else if (!(attendanceCount >= 245 && summary >= 390000))
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
                }
            }
            else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == 1)
            {
                if (attendanceCount >= 245 && summary >= 440000)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
                }
                else if (!(attendanceCount >= 215 && summary >= 340000))
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
                }
            }
            else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == 0)
            {
                if (attendanceCount >= 215 && summary >= 380000)
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
                }
                else if (!(attendanceCount >= 185 && summary >= 290000))
                {
                    ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
                }
            }
            else
            {
                ratingItem.LevelID = item.LevelID.Value;
            }

            models.SubmitChanges();
            models.ExecuteCommand("update ServingCoach set LevelID={0} where CoachID={1}", ratingItem.LevelID, item.CoachID);
            models.ExecuteCommand(@"
                UPDATE LessonTimeSettlement
                SET        ProfessionalLevelID = ServingCoach.LevelID
                FROM     LessonTime INNER JOIN
                               LessonTimeSettlement ON LessonTime.LessonID = LessonTimeSettlement.LessonID INNER JOIN
                               ServingCoach ON LessonTime.AttendingCoach = ServingCoach.CoachID
                WHERE   (LessonTime.ClassTime >= {0}) AND (ServingCoach.CoachID = {1}) ", quarterEnd, item.CoachID);

        }

        //public static void CheckProfessionalLeve<TEntity>(this ModelSource<TEntity> models, ServingCoach item)
        //    where TEntity : class, new()
        //{
        //    if (item.LevelID == (int)Naming.ProfessionLevelDefinition.AFM_1st
        //        || item.LevelID == (int)Naming.ProfessionLevelDefinition.AFM_2nd
        //        || item.LevelID == (int)Naming.ProfessionLevelDefinition.FM_1st
        //        || item.LevelID == (int)Naming.ProfessionLevelDefinition.FM_2nd
        //        || !item.UserProfile.UserRoleAuthorization.Any(r => r.RoleID == (int)Naming.RoleID.Coach))
        //        return;

        //    DateTime? quarterEnd = new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1);
        //    DateTime quarterStart = quarterEnd.Value.AddMonths(-3);

        //    var attendanceCount = models.GetLessonAttendance(item.CoachID, quarterStart, ref quarterEnd, null, null).Count();
        //    var tuition = models.GetTuitionAchievement(item.CoachID, quarterStart, ref quarterEnd, null);
        //    var summary = tuition.Sum(t => t.ShareAmount) ?? 0;
        //    bool qualifiedCert = item.CoachCertificate.Count(c => c.Expiration >= quarterStart) >= 2;

        //    CoachRating ratingItem = new CoachRating
        //    {
        //        AttendanceCount = attendanceCount,
        //        CoachID = item.CoachID,
        //        RatingDate = DateTime.Now,
        //        TuitionSummary = summary
        //    };
        //    item.CoachRating.Add(ratingItem);

        //    if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_5_2nd)
        //    {
        //        if (!qualifiedCert || attendanceCount < 270 || summary < 390000)
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_2nd;
        //        }
        //        else
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_5_2nd;
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_5_1st)
        //    {
        //        if (!qualifiedCert || attendanceCount < 270 || summary < 390000)
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_1st;
        //        }
        //        else
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_5_1st;
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_4_2nd)
        //    {
        //        if (attendanceCount >= 300 && summary >= 500000)
        //        {
        //            if (qualifiedCert)
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_5_2nd;
        //            else
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_2nd;
        //        }
        //        else if (!qualifiedCert || !(attendanceCount >= 240 && summary >= 300000))
        //        {
        //            item.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_2nd;
        //        }
        //        else
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_2nd;
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_4_1st)
        //    {
        //        if (attendanceCount >= 300 && summary >= 500000)
        //        {
        //            if (qualifiedCert)
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_5_1st;
        //            else
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_1st;
        //        }
        //        else if (!qualifiedCert || !(attendanceCount >= 240 && summary >= 300000))
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_1st;
        //        }
        //        else
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_1st;
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_3_2nd)
        //    {
        //        if (attendanceCount >= 240 && summary >= 350000)
        //        {
        //            if (qualifiedCert)
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_2nd;
        //            else
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_2nd;
        //        }
        //        else if (qualifiedCert)
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_2nd;
        //        }
        //        else
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_2_2nd;
        //        }
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_3_1st)
        //    {
        //        if (attendanceCount >= 240 && summary >= 350000)
        //        {
        //            if (qualifiedCert)
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_4_1st;
        //            else
        //                ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_1st;
        //        }
        //        else if (qualifiedCert)
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_1st;
        //        }
        //        else
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_2_1st;
        //        }
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_2_2nd)
        //    {
        //        //27.5 % LEVEL3(考取兩張國際證照Beyond認可未過期)
        //        if (qualifiedCert)
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_2nd;
        //        }
        //        else
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_2_2nd;
        //        }
        //    }
        //    else if (item.LevelID == (int)Naming.ProfessionLevelDefinition.Level_2_1st)
        //    {
        //        if (qualifiedCert)
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_3_1st;
        //        }
        //        else
        //        {
        //            ratingItem.LevelID = (int)Naming.ProfessionLevelDefinition.Level_2_1st;
        //        }
        //    }
        //    else
        //    {
        //        ratingItem.LevelID = item.LevelID.Value;
        //    }

        //    item.LevelID = ratingItem.LevelID;
        //    models.SubmitChanges();
        //    //工作滿1.5 年上課抽成 + 1 % .

        //}

        public static IQueryable<CourseContract> PromptContractInEditing<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.草稿);

        }

        public static IQueryable<CourseContract> GetContractInEditingByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            if (agent.IsAssistant())
            {
                return models.PromptContractInEditing();
            }
            else
            {
                return models.PromptContractInEditing()
                    .Where(c => c.AgentID == agent.UID || c.FitnessConsultant == agent.UID);
            }
        }

        public static UserProfile LoadInstance<TEntity>(this UserProfile profile, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<UserProfile>().Where(u => u.UID == profile.UID).First();
        }

        public static IQueryable<CourseContract> PromptContract<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var items = models.GetTable<CourseContract>()
                .Where(c => c.CourseContractRevision == null);
            return items;
        }

        public static IQueryable<CourseContract> PromptApplyingContract<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var items = models.PromptContract()
                .Where(c => c.RegisterLessonContract.Count == 0);
            return items;
        }

        public static IQueryable<CourseContract> GetApplyingContractByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            return models.PromptApplyingContract().filterContractByAgent(models,agent);
        }

        public static IQueryable<CourseContractRevision> GetApplyingAmendmentByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status < (int)Naming.CourseContractStatus.已生效);
            items = models.filterAmendmentByAgent(agent, items);
            return items;
        }

        public static IQueryable<CourseContract> FilterByBranchStoreManager<TEntity>(this ModelSource<TEntity> models, IQueryable<CourseContract> items, UserProfile agent)
            where TEntity : class, new()
        {
            return models.FilterByBranchStoreManager(items, agent.UID);
        }

        public static IQueryable<CourseContract> FilterByBranchStoreManager<TEntity>(this ModelSource<TEntity> models, IQueryable<CourseContract> items, int? agentID)
            where TEntity : class, new()
        {
            return items.Join(models.GetTable<CourseContractExtension>()
                    .Join(models.GetTable<BranchStore>()
                            .Where(b => b.ManagerID == agentID || b.ViceManagerID == agentID),
                        p => p.BranchID, b => b.BranchID, (p, b) => p),
                c => c.ContractID, p => p.ContractID, (c, p) => c);
        }

        public static IQueryable<CourseContract> FilterByBranchStoreManager<TEntity>(this IQueryable<CourseContract> items, ModelSource<TEntity> models, int? agentID)
            where TEntity : class, new()
        {
            return models.FilterByBranchStoreManager(items, agentID);
        }

        public static IQueryable<CourseContract> GetContractToAllowByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.待確認);
            if (agent.IsManager() || agent.IsViceManager())
            {
                items = models.FilterByBranchStoreManager(items, agent);
            }
            else if (agent.IsAssistant())
            {

            }
            else
            {
                items = items.Where(c => false);
            }
            return items;
        }

        public static IQueryable<CourseContractRevision> GetAmendmentToAllowByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status == (int)Naming.CourseContractStatus.待確認);
            if (agent.IsManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), agent),
                    r => r.OriginalContract, c => c.ContractID, (r, c) => r);
            }
            else if (agent.IsViceManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), agent),
                                r => r.OriginalContract, c => c.ContractID, (r, c) => r)
                    .Where(r => r.CourseContract.AgentID != agent.UID);
            }
            else if (agent.IsAssistant())
            {

            }
            else
            {
                items = items.Where(c => false);
            }
            return items;
        }

        public static IQueryable<CourseContract> PromptContractToSign<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var items = models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.待簽名);
            return items;
        }

        public static IQueryable<CourseContract> GetContractToSignByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.PromptContractToSign().filterContractByAgent(models, agent);
            return items;
        }

        public static IQueryable<CourseContractRevision> GetAmendmentToSignByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status == (int)Naming.CourseContractStatus.待簽名);
            items = models.filterAmendmentByAgent(agent, items);
            return items;
        }

        private static IQueryable<CourseContract> filterContractByAgent<TEntity>(this IQueryable<CourseContract> items, ModelSource<TEntity> models, UserProfile agent)
                        where TEntity : class, new()
        {
            if (agent.IsManager() || agent.IsViceManager())
            {
                items = models.FilterByBranchStoreManager(items, agent);
            }
            else if (agent.IsAssistant())
            {

            }
            else if (agent.IsCoach())
            {
                items = items.Where(c => c.FitnessConsultant == agent.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return items;
        }

        private static IQueryable<CourseContractRevision> filterAmendmentByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent, IQueryable<CourseContractRevision> items)
                        where TEntity : class, new()
        {
            if (agent.IsManager() || agent.IsViceManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), agent),
                    r => r.OriginalContract, c => c.ContractID, (r, c) => r);
            }
            else if (agent.IsAssistant())
            {

            }
            else if (agent.IsCoach())
            {
                items = items.Where(c => c.CourseContract.FitnessConsultant == agent.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return items;
        }

        public static IQueryable<CourseContract> PromptContractToConfirm<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var items = models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.待審核);

            return items;
        }

        public static IQueryable<CourseContract> GetContractToConfirmByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.PromptContractToConfirm();
            if (agent.IsManager())
            {
                items = models.FilterByBranchStoreManager(items, agent);
            }
            else if (agent.IsViceManager())
            {
                items = models.FilterByBranchStoreManager(items, agent)
                    .Where(c => c.AgentID != agent.UID);
            }
            else if (agent.IsAssistant())
            {

            }
            else
            {
                items = items.Where(c => false);
            }
            return items;
        }

        public static IQueryable<CourseContractRevision> GetAmendmentToConfirmByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile agent)
            where TEntity : class, new()
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status == (int)Naming.CourseContractStatus.待審核);
            if (agent.IsManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), agent),
                    r => r.OriginalContract, c => c.ContractID, (r, c) => r);
            }
            else if (agent.IsViceManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), agent)
                        .Where(c => c.AgentID != agent.UID),
                    r => r.OriginalContract, c => c.ContractID, (r, c) => r);
            }
            else if (agent.IsAssistant())
            {

            }
            else
            {
                items = items.Where(c => false);
            }
            return items;
        }

        public static String CreateContractPDF(this CourseContract item, bool createNew = false)
        {
            String pdfFile = Path.Combine(GlobalDefinition.ContractPdfPath, item.ContractNo + ".pdf");
            if (createNew == true || !File.Exists(pdfFile))
            {
                String viewUrl = Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/CourseContract/ViewContract") + "?pdf=1&contractID=" + item.ContractID;
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }

        public static String CreateContractAmendmentPDF(this CourseContractRevision item, bool createNew = false)
        {
            String pdfFile = Path.Combine(GlobalDefinition.ContractPdfPath, item.CourseContract.ContractNo() + ".pdf");
            if (createNew == true || !File.Exists(pdfFile))
            {
                String viewUrl = Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/CourseContract/ViewContractAmendment") + "?pdf=1&revisionID=" + item.RevisionID;
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }

        public static String CreateInvoicePDF(this InvoiceItem item, bool createNew = false)
        {
            String storePath = Path.Combine(GlobalDefinition.InvoicePdfPath, item.InvoiceDate.Value.Year.ToString());
            if (!Directory.Exists(storePath))
                Directory.CreateDirectory(storePath);
            String pdfFile = Path.Combine(storePath, item.TrackCode + item.No + ".pdf");
            if (createNew == true || !File.Exists(pdfFile))
            {
                String viewUrl = Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/Invoice/PrintInvoice") + "?invoiceID=" + item.InvoiceID;
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }

        public static String CreateQueuedInvoicePDF(this UserProfile item)
        {
            String storePath = Path.Combine(GlobalDefinition.InvoicePdfPath, DateTime.Today.ToString("yyyy-MM-dd"));
            if (!Directory.Exists(storePath))
                Directory.CreateDirectory(storePath);
            String pdfFile = Path.Combine(storePath, item.UID + "-" + DateTime.Now.Ticks + ".pdf");
            if (!File.Exists(pdfFile))
            {
                String viewUrl = Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/Invoice/PrintInvoice") + "?uid=" + item.UID + "&t=" + DateTime.Now.Ticks;
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }

        public static String CreateQueuedAllowancePDF(this UserProfile item)
        {
            String storePath = Path.Combine(GlobalDefinition.InvoicePdfPath, DateTime.Today.ToString("yyyy-MM-dd"));
            if (!Directory.Exists(storePath))
                Directory.CreateDirectory(storePath);
            String pdfFile = Path.Combine(storePath, item.UID + "-Allowance-" + DateTime.Now.Ticks + ".pdf");
            if (!File.Exists(pdfFile))
            {
                String viewUrl = Settings.Default.HostDomain + VirtualPathUtility.ToAbsolute("~/Invoice/PrintAllowance") + "?uid=" + item.UID + "&t=" + DateTime.Now.Ticks;
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }


        public static bool CheckLearnerDiscount<TEntity>(this ModelSource<TEntity> models, IEnumerable<int> uid)
            where TEntity : class, new()
        {
            return models.GetTable<CourseContractMember>().Where(m => uid.Contains(m.UID))
                            .Any(m => m.CourseContract.Status == (int)Naming.CourseContractStatus.已生效);
        }

        public static IQueryable<ServingCoach> GetServingCoachInSameStore<TEntity>(this UserProfile profile, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<ServingCoach>()
                .Join(models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID)
                                            .Join(models.GetTable<CoachWorkplace>(),
                                                b => b.BranchID, w => w.BranchID, (b, w) => w),
                                            s => s.CoachID, w => w.CoachID, (s, w) => s);
        }

        public static IQueryable<PaymentAudit> GetPaymentToAuditByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile profile)
            where TEntity : class, new()
        {
            IQueryable<PaymentAudit> items;
            if (profile.IsAssistant() || profile.IsOfficer())
            {
                items = models.GetTable<PaymentAudit>().Where(p => !p.AuditorID.HasValue);
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                var payment = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID)
                    .SelectMany(b => b.PaymentTransaction)
                    .Select(p => p.Payment);

                items = payment.Select(p => p.PaymentAudit)
                    .Where(a => !a.AuditorID.HasValue);
            }
            else
            {
                items = models.GetTable<PaymentAudit>().Where(f => false);
            }
            return items;
        }

        public static IQueryable<VoidPayment> GetVoidPaymentToApproveByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile profile)
            where TEntity : class, new()
        {
            IQueryable<VoidPayment> items;
            if (profile.IsAssistant() || profile.IsOfficer())
            {
                items = models.GetTable<VoidPayment>().Where(p => p.Status == (int)Naming.CourseContractStatus.待審核);
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                var payment = models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID)
                    .SelectMany(b => b.PaymentTransaction)
                    .Select(p => p.Payment);

                items = payment.Select(p => p.VoidPayment)
                        .Where(p => p.Status == (int)Naming.CourseContractStatus.待審核);
            }
            else
            {
                items = models.GetTable<VoidPayment>().Where(f => false);
            }

            return items;
        }

        public static IQueryable<VoidPayment> GetVoidPaymentToEditByAgent<TEntity>(this ModelSource<TEntity> models, UserProfile profile)
            where TEntity : class, new()
        {
            IQueryable<VoidPayment> items;
            if (profile.IsAssistant() || profile.IsOfficer())
            {
                items = models.GetTable<VoidPayment>().Where(p => p.Status == (int)Naming.CourseContractStatus.草稿);
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                items = models.GetTable<VoidPayment>().Where(p => false);
            }
            else
            {
                items = models.GetTable<VoidPayment>().Where(p => p.Status == (int)Naming.CourseContractStatus.草稿)
                        .Where(p => p.HandlerID == profile.UID);
            }

            return items;
        }

        public static LessonPriceType CurrentTrialLessonPrice<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<LessonPriceType>().Where(p => p.Status == (int)Naming.DocumentLevelDefinition.體驗課程).FirstOrDefault();
        }

        public static LessonPriceType CurrentSessionPrice<TEntity>(this ModelSource<TEntity> models, Naming.LessonPriceStatus sessionStatus = Naming.LessonPriceStatus.自主訓練)
            where TEntity : class, new()
        {
            return models.GetTable<LessonPriceType>().Where(p => p.Status == (int)sessionStatus).FirstOrDefault();
        }

        public static void ExecuteSettlement<TEntity>(this ModelSource<TEntity> models, DateTime startDate, DateTime endExclusiveDate)
            where TEntity : class, new()
        {
            models.GetDataContext().DeleteRedundantTrack();

            var items = models.GetTable<ContractTrustTrack>().Where(t => t.EventDate >= startDate && t.EventDate < endExclusiveDate)
                    .Where(t => !t.SettlementID.HasValue);

            if (items.Count() > 0)
            {
                int? lastSettlementID = models.GetTable<Settlement>().OrderByDescending(s => s.SettlementID)
                    .FirstOrDefault()?.SettlementID;

                Settlement settlement = new Settlement
                {
                    SettlementDate = DateTime.Now,
                    StartDate = startDate,
                    EndExclusiveDate = endExclusiveDate
                };
                models.GetTable<Settlement>().InsertOnSubmit(settlement);
                models.SubmitChanges();

                if (lastSettlementID.HasValue)
                {
                    models.ExecuteCommand(@"INSERT INTO ContractTrustSettlement
                           (ContractID, SettlementID, TotalTrustAmount, InitialTrustAmount, BookingTrustAmount, CurrentLiableAmount)
                            SELECT  ContractID, {0}, TotalTrustAmount, BookingTrustAmount, BookingTrustAmount, 0
                            FROM     ContractTrustSettlement
                            WHERE   (SettlementID = {1}) AND (ContractID NOT IN
                                               (SELECT  ContractID
                                               FROM     ContractTrustTrack
                                               WHERE   (SettlementID = {1}) AND (TrustType IN ('S', 'X'))))",
                        settlement.SettlementID, lastSettlementID);
                }

                models.ExecuteCommand(@"UPDATE CourseContractTrust
                            SET        CurrentSettlement = ContractTrustSettlement.SettlementID
                            FROM     CourseContractTrust INNER JOIN
                                           ContractTrustSettlement ON CourseContractTrust.ContractID = ContractTrustSettlement.ContractID
                            WHERE   (ContractTrustSettlement.SettlementID = {0})",
                   settlement.SettlementID);

                models.ExecuteCommand(@"INSERT INTO CourseContractTrust
                                           (ContractID, CurrentSettlement)
                            SELECT  ContractID, SettlementID
                            FROM     ContractTrustSettlement
                            WHERE   (SettlementID = {0}) AND (ContractID NOT IN
                                               (SELECT  ContractID
                                               FROM     CourseContractTrust))",
                    settlement.SettlementID);

                foreach (var item in items.GroupBy(t => t.ContractID))
                {
                    var contract = models.GetTable<CourseContract>().Where(t => t.ContractID == item.Key).First();
                    ContractTrustSettlement contractTrustSettlement;
                    bool toUpdateTrustSettlement = false;
                    if (contract.CourseContractTrust == null)
                    {
                        contract.CourseContractTrust = new CourseContractTrust
                        {
                            CurrentSettlement = settlement.SettlementID
                        };
                        contractTrustSettlement = new ContractTrustSettlement
                        {
                            ContractID = contract.ContractID,
                            SettlementID = settlement.SettlementID,
                            InitialTrustAmount = 0,
                            TotalTrustAmount = 0,
                            BookingTrustAmount = contract.TotalCost,
                            CurrentLiableAmount = 0
                        };

                        models.GetTable<ContractTrustSettlement>().InsertOnSubmit(contractTrustSettlement);
                    }
                    else
                    {
                        var currentTrustSettlement = contract.CourseContractTrust.ContractTrustSettlement;
                        if (currentTrustSettlement.SettlementID != settlement.SettlementID)
                        {
                            contractTrustSettlement = new ContractTrustSettlement
                            {
                                ContractID = contract.ContractID,
                                SettlementID = settlement.SettlementID,
                                InitialTrustAmount = currentTrustSettlement.BookingTrustAmount.Value,
                                TotalTrustAmount = currentTrustSettlement.TotalTrustAmount,
                                BookingTrustAmount = currentTrustSettlement.BookingTrustAmount,
                                CurrentLiableAmount = 0
                            };

                            models.GetTable<ContractTrustSettlement>().InsertOnSubmit(contractTrustSettlement);
                            toUpdateTrustSettlement = true;
                        }
                        else
                        {
                            contractTrustSettlement = currentTrustSettlement;
                        }
                    }

                    foreach (var trust in item)
                    {
                        trust.SettlementID = settlement.SettlementID;
                        switch (trust.TrustType)
                        {
                            case "B":
                            case "T":
                                contractTrustSettlement.TotalTrustAmount += trust.Payment.PayoffAmount ?? 0;
                                break;

                            case "X":
                            case "S":
                                contractTrustSettlement.TotalTrustAmount -= trust.ReturnAmount ?? 0;
                                contractTrustSettlement.BookingTrustAmount -= trust.ReturnAmount ?? 0;
                                break;

                            case "V":
                                contractTrustSettlement.TotalTrustAmount -= trust.VoidPayment.Payment.PayoffAmount ?? 0;
                                break;

                            case "N":
                                var lesson = trust.LessonTime.RegisterLesson;
                                contractTrustSettlement.TotalTrustAmount -= (lesson.LessonPriceType.ListPrice * lesson.GroupingMemberCount * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100 ?? 0);
                                contractTrustSettlement.BookingTrustAmount -= (lesson.LessonPriceType.ListPrice * lesson.GroupingMemberCount * lesson.GroupingLessonDiscount.PercentageOfDiscount / 100 ?? 0);
                                break;
                        }
                    }

                    contractTrustSettlement.CurrentLiableAmount = contractTrustSettlement.BookingTrustAmount - contractTrustSettlement.TotalTrustAmount;

                    models.SubmitChanges();
                    if (toUpdateTrustSettlement)
                    {
                        models.ExecuteCommand("update CourseContractTrust set CurrentSettlement={0} where ContractID={1}", settlement.SettlementID, contract.ContractID);
                    }
                }

            }
        }

        public static IEnumerable<UserProfile> CheckOverlapedBooking<TEntity>(this ModelSource<TEntity> models, LessonTime timeItem, RegisterLesson lesson, LessonTime source = null)
            where TEntity : class, new()
        {
            int durationHours = (timeItem.ClassTime.Value.Minute + timeItem.DurationInMinutes.Value + 59) / 60;
            IQueryable<LessonTimeExpansion> items;
            if (source == null)
            {
                items = models.GetTable<LessonTimeExpansion>().Where(t => t.ClassDate == timeItem.ClassTime.Value.Date
                    && t.Hour >= timeItem.ClassTime.Value.Hour
                    && t.Hour < (timeItem.ClassTime.Value.Hour + durationHours));
            }
            else
            {
                items = models.GetTable<LessonTimeExpansion>().Where(t => t.ClassDate == timeItem.ClassTime.Value.Date
                    && t.Hour >= timeItem.ClassTime.Value.Hour
                    && t.Hour < (timeItem.ClassTime.Value.Hour + durationHours)
                    && t.LessonID != source.LessonID);
            }

            if (lesson.GroupingMemberCount > 1)
            {
                return items.Select(t => t.RegisterLesson)
                    .Join(models.GetTable<RegisterLesson>().Where(r => r.RegisterGroupID == lesson.RegisterGroupID),
                        t => t.UID, l => l.UID, (t, l) => l)
                    .Select(l => l.UserProfile);
            }
            else
            {
                return items.Select(t => t.RegisterLesson.UserProfile)
                    .Where(u => u.UID == lesson.UID);
            }
        }

        public static void ProcessVacantNo<TEntity>(this ModelSource<TEntity> models, int year, int periodNo)
            where TEntity : class, new()
        {
            var items = models.GetTable<BranchStore>();

            foreach (var item in items)
            {
                models.GetDataContext().ProcessInvoiceNo(item.BranchID, year, periodNo);
            }
        }

        public static IQueryable<LessonTime> LearnerGetUncheckedLessons<TEntity>(this UserProfile profile, ModelSource<TEntity> models,bool includeAfterToday = false)
            where TEntity : class, new()
        {
            return models.GetTable<LessonTime>()
                .Where(l => l.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.在家訓練)
                .Where(l => l.GroupingLesson.RegisterLesson.Any(r => r.UID == profile.UID))
                .GetLearnerUncheckedLessons(includeAfterToday);
        }

        public static IQueryable<LessonTime> GetLearnerUncheckedLessons(this IQueryable<LessonTime> items, bool includeAfterToday = false)
        {
            if (includeAfterToday)
            {
                return items.Where(l => !l.LessonPlan.CommitAttendance.HasValue);
            }
            else
            {
                return items.Where(l => !l.LessonPlan.CommitAttendance.HasValue && l.ClassTime < DateTime.Today.AddDays(1));
            }
        }

        public static void AssignLessonAttendingCoach(this LessonTime item, ServingCoach coach)
        {
            item.AttendingCoach = coach.CoachID;
            if(item.LessonTimeSettlement==null)
            {
                item.LessonTimeSettlement = new LessonTimeSettlement
                {
                };
            }
            item.LessonTimeSettlement.ProfessionalLevelID = coach.LevelID.Value;
            item.LessonTimeSettlement.MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex;
        }

        public static IQueryable<TrainingItemAids> LearnerTrainingAids<TEntity>(this int uid, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<RegisterLesson>().Where(f => f.UID == uid)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l)
                .Join(models.GetTable<TrainingPlan>(), l => l.LessonID, p => p.LessonID, (l, p) => p)
                .Join(models.GetTable<TrainingExecution>(), p => p.ExecutionID, x => x.ExecutionID, (p, x) => x)
                .Join(models.GetTable<TrainingItem>(), x => x.ExecutionID, i => i.ExecutionID, (x, i) => i)
                .Join(models.GetTable<TrainingItemAids>(), x => x.ItemID, s => s.ItemID, (x, s) => s);
        }

    }
}