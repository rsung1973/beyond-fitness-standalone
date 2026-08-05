/*
    SQL translation of WebDev\Helper\ReportExtensionMethods.cs
    ExecuteLessonPerformanceSettlement(startDate, endExclusiveDate, forRole)

    Usage:
      1. Set @SettlementDate to any date in the target month.
      2. Set @ForRole to one of:
         'coach', 'health', 'manager', 'vicemanager', 'fes', 'rfm', 'officer'

    Notes:
      - AccountingController.ExecuteMonthlyPerformanceSettlementAsync passes the first
        day of the month and the next month's first day, but the method then uses the
        matched dbo.Settlement.StartDate / EndExclusiveDate for the actual work.
      - If @ForRole is NULL, the C# method still performs the common CoachMonthlySalary
        upsert/update for all effective coaches, but skips all role-specific bonus
        calculations. This script keeps that behavior.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @SettlementDate date = '2026-01-01';
DECLARE @ForRole nvarchar(30) = N'coach';

SET @ForRole = LOWER(NULLIF(LTRIM(RTRIM(@ForRole)), N''));

DECLARE
    @SettlementID int,
    @MonthStart date,
    @MonthEnd date,
    @StartDate datetime,
    @EndExclusiveDate datetime,
    @Year int;

SET @MonthStart = DATEFROMPARTS(YEAR(@SettlementDate), MONTH(@SettlementDate), 1);
SET @MonthEnd = DATEADD(month, 1, @MonthStart);

SELECT TOP (1)
    @SettlementID = s.SettlementID,
    @StartDate = s.StartDate,
    @EndExclusiveDate = s.EndExclusiveDate,
    @Year = s.[Year]
FROM dbo.Settlement AS s
WHERE @MonthStart <= s.SettlementDate
  AND @MonthEnd > s.SettlementDate;

IF @SettlementID IS NULL
BEGIN
    RAISERROR(N'No dbo.Settlement row matched @SettlementDate.', 16, 1);
    RETURN;
END;

BEGIN TRAN;

/* Constants from Naming.cs / Rules.cs */
DECLARE
    @StatusDeleted int = 0,
    @StatusGeneral int = 1,
    @StatusPI int = 103,
    @StatusTrial int = 1006,
    @StatusPointExchange int = 1007,
    @StatusGroupMember int = 1008,
    @StatusWelfare int = 1010,
    @StatusDietitian int = 1012,
    @StatusAT int = 1013,
    @StatusSR int = 1014,
    @StatusGroupX int = 1015,
    @FeatureSR int = 1014,
    @LessonSettlementHalf int = 1,
    @LessonSettlementFull int = 2,
    @MemberChecked int = 1003,
    @CategorySpecial int = 1103,
    @CategoryFM int = 1106,
    @CategoryAFM int = 1107,
    @CategoryFES int = 1108,
    @CategoryHealth int = 1109,
    @CategoryDietitian int = 1110,
    @LevelRFM int = 45,
    @ServingCoachApprentice int = 1;

IF OBJECT_ID('tempdb..#LessonItems') IS NOT NULL DROP TABLE #LessonItems;
IF OBJECT_ID('tempdb..#Countable') IS NOT NULL DROP TABLE #Countable;
IF OBJECT_ID('tempdb..#PT') IS NOT NULL DROP TABLE #PT;
IF OBJECT_ID('tempdb..#EffectiveCoach') IS NOT NULL DROP TABLE #EffectiveCoach;
IF OBJECT_ID('tempdb..#RoleCoach') IS NOT NULL DROP TABLE #RoleCoach;
IF OBJECT_ID('tempdb..#SalaryBase') IS NOT NULL DROP TABLE #SalaryBase;

SELECT *
INTO #LessonItems
FROM dbo.V_Tuition AS v
WHERE v.ClassTime >= @StartDate
  AND v.ClassTime <  @EndExclusiveDate;

/* LessonTimeSettlement status updates */
UPDATE lts
SET lts.SettlementStatus = @LessonSettlementFull,
    lts.SettlementID = @SettlementID
FROM dbo.LessonTimeSettlement AS lts
JOIN #LessonItems AS v ON v.LessonID = lts.LessonID
WHERE v.PriceStatus <> @StatusPI
  AND (v.ELStatus IS NULL OR v.ELStatus <> @StatusPI)
  AND v.CoachAttendance IS NOT NULL
  AND v.CommitAttendance IS NOT NULL;

UPDATE lts
SET lts.SettlementStatus = @LessonSettlementHalf,
    lts.SettlementID = @SettlementID
FROM dbo.LessonTimeSettlement AS lts
JOIN #LessonItems AS v ON v.LessonID = lts.LessonID
WHERE v.PriceStatus = @StatusPI
   OR v.ELStatus = @StatusPI
   OR (v.CommitAttendance IS NULL AND v.CoachAttendance IS NOT NULL)
   OR (v.CommitAttendance IS NOT NULL AND v.CoachAttendance IS NULL);

UPDATE lts
SET lts.SettlementID = @SettlementID
FROM dbo.LessonTimeSettlement AS lts
JOIN #LessonItems AS v ON v.LessonID = lts.LessonID
WHERE v.CommitAttendance IS NULL
  AND v.CoachAttendance IS NULL;

SELECT *
INTO #Countable
FROM #LessonItems AS v
WHERE v.PriceStatus <> @StatusDietitian
  AND (
        v.CoachAttendance IS NOT NULL
        OR (
            v.CoachAttendance IS NULL
            AND NOT (v.PriceStatus = @StatusTrial OR v.ELStatus = @StatusTrial)
        )
      );

SELECT *
INTO #PT
FROM #LessonItems AS v
WHERE v.PriceStatus IN (@StatusGeneral, @StatusDeleted, @StatusPointExchange, @StatusWelfare, @StatusGroupMember, @StatusSR, @StatusAT)
   OR v.ELStatus    IN (@StatusGeneral, @StatusDeleted, @StatusPointExchange, @StatusWelfare, @StatusGroupMember, @StatusSR, @StatusAT);

