/*===========================================================================
  補結算：將結算後才新增的 ContractTrustTrack 併入其 EventDate 所屬的結算期別

  對象：ContractID = 67906 / LessonID = 679049 (TrustID 550645, TrustType 'N',
        EventDate 2026-07-31 20:30) → 屬於 SettlementID 123 (2026-07-01 ~ 2026-08-01)

  邏輯完全對應 WebDev/Helper/BusinessExtensionMethods.cs 的 ExecuteSettlement()：
    B / T : TotalTrustAmount   += Payment.PayoffAmount
    X / S : TotalTrustAmount   -= ReturnAmount
            BookingTrustAmount -= ReturnAmount
    V     : TotalTrustAmount   -= VoidPayment.Payment.PayoffAmount
    N     : TotalTrustAmount   -= ListPrice * GroupingMemberCount * PercentageOfDiscount / 100
            BookingTrustAmount -= (同上)
    最後   CurrentLiableAmount  = BookingTrustAmount - TotalTrustAmount

  註：金額一律整數運算（與 C# int 運算一致），勿改為 decimal。
===========================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ContractID int = 67906;
DECLARE @LessonID   int = 679049;   -- 只補這筆；設為 NULL 可補該合約所有漏結算的異動

------------------------------------------------------------------------
-- 1. 找出「尚未結算，但 EventDate 已落在既有結算期別內」的異動並算出增減額
------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Patch') IS NOT NULL DROP TABLE #Patch;

SELECT  k.TrustID,
        k.ContractID,
        k.TrustType,
        k.EventDate,
        s.SettlementID,
        DeltaTotal = CASE k.TrustType
                        WHEN 'B' THEN  ISNULL(pay.PayoffAmount, 0)
                        WHEN 'T' THEN  ISNULL(pay.PayoffAmount, 0)
                        WHEN 'X' THEN -ISNULL(k.ReturnAmount, 0)
                        WHEN 'S' THEN -ISNULL(k.ReturnAmount, 0)
                        WHEN 'V' THEN -ISNULL(voidPay.PayoffAmount, 0)
                        WHEN 'N' THEN -ISNULL(p.ListPrice * r.GroupingMemberCount * g.PercentageOfDiscount / 100, 0)
                        ELSE 0
                     END,
        DeltaBooking = CASE k.TrustType
                        WHEN 'X' THEN -ISNULL(k.ReturnAmount, 0)
                        WHEN 'S' THEN -ISNULL(k.ReturnAmount, 0)
                        WHEN 'N' THEN -ISNULL(p.ListPrice * r.GroupingMemberCount * g.PercentageOfDiscount / 100, 0)
                        ELSE 0
                     END
INTO    #Patch
FROM    ContractTrustTrack k
        INNER JOIN Settlement s
                ON k.EventDate >= s.StartDate AND k.EventDate < s.EndExclusiveDate
        LEFT  JOIN Payment pay      ON pay.PaymentID = k.PaymentID
        LEFT  JOIN VoidPayment v    ON v.VoidID      = k.VoidID
        LEFT  JOIN Payment voidPay  ON voidPay.PaymentID = v.VoidID
        LEFT  JOIN LessonTime t     ON t.LessonID    = k.LessonID
        LEFT  JOIN RegisterLesson r ON r.RegisterID  = t.RegisterID
        LEFT  JOIN LessonPriceType p ON p.PriceID    = r.ClassLevel
        LEFT  JOIN GroupingLessonDiscount g ON g.GroupingMemberCount = r.GroupingMemberCount
WHERE   k.SettlementID IS NULL
  AND   k.ContractID = @ContractID
  AND  (@LessonID IS NULL OR k.LessonID = @LessonID);

SELECT '待補異動' AS 項目, * FROM #Patch;

IF NOT EXISTS (SELECT 1 FROM #Patch)
BEGIN
    RAISERROR('找不到需要補結算的 ContractTrustTrack，未做任何異動。', 16, 1);
    RETURN;
END

------------------------------------------------------------------------
-- 2. 安全檢查
------------------------------------------------------------------------
-- 2-1 目標結算期別必須已有該合約的 ContractTrustSettlement 明細
IF EXISTS (SELECT 1 FROM #Patch pt
           WHERE NOT EXISTS (SELECT 1 FROM ContractTrustSettlement c
                             WHERE c.ContractID = pt.ContractID AND c.SettlementID = pt.SettlementID))
BEGIN
    RAISERROR('該合約在目標結算期別沒有 ContractTrustSettlement 明細，需改由 ExecuteSettlement 重跑。', 16, 1);
    RETURN;
END

-- 2-2 不可有更晚期別的結算（否則 InitialTrustAmount 需逐期遞延調整）
IF EXISTS (SELECT 1 FROM ContractTrustSettlement c
           WHERE c.ContractID = @ContractID
             AND c.SettlementID > (SELECT MIN(SettlementID) FROM #Patch))
BEGIN
    RAISERROR('存在更晚期別的結算資料，補帳需一併遞延調整，本腳本不處理。', 16, 1);
    RETURN;
END

------------------------------------------------------------------------
-- 3. 補帳
------------------------------------------------------------------------
BEGIN TRANSACTION;

SELECT '異動前' AS 項目, * FROM ContractTrustSettlement
WHERE ContractID = @ContractID AND SettlementID IN (SELECT SettlementID FROM #Patch);

-- 3-1 累加金額
UPDATE  c
SET     c.TotalTrustAmount   = c.TotalTrustAmount   + d.DeltaTotal,
        c.BookingTrustAmount = c.BookingTrustAmount + d.DeltaBooking
FROM    ContractTrustSettlement c
        INNER JOIN (SELECT ContractID, SettlementID,
                           DeltaTotal   = SUM(DeltaTotal),
                           DeltaBooking = SUM(DeltaBooking)
                    FROM #Patch GROUP BY ContractID, SettlementID) d
                ON d.ContractID = c.ContractID AND d.SettlementID = c.SettlementID;

-- 3-2 重算應計提差額
UPDATE  c
SET     c.CurrentLiableAmount = c.BookingTrustAmount - c.TotalTrustAmount
FROM    ContractTrustSettlement c
        INNER JOIN (SELECT DISTINCT ContractID, SettlementID FROM #Patch) d
                ON d.ContractID = c.ContractID AND d.SettlementID = c.SettlementID;

-- 3-3 標記異動已結算
UPDATE  k
SET     k.SettlementID = pt.SettlementID
FROM    ContractTrustTrack k
        INNER JOIN #Patch pt ON pt.TrustID = k.TrustID;

-- 3-4 與 ExecuteSettlement 一致：確保合約已標記信託
UPDATE  CourseContract
SET     Entrusted = 1
WHERE   ContractID = @ContractID AND ISNULL(Entrusted, 0) = 0;

SELECT '異動後' AS 項目, * FROM ContractTrustSettlement
WHERE ContractID = @ContractID AND SettlementID IN (SELECT SettlementID FROM #Patch);

SELECT '異動後 Track' AS 項目, TrustID, ContractID, EventDate, TrustType, SettlementID, LessonID
FROM    ContractTrustTrack
WHERE   ContractID = @ContractID ORDER BY TrustID;

-- 確認無誤後改為 COMMIT TRANSACTION;
ROLLBACK TRANSACTION;
--COMMIT TRANSACTION;

DROP TABLE #Patch;
