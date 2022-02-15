using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;

namespace WebHome.Models.ViewModel
{
    public class InputViewModel
    {
        public String Name { get; set; }
        public String Id { get; set; }
        public String Label { get; set; }
        public String Value { get; set; }
        public String PlaceHolder { get; set; }
        public String ErrorMessage { get; set; }
        public bool? IsValid { get; set; }
        public String InputType { get; set; }
        public Object DefaultValue { get; set; }
        public String ButtonStyle { get; set; }
        public String IconStyle { get; set; }
        public String Href { get; set; }
    }

    public class CourseContractViewModel : QueryViewModel
    {
        private DateTime? expiration;
        private DateTime? validFrom;
        private DateTime? contractDate;

        public int? ContractID { get; set; }
        public CourseContractType.ContractTypeDefinition? ContractType { get; set; } = CourseContractType.ContractTypeDefinition.CPA;
        public DateTime? ContractDate { get => contractDate?.CurrentLocalTime(); set => contractDate = value; }
        public String Subject { get; set; }
        public DateTime? ValidFrom { get => validFrom?.CurrentLocalTime(); set => validFrom = value; }
        public DateTime? Expiration { get => expiration?.CurrentLocalTime(); set => expiration = value; }
        public int? OwnerID { get; set; }
        public int? SequenceNo { get; set; } = 0;
        public int? Lessons { get; set; }
        public int? PriceID { get; set; }
        public String Remark { get; set; }
        public int? FitnessConsultant { get; set; }
        public int? Status { get; set; }
        public Naming.CourseContractStatus? FromStatus { get; set; }
        public int[] UID { get; set; }
        public int? BranchID { get; set; }
        public int? AgentID { get; set; }
        public String Reason { get; set; }
        public int? MonthExtension { get; set; }
        public int? RevisionID { get; set; }
        public bool? Drawback { get; set; }
        public int? SettlementPrice { get; set; }
        public bool? Renewal { get; set; }
        public bool? InstallmentPlan { get; set; }
        public int? Installments { get; set; }
        public int? DurationInMinutes { get; set; }
        public int? TotalCost { get; set; }
        public bool? Extension { get; set; }
        public bool? Booking { get; set; }
        public bool? Cancel { get; set; }
        public bool? Agree { get; set; }
        public String PriceName { get; set; }
        public int? InstallmentID { get; set; }
        public int? ManagerID { get; set; }
        public int? ViceManagerID { get; set; }
        public Naming.OperationMode? OperationMode { get; set; }
        public String[] PaymentMethod { get; set; }
        public Naming.ContractVersion? Version { get; set; }
        public Naming.Actor? BySelf { get; set; }
        public int? ProcessingFee { get; set; }
        public bool? UnpaidExpiring { get; set; }
        public bool? Unpaid { get; set; }
        public String Pdf { get; set; }
        public Naming.CauseForEnding? CauseForEnding { get; set; }
        public int? MemberID { get; set; }
        public bool? PartialEffectiive { get; set; }
        public bool? SignOnline { get; set; }
        public int? SupervisorID { get; set; }
    }

    public class CourseContractQueryViewModel : CourseContractViewModel
    {
        private DateTime? payoffDueTo;
        private DateTime? payoffDueFrom;
        private DateTime? effectiveDateTo;
        private DateTime? effectiveDateFrom;
        private DateTime? expirationTo;
        private DateTime? expirationFrom;
        private DateTime? contractDateTo;
        private DateTime? contractDateFrom;

