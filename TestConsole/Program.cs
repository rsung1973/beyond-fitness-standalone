using DocumentFormat.OpenXml.Wordprocessing;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Properties;
using WebHome.Helper;

namespace TestConsole
{
    internal class Program
    {
        static void Main(string[] args)
        {
            if (AppSettings.Default.BFDbConnection == null)
            {
                AppSettings.Default.BFDbConnection = "Password=beyond;Persist Security Info=True;User ID=bf;Initial Catalog=BeyondFitness;Data Source=210.65.88.120\\sqlexpress,1433;MultipleActiveResultSets=true;";
                //AppSettings.Default.BFDbConnection = "Password=beyond;Persist Security Info=True;User ID=bf;Initial Catalog=BeyondFitnessProd2;Data Source=vm-titan\\sqlexpress,1433;MultipleActiveResultSets=true;";
            }

            //test03();

            test02(args);
            //test01();
        }

        private static void test03()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                var invoice = models.GetTable<InvoiceItem>()
                        .Where(i => i.TrackCode == "QZ")
                        .Where(i => i.No == "05760009").FirstOrDefault();
                var payment = invoice?.Payment.FirstOrDefault();
                if (payment != null)
                {
                    var allowance = models.PrepareAllowanceForPayment(payment, 14000, "退費", DateTime.Now);
                }
            }
        }

        private static void test02(string[] args)
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                MonthlyIndicator? item = null;
                if (args.Length > 0 && int.TryParse(args[0], out int periodID))
                {
                    item = models.GetTable<MonthlyIndicator>()
                        .Where(p => p.PeriodID == periodID)
                        .FirstOrDefault();

                    if (item != null)
                    {
                        CalculateInstallAchievement(models, item);
                    }
                }
                else
                {
                    foreach (var indicator in models.GetTable<MonthlyIndicator>())
                    {
                        CalculateInstallAchievement(models, indicator);
                    }

                }
            }
        }

        private static void CalculateInstallAchievement(ModelSource<BFDataContext> models, MonthlyIndicator indicator)
        {
            foreach (var coachItem in indicator.MonthlyCoachRevenueIndicator)
            {
                var shareSummary = indicator.GetPaymentAchievementSummary(models, coachItem.CoachID);
                var voidItems = indicator.GetVoidShare(models, coachItem.CoachID);

                coachItem.InstallmentAchievement = shareSummary - (voidItems.Sum(t => t.VoidShare) ?? 0);
                models.SubmitChanges();
                Console.Write('+');
            }
        }

        private static void test01()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                var items = models.GetTable<LearnerAward>()
                                .Where(a => a.ItemID == 34 || a.ItemID == 35)
                                .Where(a => !models.GetTable<AwardingLesson>().Any(l => l.AwardID == a.AwardID))
                                .ToList();
                foreach (var award in items)
                {
                    var item = award.BonusAwardingItem;
                    if (item.BonusAwardingLesson != null)
                    {
                        var lesson = models.GetTable<RegisterLesson>().Where(r => r.UID == award.UID)
                            .Join(models.GetTable<RegisterLessonContract>(), r => r.RegisterID, c => c.RegisterID, (r, c) => r)
                            .OrderByDescending(r => r.RegisterID).FirstOrDefault();

                        //if (item.BonusAwardingIndication != null && item.BonusAwardingIndication.Indication == "AwardingLessonGift")
                        //{
                        //    var giftLesson = new RegisterLesson
                        //    {
                        //        RegisterDate = DateTime.Now,
                        //        GroupingMemberCount = 1,
                        //        ClassLevel = item.BonusAwardingLesson.PriceID,
                        //        Lessons = 1,
                        //        UID = recipientID.Value,
                        //        AdvisorID = lesson?.RegisterLessonContract.CourseContract.FitnessConsultant,
                        //        Attended = (int)Naming.LessonStatus.準備上課,
                        //        GroupingLesson = new GroupingLesson { }
                        //    };
                        //    award.AwardingLessonGift = new AwardingLessonGift
                        //    {
                        //        RegisterLesson = giftLesson
                        //    };
                        //    models.GetTable<RegisterLesson>().InsertOnSubmit(giftLesson);
                        //}
                        //else
                        {
                            var awardLesson = new RegisterLesson
                            {
                                RegisterDate = DateTime.Now,
                                GroupingMemberCount = 1,
                                ClassLevel = item.BonusAwardingLesson.PriceID,
                                Lessons = 1,
                                UID = award.UID,
                                AdvisorID = lesson?.AdvisorID,
                                Attended = (int)Naming.LessonStatus.準備上課,
                                GroupingLesson = new GroupingLesson { }
                            };
                            award.AwardingLesson = new AwardingLesson
                            {
                                RegisterLesson = awardLesson
                            };
                            models.GetTable<RegisterLesson>().InsertOnSubmit(awardLesson);
                        }
                    }

                    models.SubmitChanges();
                    Console.WriteLine($"回補點數兌換課:AwardID:{award.AwardID},ItemID:{item.ItemID},{award.UserProfile.RealName}");
                }
            }
        }
    }
}