SELECT
    c.CoachID,
    c.LevelID AS CoachLevelID,
    pl.CategoryID,
    CASE
        WHEN pl.CategoryID = @CategorySpecial THEN N'officer'
        WHEN pl.CategoryID = @CategoryFES THEN N'fes'
        WHEN pl.LevelID = @LevelRFM THEN N'rfm'
        WHEN pl.CategoryID = @CategoryFM AND pl.LevelID <> @LevelRFM THEN N'manager'
        WHEN pl.CategoryID = @CategoryAFM THEN N'vicemanager'
        WHEN pl.CategoryID = @CategoryHealth THEN N'health'
        WHEN pl.CategoryID = @CategoryDietitian THEN N'health'
        ELSE N'coach'
    END AS RoleKind,
    cwa.SingleWorkPlace,
    CASE WHEN EXISTS (
        SELECT 1
        FROM dbo.ServingCoachProperty AS scp
        WHERE scp.CoachID = c.CoachID
          AND scp.PropertyID = @ServingCoachApprentice
    ) THEN 1 ELSE 0 END AS IsApprentice
INTO #EffectiveCoach
FROM dbo.ServingCoach AS c
JOIN dbo.UserProfile AS u ON u.UID = c.CoachID
LEFT JOIN dbo.ProfessionalLevel AS pl ON pl.LevelID = c.LevelID
OUTER APPLY (
    SELECT CASE WHEN COUNT(*) = 1 THEN MAX(cw.BranchID) END AS SingleWorkPlace
    FROM dbo.CoachWorkplace AS cw
    WHERE cw.CoachID = c.CoachID
) AS cwa
WHERE u.LevelID = @MemberChecked
  AND c.LevelID > 0;

SELECT *
INTO #RoleCoach
FROM #EffectiveCoach
WHERE RoleKind = @ForRole;

/* Common CoachMonthlySalary upsert/update for all effective coaches */
INSERT INTO Report.CoachMonthlySalary (CoachID, SettlementID, [Year], AvgFlag, LevelID)
SELECT ec.CoachID, @SettlementID, @Year, 1, COALESCE(li.ProfessionalLevelID, ec.CoachLevelID, 0)
FROM #EffectiveCoach AS ec
OUTER APPLY (
    SELECT TOP (1) c.ProfessionalLevelID
    FROM #Countable AS c
    WHERE c.AttendingCoach = ec.CoachID
) AS li
WHERE NOT EXISTS (
    SELECT 1
    FROM Report.CoachMonthlySalary AS s
    WHERE s.CoachID = ec.CoachID
      AND s.SettlementID = @SettlementID
);

UPDATE s
SET s.WorkPlace = CASE WHEN ec.SingleWorkPlace IS NOT NULL THEN ec.SingleWorkPlace ELSE s.WorkPlace END,
    s.LevelID = COALESCE(li.ProfessionalLevelID, ec.CoachLevelID, 0),
    s.PerformanceAchievement = COALESCE(pa.ShareAmount, 0),
    s.VoidShare = COALESCE(vs.VoidShare, 0)
FROM Report.CoachMonthlySalary AS s
JOIN #EffectiveCoach AS ec ON ec.CoachID = s.CoachID
OUTER APPLY (
    SELECT TOP (1) c.ProfessionalLevelID
    FROM #Countable AS c
    WHERE c.AttendingCoach = ec.CoachID
) AS li
OUTER APPLY (
    SELECT SUM(ta.ShareAmount) AS ShareAmount
    FROM dbo.Payment AS p
    JOIN dbo.TuitionAchievement AS ta ON ta.InstallmentID = p.PaymentID
    WHERE p.PayoffDate >= @StartDate
      AND p.PayoffDate < @EndExclusiveDate
      AND ta.CoachID = ec.CoachID
) AS pa
OUTER APPLY (
    SELECT SUM(ta.VoidShare) AS VoidShare
    FROM dbo.VoidPayment AS vp
    JOIN dbo.Payment AS p ON p.PaymentID = vp.VoidID
    JOIN dbo.TuitionAchievement AS ta ON ta.InstallmentID = p.PaymentID
    WHERE vp.VoidDate >= @StartDate
      AND vp.VoidDate < @EndExclusiveDate
      AND p.AllowanceID IS NOT NULL
      AND ta.CoachID = ec.CoachID
) AS vs
WHERE s.SettlementID = @SettlementID;

/* Role-specific common achievement calculation: calcGeneralAchievement() */
;WITH CoachBranch AS (
    SELECT c.AttendingCoach AS CoachID, c.BranchID
    FROM #Countable AS c
    JOIN #RoleCoach AS rc ON rc.CoachID = c.AttendingCoach
    WHERE c.BranchID IS NOT NULL
    GROUP BY c.AttendingCoach, c.BranchID
)
INSERT INTO Report.CoachBranchMonthlyBonus (CoachID, SettlementID, BranchID)
SELECT cb.CoachID, @SettlementID, cb.BranchID
FROM CoachBranch AS cb
WHERE NOT EXISTS (
    SELECT 1
    FROM Report.CoachBranchMonthlyBonus AS b
    WHERE b.CoachID = cb.CoachID
      AND b.SettlementID = @SettlementID
      AND b.BranchID = cb.BranchID
);