        public CourseContractQueryViewModel()
        {
            //ContractDateFrom = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            //ContractDateTo = ContractDateFrom.Value.AddMonths(1).AddDays(-1);
        }
        public String RealName { get; set; }
        public DateTime? ContractDateFrom { get => contractDateFrom?.CurrentLocalTime(); set => contractDateFrom = value; }
        public DateTime? ContractDateTo { get => contractDateTo?.CurrentLocalTime(); set => contractDateTo = value; }
        public String ContractNo { get; set; }
        public bool? IsExpired { get; set; }
        public Naming.ContractServiceMode? ContractQueryMode { get; set; }
        public DateTime? ExpirationFrom { get => expirationFrom?.CurrentLocalTime(); set => expirationFrom = value; }
        public DateTime? ExpirationTo { get => expirationTo?.CurrentLocalTime(); set => expirationTo = value; }
        public DateTime? EffectiveDateFrom { get => effectiveDateFrom?.CurrentLocalTime(); set => effectiveDateFrom = value; }
        public DateTime? EffectiveDateTo { get => effectiveDateTo?.CurrentLocalTime(); set => effectiveDateTo = value; }
        public Naming.ContractPayoffMode? PayoffMode { get; set; }
        public DateTime? PayoffDueFrom { get => payoffDueFrom?.CurrentLocalTime(); set => payoffDueFrom = value; }
        public DateTime? PayoffDueTo { get => payoffDueTo?.CurrentLocalTime(); set => payoffDueTo = value; }
        public int? OfficerID { get; set; }
        public bool? ByCustom { get; set; }
        public bool? IncludeTotalUnpaid { get; set; }
        public int? AlarmCount { get; set; }
        public bool? BypassCondition { get; set; }
    }


    public class ContractMemberViewModel : LearnerViewModel
    {
        public int? OwnerID { get; set; }
        public int? ContractType { get; set; }
        public bool? ProfileOnly { get; set; }
        public bool? HasReset { get; set; }
    }

    public class UserSignatureViewModel : QueryViewModel
    {
        public int? UID { get; set; }
        public String Signature { get; set; }
        public int? SignatureCount { get; set; }
    }


    public class CourseContractSignatureViewModel : UserSignatureViewModel
    {
        public int? ContractID { get; set; }
        public String SignatureName { get; set; }
    }

    public class LessonPriceQueryViewModel : LessonPriceViewModel
    {
        public LessonPriceQueryViewModel()
        {
            Status = (int)Naming.LessonSeriesStatus.已停用;
        }
        public int? BranchID { get; set; }
        public int? Year { get; set; } = DateTime.Today.Year;
        public int? DurationInMinutes { get; set; } = 60;
        public int?[] ListPriceSeries { get; set; }
        public int? SeriesID { get; set; }
        public int?[] PriceSeriesID { get; set; }
        public bool?[] ReadOnly { get; set; }
    }

    public class LearnerQueryViewModel : LearnerViewModel
    {
        public int? CoachID { get; set; }
        public int?[] LessonID { get; set; }
        public int? BirthIncomingDays { get; set; } = 14;
        public bool? IncludeTrial { get; set; }
        public DateTime? BirthDate { get; set; }
    }

    public class PaymentViewModel : InvoiceViewModel
    {
        public int? PaymentID { get; set; }
        //public int? PayoffAmount { get; set; }

        DateTime? _payoffDate;
        public DateTime? PayoffDate
        {
            get
            {
                if (!_payoffDate.HasValue)
                {
                    _payoffDate = DateTime.Today;
                }
                return _payoffDate?.CurrentLocalTime();
            }
            set
            {
                _payoffDate = value;
            }
        }
        public int? Status { get; set; }
        public int? HandlerID { get; set; }
        public string PaymentType { get; set; } //= "現金";
        public int? InvoiceID { get; set; }
        public int? TransactionType { get; set; }
        public String ContractNo { get; set; }
        //public Naming.InvoiceTypeDefinition? InvoiceType { get; set; } = Naming.InvoiceTypeDefinition.二聯式;
        //public string BuyerReceiptNo { get; set; }
        public string InvoiceNo { get; set; }
        //public string Remark { get; set; }
        //public int? SellerID { get; set; }
        public int? RegisterID { get; set; }
        public int? ProductID { get; set; }
        public int? ProductCount { get; set; } = 1;
        public int?[] VoidID { get; set; }
        public bool? Drawback { get; set; }
        public int? ShareAmount { get; set; }
        public int? CoachID { get; set; }
        public int? ContractID { get; set; }
        public bool? InvoiceNow { get; set; }
        public int?[] ProductItemID { get; set; }
        public bool? MyCarrier { get; set; }
    }

    public class PaymentQueryViewModel : PaymentViewModel
    {
        private DateTime? cancelDateTo;
        private DateTime? cancelDateFrom;
        private DateTime? allowanceDateTo;
        private DateTime? allowanceDateFrom;
        private DateTime? payoffDateTo;
        private DateTime? payoffDateFrom;

        public PaymentQueryViewModel() : base()
        {
            InvoiceType = null;
        }

