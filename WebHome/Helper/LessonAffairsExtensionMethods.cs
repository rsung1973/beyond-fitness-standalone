using CommonLib.DataAccess;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;
using Microsoft.Extensions.Configuration;

namespace WebHome.Helper
{
    public static class LessonAffairsExtensionMethods
    {
        public static void RegisterMonthlyGiftLesson(this GenericManager<BFDataContext> models,int?[] uid=null)
                    
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
                            AdvisorID = Startup.Properties.GetValue<int?>("DefaultCoach"),
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

        public static void RegisterRemoteFeedbackLesson(this GenericManager<BFDataContext> models, IQueryable<LessonTime> items = null)
            
        {
            var catalog = models.GetTable<ObjectiveLessonCatalog>().Where(c => c.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLineFeedback)
                    .FirstOrDefault();

            var price = catalog?.ObjectiveLessonPrice.FirstOrDefault();

            if (price == null)
            {
                return;
            }

            var exceptive = models.GetTable<UserRole>().Where(r => r.RoleID == (int)Naming.RoleID.HealthCare);
            var exceptivePrice = models.GetTable<ObjectiveLessonPrice>()
                    .Where(b => b.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLineFeedback
                        || b.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine)
                    .Select(b => b.PriceID)
                    .ToArray();

            if (items == null)
            {
                items = models.GetTable<LessonTime>();
            }

            items = items
                .Where(l => !exceptive.Any(x => x.UID == l.AttendingCoach))
                .Join(models.PromptVirtualClassOccurrence(),
                    l => l.BranchID, b => b.BranchID, (l, b) => l);

            DateTime startDate = new DateTime(2021, 8, 9);

            items = items
                    .Join(models.GetTable<V_LessonTime>()
                        .Where(t => t.ClassTime >= startDate)
                        .Where(t => t.CoachAttendance.HasValue)
                        .Where(t => t.CommitAttendance.HasValue)
                        .Where(t => !exceptivePrice.Contains(t.PriceID))
                        .Where(t => SessionScopeForRemoteFeedback.Contains(t.PriceStatus)),
                    l => l.LessonID, t => t.LessonID, (l, t) => l);

            var calcItems = items.GroupBy(l => l.GroupID);
            var table = models.GetTable<RegisterLesson>();

            var groupingCount = calcItems.Select(g => new
                {
                    g.First().GroupingLesson,
                    UID = g.First().GroupingLesson.RegisterLesson.Select(r => r.UID).OrderBy(u => u).ToArray(),
                    TotalCount = g.Count()
                })
                .ToList()
                .GroupBy(g => g.UID.JsonStringify())
                .Select(g => new
                {
                    g.First().GroupingLesson,
                    UID = g.Key,
                    TotalCount = g.Sum(v => v.TotalCount),
                });

            foreach (var g in groupingCount)
            {
                var lesson = g.GroupingLesson;
                var item = lesson.RegisterLesson.First();
                GroupingLesson groupLesson = null;
                foreach (var uid in JsonConvert.DeserializeObject<int[]>(g.UID))
                {
                    var currentFeedback = table
                        .Where(r => r.RegisterDate >= startDate)
                        .Where(r => r.ClassLevel == price.PriceID)
                        .Where(r => r.UID == uid)
                        .FirstOrDefault();

                    if (currentFeedback == null)
                    {
                        if (groupLesson == null)
                        {
                            groupLesson = new GroupingLesson { };
                        }

                        currentFeedback = new RegisterLesson
                        {
                            UID = uid,
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

                    int availableCount = g.TotalCount / 2;
                    if (currentFeedback.Lessons < availableCount)
                    {
                        currentFeedback.Lessons = availableCount;
                        currentFeedback.Attended = (int)Naming.LessonStatus.準備上課;
                    }

                    models.SubmitChanges();

                }
            }
        }

        //public static void RegisterRemoteFeedbackLesson(this GenericManager<BFDataContext> models,IQueryable<LessonTime> items = null)
        //    
        //{
        //    var catalog = models.GetTable<ObjectiveLessonCatalog>().Where(c => c.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLineFeedback)
        //            .FirstOrDefault();

        //    var price = catalog?.ObjectiveLessonPrice.FirstOrDefault();

        //    if (price == null)
        //    {
        //        return;
        //    }

        //    var exceptive = models.GetTable<UserRole>().Where(r => r.RoleID == (int)Naming.RoleID.Dietitian);
        //    var exceptivePrice = models.GetTable<ObjectiveLessonPrice>()
        //            .Where(b => b.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLineFeedback
        //                || b.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine)
        //            .Select(b => b.PriceID)
        //            .ToArray();

        //    if (items == null)
        //    {
        //        items = models.GetTable<LessonTime>();
        //    }

        //    items = items
        //        .Where(l => !exceptive.Any(x => x.UID == l.AttendingCoach))
        //        .Join(models.PromptVirtualClassOccurrence(),
        //            l => l.BranchID, b => b.BranchID, (l, b) => l);

        //    items = items
        //            .Join(models.GetTable<V_LessonTime>()
        //                .Where(t => t.CoachAttendance.HasValue)
        //                .Where(t => t.CommitAttendance.HasValue)
        //                .Where(t => !exceptivePrice.Contains(t.PriceID))
        //                .Where(t => SessionScopeForRemoteFeedback.Contains(t.PriceStatus)),
        //            l => l.LessonID, t => t.LessonID, (l, t) => l);

        //    var calcItems = items.GroupBy(l => l.GroupID);
        //    var table = models.GetTable<RegisterLesson>();

        //    var groupingCount = calcItems.Select(g => new
        //    {
        //        g.First().GroupingLesson,
        //        UID = g.First().GroupingLesson.RegisterLesson.Select(r => r.UID).OrderBy(u => u).ToArray(),
        //        TotalCount = g.Count()
        //    })
        //        .ToList()
        //        .GroupBy(g => g.UID.JsonStringify())
        //        .Select(g => new
        //        {
        //            g.First().GroupingLesson,
        //            UID = g.Key,
        //            TotalCount = g.Sum(v => v.TotalCount),
        //        });

        //    foreach (var g in groupingCount)
        //    {
        //        var lesson = g.GroupingLesson;
        //        var item = lesson.RegisterLesson.First();
        //        GroupingLesson groupLesson = null;
        //        foreach (var uid in JsonConvert.DeserializeObject<int[]>(g.UID))
        //        {
        //            var currentFeedback = table
        //                .Where(r => r.ClassLevel == price.PriceID)
        //                .Where(r => r.UID == uid)
        //                .FirstOrDefault();

        //            if (currentFeedback == null)
        //            {
        //                if (groupLesson == null)
        //                {
        //                    groupLesson = new GroupingLesson { };
        //                }

        //                currentFeedback = new RegisterLesson
        //                {
        //                    UID = uid,
        //                    RegisterDate = DateTime.Now,
        //                    BranchID = item.BranchID,
        //                    GroupingMemberCount = item.GroupingMemberCount,
        //                    ClassLevel = price.PriceID,
        //                    IntuitionCharge = new IntuitionCharge
        //                    {
        //                        ByInstallments = 1,
        //                        Payment = "Cash",
        //                        FeeShared = 0
        //                    },
        //                    Attended = (int)Naming.LessonStatus.準備上課,
        //                    AdvisorID = item.AdvisorID,
        //                    AttendedLessons = 0,
        //                    GroupingLesson = groupLesson,
        //                };

        //                table.Add(currentFeedback);
        //            }

        //            if (currentFeedback.Lessons < g.TotalCount)
        //            {
        //                currentFeedback.Lessons = g.TotalCount;
        //                currentFeedback.Attended = (int)Naming.LessonStatus.準備上課;
        //            }

        //            models.SubmitChanges();

        //        }
        //    }
        //}

        public static bool ValidateMeetingRoom(this String url, BranchStore branch, GenericManager<BFDataContext> models)
        {
            bool check = false;
            var branchID = branch.BranchID;
            url = url?.ToLower();
            if (url != null)
            {
                var c = models.GetTable<ObjectiveLessonLocation>()
                                    .Where(l => l.BranchID == branchID)
                                    .Where(l => l.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine)
                                    .Where(l => l.PreferredUrl != null)
                                    .FirstOrDefault();
                if (c != null)
                {
                    check = false;
                    foreach (var place in JsonConvert.DeserializeObject<String[]>(c.PreferredUrl))
                    {
                        if (url.StartsWith(place.ToLower()))
                        {
                            check = true;
                            break;
                        }
                    }
                }

            }

            return check;
        }

        static readonly int[] SpecialGivingLesson2021 = { 422 };
        public static void RegisterSpecialGivingLesson2021(this GenericManager<BFDataContext> models, int[] items)
            
        {
            var table = models.GetTable<RegisterLesson>();

            foreach (var uid in items)
            {
                foreach(var priceID in SpecialGivingLesson2021)
                {
                    var givingLesson = table
                        .Where(r => r.ClassLevel == priceID)
                        .Where(r => r.UID == uid)
                        .FirstOrDefault();

                    if (givingLesson == null)
                    {
                        givingLesson = new RegisterLesson
                        {
                            UID = uid,
                            RegisterDate = DateTime.Now,
                            GroupingMemberCount = 1,
                            Lessons=1,
                            ClassLevel = priceID,
                            IntuitionCharge = new IntuitionCharge
                            {
                                ByInstallments = 1,
                                Payment = "Cash",
                                FeeShared = 0
                            },
                            Attended = (int)Naming.LessonStatus.準備上課,
                            AdvisorID = Startup.Properties.GetValue<int?>("DefaultCoach"),
                            AttendedLessons = 0,
                            GroupingLesson = new GroupingLesson { },
                        };

                        table.InsertOnSubmit(givingLesson);
                    }

                    models.SubmitChanges();

                }

            }
        }

    }
}