using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebHome.Models.Locale
{
    public class Naming
    {
        private Naming()
        {

        }

        public static readonly String[] DayOfWeek = new string[]
        {
            "週日",
            "週一",
            "週二",
            "週三",
            "週四",
            "週五",
            "週六",
        };

        public enum DataResultMode
        {
            Display = 0,
            Print = 1,
            Download = 2
        }

        public enum DocumentTypeDefinition
        {
            Professional = 1,
            Knowledge = 2,
            Rental = 3,
            Products = 4,
            Cooperation = 5,
            ContactUs = 6,
            Inspirational = 7,
            E_Invoice = 8,
            E_InvoiceCancellation = 9,
            E_Allowance = 10,
            E_AllowanceCancellation = 11,
            PaperInvoice = 12,
            PaperInvoiceCancellation = 13
        }

        public enum DocumentLevelDefinition
        {
            已刪除 = 0,
            正常 = 1,
            暫存 = 2,
            自主訓練 = 103,
            自由教練預約 = 1004,
            教練PI = 1005,
            體驗課程 = 1006,
            點數兌換課程 = 1007
        }

        public enum LessonPriceStatus
        {
            已刪除 = 0,
            一般課程 = 1,
            暫存 = 2,
            自主訓練 = 103,
            企業合作方案 = 1003,
            自由教練預約 = 1004,
            教練PI = 1005,
            體驗課程 = 1006,
            點數兌換課程 = 1007,
            團體學員課程 = 1008,
            在家訓練 = 1009,
            員工福利課程 = 1010,
        }

        public enum LessonPriceFeature
        {
            自主訓練 = 103,
            自由教練預約 = 1004,
            教練PI = 1005,
            體驗課程 = 1006,
            點數兌換課程 = 1007,
            舊會員續約 = 1008
        }

        public enum LessonSeriesStatus
        {
            已停用 = 0,
            已啟用 = 1,
            準備中 = 2,
        }

        public enum MemberStatusDefinition
        {
            ReadyToRegister = 1001,
            Deleted = 1002,
            Checked = 1003,
            Anonymous = 1004,
            Left    =   1005,
        }

        public enum MemberStatus
        {
            尚未註冊 = 1001,
            已停用 = 1002,
            已註冊 = 1003,
            訪客 = 1004,
            離職 = 1005,
        }

        public enum RoleID
        {
            Administrator = 1,
            Coach = 2,
            FreeAgent = 3,
            Learner = 4,
            Guest = 5,
            Accounting = 6,
            Officer = 7,
            Assistant = 8,
            Manager = 9,
            ViceManager = 10,
            Preliminary = 11,
            Servitor = 12,
            FES = 13,
            Dietitian = 14,
        }

        public static readonly String[] RoleName = new String[] {
            "",
            "系統管理員",
            "體能顧問",
            "自由教練",
            "學員",
            "訪客",
            "財務助理",
            "CEO",
            "行政助理",
            "FM",
            "AFM",
            "體驗學員",
            "工讀生",
            "FES",
            "營養師",
        };

        public static readonly int[] StaffRole = new int[] 
        {
            (int)RoleID.Administrator,
            (int)RoleID.Accounting,
            (int)RoleID.Assistant,
            (int)RoleID.Coach,
            (int)RoleID.Manager,
            (int)RoleID.Officer,
            (int)RoleID.Servitor,
            (int)RoleID.ViceManager,
            (int)RoleID.FES,
            (int)RoleID.Dietitian,
        };

        public enum LessonStatus
        {
            準備上課 = 100,
            上課中 = 101,
            課程結束 = 102
        }

        public enum QuestionType
        {
            問答題 = 200,
            單選題 = 201,
            多重選 = 202,
            是非題 = 203,
            單選其他 = 204,
            多重選其他 = 205
        }

        public enum FitnessAssessmentGroup
        {
            檢測體能 = 1,
        }

        public enum IncommingMessageStatus
        {
            未讀 = 3,
            已讀 = 4,
            拒答 = 5,
            教練代答 = 6,
        }

        public enum LessonQueryType
        {
            一般課程 = 0,
            自主訓練,
            教練PI,
            體驗課程,
            在家訓練,
        }

        public enum ProfessionalCategory
        {
            Preliminary = 1100,
            舊制 = 1101,
            新制 = 1102,
            Special = 1103,
            Senior = 1104,
            Junior = 1105,
            FM = 1106,
            AFM = 1107,
            FES = 1108,
        }

        public static readonly ProfessionalCategory[] ManagerialLevel = new ProfessionalCategory[]
        {
            ProfessionalCategory.Special,
            ProfessionalCategory.FM,
        };

        public enum ProfessionLevelDefinition
        {
            Preliminary = 0,
            FM_1st = 1,
            AFM_1st = 2,
            Level_5_1st = 14,
            Level_4_1st = 3,
            Level_3_1st = 4,
            Level_2_1st = 5,
            Level_1_1st = 6,
            FM_2nd = 7,
            AFM_2nd = 8,
            Level_5_2nd = 9,
            Level_4_2nd = 10,
            Level_3_2nd = 11,
            Level_2_2nd = 12,
            Level_1_2nd = 13
        }

        public enum CourseContractStatus
        {
            草稿 = 1201,
            待確認 = 1202,
            待簽名 = 1203,
            待審核 = 1204,
            已生效 = 1205,
            已履行 = 1206,
            已終止 = 1207,
            已轉讓 = 1208,
            已轉點 = 1209,
            已過期 = 1210,
        }

        public enum ContractQueryStatus
        {
            編輯中 = 1201,
            待確認 = 1202,
            待簽名 = 1203,
            待審核 = 1204,
            生效中 = 1205,
            已履行 = 1206,
            已終止 = 1207,
            已轉讓 = 1208,
            已轉點 = 1209,
            已過期 = 1210,
        }

        public enum ContractServiceStatus
        {
            待審核 = 1202,
            待簽名 = 1203,
            已生效 = 1205,
        }

        public enum OperationMode
        {
            快速終止 = 1,
        }



        public enum VoidPaymentStatus
        {
            退件 = 1201,
            待確認 = 1202,
            待簽名 = 1203,
            待審核 = 1204,
            已生效 = 1205,
        }

        public enum PaymentTransactionType
        {
            體能顧問費 = 1,
            自主訓練 = 2,
            食飲品 = 3,
            運動商品 = 4,
            合約轉讓沖銷 = 5,
            合約轉點沖銷 = 6,
            合約終止沖銷 = 7,
            合約轉點餘額 = 8,
            合約轉讓餘額 = 9,
            教育訓練 = 10,

        }

        public enum MerchandiseStatus
        {
            Discontinued = 0,
            OnSale = 1,
            SoldOut = 2
        }


        public enum InvoiceTypeDefinition
        {
            三聯式 = 1,
            二聯式 = 2,
            二聯式收銀機 = 3,
            特種稅額 = 4,
            電子計算機 = 5,
            三聯式收銀機 = 6,
            一般稅額計算之電子發票 = 7,
            特種稅額計算之電子發票 = 8,
        }

        public enum TrustType
        {
            B = 1,
            T,
            N,
            S,
            X,
            V
        }

        public enum TaxTypeDefinition
        {
            應稅 = 1,
            零稅率 = 2,
            免稅 = 3,
            特種稅率 = 4,
            混合稅率 = 9
        }

        public enum GeneralStatus
        {
            Failed = 0,
            Successful = 1
        }

        public enum QueryIntervalDefinition
        {
            自訂區間 = 0,
            今日 = 1,
            本週 = 2,
            本月 = 3,
            本季 = 4,
            近半年 = 5,
            近一年 = 6
        }

        public enum BonusAwardingAction
        {
            程式連結 = 1,
            手動 = 2
        }

        public enum BranchName
        {
            請選擇 = 0,
            南京 = 1,
            信義 = 2,
            忠孝 = 3,
            東門 = 4,
            璞真 = 5,
            甜蜜的家 = 6,
            其他 = 7,
            遠距 = 20,
        }

        public enum EnterpriseLessonTypeDefinition
        {
            體驗課程 = 1,
            體能顧問1對1課程,
            體能顧問1對2課程,
            自主訓練
        }

        public enum ContractServiceMode
        {
            ContractOnly = 1,
            ServiceOnly,
            All,
        }

        public enum ContractPayoffMode
        {
            Unpaid = 0,
            Paid = 1,
            All,
        }

        public enum QuestionnaireGroup
        {
            滿意度問卷調查_2017 = 7,
            身體心靈密碼 = 10,
        }

        public enum PowerAbilityLevel
        {
            初階 = 1,
            中階 = 2,
            高階 = 3,
        }

        public enum ContractVersion
        {
            Ver2019 = 20190801,
        }

        public enum Actor
        {
            ByOther = 0,
            BySelf = 1,
        }

        public enum LessonSettlementStatus
        {
            HalfAchievement = 1,
            FullAchievement = 2,
        }

        public enum LessonSelfTraining
        {
            自主訓練 = 1,
            在家訓練 = 2,
            體驗課程 = 3,
        }

        [Flags]
        public enum DataOperationMode
        {
            Create = 1,
            Read = 2,
            Update = 4,
            Delete = 8
        }

        public enum TrainingItemMode
        {
            ForTrainingItem = 0,
            ForBreakInterval = 1,
        }

        public enum CauseForEnding
        {
            合約到期轉新約 = 1,
            轉讓,
            私人原因,
            更改合約類型,
            學生簽約後不付款,
            教練誤開合約後終止,
            分期不付款,
            其他,
            所屬教練離職,
            新冠肺炎疫情,
        }

        public enum ProfessionalLevelCheck
        {
            PT_1 = 4,
            PT_2 = 5,
            PT_3 = 0,
            PT_4 = 1,
            PT_5 = 2,
            PT_6 = 3,

        }

        public enum MasterVersion
        {
            Ver2020 = 0,
        }

        public enum SessionTypeDefinition
        {
            PT = 1,
            PI = 2,
            ST = 3,
            TS = 4,
        }

    }
}