        public string UserName { get; set; }
        public int? BranchID { get; set; }
        public bool? IsCancelled { get; set; }
        public DateTime? PayoffDateFrom { get => payoffDateFrom?.CurrentLocalTime(); set => payoffDateFrom = value; }
        public DateTime? PayoffDateTo { get => payoffDateTo?.CurrentLocalTime(); set => payoffDateTo = value; }
        public bool? Entrusting { get; set; }
        public DateTime? SettlementDate
        {
            get => PayoffDateFrom;
            set => PayoffDateFrom = value;
        }
        public bool? BypassCondition { get; set; }
        public Naming.PaymentTransactionType?[] CompoundType { get; set; }
        public bool? HasCancellation
        {
            get;
            set;
        }
        public bool? HasAllowance { get; set; }
        public bool? HasInvoicePrinted { get; set; }
        public int? ShareFor { get; set; }
        public bool? IncomeOnly { get; set; }
        public bool? HasShare { get; set; }
        public int? RelatedID { get; set; }
        public int? TransactionID { get; set; }
        public DateTime? AllowanceDateFrom { get => allowanceDateFrom?.CurrentLocalTime(); set => allowanceDateFrom = value; }
        public DateTime? AllowanceDateTo { get => allowanceDateTo?.CurrentLocalTime(); set => allowanceDateTo = value; }
        public DateTime? CancelDateFrom { get => cancelDateFrom?.CurrentLocalTime(); set => cancelDateFrom = value; }
        public DateTime? CancelDateTo { get => cancelDateTo?.CurrentLocalTime(); set => cancelDateTo = value; }

    }

    public class PayoffViewModel : PaymentViewModel
    {
        public String mid { get; set; }
        public String tid { get; set; }
        public String oid { get; set; }
        public String pan { get; set; }
        public int? transCode { get; set; }
        public int? transMode { get; set; }
        public String transDate { get; set; }
        public String transTime { get; set; }
        public String transAmt { get; set; }
        public String approveCode { get; set; }
        public String responseCode { get; set; }
        public String responseMsg { get; set; }
        public String installmentType { get; set; }
        public int? installment { get; set; }
        public int? firstAmt { get; set; }
        public int? eachAmt { get; set; }
        public int? fee { get; set; }
        public String redeemType { get; set; }
        public int? redeemUsed { get; set; }
        public int? redeemBalance { get; set; }
        public int? creditAmt { get; set; }
        public String secureStatus { get; set; }
    }

    public class AchievementQueryViewModel : QueryViewModel
    {
        private DateTime? classTime;
        private DateTime? achievementDateTo;
        private DateTime? achievementDateFrom;

        public AchievementQueryViewModel()
        {
        }
        public int? BranchID { get; set; }
        public int? CoachID { get; set; }
        public DateTime? AchievementDateFrom { get => achievementDateFrom?.CurrentLocalTime(); set => achievementDateFrom = value; }
        public DateTime? AchievementDateTo { get => achievementDateTo?.CurrentLocalTime(); set => achievementDateTo = value; }
        public String AchievementYearMonthFrom { get; set; }
        public String AchievementYearMonthTo { get; set; }
        public int?[] ByCoachID { get; set; }
        public DateTime? ClassTime { get => classTime?.CurrentLocalTime(); set => classTime = value; }
        public Naming.LessonQueryType? QueryType { get; set; }
        public Naming.QueryIntervalDefinition? QueryInterval { get; set; }
        public bool? BypassCondition { get; set; }
        public bool? DetailsOnly { get; set; }
        public bool? IgnoreAttendance { get; set; }
    }

    public class CoachBonusViewModel : QueryViewModel
    {
        public int? CoachID { get; set; }
        public int? SettlementID { get; set; }
        public int? ManagerBonus { get; set; }
        public int? SpecialBonus { get; set; }
        public int? UID
        {
            get => CoachID;
            set => CoachID = value;
        }
        public int? SalaryID { get; set; }
    }

    public class MonthlyBonusViewModel : AchievementQueryViewModel
    {
        public int? ManagerBonus { get; set; }
        public int? SpecialBonus { get; set; }
    }

    public class QuestionnaireQueryViewModel : AchievementQueryViewModel
    {
        public QuestionnaireQueryViewModel() : base()
        {
            AchievementDateFrom = null;
        }
        public String UserName { get; set; }
        public int? Status { get; set; }
    }

