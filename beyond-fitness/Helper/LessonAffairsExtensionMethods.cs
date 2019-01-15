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
        public static void RegisterMonthlyGiftLesson<TEntity>(this ModelSource<TEntity> models)
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
                            lesson.Lessons += (lastLesson.Lessons - lastLesson.GroupingLesson.LessonTime.Count);
                        }

                    }

                    models.SubmitChanges();

                }
            }

        }
    }
}