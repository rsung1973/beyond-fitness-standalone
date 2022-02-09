using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Web;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using CommonLib.Core.Utility;
using CommonLib.DataAccess;
//

namespace WebHome.Helper
{
    public static class BusinessExtensionMethods
    {
        public static void AttendLesson(this GenericManager<BFDataContext> models, LessonTime item,UserProfile actor, Naming.QuestionnaireGroup? groupID = null)
                    
        {
            if (!item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                LessonAttendance attendance = item.LessonAttendance;
                if (attendance == null)
                    attendance = item.LessonAttendance = new LessonAttendance
                    {
                        ActorID = actor.UID,
                    };
                attendance.CompleteDate = DateTime.Now;

                models.SubmitChanges();

                if(item.IsPTSession())
                {
                    foreach (var r in item.GroupingLesson.RegisterLesson)
                    {
                        //if (groupID == Naming.QuestionnaireGroup.身體心靈密碼)
                        //{
                        //    r.UID.CheckCurrentQuestionnaireRequest(models, Naming.QuestionnaireGroup.身體心靈密碼);
                        //}
                        //else
                        //{
                        //    models.CheckLearnerQuestionnaireRequest(r);
                        //}
                        if (models.GetTable<QuestionnaireRequest>()
                            .Where(q => q.UID == r.UID)
                            .Where(q => q.GroupID == (int)Naming.QuestionnaireGroup.身體心靈密碼)
                            .Any())
                        {
                            r.UID.CheckCurrentQuestionnaireRequest(models, actor, Naming.QuestionnaireGroup.滿意度問卷調查_2017);
                        }
                        else
                        {
                            r.UID.CheckCurrentQuestionnaireRequest(models, actor, Naming.QuestionnaireGroup.身體心靈密碼);
                        }
                    }

                }
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

                if (contract.RemainedLessonCount(true) == 0)
                {
                    contract.ValidTo = DateTime.Now;
                    models.SubmitChanges();
                }
            }

        }

        //public static void CheckLearnerQuestionnaireRequest(this GenericManager<BFDataContext> models, RegisterLesson item)
        //    
        //{
        //    if (item.LessonPriceType.ExcludeQuestionnaire.HasValue)
        //        return;

        //    if (item.Lessons <= 10)
        //        return;

        //    int countBase;
        //    //if (item.Lessons <= 10)
        //    //{
        //    //    countBase = item.Lessons;
        //    //}
        //    //else 
        //    if (item.Lessons <= 51)
        //    {
        //        countBase = item.Lessons / 2;
        //    }
        //    else
        //    {
        //        countBase = item.Lessons / 3;
        //    }

        //    int totalAttendance =
        //        models.GetTable<LessonTime>().Where(l => l.GroupID == item.RegisterGroupID && l.LessonAttendance != null).Count()
        //            + (item.AttendedLessons ?? 0);
        //    int checkAttendance = totalAttendance;
        //    bool underCount = true;
        //    if (item.QuestionnaireRequest.Count > 0)
        //    {
        //        var questItem = item.QuestionnaireRequest.OrderByDescending(q => q.QuestionnaireID).First();
        //        checkAttendance = models.GetTable<LessonTime>().Where(l => l.GroupID == item.RegisterGroupID
        //            && l.LessonAttendance != null && l.LessonAttendance.CompleteDate > questItem.RequestDate).Count();
        //        underCount = totalAttendance < countBase * (item.QuestionnaireRequest.Count + 1)
        //            && item.Lessons >= countBase * (item.QuestionnaireRequest.Count + 1);
        //    }

        //    if (((item.Lessons - totalAttendance >= countBase && checkAttendance >= countBase) || (totalAttendance + 1) == item.Lessons) && underCount)
        //    {
        //        CreateQuestionnaire(models, item);
        //    }

        //}

        //public static QuestionnaireRequest CreateQuestionnaire(this GenericManager<BFDataContext> models, RegisterLesson item,Naming.QuestionnaireGroup? groupID = Naming.QuestionnaireGroup.滿意度問卷調查_2017) 
        //{
        //    var group = models.GetTable<QuestionnaireGroup>().Where(g => g.GroupID == (int?)groupID).FirstOrDefault();
        //    if (group != null && !item.QuestionnaireRequest.Any(q => q.PDQTask.Count == 0))
        //    {
        //        var questionnaire = new QuestionnaireRequest
        //        {
        //            GroupID = group.GroupID,
        //            RegisterID = item.RegisterID,
        //            RequestDate = DateTime.Now,
        //            UID = item.UID
        //        };
        //        models.GetTable<QuestionnaireRequest>().InsertOnSubmit(questionnaire);
        //        models.SubmitChanges();

        //        return questionnaire;
        //    }
        //    return null;
        //}

        public static QuestionnaireRequest AssertQuestionnaire(this int learnerID, GenericManager<BFDataContext> models, UserProfile creator, Naming.QuestionnaireGroup groupID = Naming.QuestionnaireGroup.滿意度問卷調查_2017, QuestionnaireRequest.PartIDEnum? partID = null)
            
        {
            lock (typeof(BusinessExtensionMethods))
            {
                var item = models.GetEffectiveQuestionnaireRequest(learnerID, groupID)
                            .FirstOrDefault();

                if (item == null)
                {
                    item = new QuestionnaireRequest
                    {
                        GroupID = (int)groupID,
                        RequestDate = DateTime.Now,
                        UID = learnerID,
                        PartID = (int?)partID,
                        CreatorID = creator.UID,
                    };
                    models.GetTable<QuestionnaireRequest>().InsertOnSubmit(item);
                    models.SubmitChanges();
                }
                return item;
            }
        }

        public static QuestionnaireRequest CheckCurrentQuestionnaireRequest(this int learnerID, GenericManager<BFDataContext> models,UserProfile actor, Naming.QuestionnaireGroup groupID = Naming.QuestionnaireGroup.滿意度問卷調查_2017)
            
        {
            IQueryable<LessonAttendance> attendance = models.GetTable<LessonAttendance>();

            var PT = learnerID.PromptLearnerLessons(models)
                            .PTLesson();

            var PI = learnerID.PromptLearnerLessons(models)
                            .PILesson();

            var item = models.GetTable<QuestionnaireRequest>().Where(q => q.UID == learnerID)
                    .Where(q => q.Status.HasValue)
                    //.Where(q => q.GroupID == (int)groupID)
                    .OrderByDescending(q => q.QuestionnaireID)
                    .FirstOrDefault();

            if (item != null)
            {
                if (item.GroupID == (int)groupID)
                {
                    if (item.Status == (int)Naming.IncommingMessageStatus.未讀)
                    {
                        return item;
                    }
                }

                var pdq = item.PDQTask.OrderByDescending(t => t.TaskID).FirstOrDefault();

                if (pdq != null)
                {
                    PT = PT.Where(l => l.ClassTime >= pdq.TaskDate);
                    PI = PI.Where(l => l.ClassTime >= pdq.TaskDate);
                }
                else
                {
                    PT = PT.Where(l => l.ClassTime >= item.RequestDate);
                    PI = PI.Where(l => l.ClassTime >= item.RequestDate);
                }

            }

            PT = PT.Join(attendance, l => l.LessonID, a => a.LessonID, (l, a) => l);
            PI = PI.Join(attendance, l => l.LessonID, a => a.LessonID, (l, a) => l);

            //if (PT.Count() + PI.Count() >= 12)
            if (PT.Count() >= 15)
            {
                return learnerID.AssertQuestionnaire(models, actor, groupID, QuestionnaireRequest.PartIDEnum.PartB);
            }

            return null;
        }



