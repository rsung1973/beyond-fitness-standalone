using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using WebHome.Models.Locale;

namespace WebHome.Models.DataEntity
{
    public static class DataEntityExtendsions
    {
        public static String YearsOld(this UserProfile item)
        {
            return item.Birthday.HasValue ? (DateTime.Today.Year - item.Birthday.Value.Year).ToString() : "--";
        }

        public static int CurrentYearsOld(this UserProfile item)
        {
            return item.Birthday.HasValue ? (int)((DateTime.Today - item.Birthday.Value).TotalDays / 365) : 999;
        }

        public static bool CheckMinorLearner(this CourseContract item)
        {
            if (item.CourseContractType.IsGroup == true)
            {
                foreach (var m in item.CourseContractMember)
                {
                    if (m.UserProfile.CurrentYearsOld() < 18)
                    {
                        return true;
                    }
                }
            }
            else
            {
                return item.ContractOwner.CurrentYearsOld() < 18;
            }
            return false;
        }


        public static String CurrentLessonStatus(this LessonTime item)
        {
            return item.TrainingPlan.Count == 0
                                    ? item.RegisterLesson.LessonPriceType.Status == (int)Naming.DocumentLevelDefinition.自由教練預約
                                        ? item.LessonAttendance == null
                                            ? "已預約"
                                            : "已完成課程"
                                        : "已預約"
                                    : item.LessonAttendance != null
                                        ? "已完成課程"
                                        : "編輯課程內容中";
        }

        public static int RemainedLessonCount(this RegisterLesson item, bool onlyAttended = false)
        {
            if (item.RegisterLessonSharing != null)
            {
                return item.Lessons - item.RegisterLessonSharing.LessonRefernece.SharingReference
                    .Select(r => r.RegisterLesson)
                    .Sum(r => r.AttendedLessonCount(onlyAttended, true));

            }
            else
            {
                return item.Lessons - item.AttendedLessonCount(onlyAttended, true);
            }
        }

        public static int AttendedLessonCount(this RegisterLesson item, bool onlyAttended = false, bool singleMode = false)
        {
            if (singleMode)
            {
                if (onlyAttended)
                {
                    return (item.AttendedLessons ?? 0)
                            + (item.LessonTime.Count(l => l.LessonAttendance != null));
                }
                else
                {
                    return (item.AttendedLessons ?? 0)
                        + (item.LessonTime.Count);
                }
            }
            else
            {

                if (onlyAttended)
                {
                    return (item.AttendedLessons ?? 0)
                            + (item.RegisterGroupID.HasValue
                                    ? item.GroupingLesson.LessonTime.Count(l => l.LessonAttendance != null) / item.GroupingMemberCount
                                    : item.LessonTime.Count(l => l.LessonAttendance != null));
                }
                else
                {
                    return (item.AttendedLessons ?? 0)
                        + (item.RegisterGroupID.HasValue
                                    ? item.GroupingLesson.LessonTime.Count / item.GroupingMemberCount
                                    : item.LessonTime.Count);
                }
            }
        }

        public static int SpecifiedAttendedLessonCount(this RegisterLesson item, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return (item.RegisterGroupID.HasValue
                            ? item.GroupingLesson.LessonTime.Count(l => l.LessonAttendance != null)
                            : item.LessonTime.Count(l => l.LessonAttendance != null));
            }
            else
            {
                return (item.RegisterGroupID.HasValue
                        ? item.GroupingLesson.LessonTime.Count
                        : item.LessonTime.Count);
            }
        }