;WITH BranchAgg AS (
    SELECT
        c.AttendingCoach AS CoachID,
        c.BranchID,
        CAST(COUNT(*) AS decimal(18,2))
            - CAST(SUM(CASE WHEN c.PriceStatus = @StatusPI OR c.ELStatus = @StatusPI THEN 1 ELSE 0 END) AS decimal(18,2)) / 2
            - CAST(SUM(CASE WHEN c.PriceStatus = @StatusTrial AND EXISTS (
                    SELECT 1 FROM dbo.LessonPriceProperty AS lpp
                    WHERE lpp.PriceID = c.PriceID AND lpp.PropertyID = @FeatureSR
                ) THEN 1 ELSE 0 END) AS decimal(18,2)) / 2 AS AchievementAttendanceCount,
        CAST(COALESCE(SUM(CASE WHEN c.EnterpriseRegisterID IS NULL
            THEN c.CoachPayoff * c.GroupingMemberCount * c.TuitionIndex * c.PercentageOfDiscount / 100.0
            ELSE 0 END), 0)
            + COALESCE(SUM(CASE WHEN c.EnterpriseRegisterID IS NOT NULL
            THEN c.EnterpriseCoachPayoff * c.TuitionIndex * c.PercentageOfDiscount / 100.0
            ELSE 0 END), 0) AS int) AS Tuition,
        CAST(COALESCE(SUM(c.CoachPayoff * c.TuitionIndex * c.GroupingMemberCount * c.PercentageOfDiscount / 100.0 * c.MarkedGradeIndex / 100.0), 0) AS int) AS AttendanceBonus
    FROM #Countable AS c
    JOIN #RoleCoach AS rc ON rc.CoachID = c.AttendingCoach
    WHERE c.BranchID IS NOT NULL
    GROUP BY c.AttendingCoach, c.BranchID
)
UPDATE b
SET b.AchievementAttendanceCount = a.AchievementAttendanceCount,
    b.Tuition = a.Tuition,
    b.AttendanceBonus = a.AttendanceBonus
FROM Report.CoachBranchMonthlyBonus AS b
JOIN BranchAgg AS a
  ON a.CoachID = b.CoachID
 AND a.BranchID = b.BranchID
WHERE b.SettlementID = @SettlementID;

;WITH PTAgg AS (
    SELECT
        p.AttendingCoach AS CoachID,
        COUNT(*) AS PTAttendanceCount,
        CAST(CAST(COALESCE(SUM(CASE WHEN p.EnterpriseRegisterID IS NULL
            THEN p.CoachPayoff * p.GroupingMemberCount * p.TuitionIndex * p.PercentageOfDiscount / 100.0
            ELSE 0 END), 0)
            + COALESCE(SUM(CASE WHEN p.EnterpriseRegisterID IS NOT NULL
            THEN p.EnterpriseCoachPayoff * p.TuitionIndex * p.PercentageOfDiscount / 100.0
            ELSE 0 END), 0) AS int) * 1.0 / COUNT(*) + 0.5 AS int) AS PTAverageUnitPrice
    FROM #PT AS p
    JOIN #RoleCoach AS rc ON rc.CoachID = p.AttendingCoach
    GROUP BY p.AttendingCoach
),
OtherAgg AS (
    SELECT
        vc.PrimaryCoach AS CoachID,
        COUNT(*) AS AttendedByOther,
        CAST((COALESCE(SUM(vc.ListPrice * vc.GroupingMemberCount * vc.PercentageOfDiscount / 100.0), 0)
            + COALESCE(SUM(vc.EnterpriseListPrice * vc.GroupingMemberCount * vc.PercentageOfDiscount / 100.0), 0)) / COUNT(*) + 0.5 AS int) AS AttendedByOtherAvgPrice
    FROM #LessonItems AS li
    JOIN dbo.V_TuitionCoach AS vc ON vc.LessonID = li.LessonID
    JOIN #RoleCoach AS rc ON rc.CoachID = vc.PrimaryCoach
    WHERE li.PriceStatus IN (@StatusGeneral, @StatusDeleted, @StatusGroupMember)
      AND vc.AttendingCoach <> vc.PrimaryCoach
    GROUP BY vc.PrimaryCoach
),
TSAgg AS (
    SELECT AttendingCoach AS CoachID, COUNT(*) AS TSAttendanceCount, COALESCE(SUM(CoachPayoff), 0) AS TSBonus
    FROM #LessonItems
    WHERE PriceStatus = @StatusTrial
    GROUP BY AttendingCoach
),
PIAgg AS (
    SELECT AttendingCoach AS CoachID, COUNT(*) AS PIAttendanceCount, COALESCE(SUM(CoachPayoff), 0) AS PIBonus
    FROM #LessonItems
    WHERE PriceStatus = @StatusPI
    GROUP BY AttendingCoach
),
GroupXByClass AS (
    SELECT AttendingCoach AS CoachID, ClassTime, COUNT(*) AS Attendance
    FROM #LessonItems
    WHERE PriceStatus = @StatusGroupX
    GROUP BY AttendingCoach, ClassTime
),
GroupXAgg AS (
    SELECT
        CoachID,
        COUNT(*) AS GroupXAttendanceCount,
        SUM(CASE WHEN Attendance BETWEEN 1 AND 5 THEN 1200
                 WHEN Attendance BETWEEN 6 AND 7 THEN 1500
                 WHEN Attendance >= 8 THEN 1800
                 ELSE 0 END) AS GroupXBonus
    FROM GroupXByClass
    GROUP BY CoachID
),
Tenure AS (
    SELECT
        fe.UID AS CoachID,
        SUM(CASE WHEN fe.EmploymentDate IS NOT NULL
            THEN DATEDIFF(day, fe.EmploymentDate, COALESCE(fe.LeavedDate, CONVERT(date, GETDATE()))) + 1
            ELSE 0 END) AS JobTenureInDays
    FROM dbo.ForEmployee AS fe
    GROUP BY fe.UID
)
UPDATE s
SET s.PTAttendanceCount = COALESCE(pt.PTAttendanceCount, 0),
    s.PTAverageUnitPrice = COALESCE(pt.PTAverageUnitPrice, 0),
    s.AttendedByOther = COALESCE(oa.AttendedByOther, 0),
    s.AttendedByOtherAvgPrice = COALESCE(oa.AttendedByOtherAvgPrice, 0),
    s.AttendedShare = 0,
    s.JobTenureInDays = COALESCE(t.JobTenureInDays, 0),
    s.TSAttendanceCount = COALESCE(ts.TSAttendanceCount, 0),
    s.TSBonus = COALESCE(ts.TSBonus, 0),
    s.PIAttendanceCount = COALESCE(pi.PIAttendanceCount, 0),
    s.PIBonus = COALESCE(pi.PIBonus, 0),
    s.GroupXAttendanceCount = COALESCE(gx.GroupXAttendanceCount, 0),
    s.GroupXBonus = COALESCE(gx.GroupXBonus, 0)