        public static bool CheckCurrentQuestionnaireRequest(this GenericManager<BFDataContext> models, RegisterLesson item)
            
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

        public static bool CouldMarkToAttendLesson(this GenericManager<BFDataContext> models, LessonTime item)
            
        {
            if (models.IsAttendanceOverdue(item))
                return false;

            return !item.LessonFitnessAssessment.Any(f => !f.LessonFitnessAssessmentReport.Any(r => r.FitnessAssessmentItem.ItemID == 16)
                    || !f.LessonFitnessAssessmentReport.Any(r => r.FitnessAssessmentItem.ItemID == 17)
                    || !f.LessonFitnessAssessmentReport.Any(r => r.FitnessAssessmentItem.GroupID == 3));
        }

        public static bool CheckToAttendLesson(this LessonTime lessonItem, GenericManager<BFDataContext> models)
            
        {

            if (lessonItem.LessonAttendance != null)
            {
                return false;
            }

            if(!(lessonItem.ClassTime < DateTime.Today.AddDays(1)))
            {
                return false;
            }

            if (lessonItem.IsSTSession())
            {
                return false;
            }

            if(lessonItem.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練)
            {
                return false;
            }

            bool result = true;
            if(lessonItem.IsCoachPISession())
            {
                result = !models.GetEffectiveQuestionnaireRequest(lessonItem.RegisterLesson.UserProfile, Naming.QuestionnaireGroup.身體心靈密碼).Any();
            }
            else 
            {
                result = !lessonItem.GetEffectiveQuestionnaireRequest(models, Naming.QuestionnaireGroup.身體心靈密碼).Any();
            }

            return result;
        }


        public static bool IsAttendanceOverdue(this GenericManager<BFDataContext> models, LessonTime item)
            
        {
            var due = models.GetTable<LessonAttendanceDueDate>().OrderByDescending(d => d.DueDate).FirstOrDefault();
            return due != null && item.ClassTime < due.DueDate;
        }

        public static DailyBookingQueryViewModel InitializeBookingQuery(this HttpContext context, string userName, int? branchID, UserProfile item)
        {
            DailyBookingQueryViewModel viewModel = (DailyBookingQueryViewModel)context.GetCacheValue("DailyBookingQuery");
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
                context.SetCacheValue("DailyBookingQuery", viewModel);
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


        public static IQueryable<UserProfile> CheckOverlappingBooking(this GenericManager<BFDataContext> models, LessonTime intendedBooking, LessonTime originalBooking)
                    
        {
            //List<int> checkHour = new List<int>();
            //DateTime startTime = intendedBooking.ClassTime.Value.AddMinutes(-intendedBooking.ClassTime.Value.Minute);
            //DateTime endTime = intendedBooking.ClassTime.Value.AddMinutes(intendedBooking.DurationInMinutes.Value);

            //for (var t = startTime; t < endTime; t = t.AddHours(1))
            //{
            //    checkHour.Add(t.Hour);
            //}

            var oriUID = originalBooking.GroupingLesson.RegisterLesson.Select(r => r.UID).ToArray();

            //var overlappingItems = models.GetTable<LessonTimeExpansion>()
            //                    .Where(t => t.ClassDate == startTime.Date)
            //                    .Where(t => checkHour.Contains(t.Hour))
            //                    .Where(t => t.LessonID != originalBooking.LessonID)
            //                    .Select(t => t.RegisterLesson.UserProfile)
            //                    .Where(u => oriUID.Contains(u.UID));

            var overlappingItems = models.GetTable<LessonTime>().Where(l => l.LessonID != originalBooking.LessonID)
                            .Where(l => !(l.ClassTime >= intendedBooking.ClassTime.Value.AddMinutes(intendedBooking.DurationInMinutes.Value)
                                        || intendedBooking.ClassTime >= l.ClassTime.Value.AddMinutes(l.DurationInMinutes.Value)))
                            .Select(l => l.RegisterLesson.UserProfile)
                            .Where(u => oriUID.Contains(u.UID));

            return overlappingItems;

        }

        public static UserProfile CreateLearner(this GenericManager<BFDataContext> models, LearnerViewModel viewModel)
                    
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
                CreateTime = DateTime.Now,
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

        public static IQueryable<QuestionnaireRequest> GetQuestionnaireRequest(this GenericManager<BFDataContext> models, UserProfile profile, Naming.QuestionnaireGroup groupID = Naming.QuestionnaireGroup.滿意度問卷調查_2017)
            
        {
            return models.GetTable<QuestionnaireRequest>().Where(q => q.UID == profile.UID)
                .Where(q => q.PDQTask.Count == 0)
                .Where(q => q.GroupID == (int)groupID)
                .Where(q => !q.Status.HasValue);
        }

        public static IQueryable<QuestionnaireRequest> GetEffectiveQuestionnaireRequest(this GenericManager<BFDataContext> models, UserProfile profile, Naming.QuestionnaireGroup? groupID = null)
            
        {
            return models.GetEffectiveQuestionnaireRequest(profile.UID, groupID);
        }

        public static IQueryable<QuestionnaireRequest> GetEffectiveQuestionnaireRequest(this GenericManager<BFDataContext> models, int uid, Naming.QuestionnaireGroup? groupID = null)
            
        {
            var items = models.GetTable<QuestionnaireRequest>()
                .Where(q => q.UID == uid)
                .Where(q => !q.Status.HasValue
                    || q.Status == (int)Naming.IncommingMessageStatus.未讀);
            if (groupID.HasValue)
            {
                items = items.Where(q => q.GroupID == (int?)groupID);
            }
            return items;
        }

        public static QuestionnaireRequest GetLastCompleteQuestionnaireRequest(this GenericManager<BFDataContext> models, int uid, Naming.QuestionnaireGroup groupID)
            
        {
            return models.GetTable<QuestionnaireRequest>()
                .Where(q => q.UID == uid)
                .Where(q => q.GroupID == (int)groupID)
                .Where(q => q.Status == (int)Naming.IncommingMessageStatus.已讀)
                .OrderByDescending(q => q.QuestionnaireID)
                .FirstOrDefault();
        }


        public static IQueryable<QuestionnaireRequest> GetEffectiveQuestionnaireRequest(this LessonTime item, GenericManager<BFDataContext> models, Naming.QuestionnaireGroup group)
            
        {
            return models.GetTable<RegisterLesson>().Where(r => r.RegisterGroupID == item.GroupID)
                .Join(models.GetTable<QuestionnaireRequest>(), r => r.UID, q => q.UID, (r, q) => q)
                .Where(q => q.GroupID == (int)group)
                .Where(q => !q.Status.HasValue
                    || q.Status == (int)Naming.IncommingMessageStatus.未讀);
        }


        public static int? BonusPoint(this UserProfile item, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<PDQTaskBonus>()
                .Where(t => t.PDQTask.UID == item.UID)
                .Where(t => !t.BonusExchange.Any())
                .Sum(x => x.PDQTask.PDQQuestion.PDQQuestionExtension.BonusPoint);
        }

        public static int? AwardedPoint(this UserProfile item, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<PDQTaskBonus>()
                .Where(t => t.PDQTask.UID == item.UID)
                .Sum(x => x.PDQTask.PDQQuestion.PDQQuestionExtension.BonusPoint);
        }


        public static IEnumerable<PDQTaskBonus> BonusPointList(this UserProfile item, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<PDQTaskBonus>()
                .Where(t => t.PDQTask.UID == item.UID)
                .Where(t => !t.BonusExchange.Any());
        }

        public static IQueryable<LessonTime> GetLessonAttendance(this GenericManager<BFDataContext> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month, int? branchID)
            
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

        public static IQueryable<LessonTime> GetPISessionAttendance(this GenericManager<BFDataContext> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month, int? branchID)
            
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

        public static int CalcAchievement(this GenericManager<BFDataContext> models, IEnumerable<LessonTime> items)
            
        {
            var lessons = items.FullAchievementLesson()
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

            lessons = items.HalfAchievementLesson()
                .Select(l => l.GroupingLesson)
                        .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r)
                        .Where(r => r.IntuitionCharge != null);

            var halfAchievement = lessons.Where(r => r.IntuitionCharge.Payment == "Cash" || r.IntuitionCharge.FeeShared == 0).Sum(l => l.LessonPriceType.CoachPayoff * l.GroupingLessonDiscount.PercentageOfDiscount / 100) / 2
                + lessons.Where(r => r.IntuitionCharge.Payment == "CreditCard" && r.IntuitionCharge.FeeShared == 1).Sum(l => l.LessonPriceType.CoachPayoffCreditCard * l.GroupingLessonDiscount.PercentageOfDiscount / 100) / 2;

            return (fullAchievement ?? 0) + (halfAchievement ?? 0);
        }

