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
            return item.Birthday.HasValue ? (DateTime.Today.Year - item.Birthday.Value.Year).ToString()  : "--";
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

        public static int RemainedLessonCount(this RegisterLesson item,bool onlyAttended = false)
        {
            //return item.Lessons
            //        - item.GroupingLesson.LessonTime.Count(/*l=>l.LessonAttendance!= null*/);
            if (onlyAttended)
            {
                return item.Lessons - (item.AttendedLessons ?? 0)
                        - (item.RegisterGroupID.HasValue ? item.GroupingLesson.LessonTime.Count(l => l.LessonAttendance != null) : item.LessonTime.Count(l => l.LessonAttendance != null));
            }
            else
            {
                return item.Lessons - (item.AttendedLessons ?? 0)
                    - (item.RegisterGroupID.HasValue ? item.GroupingLesson.LessonTime.Count : item.LessonTime.Count);
            }
        }

        public static int AttendedLessonCount(this RegisterLesson item, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return (item.AttendedLessons ?? 0)
                        + (item.RegisterGroupID.HasValue 
                            ? item.GroupingLesson.LessonTime.Count(l => l.LessonAttendance != null) 
                            : item.LessonTime.Count(l => l.LessonAttendance != null));
            }
            else
            {
                return (item.AttendedLessons ?? 0)
                    + (item.RegisterGroupID.HasValue 
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

        public static int AttendedLessonCount(this RegisterLesson item,DateTime dateBefore, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return (item.AttendedLessons ?? 0)
                        + (item.RegisterGroupID.HasValue
                            ? item.GroupingLesson.LessonTime.Count(l => l.LessonAttendance != null && l.ClassTime<dateBefore)
                            : item.LessonTime.Count(l => l.LessonAttendance != null && l.ClassTime<dateBefore));
            }
            else
            {
                return (item.AttendedLessons ?? 0)
                    + (item.RegisterGroupID.HasValue
                        ? item.GroupingLesson.LessonTime.Count(l => l.ClassTime < dateBefore)
                        : item.LessonTime.Count(l => l.ClassTime < dateBefore));
            }
        }

        public static int RemainedLessonCount(this CourseContract item, bool onlyAttended = false)
        {
            return (item.Lessons ?? 0)
                    - item.AttendedLessonCount(onlyAttended);
        }

        public static int UnfinishedLessonCount(this CourseContract item)
        {
            return item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l => l.LessonAttendance == null));
        }

        public static int AttendedLessonCount(this CourseContract item, bool onlyAttended = false)
        {
            var items = item.CountableRegisterLesson();

            if (onlyAttended)
            {
                return items.Sum(r => (r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.LessonAttendance != null).Count());
            }
            else
            {
                return items.Sum(r => (r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Count());
            }

        }

        public static int AttendedLessonCount(this CourseContract item,DateTime dateBefore, bool onlyAttended = false)
        {
            var items = item.CountableRegisterLesson();

            if (onlyAttended)
            {
                return items.Sum(r => (r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.LessonAttendance != null && l.ClassTime < dateBefore).Count());
            }
            else
            {
                return items.Sum(r => (r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.ClassTime < dateBefore).Count());
            }
        }

        public static int TotalAttendedCost(this CourseContract item, DateTime dateBefore, bool onlyAttended = false)
        {
            var items = item.CountableRegisterLesson();

            if (onlyAttended)
            {
                return items.Sum(r => ((r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.LessonAttendance != null && l.ClassTime < dateBefore).Count()) 
                                    * r.LessonPriceType.ListPrice.Value);
            }
            else
            {
                return items.Sum(r => ((r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.ClassTime < dateBefore).Count())
                                    * r.LessonPriceType.ListPrice.Value);
            }
        }

        public static int TotalAttendedCost(this CourseContract item, DateTime dateFrom, DateTime dateBefore, bool onlyAttended = false)
        {
            var items = item.CountableRegisterLesson();

            if (onlyAttended)
            {
                return items.Sum(r => ((r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.LessonAttendance != null && l.ClassTime >= dateFrom && l.ClassTime < dateBefore).Count())
                                    * r.LessonPriceType.ListPrice.Value);
            }
            else
            {
                return items.Sum(r => ((r.AttendedLessons ?? 0) + r.GroupingLesson.LessonTime.Where(l => l.ClassTime >= dateFrom && l.ClassTime < dateBefore).Count())
                                    * r.LessonPriceType.ListPrice.Value);
            }
        }



        public static IEnumerable<LessonTime> AttendedLessonList(this CourseContract item, bool onlyAttended = false)
        {
            IEnumerable<LessonTime> items = item.CountableRegisterLesson()
                .SelectMany(c => c.GroupingLesson.LessonTime);

            if (onlyAttended)
            {
                items = items
                    .Where(l => l.LessonAttendance != null);
            }

            return items;
        }

        public static IEnumerable<RegisterLesson> CountableRegisterLesson(this CourseContract item)
        {

            if (item.ContractType == (int)CourseContractType.ContractTypeDefinition.CFA)
            {
                return item.RegisterLessonContract
                    .Select(c => c.RegisterLesson);
            }
            else
            {
                return item.RegisterLessonContract
                    .Select(c => c.RegisterLesson)
                    .Where(r => r.UID == item.OwnerID);
            }
        }


        public static String FullName(this UserProfile item, bool mask = false)
        {
            if(mask)
            {
                return item.Nickname == null ? item.RealName.MaskedName() : item.RealName.MaskedName() + "(" + item.Nickname + ")";
            }
            return item.Nickname == null ? item.RealName : item.RealName + "(" + item.Nickname + ")";
        }

        public static String FullNameHtml(this UserProfile profile,String css = null)
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
            return $"{item.CourseContractType.TypeName}({item.LessonPriceType.DurationInMinutes}分鐘)";
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


        public static String LessonLearner(this RegisterLesson lesson,String separator = "/")
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
            switch(status)
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
                        return "T.S";
                    case (int)Naming.LessonPriceStatus.點數兌換課程:
                        return item.RegisterLesson.LessonPriceType.SimpleDescription;

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
                        ? item.LowerLimit == 1
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
                            : insteadOfNull;
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
            if(item.CauseForEnding.HasValue)
            {
                sb.Append((Naming.CauseForEnding)item.CauseForEnding);
            }
            if (item.CourseContract.Remark != null)
            {
                sb.Append($"（{item.CourseContract.Remark}）");
            }

            return sb.ToString();
        }

    }

    public partial class UserProfile
    {
        public UserRole CurrentUserRole
        {
            get
            {
                return this.UserRole[0];
            }
        }

        public int? DailyQuestionID { get; set; }

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
        }
    }

    public partial class MonthlyCoachRevenueIndicator
    {
        public decimal AttendanceCount => (ActualCompleteLessonCount ?? 0)
                    + (ActualCompleteTSCount ?? 0)
                    + (ActualCompletePICount ?? 0M) / 2M;
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
            DietaryConsult= 4,
        }
    }

    public partial class Payment
    {
        public String PaymentFor => TransactionType == (int)Naming.PaymentTransactionType.自主訓練
                    ? TuitionInstallment != null
                        ? this.TuitionInstallment.IntuitionCharge.RegisterLesson.LessonPriceType.SimpleDescription
                        : "T.S/P.I"
                    : String.Concat(((Naming.PaymentTransactionType)this.TransactionType).ToString(),
                        this.TransactionType == (int)Naming.PaymentTransactionType.運動商品
                            || this.TransactionType == (int)Naming.PaymentTransactionType.食飲品
                            || this.TransactionType == (int)Naming.PaymentTransactionType.教育訓練
                        ? String.Join("/", this.PaymentTransaction.PaymentOrder.Select(p => p.MerchandiseWindow.ProductName))
                        : null);
    }

    public partial class LessonPriceType
    {
        public String SimpleDescription => Description?.Substring(Description.IndexOf('】') + 1);
        public bool IsPackagePrice => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.LessonPackage) == true;
        public bool IsDietaryConsult => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.DietaryConsult) == true;
        public bool IsDistanceLesson => this?.ObjectiveLessonPrice.Any(p => p.CatalogID == (int)ObjectiveLessonCatalog.CatalogDefinition.OnLine) == true;
    }

    public partial class RegisterLesson
    {
        public bool IsPaid => IntuitionCharge?.TuitionInstallment?
            .Any(t => t.Payment.VoidPayment == null || t.Payment.VoidPayment.Status != (int)Naming.CourseContractStatus.已生效) == true;
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
        }

        public static bool IsSuitableForVirtaulClass(ContractTypeDefinition? ct)
        {
            return ct == ContractTypeDefinition.CPA
                || ct == ContractTypeDefinition.CNA
                || ct == ContractTypeDefinition.CGA;
        }

    }

}