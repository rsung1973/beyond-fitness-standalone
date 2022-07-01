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
using Microsoft.AspNetCore.Mvc;

using CommonLib.DataAccess;

using CommonLib.Utility;
using WebHome.Controllers;
using WebHome.Helper.BusinessOperation;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.Timeline;
using WebHome.Models.ViewModel;
//

namespace WebHome.Helper
{
    public static class CourseContractExtensionMethods
    {
        public static IQueryable<CourseContract> PromptExpiringContract(this GenericManager<BFDataContext> models)
                
        {
            //var revisionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
            //    .Select(r => r.RevisionID);
            //var items = models.GetTable<CourseContract>()
            //    .Where(c => !c.RegisterLessonContract.Any(r => r.RegisterLesson.Attended == (int)Naming.LessonStatus.課程結束))
            //    .Where(c => c.Expiration < DateTime.Today.AddMonths(1))
            //    .Where(c => !revisionID.Any(r => r == c.ContractID));
            //return items;
            return models.PromptEffectiveContract()
                .Where(c => c.Expiration >= DateTime.Today)
                .Where(c => c.Expiration < DateTime.Today.AddMonths(1));
        }

        public static IQueryable<CourseContract> PromptUnpaidContract(this GenericManager<BFDataContext> models)
                
        {
            return models.PromptEffectiveContract().FilterByUnpaidContract(models);
        }

        public static IQueryable<CourseContract> FilterByUnpaidContract(this IQueryable<CourseContract> contractItems, GenericManager<BFDataContext> models)
                
        {
            var items = models.GetTable<ContractPayment>()
                    .Join(models.GetTable<Payment>().Where(p => p.VoidPayment == null),
                        c => c.PaymentID, p => p.PaymentID, (c, p) => c);

            return contractItems
                .Join(models.GetTable<CourseContractExtension>().Where(t => t.Version.HasValue),
                    c => c.ContractID, t => t.ContractID, (c, t) => c)
                .Where(c => !items.Any(t => t.ContractID == c.ContractID));
        }

        public static IQueryable<CourseContract> GetEarlyUnpaidInstallments(this CourseContract contract,GenericManager<BFDataContext> models)
                
        {
            var items = models.GetTable<CourseContract>()
                .Where(c => c.InstallmentID == contract.InstallmentID)
                .Where(c => c.ContractID < contract.ContractID);

            return items.FilterByUnpaidContract(models);
        }

        public static bool HasEarlyUnpaidInstallments(this CourseContract contract, GenericManager<BFDataContext> models)
                
        {
            return contract.GetEarlyUnpaidInstallments(models).Any();
        }

        public static IQueryable<CourseContract> PromptUnpaidExpiredContract(this GenericManager<BFDataContext> models)
                
        {
            return models.GetTable<CourseContract>().FilterByUnpaidExpiredContract(models);
        }

        public static IQueryable<CourseContract> FilterByUnpaidExpiredContract(this IQueryable<CourseContract> contractItems, GenericManager<BFDataContext> models)
                
        {
            return contractItems.Where(c => c.Status == (int)Naming.CourseContractStatus.已終止)
                .Where(c => c.Subject == "已自動終止");
        }


        public static IQueryable<CourseContract> PromptUnpaidExpiringContract(this GenericManager<BFDataContext> models)
                
        {
            return models.PromptUnpaidContract()
                .Where(c => c.PayoffDue < DateTime.Today);
        }

        public static IQueryable<CourseContract> PromptEffectiveContract(this GenericManager<BFDataContext> models)
                
        {
            //var revisionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
            //    .Select(r => r.RevisionID);
            var items = models.GetTable<CourseContract>()
                .Where(c => c.CourseContractRevision == null)
                .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效);
            return items;
            //return models.PromptOriginalContract().FilterByEffective(models);
        }

        public static IQueryable<CourseContract> PromptAccountingContract(this GenericManager<BFDataContext> models)
        
