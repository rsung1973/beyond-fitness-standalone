using DocumentFormat.OpenXml.Wordprocessing;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Properties;
using WebHome.Helper;
using WebHome.Models.MIG3_1.C0401;
using CommonLib.Utility;
using CommonLib.Logger;
using CommonLib.Core.Utility;
using WebHome.Helper.Jobs;
using System.Net;
using System.Text;
using System.Web;

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

            test03();

            //test02(args);
            //test01();
            //test04(args);
            //test05();
            //test06();

            //(new CheckInvoiceDispatch()).DoJob();
            //test08();

            //System.Diagnostics.Debugger.Launch();
            //if(args.Length > 0 && int.TryParse(args[0],out int periodID))
            //{
            //    using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            //    {
            //        var item = models.GetTable<MonthlyIndicator>().Where(m => m.PeriodID == periodID).FirstOrDefault();
            //        if (item != null)
            //        {
            //            item.UpdateMonthlyAchievement(models);
            //        }
            //    }
            //}

            //test12();

        }

        private static void test12()
        {
            String urlPattern = "https://maps.google.com/maps/api/geocode/json?sensor=false&address={0}&key=AIzaSyDKXwfddYcgXgjFtAkXt4Iigh0KFe-HfsM&language=zh-TW";

            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                var items = models.GetTable<UserProfile>().Where(u => u.Address != null)
                                .Join(models.GetTable<UserProfileExtension>()
                                    .Where(t => t.AdministrativeArea != null)
                                    .Where(t => t.GeoCode == null),
                                    u => u.UID, t => t.UID, (u, t) => u);
                using (WebClient client = new WebClient())
                {
                    var encoding = new UTF8Encoding(false);
                    client.Headers.Add(HttpRequestHeader.ContentType, "application/json");
                    client.Encoding = encoding;

                    foreach (var item in items)
                    {
                        String url = String.Format(urlPattern, HttpUtility.UrlEncode($"{item.UserProfileExtension.AdministrativeArea}{item.Address}"));
                        FileLogger.Logger.Info(url);
                        var result = client.DownloadString(url);
                        item.UserProfileExtension.GeoCode = result;
                        models.SubmitChanges();
                        FileLogger.Logger.Info(result);
                        Thread.Sleep(50);
                    }
                }
            }
        }



        private static void test06()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                var items = models.GetTable<Organization>()
                                .Where(o => models.GetTable<BranchStore>()
                                                    .Any(b => b.BranchID == o.CompanyID));
                File.WriteAllText("data.json", items.JsonStringify());
            }
        }

        private static void test05()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                foreach (var item in models.GetTable<InvoiceItem>())
                {
                    try
                    {
                        var c0401 = item.CreateC0401();
                        c0401.ConvertToXml().Save(Path.Combine(FileLogger.Logger.LogDailyPath, $"C0401-{item.TrackCode}{item.No}.xml"));
                        Console.Write("+");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error:{item.InvoiceID},{item.TrackCode}{item.No}");
                        FileLogger.Logger.Error(ex);
                    }
                }

            }
        }

        private static void test07()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                foreach (var item in models.GetTable<InvoiceItem>()
                                        .Where(i=>models.GetTable<InvoiceCancellation>().Any(c=>c.InvoiceID==i.InvoiceID)))
                {
                    try
                    {
                        var c0501 = item.CreateC0501();
                        c0501.ConvertToXml().Save(Path.Combine(FileLogger.Logger.LogDailyPath, $"C0401-{item.TrackCode}{item.No}.xml"));
                        Console.Write("+");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error:{item.InvoiceID},{item.TrackCode}{item.No}");
                        FileLogger.Logger.Error(ex);
                    }
                }

            }
        }

        private static void test08()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                foreach (var item in models.GetTable<InvoiceAllowance>())
                {
                    try
                    {
                        var d0401 = item.CreateD0401();
                        d0401.ConvertToXml().Save(Path.Combine(FileLogger.Logger.LogDailyPath, $"D0401-{item.AllowanceNumber}.xml"));
                        Console.Write("+");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error:{item.AllowanceID},{item.AllowanceNumber}");
                        FileLogger.Logger.Error(ex);
                    }
                }

            }
        }


        private static void test04(string[] args)
        {
            if (!(args?.Length > 0))
            {
                return;
            }

            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                var invoiceNo = args[0];

                var item = models.GetTable<InvoiceItem>().Where(i => i.TrackCode == invoiceNo.Substring(0, 2)
                        && i.No == invoiceNo.Substring(2))
                    .OrderByDescending(i => i.InvoiceID)
                    .FirstOrDefault();
                if (item != null)
                {
                    var c0401 = item.CreateC0401();
                    c0401.ConvertToXml().Save(Path.Combine(FileLogger.Logger.LogDailyPath, $"C0401-{invoiceNo}.xml"));
                    var voidItem = new WebHome.Models.MIG3_1.C0701.VoidInvoice
                    {
                        VoidInvoiceNumber = invoiceNo,
                        InvoiceDate = String.Format("{0:yyyyMMdd}", item.InvoiceDate),
                        BuyerId = item.InvoiceBuyer.ReceiptNo,
                        SellerId = item.InvoiceSeller.ReceiptNo,
                        VoidDate = DateTime.Now.Date.ToString("yyyyMMdd"),
                        VoidTime = DateTime.Now,
                        VoidReason = "註銷重開",
                        Remark = ""
                    };

                    voidItem.ConvertToXml().Save(Path.Combine(FileLogger.Logger.LogDailyPath, $"C0701-{invoiceNo}.xml"));
                    Console.WriteLine(voidItem.ConvertToXml().OuterXml);
                }

            }
        }

        private static void test03()
        {
            using (ModelSource<BFDataContext> models = new ModelSource<BFDataContext>())
            {
                var invoice = models.GetTable<InvoiceItem>()
                        .Where(i => i.TrackCode == "CY")
                        .Where(i => i.No == "95117512").FirstOrDefault();
                var payment = invoice?.Payment.FirstOrDefault();
                if (payment != null)
                {
                    var allowance = models.PrepareAllowanceForPayment(payment, 3750, "退款", DateTime.Now);
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