FROM Report.CoachMonthlySalary AS s
JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
LEFT JOIN PTAgg AS pt ON pt.CoachID = s.CoachID
LEFT JOIN OtherAgg AS oa ON oa.CoachID = s.CoachID
LEFT JOIN TSAgg AS ts ON ts.CoachID = s.CoachID
LEFT JOIN PIAgg AS pi ON pi.CoachID = s.CoachID
LEFT JOIN GroupXAgg AS gx ON gx.CoachID = s.CoachID
LEFT JOIN Tenure AS t ON t.CoachID = s.CoachID
WHERE s.SettlementID = @SettlementID;

/* coach: calcCoachBonus(); vice-manager apprentices also use this path first. */
IF @ForRole IN (N'coach', N'vicemanager')
BEGIN
    ;WITH Seniority AS (
        SELECT s.CoachID,
               CASE WHEN s.LevelID IN (40,41,49,50) THEN
                    CASE WHEN COALESCE(s.JobTenureInDays, 0) / 365 >= 10 THEN 0.010
                         WHEN COALESCE(s.JobTenureInDays, 0) / 365 >= 8 THEN 0.008
                         WHEN COALESCE(s.JobTenureInDays, 0) / 365 >= 5 THEN 0.004
                         ELSE 0 END
                    ELSE 0 END AS SeniorityPct
        FROM Report.CoachMonthlySalary AS s
        JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
        WHERE s.SettlementID = @SettlementID
          AND (@ForRole = N'coach' OR rc.IsApprentice = 1)
    ),
    Bonus AS (
        SELECT s.CoachID,
               FLOOR(COALESCE(SUM(FLOOR(COALESCE(s.PTAverageUnitPrice,0) / 1.05 + 0.5)
                    * (CASE WHEN s.PTAttendanceCount > tier.UpperBound THEN tier.UpperBound ELSE s.PTAttendanceCount END - tier.LowerBound + 1)
                    * (tier.Pct + sn.SeniorityPct)), 0) + 0.5) AS AttendanceBonus
        FROM Report.CoachMonthlySalary AS s
        JOIN Seniority AS sn ON sn.CoachID = s.CoachID
        CROSS APPLY (VALUES
            (41, 50, 0.30), (51, 60, 0.35), (61, 70, 0.40), (71, 80, 0.45),
            (81, 90, 0.50), (91,100, 0.55), (101,120,0.65), (121,2147483647,0.70)
        ) AS tier(LowerBound, UpperBound, Pct)
        WHERE s.SettlementID = @SettlementID
          AND s.PTAttendanceCount >= tier.LowerBound
        GROUP BY s.CoachID
    ),
    Coop AS (
        SELECT s.CoachID,
               FLOOR(COALESCE(SUM(FLOOR(COALESCE(s.AttendedByOtherAvgPrice,0) / 1.05 + 0.5)
                    * (CASE WHEN s.AttendedByOther > tier.UpperBound THEN tier.UpperBound ELSE s.AttendedByOther END - tier.LowerBound + 1)
                    * tier.Pct), 0) + 0.5) AS AttendedShare
        FROM Report.CoachMonthlySalary AS s
        CROSS APPLY (VALUES
            (1, 5, 0.04), (6,10,0.04), (11,15,0.06), (16,20,0.08), (21,25,0.10), (26,30,0.12)
        ) AS tier(LowerBound, UpperBound, Pct)
        WHERE s.SettlementID = @SettlementID
          AND s.PTAttendanceCount >= 40
          AND s.AttendedByOther > 0
          AND s.AttendedByOther >= tier.LowerBound
        GROUP BY s.CoachID
    )
    UPDATE s
    SET s.AttendanceBonus = COALESCE(b.AttendanceBonus, 0),
        s.AttendedShare = COALESCE(c.AttendedShare, 0)
    FROM Report.CoachMonthlySalary AS s
    JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
    LEFT JOIN Bonus AS b ON b.CoachID = s.CoachID
    LEFT JOIN Coop AS c ON c.CoachID = s.CoachID
    WHERE s.SettlementID = @SettlementID
      AND (@ForRole = N'coach' OR rc.IsApprentice = 1);
END;