        {
            var items = models.GetTable<CourseContract>()
                .Where(c => c.CourseContractRevision == null)
                .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效
                    || c.Status == (int)Naming.CourseContractStatus.已過期);
            return items;
        }


        public static IQueryable<CourseContract> FilterByEffective(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models)
                
        {
            return items
                    .Where(c => c.Status == (int)Naming.CourseContractStatus.已生效);
        }

        public static IQueryable<CourseContract> PromptOriginalContract(this GenericManager<BFDataContext> models)
                
        {
            //var contractID = models.GetTable<RegisterLessonContract>()
            //                    .Join(models.GetTable<RegisterLesson>().Where(r => r.Attended != (int)Naming.LessonStatus.課程結束),
            //                        c => c.RegisterID, r => r.RegisterID, (c, r) => c.ContractID);
            //return models.GetTable<CourseContract>()
            //        .Where(c => contractID.Contains(c.ContractID));
            return models.PromptRegisterLessonContract()
                        .Where(c => c.Status >= (int)Naming.CourseContractStatus.已生效);
        }

        public static IQueryable<CourseContract> PromptRegisterLessonContract(this GenericManager<BFDataContext> models)
                
        {
            return models.GetTable<CourseContract>()
                    .Where(c => c.RegisterLessonContract.Any());
        }

        public static IQueryable<CourseContract> PromptContractService(this GenericManager<BFDataContext> models)
                
        {
            return models.GetTable<CourseContract>()
                .Join(models.GetTable<CourseContractRevision>(), c => c.ContractID, r => r.RevisionID, (c, r) => c);
        }

        public static IQueryable<CourseContractRevision> PromptEffectiveRevision(this GenericManager<BFDataContext> models, DateTime? dateFrom, DateTime? dateTo)
                
        {
            IQueryable<CourseContract> items = models.GetTable<CourseContract>();
            if (dateFrom.HasValue)
                items = items.Where(c => c.EffectiveDate >= dateFrom);
            if (dateTo.HasValue)
                items = items.Where(c => c.EffectiveDate < dateTo);
            return models.GetTable<CourseContractRevision>()
                .Join(models.PromptEffectiveContract(), r => r.OriginalContract, c => c.ContractID, (r, c) => r)
                .Join(items, r => r.RevisionID, c => c.ContractID, (r, c) => r);
        }


        public static IQueryable<CourseContract> FilterByExpiringContract(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models)
                
        {
            var revisionID = models.GetTable<CourseContractRevision>().Where(r => r.Reason == "展延")
                .Select(r => r.RevisionID);
            return items
                    .Where(c => !c.RegisterLessonContract.Any(r => r.RegisterLesson.Attended == (int)Naming.LessonStatus.課程結束))
                    .Where(c => c.Expiration < DateTime.Today.AddMonths(1))
                    .Where(c => !revisionID.Any(r => r == c.ContractID));
        }

        public static IQueryable<CourseContract> FilterByUserRoleScope(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models, UserProfile profile)
                
        {
            if (profile.IsAssistant() || profile.IsOfficer())
            {
                return items;
            }
            else if (profile.IsManager() || profile.IsViceManager())
            {
                return models.FilterByBranchStoreManager(items, profile);
            }
            else if (profile.IsCoach())
            {
                return items.Where(c => c.FitnessConsultant == profile.UID);
            }
            else
            {
                return items.Where(c => false);
            }
        }

        public static IQueryable<CourseContractRevision> FilterByUserRoleScope(this IQueryable<CourseContractRevision> items, GenericManager<BFDataContext> models, UserProfile profile)
                
        {
            if (profile.IsManager() || profile.IsViceManager())
            {
                items = items.Join(models.FilterByBranchStoreManager(models.GetTable<CourseContract>(), profile),
                    r => r.OriginalContract, c => c.ContractID, (r, c) => r);
            }
            else if (profile.IsAssistant() || profile.IsOfficer())
            {

            }
            else if (profile.IsCoach())
            {
                items = items.Where(c => c.CourseContract.FitnessConsultant == profile.UID);
            }
            else
            {
                items = items.Where(c => false);
            }

            return items;
        }

        public static IQueryable<CourseContract> FilterByExpired(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models)
                
        {
            return items.Where(c => c.Status == (int)Naming.CourseContractStatus.已過期);
        }

        public static IQueryable<CourseContract> FilterByToPay(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models)
                
        {

            //var dataItems = items.GroupJoin(models.GetTable<ContractPayment>()
            //                        .Join(models.GetTable<Payment>()
            //                            .Where(p => p.VoidPayment == null || p.AllowanceID.HasValue),
            //                            c => c.PaymentID, p => p.PaymentID, (c, p) => new { c.ContractID, p.PayoffAmount }),
            //                        t => t.ContractID, a => a.ContractID, (t, a) => new { Contract = t, TotalPaidAmount = a.Sum(s => s.PayoffAmount) })
            //                    .Where(t => !t.TotalPaidAmount.HasValue || t.Contract.TotalCost > t.TotalPaidAmount)
            //                    .Select(t => t.Contract);

            var dataItems = items.QueryContractPayment(models)
                    .Where(t => !t.TotalPaidAmount.HasValue || t.Contract.TotalCost > t.TotalPaidAmount)
                    .Select(t => t.Contract);

            return dataItems;
        }

        public static IQueryable<CourseContractPayment> QueryContractPayment(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models)
                
        {
            //var paymentItems = models.GetTable<Payment>().FilterByEffective();

            //var dataItems = items.Where(c => paymentItems.Any(p => p.ContractPayment.ContractID == c.ContractID))
            //    .Select(t => new CourseContractPayment
            //    {
            //        Contract = t,
            //        TotalPaidAmount = t.ContractPayment.Sum(s => s.Payment.PayoffAmount)
            //    });

            //int count = dataItems.Count();

            var dataItems = items.GroupJoin(models.GetTable<ContractPayment>()
                                    .Join(models.GetTable<Payment>().FilterByEffective(),
                                        c => c.PaymentID, p => p.PaymentID, (c, p) => new { c.ContractID, p.PayoffAmount }),
                                    t => t.ContractID, a => a.ContractID, (t, a) => new CourseContractPayment { Contract = t, TotalPaidAmount = a.Sum(s => s.PayoffAmount) });

            return dataItems;
        }

        public static bool IsContractService(this CourseContract item)
        {
            return item.CourseContractRevision != null;
        }

        public static String ContractCurrentStatus(this CourseContract item)
        {
            return item.IsContractService()
                        ? ((Naming.ContractServiceStatus)item.Status).ToString()
                        : item.Status == (int)Naming.ContractQueryStatus.已終止
                            ? item.Subject ?? ((Naming.ContractQueryStatus)item.Status).ToString()
                            : ((Naming.ContractQueryStatus)item.Status).ToString();
        }

        public static bool IsEditable(this CourseContract item, GenericManager<BFDataContext> models, UserProfile agent)
                
        {
            return item.Status == (int)Naming.CourseContractStatus.草稿
                    && (item.AgentID == agent.UID || item.FitnessConsultant == agent.UID);
            //return models.GetContractInEditingByAgent(agent).Any(c => c.ContractID == item.ContractID); ;

        }

        public static bool IsSignable(this CourseContract item, GenericManager<BFDataContext> models, UserProfile agent)
                
        {
            return item.Status == (int)Naming.CourseContractStatus.待簽名
                && agent.IsCoach();
            //return models.GetContractToSignByAgent(agent).Any(c => c.ContractID == item.ContractID);
        }

        public static bool IsApprovable(this CourseContract item, GenericManager<BFDataContext> models, UserProfile agent)
                
        {
            return models.GetContractToConfirmByAgent(agent).Any(c => c.ContractID == item.ContractID);
        }

        public static bool IsServiceApprovable(this CourseContract item, GenericManager<BFDataContext> models, UserProfile agent)
                
        {
            return models.GetAmendmentToAllowByAgent(agent).Any(c => c.RevisionID == item.ContractID);
        }

        public static bool IsServiceSignable(this CourseContract item, GenericManager<BFDataContext> models, UserProfile agent)
                
        {
            return item.IsSignable(models, agent);
            //return models.GetAmendmentToSignByAgent(agent).Any(c => c.RevisionID == item.ContractID);
        }

        public static bool IsPayable(this CourseContract item, GenericManager<BFDataContext> models)
                
        {
            return models.PromptAccountingContract()
                    .FilterByToPay(models)
                    .Any(c => c.ContractID == item.ContractID);
        }

        public static bool CanApplyContractAmendment(this CourseContract item, GenericManager<BFDataContext> models)
                
        {
            return (item.Status == (int)Naming.CourseContractStatus.已生效
                        || item.Status == (int)Naming.CourseContractStatus.已過期)
                    && !item.IsContractServiceInProgress(models);
        }

        public static bool IsContractServiceInProgress(this CourseContract item, GenericManager<BFDataContext> models)
                
        {
            return models.GetTable<CourseContractRevision>().Any(r => r.OriginalContract == item.ContractID && r.CourseContract.Status < (int)Naming.CourseContractStatus.已生效);
        }


        public static IQueryable<LessonPriceType> PromptEffectiveLessonPrice(this GenericManager<BFDataContext> models,IQueryable<LessonPriceType> items = null)
                
        {
            if(items==null)
            {
                items = models.GetTable<LessonPriceType>();
            }

            return items
                .Where(l => l.Status == (int)Naming.LessonSeriesStatus.已啟用)
                .Where(l => /*l.LowerLimit.HasValue &&*/ (!l.SeriesID.HasValue || l.CurrentPriceSeries.Status == (int)Naming.LessonSeriesStatus.已啟用));
        }

        public static IQueryable<UserProfile> PromptContractMembers(this int[] uid, GenericManager<BFDataContext> models)
                
        {
            IQueryable<UserProfile> items = models.GetTable<UserProfile>();

            if (uid != null && uid.Length > 0)
            {
                items = items.Where(u => uid.Contains(u.UID));
            }
            else
            {
                items = items.Where(u => false);
            }
            return items;
        }

        public static IQueryable<CourseContract> FilterByAlarmedContract(this IQueryable<CourseContract> items, GenericManager<BFDataContext> models, int alarmCount)
            
        {
            var c0 = items.Where(c => c.ContractType == (int)CourseContractType.ContractTypeDefinition.CFA 
                                    || c.ContractType == (int)CourseContractType.ContractTypeDefinition.CGF
                                    || c.ContractType == (int)CourseContractType.ContractTypeDefinition.CVF);
            var c1 = items.Where(c => c.ContractType != (int)CourseContractType.ContractTypeDefinition.CFA
                                    && c.ContractType != (int)CourseContractType.ContractTypeDefinition.CGF
                                    && c.ContractType != (int)CourseContractType.ContractTypeDefinition.CVF);

            var c2 = c0.Select(c => new { Contract = c, RemainedCount = c.RemainedLessonCount(false) })
                        .Concat(c1.Select(c => new { Contract = c, RemainedCount = c.RemainedLessonCount(false) }));
            return c2.Where(c => c.RemainedCount <= alarmCount).Select(c => c.Contract);
        }

        public static IQueryable<CourseContract> PromptAlarmedContract(this GenericManager<BFDataContext> models, int alarmCount)
            
        {
            return models.PromptEffectiveContract().FilterByAlarmedContract(models, alarmCount);
        }

        public static void ClearUnpaidOverdueContract(this GenericManager<BFDataContext> models)
                    
        {
            DateTime checkDate = DateTime.Today.FirstDayOfMonth();
            var items = models.PromptUnpaidContract()
                                .Where(c => c.PayoffDue.Value.AddMonths(1) < checkDate)
                                .Where(c => c.CourseContractExtension.Version.HasValue);

            foreach(var item in items)
            {
                item.Status = (int)Naming.CourseContractStatus.已終止;
                item.ValidTo = checkDate;
                item.Subject = "已自動終止";
            }
            models.SubmitChanges();

            foreach (var item in items)
            {
                item.TerminateRegisterLesson(models);
            }
        }

        public static void TerminateRegisterLesson(this CourseContract contract, GenericManager<BFDataContext> models)
        {
            models.ExecuteCommand(@"UPDATE       RegisterLesson
                    SET                Attended = {0}
                    FROM            RegisterLessonContract INNER JOIN
                                             RegisterLesson ON RegisterLessonContract.RegisterID = RegisterLesson.RegisterID
                    WHERE        (RegisterLessonContract.ContractID = {1})", (int)Naming.LessonStatus.課程結束, contract.ContractID);
        }

        public static LessonPriceType ContractOriginalSeriesPrice(this CourseContract item, GenericManager<BFDataContext> models)
                    
        {
            return item.LessonPriceType.LessonUnitPrice?.PriceTypeItem ?? item.LessonPriceType.GetOriginalSeriesPrice(models);

            //return item.LessonPriceType.CurrentPriceSeries?.AllLessonPrice.Where(p => p.LowerLimit == 1).FirstOrDefault();
        }

        public static LessonPriceType GetOriginalSeriesPrice(this LessonPriceType priceItem, GenericManager<BFDataContext> models)
        {
            var seriesItem = models.GetTable<V_LessonUnitPrice>()
                    .Where(p => p.DurationInMinutes == priceItem.DurationInMinutes)
                    .Where(p => p.BranchID == priceItem.BranchID)
                    .Join(models.GetTable<LessonPriceType>(),
                        p => p.PriceID, s => s.PriceID, (p, s) => s)
                    .OrderByDescending(s => s.PriceID);

            return seriesItem.FirstOrDefault();

            //return item.LessonPriceType.CurrentPriceSeries?.AllLessonPrice.Where(p => p.LowerLimit == 1).FirstOrDefault();
        }


        public static IQueryable<CourseContract> PartialEffective(this CourseContract item, GenericManager<BFDataContext> models)
            
        {
            return models.GetTable<CourseContract>().Where(c => c.InstallmentID == item.InstallmentID)
                    .Where(c => c.Status >= (int)Naming.CourseContractStatus.已生效);
        }

        public static int? TotalLessonCount(this CourseContract item,GenericManager<BFDataContext> models)
        {
            return item.InstallmentID.HasValue ? models.GetTable<CourseContract>().Where(c => c.InstallmentID == item.InstallmentID).Sum(c => c.Lessons) : (item.Lessons ?? item.LessonPriceType?.ExpandActualLessonCount(models));
        }

        public static LessonPriceType GetCandidateCustomCombinationPrice(this GenericManager<BFDataContext> models)
        {
            return models.GetTable<ObjectiveLessonPrice>()
                .Where(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.CustomCombination)
                .Select(p => p.LessonPriceType)
                .FirstOrDefault();
        }

        public static List<LessonPriceType> EvaluateCustomCombinationTotalCost(this GenericManager<BFDataContext> models,CourseContractViewModel viewModel, List<LessonPriceType> items, out int totalLessons,out int totalCost)
        {
            totalLessons = 0;
            totalCost = 0;

            CourseContractType typeItem;
            if (viewModel.ContractType == CourseContractType.ContractTypeDefinition.CGA_Aux)
            {
                typeItem = models.GetTable<CourseContractType>().Where(t => t.TypeID == (int?)viewModel.ContractTypeAux).FirstOrDefault();
            }
            else if (viewModel.ContractType == CourseContractType.ContractTypeDefinition.CVA_Aux)
            {
                typeItem = models.GetTable<CourseContractType>().Where(t => t.TypeID == ((int?)viewModel.ContractTypeAux + CourseContractType.OffsetFromCGA2CVA)).FirstOrDefault();
            }
            else
            {
                typeItem = models.GetTable<CourseContractType>().Where(t => t.TypeID == (int?)viewModel.ContractType).FirstOrDefault();
            }

            bool isNullOrEmpty = items == null || items.Count == 0;
            if (items == null)
            {
                items = new List<LessonPriceType>();
            }

            for (int i = 0; i < viewModel.OrderPriceID.Length; i++)
            {
                LessonPriceType item;
                if(isNullOrEmpty)
                {
                    item = models.GetTable<LessonPriceType>().Where(p => p.PriceID == viewModel.OrderPriceID[i]).FirstOrDefault();
                    items.Add(item);
                }
                else
                {
                    item = items[i];
                }

                if (viewModel.OrderLessons[i] > 0)
                {
                    if (item != null)
                    {
                        int lessons = ((item.BundleCount ?? 1) * viewModel.OrderLessons[i].Value);
                        int cost = (item.ListPrice ?? 0) * lessons;
                        totalLessons += lessons;

                        if (typeItem != null)
                        {
                            if (item.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.一對一課程))
                            {
                                totalCost += cost;
                            }
                            else
                            {
                                totalCost += cost * (typeItem.GroupingMemberCount ?? 1) * (typeItem.GroupingLessonDiscount.PercentageOfDiscount ?? 100) / 100;
                            }
                        }
                    }
                }
            }
            return items;
        }

        public static void EvaluateCustomCombinationTotalCost(this CourseContract item, out int totalLessons, out int totalCost)
        {
            totalLessons = 0;
            totalCost = 0;

            CourseContractType typeItem = item.CourseContractType;
            foreach (var order in item.CourseContractOrder)
            {
                LessonPriceType priceItem = order.LessonPriceType;

                int lessons = ((priceItem.BundleCount ?? 1) * order.Lessons);
                int cost = (priceItem.ListPrice ?? 0) * lessons;
                totalLessons += lessons;

                if (typeItem != null)
                {
                    if (priceItem.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.一對一課程))
                    {
                        totalCost += cost;
                    }
                    else
                    {
                        totalCost += cost * (typeItem.GroupingMemberCount ?? 1) * (typeItem.GroupingLessonDiscount.PercentageOfDiscount ?? 100) / 100;
                    }
                }
            }
        }

        public static int CalculateReturnAmount(this CourseContract contract,int totalPaid,out int processingFee)
        {
            int attendanceFee = 0;
            foreach (var r in contract.RegisterLessonContract
                    .Select(c => c.RegisterLesson))
            {
                attendanceFee += ((r.AttendedLessonCount(singleMode: true) * r.GroupingMemberCount * r.LessonPriceType.ListPrice * r.GroupingLessonDiscount.PercentageOfDiscount / 100) ?? 0);
            }
            int remained = totalPaid - attendanceFee;
            processingFee = Math.Min(remained * 20 / 100, 9000);
            return remained;
        }

        public static String CreatePIN(this GenericManager<BFDataContext> models, CourseContractExtension extension)
        {
            var pinCode = DateTime.Now.Ticks % 1000000;
            extension.SignerPIN = $"{(char)('A' + (pinCode % 26))}{(char)('A' + (pinCode % 1000 % 26))}-{pinCode:000000}";
            models.SubmitChanges();
            return extension.SignerPIN;
        }
    }
}