    public class TrustQueryViewModel : QueryViewModel
    {
        private DateTime? trustDateTo;
        private DateTime? trustDateFrom;

        public TrustQueryViewModel()
        {
        }
        public int? BranchID { get; set; }
        public String TrustType { get; set; }
        public DateTime? TrustDateFrom { get => trustDateFrom?.CurrentLocalTime(); set => trustDateFrom = value; }
        public DateTime? TrustDateTo { get => trustDateTo?.CurrentLocalTime(); set => trustDateTo = value; }
        public String TrustYearMonth { get; set; }
        public String ContractNo { get; set; }

    }

    public class EnterpriseContractViewModel : QueryViewModel
    {
        private DateTime? expiration;
        private DateTime? validFrom;
        private DateTime? contractDate;

        public int? ContractID { get; set; }
        public DateTime? ContractDate { get => contractDate?.CurrentLocalTime(); set => contractDate = value; }
        public String Subject { get; set; }
        public String Remark { get; set; }
        public int[] UID { get; set; }

        public int? CompanyID { get; set; }
        public String CompanyName { get; set; }
        public String ReceiptNo { get; set; }
        public int?[] EnterprisePriceID { get; set; }
        public int?[] EnterpriseLessons { get; set; }
        public int?[] EnterpriseDurationInMinutes { get; set; }
        public int?[] EnterpriseListPrice { get; set; }
        public int? TotalCost { get; set; }
        public int? BranchID { get; set; }
        public DateTime? ValidFrom { get => validFrom?.CurrentLocalTime(); set => validFrom = value; }
        public DateTime? Expiration { get => expiration?.CurrentLocalTime(); set => expiration = value; }
    }

    public class EnterpriseProgramItemViewModel
    {
        public int? PriceID { get; set; }
        public int? Lessons { get; set; }
        public int? ContractType { get; set; }
        public int? DurationInMinutes { get; set; }
        public int? ListPrice { get; set; }
        public String Description { get; set; }
    }

    public class EnterpriseGroupMemberViewModel
    {
        public int? ContractID { get; set; }
        public int? GroupUID { get; set; }
        public int? UID { get; set; }
    }

    public class InvoiceNoViewModel : QueryViewModel
    {
        public int? BranchID { get; set; }
        public short? Year { get; set; }
        public short? PeriodNo { get; set; }
        public int? IntervalID { get; set; }
        public String TrackCode { get; set; }
        public int? StartNo { get; set; }
        public int? EndNo { get; set; }
        public int?[] BookletCount { get; set; }
        public int?[] BookletBranchID { get; set; }
        public int? GroupID { get; set; }


    }

    public class InvoiceQueryViewModel : InvoiceNoViewModel
    {
        private DateTime? dateTo;
        private DateTime? dateFrom;

        public int? HandlerID { get; set; }
        public bool? IsPrinted { get; set; }
        public DateTime? DateFrom { get => dateFrom?.CurrentLocalTime(); set => dateFrom = value; }
        public DateTime? DateTo { get => dateTo?.CurrentLocalTime(); set => dateTo = value; }
        public String InvoiceNo { get; set; }
        public int?[] InvoiceID { get; set; }
        public int? UID { get; set; }
        public int? DispatchStatus { get; set; }
        public int?[] AllowanceID { get; set; }
        public Naming.DocumentTypeDefinition? DocType { get; set; }
        public int? InvoiceType { get; set; }
        public int? Month { get; set; }
        public int? TrackPeriodNo => (DateFrom?.Month + 1) / 2;
        public int? TrackID { get; set; }
    }

    public class AwardQueryViewModel : LoginViewModel
    {
        private DateTime? dateTo;
        private DateTime? dateFrom;

        public string UserName { get; set; }
        public int? ActorID { get; set; }
        public int? ItemID { get; set; }
        public DateTime? DateFrom { get => dateFrom?.CurrentLocalTime(); set => dateFrom = value; }
        public DateTime? DateTo { get => dateTo?.CurrentLocalTime(); set => dateTo = value; }
        public String PointRange { get; set; }
        public int? Lower { get; set; }
        public int? Upper { get; set; }
        public String WriteoffCode { get; set; }
    }