        public static IEnumerable<LessonTime> AttendedLessonList(this RegisterLesson item, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return item.GroupingLesson.LessonTime.Where(l => l.LessonAttendance != null);
            }
            else
            {
                return item.GroupingLesson.LessonTime;
            }
        }

        public static int AttendedLessonCount(this RegisterLesson item, DateTime dateBefore, bool onlyAttended = false, bool singleMode = false)
        {
            if (singleMode)
            {
                if (onlyAttended)
                {
                    return (item.AttendedLessons ?? 0)
                            + (item.LessonTime.Count(l => l.LessonAttendance != null && l.ClassTime < dateBefore));
                }
                else
                {
                    return (item.AttendedLessons ?? 0)
                        + (item.LessonTime.Count(l => l.ClassTime < dateBefore));
                }
            }
            else
            {

                if (onlyAttended)
                {
                    return (item.AttendedLessons ?? 0)
                            + (item.RegisterGroupID.HasValue
                                ? item.GroupingLesson.LessonTime.Count(l => l.LessonAttendance != null && l.ClassTime < dateBefore)
                                : item.LessonTime.Count(l => l.LessonAttendance != null && l.ClassTime < dateBefore));
                }
                else
                {
                    return (item.AttendedLessons ?? 0)
                        + (item.RegisterGroupID.HasValue
                            ? item.GroupingLesson.LessonTime.Count(l => l.ClassTime < dateBefore)
                            : item.LessonTime.Count(l => l.ClassTime < dateBefore));
                }
            }
        }

        public static int RemainedLessonCount(this CourseContract item, bool onlyAttended = false)
        {
            return item.RegisterLessonContract
                .Select(c => c.RegisterLesson)
                .Where(r => r.SharingReference.Any())
                .Sum(r => r.Lessons) - item.AttendedLessonCount(onlyAttended);
        }

        public static int UnfinishedLessonCount(this CourseContract item)
        {
            return item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l => l.LessonAttendance == null));
        }

        public static int AttendedLessonCount(this CourseContract item, bool onlyAttended = false)
        {
            var items = item.RegisterLessonContract.Select(c => c.RegisterLesson);

            return items.Sum(r => r.AttendedLessonCount(onlyAttended, singleMode: true));
        }

        public static int AttendedLessonCount(this CourseContract item, DateTime dateBefore, bool onlyAttended = false)
        {
            var items = item.RegisterLessonContract.Select(c => c.RegisterLesson);

            return items.Sum(r => r.AttendedLessonCount(dateBefore, onlyAttended, singleMode: true));

        }

        public static int TotalAttendedCost(this CourseContract item, DateTime dateBefore, bool onlyAttended = false)
        {
            var items = item.RegisterLessonContract.Select(c => c.RegisterLesson);

            return items.Sum(r => r.AttendedLessonCount(dateBefore, onlyAttended)
                                * r.LessonPriceType.ListPrice.Value * (r.GroupingLessonDiscount.PercentageOfDiscount ?? 100) / 100);

        }

        //public static int TotalAttendedCost(this CourseContract item, DateTime dateFrom, DateTime dateBefore, bool onlyAttended = false)
        //{
        //    var items = item.CountableRegisterLesson();

        //    if (onlyAttended)
        //    {
        //        return items.Sum(r => ((r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.LessonAttendance != null && l.ClassTime >= dateFrom && l.ClassTime < dateBefore).Count())
        //                            * r.LessonPriceType.ListPrice.Value);
        //    }
        //    else
        //    {
        //        return items.Sum(r => ((r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.ClassTime >= dateFrom && l.ClassTime < dateBefore).Count())
        //                            * r.LessonPriceType.ListPrice.Value);
        //    }
        //}



        public static IEnumerable<LessonTime> AttendedLessonList(this CourseContract item, bool onlyAttended = false)
        {
            var items = item.RegisterLessonContract
                .Select(c => c.RegisterLesson)
                .GroupBy(r => r.GroupingLesson)
                .Select(g => g.Key)
                .SelectMany(g => g.LessonTime);

            if (onlyAttended)
            {
                items = items
                    .Where(l => l.LessonAttendance != null);
            }

            return items;
        }

        //public static IEnumerable<RegisterLesson> CountableRegisterLesson(this CourseContract item)
        //{
        //    //if (item.ContractType == (int)CourseContractType.ContractTypeDefinition.CFA)
        //    //{
        //    //    return item.RegisterLessonContract
        //    //        .Select(c => c.RegisterLesson);
        //    //}
        //    //else
        //    //{
        //    //    return item.RegisterLessonContract
        //    //        .Select(c => c.RegisterLesson)
        //    //        .Where(r => r.UID == item.OwnerID);
        //    //}

        //    return item.RegisterLessonContract.Where(r => r.ForShared == true)
        //        .Select(c => c.RegisterLesson)
        //        .Concat(item.RegisterLessonContract
        //            .Where(c => !c.ForShared.HasValue || c.ForShared == false)
        //            .Select(c => c.RegisterLesson)
        //            .Where(r => r.UID == item.OwnerID));

        //}


        public static String FullName(this UserProfile item, bool mask = false)
        {
            if (mask)
            {
                return item.Nickname == null ? item.RealName.MaskedName() : item.RealName.MaskedName() + "(" + item.Nickname + ")";
            }
            return item.Nickname == null ? item.RealName : item.RealName + "(" + item.Nickname + ")";
        }

        public static String FullNameHtml(this UserProfile profile, String css = null)
        {
            return String.Concat($"<span class='{css}'>{profile.RealName}",
                        !String.IsNullOrEmpty(profile.Nickname) ? $"<span class='small'>({profile.Nickname})</span>" : null,
                        "</span>");
        }

        public static String MaskedName(this String name)
        {
            if (name == null || name.Length < 2)
                return name;
            StringBuilder sb = new StringBuilder(name);
            sb[1] = 'Ｏ';
            return sb.ToString();
        }

        public static String Address(this UserProfile item)
        {
            return item.UserProfileExtension.AdministrativeArea + item.Address;
        }


        public static String ContractNo(this CourseContract contract)
        {
            return contract.ContractNo != null ? String.Format("{0}-{1:00}", contract.ContractNo, contract.SequenceNo) : "--";
        }

        public static String ContractName(this CourseContract item)
        {
            return $"{item.CourseContractType.TypeName}({item.CurrentPrice.DurationInMinutes}分鐘)";
        }

        public static String ContractLearner(this CourseContract item, String separator = "/")
        {
            if (item.CourseContractType.IsGroup == true)
            {
                return String.Join(separator, item.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()));
            }
            else
            {
                return item.ContractOwner.FullName();
            }
        }

        public static String ContractLearnerName(this CourseContract item, String separator = "/")
        {
            if (item.CourseContractType.IsGroup == true)
            {
                return String.Join(separator, item.CourseContractMember.Select(m => m.UserProfile.RealName));
            }
            else
            {
                return item.ContractOwner.RealName;
            }
        }


        public static String LessonLearner(this RegisterLesson lesson, String separator = "/")
        {
            if (lesson.GroupingMemberCount > 1)
            {
                return String.Join(separator, lesson.GroupingLesson.RegisterLesson.Select(s => s.UserProfile).ToArray().Select(m => m.FullName()));
            }
            else
            {
                return lesson.UserProfile.FullName();
            }
        }

        public static DateTime? Expiration(this CourseContract contract)
        {
            var revision = contract.RevisionList.Where(r => r.Reason == "展期").FirstOrDefault();
            if (revision != null)
            {
                return revision.CourseContract.Expiration;
            }
            return contract.Expiration;
        }


        public static int TotalPaidAmount(this CourseContract contract)
        {
            return contract.ContractPayment
                .Select(c => c.Payment)
                .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                .FilterByEffective()
                .Sum(c => c.PayoffAmount) ?? 0;
        }

        public static int? TotalPayoffCount(this CourseContract contract)
        {
            return contract.ContractPayment
                .Select(c => c.Payment)
                .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                .FilterByEffective().Count();
        }

        public static decimal? TotalAllowanceAmount(this CourseContract contract)
        {
            return contract.ContractPayment
                .Select(c => c.Payment)
                .Where(p => p.AllowanceID.HasValue)
                .Select(p => p.InvoiceAllowance)
                .Sum(c => c.TotalAmount + c.TaxAmount);
        }


        public static LessonPriceType OriginalSeriesPrice(this CourseContract item)
        {
            return item.LessonPriceType.SeriesID.HasValue
                ? item.LessonPriceType
                    .CurrentPriceSeries.AllLessonPrice
                        .Where(p => p.DurationInMinutes == item.LessonPriceType.DurationInMinutes)
                        .OrderBy(p => p.LowerLimit).FirstOrDefault()
                : null;
        }

        public static String LessonTypeStatus(this int? status)
        {
            switch (status)
            {
                case (int)Naming.LessonPriceStatus.自主訓練:
                    return "P.I";
                case (int)Naming.LessonPriceStatus.一般課程:
                case (int)Naming.LessonPriceStatus.團體學員課程:
                case (int)Naming.LessonPriceStatus.已刪除:
                    return "P.T";
                case (int)Naming.LessonPriceStatus.在家訓練:
                    return "S.T";
                case (int)Naming.LessonPriceStatus.教練PI:
                    return "Coach P.I";
                case (int)Naming.LessonPriceStatus.體驗課程:
                    return "T.S";
                case (int)Naming.LessonPriceStatus.營養課程:
                    return "S.D";
                case (int)Naming.LessonPriceStatus.運動恢復課程:
                    return "S.R";
                case (int)Naming.LessonPriceStatus.運動防護課程:
                    return "A.T";

                default:
                    return ((Naming.LessonPriceStatus)status).ToString();
            }
        }

        public static String LessonTypeStatus(this LessonTime item)
        {
            if (item.RegisterLesson.RegisterLessonEnterprise == null)
            {
                switch (item.RegisterLesson.LessonPriceType.Status)
                {
                    case (int)Naming.LessonPriceStatus.自主訓練:
                        return "P.I";
                    case (int)Naming.LessonPriceStatus.一般課程:
                    case (int)Naming.LessonPriceStatus.團體學員課程:
                    case (int)Naming.LessonPriceStatus.已刪除:
                        return "P.T";
                    case (int)Naming.LessonPriceStatus.在家訓練:
                        return "S.T";
                    case (int)Naming.LessonPriceStatus.教練PI:
                        return "Coach P.I";
                    case (int)Naming.LessonPriceStatus.體驗課程:
                        return item.RegisterLesson.LessonPriceType.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.BR體驗)
                                ? "T.S - BR"
                                : "T.S - 檢測";
                    case (int)Naming.LessonPriceStatus.點數兌換課程:
                        return item.RegisterLesson.LessonPriceType.SimpleDescription;
                    case (int)Naming.LessonPriceStatus.營養課程:
                        return "S.D";
                    case (int)Naming.LessonPriceStatus.運動恢復課程:
                        return "S.R";
                    case (int)Naming.LessonPriceStatus.運動防護課程:
                        return "A.T";
                    default:
                        return item.RegisterLesson.LessonPriceType.Description;
                }
            }
            else
            {
                return item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status.LessonTypeStatus() + "(企)";
            }
        }

        public static IQueryable<TuitionAchievement> FilterByEffective(this IQueryable<TuitionAchievement> items)
        {
            return items
                    .Where(t => t.Payment.VoidPayment == null || t.Payment.AllowanceID.HasValue);
        }

        public static IEnumerable<Payment> FilterByEffective(this IEnumerable<Payment> items)
        {
            return items
                    .Where(t => t.VoidPayment == null || t.AllowanceID.HasValue);
        }

        public static IEnumerable<TuitionAchievement> FilterByEffective(this IEnumerable<TuitionAchievement> items)
        {
            return items
                    .Where(t => t.Payment.VoidPayment == null || t.Payment.AllowanceID.HasValue);
        }

        public static IQueryable<Payment> FilterByEffective(this IQueryable<Payment> items)
        {
            return items
                    .Where(t => t.VoidPayment == null || t.AllowanceID.HasValue);
        }


        public static decimal? EffectiveAchievement(this Payment item)
        {
            if (item.AllowanceID.HasValue)
            {
                return item.PayoffAmount - item.InvoiceAllowance.TotalAmount - item.InvoiceAllowance.TaxAmount;
            }
            else if (item.VoidPayment != null)
            {
                return 0;
            }
            else
            {
                return item.PayoffAmount;
            }
        }

        public static String FullLessonDuration(this LessonTime item)
        {
            return $"{item.ClassTime:yyyy/MM/dd HH:mm}~{item.ClassTime.Value.AddMinutes(item.DurationInMinutes.Value):HH:mm}";
        }

        public static bool IsCompletePDQ(this UserProfile profile)
        {
            return profile.PDQTask
                .Select(t => t.PDQQuestion)
                .Where(q => q.PDQQuestionExtension == null).Count() >= 20;
        }

        public static String PriceTypeBundle(this LessonPriceType item)
        {
            return item.SeriesID.HasValue
                    ? item.Status == (int)Naming.LessonPriceStatus.營養課程
                        || item.Status == (int)Naming.LessonPriceStatus.自主訓練
                        ? item.Description
                        : item.LowerLimit == 1
                            ? "單堂"
                            : item.LowerLimit + "堂"
                    : item.Description;
        }

        public static int? SeriesSingleLessonPrice(this LessonPriceType item)
        {
            return item.LessonUnitPrice != null
                ? item.LessonUnitPrice.PriceTypeItem.ListPrice
                : item.CurrentPriceSeries?.AllLessonPrice.Where(p => p.LowerLimit == 1).FirstOrDefault()?.ListPrice;
        }

        public static string ExercisePowerAbility(this PersonalExercisePurpose purpose)
        {
            return purpose?.PowerAbility != null
                        ? purpose.PowerAbility.Substring(0, 3)
                        : "？型";
        }

        public static string ExercisePurpose(this PersonalExercisePurpose purpose)
        {
            return $"{(purpose?.Purpose ?? "？")}期";
        }

        public static string ExercisePurposeDescription(this PersonalExercisePurpose purpose)
        {
            return String.Concat(
                purpose.ExercisePowerAbility(),
                " / ",
                purpose.ExercisePurpose());
        }

        public static String PayerName(this Payment item, String insteadOfNull = null)
        {
            return item.TuitionInstallment != null
                        ? item.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile.FullName()
                        : item.ContractPayment != null
                            ? item.ContractPayment.CourseContract.CourseContractType.IsGroup == true
                                ? String.Join("/", item.ContractPayment.CourseContract.CourseContractMember.Select(m => m.UserProfile).ToArray().Select(u => u.FullName()))
                                : item.ContractPayment.CourseContract.ContractOwner.FullName()
                            : item.PaymentTransaction.PaymentContractTermination != null
                                ? item.PaymentTransaction.PaymentContractTermination.CourseContractTermination.CourseContractRevision.CourseContract.ContractOwner.FullName()
                                : item.PaymentTransaction.UserProfile?.FullName() ?? insteadOfNull;
        }

        public static UserProfile Payer(this Payment item)
        {
            return item.TuitionInstallment != null
                        ? item.TuitionInstallment.IntuitionCharge.RegisterLesson.UserProfile
                        : item.ContractPayment?.CourseContract.ContractOwner;
        }

        public static String WorkPlace(this ServingCoach item)
        {
            return item.CoachWorkplace.Count == 1
                            ? item.CoachWorkplace.First().BranchStore.BranchName
                            : "其他";
        }

        public static int? WorkBranchID(this ServingCoach item)
        {
            return item.CoachWorkplace.Count == 1
                            ? (int?)item.CoachWorkplace.First().BranchID
                            : (int?)null;
        }

        public static int? PreferredBranchID(this ServingCoach item)
        {
            return item.CoachWorkplace.FirstOrDefault()?.BranchID;
        }

        public static BranchStore CurrentWorkBranch(this ServingCoach item)
        {
            return item.CoachWorkplace.Count == 1
                            ? item.CoachWorkplace.First().BranchStore
                            : null;
        }

        public static int? SelectWorkBranchID(this ServingCoach item)
        {
            return item.CoachWorkplace.FirstOrDefault()?.BranchID;
        }

        public static String TerminationReason(this CourseContractRevision item)
        {
            StringBuilder sb = new StringBuilder();
            if (item.CauseForEnding.HasValue)
            {
                sb.Append((Naming.CauseForEnding)item.CauseForEnding);
            }
            if (item.CourseContract.Remark != null)
            {
                sb.Append($"（{item.CourseContract.Remark}）");
            }

            return sb.ToString();
        }

        public static bool IsOfficer(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.Special;
        }

        public static bool IsManager(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.FM;
        }

        public static bool IsViceManager(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.AFM;
        }

        public static bool IsFES(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.FES;
        }

        public static bool IsHealthCare(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.Health;
        }

        public static bool IsDietitian(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.Health_SD;
        }

        public static bool IsCoach(this ProfessionalLevel level)
        {
            return level?.CategoryID == (int)Naming.ProfessionalCategory.Senior
                    || level?.CategoryID == (int)Naming.ProfessionalCategory.Junior;
        }
    }

    public partial class UserProfile
    {
        public UserRole CurrentUserRole
        {
            get
            {
                return this.UserRole.Count > 0 ? this.UserRole[0] : null;
            }
        }

        public int? DailyQuestionID { get; set; }

        public bool IsVIP { get => ((UserProfileExtension?.VipStatus ?? 0) & (int)UserProfileExtension.VipStatusDefinition.VVIP) > 0; }
        public bool IsAnonymous { get => ((UserProfileExtension?.VipStatus ?? 0) & (int)UserProfileExtension.VipStatusDefinition.Anonymous) > 0; }
        public bool IsRegular { get => ((UserProfileExtension?.VipStatus ?? 0) & (int)UserProfileExtension.VipStatusDefinition.RegularCustomer) > 0; }

    }

    public class CourseContractPayment
    {
        public CourseContract Contract { get; set; }
        public decimal? TotalPaidAmount { get; set; }
    }

    public partial class UserProfileExtension
    {
        public enum VipStatusDefinition
        {
            VVIP = 1,
            PIOnly = 2,
            LimitedAccount = 4,
            Anonymous = 8,
            RegularCustomer = 16,   // <2020/1/1 建檔學員
        }
    }

    public partial class MonthlyCoachRevenueIndicator
    {
        public decimal AttendanceCount => (ActualCompleteLessonCount ?? 0)
                    + (ActualCompleteTSCount ?? 0)
                    + (ActualCompletePICount ?? 0M) / 2M
                    + (ATCount ?? 0)
                    + (SRCount ?? 0)
                    + (SDCount ?? 0);

        public int? FinalActualBRCount { get => (ActualBRCount ?? 0) + (AdjustActualBRCount ?? 0); }
        public int? FinalDealedCountWithBR { get => (DealedCountWithBR ?? 0) + (AdjustDealedCountWithBR ?? 0); }
        public int? FinalTrialDealedCount { get => (TrialDealedCount ?? 0) + (AdjustTrialDealedCount ?? 0); }
    }

    public partial class BranchStore
    {
        [Flags]
        public enum StatusDefinition
        {
            CurrentDisabled = 1,
            VirtualClassroom = 2,
            GeographicLocation = 4,
        }

        public bool IsVirtualClassroom()
        {
            return (this.Status & (int)StatusDefinition.VirtualClassroom) == (int)StatusDefinition.VirtualClassroom;
        }
    }

    public partial class ObjectiveLessonCatalog
    {
        public enum CatalogDefinition
        {
            OnLine = 1,
            OnLineFeedback = 2,
            LessonPackage = 3,
            DietaryConsult = 4,
            CustomCombination = 5,
            AT = 6,
            SR = 7,
            SD = 8,
        }
    }

    public partial class Payment
    {
        public String PaymentFor => TransactionType == (int)Naming.PaymentTransactionType.自主訓練
                    ? TuitionInstallment != null
                        ? this.TuitionInstallment.IntuitionCharge.RegisterLesson.LessonPriceType.SimpleDescription
                        : "T.S/P.I"
                    : ContractPayment != null
                        ? ContractPayment.CourseContract.ContractType == (int)CourseContractType.ContractTypeDefinition.CIA
                            ? "自主體能顧問課程費"
                            : ((Naming.PaymentTransactionType)this.TransactionType).ToString()
                        : String.Concat(((Naming.PaymentTransactionType)this.TransactionType).ToString(),
                                    "-",
                                    this.TransactionType == (int)Naming.PaymentTransactionType.運動商品
                                        || this.TransactionType == (int)Naming.PaymentTransactionType.食飲品
                                        || this.TransactionType == (int)Naming.PaymentTransactionType.各項費用
                                    ? this.PaymentTransaction.PaymentOrder.Any()
                                        ? String.Join("/", this.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName))
                                        : String.Join("/", this.InvoiceItem?.InvoiceDetails.Select(d => d.InvoiceProduct.Brief))
                                    : null);
    }

    public partial class LessonPriceType
    {
        public String SimpleDescription
        {
            get
            {
                //if (IsSingleCharge && SessionScopeForPTSingleCharge.Contains(this?.Status))
                //    return "P.T《單堂購買》";
                var singleCharge = this?.LessonPriceProperty
                        .Where(p => p.PropertyID == (int)Naming.LessonPriceFeature.單堂現場付款)
                        .FirstOrDefault();

                if (Description == null)
                    return null;

                int start = Description.IndexOf('》');
                if (start == -1)
                {
                    start = Description.IndexOf('】');
                }

                int end = Description.IndexOf('-', start + 1);
                if (end == -1)
                {
                    end = Description.IndexOf('/', start + 1);
                }

                return end == -1
                            ? $"{Description[(start + 1)..].Trim()}{singleCharge?.Description}"
                            : $"{Description[(start + 1)..end].Trim()}{singleCharge?.Description}";

            }
        }
        public bool IsPackagePrice => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.LessonPackage) == true;
        public bool IsDietaryConsult => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.DietaryConsult) == true;
        public bool IsDistanceLesson => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine) == true;
        public bool IsCombination => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.CustomCombination) == true;
        public bool IsOneByOne => this?.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.一對一課程) == true;
        public bool ForDietary => this?.Status == (int)Naming.LessonPriceStatus.營養課程
            || this?.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.營養課程) == true;
        public bool IsSingleCharge => this?.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.單堂現場付款) == true;
        public bool IsATSession => this?.Status == (int)Naming.LessonPriceStatus.運動防護課程
            || this?.LessonPriceProperty.Any(p => p.PropertyID == (int)Naming.LessonPriceFeature.運動防護課程) == true;

        public static readonly int?[] SessionScopeForPTSingleCharge = new int?[]
        {
                    (int)Naming.LessonPriceStatus.一般課程,
                    (int)Naming.LessonPriceStatus.運動恢復課程,
                    (int)Naming.LessonPriceStatus.運動防護課程,
        };

        public String SimpleSessionName
        {
            get
            {
                switch ((Naming.LessonPriceStatus?)this.Status)
                {
                    case Naming.LessonPriceStatus.營養課程:
                        return "S.D";
                    case Naming.LessonPriceStatus.運動恢復課程:
                        return "S.R";
                    case Naming.LessonPriceStatus.運動防護課程:
                        return "A.T";
                    case Naming.LessonPriceStatus.自主訓練:
                        return "P.I";
                    default:
                        return "P.T";
                }
            }
        }

        public String SessionName
        {
            get
            {
                switch ((Naming.LessonPriceStatus?)this.Status)
                {
                    case Naming.LessonPriceStatus.營養課程:
                        return "S.D Session《一個月》";
                    case Naming.LessonPriceStatus.運動恢復課程:
                        return "S.R Session";
                    case Naming.LessonPriceStatus.運動防護課程:
                        return "A.T Session";
                    case Naming.LessonPriceStatus.自主訓練:
                        return "P.I Session";
                    default:
                        return "P.T Session";
                }
            }
        }
    }

    public partial class RegisterLesson
    {
        public bool IsPaid => IntuitionCharge?.TuitionInstallment?
            .Any(t => t.Payment.VoidPayment == null || t.Payment.VoidPayment.Status != (int)Naming.CourseContractStatus.已生效) == true;

        public bool IsSingleCharge => this?.RegisterLessonContract == null && this?.LessonPriceType.IsSingleCharge == true;

    }

    public partial class LessonTime
    {
        public enum SelfTrainingDefinition
        {
            自主訓練 = 1,
            在家訓練 = 2,
            體驗課程 = 3,
        }
    }

    public partial class CourseContractType
    {
        public enum ContractTypeDefinition
        {
            CPA = 1,
            CFA,
            CPB,
            CPC,
            CNA,
            CGA,
            CGF,
            CGB,
            CGC,
            CRA,
            CMP,
            CVA,
            CVF,
            CVB,
            CVC,
            CRF,
            CIA,
        }

        public static bool IsSuitableForVirtaulClass(ContractTypeDefinition? ct)
        {
            return ct == ContractTypeDefinition.CPA
                || ct == ContractTypeDefinition.CNA
                || ct == ContractTypeDefinition.CVA
                || ct == ContractTypeDefinition.CVB
                || ct == ContractTypeDefinition.CVC
                || ct == ContractTypeDefinition.CVF;
        }

        public bool ForVirtaulClass => IsSuitableForVirtaulClass((ContractTypeDefinition)TypeID);

        public bool IsCombination => this.ContractCode?.StartsWith("CG") == true;

        public bool IsVirtualCourse => this.ContractCode?.StartsWith("CV") == true;
        public enum TrustTypeDefinition
        {
            Ignore = 0,
            Normal = 1,
        }
    }

    public partial class CourseContractExtension
    {
        public enum UnitPriceAdjustmentDefinition
        {
            //是否彈性設定購買單價
            T1 = 1, //否，不可彈性設定購買單價
            T2 = 2, //是，轉讓予第三人允許彈性設定購買單價
            T3 = 3, //是，轉開新合約允許彈性設定購買單價
            T4 = 4,	//是，企業簽訂優惠允許彈性設定購買單價
        }

        public static readonly String[] PriceAdjustment =
            {
                "",
                "固定牌告單位數",
                "轉讓第三人",
                "轉開新合約",
                "特別簽訂優惠",
            };
    }

    public partial class UserRelationship
    {
        public enum RelationForDefinition
        {
            NotMySelfPhone = 1,
        }

    }

    public partial class LessonPriceExchange
    {
        public enum ExchangeStatus
        {
            已停用 = 0,
        }

    }

    public partial class CourseContractAction
    {
        public enum ActionType
        {
            轉換課程堂數 = 1,
            合約終止手續費 = 2,
            免收手續費 = 3,
            盤點 = 4,
        }

    }

    public partial class CourseContractRevision
    {
        public static String CauseForEndingMeaning(Naming.CauseForEnding? cause)
        {
            switch (cause)
            {
                case Naming.CauseForEnding.合約到期轉新約:
                    return "合約到期轉新約";
                case Naming.CauseForEnding.轉讓第三人:
                    return "轉讓第三人";
                case Naming.CauseForEnding.私人原因:
                    return "私人原因（工作、搬家、懷孕、受傷）";
                case Naming.CauseForEnding.更改合約類型:
                    return "更改合約內容（不退費：更改類型/購買堂數等）";
                case Naming.CauseForEnding.學生簽約後反悔:
                    return "學生簽約後反悔";
                case Naming.CauseForEnding.所屬教練離職:
                    return "所屬教練離職";
                case Naming.CauseForEnding.新冠肺炎疫情:
                    return "新冠肺炎疫情";
                case Naming.CauseForEnding.不宜運動:
                    return "傷害、疾病或身體不適致不宜運動（須檢附醫生證明）";
                case Naming.CauseForEnding.其他:
                    return "其他（自行輸入）";
                default:
                    return null;

            }
        }
    }

    public partial class CourseContractTermination
    {
        public enum FeeChargeType
        {
            不收 = 0,
            已收 = 1,
            待收 = 2,
        }
    }

    public partial class SystemEventBulletin
    {
        public enum BulletinEventType
        {
            新手上路 = 1,
            新手上路導覽推播 = 2,
            系統公告 = 3,
        }
    }

    public partial class LearnerCoachProperty
    {
        public enum PropertyType
        {
            PrimaryCoach = 1,
        }
    }

    public partial class ServingCoach
    {
        public bool IsLeaved => LeavedDate.HasValue;
    }

    public partial class CourseContract
    {
        public LessonPriceType CurrentPrice
        {
            get => this.CourseContractOrder?.Count == 1 ? CourseContractOrder[0].LessonPriceType : this.LessonPriceType;
        }
    }

    public partial class CoachCertificate
    {
        public enum CertificateStatusDefinition
        {
            已核准 = 1,
            待審核 = 2,
        }
    }

    public partial class ProfessionalCertificate
    {
        public enum ProfessionalCertificateStatus
        {
            已下架 = 0,
            正常 = 1,
        }
    }

    public partial class ServingCoachProperty
    {
        public enum PropertyDefinition
        {
            Apprentice = 1,
        }
    }

    public partial class TrialLearner
    {
        public enum TrialStatusDefinition
        {
            尚未聯繫 = 1,
            已PARQ = 2,
            不需要 = 3,
            聯繫不上 = 4,
            電話空號 = 5,
            時間確認中 = 6,
            已約好準備體驗 = 7,
            完成體驗 = 8,
        }
    }

    public partial class UserProfileProperty
    {
        public enum PropertyDefinition
        {
            ValidEmail = 1301,
        }
    }

    public partial class TrainingStage
    {
        public enum StageDefinition
        {
            Basic = 1,
            Athletic = 2,
            Strength = 3,
            Cardio = 4,
            Recover = 5,
        }
    }

    public partial class FeedbackSurvey
    {
        public enum RequiredLevelDefinition 
        {
            Required = 1,
        }

        public enum QuestionTypeDefinition 
        { 
            QandA = 200,
            SingleChoice = 201,
        }
    }

    public partial class CampaignMission
    {
        public enum CampaignMissionType
        {
            SelfAssessment = 1,
            FeedbackSurvey = 2,
        }
    }

    public partial class MerchandiseTransactionType
    {
        public enum MainAwardingCategory
        {
            TrainingCourse = 11,
            ExerciseEquipment = 12,
            FasciaReleaseEquipment = 13,    
            BrandedClothing = 14,
        }
    }

    public partial class LessonSelfAssessment
    {
        public enum WaterIntakeIndication
        {
            極度缺乏 = 1,
            有點缺乏 = 2,
            及格 = 3,
            良好 = 4,
        }
    }

}