/* health / dietitian */
IF @ForRole = N'health'
BEGIN
    ;WITH HealthCount AS (
        SELECT AttendingCoach AS CoachID, COUNT(*) AS Cnt
        FROM #LessonItems
        WHERE PriceStatus IN (@StatusSR, @StatusPointExchange)
        GROUP BY AttendingCoach
    ),
    DietitianCount AS (
        SELECT AttendingCoach AS CoachID, COUNT(*) AS Cnt
        FROM #LessonItems
        WHERE PriceStatus IN (@StatusDietitian, @StatusPointExchange, @StatusTrial)
        GROUP BY AttendingCoach
    ),
    Seniority AS (
        SELECT s.CoachID,
               CASE WHEN s.LevelID IN (40,41,49,50) THEN
                    CASE WHEN COALESCE(s.JobTenureInDays, 0) / 365 >= 10 THEN 0.010
                         WHEN COALESCE(s.JobTenureInDays, 0) / 365 >= 8 THEN 0.008
                         WHEN COALESCE(s.JobTenureInDays, 0) / 365 >= 5 THEN 0.004
                         ELSE 0 END
                    ELSE 0 END AS SeniorityPct
        FROM Report.CoachMonthlySalary AS s
        WHERE s.SettlementID = @SettlementID
    ),
    HealthBonus AS (
        SELECT s.CoachID,
               FLOOR(COALESCE(SUM(FLOOR(COALESCE(s.PTAverageUnitPrice,0) / 1.05 + 0.5)
                    * (CASE WHEN COALESCE(hc.Cnt,0) > tier.UpperBound THEN tier.UpperBound ELSE COALESCE(hc.Cnt,0) END - tier.LowerBound + 1)
                    * (tier.Pct + sn.SeniorityPct)), 0) + 0.5) AS AttendanceBonus
        FROM Report.CoachMonthlySalary AS s
        JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID AND rc.CategoryID = @CategoryHealth
        JOIN Seniority AS sn ON sn.CoachID = s.CoachID
        LEFT JOIN HealthCount AS hc ON hc.CoachID = s.CoachID
        CROSS APPLY (VALUES
            (51, 60, 0.30), (61, 70, 0.35), (71, 80, 0.40), (81, 90, 0.45),
            (91,100, 0.50), (101,110,0.55), (111,120,0.65), (121,130,0.65), (131,2147483647,0.70)
        ) AS tier(LowerBound, UpperBound, Pct)
        WHERE s.SettlementID = @SettlementID
          AND COALESCE(hc.Cnt,0) >= tier.LowerBound
        GROUP BY s.CoachID
    ),
    DietitianBonus AS (
        SELECT s.CoachID,
               COALESCE(dc.Cnt, 0) AS Cnt,
               CASE
                   WHEN s.LevelID = 37 AND COALESCE(dc.Cnt,0) >= 36 THEN (COALESCE(dc.Cnt,0)-15) * 250
                   WHEN s.LevelID = 37 AND COALESCE(dc.Cnt,0) >= 16 THEN (COALESCE(dc.Cnt,0)-15) * 200
                   WHEN s.LevelID = 38 AND COALESCE(dc.Cnt,0) >= 46 THEN (COALESCE(dc.Cnt,0)-15) * 350
                   WHEN s.LevelID = 38 AND COALESCE(dc.Cnt,0) >= 36 THEN (COALESCE(dc.Cnt,0)-15) * 300
                   WHEN s.LevelID = 38 AND COALESCE(dc.Cnt,0) >= 16 THEN (COALESCE(dc.Cnt,0)-15) * 250
                   WHEN s.LevelID = 42 AND COALESCE(dc.Cnt,0) >= 51 THEN (COALESCE(dc.Cnt,0)-15) * 400
                   WHEN s.LevelID = 42 AND COALESCE(dc.Cnt,0) >= 36 THEN (COALESCE(dc.Cnt,0)-15) * 350
                   WHEN s.LevelID = 42 AND COALESCE(dc.Cnt,0) >= 16 THEN (COALESCE(dc.Cnt,0)-15) * 300
                   WHEN s.LevelID = 43 AND COALESCE(dc.Cnt,0) >= 56 THEN (COALESCE(dc.Cnt,0)-15) * 550
                   WHEN s.LevelID = 43 AND COALESCE(dc.Cnt,0) >= 36 THEN (COALESCE(dc.Cnt,0)-15) * 400
                   WHEN s.LevelID = 43 AND COALESCE(dc.Cnt,0) >= 16 THEN (COALESCE(dc.Cnt,0)-15) * 350
                   WHEN s.LevelID = 44 AND COALESCE(dc.Cnt,0) >= 61 THEN (COALESCE(dc.Cnt,0)-15) * 600
                   WHEN s.LevelID = 44 AND COALESCE(dc.Cnt,0) >= 36 THEN (COALESCE(dc.Cnt,0)-15) * 450
                   WHEN s.LevelID = 44 AND COALESCE(dc.Cnt,0) >= 16 THEN (COALESCE(dc.Cnt,0)-15) * 400
                   ELSE 0
               END AS AttendanceBonus
        FROM Report.CoachMonthlySalary AS s
        JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID AND rc.CategoryID = @CategoryDietitian
        LEFT JOIN DietitianCount AS dc ON dc.CoachID = s.CoachID
        WHERE s.SettlementID = @SettlementID
    )
    UPDATE s
    SET s.PTAttendanceCount = CASE WHEN rc.CategoryID = @CategoryHealth THEN COALESCE(hc.Cnt,0) ELSE COALESCE(db.Cnt,0) END,
        s.AttendanceBonus = CASE WHEN rc.CategoryID = @CategoryHealth THEN COALESCE(hb.AttendanceBonus,0) ELSE COALESCE(db.AttendanceBonus,0) END,
        s.AttendedByOther = CASE WHEN rc.CategoryID = @CategoryHealth THEN 0 ELSE s.AttendedByOther END,
        s.AttendedShare = CASE WHEN rc.CategoryID = @CategoryHealth THEN 0 ELSE s.AttendedShare END,
        s.AttendedByOtherAvgPrice = CASE WHEN rc.CategoryID = @CategoryHealth THEN 0 ELSE s.AttendedByOtherAvgPrice END
    FROM Report.CoachMonthlySalary AS s
    JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
    LEFT JOIN HealthCount AS hc ON hc.CoachID = s.CoachID
    LEFT JOIN HealthBonus AS hb ON hb.CoachID = s.CoachID
    LEFT JOIN DietitianBonus AS db ON db.CoachID = s.CoachID
    WHERE s.SettlementID = @SettlementID;
END;