        public static int CalcLearnerContractAchievement(this IQueryable<LessonTime> items, out int count, bool filterData = true)
        {
            var lessonItems = filterData
                ? items.Where(l => l.RegisterLesson.RegisterLessonContract != null)
                : items;
            count = lessonItems.Count();
            return lessonItems.Sum(l => l.RegisterLesson.LessonPriceType.ListPrice * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0;
        }

        public static int CalcLearnerContractAchievement(this IQueryable<V_Tuition> items, out int count, bool filterData = true)
        {
            var lessonItems = filterData
                ? items.Where(l => l.ContractID.HasValue || l.EnterpriseContractID.HasValue)
                : items;
            count = lessonItems.Count();
            return lessonItems.Sum(l => l.ListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0;
        }

        public static int CalcPISessionAchievement(this IQueryable<LessonTime> items, out int count, bool filterData = true)
        {
            var lessonItems = filterData
                ? items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練)
                : items;
            count = lessonItems.Count();
            return lessonItems.Sum(l => l.RegisterLesson.LessonPriceType.ListPrice) ?? 0;
        }


        public static int CalcEnterpriseContractAchievement(this IQueryable<LessonTime> items, out int count, bool filterData = true)
        {
            var lessonItems = filterData
                ? items.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null)
                : items;
            count = lessonItems.Count();
            return lessonItems.Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice) ?? 0;
        }

