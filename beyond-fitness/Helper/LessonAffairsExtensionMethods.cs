using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
    public static class LessonAffairsExtensionMethods
    {
        public static void RegisterMonthlyGiftLesson<TEntity>(this ModelSource<TEntity> models,int?[] uid=null)
                    where TEntity : class, new()
        {
            var price = models.GetTable<LessonPriceType>().Where(l => l.IsWelfareGiftLesson != null).FirstOrDefault();
            DateTime startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            DateTime endDate = startDate.AddMonths(1);
            if (price != null)
            {
                var items = models.GetTable<EmployeeWelfare>()
                    .Where(m => m.MonthlyGiftLessons > 0)
                    .Where(y => !y.UserProfile.RegisterLesson.Any(r => r.ClassLevel == price.PriceID
                          && r.RegisterDate >= startDate && r.RegisterDate < endDate));

                if (uid != null && uid.Length > 0)
                {
                    items = items.Where(m => uid.Contains(m.UID));
                }

                if (items.Count() > 0)
                {

                    var table = models.GetTable<RegisterLesson>();

                    foreach (var item in items.ToList())
                    {
                        var lastLesson = table.Where(r => r.UID == item.UID && r.ClassLevel == price.PriceID
                            && r.RegisterDate < startDate && r.Attended != (int)Naming.LessonStatus.課程結束).FirstOrDefault();

                        var lesson = new RegisterLesson
                        {
                            UID = item.UID,
                            RegisterDate = DateTime.Now,
                            GroupingMemberCount = 1,
                            Lessons = item.MonthlyGiftLessons.Value,
                            ClassLevel = price.PriceID,
                            IntuitionCharge = new IntuitionCharge
                            {
                                ByInstallments = 1,
                                Payment = "Cash",
                                FeeShared = 0
                            },
                            Attended = (int)Naming.LessonStatus.準備上課,
                            AdvisorID = Settings.Default.DefaultCoach,
                            AttendedLessons = 0,
                            GroupingLesson = new GroupingLesson { }
                        };
                        table.InsertOnSubmit(lesson);

                        if (lastLesson != null)
                        {
                            lastLesson.Attended = (int)Naming.LessonStatus.課程結束;
                            //lesson.Lessons += (lastLesson.Lessons - lastLesson.GroupingLesson.LessonTime.Count);
                        }

                    }

                    models.SubmitChanges();

                }
            }

        }

        public static readonly int?[] SessionScopeForRemoteFeedback = new int?[]
            {
                        (int)Naming.LessonPriceStatus.一般課程,
                        (int)Naming.LessonPriceStatus.已刪除,
                        (int)Naming.LessonPriceStatus.點數兌換課程,
            };

        public static void RegisterRemoteFeedbackLesson<TEntity>(this ModelSource<TEntity> models)
            where TEntity : class, new()
        {
            var catalog = models.GetTable<ObjectiveLessonCatalog>().Where(c => c.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLineFeedback)
                    .FirstOrDefault();

            var price = catalog?.ObjectiveLessonPrice.FirstOrDefault();

            if (price == null)
            {
                return;
            }

            var items = models.GetTable<LessonTime>()
                .Join(models.PromptVirtualClassOccurrence(),
                    l => l.BranchID, b => b.BranchID, (l, b) => l);

            //var individual = items
            //        .Join(models.GetTable<V_LessonTime>()
            //            .Where(t => SessionScopeForRemoteFeedback.Contains(t.PriceStatus))
            //            .Where(t => t.GroupingMemberCount == 1),
            //        l => l.LessonID, t => t.LessonID, (l, t) => l);

            //var groupLessons = items
            //        .Join(models.GetTable<V_LessonTime>()
            //            .Where(t => SessionScopeForRemoteFeedback.Contains(t.PriceStatus))
            //            .Where(t => t.GroupingMemberCount > 1),
            //        l => l.LessonID, t => t.LessonID, (l, t) => l);

            items = items
                    .Join(models.GetTable<V_LessonTime>()
                        .Where(t => t.CoachAttendance.HasValue)
                        .Where(t => t.CommitAttendance.HasValue)
                        .Where(t => SessionScopeForRemoteFeedback.Contains(t.PriceStatus)),
                    l => l.LessonID, t => t.LessonID, (l, t) => l);

            var calcItems = items.GroupBy(l => l.GroupID);
            var table = models.GetTable<RegisterLesson>();

            foreach (var g in calcItems/*.Where(g => g.Count() > 1)*/)
            {
                var lesson = g.First();
                GroupingLesson groupLesson = null;
                foreach (var item in lesson.GroupingLesson.RegisterLesson)
                {
                    var currentFeedback = table
                        .Where(r => r.ClassLevel == price.PriceID)
                        .Where(r => r.UID == item.UID)
                        .FirstOrDefault();

                    if (currentFeedback == null)
                    {
                        if (groupLesson == null)
                        {
                            groupLesson = new GroupingLesson { };
                        }

                        currentFeedback = new RegisterLesson
                        {
                            UID = item.UID,
                            RegisterDate = DateTime.Now,
                            BranchID = item.BranchID,
                            GroupingMemberCount = item.GroupingMemberCount,
                            ClassLevel = price.PriceID,
                            IntuitionCharge = new IntuitionCharge
                            {
                                ByInstallments = 1,
                                Payment = "Cash",
                                FeeShared = 0
                            },
                            Attended = (int)Naming.LessonStatus.準備上課,
                            AdvisorID = item.AdvisorID,
                            AttendedLessons = 0,
                            GroupingLesson = groupLesson,
                        };

                        table.InsertOnSubmit(currentFeedback);
                    }

                    currentFeedback.Lessons = g.Count();
                    models.SubmitChanges();

                }
            }
        }

    }
}