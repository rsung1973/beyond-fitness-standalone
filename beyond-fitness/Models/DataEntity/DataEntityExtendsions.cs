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
            if (onlyAttended)
            {
                return item.RegisterLessonContract.Count > 0
                        ? item.CourseContractType.ContractCode == "CFA"
                            ? (item.Lessons ?? 0)
                                - item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l => l.LessonAttendance != null))
                                - (item.RegisterLessonContract.Sum(c => c.RegisterLesson.AttendedLessons) ?? 0)
                            : item.RegisterLessonContract.First().RegisterLesson.RemainedLessonCount(onlyAttended)
                        : item.Lessons.Value;
            }
            else
            {
                return item.RegisterLessonContract.Count > 0
                        ? item.CourseContractType.ContractCode == "CFA"
                            ? (item.Lessons ?? 0)
                                - item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count())
                                - (item.RegisterLessonContract.Sum(c => c.RegisterLesson.AttendedLessons) ?? 0)
                            : item.RegisterLessonContract.First().RegisterLesson.RemainedLessonCount()
                        : item.Lessons.Value;
            }
        }

        public static int UnfinishedLessonCount(this CourseContract item)
        {
            return item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l => l.LessonAttendance == null));
        }

        public static int AttendedLessonCount(this CourseContract item, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return item.ContractType == (int)Naming.ContractTypeDefinition.CFA
                            ? item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l => l.LessonAttendance != null))
                                + (item.RegisterLessonContract.Sum(c => c.RegisterLesson.AttendedLessons) ?? 0)
                            : item.RegisterLessonContract.First()
                                .RegisterLesson.AttendedLessonCount(onlyAttended);
            }
            else
            {
                return item.ContractType == (int)Naming.ContractTypeDefinition.CFA
                            ? item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count())
                                + (item.RegisterLessonContract.Sum(c => c.RegisterLesson.AttendedLessons) ?? 0)
                            : item.RegisterLessonContract.First()
                                .RegisterLesson.AttendedLessonCount();
            }
        }

        public static int AttendedLessonCount(this CourseContract item,DateTime dateBefore, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return item.ContractType == (int)Naming.ContractTypeDefinition.CFA
                            ? item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l => l.LessonAttendance != null && l.ClassTime < dateBefore))
                                + (item.RegisterLessonContract.Sum(c => c.RegisterLesson.AttendedLessons) ?? 0)
                            : item.RegisterLessonContract.First()
                                .RegisterLesson.AttendedLessonCount(dateBefore, onlyAttended);
            }
            else
            {
                return item.ContractType == (int)Naming.ContractTypeDefinition.CFA
                            ? item.RegisterLessonContract.Sum(c => c.RegisterLesson.LessonTime.Count(l=> l.ClassTime < dateBefore))
                                + (item.RegisterLessonContract.Sum(c => c.RegisterLesson.AttendedLessons) ?? 0)
                            : item.RegisterLessonContract.First()
                                .RegisterLesson.AttendedLessonCount(dateBefore);
            }
        }

        public static IEnumerable<LessonTime> AttendedLessonList(this CourseContract item, bool onlyAttended = false)
        {
            if (onlyAttended)
            {
                return item.ContractType == (int)Naming.ContractTypeDefinition.CFA
                            ? item.RegisterLessonContract.SelectMany(c => c.RegisterLesson.LessonTime.Where(l => l.LessonAttendance != null))
                            : item.RegisterLessonContract.First()
                                .RegisterLesson.AttendedLessonList(onlyAttended);
            }
            else
            {
                return item.ContractType == (int)Naming.ContractTypeDefinition.CFA
                            ? item.RegisterLessonContract.SelectMany(c => c.RegisterLesson.LessonTime)
                            : item.RegisterLessonContract.First()
                                .RegisterLesson.AttendedLessonList();
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

        public static String MaskedName(this String name)
        {
            if (name == null || name.Length < 2)
                return name;
            StringBuilder sb = new StringBuilder(name);
            sb[1] = '○';
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


        public static int? TotalPaidAmount(this CourseContract contract)
        {
            return contract.ContractPayment
                .Select(c => c.Payment)
                .Where(p => p.TransactionType == (int)Naming.PaymentTransactionType.體能顧問費
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉讓餘額
                    || p.TransactionType == (int)Naming.PaymentTransactionType.合約轉點餘額)
                .Where(p => p.VoidPayment == null || p.AllowanceID.HasValue)
                .Sum(c => c.PayoffAmount);
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
            return item.RegisterLesson.RegisterLessonEnterprise == null
                    ? item.RegisterLesson.LessonPriceType.Status.LessonTypeStatus()
                    : item.RegisterLesson.RegisterLessonEnterprise.EnterpriseCourseContent.EnterpriseLessonType.Status.LessonTypeStatus() + "(企)";
        }


        public static decimal? EffectiveAchievement(this Payment item)
        {
            if (item.VoidPayment != null)
            {
                return 0;
            }
            else if (item.AllowanceID.HasValue)
            {
                return item.PayoffAmount - item.InvoiceAllowance.TotalAmount - item.InvoiceAllowance.TaxAmount;
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

        public String ReportInputError { get; set; } = WebHome.Properties.Settings.Default.ReportInputError;

    }

    public class CourseContractPayment
    {
        public CourseContract Contract { get; set; }
        public decimal? TotalPaidAmount { get; set; }
    }
}