/* manager / FES / RFM / officer */
;WITH Grade AS (
    SELECT pl.LevelID, COALESCE(sd.CommissionGrade, 0) AS CommissionGrade
    FROM dbo.ProfessionalLevel AS pl
    LEFT JOIN dbo.ProfessionalLevelBasicSalary AS bs ON bs.LevelID = pl.LevelID
    LEFT JOIN dbo.SalaryDetails AS sd ON sd.SalaryID = bs.SalaryID
)
UPDATE s
SET s.GradeIndex = g.CommissionGrade,
    s.AttendanceBonus =
        CASE
            WHEN @ForRole = N'manager' THEN CAST(FLOOR((CASE WHEN COALESCE(s.PTAttendanceCount,0) < 40 THEN COALESCE(s.PTAttendanceCount,0) ELSE 40 END) * FLOOR(COALESCE(s.PTAverageUnitPrice,0) / 1.05 + 0.5) * g.CommissionGrade / 100.0 + 0.5) AS int)
            WHEN @ForRole = N'fes' THEN CAST(FLOOR((CASE WHEN COALESCE(s.PTAttendanceCount,0) < 70 THEN COALESCE(s.PTAttendanceCount,0) ELSE 70 END) * FLOOR(COALESCE(s.PTAverageUnitPrice,0) / 1.05 + 0.5) * g.CommissionGrade / 100.0 + 0.5) AS int)
            WHEN @ForRole = N'rfm' THEN CAST(FLOOR((CASE WHEN COALESCE(s.PTAttendanceCount,0) < 60 THEN COALESCE(s.PTAttendanceCount,0) ELSE 60 END) * FLOOR(COALESCE(s.PTAverageUnitPrice,0) / 1.05 + 0.5) * g.CommissionGrade / 100.0 + 0.5) AS int)
            WHEN @ForRole = N'officer' THEN CAST(FLOOR((CASE WHEN COALESCE(s.PTAttendanceCount,0) < 70 THEN COALESCE(s.PTAttendanceCount,0) ELSE 70 END) * FLOOR(COALESCE(s.PTAverageUnitPrice,0) / 1.05 + 0.5) * g.CommissionGrade / 100.0 + 0.5) AS int)
            ELSE s.AttendanceBonus
        END,
    s.ManagerBonus =
        CASE WHEN @ForRole IN (N'manager', N'fes', N'rfm') THEN 0 ELSE s.ManagerBonus END
FROM Report.CoachMonthlySalary AS s
JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
LEFT JOIN Grade AS g ON g.LevelID = s.LevelID
WHERE s.SettlementID = @SettlementID
  AND @ForRole IN (N'manager', N'fes', N'rfm', N'officer');

