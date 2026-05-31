using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading;
using System.Web;
using CommonLib.Utility;
using WebHome.Models.DataEntity;
using WebHome.Models.Locale;
using WebHome.Models.ViewModel;

using CommonLib.DataAccess;
using WebHome.Helper.BusinessOperation;
using Newtonsoft.Json;
using WebHome.Properties;

namespace WebHome.Helper
{
    public static class PerformanceSettlementExtensions
    {
        static readonly int[] ManagerAttendanceIndex = { 76, 71, 66, 61, 56, 51, 46, 41, 36, 31, 26, 21, 16, 11 };
        static readonly int[] ManagerAttendanceBonus = { 42500, 40500, 37000, 34000, 31000, 27500, 24000, 21000, 18000, 15000, 12000, 9000, 6000, 3000 };
        static readonly int[] ViceManagerAttendanceIndex = { 91, 86, 81, 76, 71, 66, 61, 56, 51, 46, 41, 36, 31, 26, 21, 16, 11 };
        static readonly int[] ViceManagerAttendanceBonus = { 47000, 44500, 42000, 39500, 37000, 34500, 32000, 29500, 27000, 24500, 22000, 19500, 17000, 14500, 12000, 9500, 7000 };
        static readonly int[] EducatorAttendanceIndex = { 91, 86, 81, 76, 71, 66, 61, 56, 51, 46, 41, 36, 31, 26, 21, 16, 11 };
        static readonly int[] EducatorAttendanceBonus = { 47500, 45000, 42500, 40000, 37000, 34000, 31500, 29000, 26500, 24000, 21500, 19000, 16500, 14000, 11500, 9000, 6500 };

        static readonly int[] ManagerManagementBonusIndex = { 130, 120, 110, 100 };
        static readonly decimal[] ManagerManagementBonusRatio = { 0.03M, 0.02M, 0.015M, 0.01M };
        static readonly decimal[] ViceManagerManagementBonusRatio = { 0.01M, 0.008M, 0.006M, 0.005M };
        static readonly decimal[] ApprenticeManagementBonusRatio = { 0.005M, 0.004M, 0.003M, 0.002M };
        static readonly Dictionary<int, int[][]> DietitianBonusIndex = new Dictionary<int, int[][]>
        {
            {
                37,
                new[]
                {
                    new int[] { 36, 250 },
                    new int[] { 16, 200 },
                }
            },
            {
                38,
                new[]
                {
                    new int[] { 46, 350 },
                    new int[] { 36, 300 },
                    new int[] { 16, 250 },
                }
            },
            {
                42,
                new[]
                {
                    new int[] { 51, 400 },
                    new int[] { 36, 350 },
                    new int[] { 16, 300 },
                }
            },
            {
                43,
                new[]
                {
                    new int[] { 56, 550 },
                    new int[] { 36, 400 },
                    new int[] { 16, 350 },
                }
            },
            {
                44,
                new[]
                {
                    new int[] { 61, 600 },
                    new int[] { 36, 450 },
                    new int[] { 16, 400 },
                }
            },
        };

