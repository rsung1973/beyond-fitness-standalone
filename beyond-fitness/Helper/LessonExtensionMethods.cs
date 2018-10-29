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

    }
}