/* manager / vice manager branch totals and KPI management grade */
IF @ForRole IN (N'manager', N'vicemanager')
BEGIN
    IF OBJECT_ID('tempdb..#ManagerBranch') IS NOT NULL DROP TABLE #ManagerBranch;
    IF OBJECT_ID('tempdb..#Kpi') IS NOT NULL DROP TABLE #Kpi;

    SELECT
        rc.CoachID,
        COALESCE(bs.BranchID, cw.SingleBranchID) AS BranchID,
        rc.IsApprentice
    INTO #ManagerBranch
    FROM #RoleCoach AS rc
    OUTER APPLY (
        SELECT TOP (1) b.BranchID
        FROM dbo.BranchStore AS b
        WHERE (@ForRole = N'manager' AND b.ManagerID = rc.CoachID)
           OR (@ForRole = N'vicemanager' AND b.ViceManagerID = rc.CoachID)
    ) AS bs
    OUTER APPLY (
        SELECT CASE WHEN COUNT(*) = 1 THEN MAX(cw.BranchID) END AS SingleBranchID
        FROM dbo.CoachWorkplace AS cw
        WHERE cw.CoachID = rc.CoachID
    ) AS cw
    WHERE COALESCE(bs.BranchID, cw.SingleBranchID) IS NOT NULL;

    INSERT INTO Report.CoachBranchMonthlyBonus (CoachID, SettlementID, BranchID)
    SELECT mb.CoachID, @SettlementID, mb.BranchID
    FROM #ManagerBranch AS mb
    WHERE NOT EXISTS (
        SELECT 1 FROM Report.CoachBranchMonthlyBonus AS b
        WHERE b.CoachID = mb.CoachID
          AND b.SettlementID = @SettlementID
          AND b.BranchID = mb.BranchID
    );

    ;WITH BranchItems AS (
        SELECT
            mb.CoachID,
            mb.BranchID,
            COUNT(c.LessonID) AS BranchTotalAttendanceCount,
            CAST(COALESCE(SUM(CASE WHEN c.EnterpriseRegisterID IS NULL
                THEN c.CoachPayoff * c.GroupingMemberCount * c.TuitionIndex * c.PercentageOfDiscount / 100.0
                ELSE 0 END), 0)
                + COALESCE(SUM(CASE WHEN c.EnterpriseRegisterID IS NOT NULL
                THEN c.EnterpriseCoachPayoff * c.TuitionIndex * c.PercentageOfDiscount / 100.0
                ELSE 0 END), 0) AS int) AS BranchTotalTuition
        FROM #ManagerBranch AS mb
        LEFT JOIN #Countable AS c ON c.WorkPlace = mb.BranchID
        GROUP BY mb.CoachID, mb.BranchID
    ),
    BranchVoid AS (
        SELECT mb.CoachID, mb.BranchID, SUM(ta.VoidShare) AS VoidShare
        FROM #ManagerBranch AS mb
        JOIN dbo.PaymentTransaction AS pt ON pt.BranchID = mb.BranchID
        JOIN dbo.Payment AS p ON p.PaymentID = pt.PaymentID AND p.AllowanceID IS NOT NULL
        JOIN dbo.VoidPayment AS vp ON vp.VoidID = p.PaymentID
        JOIN dbo.TuitionAchievement AS ta ON ta.InstallmentID = p.PaymentID
        WHERE vp.VoidDate >= @StartDate
          AND vp.VoidDate < @EndExclusiveDate
        GROUP BY mb.CoachID, mb.BranchID
    )
    UPDATE b
    SET b.BranchTotalAttendanceCount = bi.BranchTotalAttendanceCount,
        b.BranchTotalTuition = bi.BranchTotalTuition,
        b.VoidShare = COALESCE(bv.VoidShare, 0)
    FROM Report.CoachBranchMonthlyBonus AS b
    JOIN BranchItems AS bi
      ON bi.CoachID = b.CoachID
     AND bi.BranchID = b.BranchID
    LEFT JOIN BranchVoid AS bv
      ON bv.CoachID = b.CoachID
     AND bv.BranchID = b.BranchID
    WHERE b.SettlementID = @SettlementID;

    ;WITH Indicator AS (
        SELECT TOP (1) PeriodID
        FROM KPI.MonthlyIndicator
        WHERE StartDate <= @StartDate
          AND EndExclusiveDate > @StartDate
    )
        SELECT
            mb.CoachID,
            mb.BranchID,
            COALESCE(g.ActualCompleteLessonCount,0) + COALESCE(g.SRCount,0) + COALESCE(g.SDCount,0) + COALESCE(g.ATCount,0) AS BranchTotalPTCount,
            COALESCE(g.ActualLessonAchievement,0) + COALESCE(g.SRAchievement,0) + COALESCE(g.SDAchievement,0) + COALESCE(g.ATAchievement,0) AS BranchTotalPTTuition,
            ROUND(CAST(COALESCE(g.ActualLessonAchievement,0) + COALESCE(g.SRAchievement,0) + COALESCE(g.SDAchievement,0) + COALESCE(g.ATAchievement,0)
                + COALESCE(g.ActualSharedAchievement,0) - COALESCE(g.VoidShare,0) AS decimal(18,4))
                * rg.IndicatorPercentage / NULLIF(i.RevenueGoal,0), 0) AS AchievementRatio,
            CASE
                WHEN ROUND(CAST(COALESCE(g.ActualLessonAchievement,0) + COALESCE(g.SRAchievement,0) + COALESCE(g.SDAchievement,0) + COALESCE(g.ATAchievement,0)
                    + COALESCE(g.ActualSharedAchievement,0) - COALESCE(g.VoidShare,0) AS decimal(18,4))
                    * rg.IndicatorPercentage / NULLIF(i.RevenueGoal,0), 0) >= 130 THEN 0
                WHEN ROUND(CAST(COALESCE(g.ActualLessonAchievement,0) + COALESCE(g.SRAchievement,0) + COALESCE(g.SDAchievement,0) + COALESCE(g.ATAchievement,0)
                    + COALESCE(g.ActualSharedAchievement,0) - COALESCE(g.VoidShare,0) AS decimal(18,4))
                    * rg.IndicatorPercentage / NULLIF(i.RevenueGoal,0), 0) >= 120 THEN 1
                WHEN ROUND(CAST(COALESCE(g.ActualLessonAchievement,0) + COALESCE(g.SRAchievement,0) + COALESCE(g.SDAchievement,0) + COALESCE(g.ATAchievement,0)
                    + COALESCE(g.ActualSharedAchievement,0) - COALESCE(g.VoidShare,0) AS decimal(18,4))
                    * rg.IndicatorPercentage / NULLIF(i.RevenueGoal,0), 0) >= 110 THEN 2
                WHEN ROUND(CAST(COALESCE(g.ActualLessonAchievement,0) + COALESCE(g.SRAchievement,0) + COALESCE(g.SDAchievement,0) + COALESCE(g.ATAchievement,0)
                    + COALESCE(g.ActualSharedAchievement,0) - COALESCE(g.VoidShare,0) AS decimal(18,4))
                    * rg.IndicatorPercentage / NULLIF(i.RevenueGoal,0), 0) >= 100 THEN 3
            END AS BonusIdx
        INTO #Kpi
        FROM #ManagerBranch AS mb
        JOIN Indicator AS mi ON 1 = 1
        JOIN KPI.MonthlyBranchRevenueIndicator AS i ON i.PeriodID = mi.PeriodID AND i.BranchID = mb.BranchID
        JOIN KPI.MonthlyBranchRevenueGoal AS g ON g.PeriodID = i.PeriodID AND g.BranchID = i.BranchID AND g.GradeID = i.GradeID
        JOIN KPI.MonthlyRevenueGrade AS rg ON rg.GradeID = i.GradeID;

    UPDATE b
    SET b.BranchTotalPTCount = k.BranchTotalPTCount,
        b.BranchTotalPTTuition = k.BranchTotalPTTuition
    FROM Report.CoachBranchMonthlyBonus AS b
    JOIN #Kpi AS k ON k.CoachID = b.CoachID AND k.BranchID = b.BranchID
    WHERE b.SettlementID = @SettlementID;

    UPDATE s
    SET s.ManagementBonusGrade =
        CASE
            WHEN @ForRole = N'vicemanager' AND rc.IsApprentice = 1 THEN
                CASE k.BonusIdx WHEN 0 THEN 0.005 WHEN 1 THEN 0.004 WHEN 2 THEN 0.003 WHEN 3 THEN 0.002 ELSE s.ManagementBonusGrade END
            WHEN @ForRole = N'vicemanager' THEN
                CASE k.BonusIdx WHEN 0 THEN 0.010 WHEN 1 THEN 0.008 WHEN 2 THEN 0.006 WHEN 3 THEN 0.005 ELSE s.ManagementBonusGrade END
            ELSE s.ManagementBonusGrade
        END,
        s.ManagerBonus = 0
    FROM Report.CoachMonthlySalary AS s
    JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
    JOIN #Kpi AS k ON k.CoachID = s.CoachID
    WHERE s.SettlementID = @SettlementID;

    MERGE Report.BranchMonthlySummary AS target
    USING (
        SELECT BranchID, MAX(AchievementRatio) AS AchievementRatio
        FROM #Kpi
        GROUP BY BranchID
    ) AS src
    ON target.SettlementID = @SettlementID
   AND target.BranchID = src.BranchID
    WHEN MATCHED THEN
        UPDATE SET AchievementRatio = src.AchievementRatio
    WHEN NOT MATCHED THEN
        INSERT (SettlementID, BranchID, AchievementRatio)
        VALUES (@SettlementID, src.BranchID, src.AchievementRatio);