    public class ExerciseGameViewModel
    {
        private DateTime? testDate;

        public int? UID { get; set; }
        public int? Status { get; set; }
        public decimal? Score { get; set; }
        public DateTime? TestDate { get => testDate?.CurrentLocalTime(); set => testDate = value; }
        public int? ExerciseID { get; set; }
        public int? TestID { get; set; }
    }

    public class DailyQuestionViewModel : DailyQuestionQueryViewModel
    {
        public int? SuggestionID { get; set; }
        public String Question { get; set; }
    }

    public class PromotionQueryViewModel
    {

    }

    public class PromotionViewModel : QueryViewModel
    {
        private DateTime? endDate;
        private DateTime? startDate;

        public int? GroupID { get; set; }
        public String GroupName { get; set; }
        public DateTime? StartDate { get => startDate?.CurrentLocalTime(); set => startDate = value; }
        public DateTime? EndDate { get => endDate?.CurrentLocalTime(); set => endDate = value; }
        public int? QuestionID { get; set; }
        public String Question { get; set; }
        public int? BonusPoint { get; set; }
        public Naming.LessonSeriesStatus? Status { get; set; }
        public Naming.BonusAwardingAction? AwardingAction { get; set; }
        public DateTime? CreationTime { get; set; }
    }

    public class PromotionParticipantViewModel : PromotionViewModel
    {
        public int? TaskID { get; set; }
        public String UserName { get; set; }
        public int? UID { get; set; }
    }

    public class ContractSettlementViewModel
    {
        private DateTime? settlementFrom;
        private DateTime? settlementDate;

        public DateTime? SettlementDate { get => settlementDate?.CurrentLocalTime(); set => settlementDate = value; }
        public DateTime? SettlementFrom { get => settlementFrom?.CurrentLocalTime(); set => settlementFrom = value; }
        public DateTime? SettlementTo
        {
            get => SettlementDate;
            set => SettlementDate = value;
        }
        public bool? Effective { get; set; }

    }

    public class BlogArticleQueryViewModel : QueryViewModel
    {
        public int? CategoryID { get; set; }
        public int? DocID { get; set; }
        public new int? id
        {
            get => DocID;
            set => DocID = value;
        }
        public int? AuthorID { get; set; }
        public DateTime? DocDate { get; set; }
        public String Subtitle { get; set; }
        public int?[] TagID { get; set; }

    }

    public class AttachmentQueryViewModel : QueryViewModel
    {
        public int? AttachmentID { get; set; }
        public new int? id
        {
            get => AttachmentID;
            set => AttachmentID = value;
        }

    }

    public class MonthlyIndicatorQueryViewModel : LessonQueryViewModel
    {
        public int? PeriodID { get; set; }
        public int? Year { get; set; }
        public int? Month { get; set; }
        public int? BranchID { get; set; }
        public int? ChartType { get; set; }
        public Naming.SessionTypeDefinition[] SessionType { get; set; }

    }

    public class MonthlySelectorViewModel
    {
        public int? RecentCount { get; set; }
    }

    public class MonthlyCoachRevenueIndicatorQueryViewModel : MonthlyIndicatorQueryViewModel
    {
        public int? AchievementGoal { get; set; }
        public int? CompleteLessonsGoal { get; set; }
        public int? AverageLessonPrice { get; set; }
        public int? BRCount { get; set; }
        public String RiskPrediction { get; set; }
        public String Strategy { get; set; }
        public String Comment { get; set; }

        public static readonly String[] __SessionName =
        {
            "",
            "P.T",
            "P.I",
            "S.T",
            "T.S",
        };
    }

    public class LessonOverviewQueryViewModel : MonthlyIndicatorQueryViewModel
    {
        public int? LessonID { get; set; }
        public bool? CoachAttended { get; set; }
        public bool? LearnerCommitted { get; set; }
        public Naming.LessonQueryType? LessonType { get; set; }
        public bool? ByManager { get; set; }
        public Naming.LessonPriceStatus[] CombinedStatus { get; set; }

    }

    public class ServingCoachQueryViewModel : QueryViewModel
    {
        public int? Allotment { get; set; }
        public int? AllotmentCoach { get; set; }
        public bool? SelectAll { get; set; }
        public String SelectablePartial { get; set; }
        public int? WorkPlace { get; set; }
    }

}