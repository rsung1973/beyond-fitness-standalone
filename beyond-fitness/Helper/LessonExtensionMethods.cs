using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;

using CommonLib.DataAccess;
using MessagingToolkit.QRCode.Codec;
using Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class LessonExtensionMethods
    {
        public static IQueryable<LessonTime> TotalLessons<TEntity>(this IQueryable<RegisterLesson> items, ModelSource<TEntity> models)
                    where TEntity : class, new()
        {
            return items
                    .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                    .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l);
        }

        public static int TotalLessonMinutes<TEntity>(this UserProfile profile, ModelSource<TEntity> models, DateTime dateFrom, DateTime dateTo)
                    where TEntity : class, new()
        {
            var normalItems = models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID && r.LessonPriceType.Status != (int)Naming.LessonPriceStatus.在家訓練);
            var STSessionItems = models.GetTable<RegisterLesson>().Where(r => r.UID == profile.UID && r.LessonPriceType.Status == (int)Naming.LessonPriceStatus.在家訓練);
            var totalMinutes = (normalItems.TotalLessons(models)
                   .Where(l => l.ClassTime >= dateFrom)
                   .Where(l => l.ClassTime < dateTo)
                   .Where(l => l.LessonPlan.CommitAttendance.HasValue || l.LessonAttendance != null)
                   .Sum(l => l.DurationInMinutes) ?? 0)
                   + (STSessionItems.TotalLessons(models)
                       .Where(l => l.ClassTime >= dateFrom)
                       .Where(l => l.ClassTime < dateTo)
                       .Sum(l => l.DurationInMinutes) ?? 0);
            return totalMinutes;
        }

        public static IEnumerable<CalendarEvent> BuildVipLessonEvents<TEntity>(this UserProfile item, ModelSource<TEntity> models, DateTime start, DateTime end, bool? learner)
            where TEntity : class, new()
        {
            var today = DateTime.Today;

            var dataItems = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= start && t.ClassTime < end.AddDays(1))
                .Where(t => t.RegisterLesson.RegisterLessonEnterprise == null)
                .Where(t => t.RegisterLesson.UID == item.UID
                    || t.GroupingLesson.RegisterLesson.Any(r => r.UID == item.UID)).ToList();

            //var items = dataItems
            //    .Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0)
            //    .Select(g => new _calendarEvent
            //    {
            //        id = "course",
            //        title = "",
            //        start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
            //        description = "P.T session",
            //        lessonID = g.LessonID,
            //        allDay = true,
            //        className = g.ClassTime < today ? new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-blue" },
            //        icon = g.ClassTime < today ? learner == true ? "fa-anchor" : "fa-check" : "fa-clock-o"
            //    });

            var items = dataItems
                .Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0)
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.正常
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.已刪除
                    || t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.點數兌換課程)
                .Where(t => t.RegisterLesson.GroupingMemberCount == 1)
                .Select(g => new CalendarEvent
                {
                    id = "course",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "1 對 1",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-blue" },//g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pinkDark" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  // "fa -user"
                });

            items = items.Concat(dataItems
                .Where(t => !t.TrainingBySelf.HasValue || t.TrainingBySelf == 0)
                .Where(t => t.RegisterLesson.GroupingMemberCount > 1)
                .Select(g => new CalendarEvent
                {
                    id = "course",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "1 對 " + g.RegisterLesson.GroupingMemberCount,
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-blue" },  //g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-pinkDark" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-users"
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI)
                .Select(g => new CalendarEvent
                {
                    id = "coach",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "教練P.I",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-teal" },
                    icon = "fa-university"
                }));


            items = items.Concat(dataItems
                .Where(t => t.TrainingBySelf == 1)
                .Select(g => new CalendarEvent
                {
                    id = "self",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "P.I session",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = /*g.ClassTime < today ? new string[] { "event", "bg-color-yellow" } :*/ g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-red" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-child" // learner == true ? "fa-child" : g.ClassTime < today ? "fa-ckeck" : "fa-clock-o"
                }));

            items = items.Concat(dataItems
                .Where(t => t.TrainingBySelf == 2)
                .Select(g => new CalendarEvent
                {
                    id = "home",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "S.T session",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = /*g.ClassTime < today ? new string[] { "event", "bg-color-yellow" } :*/ g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-yellow" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-child" // learner == true ? "fa-child" : g.ClassTime < today ? "fa-ckeck" : "fa-clock-o"
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
                .Select(g => new CalendarEvent
                {
                    id = "trial",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "體驗課程",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-pink" },  //  g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pink" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-magic"
                }));

            items = items.Concat(BuildVipLessonEventsForEnterprise(item, models, start, end, learner));

            return items;
        }

        private static IEnumerable<CalendarEvent> BuildVipLessonEventsForEnterprise<TEntity>(this UserProfile item, ModelSource<TEntity> models, DateTime start, DateTime end, bool? learner)
            where TEntity : class, new()
        {
            var today = DateTime.Today;

            var dataItems = models.GetTable<LessonTime>()
                .Where(t => t.ClassTime >= start && t.ClassTime < end.AddDays(1))
                .Where(t => t.RegisterLesson.RegisterLessonEnterprise != null)
                .Where(t => t.RegisterLesson.UID == item.UID
                    || t.GroupingLesson.RegisterLesson.Any(r => r.UID == item.UID)).ToList();


            var items = dataItems
                .Where(t => t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.一般課程)
                .Select(g => new CalendarEvent
                {
                    id = "course",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "1 對 1",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-blue" },//g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pinkDark" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  // "fa -user"
                });

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.GroupingMemberCount > 1)
                .Select(g => new CalendarEvent
                {
                    id = "course",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "1 對 " + g.RegisterLesson.GroupingMemberCount,
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-blue" },  //g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-yellow" } : new string[] { "event", "bg-color-pinkDark" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-users"
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練)
                .Select(g => new CalendarEvent
                {
                    id = "self",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "P.I session",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = /*g.ClassTime < today ? new string[] { "event", "bg-color-yellow" } :*/ g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-red" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-child" // learner == true ? "fa-child" : g.ClassTime < today ? "fa-ckeck" : "fa-clock-o"
                }));

            items = items.Concat(dataItems
                .Where(t => t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程)
                .Select(g => new CalendarEvent
                {
                    id = "trial",
                    title = "",
                    start = g.ClassTime.Value.ToString("yyyy-MM-dd"),
                    description = "體驗課程",
                    lessonID = g.LessonID,
                    allDay = true,
                    className = g.LessonAttendance != null && learner == false ? new string[] { "event", "bg-color-grayDark" } : new string[] { "event", "bg-color-pink" },  //  g.ClassTime < today ? g.LessonAttendance == null ? new string[] { "event", "bg-color-red" } : new string[] { "event", "bg-color-blue" } : new string[] { "event", "bg-color-pink" },
                    icon = g.LessonPlan.CommitAttendance.HasValue ? "far fa-check-square" : null  //"fa-magic"
                }));
            return items;
        }

        public static IQueryable<LessonTime> ByLessonQueryType(this IQueryable<LessonTime> items, Naming.LessonQueryType? query)
        {
            switch (query)
            {
                case Naming.LessonQueryType.一般課程:
                    items = items.PTLesson();
                    break;

                case Naming.LessonQueryType.自主訓練:
                    //items = items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練
                    //    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練));
                    items = items.Where(l => l.TrainingBySelf == 1);
                    break;
                case Naming.LessonQueryType.教練PI:
                    items = items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI);
                    break;
                case Naming.LessonQueryType.體驗課程:
                    items = items.TrialLesson();
                    break;

                case Naming.LessonQueryType.在家訓練:
                    items = items.Where(l => l.TrainingBySelf == 2);
                    break;
            }

            return items;
        }

        public static int[] PTScope = new int[] {
                        (int)Naming.LessonPriceStatus.一般課程,
                        //(int)Naming.LessonPriceStatus.企業合作方案,
                        (int)Naming.LessonPriceStatus.已刪除,
                        (int)Naming.LessonPriceStatus.點數兌換課程 };

        public static IQueryable<LessonTime> PTorPILesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => PTScope.Contains(l.RegisterLesson.LessonPriceType.Status.Value)
                    || l.TrainingBySelf == 1
                    || (l.RegisterLesson.RegisterLessonEnterprise != null
                            && (new int?[]
                                {
                                    (int)Naming.EnterpriseLessonTypeDefinition.自主訓練,
                                    (int)Naming.EnterpriseLessonTypeDefinition.體能顧問1對1課程,
                                    (int)Naming.EnterpriseLessonTypeDefinition.體能顧問1對2課程,
                                }).Contains(l.RegisterLesson.RegisterLessonEnterprise.TypeID)));
        }


        public static IQueryable<LessonTime> PTLesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => PTScope.Contains(l.RegisterLesson.LessonPriceType.Status.Value)
                    || (l.RegisterLesson.RegisterLessonEnterprise != null
                            && (new int?[]
                                {
                                    (int)Naming.LessonPriceStatus.一般課程,
                                    (int)Naming.LessonPriceStatus.團體學員課程
                                }).Contains(l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status)));
        }

        public static IEnumerable<LessonTime> PTLesson(this IEnumerable<LessonTime> items)
        {
            return items.Where(l => PTScope.Contains(l.RegisterLesson.LessonPriceType.Status.Value)
                    || (l.RegisterLesson.RegisterLessonEnterprise != null
                            && (new int?[]
                                {
                                    (int)Naming.LessonPriceStatus.一般課程,
                                    (int)Naming.LessonPriceStatus.團體學員課程
                                }).Contains(l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status)));
        }

        public static bool IsPTSession(this LessonTime item)
        {
            return PTScope.Contains(item.RegisterLesson.LessonPriceType.Status.Value)
                    || (item.RegisterLesson.RegisterLessonEnterprise != null
                            && (new int?[]
                                {
                                    (int)Naming.LessonPriceStatus.一般課程,
                                    (int)Naming.LessonPriceStatus.團體學員課程
                                }).Contains(item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status));
        }

        public static IQueryable<LessonTime> PILesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => l.TrainingBySelf == 1);
        }


        public static bool IsPISession(this LessonTime item)
        {
            return item.TrainingBySelf == 1;
        }

        public static bool IsSTSession(this LessonTime item)
        {
            return item.TrainingBySelf == 2;
        }

        public static bool IsTrialLesson(this LessonTime item)
        {
            return item.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程
                                    || (item.RegisterLesson.RegisterLessonEnterprise != null && item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程);
        }

        public static bool IsCoachPISession(this LessonTime item)
        {
            return item.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI;
        }

        public static IQueryable<LessonTime> TrialLesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程
                                    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程));
        }

        public static IEnumerable<LessonTime> TrialLesson(this IEnumerable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程
                                    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程));
        }

        public static IQueryable<LessonTime> AllCompleteLesson(this IQueryable<LessonTime> items)
        {
            return items
                //.Where(t => t.LessonAttendance != null)
                //.Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.自由教練預約)
                .Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.教練PI)
                //.Where(t => t.RegisterLesson.RegisterLessonEnterprise==null 
                //    || t.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.DocumentLevelDefinition.自主訓練)
                //.Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.體驗課程)
                //.Where(t => t.RegisterLesson.LessonPriceType.Status != (int)Naming.DocumentLevelDefinition.點數兌換課程)
                .Where(t => t.LessonAttendance != null || t.LessonPlan.CommitAttendance.HasValue);
        }

        public static TrainingPlan AssertTrainingPlan<TEntity>(this LessonTime item, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var plan = item.TrainingPlan.FirstOrDefault();
            if (plan == null)
            {
                plan = new TrainingPlan
                {
                    TrainingExecution = new TrainingExecution
                    {
                    }
                };

                item.TrainingPlan.Add(plan);
                models.SubmitChanges();
            }

            return plan;

        }

        public static bool CouldBeCancelled(this LessonTime item,UserProfile profile)
        {
            if (item.IsSTSession())
                return true;

            if (!item.ContractTrustTrack.Any(s => s.SettlementID.HasValue))
            {
                if (item.GroupingLesson.RegisterLesson.Any(r => r.RegisterLessonContract != null && r.RegisterLessonContract.CourseContract.RevisionList.Where(v => v.Reason != "展延").Count() > 0))
                {
                    return false;
                }
                if (profile.IsAssistant() || profile.IsAuthorizedSysAdmin())
                    return true;
                if (item.LessonAttendance == null && !item.LessonPlan.CommitAttendance.HasValue && item.ClassTime.Value >= DateTime.Today.AddDays(-3))
                    return true;
            }
            return false;
        }

        public static void RevokeBooking<TEntity>(this LessonTime item, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var registerLesson = item.RegisterLesson;
            if (item.IsCoachPISession() || item.IsTrialLesson())
            {
                if (item.RegisterLesson.MasterRegistration == true)
                {
                    models.ExecuteCommand("delete LessonTime where GroupID={0}", item.GroupID);
                    models.ExecuteCommand("delete RegisterLesson where RegisterGroupID={0}", item.GroupID);
                    models.ExecuteCommand("delete GroupingLesson where GroupID={0}", item.GroupID);
                }
                else
                {
                    models.ExecuteCommand("delete LessonTime where LessonID={0}", item.LessonID);
                    models.ExecuteCommand("delete RegisterLesson where RegisterID={0}", item.RegisterID);
                }
            }
            else
            {
                var contract = registerLesson.RegisterLessonContract?.CourseContract;
                if (contract != null)
                {
                    models.ExecuteCommand(@"UPDATE       CourseContract
                            SET                Status = {0}
                            WHERE     ContractID = {1} and Status = {0}",
                        (int)Naming.CourseContractStatus.已生效, contract.ContractID, (int)Naming.CourseContractStatus.已履行);
                }
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
                    WHERE   (LessonTime.LessonID = {0}) AND (RegisterLesson.Attended = {1})", item.LessonID, (int)Naming.LessonStatus.課程結束, (int)Naming.LessonStatus.上課中);
                }

                models.DeleteAny<LessonTime>(l => l.LessonID == item.LessonID);
                if (registerLesson.UserProfile.LevelID == (int)Naming.MemberStatusDefinition.Anonymous //團體課
                    || registerLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練  /*自主訓練*/
                    || registerLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.教練PI
                    || registerLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.體驗課程)
                {
                    models.DeleteAny<RegisterLesson>(l => l.RegisterID == item.RegisterID);
                }
            }

        }

        public static IQueryable<RegisterLesson> PromptLearnerRegisterLessons<TEntity>(this UserProfile profile, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<RegisterLesson>()
                .Where(r => r.RegisterLessonContract != null)
                .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                    && l.UID == profile.UID)
                .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                .Where(l => l.RegisterGroupID.HasValue);
        }

        public static IQueryable<RegisterLesson> PromptLearnerEnterpriseLessons<TEntity>(this UserProfile profile, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<RegisterLesson>()
                .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                    && (l.UID == profile.UID))
                .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                .Where(l => l.RegisterGroupID.HasValue)
                .Join(models.GetTable<RegisterLessonEnterprise>(), r => r.RegisterID, t => t.RegisterID, (r, t) => r);
        }

        public static IQueryable<QuestionnaireRequest> PromptLessonQuestionnaireRequest<TEntity>(this IQueryable<RegisterLesson> items, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return items
                .Join(models.GetTable<QuestionnaireRequest>(),
                    r => r.RegisterID, q => q.RegisterID, (r, q) => q)
                .Where(q => !q.Status.HasValue && !q.PDQTask.Any());
        }

        public static void ProcessBookingWhenCrossBranch<TEntity>(this LessonTime item, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            if (!models.GetTable<CoachWorkplace>()
                            .Any(c => c.BranchID == item.BranchID
                                && c.CoachID == item.AttendingCoach))
            {
                if (item.PreferredLessonTime == null)
                {
                    item.PreferredLessonTime = new PreferredLessonTime { };
                    models.SubmitChanges();
                }
            }
        }

        public static void AllowBookingWhenCrossBranch<TEntity>(this LessonTime item, ModelSource<TEntity> models,UserProfile approver)
            where TEntity : class, new()
        {
            models.ExecuteCommand(@"
                UPDATE       PreferredLessonTime
                SET                ApprovalDate = {0}, ApproverID = {1}
                WHERE        (LessonID = {2})", DateTime.Now, approver.UID, item.LessonID);
        }

        public static IQueryable<LessonTime> ConcurrentLessons<TEntity>(this LessonTimeExpansion item, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var branchID = item.LessonTime.BranchID;
            return models.GetTable<LessonTimeExpansion>().Where(t => t.ClassDate == item.ClassDate && t.Hour == item.Hour)
                    .Join(models.GetTable<LessonTime>().Where(l => l.BranchID == branchID), t => t.LessonID, i => i.LessonID, (t, i) => i);
        }

        public static IQueryable<RegisterLesson> ConcurrentRegisterLessons<TEntity>(this IQueryable<LessonTime> items, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return items.Join(models.GetTable<GroupingLesson>(), l => l.GroupID, g => g.GroupID, (l, g) => g)
                    .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);
        }

        public static IQueryable<LessonTime> PreferredLessonTimeToApprove<TEntity>(this UserProfile manager, ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            return models.GetTable<LessonTime>()
                    .Where(l => l.LessonAttendance == null)
                    .Join(models.GetTable<BranchStore>().Where(b => b.ManagerID == manager.UID || b.ViceManagerID == manager.UID),
                        l => l.BranchID, b => b.BranchID, (l, b) => l)
                    .Join(models.GetTable<PreferredLessonTime>().Where(p => !p.ApprovalDate.HasValue),
                        l => l.LessonID, p => p.LessonID, (l, p) => l);
        }

    }
}