END;

/* vice manager non-apprentice attendance bonus table; apprentice keeps coach bonus + management grade logic above */
IF @ForRole = N'vicemanager'
BEGIN
    UPDATE s
    SET s.AttendanceBonus =
        CASE
            WHEN att.AttendanceCount >= 91 THEN 47000
            WHEN att.AttendanceCount >= 86 THEN 44500
            WHEN att.AttendanceCount >= 81 THEN 42000
            WHEN att.AttendanceCount >= 76 THEN 39500
            WHEN att.AttendanceCount >= 71 THEN 37000
            WHEN att.AttendanceCount >= 66 THEN 34500
            WHEN att.AttendanceCount >= 61 THEN 32000
            WHEN att.AttendanceCount >= 56 THEN 29500
            WHEN att.AttendanceCount >= 51 THEN 27000
            WHEN att.AttendanceCount >= 46 THEN 24500
            WHEN att.AttendanceCount >= 41 THEN 22000
            WHEN att.AttendanceCount >= 36 THEN 19500
            WHEN att.AttendanceCount >= 31 THEN 17000
            WHEN att.AttendanceCount >= 26 THEN 14500
            WHEN att.AttendanceCount >= 21 THEN 12000
            WHEN att.AttendanceCount >= 16 THEN 9500
            WHEN att.AttendanceCount >= 11 THEN 7000
            ELSE 0
        END,
        s.ManagerBonus = 0
    FROM Report.CoachMonthlySalary AS s
    JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID AND rc.IsApprentice = 0
    OUTER APPLY (
        SELECT COALESCE(SUM(b.AchievementAttendanceCount),0) AS AttendanceCount
        FROM Report.CoachBranchMonthlyBonus AS b
        WHERE b.CoachID = s.CoachID
          AND b.SettlementID = @SettlementID
    ) AS att
    WHERE s.SettlementID = @SettlementID;
END;

/* officer branch totals and 1% all-lesson management bonus */
IF @ForRole = N'officer'
BEGIN
    INSERT INTO Report.CoachBranchMonthlyBonus (CoachID, SettlementID, BranchID)
    SELECT rc.CoachID, @SettlementID, bs.BranchID
    FROM #RoleCoach AS rc
    CROSS JOIN dbo.BranchStore AS bs
    WHERE NOT EXISTS (
        SELECT 1 FROM Report.CoachBranchMonthlyBonus AS b
        WHERE b.CoachID = rc.CoachID
          AND b.SettlementID = @SettlementID
          AND b.BranchID = bs.BranchID
    );

    ;WITH BranchAgg AS (
        SELECT
            rc.CoachID,
            bs.BranchID,
            COUNT(c.LessonID) AS BranchTotalAttendanceCount,
            CAST(COALESCE(SUM(CASE WHEN c.EnterpriseRegisterID IS NULL
                THEN c.CoachPayoff * c.GroupingMemberCount * c.TuitionIndex * c.PercentageOfDiscount / 100.0
                ELSE 0 END), 0)
                + COALESCE(SUM(CASE WHEN c.EnterpriseRegisterID IS NOT NULL
                THEN c.EnterpriseCoachPayoff * c.TuitionIndex * c.PercentageOfDiscount / 100.0
                ELSE 0 END), 0) AS int) AS BranchTotalTuition
        FROM #RoleCoach AS rc
        CROSS JOIN dbo.BranchStore AS bs
        LEFT JOIN #Countable AS c ON c.BranchID = bs.BranchID
        GROUP BY rc.CoachID, bs.BranchID
    )
    UPDATE b
    SET b.BranchTotalAttendanceCount = a.BranchTotalAttendanceCount,
        b.BranchTotalTuition = a.BranchTotalTuition
    FROM Report.CoachBranchMonthlyBonus AS b
    JOIN BranchAgg AS a ON a.CoachID = b.CoachID AND a.BranchID = b.BranchID
    WHERE b.SettlementID = @SettlementID;

    ;WITH LessonAchievement AS (
        SELECT CAST(
            COALESCE(SUM(CASE WHEN PriceStatus IN (@StatusGeneral, @StatusDeleted, @StatusGroupMember)
                THEN ListPrice * GroupingMemberCount * PercentageOfDiscount / 100.0 ELSE 0 END), 0)
            + COALESCE(SUM(CASE WHEN ELStatus IN (@StatusGeneral, @StatusDeleted, @StatusGroupMember)
                THEN EnterpriseListPrice * GroupingMemberCount * PercentageOfDiscount / 100.0 ELSE 0 END), 0)
            AS int) AS Amount
        FROM #LessonItems
    )
    UPDATE s
    SET s.ManagerBonus = CAST(FLOOR(la.Amount / 1.05 * 0.01 + 0.5) AS int)
    FROM Report.CoachMonthlySalary AS s
    JOIN #RoleCoach AS rc ON rc.CoachID = s.CoachID
    CROSS JOIN LessonAchievement AS la
    WHERE s.SettlementID = @SettlementID;
END;

COMMIT;

SELECT *
FROM Report.CoachMonthlySalary
WHERE SettlementID = @SettlementID
ORDER BY CoachID;