        public static void ExecuteLessonPerformanceSettlement(this GenericManager<BFDataContext> models, DateTime startDate, DateTime endExclusiveDate, String forRole = null)
        {
            var settlement = models.GetTable<Settlement>().Where(s => startDate <= s.SettlementDate && endExclusiveDate > s.SettlementDate).FirstOrDefault();
            if (settlement == null)
                return;

            //models.ExecuteCommand(@"UPDATE Report.MonthlySalaryDetails
            //    SET SettlementID = {0} where SettlementID is null", settlement.SettlementID);

            forRole = forRole?.GetEfficientString()?.ToLower();

            LessonTimeAchievementHelper helper = new LessonTimeAchievementHelper(models)
            {
                LessonItems = models.GetTable<V_Tuition>().Where(l => l.ClassTime >= settlement.StartDate && l.ClassTime < settlement.EndExclusiveDate)
            };

            foreach (var item in helper.SettlementFullAchievement)
            {
                models.ExecuteCommand("update LessonTimeSettlement set SettlementStatus = {0},SettlementID = {1} where LessonID={2}", (int)Naming.LessonSettlementStatus.FullAchievement, settlement.SettlementID, item.LessonID);
            }

            foreach (var item in helper.SettlementHalfAchievement)
            {
                models.ExecuteCommand("update LessonTimeSettlement set SettlementStatus = {0},SettlementID = {1} where LessonID={2}", (int)Naming.LessonSettlementStatus.HalfAchievement, settlement.SettlementID, item.LessonID);
            }

            foreach (var item in helper.SettlementVainAchievement)
            {
                models.ExecuteCommand("update LessonTimeSettlement set SettlementID = {0} where LessonID={1}", settlement.SettlementID, item.LessonID);
            }

            var coachItems = models.PromptEffectiveCoach();

            var salaryTable = models.GetTable<CoachMonthlySalary>();
            var countableItems = helper.PerformanceCountableLesson;
            var PTItems = helper.PTSession;
            //var PTItemsAchievement = helper.PTSessionForAchievement;

            var paymentItems = models.GetTable<Payment>().Where(p => p.PayoffDate >= settlement.StartDate && p.PayoffDate < settlement.EndExclusiveDate);
            //.FilterByEffective();
            IQueryable<TuitionAchievement> achievementItems = paymentItems.GetPaymentAchievement(models);

            var voidPayment = models.GetTable<VoidPayment>().Where(p => p.VoidDate >= settlement.StartDate && p.VoidDate < settlement.EndExclusiveDate)
                                .Join(models.GetTable<Payment>().Where(p => p.AllowanceID.HasValue), v => v.VoidID, p => p.PaymentID, (v, p) => p);

            // JSON 設定檔是整個結算週期共用的規則，載入一次即可，避免每位教練重複讀檔。
            var bonusConfigSR = LoadBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "BonusConfig_SR.json"));
            var bonusConfigCoach = LoadBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "BonusConfig_Coach.json"));
            var bonusConfigCooperation = LoadBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "BonusConfig_Cooperation.json"));
            var groupXConfig = LoadGroupXBonusConfig(Path.Combine(AppSettings.AppRoot, "App_Data", "GroupXBonusConfig.json"));

            bool ShouldProcessRole(String role)
            {
                return forRole == role;
            }

            foreach (var coach in coachItems)
            {
                // 先建立或更新薪資主檔，後續各角色公式只負責填入獎金欄位。
                var lessonItem = countableItems.Where(l => l.AttendingCoach == coach.CoachID).FirstOrDefault();
                var salary = salaryTable.Where(s => s.CoachID == coach.CoachID && s.SettlementID == settlement.SettlementID).FirstOrDefault();
                if (salary == null)
                {
                    salary = new CoachMonthlySalary
                    {
                        CoachID = coach.CoachID,
                        SettlementID = settlement.SettlementID,
                        Year = settlement.Year,
                        AvgFlag = true,
                    };
                    salaryTable.InsertOnSubmit(salary);
                }

                if (coach.CoachWorkplace.Count == 1)
                {
                    salary.WorkPlace = coach.CoachWorkplace.First().BranchID;
                }

                if (lessonItem != null)
                {
                    salary.LevelID = lessonItem.ProfessionalLevelID;
                    //salary.GradeIndex = lessonItem.MarkedGradeIndex ?? 0;
                }
                else
                {
                    salary.LevelID = coach.LevelID ?? 0;
                    //salary.GradeIndex = coach.ProfessionalLevel?.GradeIndex ?? 0;
                }

                var performanceItems = achievementItems.Where(t => t.CoachID == coach.CoachID);
                salary.PerformanceAchievement = performanceItems.Sum(t => t.ShareAmount) ?? 0;

                var voidTuition = voidPayment
                    .Join(models.GetTable<TuitionAchievement>()
                            .Where(t => t.CoachID == coach.CoachID),
                        p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                salary.VoidShare = voidTuition.Sum(t => t.VoidShare) ?? 0;

                models.SubmitChanges();

                void CalcGeneralAchievement()
                {
                    // 共用課程統計：各角色獎金公式都依賴 PT、TS、PI、GroupX 與合作課數。
                    var attendingLessons = countableItems.Where(l => l.AttendingCoach == coach.CoachID);
                    foreach (var g in attendingLessons.GroupBy(l => l.BranchID))
                    {
                        var branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == g.Key).FirstOrDefault();
                        if (branchBonus == null)
                        {
                            branchBonus = new CoachBranchMonthlyBonus
                            {
                                CoachMonthlySalary = salary,
                                BranchID = g.Key.Value
                            };
                            salary.CoachBranchMonthlyBonus.Add(branchBonus);
                        }

                        LessonTimeAchievementHelper branchHelper = new LessonTimeAchievementHelper(models)
                        {
                            LessonItems = attendingLessons.Where(l => l.BranchID == g.Key)
                        };

                        branchBonus.AchievementAttendanceCount = branchHelper.LessonItems.Count()
                                - branchHelper.SettlementPILesson.Count() / 2m
                                - branchHelper.TSSRSession.Count() / 2m;

                        branchBonus.Tuition = branchHelper.LessonItems.CalcTuition(models);

                        branchBonus.AttendanceBonus = branchHelper.LessonItems.CalcTuitionShare(models);

                        models.SubmitChanges();
                    }

                    salary.PTAttendanceCount = PTItems.Where(v => v.AttendingCoach == coach.CoachID).Count();
                    salary.PTAverageUnitPrice = salary.PTAttendanceCount > 0
                            ? (int?)(PTItems.Where(v => v.AttendingCoach == coach.CoachID).CalcTuition(models) / (decimal?)salary.PTAttendanceCount + 0.5M)
                            : 0;

                    var tuitionCoach = helper.PTTuitionCoach
                                        .Where(t => t.AttendingCoach != t.PrimaryCoach)
                                        .Where(t => t.PrimaryCoach == coach.CoachID);

                    salary.AttendedByOther = tuitionCoach.Count();
                    salary.AttendedShare = 0;
                    if (salary.AttendedByOther > 0)
                    {
                        var lessonAchievement = tuitionCoach.Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0M;
                        lessonAchievement += (tuitionCoach.Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0M);
                        salary.AttendedByOtherAvgPrice = (int)(lessonAchievement / salary.AttendedByOther + 0.5M);
                        //var ratio = salary.AttendedByOther > 29 ? 5 : 4;
                        //salary.AttendedShare = (Math.Max(salary.AttendedByOther.Value - (10 - Math.Min(salary.PTAttendanceCount.Value, 10)), 0) * salary.AttendedByOtherAvgPrice * ratio + 50) / 100;
                    }
                    else
                    {
                        salary.AttendedByOtherAvgPrice = 0;
                    }

                    salary.JobTenureInDays = models.PromptEmploymentDurationInDays(coach.CoachID);
                    var TS_Items = helper.LessonItems
                            .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程)
                            .Where(v => v.AttendingCoach == coach.CoachID);
                    salary.TSAttendanceCount = TS_Items.Count();
                    salary.TSBonus = TS_Items.Sum(v => v.CoachPayoff) ?? 0;

                    var groupX = helper.GroupXItems
                            .Where(v => v.AttendingCoach == coach.CoachID)
                            .GroupBy(t => t.ClassTime).ToList();
                    salary.GroupXAttendanceCount = groupX.Count();
                    salary.GroupXBonus = groupX.Any()
                        ? groupX.Sum(g => CalculateGroupXBonus(1, g.Count(), groupXConfig))
                        : 0;

                    var PI_Items = helper.LessonItems
                        .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.自主訓練)
                        .Where(v => v.AttendingCoach == coach.CoachID);
                    salary.PIAttendanceCount = PI_Items.Count();
                    salary.PIBonus = PI_Items.Sum(v => v.CoachPayoff) ?? 0;

                    models.SubmitChanges();
                }

                void CalcCoachBonus()
                {
                    //Console.WriteLine($"教練: {coach.CoachID} , {coach.UserProfile.RealName}");
                    // 計算累計獎金
                    int durationYears = (salary.JobTenureInDays ?? 0) / 365;
                    // 計算年資加成
                    decimal seniorityBonusPercentage = AppSettings.Default.SeniorityBonusAvailableLevel.Any(l => l == coach.LevelID)
                        ? GetSeniorityBonusPercentage(durationYears, bonusConfigCoach.SeniorityBonuses)
                        : 0;
                    //Console.WriteLine($"年資: {durationYears}, 年資加成: {seniorityBonusPercentage}, 平均單價: {salary.PTAverageUnitPrice}, PT課數: {salary.PTAttendanceCount ?? 0}");
                    salary.AttendanceBonus = (int)(ComputeBonusThreshold((decimal)(salary.PTAverageUnitPrice ?? 0), salary.PTAttendanceCount ?? 0, bonusConfigCoach, seniorityBonusPercentage) + 0.5M);
                    //Console.WriteLine($"上課獎金: {salary.AttendanceBonus}");
                    if (salary.PTAttendanceCount >= 40 && salary.AttendedByOther > 0)
                    {
                        //Console.WriteLine($"合作課**************************************");
                        salary.AttendedShare = (int)(ComputeBonusThreshold((decimal)(salary.AttendedByOtherAvgPrice ?? 0), salary.AttendedByOther ?? 0, bonusConfigCooperation) + 0.5M);
                        //Console.WriteLine($"合作課獎金: {salary.AttendedShare}");
                    }
                    //Console.WriteLine($"********************************************");
                    models.SubmitChanges();
                }

                CoachBranchMonthlyBonus PrepareManagedBranchBonus(BranchStore branch)
                {
                    if (branch == null)
                    {
                        return null;
                    }

                    var branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == branch.BranchID).FirstOrDefault();
                    if (branchBonus == null)
                    {
                        branchBonus = new CoachBranchMonthlyBonus
                        {
                            CoachMonthlySalary = salary,
                            BranchID = branch.BranchID
                        };
                        salary.CoachBranchMonthlyBonus.Add(branchBonus);
                    }

                    var branchItems = countableItems.Where(w => w.WorkPlace == branch.BranchID);
                    branchBonus.BranchTotalAttendanceCount = branchItems.Count();
                    branchBonus.BranchTotalTuition = branchItems.CalcTuition(models);

                    var branchVoidTuition = voidPayment
                        .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == branch.BranchID), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                        .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                    branchBonus.VoidShare = branchVoidTuition.Sum(t => t.VoidShare) ?? 0;

                    models.SubmitChanges();
                    return branchBonus;
                }

                void PrepareBranchSummary(BranchStore branch, decimal achievementRatio)
                {
                    var summaryItem = models.GetTable<BranchMonthlySummary>()
                        .Where(m => m.SettlementID == settlement.SettlementID && m.BranchID == branch.BranchID)
                        .FirstOrDefault();

                    if (summaryItem == null)
                    {
                        summaryItem = new BranchMonthlySummary
                        {
                            SettlementID = settlement.SettlementID,
                            BranchID = branch.BranchID
                        };
                        models.GetTable<BranchMonthlySummary>().InsertOnSubmit(summaryItem);
                    }

                    summaryItem.AchievementRatio = achievementRatio;
                }

                void CalcManagerBonus(BranchStore branch, CoachBranchMonthlyBonus branchBonus)
                {
                    // 店主管目前只計算自身上課獎金，管理獎金由分店月摘要保留 0。
                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 40)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    salary.ManagerBonus = 0;

                    decimal achievementRatio = 0;
                    PrepareBranchSummary(branch, achievementRatio);

                    models.SubmitChanges();
                }


                void CalcViceManagerBonus(BranchStore branch, CoachBranchMonthlyBonus branchBonus)
                {
                    // 副店長保留課數階梯獎金，並依月指標達成率設定管理獎金級距。
                    var netAchievement = Math.Max(salary.PerformanceAchievement.Value - salary.VoidShare.Value, 0);

                    var attendanceCount = salary.CoachBranchMonthlyBonus.Sum(b => b.AchievementAttendanceCount);
                    int bonusIdx = 0;
                    for (; bonusIdx < ViceManagerAttendanceIndex.Length; bonusIdx++)
                    {
                        if (attendanceCount >= ViceManagerAttendanceIndex[bonusIdx])
                        {
                            break;
                        }
                    }

                    if (bonusIdx < ViceManagerAttendanceIndex.Length)
                    {
                        salary.AttendanceBonus = ViceManagerAttendanceBonus[bonusIdx];
                    }
                    else
                    {
                        salary.AttendanceBonus = 0;
                    }

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    var indicator = models.GetTable<MonthlyIndicator>().Where(s => s.StartDate <= settlement.StartDate && s.EndExclusiveDate > settlement.StartDate).FirstOrDefault();
                    decimal achievementRatio = 0;
                    salary.ManagerBonus = 0;

                    if (indicator != null)
                    {
                        MonthlyBranchRevenueGoal item = indicator.MonthlyBranchRevenueIndicator.Where(r => r.BranchID == branch.BranchID)
                            .Where(r => r.MonthlyBranchRevenueGoal != null)
                            .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();

                        if (item != null)
                        {
                            branchBonus.BranchTotalPTCount =
                                (item.ActualCompleteLessonCount ?? 0)
                                + (item.SRCount ?? 0)
                                + (item.SDCount ?? 0)
                                + (item.ATCount ?? 0);
                            var tuitionSubtotal =
                            branchBonus.BranchTotalPTTuition =
                                (item.ActualLessonAchievement ?? 0)
                                + (item.SRAchievement ?? 0)
                                + (item.SDAchievement ?? 0)
                                + (item.ATAchievement ?? 0);

                            decimal indicatorAmt = (decimal)item.MonthlyBranchRevenueIndicator.RevenueGoal;
                            decimal basePercentage = item.MonthlyBranchRevenueIndicator.MonthlyRevenueGrade.IndicatorPercentage;
                            int totalAchievementAmt = (tuitionSubtotal + item.ActualSharedAchievement - (item.VoidShare ?? 0)) ?? 0;

                            achievementRatio = Math.Round(totalAchievementAmt * basePercentage / indicatorAmt);
                            bonusIdx = 0;
                            for (; bonusIdx < ManagerManagementBonusIndex.Length; bonusIdx++)
                            {
                                if (achievementRatio >= ManagerManagementBonusIndex[bonusIdx])
                                {
                                    break;
                                }
                            }

                            if (bonusIdx < ManagerManagementBonusIndex.Length)
                            {
                                //salary.ManagerBonus = (int)(tuitionSubtotal * ViceManagerManagementBonusRatio[bonusIdx] / 1.05M + 0.5M);
                                salary.ManagementBonusGrade = ViceManagerManagementBonusRatio[bonusIdx];
                            }
                        }
                    }

                    PrepareBranchSummary(branch, achievementRatio);

                    models.SubmitChanges();

                    //抽個人
                    if ((salary.SpecialBonus == 0 || !salary.SpecialBonus.HasValue) && achievementRatio <= 85)
                    {
                        CalcCoachBonus();
                        salary.SpecialBonus = salary.AchievementBonus;
                        salary.AchievementBonus = 0;
                        models.SubmitChanges();
                    }
                }

                void CalcFESBonus()
                {
                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 70)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    salary.ManagerBonus = 0;

                    models.SubmitChanges();
                }

                void CalcRFMBonus()
                {
                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 60)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    salary.ManagerBonus = 0;

                    models.SubmitChanges();
                }

                void CalcHealthCareBonus()
                {
                    // 運動恢復只採計 SR/點數兌換課程，並清掉合作課相關欄位。
                    salary.PTAttendanceCount = helper.LessonItems
                            .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.運動恢復課程
                                    || v.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程)
                            .Where(v => v.AttendingCoach == coach.CoachID).Count();

                    // 計算累計獎金
                    int durationYears = (salary.JobTenureInDays ?? 0) / 365;
                    // 計算年資加成
                    decimal seniorityBonusPercentage = AppSettings.Default.SeniorityBonusAvailableLevel.Any(l => l == coach.LevelID)
                        ? GetSeniorityBonusPercentage(durationYears, bonusConfigCoach.SeniorityBonuses)
                        : 0;
                    salary.AttendanceBonus = (int)(ComputeBonusThreshold((decimal)(salary.PTAverageUnitPrice ?? 0), salary.PTAttendanceCount ?? 0, bonusConfigSR, seniorityBonusPercentage) + 0.5M);

                    salary.AttendedByOther = 0;
                    salary.AttendedShare = 0;
                    salary.AttendedByOtherAvgPrice = 0;

                    models.SubmitChanges();
                }

                void CalcDietitianBonus()
                {
                    // 營養師依職級套用固定堂數門檻與單堂獎金。
                    salary.PTAttendanceCount = helper.LessonItems
                            .Where(v => v.PriceStatus == (int)Naming.LessonPriceStatus.營養課程
                                    || v.PriceStatus == (int)Naming.LessonPriceStatus.點數兌換課程
                                    || v.PriceStatus == (int)Naming.LessonPriceStatus.體驗課程)
                            .Where(v => v.AttendingCoach == coach.CoachID).Count();

                    salary.AttendanceBonus = 0;

                    if (coach.LevelID.HasValue && DietitianBonusIndex.ContainsKey(coach.LevelID.Value))
                    {
                        var bonusLevel = DietitianBonusIndex[coach.LevelID.Value];
                        var bonusIdx = bonusLevel.Where(i => salary.PTAttendanceCount >= i[0]).FirstOrDefault();
                        if (bonusIdx != null)
                        {
                            salary.AttendanceBonus = (salary.PTAttendanceCount - 15) * bonusIdx[1];
                        }
                    }

                    models.SubmitChanges();
                }

                BranchStore branch;
                if (coach.ProfessionalLevel.IsOfficer())
                {
                    if (!ShouldProcessRole("officer"))
                    {
                        continue;
                    }

                    // 高階主管需要彙總全分店的課程與退費資訊。
                    foreach (var b in models.GetTable<BranchStore>())
                    {
                        var g = countableItems.Where(t => t.BranchID == b.BranchID);

                        var branchBonus = salary.CoachBranchMonthlyBonus.Where(item => item.BranchID == b.BranchID).FirstOrDefault();
                        if (branchBonus == null)
                        {
                            branchBonus = new CoachBranchMonthlyBonus
                            {
                                CoachMonthlySalary = salary,
                                BranchID = b.BranchID
                            };
                            salary.CoachBranchMonthlyBonus.Add(branchBonus);
                        }

                        branchBonus.BranchTotalAttendanceCount = g.Count();
                        branchBonus.BranchTotalTuition = g.CalcTuition(models);

                        var branchVoidTuition = voidPayment
                            .Join(models.GetTable<PaymentTransaction>().Where(t => t.BranchID == b.BranchID), p => p.PaymentID, t => t.PaymentID, (p, t) => p)
                            .Join(models.GetTable<TuitionAchievement>(), p => p.PaymentID, t => t.InstallmentID, (p, t) => t);

                        branchBonus.VoidShare = branchVoidTuition.Sum(t => t.VoidShare) ?? 0;

                        models.SubmitChanges();
                    }

                    CalcGeneralAchievement();

                    salary.GradeIndex = salary.ProfessionalLevel?.ProfessionalLevelBasicSalary?.SalaryDetails.CommissionGrade ?? 0;

                    salary.AttendanceBonus = (int?)(Math.Min(salary.PTAttendanceCount ?? 0, 70)
                        * (int?)(salary.PTAverageUnitPrice / 1.05M + 0.5M)
                        * (salary.GradeIndex / 100M)
                        + 0.5M) ?? 0;

                    //salary.AttendanceBonus += salary.TSAttendanceCount! * bonusConfigSR.TSBonusUnitPrice;

                    int lessonAchievement = helper.LessonItems.Where(t => BusinessConsoleExtensions.SessionScopeForAchievement.Contains(t.PriceStatus)).Sum(t => t.ListPrice * t.GroupingMemberCount * t.PercentageOfDiscount / 100) ?? 0;
                    lessonAchievement += (helper.LessonItems.Where(t => BusinessConsoleExtensions.SessionScopeForAchievement.Contains(t.ELStatus)).Sum(l => l.EnterpriseListPrice * l.GroupingMemberCount * l.PercentageOfDiscount / 100) ?? 0);

                    salary.ManagerBonus = (int)(lessonAchievement / 1.05M * 0.01M + 0.5M);
                    models.SubmitChanges();
                }
                else if (coach.ProfessionalLevel.IsFES())
                {
                    if (!ShouldProcessRole("fes"))
                    {
                        continue;
                    }
                    CalcGeneralAchievement();
                    CalcFESBonus();
                }
                else if (coach.ProfessionalLevel.IsRFM())
                {
                    if (!ShouldProcessRole("rfm"))
                    {
                        continue;
                    }
                    CalcGeneralAchievement();
                    CalcRFMBonus();
                }
                else if (coach.ProfessionalLevel.IsManager())
                {
                    if (!ShouldProcessRole("manager"))
                    {
                        continue;
                    }

                    branch = models.GetTable<BranchStore>()
                        .Where(b => b.ManagerID == coach.CoachID).FirstOrDefault();

                    if (branch == null)
                    {
                        branch = coach.CurrentWorkBranch();
                    }

                    CoachBranchMonthlyBonus branchBonus = PrepareManagedBranchBonus(branch);
                    CalcGeneralAchievement();
                    CalcManagerBonus(branch, branchBonus);
                }
                else if (coach.ProfessionalLevel.IsViceManager())
                {
                    if (!ShouldProcessRole("vicemanager"))
                    {
                        continue;
                    }

                    if (coach.ServingCoachProperty.Any(p => p.PropertyID == (int)ServingCoachProperty.PropertyDefinition.Apprentice))
                    {
                        CalcGeneralAchievement();
                        CalcCoachBonus();

                        branch = models.GetTable<BranchStore>().Where(b => b.ViceManagerID == coach.CoachID).FirstOrDefault();
                        branch ??= coach.CurrentWorkBranch();

                        CoachBranchMonthlyBonus branchBonus = null;
                        if (branch != null)
                        {
                            branchBonus = salary.CoachBranchMonthlyBonus.Where(b => b.BranchID == branch.BranchID).FirstOrDefault();
                        }

                        var indicator = models.GetTable<MonthlyIndicator>().Where(s => s.StartDate <= settlement.StartDate && s.EndExclusiveDate > settlement.StartDate).FirstOrDefault();
                        decimal achievementRatio = 0;
                        salary.ManagerBonus = 0;
                        int bonusIdx = 0;

                        if (indicator != null && branchBonus != null)
                        {
                            MonthlyBranchRevenueGoal item = indicator.MonthlyBranchRevenueIndicator.Where(r => r.BranchID == branch.BranchID)
                                .Where(r => r.MonthlyBranchRevenueGoal != null)
                                .Select(r => r.MonthlyBranchRevenueGoal).FirstOrDefault();

                            if (item != null)
                            {
                                branchBonus.BranchTotalPTCount =
                                    (item.ActualCompleteLessonCount ?? 0)
                                    + (item.SRCount ?? 0)
                                    + (item.SDCount ?? 0)
                                    + (item.ATCount ?? 0);
                                var tuitionSubtotal =
                                branchBonus.BranchTotalPTTuition =
                                    (item.ActualLessonAchievement ?? 0)
                                    + (item.SRAchievement ?? 0)
                                    + (item.SDAchievement ?? 0)
                                    + (item.ATAchievement ?? 0);

                                decimal indicatorAmt = (decimal)item.MonthlyBranchRevenueIndicator.RevenueGoal;
                                decimal basePercentage = item.MonthlyBranchRevenueIndicator.MonthlyRevenueGrade.IndicatorPercentage;
                                int totalAchievementAmt = (tuitionSubtotal + item.ActualSharedAchievement - (item.VoidShare ?? 0)) ?? 0;

                                achievementRatio = Math.Round(totalAchievementAmt * basePercentage / indicatorAmt);
                                bonusIdx = 0;
                                for (; bonusIdx < ManagerManagementBonusIndex.Length; bonusIdx++)
                                {
                                    if (achievementRatio >= ManagerManagementBonusIndex[bonusIdx])
                                    {
                                        break;
                                    }
                                }

                                if (bonusIdx < ManagerManagementBonusIndex.Length)
                                {
                                    //salary.ManagerBonus = (int)(tuitionSubtotal * ApprenticeManagementBonusRatio[bonusIdx] / 1.05M + 0.5M);
                                    salary.ManagementBonusGrade = ApprenticeManagementBonusRatio[bonusIdx];
                                }
                                models.SubmitChanges();
                            }
                        }
                    }
                    else
                    {
                        branch = models.GetTable<BranchStore>().Where(b => b.ViceManagerID == coach.CoachID).FirstOrDefault();

                        if (branch == null)
                        {
                            branch = coach.CurrentWorkBranch();
                        }

                        CoachBranchMonthlyBonus branchBonus = PrepareManagedBranchBonus(branch);
                        CalcGeneralAchievement();
                        CalcViceManagerBonus(branch, branchBonus);
                    }
                }
                else if (coach.ProfessionalLevel.IsHealthCare())
                {
                    if (!ShouldProcessRole("health"))
                    {
                        continue;
                    }

                    CalcGeneralAchievement();
                    CalcHealthCareBonus();
                }
                else if (coach.ProfessionalLevel.IsDietitian())
                {
                    if (!ShouldProcessRole("health"))
                    {
                        continue;
                    }

                    CalcGeneralAchievement();
                    CalcDietitianBonus();
                }
                else
                {
                    if (!ShouldProcessRole("coach"))
                    {
                        continue;
                    }

                    CalcGeneralAchievement();
                    CalcCoachBonus();
                }
            }
        }

        static decimal GetSeniorityBonusPercentage(int years, SeniorityBonus[] bonuses)
        {
            foreach (var bonus in bonuses)
            {
                if ((bonus.MinYears <= years) && (bonus.MaxYears == null || years < bonus.MaxYears))
                {
                    return bonus.BonusPercentage;
                }
            }
            return 0;
        }

        static BonusConfig LoadBonusConfig(string filePath)
        {
            var config = new BonusConfig();
            if (File.Exists(filePath))
            {
                string json = File.ReadAllText(filePath);
                return JsonConvert.DeserializeObject<BonusConfig>(json);
            }
            else
            {
                File.WriteAllText(filePath, config.JsonStringify());
            }
            return config;
        }

        static CustomizedGroupCourse LoadGroupXBonusConfig(string filePath)
        {
            var config = new CustomizedGroupCourse();
            if (File.Exists(filePath))
            {
                string json = File.ReadAllText(filePath);
                return JsonConvert.DeserializeObject<CustomizedGroupCourse>(json);
            }
            else
            {
                File.WriteAllText(filePath, config.JsonStringify());
            }
            return config;
        }

        static int CalculateGroupXBonus(int classes, int attendance, CustomizedGroupCourse config)
        {
            int totalBonus = 0;
            // 找出適用的獎金規則
            var applicableRule = config.AttendanceRanges.FirstOrDefault(r =>
                attendance >= (r.Min ?? int.MinValue) &&
                (r.Max == null || attendance <= r.Max));

            if (applicableRule != null)
            {
                totalBonus = applicableRule.BonusPerClass * classes;
            }

            return totalBonus;
        }

        static decimal CalculateTotalBonus(decimal averagePrice, int totalClasses, int seniorityYears, BonusConfig config)
        {
            decimal totalBonus = ComputeBonusThreshold(averagePrice, totalClasses, config);

            // 計算年資加成
            decimal seniorityBonusPercentage = GetSeniorityBonusPercentage(seniorityYears, config.SeniorityBonuses);
            totalBonus += totalClasses * averagePrice * seniorityBonusPercentage;

            return totalBonus;
        }

        static decimal ComputeBonusThreshold(decimal averagePrice, int totalClasses, BonusConfig config, decimal seniorityPercentage = 0)
        {
            decimal totalBonus = 0;
            averagePrice = (int)(averagePrice / 1.05M + 0.5M);
            // 計算基本抽成獎金
            for (int i = 0; i < config.Thresholds.Length; i++)
            {
                int lowerBound = config.Thresholds[i];
                int upperBound = (i + 1 < config.Thresholds.Length)
                                    ? config.Thresholds[i + 1] - 1
                                    : config.ClassesCeiling.HasValue
                                        ? Math.Min(totalClasses, config.ClassesCeiling.Value)
                                        : totalClasses;

                if (totalClasses >= lowerBound)
                {
                    int applicableClasses = Math.Min(totalClasses, upperBound) - lowerBound + 1;
                    totalBonus += averagePrice * applicableClasses * (config.Percentages[i] + seniorityPercentage);
                    //Console.WriteLine($"累進抽成獎金: {totalBonus} , {averagePrice} * {applicableClasses} * {config.Percentages[i] + seniorityPercentage}");
                }
                else
                {
                    break;
                }
            }

            return totalBonus;
        }


    }
}
