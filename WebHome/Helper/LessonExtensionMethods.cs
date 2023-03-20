using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Web;
using Microsoft.AspNetCore.Mvc;

using CommonLib.DataAccess;
using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace WebHome.Helper
{
    public static class LessonExtensionMethods
    {
        public static IQueryable<LessonTime> TotalLessons(this IQueryable<RegisterLesson> items, GenericManager<BFDataContext> models)
                    
        {
            return items
                    .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                    .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l);
        }

        public static IQueryable<LessonTime> TotalRegisterLessonItems(this IQueryable<RegisterLesson> items, GenericManager<BFDataContext> models)
                    
        {
            return items
                    .Join(models.GetTable<LessonTime>(), g => g.RegisterID, l => l.RegisterID, (g, l) => l);
        }

        public static int TotalLessonMinutes(this UserProfile profile, GenericManager<BFDataContext> models, DateTime dateFrom, DateTime dateTo)
                    
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

        public static IEnumerable<CalendarEvent> BuildVipLessonEvents(this UserProfile item, GenericManager<BFDataContext> models, DateTime start, DateTime end, bool? learner)
            
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
                .Where(t => PTScope.Contains(t.RegisterLesson.LessonPriceType.Status))
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

        private static IEnumerable<CalendarEvent> BuildVipLessonEventsForEnterprise(this UserProfile item, GenericManager<BFDataContext> models, DateTime start, DateTime end, bool? learner)
            
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

        public static IQueryable<V_Tuition> ByLessonQueryType(this IQueryable<V_Tuition> items, Naming.LessonQueryType? query)
        {
            switch (query)
            {
                case Naming.LessonQueryType.一般課程:
                    items = items.PTLesson();
                    break;

                case Naming.LessonQueryType.自主訓練:
                    //items = items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練
                    //    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練));
                    items = items.PILesson();
                    break;
                case Naming.LessonQueryType.教練PI:
                    items = items.Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.教練PI);
                    break;
                case Naming.LessonQueryType.體驗課程:
                    items = items.TrialLesson();
                    break;

                case Naming.LessonQueryType.在家訓練:
                    items = items.Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.在家訓練);
                    break;
            }

            return items;
        }

        public static int?[] PTScope = new int?[] {
                        (int)Naming.LessonPriceStatus.一般課程,
                        (int)Naming.LessonPriceStatus.團體學員課程,
                        (int)Naming.LessonPriceStatus.已刪除,
                        (int)Naming.LessonPriceStatus.點數兌換課程,
                        (int)Naming.LessonPriceStatus.員工福利課程,
                        (int)Naming.LessonPriceStatus.營養課程,
                        (int)Naming.LessonPriceStatus.運動恢復課程,
                        (int)Naming.LessonPriceStatus.運動防護課程,
        };

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

        public static IQueryable<V_Tuition> PTLesson(this IQueryable<V_Tuition> items)
        {
            return items.Where(l => PTScope.Contains(l.PriceStatus)
                    || (PTScope.Contains(l.ELStatus)));
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

        public static IQueryable<V_Tuition> PILesson(this IQueryable<V_Tuition> items)
        {
            return items.Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                    || l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練);
        }

        public static IQueryable<LessonTime> STLesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => l.TrainingBySelf == 2);
        }


        public static IQueryable<LessonTime> LearnerPILesson(this IQueryable<LessonTime> items)
        {
            return items/*.PILesson()*/
                .Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練
                    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練));
        }

        public static IEnumerable<LessonTime> LearnerPILesson(this IEnumerable<LessonTime> items)
        {
            return items
                .Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.自主訓練
                    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.自主訓練));
        }

        public static IEnumerable<V_Tuition> LearnerPILesson(this IEnumerable<V_Tuition> items)
        {
            return items
                .Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練
                    || (l.ELStatus == (int)Naming.LessonPriceStatus.自主訓練));
        }



        public static IQueryable<LessonTime> ExclusivePILesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.自主訓練)
                    .Where(l => l.RegisterLesson.RegisterLessonEnterprise == null || l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.LessonPriceStatus.自主訓練);
        }

        public static IEnumerable<LessonTime> ExclusivePILesson(this IEnumerable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.自主訓練)
                    .Where(l => l.RegisterLesson.RegisterLessonEnterprise == null || l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.LessonPriceStatus.自主訓練);
        }

        public static IEnumerable<V_Tuition> ExclusivePILesson(this IEnumerable<V_Tuition> items)
        {
            return items.Where(l => l.PriceStatus != (int)Naming.LessonPriceStatus.自主訓練)
                    .Where(l => !l.ELStatus.HasValue || l.ELStatus != (int)Naming.LessonPriceStatus.自主訓練);
        }


        public static bool IsPISession(this LessonTime item)
        {
            return item.TrainingBySelf == 1;
        }

        public static bool IsReceivableSession(this LessonTime item)
        {
            return item.RegisterLesson.IsSingleCharge;
        }

        public static bool IsSTSession(this LessonTime item)
        {
            return item.TrainingBySelf == (int)LessonTime.SelfTrainingDefinition.在家訓練;
        }

        public static Func<LessonTime, bool> CheckTrialLesson = item =>
        {
            return item.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程
                                    || (item.RegisterLesson.RegisterLessonEnterprise != null && item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程);
        };

        public static Func<LessonTime, bool> IsNotTrialLesson = item =>
        {
            return item.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.體驗課程
                                    && (item.RegisterLesson.RegisterLessonEnterprise == null || item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.LessonPriceStatus.體驗課程);
        };

        public static Expression<Func<LessonTime, bool>> QueryTrialLesson = item =>
                    item.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程
                                    || (item.RegisterLesson.RegisterLessonEnterprise != null && item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程);
        

        public static Expression<Func<LessonTime, bool>> QueryNotTrialLesson = item =>
                     item.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.體驗課程
                                    && (item.RegisterLesson.RegisterLessonEnterprise == null || item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status != (int)Naming.LessonPriceStatus.體驗課程);


        public static bool IsTrialLesson(this LessonTime item)
        {
            return CheckTrialLesson(item);
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

        public static IQueryable<V_Tuition> TrialLesson(this IQueryable<V_Tuition> items)
        {
            return items.Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程
                                    || (l.ELStatus == (int)Naming.LessonPriceStatus.體驗課程));
        }

        public static IQueryable<LessonTime> BonusLesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.點數兌換課程);
        }

        public static IQueryable<V_Tuition> BonusLesson(this IQueryable<V_Tuition> items)
        {
            return items.Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程);
        }


        public static IEnumerable<LessonTime> TrialLesson(this IEnumerable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.Status == (int)Naming.LessonPriceStatus.體驗課程
                                    || (l.RegisterLesson.RegisterLessonEnterprise != null && l.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status == (int)Naming.LessonPriceStatus.體驗課程));
        }

        public static IQueryable<LessonTime> WelfareGiftLesson(this IQueryable<LessonTime> items)
        {
            return items.Where(l => l.RegisterLesson.LessonPriceType.IsWelfareGiftLesson != null);
        }

        public static IQueryable<V_Tuition> WelfareGiftLesson(this IQueryable<V_Tuition> items)
        {
            return items.Where(l => l.PriceStatus == (int)Naming.LessonPriceStatus.員工福利課程);
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
                .Where(t => t.LessonAttendance != null /*|| t.LessonPlan.CommitAttendance.HasValue*/);
        }

        public static IQueryable<V_Tuition> FilterByCompleteLesson(this IQueryable<V_Tuition> items)
        {
            //return items.Where(v => v.CoachAttendance.HasValue
            //                            || (!v.CoachAttendance.HasValue
            //                                    && !(v.PriceStatus == (int)Naming.DocumentLevelDefinition.體驗課程
            //                                            || (v.ELStatus == (int)Naming.DocumentLevelDefinition.體驗課程))));
            return items.Where(v => v.CoachAttendance.HasValue
                                        /*|| v.PriceStatus == (int)Naming.DocumentLevelDefinition.體驗課程
                                        || v.ELStatus == (int)Naming.DocumentLevelDefinition.體驗課程*/);

        }

        public static IQueryable<LessonTime> FullAchievementLesson(this IQueryable<LessonTime> items)
        {
            return items.Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue);
        }

        public static IQueryable<LessonTime> HalfAchievementLesson(this IQueryable<LessonTime> items)
        {
            return items
                .Where(t => (t.LessonAttendance == null && t.LessonPlan.CommitAttendance.HasValue)
                        || (t.LessonAttendance != null && !t.LessonPlan.CommitAttendance.HasValue));
        }

        public static IEnumerable<LessonTime> FullAchievementLesson(this IEnumerable<LessonTime> items)
        {
            return items.Where(t => t.LessonAttendance != null && t.LessonPlan.CommitAttendance.HasValue);
        }

        public static IEnumerable<V_Tuition> FullAchievementLesson(this IEnumerable<V_Tuition> items)
        {
            return items.Where(t => t.CoachAttendance.HasValue)
                        .Where(t => t.CommitAttendance.HasValue);
        }


        public static IEnumerable<LessonTime> HalfAchievementLesson(this IEnumerable<LessonTime> items)
        {
            return items
                .Where(t => (t.LessonAttendance == null && t.LessonPlan.CommitAttendance.HasValue)
                        || (t.LessonAttendance != null && !t.LessonPlan.CommitAttendance.HasValue));
        }

        public static IEnumerable<V_Tuition> HalfAchievementLesson(this IEnumerable<V_Tuition> items)
        {
            return items.Where(t => t.CoachAttendance.HasValue)
                        .Where(t => !t.CommitAttendance.HasValue);
        }



        public static TrainingPlan AssertTrainingPlan(this LessonTime item, GenericManager<BFDataContext> models, Naming.DocumentLevelDefinition? planStatus = null,int? UID = null)
            
        {
            if (UID.HasValue)
            {
                return item.AssertLearnerTrainingPlan(models, UID.Value, planStatus);
            }

            var plan = item.TrainingPlan.FirstOrDefault();
            if (plan == null)
            {
                if(item.IsCoachPISession())
                {
                    plan = new TrainingPlan
                    {
                        RegisterID = item.RegisterID,
                        PlanStatus = (int?)planStatus,
                        TrainingExecution = new TrainingExecution
                        {
                        }
                    };

                    item.TrainingPlan.Add(plan);
                }
                else
                {
                    foreach (var lesson in item.GroupingLesson.RegisterLesson)
                    {
                        plan = new TrainingPlan
                        {
                            RegisterID = lesson.RegisterID,
                            PlanStatus = (int?)planStatus,
                            TrainingExecution = new TrainingExecution
                            {
                            }
                        };

                        item.TrainingPlan.Add(plan);
                    }
                }

                models.SubmitChanges();
            }

            return plan;

        }

        public static TrainingPlan AssertLearnerTrainingPlan(this LessonTime item, GenericManager<BFDataContext> models, int UID, Naming.DocumentLevelDefinition? planStatus = null)
            
        {

            var lesson = item.GroupingLesson.RegisterLesson.Where(r => r.UID == UID).First();

            var plan = item.TrainingPlan.Where(p => p.RegisterID == lesson.RegisterID).FirstOrDefault();
            if (plan == null)
            {
                plan = item.TrainingPlan.Where(t => !t.RegisterID.HasValue).FirstOrDefault();
                if (plan != null)
                {
                    plan.RegisterID = lesson.RegisterID;
                    models.SubmitChanges();
                }
            }

            if (plan == null)
            {
                plan = new TrainingPlan
                {
                    RegisterID = lesson.RegisterID,
                    PlanStatus = (int?)planStatus,
                    TrainingExecution = new TrainingExecution
                    {
                    }
                };

                item.TrainingPlan.Add(plan);
                models.SubmitChanges();
            }

            return plan;

        }

        public static PersonalExercisePurposeItem AssertPurposeItem(this UserProfile profile, GenericManager<BFDataContext> models,String purposeItem)
            
        {
            if (profile.PersonalExercisePurpose == null)
            {
                profile.PersonalExercisePurpose = new PersonalExercisePurpose { };
            }

            PersonalExercisePurposeItem item = new PersonalExercisePurposeItem
            {
                PurposeItem = purposeItem,
                InitialDate = DateTime.Now,
            };
            profile.PersonalExercisePurpose.PersonalExercisePurposeItem.Add(item);
            models.SubmitChanges();

            return item;

        }

        public static bool CouldBeCancelled(this LessonTime item,UserProfile profile)
        {
            if (item.IsSTSession())
                return true;

            if (item.IsReceivableSession())
            {
                if (item.RegisterLesson.IsPaid)
                {
                    return false;
                }
            }

            if(item.RegisterLesson.LessonPriceType.ForDietary)
            {
                if (!item.IsTrialLesson())
                {
                    return false;
                }
            }

            if (!item.ContractTrustTrack.Any(s => s.SettlementID.HasValue))
            {
                if (item.GroupingLesson.RegisterLesson.Any(r => r.RegisterLessonContract != null && r.RegisterLessonContract.CourseContract.RevisionList
                    .Where(v => v.Reason != "展延" && v.Reason != "轉換體能顧問" && v.Reason != "轉換課程堂數").Count() > 0))
                {
                    return false;
                }
                if (profile.IsAssistant() || profile.IsAuthorizedSysAdmin())
                {
                    return true;
                }
                if (item.AttendingCoach != profile.UID)
                {
                    return false;
                }
                if (item.LessonAttendance == null && !item.LessonPlan.CommitAttendance.HasValue && item.ClassTime.Value >= DateTime.Today.AddDays(-3))
                    return true;
            }
            return false;
        }

        public static void RevokeBooking(this LessonTime item, GenericManager<BFDataContext> models)
            
        {
            var registerLesson = item.RegisterLesson;
            if (item.IsCoachPISession() 
                || (item.IsTrialLesson() && !(item.BranchStore?.IsVirtualClassroom()==true))
                || registerLesson.IsSingleCharge)
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
                            SET                Status = {0}, ValidTo = null
                            WHERE     ContractID = {1} and Status = {2}",
                        (int)Naming.CourseContractStatus.已生效, contract.ContractID, (int)Naming.CourseContractStatus.已履行);
                }
                if (contract != null && (contract.ContractType == (int)CourseContractType.ContractTypeDefinition.CFA
                        || contract.ContractType == (int)CourseContractType.ContractTypeDefinition.CGF
                        || contract.ContractType == (int)CourseContractType.ContractTypeDefinition.CVF))
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

        public static IQueryable<RegisterLesson> PromptLearnerRegisterLessons(this UserProfile profile, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<RegisterLesson>()
                .Where(r => r.RegisterLessonContract != null)
                .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                    && l.UID == profile.UID)
                .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                .Where(l => l.RegisterGroupID.HasValue);
        }

        public static IQueryable<RegisterLesson> PromptLearnerEnterpriseLessons(this UserProfile profile, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<RegisterLesson>()
                .Where(l => l.Attended != (int)Naming.LessonStatus.課程結束
                    && (l.UID == profile.UID))
                .Where(l => l.Lessons > l.GroupingLesson.LessonTime.Count)
                .Where(l => l.RegisterGroupID.HasValue)
                .Join(models.GetTable<RegisterLessonEnterprise>(), r => r.RegisterID, t => t.RegisterID, (r, t) => r);
        }

        public static IQueryable<QuestionnaireRequest> PromptLessonQuestionnaireRequest(this IQueryable<RegisterLesson> items, GenericManager<BFDataContext> models)
            
        {
            return items
                .Join(models.GetTable<QuestionnaireRequest>(),
                    r => r.RegisterID, q => q.RegisterID, (r, q) => q)
                .Where(q => !q.Status.HasValue && !q.PDQTask.Any());
        }

        public static IQueryable<LessonTime> PromptLearnerLessons(this int learnerID, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<RegisterLesson>().Where(u => u.UID == learnerID)
                .Where(r=>r.LessonPriceType.Status != (int)Naming.LessonPriceStatus.教練PI)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l);
        }

        public static IQueryable<LessonTime> PromptLearnerLessons(this CourseContract item, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<RegisterLesson>()
                .Join(models.GetTable<RegisterLessonContract>().Where(c => c.ContractID == item.ContractID),
                    r => r.RegisterID, c => c.RegisterID, (r, c) => r)
                .Join(models.GetTable<GroupingLesson>(), r => r.RegisterGroupID, g => g.GroupID, (r, g) => g)
                .Join(models.GetTable<LessonTime>(), g => g.GroupID, l => l.GroupID, (g, l) => l);
        }

        public static IQueryable<LessonTime> PromptCoachPILessons(this int learnerID, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<RegisterLesson>().Where(u => u.UID == learnerID)
                .Where(r => r.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI)
                .Join(models.GetTable<LessonTime>(), g => g.RegisterID, l => l.RegisterID, (g, l) => l);
        }

        public static IQueryable<LessonTime> PromptLearnerLessons(this GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<LessonTime>()
                .Where(r => r.RegisterLesson.LessonPriceType.Status != (int)Naming.LessonPriceStatus.教練PI);
        }

        public static IQueryable<LessonTime> PromptCoachPILessons(this GenericManager<BFDataContext> models, IQueryable<LessonTime> items = null)
            
        {
            if (items == null)
            {
                items = models.GetTable<LessonTime>();
            }

            return models.GetTable<RegisterLesson>()
                .Where(r => r.LessonPriceType.Status == (int)Naming.LessonPriceStatus.教練PI)
                .Join(items, g => g.RegisterID, l => l.RegisterID, (g, l) => l);
        }


        public static void ProcessBookingWhenCrossBranch(this LessonTime item, GenericManager<BFDataContext> models)
            
        {
            if (!(item.BranchStore?.IsVirtualClassroom()==true) && !models.GetTable<CoachWorkplace>()
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

        public static void AllowBookingWhenCrossBranch(this LessonTime item, GenericManager<BFDataContext> models,UserProfile approver)
            
        {
            models.ExecuteCommand(@"
                UPDATE       PreferredLessonTime
                SET                ApprovalDate = {0}, ApproverID = {1}
                WHERE        (LessonID = {2})", DateTime.Now, approver.UID, item.LessonID);
        }

        public static IQueryable<LessonTime> ConcurrentLessons(this LessonTimeExpansion item, GenericManager<BFDataContext> models)
            
        {
            var branchID = item.LessonTime.BranchID;
            return models.GetTable<LessonTimeExpansion>().Where(t => t.ClassDate == item.ClassDate && t.Hour == item.Hour)
                    .Join(models.GetTable<LessonTime>().Where(l => l.BranchID == branchID), t => t.LessonID, i => i.LessonID, (t, i) => i);
        }

        public static IQueryable<RegisterLesson> ConcurrentRegisterLessons(this IQueryable<LessonTime> items, GenericManager<BFDataContext> models)
            
        {
            return items.Join(models.GetTable<GroupingLesson>(), l => l.GroupID, g => g.GroupID, (l, g) => g)
                    .Join(models.GetTable<RegisterLesson>(), g => g.GroupID, r => r.RegisterGroupID, (g, r) => r);
        }

        public static IQueryable<LessonTime> PreferredLessonTimeToApprove(this UserProfile manager, GenericManager<BFDataContext> models)
            
        {
            var items = models.GetTable<LessonTime>()
                    //.Where(l => l.LessonAttendance == null)
                    .Join(models.GetTable<PreferredLessonTime>().Where(p => !p.ApprovalDate.HasValue),
                        l => l.LessonID, p => p.LessonID, (l, p) => l);

            if(manager.IsAssistant())
            {

            }
            else
            {
                items = items
                    .Join(models.GetTable<BranchStore>().Where(b => b.ManagerID == manager.UID || b.ViceManagerID == manager.UID),
                        l => l.BranchID, b => b.BranchID, (l, b) => l);
            }
            return items;
        }

        public static TrainingPlan CloneTrainingPlan(this GenericManager<BFDataContext> models, TrainingPlan source, TrainingPlan target = null, bool copyEmphasis = true)

        {
            if (source == target || source == null)
            {
                return null;
            }

            if (target == null)
            {
                target = new TrainingPlan
                {
                    LessonID = source.LessonID,
                    PlanStatus = source.PlanStatus,
                    //RegisterID = source.RegisterID,
                    TrainingExecution = new TrainingExecution
                    {
                    }
                };
                models.GetTable<TrainingPlan>().InsertOnSubmit(target);
            }
            else
            {
                models.ExecuteCommand("delete TrainingExecutionStage where ExecutionID = {0}", target.ExecutionID);
                models.ExecuteCommand("delete TrainingItem where ExecutionID = {0}", target.ExecutionID);
            }

            if (copyEmphasis)
            {
                target.TrainingExecution.Emphasis = source.TrainingExecution.Emphasis;
            }
            target.TrainingExecution.TrainingExecutionStage.AddRange(source.TrainingExecution.TrainingExecutionStage
                .Select(t => new TrainingExecutionStage
                {
                    StageID = t.StageID,
                    TotalMinutes = t.TotalMinutes
                }));

            foreach (var i in source.TrainingExecution.TrainingItem)
            {
                var item = new TrainingItem
                {
                    ActualStrength = i.ActualStrength,
                    ActualTurns = i.ActualTurns,
                    BreakIntervalInSecond = i.BreakIntervalInSecond,
                    Description = i.Description,
                    GoalStrength = i.GoalStrength,
                    GoalTurns = i.GoalTurns,
                    Remark = i.Remark,
                    Repeats = i.Repeats,
                    Sequence = i.Sequence,
                    TrainingID = i.TrainingID,
                    DurationInMinutes = i.DurationInMinutes,
                };

                target.TrainingExecution.TrainingItem.Add(item);
                item.TrainingItemAids.AddRange(i.TrainingItemAids
                    .Select(a => new TrainingItemAids
                    {
                        AidID = a.AidID
                    }));

            }

            models.SubmitChanges();
            return target;

        }

        public static void BookingLessonTimeExpansion(this LessonTime item, GenericManager<BFDataContext> models, DateTime classTime,int duration)
            
        {

            if (item.IsCoachPISession())
            {
                models.ExecuteCommand(@"DELETE FROM LessonTimeExpansion
                    FROM     GroupingLesson INNER JOIN
                                    LessonTime ON GroupingLesson.GroupID = LessonTime.GroupID INNER JOIN
                                    LessonTime AS t ON GroupingLesson.GroupID = t.GroupID INNER JOIN
                                    LessonTimeExpansion ON t.LessonID = LessonTimeExpansion.LessonID
                    WHERE   (LessonTime.LessonID = {0})", item.LessonID);
            }
            else
            {
                models.ExecuteCommand(@"DELETE FROM LessonTimeExpansion
                    WHERE   (LessonID = {0})", item.LessonID);
            }

            DateTime endTime = classTime.AddMinutes(duration);
            DateTime startTime = classTime.AddMinutes(-classTime.Minute);

            int endHour = classTime.Hour + (duration + classTime.Minute - 1) / 60;

            void buildTimeExpansion(LessonTime lessonItem,RegisterLesson lesson)
            {
                for (var s = startTime;s < endTime;s = s.AddHours(1))
                {
                    LessonTimeExpansion newItem = new LessonTimeExpansion
                    {
                        ClassDate = s.Date,
                        Hour = s.Hour,
                        LessonID = lessonItem.LessonID,
                    };

                    models.GetTable<LessonTimeExpansion>().InsertOnSubmit(newItem);
                }
            };

            if(item.IsCoachPISession())
            {
                foreach(var lesson in models.GetTable<LessonTime>().Where(l=>l.GroupID==item.GroupID))
                {
                    buildTimeExpansion(lesson, lesson.RegisterLesson);
                }
            }
            else
            {
                foreach (var lesson in item.GroupingLesson.RegisterLesson)
                {
                    buildTimeExpansion(item, lesson);
                }
            }

            models.SubmitChanges();
        }

        public static void UpdateBookingByCoach(this LessonTimeBookingViewModel viewModel, GenericManager<BFDataContext> models,out String alertMessage)
            
        {
            alertMessage = null;
            if (viewModel.KeyID != null)
            {
                viewModel.LessonID = viewModel.DecryptKeyValue();
            }

            LessonTime item = models.GetTable<LessonTime>().Where(l => l.LessonID == viewModel.LessonID).FirstOrDefault();
            if (item == null)
            {
                alertMessage = "修改上課時間資料不存在!!";
                return ;
            }

            if (!viewModel.ClassTimeStart.HasValue)
            {
                alertMessage = "請選擇上課時間!!";
                return;
            }

            if (item.LessonAttendance != null)
            {
                alertMessage = "已完成上課，不可修改!!";
                return ;
            }

            if (item.ContractTrustTrack.Any(t => t.SettlementID.HasValue))
            {
                alertMessage = "課程資料已信託，不可修改!!";
                return ;
            }

            if (!(item.BranchStore?.IsVirtualClassroom() == true) && !item.IsSTSession() && !models.GetTable<CoachWorkplace>()
                            .Any(c => c.BranchID == item.BranchID
                                && c.CoachID == item.AttendingCoach)
                && viewModel.ClassTimeStart.Value < DateTime.Today.AddDays(1))
            {
                alertMessage = "此時段不允許跨店預約!!";
                return;
            }

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = item.InvitedCoach,
                AttendingCoach = item.AttendingCoach,
                ClassTime = viewModel.ClassTimeStart,
                DurationInMinutes = item.DurationInMinutes
                //DurationInMinutes = (int)(viewModel.ClassTimeEnd.Value - viewModel.ClassTimeStart.Value).TotalMinutes
            };

            if (item.IsCoachPISession())
            {
                timeItem.DurationInMinutes = (int)(viewModel.ClassTimeEnd.Value - viewModel.ClassTimeStart.Value).TotalMinutes;
            }

            if (models.GetTable<Settlement>().Any(s => s.StartDate <= viewModel.ClassTimeStart && s.EndExclusiveDate > viewModel.ClassTimeStart))
            {
                alertMessage = "修改上課時間(" + String.Format("{0:yyyy/MM/dd}", viewModel.ClassTimeStart) + "已結算!!";
                return ;
            }

            var users = models.CheckOverlappingBooking(timeItem, item);
            if (users.Count() > 0)
            {
                alertMessage = "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!";
                return ;
            }

            foreach (var regles in item.RegisterLesson.GroupingLesson.RegisterLesson)
            {
                var contract = regles.RegisterLessonContract?.CourseContract;
                if (contract != null)
                {
                    if (timeItem.ClassTime.Value > contract.Expiration.Value.AddDays(1))
                    {
                        alertMessage = "合約尚未生效或已過期!!";
                        return ;
                    }
                }
                else
                {
                    var entpContract = regles.RegisterLessonEnterprise?.EnterpriseCourseContract;
                    if (entpContract != null)
                    {
                        if (timeItem.ClassTime.Value > entpContract.Expiration.Value.AddDays(1))
                        {
                            alertMessage = "合約尚未生效或已過期!!";
                            return ;
                        }
                    }
                }
            }

            void updateClassTime(LessonTime lessonItem)
            {
                //lessonItem.InvitedCoach = viewModel.CoachID;
                //lessonItem.AttendingCoach = viewModel.CoachID;
                lessonItem.ClassTime = viewModel.ClassTimeStart;
                lessonItem.DurationInMinutes = timeItem.DurationInMinutes;
                if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassTimeStart.Value.Hour))
                    lessonItem.HourOfClassTime = viewModel.ClassTimeStart.Value.Hour;
                //item.BranchID = viewModel.BranchID;
                //item.TrainingBySelf = viewModel.TrainingBySelf;
                foreach (var t in item.ContractTrustTrack)
                {
                    t.EventDate = viewModel.ClassTimeStart.Value;
                }

                models.SubmitChanges();

            };

            if (item.IsCoachPISession())
            {
                foreach (var lesson in models.GetTable<LessonTime>().Where(l => l.GroupID == item.GroupID))
                {
                    updateClassTime(lesson);
                }
            }
            else
            {
                updateClassTime(item);
                if (item.IsPISession()/*item.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自主訓練*/)
                {
                    models.ExecuteCommand("update TuitionInstallment set PayoffDate = {0} where RegisterID = {1} ", item.ClassTime, item.RegisterID);
                }

                if (!item.IsSTSession())
                {
                    models.ExecuteCommand("delete PreferredLessonTime where LessonID = {0}", item.LessonID);
                    item.ProcessBookingWhenCrossBranch(models);
                }
            }

            item.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);

        }

        public static void ValidateCommonBooking(this LessonTimeViewModel viewModel, SampleController<UserProfile> controller, out ServingCoach coach, out BranchStore branch, LessonPriceType priceType = null)
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            if (!viewModel.ClassDate.HasValue)
            {
                ModelState.AddModelError("ClassDate", "請選擇上課日期!!");
            }
            else if (viewModel.ClassDate < DateTime.Today)
            {
                ModelState.AddModelError("ClassDate", "預約時間不可早於今天!!");
            }

            branch = null;
            if (!viewModel.BranchID.HasValue)
            {
                ModelState.AddModelError("BranchID", "請選擇上課地點!!");
            }
            else
            {
                branch = models.GetTable<BranchStore>().Where(b => b.BranchID == viewModel.BranchID).FirstOrDefault();
            }

            coach = models.GetTable<ServingCoach>().Where(s => s.CoachID == viewModel.CoachID).FirstOrDefault();
            if (coach == null)
            {
                ModelState.AddModelError("CoachID", "未指定體能顧問!!");
            }

            viewModel.Place = viewModel.Place.GetEfficientString();
            if (branch?.IsVirtualClassroom() == true)
            {
                if (priceType == null || priceType.IsDistanceLesson)
                {
                    if (!viewModel.Place.ValidateMeetingRoom(branch, models))
                    {
                        ModelState.AddModelError("Place", "請輸入正確會議室連結!!");
                    }
                }
                else
                {
                    ModelState.AddModelError("Message", "該課程不提供遠距上課!!");
                }
            }
        }

        public static LessonTime CommitCourseContractBookingByCoach(this LessonTimeViewModel viewModel, SampleController<UserProfile> controller)
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;

            viewModel.ValidateCommonBooking(controller, out ServingCoach coach, out BranchStore branch);

            if (!ModelState.IsValid)
            {
                return null;
            }

            if (branch?.IsVirtualClassroom() != true && viewModel.TrainingBySelf != LessonTime.SelfTrainingDefinition.在家訓練)
            {
                if (!models.GetTable<CoachWorkplace>()
                                .Any(c => c.BranchID == viewModel.BranchID
                                    && c.CoachID == viewModel.CoachID)
                    && viewModel.ClassDate.Value < DateTime.Today.AddDays(1))
                {
                    ModelState.AddModelError("BranchID", "此時段不允許跨店預約!!");
                }
            }

            if (!ModelState.IsValid)
            {
                return null;
            }

            RegisterLesson lesson;
            LessonPriceType priceType;

            if (viewModel.TrainingBySelf.HasValue)
            {
                if (!viewModel.UID.HasValue)
                {
                    ModelState.AddModelError("userName", "請選擇上課學員!!");
                    return null;
                }

                if (viewModel.SessionStatus.HasValue)
                {
                    priceType = models.CurrentSessionPrice(viewModel.SessionStatus.Value, viewModel.PriceID);
                }
                else
                {
                    priceType = models.CurrentSessionPrice();
                }

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
                    GroupingLesson = new GroupingLesson { },
                };

                //var installment = new TuitionInstallment
                //{
                //    PayoffDate = viewModel.ClassDate,
                //    PayoffAmount = priceType.ListPrice
                //};
                //installment.TuitionAchievement.Add(new TuitionAchievement
                //{
                //    CoachID = lesson.AdvisorID.Value,
                //    ShareAmount = installment.PayoffAmount
                //});

                //lesson.IntuitionCharge.TuitionInstallment.Add(installment);
                models.GetTable<RegisterLesson>().InsertOnSubmit(lesson);
                models.SubmitChanges();
            }
            else
            {
                lesson = models.GetTable<RegisterLesson>().Where(r => r.RegisterID == viewModel.RegisterID).FirstOrDefault();
                if (lesson == null)
                {
                    ModelState.AddModelError("Message", "學員未購買課程!!");
                    return null;
                }
                priceType = lesson.LessonPriceType;

                if (lesson.Attended == (int)Naming.LessonStatus.課程結束)
                {
                    ModelState.AddModelError("Message", "學員課程已結束!!");
                    return null;
                }

                if (lesson.RegisterLessonContract != null)
                {
                    var contract = lesson.RegisterLessonContract.CourseContract;
                    if (contract.Expiration.Value < DateTime.Today)
                    {
                        ModelState.AddModelError("Message", "合約已過期!!");
                        return null;
                    }

                    if (contract.Expiration.Value.AddDays(1) < viewModel.ClassDate.Value)
                    {
                        ModelState.AddModelError("Message", "合約尚未生效或已過期!!");
                        return null;
                    }

                    var lessonCount = lesson.AttendedLessonCount();
                    //var lessonCount = lesson.GroupingLesson.LessonTime.Count;
                    //if (contract.CourseContractType.ContractCode == "CFA"
                    //        || contract.CourseContractType.ContractCode == "CGF"
                    //        || contract.CourseContractType.ContractCode == "CVF")
                    //{
                    //    lessonCount = contract.RegisterLessonContract.Sum(c => c.RegisterLesson.GroupingLesson.LessonTime.Count());
                    //}

                    //if (lessonCount + (lesson.AttendedLessons ?? 0) >= lesson.Lessons)
                    //{
                    //    return View("~/Views/ConsoleHome/Shared/JsAlert.cshtml", model: "學員上課堂數已滿!!");
                    //}

                    if (lessonCount >= lesson.Lessons)
                    {
                        ModelState.AddModelError("Message", "學員上課堂數已滿!!");
                        return null;
                    }

                    if (lesson.ClassLevel == contract.PriceID)
                    {
                        if (contract.TotalCost / contract.Lessons * lessonCount > contract.ContractPayment.Sum(c => c.Payment.PayoffAmount))
                        {
                            ModelState.AddModelError("Message", "學員繳款餘額不足!!");
                            return null;
                        }
                    }
                }
            }

            if (priceType.IsDistanceLesson && branch?.IsVirtualClassroom() != true)
            {
                ModelState.AddModelError("Message", "遠距課程上課地點錯誤!!");
                return null;
            }

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = priceType.DurationInMinutes,
                TrainingBySelf = (int?)viewModel.TrainingBySelf,
                RegisterID = lesson.RegisterID,
                LessonPlan = new LessonPlan
                {

                },
                BranchID = viewModel.BranchID,
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.ProfessionalLevel.GradeIndex,
                    CoachWorkPlace = coach.WorkBranchID(),
                },
                Place = branch?.IsVirtualClassroom() == true ? viewModel.Place : null,
            };
            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Value.Hour;

            if (viewModel.TrainingBySelf.HasValue)
            {
                timeItem.GroupID = lesson.RegisterGroupID;
            }
            else
            {
                var users = models.CheckOverlapedBooking(timeItem, lesson);
                if (users.Any())
                {
                    ModelState.AddModelError("Message", "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!");
                    return null;

                }

                if (lesson.GroupingMemberCount > 1)
                {
                    timeItem.GroupID = lesson.RegisterGroupID;
                    timeItem.LessonFitnessAssessment.AddRange(
                        lesson.GroupingLesson.RegisterLesson.Select(
                            r => new LessonFitnessAssessment
                            {
                                UID = r.UID
                            }));
                }
                else
                {
                    timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
                    {
                        UID = lesson.UID
                    });
                    if (!lesson.RegisterGroupID.HasValue)
                    {
                        timeItem.GroupingLesson = lesson.GroupingLesson = new GroupingLesson { };
                    }
                    else
                    {
                        timeItem.GroupID = lesson.RegisterGroupID;
                    }
                }

                if (lesson.RegisterLessonContract != null)
                {
                    models.GetTable<ContractTrustTrack>().InsertOnSubmit(new ContractTrustTrack
                    {
                        ContractID = lesson.RegisterLessonContract.ContractID,
                        EventDate = timeItem.ClassTime.Value,
                        LessonTime = timeItem,
                        TrustType = Naming.TrustType.N.ToString()
                    });
                }

            }

            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);

            try
            {
                models.SubmitChanges();

                timeItem.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);
                timeItem.ProcessBookingWhenCrossBranch(models);

            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonsController>().LogError(ex, ex.Message);
                ModelState.AddModelError("Message", "預約未完成，請重新預約!!");
                return null;
            }

            if (viewModel.TrainingBySelf.HasValue)
            {

            }
            else
            {
                var bookingItem = models.GetTable<RegisterLessonSharing>()
                        .Where(s => s.RegisterID == timeItem.RegisterID)
                        .Join(models.GetTable<RegisterLessonBooking>()
                                .Where(b => !b.LessonID.HasValue),
                            s => s.ShareID, b => b.RegisterID, (s, b) => b)
                        .OrderBy(b => b.BookingID).FirstOrDefault();

                if (bookingItem != null)
                {
                    var result = models.ExecuteCommand(@"UPDATE RegisterLessonBooking
                            SET        BookingTime = {0}, LessonID = {1}
                            WHERE   (BookingID = {2}) AND (RegisterID = {3})",
                                DateTime.Now, timeItem.LessonID, bookingItem.BookingID, bookingItem.RegisterID);
                    if(result>0)
                    {
                        return timeItem;
                    }
                    else
                    {
                        models.ExecuteCommand("delete LessonTime where LessonID = {0}", timeItem.LessonID);
                        ModelState.AddModelError("Message", "預約未完成，請重新預約!!");

                        return null;
                    }
                }
            }

            return timeItem;
        }

        public static LessonTime CommitSingleCourseBookingByCoach(this LessonTimeViewModel viewModel, SampleController<UserProfile> controller,LessonPriceType priceType)
        {
            var ModelState = controller.ModelState;
            var ViewBag = controller.ViewBag;
            var HttpContext = controller.HttpContext;
            var models = controller.DataSource;

            ViewBag.ViewModel = viewModel;

            viewModel.ValidateCommonBooking(controller, out ServingCoach coach, out BranchStore branch, priceType);

            if (!ModelState.IsValid)
            {
                return null;
            }

            if (branch?.IsVirtualClassroom() != true)
            {
                if (!models.GetTable<CoachWorkplace>()
                                .Any(c => c.BranchID == viewModel.BranchID
                                    && c.CoachID == viewModel.CoachID)
                    && viewModel.ClassDate.Value < DateTime.Today.AddDays(1))
                {
                    ModelState.AddModelError("BranchID", "此時段不允許跨店預約!!");
                }
            }

            if (!ModelState.IsValid)
            {
                return null;
            }

            if (priceType.IsDistanceLesson && branch?.IsVirtualClassroom() != true)
            {
                ModelState.AddModelError("Message", "遠距課程上課地點錯誤!!");
                return null;
            }

            RegisterLesson lesson;
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
                MasterRegistration = true,
                GroupingLesson = new GroupingLesson { }
            };

            models.GetTable<RegisterLesson>().InsertOnSubmit(lesson);

            LessonTime timeItem = new LessonTime
            {
                InvitedCoach = viewModel.CoachID,
                AttendingCoach = viewModel.CoachID,
                //ClassTime = viewModel.ClassDate.Add(viewModel.ClassTime),
                ClassTime = viewModel.ClassDate,
                DurationInMinutes = priceType.DurationInMinutes,
                TrainingBySelf = (int?)viewModel.TrainingBySelf,
                RegisterLesson = lesson,
                LessonPlan = new LessonPlan
                {

                },
                BranchID = viewModel.BranchID,
                LessonTimeSettlement = new LessonTimeSettlement
                {
                    ProfessionalLevelID = coach.LevelID.Value,
                    MarkedGradeIndex = coach.LevelID.HasValue ? coach.ProfessionalLevel.GradeIndex : null,
                    CoachWorkPlace = coach.WorkBranchID(),
                }
            };

            if (models.GetTable<DailyWorkingHour>().Any(d => d.Hour == viewModel.ClassDate.Value.Hour))
                timeItem.HourOfClassTime = viewModel.ClassDate.Value.Hour;

            timeItem.GroupingLesson = lesson.GroupingLesson;
            timeItem.LessonFitnessAssessment.Add(new LessonFitnessAssessment
            {
                UID = lesson.UID
            });

            var users = models.CheckOverlapedBooking(timeItem, lesson);
            if (users.Any())
            {
                ModelState.AddModelError("Message", "學員(" + String.Join("、", users.Select(u => u.RealName)) + ")上課時間重複!!");
                return null;
            }

            models.GetTable<LessonTime>().InsertOnSubmit(timeItem);

            try
            {
                models.SubmitChanges();

                timeItem.BookingLessonTimeExpansion(models, timeItem.ClassTime.Value, timeItem.DurationInMinutes.Value);
                timeItem.ProcessBookingWhenCrossBranch(models);
            }
            catch (Exception ex)
            {
                ApplicationLogging.CreateLogger<LessonsController>().LogError(ex, ex.Message);
                ModelState.AddModelError("Message", "預約未完成，請重新預約!!");
                return null;
            }

            return timeItem;
        }

    }
}