        public static int CalcEnterprisePISessionAchievement(this IQueryable<LessonTime> items, out int count, bool filterData = true)
        {
            var lessonItems = filterData
                ? items.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練)
                : items;
            count = lessonItems.Count();
            return lessonItems.Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice) ?? 0;
        }

        public static int CalcPTSessionAchievement(this IQueryable<LessonTime> items, out int count)
        {
            int subtotal = items.CalcLearnerContractAchievement(out int contractCount) + items.CalcEnterpriseContractAchievement(out int entpCount);
            count = contractCount + entpCount;
            return subtotal;
        }

        public static int CalcPTSessionAchievement(this IQueryable<V_Tuition> items, out int count)
        {
            int subtotal = items.CalcLearnerContractAchievement(out int contractCount);
            count = contractCount;
            return subtotal;
        }

        public static int CalcLearnerPISessionAchievement(this IQueryable<LessonTime> items, out int count)
        {
            int subtotal = items.CalcPISessionAchievement(out count) + items.CalcEnterprisePISessionAchievement(out int entpCount);
            count += entpCount;
            return subtotal;
        }


        public static int CalcAchievement(this GenericManager<BFDataContext> models, IEnumerable<V_Tuition> items, out int shares)
            
        {
            shares = 0;

            var fullAchievement = items.FullAchievementLesson().CalcTuition(models); 
            var halfAchievement = items.HalfAchievementLesson().CalcTuition(models) / 2;

            shares = items.FullAchievementLesson().CalcTuitionShare(models)
                + items.HalfAchievementLesson().CalcTuitionShare(models) / 2;

            return fullAchievement + halfAchievement;
        }

        //public static int CalcTuition(this IQueryable<LessonTime> items, GenericManager<BFDataContext> models)
        //    
        //{
        //    var allLessons = items
        //        .Select(l => l.GroupingLesson)
        //                .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);

        //    var lessons = allLessons.Where(r => r.RegisterLessonEnterprise == null);
        //    var enterpriseLessons = allLessons.Where(r => r.RegisterLessonEnterprise != null);

        //    var tuition = (lessons
        //        .Sum(l => l.LessonPriceType.ListPrice
        //            * l.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0)
        //        + (enterpriseLessons
        //            .Sum(l => l.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
        //                * l.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0);
        //    return tuition;
        //}

        //public static int CalcTuition(this IEnumerable<LessonTime> items, GenericManager<BFDataContext> models)
        //    
        //{
        //    var allLessons = items
        //        .Select(l => l.GroupingLesson)
        //                .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);

        //    var lessons = allLessons.Where(r => r.RegisterLessonEnterprise == null);
        //    var enterpriseLessons = allLessons.Where(r => r.RegisterLessonEnterprise != null);

        //    var tuition = (lessons
        //        .Sum(l => l.LessonPriceType.ListPrice
        //            * l.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0)
        //        + (enterpriseLessons
        //            .Sum(l => l.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
        //                * l.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0);
        //    return tuition;
        //}

        public static int CalcTuition(this IQueryable<V_Tuition> items, GenericManager<BFDataContext> models)
            
        {

            var lessons = items.Where(r => !r.EnterpriseRegisterID.HasValue);
            var enterpriseLessons = items.Where(r => r.EnterpriseRegisterID.HasValue);

            var tuition = (lessons
                .Sum(l => l.CoachPayoff * l.GroupingMemberCount * l.TuitionIndex
                    * l.PercentageOfDiscount / 100) ?? 0)
                + (enterpriseLessons
                    .Sum(l => l.EnterpriseCoachPayoff * l.TuitionIndex
                        * l.PercentageOfDiscount / 100) ?? 0);
            return (int)tuition;
        }

        public static int CalcTuition(this IEnumerable<V_Tuition> items, GenericManager<BFDataContext> models)
            
        {

            var lessons = items.Where(r => !r.EnterpriseRegisterID.HasValue);
            var enterpriseLessons = items.Where(r => r.EnterpriseRegisterID.HasValue);

            var tuition = (lessons
                .Sum(l => l.CoachPayoff * l.GroupingMemberCount * l.TuitionIndex
                    * l.PercentageOfDiscount / 100) ?? 0)
                + (enterpriseLessons
                    .Sum(l => l.EnterpriseCoachPayoff * l.TuitionIndex
                        * l.PercentageOfDiscount / 100) ?? 0);
            return (int)tuition;
        }

        //public static int CalcTuitionShare(this IEnumerable<LessonTime> items, GenericManager<BFDataContext> models)
        //    
        //{
        //    int shares = 0;

        //    var courseItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise == null);
        //    var enterpriseItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null);

        //    shares = ((int?)courseItems
        //        .Sum(l => l.RegisterLesson.LessonPriceType.ListPrice
        //            * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
        //            * l.LessonTimeSettlement.MarkedGradeIndex / 100) ?? 0)
        //        + ((int?)enterpriseItems
        //        .Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
        //            * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
        //            * l.LessonTimeSettlement.MarkedGradeIndex / 100) ?? 0);

        //    return shares;
        //}

        //public static int CalcTuitionShare(this IQueryable<LessonTime> items, GenericManager<BFDataContext> models)
        //    
        //{
        //    int shares = 0;

        //    var courseItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise == null);
        //    var enterpriseItems = items.Where(l => l.RegisterLesson.RegisterLessonEnterprise != null);

        //    shares = ((int?)courseItems
        //        .Sum(l => l.RegisterLesson.LessonPriceType.ListPrice
        //            * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
        //            * l.LessonTimeSettlement.MarkedGradeIndex / 100) ?? 0)
        //        + ((int?)enterpriseItems
        //        .Sum(l => l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.ListPrice
        //            * l.RegisterLesson.GroupingMemberCount * l.RegisterLesson.GroupingLessonDiscount.PercentageOfDiscount / 100
        //            * l.LessonTimeSettlement.MarkedGradeIndex / 100) ?? 0);

        //    return shares;
        //}

        public static int CalcTuitionShare(this IQueryable<V_Tuition> items, GenericManager<BFDataContext> models)
            
        {
            int shares = 0;

            var courseItems = items.Where(l => !l.EnterpriseRegisterID.HasValue);
            var enterpriseItems = items.Where(l => l.EnterpriseRegisterID.HasValue);

            shares = ((int?)courseItems
                .Sum(l => l.CoachPayoff * l.TuitionIndex
                    * l.GroupingMemberCount * l.PercentageOfDiscount / 100
                    * l.MarkedGradeIndex / 100) ?? 0)
                + ((int?)enterpriseItems
                .Sum(l => l.CoachPayoff * l.TuitionIndex
                    * l.GroupingMemberCount * l.PercentageOfDiscount / 100
                    * l.MarkedGradeIndex / 100) ?? 0);

            return shares;
        }

        public static int CalcTuitionShare(this IEnumerable<V_Tuition> items, GenericManager<BFDataContext> models)
            
        {
            int shares = 0;

            var courseItems = items.Where(l => !l.EnterpriseRegisterID.HasValue);
            var enterpriseItems = items.Where(l => l.EnterpriseRegisterID.HasValue);

            shares = ((int?)courseItems
                .Sum(l => l.CoachPayoff * l.TuitionIndex
                    * l.GroupingMemberCount * l.PercentageOfDiscount / 100
                    * l.MarkedGradeIndex / 100) ?? 0)
                + ((int?)enterpriseItems
                .Sum(l => l.CoachPayoff * l.TuitionIndex
                    * l.GroupingMemberCount * l.PercentageOfDiscount / 100
                    * l.MarkedGradeIndex / 100) ?? 0);

            return shares;
        }



        public static IQueryable<TuitionAchievement> GetTuitionAchievement(this GenericManager<BFDataContext> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month,bool filterByEffective = true)
            
        {
            IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>();

            if (filterByEffective == true)
            {
                items = items.FilterByEffective();
            }

            DateTime? queryDateTo = dateTo;

            if (dateFrom.HasValue)
            {
                items = items.Where(i => i.Payment.PayoffDate >= dateFrom);
            }
            if (queryDateTo.HasValue)
            {
                items = items.Where(i => i.Payment.PayoffDate < queryDateTo.Value.AddDays(1));
            }
            else if (month.HasValue)
            {
                queryDateTo = dateFrom.Value.AddMonths(month.Value);
                items = items.Where(i => i.Payment.PayoffDate < queryDateTo);
                queryDateTo = queryDateTo.Value.AddDays(-1);
                dateTo = queryDateTo;
            }

            if (coachID.HasValue)
            {
                items = items.Where(t => t.CoachID == coachID);
            }

            return items;
        }

        public static IQueryable<TuitionAchievement> GetVoidTuition(this GenericManager<BFDataContext> models, int? coachID, DateTime? dateFrom, ref DateTime? dateTo, int? month)

        {
            IQueryable<TuitionAchievement> items = models.GetTable<TuitionAchievement>();

            IQueryable<VoidPayment> voidItems = models.GetTable<VoidPayment>();

            DateTime? queryDateTo = dateTo;

            if (dateFrom.HasValue)
            {
                voidItems = voidItems.Where(v => v.VoidDate >= dateFrom);
            }

            if (queryDateTo.HasValue)
            {
                voidItems = voidItems.Where(v => v.VoidDate < queryDateTo.Value.AddDays(1));
            }
            else if (month.HasValue)
            {
                queryDateTo = dateFrom.Value.AddMonths(month.Value);
                voidItems = voidItems.Where(v => v.VoidDate < queryDateTo);
                queryDateTo = queryDateTo.Value.AddDays(-1);
                dateTo = queryDateTo;
            }

            if (coachID.HasValue)
            {
                items = items.Where(t => t.CoachID == coachID);
            }

            items = voidItems.Join(models.GetTable<Payment>(), v => v.VoidID, p => p.PaymentID, (v, p) => p)
                    .Join(items, p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

            return items;
        }

        public static void CheckProfessionalLevel2020(this GenericManager<BFDataContext> models, ServingCoach item)
            
        {
            if (!item.LevelID.HasValue || item.ProfessionalLevel.ProfessionalLevelReview == null)
                return;

            DateTime? quarterEnd = new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1);
            DateTime quarterStart = quarterEnd.Value.AddMonths(-3);

            if (models.GetTable<CoachRating>().Any(g => g.CoachID == item.CoachID && g.RatingDate >= quarterEnd))
                return;

            var indicators = models.GetTable<MonthlyIndicator>().Where(i => i.StartDate >= quarterStart && i.StartDate < quarterEnd)
                                .Join(models.GetTable<MonthlyCoachRevenueIndicator>().Where(c => c.CoachID == item.CoachID),
                                    i => i.PeriodID, c => c.PeriodID, (i, c) => c);

            //IQueryable<V_Tuition> items = models.GetTable<V_Tuition>()
            //                                .Where(v => v.AttendingCoach == item.CoachID)
            //                                .Where(v => v.PriceStatus != (int)Naming.LessonPriceStatus.體驗課程)
            //                                .Where(v => v.ELStatus != (int)Naming.LessonPriceStatus.體驗課程)
            //                                .Where(v => v.ClassTime >= quarterStart)
            //                                .Where(v => v.ClassTime < quarterEnd);

            //var attendanceCount = items.Where(v => v.PriceStatus != (int)Naming.LessonPriceStatus.自主訓練 && v.ELStatus != (int)Naming.LessonPriceStatus.自主訓練).Count();
            //var PISessionCount = items.Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練 || v.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();
            //attendanceCount += ((PISessionCount + 1) / 2);

            var attendanceCount = (indicators.Sum(i => i.ActualCompleteLessonCount) ?? 0)
                                + (indicators.Sum(i => i.ActualCompleteTSCount) ?? 0)
                                + (indicators.Sum(i => i.ActualCompletePICount) ?? 0) / 2;

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

            var review = item.ProfessionalLevel.ProfessionalLevelReview;

            if (!qualifiedCert)
            {
                if (review.DemotionID.HasValue)
                {
                    ratingItem.LevelID = review.DemotionID.Value;
                }
            }
            else if (review.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_1)
            {
                if (attendanceCount >= review.PromotionAttendanceCount && summary >= review.PromotionAchievement)
                {
                    ratingItem.LevelID = review.PromotionID.Value;
                }
            }
            else if (review.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_2)
            {
                if (attendanceCount >= review.PromotionAttendanceCount && summary >= review.PromotionAchievement)
                {
                    ratingItem.LevelID = review.PromotionID.Value;
                }
                else if (!(attendanceCount >= review.NormalAttendanceCount && summary >= review.NormalAchievement))
                {
                    ratingItem.LevelID = review.DemotionID.Value;
                }

            }
            else if (review.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_6)
            {
                if (!(attendanceCount >= review.NormalAttendanceCount && summary >= review.NormalAchievement))
                {
                    ratingItem.LevelID = review.DemotionID.Value;
                }
            }
            else if (review.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_5)
            {
                if (attendanceCount >= review.PromotionAttendanceCount && summary >= review.PromotionAchievement)
                {
                    ratingItem.LevelID = review.PromotionID.Value;
                }
                else if (!(attendanceCount >= review.NormalAttendanceCount && summary >= review.NormalAchievement))
                {
                    ratingItem.LevelID = review.DemotionID.Value;
                }
            }
            else if (review.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_4)
            {
                if (attendanceCount >= review.PromotionAttendanceCount && summary >= review.PromotionAchievement)
                {
                    ratingItem.LevelID = review.PromotionID.Value;
                }
                else if (!(attendanceCount >= review.NormalAttendanceCount && summary >= review.NormalAchievement))
                {
                    ratingItem.LevelID = review.DemotionID.Value;
                }
            }
            else if (review.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_3)
            {
                if (attendanceCount >= review.PromotionAttendanceCount && summary >= review.PromotionAchievement)
                {
                    ratingItem.LevelID = review.PromotionID.Value;
                }
                else if (!(attendanceCount >= review.NormalAttendanceCount && summary >= review.NormalAchievement))
                {
                    ratingItem.LevelID = review.DemotionID.Value;
                }
            }
            else
            {
                ratingItem.LevelID = item.LevelID.Value;
            }

            models.SubmitChanges();
            models.ExecuteCommand("update ServingCoach set LevelID={0} where CoachID={1}", ratingItem.LevelID, item.CoachID);
            models.ExecuteCommand(@"
                UPDATE       LessonTimeSettlement
                SET                ProfessionalLevelID = ServingCoach.LevelID, MarkedGradeIndex = ProfessionalLevel.GradeIndex
                FROM            LessonTime INNER JOIN
                                            LessonTimeSettlement ON LessonTime.LessonID = LessonTimeSettlement.LessonID INNER JOIN
                                            ServingCoach ON LessonTime.AttendingCoach = ServingCoach.CoachID INNER JOIN
                                            ProfessionalLevel ON ServingCoach.LevelID = ProfessionalLevel.LevelID
                WHERE        (LessonTime.ClassTime >= {0}) AND (ServingCoach.CoachID = {1}) ", quarterEnd, item.CoachID);

        }


        //public static void CheckProfessionalLevel2020(this GenericManager<BFDataContext> models, ServingCoach item)
        //    
        //{
        //    if (!item.LevelID.HasValue || item.ProfessionalLevel.ProfessionalLevelReview == null)
        //        return;

        //    DateTime? quarterEnd = new DateTime(DateTime.Today.Year, (DateTime.Today.Month - 1) / 3 * 3 + 1, 1);
        //    DateTime quarterStart = quarterEnd.Value.AddMonths(-3);

        //    if (models.GetTable<CoachRating>().Any(g => g.CoachID == item.CoachID && g.RatingDate >= quarterEnd))
        //        return;

        //    var indicators = models.GetTable<MonthlyIndicator>().Where(i => i.StartDate >= quarterStart && i.StartDate < quarterEnd)
        //                        .Join(models.GetTable<MonthlyCoachRevenueIndicator>().Where(c => c.CoachID == item.CoachID),
        //                            i => i.PeriodID, c => c.PeriodID, (i, c) => c);

        //    //IQueryable<V_Tuition> items = models.GetTable<V_Tuition>()
        //    //                                .Where(v => v.AttendingCoach == item.CoachID)
        //    //                                .Where(v => v.PriceStatus != (int)Naming.LessonPriceStatus.體驗課程)
        //    //                                .Where(v => v.ELStatus != (int)Naming.LessonPriceStatus.體驗課程)
        //    //                                .Where(v => v.ClassTime >= quarterStart)
        //    //                                .Where(v => v.ClassTime < quarterEnd);

        //    //var attendanceCount = items.Where(v => v.PriceStatus != (int)Naming.LessonPriceStatus.自主訓練 && v.ELStatus != (int)Naming.LessonPriceStatus.自主訓練).Count();
        //    //var PISessionCount = items.Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練 || v.ELStatus == (int)Naming.LessonPriceStatus.自主訓練).Count();
        //    //attendanceCount += ((PISessionCount + 1) / 2);

        //    var attendanceCount = (indicators.Sum(i => i.ActualCompleteLessonCount) ?? 0)
        //                        + (indicators.Sum(i => i.ActualCompleteTSCount) ?? 0)
        //                        + (indicators.Sum(i => i.ActualCompletePICount) ?? 0) / 2;

        //    var tuition = models.GetTuitionAchievement(item.CoachID, quarterStart, ref quarterEnd, null);
        //    var summary = tuition.Sum(t => t.ShareAmount) ?? 0;
        //    bool qualifiedCert = item.CoachCertificate.Count(c => c.Expiration >= quarterStart) >= 2;

        //    CoachRating ratingItem = new CoachRating
        //    {
        //        AttendanceCount = attendanceCount,
        //        CoachID = item.CoachID,
        //        RatingDate = DateTime.Now,
        //        TuitionSummary = summary,
        //        LevelID = item.LevelID.Value,
        //    };
        //    item.CoachRating.Add(ratingItem);

        //    if (!qualifiedCert)
        //    {
        //        if (item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.HasValue)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
        //        }
        //    }
        //    else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_1)
        //    {
        //        if (attendanceCount >= 168 && summary >= 250000)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
        //        }
        //    }
        //    else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_2)
        //    {
        //        if (attendanceCount >= 188 && summary >= 330000)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
        //        }
        //        else if (!(attendanceCount >= 168 && summary >= 250000))
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
        //        }

        //    }
        //    else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_6)
        //    {
        //        if (attendanceCount < 280 || summary < 450000)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
        //        }
        //    }
        //    else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_5)
        //    {
        //        if (attendanceCount >= 280 && summary >= 510000)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
        //        }
        //        else if (!(attendanceCount >= 248 && summary >= 400000))
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
        //        }
        //    }
        //    else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_4)
        //    {
        //        if (attendanceCount >= 248 && summary >= 450000)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
        //        }
        //        else if (!(attendanceCount >= 218 && summary >= 350000))
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
        //        }
        //    }
        //    else if (item.ProfessionalLevel.ProfessionalLevelReview.CheckLevel == (int)Naming.ProfessionalLevelCheck.PT_3)
        //    {
        //        if (attendanceCount >= 218 && summary >= 390000)
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.PromotionID.Value;
        //        }
        //        else if (!(attendanceCount >= 188 && summary >= 300000))
        //        {
        //            ratingItem.LevelID = item.ProfessionalLevel.ProfessionalLevelReview.DemotionID.Value;
        //        }
        //    }
        //    else
        //    {
        //        ratingItem.LevelID = item.LevelID.Value;
        //    }

        //    models.SubmitChanges();
        //    models.ExecuteCommand("update ServingCoach set LevelID={0} where CoachID={1}", ratingItem.LevelID, item.CoachID);
        //    models.ExecuteCommand(@"
        //        UPDATE       LessonTimeSettlement
        //        SET                ProfessionalLevelID = ServingCoach.LevelID, MarkedGradeIndex = ProfessionalLevel.GradeIndex
        //        FROM            LessonTime INNER JOIN
        //                                    LessonTimeSettlement ON LessonTime.LessonID = LessonTimeSettlement.LessonID INNER JOIN
        //                                    ServingCoach ON LessonTime.AttendingCoach = ServingCoach.CoachID INNER JOIN
        //                                    ProfessionalLevel ON ServingCoach.LevelID = ProfessionalLevel.LevelID
        //        WHERE        (LessonTime.ClassTime >= {0}) AND (ServingCoach.CoachID = {1}) ", quarterEnd, item.CoachID);

        //}


        public static void CheckProfessionalLeve(this GenericManager<BFDataContext> models, ServingCoach item)
            
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

        //public static void CheckProfessionalLeve(this GenericManager<BFDataContext> models, ServingCoach item)
        //    
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

        public static IQueryable<CourseContract> PromptContractInEditing(this GenericManager<BFDataContext> models)
            
        {
            return models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.草稿);

        }

        public static IQueryable<CourseContract> GetContractInEditingByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
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

        public static UserProfile LoadInstance(this UserProfile profile, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<UserProfile>().Where(u => u.UID == profile.UID).First();
        }

        public static IQueryable<CourseContract> PromptContract(this GenericManager<BFDataContext> models)
            
        {
            var items = models.GetTable<CourseContract>()
                .Where(c => c.CourseContractRevision == null);
            return items;
        }

        public static IQueryable<CourseContract> PromptApplyingContract(this GenericManager<BFDataContext> models)
            
        {
            var items = models.PromptContract()
                .Where(c => c.RegisterLessonContract.Count == 0);
            return items;
        }

        public static IQueryable<CourseContract> GetApplyingContractByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
        {
            return models.PromptApplyingContract().filterContractByAgent(models,agent);
        }

        public static IQueryable<CourseContractRevision> GetApplyingAmendmentByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status < (int)Naming.CourseContractStatus.已生效);
            items = models.filterAmendmentByAgent(agent, items);
            return items;
        }

        public static IQueryable<CourseContract> FilterByBranchStoreManager(this GenericManager<BFDataContext> models, IQueryable<CourseContract> items, UserProfile agent)
            
        {
            return models.FilterByBranchStoreManager(items, agent.UID);
        }

        public static IQueryable<CourseContract> FilterByBranchStoreManager(this GenericManager<BFDataContext> models, IQueryable<CourseContract> items, int? agentID)
            
        {
            return items.Join(models.GetTable<CourseContractExtension>()
                    .Join(models.GetTable<BranchStore>()
                            .Where(b => b.ManagerID == agentID || b.ViceManagerID == agentID),
                        p => p.BranchID, b => b.BranchID, (p, b) => p),
                c => c.ContractID, p => p.ContractID, (c, p) => c);
        }

        public static IQueryable<CourseContract> FilterByBranchStoreManager(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models, int? agentID)
            
        {
            return models.FilterByBranchStoreManager(items, agentID);
        }

        public static IQueryable<CourseContract> FilterByLearnerMember(this IQueryable<CourseContract> items,GenericManager<BFDataContext> models,  int? memberID)
            
        {
            return items.Join(models.GetTable<CourseContractMember>().Where(m => m.UID == memberID),
                c => c.ContractID, p => p.ContractID, (c, p) => c);
        }

        public static IQueryable<CourseContract> GetContractToAllowByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
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

        public static IQueryable<CourseContractRevision> GetAmendmentToAllowByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status == (int)Naming.CourseContractStatus.待確認);
            if (agent.IsManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), agent),
                    r => r.RevisionID, c => c.ContractID, (r, c) => r);
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

        public static IQueryable<CourseContract> PromptContractToSign(this GenericManager<BFDataContext> models,bool forInstallmentPlan = false)
            
        {
            var items = models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.待簽名);

            if (forInstallmentPlan)
            {
                items = items.Where(c => !models.GetTable<CourseContract>()
                        .Where(r => r.Status != (int)Naming.CourseContractStatus.待簽名)
                        .Where(n => n.InstallmentID.HasValue)
                        .Where(n => n.InstallmentID == c.InstallmentID)
                        .Any());
            }
            return items;
        }

        public static IQueryable<CourseContract> PromptContractServiceToSign(this GenericManager<BFDataContext> models)
            
        {
            var items = models.GetTable<CourseContract>()
                .Where(c => c.CourseContractRevision != null)
                .Where(c => c.Status == (int)Naming.CourseContractStatus.待簽名);

            return items;
        }


        public static IQueryable<CourseContract> GetContractToSignByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
        {
            var items = models.PromptContractToSign().filterContractByAgent(models, agent);
            return items;
        }

        public static IQueryable<CourseContractRevision> GetAmendmentToSignByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
        {
            var items = models.GetTable<CourseContractRevision>()
                .Where(c => c.CourseContract.Status == (int)Naming.CourseContractStatus.待簽名);
            items = models.filterAmendmentByAgent(agent, items);
            return items;
        }

        private static IQueryable<CourseContract> filterContractByAgent(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models, UserProfile agent)
                        
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

        private static IQueryable<CourseContractRevision> filterAmendmentByAgent(this GenericManager<BFDataContext> models, UserProfile agent, IQueryable<CourseContractRevision> items)
                        
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

        public static IQueryable<CourseContract> PromptContractToConfirm(this GenericManager<BFDataContext> models)
            
        {
            var items = models.PromptContract()
                .Where(c => c.Status == (int)Naming.CourseContractStatus.待審核);

            return items;
        }

        public static IQueryable<CourseContract> GetContractToConfirmByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
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

        public static IQueryable<CourseContractRevision> GetAmendmentToConfirmByAgent(this GenericManager<BFDataContext> models, UserProfile agent)
            
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

        public static Func<CourseContract, string> ContractViewUrl { get; set; } = item => 
            {
                return $"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CourseContract/ViewContract")}?pdf=1&contractID={item.ContractID}";
            };

        public static String CreateContractPDF(this CourseContract item, bool createNew = false)
        {
            String pdfFile = Path.Combine(GlobalDefinition.ContractPdfPath, item.ContractNo + ".pdf");
            if (createNew == true || !File.Exists(pdfFile))
            {
                String viewUrl = ContractViewUrl(item);
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }

        public static Func<CourseContractRevision, string> ContractServiceViewUrl { get; set; } = item =>
        {
            return $"{Startup.Properties["HostDomain"]}{VirtualPathUtility.ToAbsolute("~/CourseContract/ViewContractAmendment")}?pdf=1&revisionID={item.RevisionID}";
        };

        public static String CreateContractAmendmentPDF(this CourseContractRevision item, bool createNew = false)
        {
            String pdfFile = Path.Combine(GlobalDefinition.ContractPdfPath, item.CourseContract.ContractNo() + ".pdf");
            if (createNew == true || !File.Exists(pdfFile))
            {
                String viewUrl = ContractServiceViewUrl(item);
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
                String viewUrl = Startup.Properties["HostDomain"] + VirtualPathUtility.ToAbsolute("~/Invoice/PrintInvoice") + "?invoiceID=" + item.InvoiceID;
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
                String viewUrl = Startup.Properties["HostDomain"] + VirtualPathUtility.ToAbsolute("~/Invoice/PrintInvoice") + "?uid=" + item.UID + "&t=" + DateTime.Now.Ticks;
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
                String viewUrl = Startup.Properties["HostDomain"] + VirtualPathUtility.ToAbsolute("~/Invoice/PrintAllowance") + "?uid=" + item.UID + "&t=" + DateTime.Now.Ticks;
                viewUrl.ConvertHtmlToPDF(pdfFile, 20);
            }
            return pdfFile;
        }


        public static bool CheckLearnerDiscount(this GenericManager<BFDataContext> models, IEnumerable<int> uid)
            
        {
            return models.GetTable<CourseContractMember>().Where(m => uid.Contains(m.UID))
                            .Any(m => m.CourseContract.Status >= (int)Naming.CourseContractStatus.已生效);
        }

        public static IQueryable<ServingCoach> GetServingCoachInSameStore(this UserProfile profile, GenericManager<BFDataContext> models, IQueryable<ServingCoach> items = null)
            
        {
            if (items == null)
                items = models.GetTable<ServingCoach>();
            return items
                .Join(models.GetTable<BranchStore>().Where(b => b.ManagerID == profile.UID || b.ViceManagerID == profile.UID)
                                            .Join(models.GetTable<CoachWorkplace>(),
                                                b => b.BranchID, w => w.BranchID, (b, w) => w),
                                            s => s.CoachID, w => w.CoachID, (s, w) => s);
        }

        public static IQueryable<PaymentAudit> GetPaymentToAuditByAgent(this GenericManager<BFDataContext> models, UserProfile profile)
            
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

        public static IQueryable<VoidPayment> GetVoidPaymentToApproveByAgent(this GenericManager<BFDataContext> models, UserProfile profile)
            
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

        public static IQueryable<VoidPayment> GetVoidPaymentToEditByAgent(this GenericManager<BFDataContext> models, UserProfile profile)
            
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

        public static LessonPriceType CurrentTrialLessonPrice(this GenericManager<BFDataContext> models, bool isVirtual = false,int? priceID = null)
            
        {
            IQueryable<LessonPriceType> items = models.GetTable<LessonPriceType>().Where(p => p.Status == (int)Naming.DocumentLevelDefinition.體驗課程);

            if (priceID.HasValue)
            {
                items = items.Where(p => p.PriceID == priceID);
            }

            if (isVirtual)
            {
                items = items.Where(l => models.GetTable<ObjectiveLessonPrice>()
                                .Any(t => t.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine && t.PriceID == l.PriceID));
            }
            return items.FirstOrDefault();
        }

        public static LessonPriceType CurrentSessionPrice(this GenericManager<BFDataContext> models, Naming.LessonPriceStatus sessionStatus = Naming.LessonPriceStatus.自主訓練,int? priceID = null)
            
        {
            var items = models.GetTable<LessonPriceType>().Where(p => p.Status == (int)sessionStatus);
            if(priceID.HasValue)
            {
                items = items.Where(p => p.PriceID == priceID);
            }
            return items.FirstOrDefault();
        }

        public static void ExecuteSettlement(this GenericManager<BFDataContext> models, DateTime startDate, DateTime endExclusiveDate, DateTime? settlementDate = null)
            
        {
            models.DataContext.DeleteRedundantTrack();

            var items = models.GetTable<ContractTrustTrack>().Where(t => t.EventDate >= startDate && t.EventDate < endExclusiveDate)
                    .Where(t => !t.SettlementID.HasValue);

            if (items.Count() > 0)
            {
                int? lastSettlementID = models.GetTable<Settlement>().OrderByDescending(s => s.SettlementID)
                    .FirstOrDefault()?.SettlementID;

                Settlement settlement = new Settlement
                {
                    SettlementDate = settlementDate ?? DateTime.Now,
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
                    contract.Entrusted = true;
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

        public static IEnumerable<UserProfile> CheckOverlapedBooking(this GenericManager<BFDataContext> models, LessonTime timeItem, RegisterLesson lesson, LessonTime source = null)
            
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

        public static void ProcessVacantNo(this GenericManager<BFDataContext> models, int year, int periodNo)
            
        {
            var items = models.GetTable<BranchStore>();

            foreach (var item in items)
            {
                models.DataContext.ProcessInvoiceNo(item.BranchID, year, periodNo);
            }
        }

        public static IQueryable<LessonTime> LearnerGetUncheckedLessons(this UserProfile profile, GenericManager<BFDataContext> models,bool includeAfterToday = false)
            
        {
            return models.GetTable<LessonTime>()
                .Where(l => l.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.在家訓練)
                .Where(l => l.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.教練PI)
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
            item.LessonTimeSettlement.CoachWorkPlace = coach.WorkBranchID();
        }

        public static IQueryable<TrainingItemAids> LearnerTrainingAids(this int uid, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<RegisterLesson>().Where(f => f.UID == uid)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l)
                .Join(models.GetTable<TrainingPlan>(), l => l.LessonID, p => p.LessonID, (l, p) => p)
                .Join(models.GetTable<TrainingExecution>(), p => p.ExecutionID, x => x.ExecutionID, (p, x) => x)
                .Join(models.GetTable<TrainingItem>(), x => x.ExecutionID, i => i.ExecutionID, (x, i) => i)
                .Join(models.GetTable<TrainingItemAids>(), x => x.ItemID, s => s.ItemID, (x, s) => s);
        }

        public static void ExecuteMonthlySettlement(this GenericManager<BFDataContext> models, DateTime settlementDate)
            
        {
            var calcDate = settlementDate.FirstDayOfMonth();
            models.ExecuteCommand(@"DELETE FROM ContractMonthlySummary
                                    WHERE        (SettlementDate = {0})", calcDate);

            var table = models.GetTable<ContractMonthlySummary>();
            var items = models.GetTable<CourseContract>()
                    .Where(c => c.CourseContractRevision == null)
                    .Where(c => c.EffectiveDate < calcDate)
                    .Where(c => c.Status >= (int)Naming.CourseContractStatus.已生效);

            foreach (var c in items)
            {
                try
                {
                    bool hasItem = false;

                    ContractMonthlySummary item = new ContractMonthlySummary
                    {
                        ContractID = c.ContractID,
                        SettlementDate = calcDate,
                    };

                    var paymentItems = c.ContractPayment.Select(p => p.Payment)
                            .Where(p => p.TransactionType != (int)Naming.PaymentTransactionType.合約終止沖銷)
                            .Where(p => p.PayoffDate < calcDate)
                            .FilterByEffective();

                    if (paymentItems.Count() > 0)
                    {
                        hasItem = true;
                        item.TotalPrepaid = (paymentItems.Sum(p => p.PayoffAmount) ?? 0);
                        //- ((int?)paymentItems.Where(p => p.AllowanceID.HasValue)
                        //    .Select(p => p.InvoiceAllowance).Sum(a => a.TotalAmount + a.TaxAmount) ?? 0);
                    }

                    item.TotalLessonCost = c.TotalAttendedCost(calcDate);
                    if (c.CourseContractType.GroupingLessonDiscount != null)
                    {
                        item.TotalLessonCost = item.TotalLessonCost * c.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * (c.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount ?? 100) / 100;
                    }

                    var allowanceItems = c.ContractPayment.Select(p => p.Payment)
                            //.Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                            //            || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                            //            || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                            .Where(p => p.AllowanceID.HasValue)
                            .Select(p => p.InvoiceAllowance)
                            .Where(p => p.AllowanceDate < calcDate);

                    if (allowanceItems.Count() > 0)
                    {
                        hasItem = true;
                        item.TotalAllowanceAmount = (int)(allowanceItems.Sum(p => p.TotalAmount + p.TaxAmount) ?? 0);
                    }

                    if (hasItem)
                    {
                        item.RemainedAmount = item.TotalPrepaid - item.TotalLessonCost - (item.TotalAllowanceAmount ?? 0);
                        if ((c.Status == (int)Naming.CourseContractStatus.已終止 || c.Status == (int)Naming.CourseContractStatus.已轉讓 || c.Status == (int)Naming.CourseContractStatus.已轉點)
                            && c.ValidTo < calcDate
                            && item.RemainedAmount > 0)
                        {
                            item.RemainedAmount = 0;
                        }
                        table.InsertOnSubmit(item);
                        models.SubmitChanges();
                    }
                }
                catch (Exception ex)
                {
                    ApplicationLogging.LoggerFactory.CreateLogger(typeof(BusinessExtensionMethods))
                        .LogError(ex, ex.Message);

                    //Console.WriteLine($"{c.ContractID}:{c.ContractID} => {ex}");
                }
            }
        }

        public static IQueryable<BranchStore> PromptRealStore(this GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<BranchStore>()
                .Where(b => (b.Status & (int)BranchStore.StatusDefinition.GeographicLocation) == (int)BranchStore.StatusDefinition.GeographicLocation);
        }

        public static IQueryable<BranchStore> PromptAvailableStore(this GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<BranchStore>()
                .Where(b => (b.Status & (int)BranchStore.StatusDefinition.CurrentDisabled) == 0);
        }

        public static IQueryable<BranchStore> PromptVirtualClassOccurrence(this GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<BranchStore>()
                .Join(models.GetTable<ObjectiveLessonLocation>().Where(c => c.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine),
                    b => b.BranchID, c => c.BranchID, (b, c) => b);
        }

        public static bool IsVirtualClassOccurrence(this GenericManager<BFDataContext> models,BranchStore store)
            
        {
            return models.GetTable<ObjectiveLessonLocation>()
                .Where(c => c.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine)
                .Where(b => b.BranchID == store.BranchID)
                .Any();
        }


        //public static void ExecuteMonthlySettlement(this GenericManager<BFDataContext> models, DateTime settlementDate,bool onlyEffective = true)
        //    
        //{
        //    var calcDate = settlementDate.FirstDayOfMonth();
        //    models.ExecuteCommand(@"DELETE FROM ContractMonthlySummary
        //                            WHERE        (SettlementDate = {0})", calcDate);

        //    var table = models.GetTable<ContractMonthlySummary>();
        //    var items = models.GetTable<CourseContract>()
        //            .Where(c => c.CourseContractRevision == null)
        //            .Where(c => c.EffectiveDate < calcDate)
        //            .Where(c => c.Status >= (int)Naming.CourseContractStatus.已生效);

        //    if (onlyEffective)
        //    {
        //        var lastSettlement = table.Where(s => s.SettlementDate < calcDate)
        //                .OrderByDescending(s => s.SettlementDate).FirstOrDefault();

        //        if (lastSettlement != null)
        //        {
        //            items = items.Where(c => !c.ValidTo.HasValue || c.ValidTo >= lastSettlement.SettlementDate);
        //        }
        //    }

        //    foreach(var c in items)
        //    {
        //        try
        //        {

        //            bool hasItem = false;

        //            ContractMonthlySummary item = new ContractMonthlySummary
        //            {
        //                ContractID = c.ContractID,
        //                SettlementDate = calcDate,
        //            };

        //            var paymentItems = c.ContractPayment.Select(p => p.Payment)
        //                    .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
        //                                || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
        //                                || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
        //                    .Where(p => p.PayoffDate < calcDate)
        //                    .Where(p => p.VoidPayment == null || p.AllowanceID.HasValue);

        //            if (paymentItems.Count() > 0)
        //            {
        //                hasItem = true;
        //                item.TotalPrepaid = (paymentItems.Sum(p => p.PayoffAmount) ?? 0);
        //                    //- ((int?)paymentItems.Where(p => p.AllowanceID.HasValue)
        //                    //    .Select(p => p.InvoiceAllowance).Sum(a => a.TotalAmount + a.TaxAmount) ?? 0);
        //            }

        //            var lessons = c.AttendedLessonCount(calcDate);
        //            if (lessons > 0)
        //            {
        //                hasItem = true;
        //                item.TotalLessonCost = lessons * c.LessonPriceType.ListPrice.Value;
        //                if (c.CourseContractType.GroupingLessonDiscount != null)
        //                {
        //                    item.TotalLessonCost = item.TotalLessonCost * c.CourseContractType.GroupingLessonDiscount.GroupingMemberCount * (c.CourseContractType.GroupingLessonDiscount.PercentageOfDiscount ?? 100) / 100;
        //                }
        //            }
        //            else
        //            {
        //                item.TotalLessonCost = 0;
        //            }

        //            var allowanceItems = c.ContractPayment.Select(p => p.Payment)
        //                    .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
        //                                || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
        //                                || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
        //                    .Where(p => p.AllowanceID.HasValue)
        //                    .Select(p => p.InvoiceAllowance)
        //                    .Where(p => p.AllowanceDate < calcDate);

        //            if (allowanceItems.Count() > 0)
        //            {
        //                hasItem = true;
        //                item.TotalAllowanceAmount = (int)(allowanceItems.Sum(p => p.TotalAmount+p.TaxAmount) ?? 0);
        //            }

        //            if (hasItem)
        //            {
        //                item.RemainedAmount = item.TotalPrepaid - item.TotalLessonCost;
        //                if ((c.Status == (int)Naming.CourseContractStatus.已終止 || c.Status == (int)Naming.CourseContractStatus.已轉讓 || c.Status == (int)Naming.CourseContractStatus.已轉點)
        //                    && c.ValidTo < calcDate)
        //                {
        //                    item.RemainedAmount = 0;
        //                }
        //                table.Add(item);
        //                models.SubmitChanges();
        //            }
        //            else
        //            {
        //                var lastItem = table.Where(m => m.ContractID == c.ContractID).OrderByDescending(m => m.SettlementDate).FirstOrDefault();
        //                if (lastItem != null)
        //                {
        //                    item.TotalPrepaid = lastItem.TotalPrepaid;
        //                    item.TotalLessonCost = lastItem.TotalLessonCost;
        //                    item.RemainedAmount = lastItem.RemainedAmount;
        //                    table.Add(item);
        //                    models.SubmitChanges();
        //                }
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            Logger.Error(ex);
        //            //Console.WriteLine($"{c.ContractID}:{c.ContractID} => {ex}");
        //        }
        //    }
        //}


    }
}