-- 執行前請確認：
-- A. 請先準備全新的 InsightFitPro_Sit 資料庫。
-- B. 請先手動建立兩筆 ContractPackage 資料，Id 分別為 1007 (多堂課程) 與 1008 (單堂課程)，如果Id無法設定為 1007 與 1008，請自行修改第 71 行及第 182 行 ContractItem 的 ContractPackageId 為實際的 ContractPackage Id，ContractPackage 的資料如下：
--Id	IsValid	EnterpriseId	OrganizationId	ContractTypeCategoryId	Code	Name	Description	MaxEnrollment	MinEnrollment	DurationMonths	MaxRenewalCount	DisplayOrder	IsTrust	TrustRatio	CreateDate	CreateUserProfileId	UpdateDate	UpdateUserProfileId	RenewalDurationMonths	IsOnlineSelfService
--1007	1	2	NULL	1	L	舊資料轉置	舊資料轉置	1	1	1	1	1000	1	1.0000	2026-05-16 00:00:00.0000000	1	NULL	NULL	0	0
--1008	1	2	NULL	7	S	舊資料轉置	舊資料轉置	1	1	1	1	1000	1	1.0000	2026-05-16 00:00:00.0000000	1	NULL	NULL	0	0
-- C. 請將 Organization 超越體能顧問股份有限公司總公司	總公司 統編尾加星號 -> 24928211* ，轉完資料後再改回原本的統編 24928211
USE [InsightFitPro_Sit]
GO
update [dbo].Organization set ReceiptNo= ReceiptNo+ '*' where Id=3
go
SET IDENTITY_INSERT [dbo].[ContractPackage] ON 
GO
INSERT [dbo].[ContractPackage] ([Id], [IsValid], [EnterpriseId], [OrganizationId], [ContractTypeCategoryId], [Code], [Name], [Description], [MaxEnrollment], [MinEnrollment], [DurationMonths], [MaxRenewalCount], [DisplayOrder], [IsTrust], [TrustRatio], [CreateDate], [CreateUserProfileId], [UpdateDate], [UpdateUserProfileId], [RenewalDurationMonths], [IsOnlineSelfService]) VALUES (1007, 1, 2, NULL, 1, N'L', N'舊資料轉置', N'舊資料轉置', 1, 1, 1, 1, 1000, 1, CAST(1.0000 AS Decimal(5, 4)), CAST(N'2026-05-16T00:00:00.0000000' AS DateTime2), 1, NULL, NULL, 0, 0)
GO
INSERT [dbo].[ContractPackage] ([Id], [IsValid], [EnterpriseId], [OrganizationId], [ContractTypeCategoryId], [Code], [Name], [Description], [MaxEnrollment], [MinEnrollment], [DurationMonths], [MaxRenewalCount], [DisplayOrder], [IsTrust], [TrustRatio], [CreateDate], [CreateUserProfileId], [UpdateDate], [UpdateUserProfileId], [RenewalDurationMonths], [IsOnlineSelfService]) VALUES (1008, 1, 2, NULL, 7, N'S', N'舊資料轉置', N'舊資料轉置', 1, 1, 1, 1, 1000, 1, CAST(1.0000 AS Decimal(5, 4)), CAST(N'2026-05-16T00:00:00.0000000' AS DateTime2), 1, NULL, NULL, 0, 0)
GO
SET IDENTITY_INSERT [dbo].[ContractPackage] OFF
GO
-- D. Beyond DB 名稱為 BeyondFitnessProd2，目標 DB 為 InsightFitPro_Sit，如果不同請自行修改
---------------------------------------------------------------------------------------------------------
use master
go
-- 1. UserProfile
set identity_insert InsightFitPro_Sit.dbo.UserProfile on
INSERT INTO InsightFitPro_Sit.dbo.UserProfile
         (Id, IsValid, EnterpriseId, UserName, PID, Password, MemberCode, Avatar, RealName, Gender, Birthday, NickName, CountryCode, CountryDial, Phone, Email, AdministrativeDistrictId, Address, IDNo, RegisterStatus, EmergencyContactCountryDial, 
         EmergencyContactPhone, EmergencyContactPerson, EmergencyContactRelationship, CoachLevelId, CustomerLevelId, MicrosoftId, LineId, GoogleId, IsEmployee, IsCustomer, IsForeigner, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT u.UID AS Id
, CASE WHEN u.LevelID IN (1001,1003) THEN 1 ELSE 0 END AS IsValid, 2 AS EnterpriseId, u.UserName, u.PID, u.Password, u.MemberCode, SUBSTRING(a.StoredPath, CHARINDEX('logs', a.StoredPath), LEN(a.StoredPath)) AS Avatar, u.RealName
, CASE WHEN t.Gender = 'M' THEN 1 WHEN t.Gender = 'F' THEN 2 ELSE 9 END AS Gender
, u.Birthday, u.Nickname, t.CountryCode, NULL 
         AS CountryDial, u.Phone, u.PID AS Email, NULL AS AdministrativeDistrictId, u.Address, t.IDNo, t.RegisterStatus, NULL AS EmergencyContactCountryDial, t.EmergencyContactPhone, t.EmergencyContactPerson, NULL AS EmergencyContactRelationship, NULL 
         AS CoachLevelId, NULL AS CustomerLevelId, NULL AS MicrosoftId, t.LineID, NULL AS GoogleId, CASE WHEN EXISTS
             (SELECT 1
           FROM    BeyondFitnessProd2.dbo.ServingCoach
           WHERE  ServingCoach.CoachID = u.UID) THEN 1 ELSE 0 END AS IsEmployee, CASE WHEN t.CurrentTrial = 0 OR
         t.CurrentTrial IS NULL THEN 1 ELSE 0 END AS IsCustomer, CASE WHEN t.CountryCode = 'XXXX' THEN 1 ELSE 0 END AS IsForeigner
         , ISNULL(u.CreateTime,GETDATE()) AS CreateDate
         , 1 AS CreateUserProfileId, NULL AS UpdateDate, NULL 
         AS UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.UserProfile AS u INNER JOIN
         BeyondFitnessProd2.dbo.UserProfileExtension AS t ON u.UID = t.UID LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.Attachment AS a ON u.PictureID = a.AttachmentID
WHERE (u.UID > 1)
set identity_insert InsightFitPro_Sit.dbo.UserProfile off
go

-- 2. Document and DocumentType (多堂)
set identity_insert InsightFitPro_Sit.dbo.Document on
INSERT INTO InsightFitPro_Sit.dbo.[Document]
         (Id, DocumentTypeId, DocDate)
SELECT ContractID AS Id, 1 AS DocumentTypeId, ContractDate AS DocDate
FROM   BeyondFitnessProd2.dbo.CourseContract
WHERE (SequenceNo = 0)

INSERT INTO InsightFitPro_Sit.dbo.[Document]
         (Id, DocumentTypeId, DocDate)
SELECT ContractID AS Id, 2 AS DocumentTypeId, ContractDate AS DocDate
FROM   BeyondFitnessProd2.dbo.CourseContract
WHERE (SequenceNo > 0)
set identity_insert InsightFitPro_Sit.dbo.Document off
go

-- 3. Contract and ContractItem

INSERT INTO InsightFitPro_Sit.dbo.Contract
         (DocumentId, IsValid, EnterpriseId, OrganizationId, OwnerUserProfileId, Lessons, Remark, StatusCommonPropertyId, ContractNo, TotalPrice, SettlementPrice, EffectiveDate, PayoffDueDate, FirstContractInstallmentId, Version, DiscountPromotionId, 
         PaymentBranchId, PaymentMethodCommonProertyId, ValidTo, NewestContractAmendmentId, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT c.ContractID AS DocumentId, CASE WHEN c.Status = 1205 THEN 1 ELSE 0 END AS IsValid, 2 AS EnterpriseId, ot.Id AS OrganizationId, c.OwnerID AS OwnerUserProfileId, c.Lessons, c.Remark, c.Status AS StatusCommonPropertyId, c.ContractNo, 
         c.TotalCost AS TotalPrice, c.TotalCost AS SettlementPrice, c.EffectiveDate, c.PayoffDue AS PayoffDueDate, NULL AS FirstContractInstallmentId, c.SequenceNo + 1 AS Version, NULL AS DiscountPromotionId, bt.Id AS PaymentBranchId, 
         CASE WHEN t.PaymentMethod LIKE '%刷卡%' THEN 101 WHEN t.PaymentMethod LIKE '%轉帳%' THEN 102 ELSE 100 END AS PaymentMethodCommonProertyId, c.ValidTo, NULL 
         AS NewestContractAmendmentId, c.ContractDate AS CreateDate, 1 AS CreateUserProfileId, ot.UpdateDate, ot.UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.CourseContract AS c INNER JOIN
         BeyondFitnessProd2.dbo.CourseContractExtension AS t ON c.ContractID = t.ContractID INNER JOIN
         BeyondFitnessProd2.dbo.BranchStore AS bs ON t.BranchID = bs.BranchID INNER JOIN
         BeyondFitnessProd2.dbo.Organization AS os ON bs.BranchID = os.CompanyID INNER JOIN
         InsightFitPro_Sit.dbo.Organization AS ot ON os.ReceiptNo = ot.ReceiptNo INNER JOIN
         InsightFitPro_Sit.dbo.Branch AS bt ON ot.Id = bt.OrganizationId
WHERE (c.SequenceNo = 0)
go

INSERT INTO InsightFitPro_Sit.dbo.ContractItem
         (IsValid, EnterpriseId, ContractDocumentId, ContractPackageId, ContractNameSnapshot, CurrencySnapshot, UnitPriceSnapshot, CoachCommissionAmountSnapshot, UnitSettlementPriceSnapshot, MaxRenewalCountSnapshot, Quantity, RemainingQuantity, 
         ItemTotalAmount, IsTrustSnapshot, TrustRatioSnapshot, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId, CourseDurationSnapshot)
SELECT CASE WHEN Status = 1205 THEN 1 ELSE 0 END AS IsValid, 2 AS EnterpriseId, cc.ContractID AS ContractDocumentId, 1007 AS ContractPackageId, ct.TypeName AS ContractNameSnapshot, 'TWD' AS CurrencySnapshot, CASE WHEN PriceID = 425 THEN
             (SELECT TOP 1 LPT.ListPrice
           FROM    BeyondFitnessProd2.dbo.CourseContractOrder CCO JOIN
                     BeyondFitnessProd2.dbo.LessonPriceType LPT ON CCO.PriceID = LPT.PriceID
           WHERE  CCO.ContractID = cc.ContractID
           ORDER BY CCO.SeqNo ASC) ELSE
             (SELECT LPT.ListPrice
           FROM    BeyondFitnessProd2.dbo.LessonPriceType LPT
           WHERE  LPT.PriceID = cc.PriceID) END AS UnitPriceSnapshot, CASE WHEN PriceID = 425 THEN
             (SELECT TOP 1 LPT.CoachPayoff
           FROM    BeyondFitnessProd2.dbo.CourseContractOrder CCO JOIN
                     BeyondFitnessProd2.dbo.LessonPriceType LPT ON CCO.PriceID = LPT.PriceID
           WHERE  CCO.ContractID = cc.ContractID
           ORDER BY CCO.SeqNo ASC) ELSE
             (SELECT LPT.CoachPayoff
           FROM    BeyondFitnessProd2.dbo.LessonPriceType LPT
           WHERE  LPT.PriceID = cc.PriceID) END AS CoachCommissionAmountSnapshot, NULL AS UnitSettlementPriceSnapshot, 1 AS MaxRenewalCountSnapshot, cc.Lessons AS Quantity, ISNULL
             ((SELECT SUM(rl.Lessons) AS Expr1
            FROM   BeyondFitnessProd2.dbo.RegisterLessonContract AS rlc INNER JOIN
                     BeyondFitnessProd2.dbo.RegisterLesson AS rl ON rl.RegisterID = rlc.RegisterID
            WHERE  (rlc.ContractID = cc.ContractID) AND EXISTS
                         (SELECT 1 AS Expr1
                       FROM    BeyondFitnessProd2.dbo.RegisterLessonSharing AS rls
                       WHERE  (ShareID = rl.RegisterID))), 0) - ISNULL
             ((SELECT SUM(attended.TotalAttended) AS Expr1
            FROM   BeyondFitnessProd2.dbo.RegisterLessonContract AS rlc INNER JOIN
                         (SELECT RegisterID, ISNULL(AttendedLessons, 0) +
                                     (SELECT COUNT(*) AS Expr1
                                   FROM    BeyondFitnessProd2.dbo.LessonTime AS lt
                                   WHERE  (RegisterID = rl.RegisterID)) AS TotalAttended
                       FROM    BeyondFitnessProd2.dbo.RegisterLesson AS rl) AS attended ON attended.RegisterID = rlc.RegisterID
            WHERE  (rlc.ContractID = cc.ContractID)), 0) AS RemainingQuantity, cc.TotalCost AS ItemTotalAmount, CASE WHEN ct.TrustType = 0 THEN 0 ELSE 1 END AS IsTrustSnapshot, 0.2 AS TrustRatioSnapshot, cc.ContractDate AS CreateDate, 
         1 AS CreateUserProfileId, NULL AS UpdateDate, NULL AS UpdateUserProfileId, CASE WHEN PriceID = 425 THEN
             (SELECT TOP 1 LPT.DurationInMinutes
           FROM    BeyondFitnessProd2.dbo.CourseContractOrder CCO JOIN
                     BeyondFitnessProd2.dbo.LessonPriceType LPT ON CCO.PriceID = LPT.PriceID
           WHERE  CCO.ContractID = cc.ContractID
           ORDER BY CCO.SeqNo ASC) ELSE
             (SELECT LPT.DurationInMinutes
           FROM    BeyondFitnessProd2.dbo.LessonPriceType LPT
           WHERE  LPT.PriceID = cc.PriceID) END AS CourseDurationSnapshot
FROM   BeyondFitnessProd2.dbo.CourseContract AS cc INNER JOIN
         BeyondFitnessProd2.dbo.CourseContractType AS ct ON cc.ContractType = ct.TypeID
where cc.SequenceNo = 0
go

INSERT INTO InsightFitPro_Sit.dbo.ContractAmendment
         (IsValid, EnterpriseId, ContractDocumentId, DocumentId, RevisionNo, ParentContractAmendmentId, ReasonCommonPropertyId, ResponsibleOrganizationId, MonthExtension, ProcessingFee, CauseForEndingCommonPropertyId, ExpirationDate, 
         OperatorUserProfileId, ReferralUserProfileId, EmployeeReferralUserProfileId, BankId, BankAccount, FeeChargeStatus, ContractAttachmentId, IdCardFrontAttachmentId, IdCardBackAttachmentId, MedicalProofAttachmentId, BankbookCoverAttachmentId, 
         ContractTerminationFeeChargeId, Signature, Renewal, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT CASE WHEN cc.ContractID = s.ContractID THEN 1 ELSE 0 END AS IsValid, 2 AS EnterpriseId, ct.DocumentId AS ContractDocumentId, ct.DocumentId AS DocumentId, cc.SequenceNo AS RevisionNo, NULL AS ParentContractAmendmentId, 
         500 AS ReasonCommonPropertyId, ct.OrganizationId AS ResponsibleOrganizationId, NULL AS MonthExtension, NULL AS ProcessingFee, NULL AS CauseForEndingCommonPropertyId, cc.Expiration AS ExpirationDate, 
         cc.FitnessConsultant AS OperatorUserProfileId, NULL AS ReferralUserProfileId, NULL AS EmployeeReferralUserProfileId, NULL AS BankId, NULL AS BankAccount, NULL AS FeeChargeStatus, NULL AS ContractAttachmentId, NULL 
         AS IdCardFrontAttachmentId, NULL AS IdCardBackAttachmentId, NULL AS MedicalProofAttachmentId, NULL AS BankbookCoverAttachmentId, NULL AS ContractTerminationFeeChargeId, NULL AS Signature, cc.Renewal, ct.CreateDate, ct.CreateUserProfileId, 
         ct.UpdateDate, ct.UpdateUserProfileId
FROM   (SELECT MAX(ContractID) AS ContractID, ContractNo
         FROM    BeyondFitnessProd2.dbo.CourseContract AS c1
         GROUP BY ContractNo) AS s INNER JOIN
         BeyondFitnessProd2.dbo.CourseContract AS cc ON s.ContractNo = cc.ContractNo INNER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct ON cc.ContractID = ct.DocumentId
WHERE (cc.SequenceNo = 0)
go

UPDATE InsightFitPro_Sit.dbo.Contract
SET     NewestContractAmendmentId = InsightFitPro_Sit.dbo.ContractAmendment.Id
FROM   InsightFitPro_Sit.dbo.Contract INNER JOIN
         InsightFitPro_Sit.dbo.ContractAmendment ON InsightFitPro_Sit.dbo.Contract.DocumentId = InsightFitPro_Sit.dbo.ContractAmendment.ContractDocumentId
go

INSERT INTO InsightFitPro_Sit.dbo.ContractMember
         (ContractContractAmendmentId, UserProfileId, PlusMinusFlag)
SELECT ct.NewestContractAmendmentId AS ContractContractAmendmentId, cm.UID AS UserProfileId, 1 AS PlusMinusFlag
FROM   BeyondFitnessProd2.dbo.CourseContractMember AS cm INNER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct ON cm.ContractID = ct.DocumentId
where ct.NewestContractAmendmentId is not null
go

-- 4. Single Lesson Contract and Single Lesson Contract Item

set identity_insert InsightFitPro_Sit.dbo.Document on
INSERT INTO InsightFitPro_Sit.dbo.[Document]
         (Id, DocumentTypeId, DocDate)
SELECT RegisterID + 1000000 AS Id, 1 AS DocumentTypeId, MIN(ClassTime) AS DocDate
FROM   BeyondFitnessProd2.dbo.V_Tuition AS t
WHERE (ContractID IS NULL)
GROUP BY RegisterID

set identity_insert InsightFitPro_Sit.dbo.Document off
go

INSERT INTO InsightFitPro_Sit.dbo.Contract
         (DocumentId, IsValid, EnterpriseId, OrganizationId, OwnerUserProfileId, Lessons, Remark, StatusCommonPropertyId, ContractNo, TotalPrice, SettlementPrice, EffectiveDate, PayoffDueDate, FirstContractInstallmentId, Version, DiscountPromotionId, 
         PaymentBranchId, PaymentMethodCommonProertyId, ValidTo, NewestContractAmendmentId, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT v.RegisterID + 1000000 AS DocumentId, 1 AS IsValid, 2 AS EnterpriseId, ISNULL(ot.Id,3) AS OrganizationId, rs.UID, rs.Lessons, NULL AS Remark, CASE WHEN rs.Attended = 102 THEN 1206 ELSE 1205 END AS StatusCommonPropertyId, 
         'BYND' + CAST(v.RegisterID + 1000000 AS nvarchar(16)) AS ContractNo, v.ListPrice * rs.Lessons AS TotalPrice, v.ListPrice * rs.Lessons AS SettlementPrice, rs.RegisterDate, v.ClassTime AS PayoffDueDate, NULL AS FirstContractInstallmentId, 
         1 AS Version, NULL AS DiscountPromotionId, ISNULL(bt.Id,3) AS PaymentBranchId, 103 AS PaymentMethodCommonProertyId, v.ClassTime AS ValidTo, NULL AS NewestContractAmendmentId, v.CreateDate, 1 AS CreateUserProfileId, NULL AS UpdateDate, NULL 
         AS UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.RegisterLesson AS rs INNER JOIN
             (SELECT RegisterID, MIN(BranchID) AS BranchID, MIN(ListPrice) AS ListPrice, MAX(ClassTime) AS ClassTime, MIN(ClassTime) AS CreateDate
           FROM    BeyondFitnessProd2.dbo.V_Tuition
           WHERE  (ContractID IS NULL)
           GROUP BY RegisterID) AS v ON rs.RegisterID = v.RegisterID LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.BranchStore AS bs INNER JOIN
         BeyondFitnessProd2.dbo.Organization AS os ON bs.BranchID = os.CompanyID INNER JOIN
         InsightFitPro_Sit.dbo.Organization AS ot ON os.ReceiptNo = ot.ReceiptNo INNER JOIN
         InsightFitPro_Sit.dbo.Branch AS bt ON ot.Id = bt.OrganizationId ON v.BranchID = bs.BranchID
go

INSERT INTO InsightFitPro_Sit.dbo.ContractItem
         (IsValid, EnterpriseId, ContractDocumentId, ContractPackageId, ContractNameSnapshot, CurrencySnapshot, UnitPriceSnapshot, CoachCommissionAmountSnapshot, UnitSettlementPriceSnapshot, MaxRenewalCountSnapshot, Quantity, RemainingQuantity, 
         ItemTotalAmount, IsTrustSnapshot, TrustRatioSnapshot, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId, CourseDurationSnapshot)
SELECT 1 AS IsValid, 2 AS EnterpriseId, 1000000 + v.RegisterID AS ContractDocumentId, CASE WHEN rs.Lessons > 1 THEN 1007 ELSE 1008 END AS ContractPackageId, ps.Description AS ContractNameSnapshot, 'TWD' AS CurrencySnapshot, 
         ps.ListPrice AS UnitPriceSnapshot, ps.CoachPayoff AS CoachCommissionAmountSnapshot, ps.ListPrice AS UnitSettlementPriceSnapshot, 1 AS MaxRenewalCountSnapshot, rs.Lessons AS Quantity, rs.Lessons - v.AttendedCount AS RemainingQuantity, 
         rs.Lessons * ps.ListPrice AS ItemTotalAmount, 0 AS IsTrustSnapshot, 0 AS TrustRatioSnapshot, rs.RegisterDate AS CreateDate, 1 AS CreateUserProfileId, NULL AS UpdateDate, NULL AS UpdateUserProfileId, 
         ps.DurationInMinutes AS CourseDurationSnapshot
FROM   (SELECT RegisterID, MIN(BranchID) AS BranchID, MAX(ClassTime) AS ClassTime, MIN(ClassTime) AS CreateDate, COUNT(RegisterID) AS AttendedCount
         FROM    BeyondFitnessProd2.dbo.V_Tuition
         WHERE  (ContractID IS NULL)
         GROUP BY RegisterID) AS v INNER JOIN
         BeyondFitnessProd2.dbo.RegisterLesson AS rs ON v.RegisterID = rs.RegisterID INNER JOIN
         BeyondFitnessProd2.dbo.LessonPriceType AS ps ON rs.ClassLevel = ps.PriceID
go

INSERT INTO InsightFitPro_Sit.dbo.ContractAmendment
         (IsValid, EnterpriseId, ContractDocumentId, DocumentId, RevisionNo, ParentContractAmendmentId, ReasonCommonPropertyId, ResponsibleOrganizationId, MonthExtension, ProcessingFee, CauseForEndingCommonPropertyId, ExpirationDate, 
         OperatorUserProfileId, ReferralUserProfileId, EmployeeReferralUserProfileId, BankId, BankAccount, FeeChargeStatus, ContractAttachmentId, IdCardFrontAttachmentId, IdCardBackAttachmentId, MedicalProofAttachmentId, BankbookCoverAttachmentId, 
         ContractTerminationFeeChargeId, Signature, Renewal, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT 1 AS IsValid, 2 AS EnterpriseId, ct.DocumentId AS ContractDocumentId, ct.DocumentId, 0 AS RevisionNo, NULL AS ParentContractAmendmentId, 500 AS ReasonCommonPropertyId, ct.OrganizationId AS ResponsibleOrganizationId, NULL 
         AS MonthExtension, NULL AS ProcessingFee, NULL AS CauseForEndingCommonPropertyId, rs.Expiration AS ExpirationDate, rs.AdvisorID AS OperatorUserProfileId, NULL AS ReferralUserProfileId, NULL AS EmployeeReferralUserProfileId, NULL 
         AS BankId, NULL AS BankAccount, NULL AS FeeChargeStatus, NULL AS ContractAttachmentId, NULL AS IdCardFrontAttachmentId, NULL AS IdCardBackAttachmentId, NULL AS MedicalProofAttachmentId, NULL AS BankbookCoverAttachmentId, NULL 
         AS ContractTerminationFeeChargeId, NULL AS Signature, 0 AS Renewal, v.CreateDate, 1 AS CreateUserProfileId, NULL AS UpdateDate, NULL AS UpdateUserProfileId
FROM   InsightFitPro_Sit.dbo.Contract AS ct INNER JOIN
             (SELECT RegisterID, MIN(BranchID) AS BranchID, MAX(ClassTime) AS ClassTime, MIN(ClassTime) AS CreateDate, COUNT(RegisterID) AS AttendedCount
           FROM    BeyondFitnessProd2.dbo.V_Tuition
           WHERE  (ContractID IS NULL)
           GROUP BY RegisterID) AS v INNER JOIN
         BeyondFitnessProd2.dbo.RegisterLesson AS rs ON v.RegisterID = rs.RegisterID ON ct.DocumentId = 1000000 + rs.RegisterID
go

UPDATE InsightFitPro_Sit.dbo.Contract
SET     NewestContractAmendmentId = InsightFitPro_Sit.dbo.ContractAmendment.Id
FROM   InsightFitPro_Sit.dbo.Contract INNER JOIN
         InsightFitPro_Sit.dbo.ContractAmendment ON InsightFitPro_Sit.dbo.Contract.DocumentId = InsightFitPro_Sit.dbo.ContractAmendment.ContractDocumentId
where InsightFitPro_Sit.dbo.Contract.DocumentId >= 1000000
go

INSERT INTO InsightFitPro_Sit.dbo.ContractMember
         (ContractContractAmendmentId, UserProfileId, PlusMinusFlag)
SELECT NewestContractAmendmentId AS ContractContractAmendmentId, OwnerUserProfileId AS UserProfileId, 1 AS PlusMinusFlag
FROM   InsightFitPro_Sit.dbo.Contract AS ct
WHERE (DocumentId > 1000000)
go

-- 5. Unearned Revenue Map
-- 合約掛帳

INSERT INTO InsightFitPro_Sit.dbo.UnearnedRevenue
         (IsValid, EnterpriseId, ContractDocumentId, HandlerUserProfileId, PayerUserProfileId, BuyerReceiptNo, BuyerName, OriginalPrice, TotalReceivableAmount, DiscountAmount, ValueAddedTax, PretaxAmount, TotalTrustAmount, PrepaymentBalance, TrustBalance, 
         IsTaxed, PayoffDate, DueDate, PaymentMethodCommonPropertyId, BankAccount, BankId, AccountingCommonPropertyId, BranchId, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT 1 AS IsValid, 2 AS EnterpriseId, cp.ContractID AS ContractDocumentId, p.HandlerID AS HandlerUserProfileId, cc.OwnerID AS PayerUserProfileId, BeyondFitnessProd2.dbo.InvoiceBuyer.ReceiptNo AS BuyerReceiptNo, 
         BeyondFitnessProd2.dbo.InvoiceBuyer.Name AS BuyerName, cc.TotalCost AS OriginalPrice, cc.TotalCost AS TotalReceivableAmount, 0 AS DiscountAmount, cc.TotalCost AS ValueAddedTax, ROUND(cc.TotalCost / 1.05, 0) AS PretaxAmount, 
         CASE WHEN cc.Entrusted = 1 THEN cc.TotalCost * 0.2 ELSE 0 END AS TotalTrustAmount, cc.TotalCost AS PrepaymentBalance, ISNULL(stl.TotalTrustAmount, 0) * 0.2 AS TrustBalance, 1 AS IsTaxed, p.PayoffDate, cc.PayoffDue AS DueDate, 
         ct.PaymentMethodCommonProertyId AS PaymentMethodCommonPropertyId, NULL AS BankAccount, NULL AS BankId, 2001 AS AccountingCommonPropertyId, ct.PaymentBranchId AS BranchId, p.PayoffDate AS CreateDate, 1 AS CreateUserProfileId, NULL 
         AS UpdateDate, NULL AS UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.ContractTrustSettlement AS stl INNER JOIN
             (SELECT ContractID, MAX(SettlementID) AS SettlementID
           FROM    BeyondFitnessProd2.dbo.ContractTrustSettlement AS ContractTrustSettlement_1
           GROUP BY ContractID) AS cts ON stl.SettlementID = cts.SettlementID AND stl.ContractID = cts.ContractID RIGHT OUTER JOIN
         BeyondFitnessProd2.dbo.Payment AS p INNER JOIN
         BeyondFitnessProd2.dbo.ContractPayment AS cp ON p.PaymentID = cp.PaymentID INNER JOIN
         BeyondFitnessProd2.dbo.CourseContract AS cc ON cp.ContractID = cc.ContractID LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.InvoiceBuyer ON p.InvoiceID = BeyondFitnessProd2.dbo.InvoiceBuyer.InvoiceID ON cts.ContractID = cc.ContractID INNER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct ON cc.ContractID = ct.DocumentId
go

-- UnearnedRevenueContractItemMap
INSERT INTO InsightFitPro_Sit.dbo.UnearnedRevenueContractItemMap
         (UnearnedRevenueId, ContractItemId, RevenuePerSession, TrustAmountPerSession)
SELECT ut.Id AS UnearnedRevenueId, it.Id AS ContractItemId, s.RevenuePerSession, CASE WHEN Entrusted = 1 THEN RevenuePerSession ELSE 0 END AS TrustAmountPerSession
FROM   (SELECT ContractID, CASE WHEN PriceID = 425 THEN
                       (SELECT TOP 1 LPT.ListPrice
                     FROM    BeyondFitnessProd2.dbo.CourseContractOrder CCO JOIN
                               BeyondFitnessProd2.dbo.LessonPriceType LPT ON CCO.PriceID = LPT.PriceID
                     WHERE  CCO.ContractID = cc.ContractID
                     ORDER BY CCO.SeqNo ASC) ELSE
                       (SELECT LPT.ListPrice
                     FROM    BeyondFitnessProd2.dbo.LessonPriceType LPT
                     WHERE  LPT.PriceID = cc.PriceID) END AS RevenuePerSession, Entrusted
         FROM    BeyondFitnessProd2.dbo.CourseContract AS cc) AS s INNER JOIN
         InsightFitPro_Sit.dbo.ContractItem AS it ON it.ContractDocumentId = s.ContractID INNER JOIN
         InsightFitPro_Sit.dbo.UnearnedRevenue AS ut ON ut.ContractDocumentId = s.ContractID
go

-- InvoiceItem
set identity_insert InsightFitPro_Sit.dbo.InvoiceItem on
INSERT INTO InsightFitPro_Sit.dbo.InvoiceItem
         (Id, No, InvoiceDate, InvoiceType, RandomNo, TrackCode, PrintMark, DonateMark, CarrierType, CarrierNo, DonationCode, InvoicePdf, InvoiceUrl)
SELECT InvoiceItem.InvoiceID AS Id, InvoiceItem.No, InvoiceItem.InvoiceDate, InvoiceItem.InvoiceType, InvoiceItem.RandomNo, InvoiceItem.TrackCode, InvoiceItem.PrintMark, InvoiceItem.DonateMark, InvoiceCarrier.CarrierType, InvoiceCarrier.CarrierNo, 
         InvoiceDonation.AgencyCode AS DonationCode, NULL AS InvoicePdf, NULL AS InvoiceUrl
FROM   BeyondFitnessProd2.dbo.InvoiceItem LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.InvoiceDonation ON InvoiceItem.InvoiceID = InvoiceDonation.InvoiceID LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.InvoiceCarrier ON InvoiceItem.InvoiceID = InvoiceCarrier.InvoiceID

set identity_insert InsightFitPro_Sit.dbo.InvoiceItem off
go

INSERT INTO InsightFitPro_Sit.dbo.InvoiceAmountType
         (InvoiceItemId, TaxType, SalesAmount, TaxAmount, TaxRate, TotalAmount, DiscountAmount, Adjustment, OriginalCurrencyAmount, ExchangeRate, CurrencyId)
SELECT InvoiceID AS InvoiceItemId, TaxType, SalesAmount, TaxAmount, TaxRate, TotalAmount, DiscountAmount, Adjustment, OriginalCurrencyAmount, ExchangeRate, CurrencyID
FROM   BeyondFitnessProd2.dbo.InvoiceAmountType
go

-- 、CalendarEvents、UnearnedRevenueRealizationMap
-- 合約實際收款

INSERT INTO InsightFitPro_Sit.dbo.UnearnedRevenueRealization
         (IsValid, EnterpriseId, UnearnedRevenueId, EntryDate, PrepaymentBalance, PrepaymentOffsetAmount, TrustBalance, RecognizedRevenue, RefundToBuyer, BusinessTaxReversal, RecoverableTrustAmount, VATOffset, FinanceAccountingTypeId, InvoiceItemId, 
         Remark, ProductItems, InvoiceAllowanceId, CreateUserProfileId, CreateDate, UpdateDate, UpdateUserProfileId)
SELECT 1 AS IsValid, 2 AS EnterpriseId, ut.Id AS UnearnedRevenueId, p.PayoffDate AS EntryDate, ct.TotalPrice AS PrepaymentBalance, 0 AS PrepaymentOffsetAmount, ut.TrustBalance, 0 AS RecognizedRevenue, 0 AS RefundToBuyer, 0 AS BusinessTaxReversal, 
         0 AS RecoverableTrustAmount, 0 AS VATOffset, 1 AS FinanceAccountingTypeId, p.InvoiceID AS InvoiceItemId, p.Remark
         , STUFF((
  SELECT '/' + p2.Brief
  FROM BeyondFitnessProd2.dbo.InvoiceDetails d2
  JOIN BeyondFitnessProd2.dbo.InvoiceProduct p2 ON d2.ProductID = p2.ProductID
  WHERE d2.InvoiceID = i.InvoiceID
  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS ProductItems, NULL AS InvoiceAllowanceId, ct.CreateUserProfileId, ct.CreateDate, ct.UpdateDate, ct.UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.Payment AS p INNER JOIN
         BeyondFitnessProd2.dbo.ContractPayment AS pc ON p.PaymentID = pc.PaymentID INNER JOIN
         BeyondFitnessProd2.dbo.PaymentTransaction AS ps ON p.PaymentID = ps.PaymentID LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.InvoiceItem AS i ON p.InvoiceID = i.InvoiceID INNER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct ON pc.ContractID = ct.DocumentId INNER JOIN
         InsightFitPro_Sit.dbo.UnearnedRevenue AS ut ON ut.ContractDocumentId = ct.DocumentId

go

-- 單堂課合約掛帳

INSERT INTO InsightFitPro_Sit.dbo.UnearnedRevenue
         (IsValid, EnterpriseId, ContractDocumentId, HandlerUserProfileId, PayerUserProfileId, BuyerReceiptNo, BuyerName, OriginalPrice, TotalReceivableAmount, DiscountAmount, ValueAddedTax, PretaxAmount, TotalTrustAmount, PrepaymentBalance, TrustBalance, 
         IsTaxed, PayoffDate, DueDate, PaymentMethodCommonPropertyId, BankAccount, BankId, AccountingCommonPropertyId, BranchId, CreateDate, CreateUserProfileId, UpdateDate, UpdateUserProfileId)
SELECT 1 AS IsValid, 2 AS EnterpriseId, ct.DocumentId AS ContractDocumentId, p.HandlerID AS HandlerUserProfileId, ct.OwnerUserProfileId AS PayerUserProfileId, bu.ReceiptNo AS BuyerReceiptNo, bu.Name AS BuyerName, ct.SettlementPrice AS OriginalPrice, 
         ct.SettlementPrice AS TotalReceivableAmount, 0 AS DiscountAmount, ct.SettlementPrice AS ValueAddedTax, ROUND(ct.SettlementPrice / 1.05, 0) AS PretaxAmount, 0 AS TotalTrustAmount, ct.SettlementPrice AS PrepaymentBalance, 0 AS TrustBalance, 1 AS IsTaxed, 
         p.PayoffDate, ct.PayoffDueDate AS DueDate, ct.PaymentMethodCommonProertyId AS PaymentMethodCommonPropertyId, NULL AS BankAccount, NULL AS BankId, 2002 AS AccountingCommonPropertyId, ct.PaymentBranchId AS BranchId, 
         p.PayoffDate AS CreateDate, 1 AS CreateUserProfileId, NULL AS UpdateDate, NULL AS UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.RegisterLesson AS stl INNER JOIN
         BeyondFitnessProd2.dbo.TuitionInstallment AS tu ON stl.RegisterID = tu.RegisterID INNER JOIN
         BeyondFitnessProd2.dbo.Payment AS p ON tu.InstallmentID = p.PaymentID INNER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct ON stl.RegisterID+1000000 = ct.DocumentId LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.InvoiceBuyer AS bu ON p.InvoiceID = bu.InvoiceID
go
-- UnearnedRevenueContractItemMap
INSERT INTO InsightFitPro_Sit.dbo.UnearnedRevenueContractItemMap
         (UnearnedRevenueId, ContractItemId, RevenuePerSession, TrustAmountPerSession)
SELECT ut.Id AS UnearnedRevenueId, it.Id AS ContractItemId, it.UnitPriceSnapshot AS RevenuePerSession, 0 AS TrustAmountPerSession
FROM   InsightFitPro_Sit.dbo.ContractItem AS it INNER JOIN
         InsightFitPro_Sit.dbo.UnearnedRevenue AS ut ON it.ContractDocumentId = ut.ContractDocumentId
WHERE (ut.AccountingCommonPropertyId = 2002)
go
-- 單堂課合約實際收款

INSERT INTO InsightFitPro_Sit.dbo.UnearnedRevenueRealization
         (IsValid, EnterpriseId, UnearnedRevenueId, EntryDate, PrepaymentBalance, PrepaymentOffsetAmount, TrustBalance, RecognizedRevenue, RefundToBuyer, BusinessTaxReversal, RecoverableTrustAmount, VATOffset, FinanceAccountingTypeId, InvoiceItemId, 
         Remark, ProductItems, InvoiceAllowanceId, CreateUserProfileId, CreateDate, UpdateDate, UpdateUserProfileId)
SELECT 1 AS IsValid, 2 AS EnterpriseId, ut.Id AS UnearnedRevenueId, p.PayoffDate AS EntryDate, ct.TotalPrice AS PrepaymentBalance, 0 AS PrepaymentOffsetAmount, ut.TrustBalance, 0 AS RecognizedRevenue, 0 AS RefundToBuyer, 0 AS BusinessTaxReversal, 
         0 AS RecoverableTrustAmount, 0 AS VATOffset, 4 AS FinanceAccountingTypeId, p.InvoiceID AS InvoiceItemId, p.Remark
         , STUFF((  SELECT '/' + p2.Brief  FROM BeyondFitnessProd2.dbo.InvoiceDetails d2  JOIN BeyondFitnessProd2.dbo.InvoiceProduct p2 ON d2.ProductID = p2.ProductID  WHERE d2.InvoiceID = i.InvoiceID  FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS ProductItems
         , NULL AS InvoiceAllowanceId, ct.CreateUserProfileId, ct.CreateDate, ct.UpdateDate, ct.UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.Payment AS p INNER JOIN
         BeyondFitnessProd2.dbo.TuitionInstallment AS tu ON p.PaymentID = tu.InstallmentID INNER JOIN
         BeyondFitnessProd2.dbo.RegisterLesson AS r ON tu.RegisterID = r.RegisterID LEFT OUTER JOIN
         BeyondFitnessProd2.dbo.InvoiceItem AS i ON p.InvoiceID = i.InvoiceID INNER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct ON r.RegisterID + 1000000 = ct.DocumentId INNER JOIN
         InsightFitPro_Sit.dbo.UnearnedRevenue AS ut ON ut.ContractDocumentId = ct.DocumentId

go

-- 6. CalendarEvent

drop table if exists InsightFitPro_Sit.dbo.TmpTuition

SELECT LessonID, ClassTime, AttendingCoach, GroupID, BranchID, CoachAttendance, CompleteDate, CommitAttendance, PriceID, PriceStatus, ELStatus, AchievementIndex, TuitionIndex, RegisterID, GroupingMemberCount, ListPrice, PercentageOfDiscount, 
                   ProfessionalLevelID, MarkedGradeIndex, BranchName, OfficeLocation, EnterpriseRegisterID, EnterpriseListPrice, WorkPlace, EnterpriseContractID, ISNULL(ContractID, RegisterID + 1000000) AS ContractID, SettlementStatus, CoachWorkPlace, 
                   SettlementID, CoachPayoff, EnterpriseCoachPayoff, UID
into InsightFitPro_Sit.dbo.TmpTuition
         FROM    BeyondFitnessProd2.dbo.V_Tuition

select * from InsightFitPro_Sit.dbo.TmpTuition

set identity_insert InsightFitPro_Sit.dbo.CalendarEvents on

INSERT INTO InsightFitPro_Sit.dbo.CalendarEvents
         (Id, IsValid, EnterpriseId, BranchId, ContractDocumentId, ContractItemId, ContractServiceTypeId, ContractTagId, ContractTypeCategoryId, EventType, Status, StartDateTime, EndDateTime, Remark, CreateDate, CreateUserProfileId, UpdateDate, 
         UpdateUserProfileId, OwnerUserProfileId)
SELECT v.LessonID AS Id, 1 AS IsValid, 2 AS EnterpriseId, ct1.PaymentBranchId AS BranchID, ci1.ContractDocumentId, ci1.Id AS ContractItemId, NULL AS ContractServiceTypeId, NULL AS ContractTagId, cp1.ContractTypeCategoryId, 
         CASE WHEN ci1.Quantity > 1 THEN 1 ELSE 3 END AS EventType, CASE WHEN v.CompleteDate IS NOT NULL THEN 2 ELSE 1 END AS Status, v.ClassTime AS StartDateTime, DATEADD(mi, ci1.CourseDurationSnapshot, v.ClassTime) AS EndDateTime, lp.Remark, 
         v.ClassTime AS CreateDate, 1 AS CreateUserProfileId, NULL AS Expr1, NULL AS Expr2, ct1.OwnerUserProfileId
FROM   InsightFitPro_Sit.dbo.TmpTuition AS v INNER JOIN
         BeyondFitnessProd2.dbo.LessonPlan AS lp ON v.LessonID = lp.LessonID LEFT OUTER JOIN
         InsightFitPro_Sit.dbo.Contract AS ct1 ON v.ContractID = ct1.DocumentId INNER JOIN
         InsightFitPro_Sit.dbo.ContractItem AS ci1 ON ct1.DocumentId = ci1.ContractDocumentId INNER JOIN
         InsightFitPro_Sit.dbo.ContractPackage AS cp1 ON ci1.ContractPackageId = cp1.Id

set identity_insert InsightFitPro_Sit.dbo.CalendarEvents off

drop table if exists InsightFitPro_Sit.dbo.TmpTuition
go

drop table if exists InsightFitPro_Sit.dbo.TmpCalendarEventAttendees

SELECT v.LessonID AS CalendarEventId, r.UID AS UserProfileId, 2 AS AttendeeRole, ISNULL(v.ContractID, v.RegisterID + 1000000) AS ContractDocumentId, 2 AS EnterpriseId, 1 AS IsPresent, v.ClassTime AS CreateDate, 1 AS CreateUserProfileId, 1 AS IsValid, NULL 
         AS UpdateDate, NULL AS UpdateUserProfileId
into InsightFitPro_Sit.dbo.TmpCalendarEventAttendees
FROM   BeyondFitnessProd2.dbo.V_Tuition AS v INNER JOIN
         BeyondFitnessProd2.dbo.GroupingLesson AS g ON v.GroupID = g.GroupID INNER JOIN
         BeyondFitnessProd2.dbo.RegisterLesson AS r ON g.GroupID = r.RegisterGroupID
where v.AttendingCoach <> r.UID

insert into InsightFitPro_Sit.dbo.TmpCalendarEventAttendees
SELECT v.LessonID AS CalendarEventId, v.AttendingCoach AS UserProfileId, 1 AS AttendeeRole, ISNULL(v.ContractID, v.RegisterID + 1000000) AS ContractDocumentId, 2 AS EnterpriseId, 1 AS IsPresent, v.ClassTime AS CreateDate, 1 AS CreateUserProfileId, 1 AS IsValid, NULL 
         AS UpdateDate, NULL AS UpdateUserProfileId
FROM   BeyondFitnessProd2.dbo.V_Tuition AS v 
--where v.AttendingCoach = v.UID

select * from InsightFitPro_Sit.dbo.TmpCalendarEventAttendees

--INSERT INTO InsightFitPro_Sit.dbo.CalendarEventAttendees
--         (CalendarEventId, UserProfileId, AttendeeRole, ContractItemId, EnterpriseId, IsPresent, CreateDate, CreateUserProfileId, IsValid, UpdateDate, UpdateUserProfileId)
--SELECT v.CalendarEventId, v.UserProfileId, v.AttendeeRole, ci.Id AS ContractItemId, v.EnterpriseId, v.IsPresent, v.CreateDate, v.CreateUserProfileId, v.IsValid, v.UpdateDate, v.UpdateUserProfileId
--FROM   InsightFitPro_Sit.dbo.TmpCalendarEventAttendees AS v INNER JOIN
--         InsightFitPro_Sit.dbo.ContractItem AS ci ON v.ContractDocumentId = ci.ContractDocumentId

INSERT INTO InsightFitPro_Sit.dbo.CalendarEventAttendees
         (CalendarEventId, UserProfileId, AttendeeRole, ContractItemId, EnterpriseId, IsPresent, CreateDate, CreateUserProfileId, IsValid, UpdateDate, UpdateUserProfileId)
SELECT v.CalendarEventId, v.UserProfileId, v.AttendeeRole, ci.Id AS ContractItemId, v.EnterpriseId,
       CAST(v.IsPresent AS bit),
       CAST(v.CreateDate AS datetime2),
       v.CreateUserProfileId,
       CAST(v.IsValid AS bit),
       TRY_CONVERT(datetime2, CAST(v.UpdateDate AS varchar(20))),
       v.UpdateUserProfileId
FROM   InsightFitPro_Sit.dbo.TmpCalendarEventAttendees AS v INNER JOIN
         InsightFitPro_Sit.dbo.ContractItem AS ci ON v.ContractDocumentId = ci.ContractDocumentId

drop table if exists InsightFitPro_Sit.dbo.TmpCalendarEventAttendees

go
