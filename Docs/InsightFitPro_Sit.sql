USE [InsightFitPro_Sit]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AdministrativeArea]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdministrativeArea](
	[Id] [nvarchar](8) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Area] [nvarchar](16) NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_AdministrativeArea] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AdministrativeDistrict]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdministrativeDistrict](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[AdministrativeAreaId] [nvarchar](8) NOT NULL,
	[District] [nvarchar](16) NOT NULL,
	[DistrictCode] [tinyint] NOT NULL,
	[ZipCode] [int] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_AdministrativeDistrict] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attachment]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attachment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[StoredPath] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Bank]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bank](
	[Id] [nvarchar](10) NOT NULL,
	[BankName] [nvarchar](64) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
 CONSTRAINT [PK_Bank] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Branch]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branch](
	[Id] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Location] [nvarchar](32) NULL,
	[Status] [int] NULL,
	[EnterpriseId] [int] NOT NULL,
	[OrganizationId] [int] NOT NULL,
	[Email] [nvarchar](64) NULL,
	[Phone] [nvarchar](64) NULL,
	[Addr] [nvarchar](256) NULL,
	[CreateDate] [datetime2](7) NULL,
	[CreateUserProfileId] [int] NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_BranchStore] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CalendarEventAttendeeAssessments]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CalendarEventAttendeeAssessments](
	[CalendarEventId] [int] NOT NULL,
	[UserProfileId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[SleepHours] [decimal](4, 1) NOT NULL,
	[WaterIntakeStatusCommonPropertyId] [int] NOT NULL,
	[StressLevel] [int] NOT NULL,
	[FatigueLevel] [int] NOT NULL,
	[HasFever] [bit] NOT NULL,
	[HasColdOrDiscomfort] [bit] NOT NULL,
	[HasAcuteInjury] [bit] NOT NULL,
	[HasCardiovascular] [bit] NOT NULL,
	[TakingMedication] [bit] NOT NULL,
	[IsPregnantOrMenstrual] [bit] NOT NULL,
	[Remark] [nvarchar](50) NULL,
	[SignatureData] [nvarchar](max) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_CalendarEventAttendeeAssessments] PRIMARY KEY CLUSTERED 
(
	[CalendarEventId] ASC,
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CalendarEventAttendees]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CalendarEventAttendees](
	[CalendarEventId] [int] NOT NULL,
	[UserProfileId] [int] NOT NULL,
	[AttendeeRole] [int] NOT NULL,
	[ContractItemId] [int] NULL,
	[EnterpriseId] [int] NOT NULL,
	[IsPresent] [bit] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_CalendarEventAttendees] PRIMARY KEY CLUSTERED 
(
	[CalendarEventId] ASC,
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CalendarEvents]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CalendarEvents](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[BranchId] [int] NOT NULL,
	[ContractDocumentId] [int] NULL,
	[ContractItemId] [int] NULL,
	[ContractServiceTypeId] [int] NULL,
	[ContractTagId] [int] NULL,
	[ContractTypeCategoryId] [int] NULL,
	[EventType] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[StartDateTime] [datetime2](7) NOT NULL,
	[EndDateTime] [datetime2](7) NOT NULL,
	[Remark] [nvarchar](500) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
	[OwnerUserProfileId] [int] NULL,
 CONSTRAINT [PK_CalendarEvents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoachLevel]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoachLevel](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[CoachLevelName] [nvarchar](16) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK__CoachLev__3214EC072D825693] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CommonProperty]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommonProperty](
	[Id] [int] NOT NULL,
	[PropertyName] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[PropertyType] [int] NOT NULL,
	[I18nKey] [nvarchar](50) NULL,
	[Icon] [nvarchar](50) NULL,
	[Size] [int] NULL,
 CONSTRAINT [PK_CommonProperty] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contract]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contract](
	[DocumentId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[OrganizationId] [int] NOT NULL,
	[OwnerUserProfileId] [int] NOT NULL,
	[Lessons] [int] NULL,
	[Remark] [nvarchar](256) NULL,
	[StatusCommonPropertyId] [int] NOT NULL,
	[ContractNo] [nvarchar](64) NULL,
	[TotalPrice] [decimal](18, 2) NULL,
	[SettlementPrice] [decimal](18, 2) NULL,
	[EffectiveDate] [datetime2](7) NULL,
	[PayoffDueDate] [datetime2](7) NULL,
	[FirstContractInstallmentId] [int] NULL,
	[Version] [int] NULL,
	[DiscountPromotionId] [int] NULL,
	[PaymentBranchId] [int] NOT NULL,
	[PaymentMethodCommonProertyId] [int] NULL,
	[ValidTo] [datetime2](7) NULL,
	[NewestContractAmendmentId] [int] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_Contract] PRIMARY KEY CLUSTERED 
(
	[DocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractAmendment]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractAmendment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[ContractDocumentId] [int] NULL,
	[DocumentId] [int] NULL,
	[RevisionNo] [int] NOT NULL,
	[ParentContractAmendmentId] [int] NULL,
	[ReasonCommonPropertyId] [int] NOT NULL,
	[ResponsibleOrganizationId] [int] NULL,
	[MonthExtension] [int] NULL,
	[ProcessingFee] [int] NULL,
	[CauseForEndingCommonPropertyId] [int] NULL,
	[ExpirationDate] [datetime2](7) NULL,
	[OperatorUserProfileId] [int] NULL,
	[ReferralUserProfileId] [int] NULL,
	[EmployeeReferralUserProfileId] [int] NULL,
	[BankId] [nvarchar](8) NULL,
	[BankAccount] [nvarchar](32) NULL,
	[FeeChargeStatus] [int] NULL,
	[ContractAttachmentId] [int] NULL,
	[IdCardFrontAttachmentId] [int] NULL,
	[IdCardBackAttachmentId] [int] NULL,
	[MedicalProofAttachmentId] [int] NULL,
	[BankbookCoverAttachmentId] [int] NULL,
	[ContractTerminationFeeChargeId] [int] NULL,
	[Signature] [nvarchar](max) NULL,
	[Renewal] [bit] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_ContractAmendment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractBillSplit]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractBillSplit](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[ContractPackageId] [int] NOT NULL,
	[ItemName] [nvarchar](64) NOT NULL,
	[TrustRatio] [decimal](18, 2) NULL,
	[IsTrust] [bit] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_ContractBillSplit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractItem]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[ContractDocumentId] [int] NOT NULL,
	[ContractPackageId] [int] NOT NULL,
	[ContractNameSnapshot] [nvarchar](50) NULL,
	[CurrencySnapshot] [nvarchar](4) NULL,
	[UnitPriceSnapshot] [decimal](18, 2) NULL,
	[CoachCommissionAmountSnapshot] [decimal](18, 2) NULL,
	[UnitSettlementPriceSnapshot] [decimal](18, 2) NULL,
	[MaxRenewalCountSnapshot] [int] NULL,
	[Quantity] [int] NULL,
	[RemainingQuantity] [int] NULL,
	[ItemTotalAmount] [decimal](18, 2) NULL,
	[IsTrustSnapshot] [bit] NULL,
	[TrustRatioSnapshot] [decimal](5, 4) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
	[CourseDurationSnapshot] [int] NULL,
 CONSTRAINT [PK_CourseContractItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractMember]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractMember](
	[ContractContractAmendmentId] [int] NOT NULL,
	[UserProfileId] [int] NOT NULL,
	[PlusMinusFlag] [int] NULL,
 CONSTRAINT [PK_ContractMember] PRIMARY KEY CLUSTERED 
(
	[ContractContractAmendmentId] ASC,
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPackage]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPackage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[OrganizationId] [int] NULL,
	[ContractTypeCategoryId] [int] NOT NULL,
	[Code] [nvarchar](1) NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[MaxEnrollment] [int] NOT NULL,
	[MinEnrollment] [int] NOT NULL,
	[DurationMonths] [int] NULL,
	[MaxRenewalCount] [int] NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsTrust] [bit] NULL,
	[TrustRatio] [decimal](5, 4) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
	[RenewalDurationMonths] [int] NULL,
	[IsOnlineSelfService] [bit] NULL,
 CONSTRAINT [PK_CourseSubCategory31] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPackagePricing]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPackagePricing](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[ContractPackageId] [int] NOT NULL,
	[Currency] [nvarchar](4) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[CoachCommissionAmount] [decimal](18, 2) NULL,
	[CourseDuration] [int] NOT NULL,
	[DefaultQuantity] [int] NULL,
	[MaxQuantity] [int] NOT NULL,
	[MinQuantity] [int] NOT NULL,
	[Remark] [nvarchar](100) NULL,
	[DisplayOrder] [int] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
	[ContractTagId] [int] NULL,
 CONSTRAINT [PK__CoursePr__3214EC073E971B87] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPackagePricingCoachLevelMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPackagePricingCoachLevelMap](
	[ContractPackagePricingId] [int] NOT NULL,
	[CoachLevelId] [int] NOT NULL,
 CONSTRAINT [PK_ContractPackagePricingCoachLevelMap] PRIMARY KEY CLUSTERED 
(
	[ContractPackagePricingId] ASC,
	[CoachLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPackagePricingCustomerLevelMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPackagePricingCustomerLevelMap](
	[ContractPackagePricingId] [int] NOT NULL,
	[CustomerLevelId] [int] NOT NULL,
 CONSTRAINT [PK_ContractPackagePricingCustomerLevelMap] PRIMARY KEY CLUSTERED 
(
	[ContractPackagePricingId] ASC,
	[CustomerLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPackageServiceTypeMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPackageServiceTypeMap](
	[ContractPackageId] [int] NOT NULL,
	[ContractServiceTypeId] [int] NOT NULL,
 CONSTRAINT [PK_ContractPackageServiceTypeMap] PRIMARY KEY CLUSTERED 
(
	[ContractPackageId] ASC,
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPaymentMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPaymentMap](
	[PaymentId] [int] NOT NULL,
	[ContractDocumentId] [int] NOT NULL,
 CONSTRAINT [PK_PaymentCourseContract] PRIMARY KEY CLUSTERED 
(
	[PaymentId] ASC,
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractServiceType]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractServiceType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Code] [nvarchar](20) NULL,
	[Name] [nvarchar](30) NOT NULL,
	[I18nKey] [nvarchar](50) NULL,
	[Icon] [nvarchar](50) NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_ContractServiceType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractServiceTypeLessonTabMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractServiceTypeLessonTabMap](
	[ContractServiceTypeId] [int] NOT NULL,
	[LessonTabId] [int] NOT NULL,
 CONSTRAINT [PK_ContractServiceTypeLessonTabMap] PRIMARY KEY CLUSTERED 
(
	[ContractServiceTypeId] ASC,
	[LessonTabId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTag]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTag](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Code] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[I18nKey] [nvarchar](50) NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
	[ForFree] [bit] NOT NULL,
	[ForOneTimeCourse] [bit] NOT NULL,
 CONSTRAINT [PK_ContractTag] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTemplate]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTemplate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TemplateName] [nvarchar](200) NOT NULL,
	[FactoryCode] [nvarchar](50) NOT NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK__Contract__F87ADD07812A6CCB] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTemplateClause]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTemplateClause](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ContentText] [nvarchar](max) NOT NULL,
	[CreateDate] [datetime] NULL,
 CONSTRAINT [PK__ClauseCo__81EB10013C11C62D] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTemplateStructure]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTemplateStructure](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ContractTemplateId] [int] NOT NULL,
	[ContractClauseId] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[IndentLevel] [int] NOT NULL,
 CONSTRAINT [PK__Contract__3214EC078436DD27] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTerminationFeeCharge]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTerminationFeeCharge](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[ContractPackageId] [int] NOT NULL,
	[BasicFee] [int] NULL,
	[ChargeRatePercentage] [int] NULL,
	[RemainedBasicFee] [int] NULL,
	[RemainedChargeRatePercentage] [int] NULL,
	[MaxAmount] [int] NULL,
	[CreateUserProfileId] [int] NULL,
	[CreateDate] [datetime2](7) NULL,
 CONSTRAINT [PK_CourseContractTermationFeeCharge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTypeCategory]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTypeCategory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[Code] [nvarchar](2) NULL,
	[Name] [nvarchar](15) NOT NULL,
	[EnglishName] [nvarchar](30) NULL,
	[Description] [nvarchar](100) NULL,
	[IsGroup] [bit] NOT NULL,
	[IsOneTimeCourse] [bit] NOT NULL,
	[CalendarColor] [nvarchar](10) NULL,
	[Icon] [nvarchar](50) NULL,
	[DisplayOrder] [int] NOT NULL,
	[ContractTemplateId] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_CourseCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CountryCode]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryCode](
	[Id] [nvarchar](8) NOT NULL,
	[FIFA] [nvarchar](8) NULL,
	[Dial] [nvarchar](8) NOT NULL,
	[MARC] [nvarchar](8) NOT NULL,
	[is_independent] [nvarchar](16) NOT NULL,
	[ISO3166_1_numeric] [smallint] NOT NULL,
	[GAUL] [int] NULL,
	[FIPS] [nvarchar](4) NOT NULL,
	[WMO] [nvarchar](4) NULL,
	[ISO3166_1_Alpha_2] [nvarchar](4) NOT NULL,
	[ITU] [nvarchar](8) NULL,
	[IOC] [nvarchar](8) NULL,
	[DS] [nvarchar](8) NULL,
	[UNTERM_Spanish_Formal] [nvarchar](100) NULL,
	[Global_Code] [tinyint] NOT NULL,
	[Intermediate_Region_Code] [tinyint] NULL,
	[official_name_fr] [nvarchar](100) NOT NULL,
	[UNTERM_French_Short] [nvarchar](100) NULL,
	[ISO4217_currency_name] [nvarchar](50) NOT NULL,
	[UNTERM_Russian_Formal] [nvarchar](100) NULL,
	[UNTERM_English_Short] [nvarchar](100) NULL,
	[ISO4217_currency_alphabetic_code] [nvarchar](50) NULL,
	[Small_Island_Developing_States_SIDS] [nvarchar](50) NULL,
	[UNTERM_Spanish_Short] [nvarchar](100) NULL,
	[ISO4217_currency_numeric_code] [int] NULL,
	[UNTERM_Chinese_Formal] [nvarchar](50) NULL,
	[UNTERM_French_Formal] [nvarchar](100) NULL,
	[UNTERM_Russian_Short] [nvarchar](100) NULL,
	[M49] [smallint] NOT NULL,
	[Sub_region_Code] [smallint] NULL,
	[Region_Code] [tinyint] NULL,
	[official_name_ar] [nvarchar](100) NOT NULL,
	[ISO4217_currency_minor_unit] [float] NULL,
	[UNTERM_Arabic_Formal] [nvarchar](100) NULL,
	[UNTERM_Chinese_Short] [nvarchar](50) NULL,
	[Land_Locked_Developing_Countries_LLDC] [nvarchar](50) NULL,
	[Intermediate_Region_Name] [nvarchar](50) NULL,
	[official_name_es] [nvarchar](100) NOT NULL,
	[UNTERM_English_Formal] [nvarchar](100) NULL,
	[official_name_cn] [nvarchar](50) NOT NULL,
	[official_name_en] [nvarchar](100) NOT NULL,
	[ISO4217_currency_country_name] [nvarchar](100) NOT NULL,
	[Least_Developed_Countries_LDC] [nvarchar](50) NULL,
	[Region_Name] [nvarchar](50) NULL,
	[UNTERM_Arabic_Short] [nvarchar](100) NULL,
	[Sub_region_Name] [nvarchar](50) NULL,
	[official_name_ru] [nvarchar](100) NOT NULL,
	[Global_Name] [nvarchar](50) NOT NULL,
	[Capital] [nvarchar](50) NULL,
	[Continent] [nvarchar](50) NOT NULL,
	[TLD] [nvarchar](50) NOT NULL,
	[Languages] [nvarchar](100) NULL,
	[GeonameId] [int] NOT NULL,
	[CLDR_display_name] [nvarchar](50) NOT NULL,
	[EDGAR] [nvarchar](50) NULL,
	[WikidataId] [nvarchar](50) NULL,
 CONSTRAINT [PK_CountryCode] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CustomerLevel]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerLevel](
	[Id] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[CustomerLevelName] [nvarchar](16) NOT NULL,
	[Icon] [nvarchar](50) NULL,
	[Color] [nvarchar](10) NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_CustomerLevel] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DiscountPromotion]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscountPromotion](
	[Id] [int] NOT NULL,
	[LaunchDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[DiscountCode] [nvarchar](16) NULL,
	[DiscountPercentage] [int] NULL,
	[DiscountAmount] [int] NULL,
	[TotalQuantity] [int] NULL,
 CONSTRAINT [PK_DiscountPromotion] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Document]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DocumentTypeId] [int] NULL,
	[DocDate] [datetime] NOT NULL,
	[WorkFlowId] [int] NULL,
	[TaskExecutionId] [int] NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentType]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentType](
	[Id] [int] NOT NULL,
	[TypeName] [nvarchar](128) NULL,
 CONSTRAINT [PK_DocumentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentTypeTask]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTypeTask](
	[DocumentTypeId] [int] NOT NULL,
	[TaskExecutionId] [int] NOT NULL,
 CONSTRAINT [PK_DocumentTypeTask] PRIMARY KEY CLUSTERED 
(
	[DocumentTypeId] ASC,
	[TaskExecutionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Enterprise]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Enterprise](
	[Id] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseName] [nvarchar](64) NOT NULL,
	[EnterpriseUrl] [nvarchar](100) NULL,
	[EnterpriseSeal] [nvarchar](max) NULL,
	[IsStrictValidation] [bit] NOT NULL,
	[IsPremium] [bit] NOT NULL,
	[IsTaxed] [bit] NULL,
	[IsTrustIncTax] [bit] NULL,
	[IsTaxInclusivePricing] [bit] NULL,
	[UseEInvoice] [bit] NULL,
	[CreateDate] [datetime2](7) NULL,
	[CreateUserProfileId] [int] NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
	[EventLimit] [int] NOT NULL,
	[IsFeeChargedSeparately] [bit] NULL,
 CONSTRAINT [PK_EnterpriseHeadquarter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseContractServiceTypeMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseContractServiceTypeMap](
	[EnterpriseId] [int] NOT NULL,
	[ContractServiceTypeId] [int] NOT NULL,
 CONSTRAINT [PK_EnterpriseContractServiceTypeMap] PRIMARY KEY CLUSTERED 
(
	[EnterpriseId] ASC,
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseContractTagMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseContractTagMap](
	[EnterpriseId] [int] NOT NULL,
	[ContractTagId] [int] NOT NULL,
 CONSTRAINT [PK_EnterpriseContractTagMap] PRIMARY KEY CLUSTERED 
(
	[EnterpriseId] ASC,
	[ContractTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseFitEquipmentMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseFitEquipmentMap](
	[EnterpriseId] [int] NOT NULL,
	[FitEquipmentId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_EnterpriseFitEquipmentMap] PRIMARY KEY CLUSTERED 
(
	[EnterpriseId] ASC,
	[FitEquipmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseFitExerciseMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseFitExerciseMap](
	[EnterpriseId] [int] NOT NULL,
	[FitExerciseId] [nvarchar](64) NOT NULL,
	[VideoUrl] [nvarchar](512) NULL,
 CONSTRAINT [PK_EnterpriseFitExerciseMap] PRIMARY KEY CLUSTERED 
(
	[EnterpriseId] ASC,
	[FitExerciseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseLessonFitCategoryMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseLessonFitCategoryMap](
	[EnterpriseId] [int] NOT NULL,
	[LessonFitCategoryId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_EnterpriseLessonFitCategoryMap] PRIMARY KEY CLUSTERED 
(
	[EnterpriseId] ASC,
	[LessonFitCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseRoleModulePageMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseRoleModulePageMap](
	[EnterpriseId] [int] NOT NULL,
	[RoleModulePageId] [int] NOT NULL,
 CONSTRAINT [PK_EnterpriseRoleModulePageMap] PRIMARY KEY CLUSTERED 
(
	[EnterpriseId] ASC,
	[RoleModulePageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FavoriteInvoiceItem]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FavoriteInvoiceItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[UserProfileId] [int] NOT NULL,
	[CarrierType] [nvarchar](16) NOT NULL,
	[CarrierNo] [nvarchar](64) NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
 CONSTRAINT [PK_FavoriteInvoiceItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FavoriteItems]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FavoriteItems](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[ItemName] [nvarchar](16) NOT NULL,
	[DefaultAmount] [decimal](18, 2) NULL,
	[PaymentTypeCommonPropertyId] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_FavoriteItems] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FinanceAccountingType]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinanceAccountingType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[TrustCode] [nvarchar](2) NULL,
	[AbstractCode] [nvarchar](16) NULL,
	[ItemName] [nvarchar](16) NULL,
	[Category] [nvarchar](16) NULL,
	[DefaultText] [nvarchar](64) NULL,
	[PaymentTypeCommonPropertyId] [int] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_AccountingAbstracts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitEquipment]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitEquipment](
	[Id] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Abbreviation] [nvarchar](16) NULL,
	[FitEquipmentCategoryId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_FitEquipment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitEquipmentCategory]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitEquipmentCategory](
	[Id] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](256) NULL,
 CONSTRAINT [PK_FitEquipmentCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitExercise]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitExercise](
	[Id] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Abbreviation] [nvarchar](16) NULL,
 CONSTRAINT [PK_FitExercise] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitExerciseLessonFitCategoryMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitExerciseLessonFitCategoryMap](
	[FitExerciseId] [nvarchar](64) NOT NULL,
	[LessonFitCategoryId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_FitExerciseLessonFitCategoryMap] PRIMARY KEY CLUSTERED 
(
	[FitExerciseId] ASC,
	[LessonFitCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitExerciseTagMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitExerciseTagMap](
	[FitExerciseId] [nvarchar](64) NOT NULL,
	[FitTagId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_FitExerciseTagMap] PRIMARY KEY CLUSTERED 
(
	[FitExerciseId] ASC,
	[FitTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitTag]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitTag](
	[Id] [nvarchar](64) NOT NULL,
	[CategoryId] [nvarchar](32) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_FitTag] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowance]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowance](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AllowanceNumber] [nvarchar](16) NULL,
	[AllowanceType] [tinyint] NULL,
	[AllowanceDate] [datetime] NULL,
	[TotalAmount] [decimal](18, 5) NULL,
	[TaxAmount] [decimal](18, 5) NULL,
	[InvoiceItemId] [int] NULL,
 CONSTRAINT [PK_InvoiceAllowance] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceCancellation]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceCancellation](
	[InvoiceAllowanceId] [int] NOT NULL,
	[CancelDate] [datetime] NULL,
	[Remark] [nvarchar](256) NULL,
	[CancelReason] [nvarchar](256) NULL,
 CONSTRAINT [PK_InvoiceAllowanceCancellation] PRIMARY KEY CLUSTERED 
(
	[InvoiceAllowanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAmountType]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAmountType](
	[InvoiceItemId] [int] NOT NULL,
	[TaxType] [tinyint] NULL,
	[SalesAmount] [decimal](18, 5) NULL,
	[TaxAmount] [decimal](18, 5) NULL,
	[TaxRate] [decimal](18, 5) NULL,
	[TotalAmount] [decimal](18, 5) NULL,
	[DiscountAmount] [decimal](18, 5) NULL,
	[Adjustment] [decimal](18, 5) NULL,
	[OriginalCurrencyAmount] [decimal](18, 5) NULL,
	[ExchangeRate] [decimal](18, 5) NULL,
	[CurrencyId] [int] NULL,
 CONSTRAINT [PK_InvoiceAmountType] PRIMARY KEY CLUSTERED 
(
	[InvoiceItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceCancellation]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceCancellation](
	[InvoiceItemId] [int] NOT NULL,
	[CancellationNo] [nvarchar](16) NULL,
	[CancelDate] [datetime] NULL,
	[CancelReason] [nvarchar](256) NULL,
	[ReturnTaxDocumentNo] [nvarchar](64) NULL,
	[Remark] [nvarchar](256) NULL,
 CONSTRAINT [PK_InvoiceCancellation] PRIMARY KEY CLUSTERED 
(
	[InvoiceItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceItem]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItem](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[No] [nvarchar](16) NULL,
	[InvoiceDate] [datetime] NULL,
	[InvoiceType] [tinyint] NULL,
	[RandomNo] [nvarchar](10) NULL,
	[TrackCode] [nvarchar](2) NULL,
	[PrintMark] [nvarchar](1) NULL,
	[DonateMark] [nvarchar](1) NULL,
	[CarrierType] [nvarchar](16) NULL,
	[CarrierNo] [nvarchar](64) NULL,
	[DonationCode] [nvarchar](64) NULL,
	[InvoicePdf] [nvarchar](256) NULL,
	[InvoiceUrl] [nvarchar](256) NULL,
 CONSTRAINT [PK_InvoiceItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Lesson]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lesson](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[CalendarEventId] [int] NOT NULL,
	[ContractServiceTypeId] [int] NOT NULL,
	[TodayFocus] [nvarchar](50) NULL,
	[Precautions] [nvarchar](50) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_Lesson] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitCategory]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitCategory](
	[Id] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](256) NULL,
	[Color] [nvarchar](32) NULL,
	[Icon] [nvarchar](64) NULL,
	[DisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_LessonFitCategory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitDetailCategories]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitDetailCategories](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LessonId] [int] NOT NULL,
	[LessonFitCategoryId] [nvarchar](64) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
 CONSTRAINT [PK_LessonFitDetailCategories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitDetailExerciseEquipmentMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitDetailExerciseEquipmentMap](
	[LessonFitDetailExerciseId] [int] NOT NULL,
	[FitEquipmentId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_LessonFitDetailExerciseEquipmentMap] PRIMARY KEY CLUSTERED 
(
	[LessonFitDetailExerciseId] ASC,
	[FitEquipmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitDetailExercises]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitDetailExercises](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LessonFitDetailCategoryId] [int] NOT NULL,
	[FitExerciseId] [nvarchar](64) NULL,
	[ExerciseName] [nvarchar](64) NOT NULL,
	[GroupIndex] [int] NULL,
	[DisplayOrder] [int] NOT NULL,
	[Parameters] [nvarchar](max) NULL,
	[Note] [nvarchar](256) NULL,
 CONSTRAINT [PK_LessonFitDetailExercises] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitDetailExerciseTagMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitDetailExerciseTagMap](
	[LessonFitDetailExerciseId] [int] NOT NULL,
	[FitTagId] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_LessonFitDetailExerciseTagMap] PRIMARY KEY CLUSTERED 
(
	[LessonFitDetailExerciseId] ASC,
	[FitTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitDetails]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitDetails](
	[LessonId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_LessonFitDetail] PRIMARY KEY CLUSTERED 
(
	[LessonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonGeneralDetails]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonGeneralDetails](
	[LessonId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[ServiceRecord] [nvarchar](500) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_LessonGeneralDetail] PRIMARY KEY CLUSTERED 
(
	[LessonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonLessonTagMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonLessonTagMap](
	[LessonId] [int] NOT NULL,
	[LessonTagId] [int] NOT NULL,
 CONSTRAINT [PK_LessonLessonTagMap] PRIMARY KEY CLUSTERED 
(
	[LessonId] ASC,
	[LessonTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonMassageDetails]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonMassageDetails](
	[LessonId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[TreatmentRecord] [nvarchar](500) NULL,
	[BodyAssessmentSuggestion] [nvarchar](500) NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_LessonMassageDetail] PRIMARY KEY CLUSTERED 
(
	[LessonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonTabs]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonTabs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Icon] [nvarchar](50) NULL,
	[Name] [nvarchar](30) NOT NULL,
	[I18nKey] [nvarchar](50) NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
 CONSTRAINT [PK_LessonTabs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonTags]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonTags](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[ContractServiceTypeId] [int] NOT NULL,
	[Name] [nvarchar](30) NOT NULL,
	[I18nKey] [nvarchar](50) NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
 CONSTRAINT [PK_LessonTags] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organization]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organization](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[ContactName] [nvarchar](50) NULL,
	[LogoURL] [nvarchar](200) NULL,
	[CompanyName] [nvarchar](128) NOT NULL,
	[ShortName] [nvarchar](30) NULL,
	[EnterpriseId] [int] NOT NULL,
	[ReceiptNo] [nvarchar](10) NULL,
	[Phone] [nvarchar](64) NULL,
	[ZipCode] [nvarchar](8) NULL,
	[ContactPhone] [nvarchar](20) NULL,
	[ContactMobilePhone] [nvarchar](20) NULL,
	[RegAddr] [nvarchar](256) NULL,
	[UndertakerName] [nvarchar](50) NULL,
	[Addr] [nvarchar](256) NULL,
	[EnglishName] [nvarchar](50) NULL,
	[EnglishAddr] [nvarchar](256) NULL,
	[EnglishRegAddr] [nvarchar](256) NULL,
	[ContactEmail] [nvarchar](512) NULL,
	[UndertakerPhone] [nvarchar](20) NULL,
	[InvoiceSignature] [nvarchar](64) NULL,
	[ContactTitle] [nvarchar](16) NULL,
	[TaxNo] [nvarchar](16) NULL,
	[AdministrativeDistrictId] [int] NULL,
	[CountryCode] [nvarchar](8) NULL,
	[CountryDial] [nvarchar](8) NULL,
	[DisplayOrder] [int] NULL,
	[IsHeadquarters] [bit] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrganizationProperty]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganizationProperty](
	[OrganizationId] [int] NOT NULL,
	[CommonPropertyId] [int] NOT NULL,
	[Property] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_OrganizationProperty] PRIMARY KEY CLUSTERED 
(
	[OrganizationId] ASC,
	[CommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OtherAccountingDiary]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OtherAccountingDiary](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[GrossAmount] [decimal](18, 2) NULL,
	[PretaxAmount] [decimal](18, 2) NULL,
	[VAT] [decimal](18, 2) NULL,
	[EntryDate] [datetime] NULL,
	[PayoffDate] [datetime] NULL,
	[FinanceAccountingTypeId] [int] NULL,
	[HandlerUserProfileId] [int] NULL,
	[PayerUserProfileId] [int] NULL,
	[BranchId] [int] NULL,
	[BuyerReceiptNo] [nvarchar](10) NULL,
	[BuyerName] [nvarchar](64) NULL,
	[PaymentMethodCommonPropertyId] [int] NULL,
	[AccountingCommonPropertyId] [int] NULL,
	[InvoiceItemId] [int] NULL,
	[Remark] [nvarchar](256) NULL,
	[ProductItems] [nvarchar](256) NULL,
	[InvoiceAllowanceId] [int] NULL,
	[BankId] [nvarchar](8) NULL,
	[BankAccount] [nvarchar](24) NULL,
	[ContractDocumentId] [int] NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_OtherAccountingDiary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentRefund]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentRefund](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[UnearnedRevenueRealizationId] [int] NULL,
	[OtherAccountingDiaryId] [int] NULL,
	[HandlerUserProfileId] [int] NULL,
	[RefundDate] [datetime] NOT NULL,
	[RefundMethodCommonPropertyId] [int] NULL,
	[BankAccount] [nvarchar](24) NULL,
	[BankId] [nvarchar](8) NULL,
	[Remark] [nvarchar](256) NULL,
	[IdCardFrontAttachmentId] [int] NULL,
	[IdCardBackAttachmentId] [int] NULL,
	[BankbookCoverAttachmentId] [int] NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_VoidPayment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[RoleName] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[IsSystemRole] [bit] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK__Role__3214EC07396EE52D] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleModule]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleModule](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Icon] [nvarchar](50) NULL,
	[ModuleName] [nvarchar](100) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__RoleModu__3214EC0724C23E20] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleModulePage]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleModulePage](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleModuleId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[PageName] [nvarchar](100) NOT NULL,
	[PageRoute] [nvarchar](200) NULL,
	[TransactionTypeCommonPropertyId] [int] NULL,
	[DisplayOrder] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__RolePage__3214EC07B58A606B] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleModulePageWorkflowMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleModulePageWorkflowMap](
	[EnterPriseId] [int] NOT NULL,
	[RoleModulePageId] [int] NOT NULL,
	[WorkFlowId] [int] NOT NULL,
 CONSTRAINT [PK_RoleModulePageWorkflowMap] PRIMARY KEY CLUSTERED 
(
	[EnterPriseId] ASC,
	[RoleModulePageId] ASC,
	[WorkFlowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleRoleModulePageMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleRoleModulePageMap](
	[RoleId] [int] NOT NULL,
	[RoleModulePageId] [int] NOT NULL,
 CONSTRAINT [PK_RoleRoleModulePageMap] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC,
	[RoleModulePageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnearnedRevenue]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnearnedRevenue](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[ContractDocumentId] [int] NOT NULL,
	[HandlerUserProfileId] [int] NULL,
	[PayerUserProfileId] [int] NULL,
	[BuyerReceiptNo] [nvarchar](10) NULL,
	[BuyerName] [nvarchar](64) NULL,
	[OriginalPrice] [decimal](18, 2) NULL,
	[TotalReceivableAmount] [decimal](18, 2) NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
	[ValueAddedTax] [decimal](18, 2) NULL,
	[PretaxAmount] [decimal](18, 2) NULL,
	[TotalTrustAmount] [decimal](18, 2) NULL,
	[PrepaymentBalance] [decimal](18, 2) NOT NULL,
	[TrustBalance] [decimal](18, 2) NOT NULL,
	[IsTaxed] [bit] NULL,
	[PayoffDate] [datetime2](7) NULL,
	[DueDate] [datetime2](7) NULL,
	[PaymentMethodCommonPropertyId] [int] NULL,
	[BankAccount] [nvarchar](24) NULL,
	[BankId] [nvarchar](8) NULL,
	[AccountingCommonPropertyId] [int] NULL,
	[BranchId] [int] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_AccountingReceivableBills] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnearnedRevenueContractItemMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnearnedRevenueContractItemMap](
	[UnearnedRevenueId] [int] NOT NULL,
	[ContractItemId] [int] NOT NULL,
	[RevenuePerSession] [decimal](18, 2) NULL,
	[TrustAmountPerSession] [decimal](18, 2) NULL,
 CONSTRAINT [PK_UnearnedRevenueContractItemMap] PRIMARY KEY CLUSTERED 
(
	[UnearnedRevenueId] ASC,
	[ContractItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnearnedRevenueRealization]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnearnedRevenueRealization](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[UnearnedRevenueId] [int] NOT NULL,
	[EntryDate] [datetime] NOT NULL,
	[PrepaymentBalance] [decimal](18, 2) NOT NULL,
	[PrepaymentOffsetAmount] [decimal](18, 2) NULL,
	[TrustBalance] [decimal](18, 2) NOT NULL,
	[RecognizedRevenue] [decimal](18, 2) NULL,
	[RefundToBuyer] [decimal](18, 2) NULL,
	[BusinessTaxReversal] [decimal](18, 2) NULL,
	[RecoverableTrustAmount] [decimal](18, 2) NULL,
	[VATOffset] [decimal](18, 2) NULL,
	[FinanceAccountingTypeId] [int] NULL,
	[InvoiceItemId] [int] NULL,
	[Remark] [nvarchar](256) NULL,
	[ProductItems] [nvarchar](256) NULL,
	[InvoiceAllowanceId] [int] NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_UnearnedRevenueRealization] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnearnedRevenueRealizationMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnearnedRevenueRealizationMap](
	[UnearnedRevenueRealizationId] [int] NOT NULL,
	[CalendarEventsId] [int] NULL,
 CONSTRAINT [PK_UnearnedRevenueRealizationMap] PRIMARY KEY CLUSTERED 
(
	[UnearnedRevenueRealizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserAccountReceivable]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAccountReceivable](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[PayerUserProfileId] [int] NOT NULL,
	[OtherAccountingDiaryId] [int] NULL,
	[UnearnedRevenueId] [int] NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_UserAccountReceivable] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserActivity]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserActivity](
	[UserProfileId] [int] NOT NULL,
	[RefreshTokenHash] [nvarchar](300) NULL,
	[IpAddress] [nvarchar](45) NULL,
	[ExpiredDate] [datetime2](7) NULL,
	[LastLoginDate] [datetime2](7) NULL,
	[LastLogoutDate] [datetime2](7) NULL,
 CONSTRAINT [PK_UserActivity] PRIMARY KEY CLUSTERED 
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfile]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfile](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[UserName] [nvarchar](40) NULL,
	[PID] [nvarchar](256) NOT NULL,
	[Password] [nvarchar](64) NULL,
	[MemberCode] [nvarchar](16) NULL,
	[Avatar] [varchar](max) NULL,
	[RealName] [nvarchar](40) NULL,
	[Gender] [int] NOT NULL,
	[Birthday] [date] NULL,
	[NickName] [nvarchar](40) NULL,
	[CountryCode] [nvarchar](8) NULL,
	[CountryDial] [nvarchar](8) NULL,
	[Phone] [nvarchar](32) NULL,
	[Email] [nvarchar](50) NULL,
	[AdministrativeDistrictId] [int] NULL,
	[Address] [nvarchar](128) NULL,
	[IDNo] [nvarchar](16) NULL,
	[RegisterStatus] [bit] NULL,
	[EmergencyContactCountryDial] [nvarchar](8) NULL,
	[EmergencyContactPhone] [nvarchar](32) NULL,
	[EmergencyContactPerson] [nvarchar](16) NULL,
	[EmergencyContactRelationship] [nvarchar](16) NULL,
	[CoachLevelId] [int] NULL,
	[CustomerLevelId] [int] NULL,
	[MicrosoftId] [nvarchar](64) NULL,
	[LineId] [nvarchar](64) NULL,
	[GoogleId] [nvarchar](64) NULL,
	[IsEmployee] [bit] NULL,
	[IsCustomer] [bit] NULL,
	[IsForeigner] [bit] NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
	[UpdateDate] [datetime2](7) NULL,
	[UpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfileNote]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileNote](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[UserProfileId] [int] NOT NULL,
	[LessonNote] [nvarchar](2000) NULL,
	[LessonNoteUpdateDateTime] [datetime2](7) NULL,
	[LessonNoteUpdateUserProfileId] [int] NULL,
	[BodyPrecautions] [nvarchar](2000) NULL,
	[BodyPrecautionsUpdateDateTime] [datetime2](7) NULL,
	[BodyPrecautionsUpdateUserProfileId] [int] NULL,
 CONSTRAINT [PK_UserProfileNote] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfileOrganizationMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileOrganizationMap](
	[UserProfileId] [int] NOT NULL,
	[OrganizationId] [int] NOT NULL,
 CONSTRAINT [PK_UserProfileOrganizationMap] PRIMARY KEY CLUSTERED 
(
	[UserProfileId] ASC,
	[OrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfileRoleMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileRoleMap](
	[UserProfileId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
 CONSTRAINT [PK_UserProfileRoleMap] PRIMARY KEY CLUSTERED 
(
	[UserProfileId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRegistryToken]    Script Date: 2026/5/17 上午 10:54:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRegistryToken](
	[UserProfileId] [int] NOT NULL,
	[IsValid] [bit] NOT NULL,
	[EnterpriseId] [int] NOT NULL,
	[Token] [nvarchar](300) NOT NULL,
	[ExpiredDate] [datetime2](7) NOT NULL,
	[CreateDate] [datetime2](7) NOT NULL,
	[CreateUserProfileId] [int] NOT NULL,
 CONSTRAINT [PK_UserRegistryToken] PRIMARY KEY CLUSTERED 
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AdministrativeDistrict_1]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AdministrativeDistrict_1] ON [dbo].[AdministrativeDistrict]
(
	[AdministrativeAreaId] ASC,
	[District] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Branch_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Branch_EnterpriseId] ON [dbo].[Branch]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Branch_OrganizationId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Branch_OrganizationId] ON [dbo].[Branch]
(
	[OrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEventAttendeeAssessments_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEventAttendeeAssessments_EnterpriseId] ON [dbo].[CalendarEventAttendeeAssessments]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEventAttendeeAssessments_UserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEventAttendeeAssessments_UserProfileId] ON [dbo].[CalendarEventAttendeeAssessments]
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEventAttendees_ContractItemId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEventAttendees_ContractItemId] ON [dbo].[CalendarEventAttendees]
(
	[ContractItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEventAttendees_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEventAttendees_EnterpriseId] ON [dbo].[CalendarEventAttendees]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEventAttendees_UserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEventAttendees_UserProfileId] ON [dbo].[CalendarEventAttendees]
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_BranchId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_BranchId] ON [dbo].[CalendarEvents]
(
	[BranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_ContractDocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_ContractDocumentId] ON [dbo].[CalendarEvents]
(
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_ContractItemId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_ContractItemId] ON [dbo].[CalendarEvents]
(
	[ContractItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_ContractServiceTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_ContractServiceTypeId] ON [dbo].[CalendarEvents]
(
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_ContractTagId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_ContractTagId] ON [dbo].[CalendarEvents]
(
	[ContractTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_ContractTypeCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_ContractTypeCategoryId] ON [dbo].[CalendarEvents]
(
	[ContractTypeCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_EnterpriseId] ON [dbo].[CalendarEvents]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CalendarEvents_OwnerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CalendarEvents_OwnerUserProfileId] ON [dbo].[CalendarEvents]
(
	[OwnerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CoachLevel_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CoachLevel_EnterpriseId] ON [dbo].[CoachLevel]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_DiscountPromotionId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_DiscountPromotionId] ON [dbo].[Contract]
(
	[DiscountPromotionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_EnterpriseId] ON [dbo].[Contract]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_NewestContractAmendmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_NewestContractAmendmentId] ON [dbo].[Contract]
(
	[NewestContractAmendmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_OrganizationId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_OrganizationId] ON [dbo].[Contract]
(
	[OrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_OwnerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_OwnerUserProfileId] ON [dbo].[Contract]
(
	[OwnerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_PaymentBranchId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_PaymentBranchId] ON [dbo].[Contract]
(
	[PaymentBranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Contract_StatusCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Contract_StatusCommonPropertyId] ON [dbo].[Contract]
(
	[StatusCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_BankbookCoverAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_BankbookCoverAttachmentId] ON [dbo].[ContractAmendment]
(
	[BankbookCoverAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_CauseForEndingCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_CauseForEndingCommonPropertyId] ON [dbo].[ContractAmendment]
(
	[CauseForEndingCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ContractAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ContractAttachmentId] ON [dbo].[ContractAmendment]
(
	[ContractAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ContractDocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ContractDocumentId] ON [dbo].[ContractAmendment]
(
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ContractTerminationFeeChargeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ContractTerminationFeeChargeId] ON [dbo].[ContractAmendment]
(
	[ContractTerminationFeeChargeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_DocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_DocumentId] ON [dbo].[ContractAmendment]
(
	[DocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_EmployeeReferralUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_EmployeeReferralUserProfileId] ON [dbo].[ContractAmendment]
(
	[EmployeeReferralUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_IdCardBackAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_IdCardBackAttachmentId] ON [dbo].[ContractAmendment]
(
	[IdCardBackAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_IdCardFrontAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_IdCardFrontAttachmentId] ON [dbo].[ContractAmendment]
(
	[IdCardFrontAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_MedicalProofAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_MedicalProofAttachmentId] ON [dbo].[ContractAmendment]
(
	[MedicalProofAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_OperatorUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_OperatorUserProfileId] ON [dbo].[ContractAmendment]
(
	[OperatorUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ParentContractAmendmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ParentContractAmendmentId] ON [dbo].[ContractAmendment]
(
	[ParentContractAmendmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ReasonCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ReasonCommonPropertyId] ON [dbo].[ContractAmendment]
(
	[ReasonCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ReferralUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ReferralUserProfileId] ON [dbo].[ContractAmendment]
(
	[ReferralUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractAmendment_ResponsibleOrganizationId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractAmendment_ResponsibleOrganizationId] ON [dbo].[ContractAmendment]
(
	[ResponsibleOrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractBillSplit_ContractPackageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractBillSplit_ContractPackageId] ON [dbo].[ContractBillSplit]
(
	[ContractPackageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractBillSplit_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractBillSplit_EnterpriseId] ON [dbo].[ContractBillSplit]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractItem_ContractDocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractItem_ContractDocumentId] ON [dbo].[ContractItem]
(
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractItem_ContractPackageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractItem_ContractPackageId] ON [dbo].[ContractItem]
(
	[ContractPackageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractMember_UserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractMember_UserProfileId] ON [dbo].[ContractMember]
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackage_ContractTypeCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackage_ContractTypeCategoryId] ON [dbo].[ContractPackage]
(
	[ContractTypeCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackage_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackage_EnterpriseId] ON [dbo].[ContractPackage]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackagePricing_ContractPackageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackagePricing_ContractPackageId] ON [dbo].[ContractPackagePricing]
(
	[ContractPackageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackagePricing_ContractTagId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackagePricing_ContractTagId] ON [dbo].[ContractPackagePricing]
(
	[ContractTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackagePricing_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackagePricing_EnterpriseId] ON [dbo].[ContractPackagePricing]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackagePricingCoachLevelMap_CoachLevelId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackagePricingCoachLevelMap_CoachLevelId] ON [dbo].[ContractPackagePricingCoachLevelMap]
(
	[CoachLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackagePricingCustomerLevelMap_CustomerLevelId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackagePricingCustomerLevelMap_CustomerLevelId] ON [dbo].[ContractPackagePricingCustomerLevelMap]
(
	[CustomerLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPackageServiceTypeMap_ContractServiceTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPackageServiceTypeMap_ContractServiceTypeId] ON [dbo].[ContractPackageServiceTypeMap]
(
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractPaymentMap_ContractDocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractPaymentMap_ContractDocumentId] ON [dbo].[ContractPaymentMap]
(
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractServiceTypeLessonTabMap_LessonTabId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractServiceTypeLessonTabMap_LessonTabId] ON [dbo].[ContractServiceTypeLessonTabMap]
(
	[LessonTabId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractTemplateStructure_ContractClauseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractTemplateStructure_ContractClauseId] ON [dbo].[ContractTemplateStructure]
(
	[ContractClauseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TemplateStructure_TemplateID]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_TemplateStructure_TemplateID] ON [dbo].[ContractTemplateStructure]
(
	[ContractTemplateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractTerminationFeeCharge]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractTerminationFeeCharge] ON [dbo].[ContractTerminationFeeCharge]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractTerminationFeeCharge_ContractPackageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractTerminationFeeCharge_ContractPackageId] ON [dbo].[ContractTerminationFeeCharge]
(
	[ContractPackageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractTypeCategory_ContractTemplateId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractTypeCategory_ContractTemplateId] ON [dbo].[ContractTypeCategory]
(
	[ContractTemplateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ContractTypeCategory_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_ContractTypeCategory_EnterpriseId] ON [dbo].[ContractTypeCategory]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CustomerLevel_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_CustomerLevel_EnterpriseId] ON [dbo].[CustomerLevel]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Document_DocumentTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Document_DocumentTypeId] ON [dbo].[Document]
(
	[DocumentTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EnterpriseContractServiceTypeMap_ContractServiceTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_EnterpriseContractServiceTypeMap_ContractServiceTypeId] ON [dbo].[EnterpriseContractServiceTypeMap]
(
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EnterpriseContractTagMap_ContractTagId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_EnterpriseContractTagMap_ContractTagId] ON [dbo].[EnterpriseContractTagMap]
(
	[ContractTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_EnterpriseFitEquipmentMap_FitEquipmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_EnterpriseFitEquipmentMap_FitEquipmentId] ON [dbo].[EnterpriseFitEquipmentMap]
(
	[FitEquipmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_EnterpriseFitExerciseMap_FitExerciseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_EnterpriseFitExerciseMap_FitExerciseId] ON [dbo].[EnterpriseFitExerciseMap]
(
	[FitExerciseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_EnterpriseLessonFitCategoryMap_LessonFitCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_EnterpriseLessonFitCategoryMap_LessonFitCategoryId] ON [dbo].[EnterpriseLessonFitCategoryMap]
(
	[LessonFitCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EnterpriseRoleModulePageMap_RoleModulePageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_EnterpriseRoleModulePageMap_RoleModulePageId] ON [dbo].[EnterpriseRoleModulePageMap]
(
	[RoleModulePageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FavoriteInvoiceItem_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FavoriteInvoiceItem_EnterpriseId] ON [dbo].[FavoriteInvoiceItem]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FavoriteInvoiceItem_UserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FavoriteInvoiceItem_UserProfileId] ON [dbo].[FavoriteInvoiceItem]
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FavoriteItems_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FavoriteItems_EnterpriseId] ON [dbo].[FavoriteItems]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FavoriteItems_PaymentTypeCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FavoriteItems_PaymentTypeCommonPropertyId] ON [dbo].[FavoriteItems]
(
	[PaymentTypeCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AccountingAbstracts]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_AccountingAbstracts] ON [dbo].[FinanceAccountingType]
(
	[TrustCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_AccountingAbstracts_1]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_AccountingAbstracts_1] ON [dbo].[FinanceAccountingType]
(
	[AbstractCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FinanceAccountingType_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FinanceAccountingType_EnterpriseId] ON [dbo].[FinanceAccountingType]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FinanceAccountingType_PaymentTypeCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FinanceAccountingType_PaymentTypeCommonPropertyId] ON [dbo].[FinanceAccountingType]
(
	[PaymentTypeCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FitEquipment_FitEquipmentCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FitEquipment_FitEquipmentCategoryId] ON [dbo].[FitEquipment]
(
	[FitEquipmentCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FitExerciseLessonCategoryMap_LessonFitCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FitExerciseLessonCategoryMap_LessonFitCategoryId] ON [dbo].[FitExerciseLessonFitCategoryMap]
(
	[LessonFitCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FitExerciseTagMap_FitTagId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FitExerciseTagMap_FitTagId] ON [dbo].[FitExerciseTagMap]
(
	[FitTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FitTag_CategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_FitTag_CategoryId] ON [dbo].[FitTag]
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_InvoiceAllowance_InvoiceItemId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_InvoiceAllowance_InvoiceItemId] ON [dbo].[InvoiceAllowance]
(
	[InvoiceItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InvoiceItem_InvoiceType_PrintMark]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_InvoiceItem_InvoiceType_PrintMark] ON [dbo].[InvoiceItem]
(
	[InvoiceType] ASC,
	[PrintMark] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lesson_CalendarEventId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Lesson_CalendarEventId] ON [dbo].[Lesson]
(
	[CalendarEventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lesson_ContractServiceTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Lesson_ContractServiceTypeId] ON [dbo].[Lesson]
(
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Lesson_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Lesson_EnterpriseId] ON [dbo].[Lesson]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_LessonFitDetailCategories_LessonFitCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonFitDetailCategories_LessonFitCategoryId] ON [dbo].[LessonFitDetailCategories]
(
	[LessonFitCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonFitDetailCategories_LessonId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonFitDetailCategories_LessonId] ON [dbo].[LessonFitDetailCategories]
(
	[LessonId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_LessonFitDetailExerciseEquipmentMap_FitEquipmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonFitDetailExerciseEquipmentMap_FitEquipmentId] ON [dbo].[LessonFitDetailExerciseEquipmentMap]
(
	[FitEquipmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_LessonFitDetailExercises_FitExerciseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonFitDetailExercises_FitExerciseId] ON [dbo].[LessonFitDetailExercises]
(
	[FitExerciseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonFitDetailExercises_LessonFitDetailCategoryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonFitDetailExercises_LessonFitDetailCategoryId] ON [dbo].[LessonFitDetailExercises]
(
	[LessonFitDetailCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_LessonFitDetailExerciseTagMap_FitTagId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonFitDetailExerciseTagMap_FitTagId] ON [dbo].[LessonFitDetailExerciseTagMap]
(
	[FitTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonLessonTagMap_LessonTagId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonLessonTagMap_LessonTagId] ON [dbo].[LessonLessonTagMap]
(
	[LessonTagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTags_ContractServiceTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTags_ContractServiceTypeId] ON [dbo].[LessonTags]
(
	[ContractServiceTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Organization_AdministrativeDistrictId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Organization_AdministrativeDistrictId] ON [dbo].[Organization]
(
	[AdministrativeDistrictId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Organization_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_Organization_EnterpriseId] ON [dbo].[Organization]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OrganizationProperty_CommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OrganizationProperty_CommonPropertyId] ON [dbo].[OrganizationProperty]
(
	[CommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_AccountingCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_AccountingCommonPropertyId] ON [dbo].[OtherAccountingDiary]
(
	[AccountingCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_BranchId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_BranchId] ON [dbo].[OtherAccountingDiary]
(
	[BranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_ContractDocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_ContractDocumentId] ON [dbo].[OtherAccountingDiary]
(
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_EnterpriseId] ON [dbo].[OtherAccountingDiary]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_FinanceAccountingTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_FinanceAccountingTypeId] ON [dbo].[OtherAccountingDiary]
(
	[FinanceAccountingTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_HandlerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_HandlerUserProfileId] ON [dbo].[OtherAccountingDiary]
(
	[HandlerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_InvoiceAllowanceId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_InvoiceAllowanceId] ON [dbo].[OtherAccountingDiary]
(
	[InvoiceAllowanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_InvoiceItemId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_InvoiceItemId] ON [dbo].[OtherAccountingDiary]
(
	[InvoiceItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_PayerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_PayerUserProfileId] ON [dbo].[OtherAccountingDiary]
(
	[PayerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_OtherAccountingDiary_PaymentMethodCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_OtherAccountingDiary_PaymentMethodCommonPropertyId] ON [dbo].[OtherAccountingDiary]
(
	[PaymentMethodCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_BankbookCoverAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_BankbookCoverAttachmentId] ON [dbo].[PaymentRefund]
(
	[BankbookCoverAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_EnterpriseId] ON [dbo].[PaymentRefund]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_HandlerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_HandlerUserProfileId] ON [dbo].[PaymentRefund]
(
	[HandlerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_IdCardBackAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_IdCardBackAttachmentId] ON [dbo].[PaymentRefund]
(
	[IdCardBackAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_IdCardFrontAttachmentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_IdCardFrontAttachmentId] ON [dbo].[PaymentRefund]
(
	[IdCardFrontAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_OtherAccountingDiaryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_OtherAccountingDiaryId] ON [dbo].[PaymentRefund]
(
	[OtherAccountingDiaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_RefundMethodCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_RefundMethodCommonPropertyId] ON [dbo].[PaymentRefund]
(
	[RefundMethodCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PaymentRefund_UnearnedRevenueRealizationId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_PaymentRefund_UnearnedRevenueRealizationId] ON [dbo].[PaymentRefund]
(
	[UnearnedRevenueRealizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_RoleName]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_RoleName] ON [dbo].[Role]
(
	[EnterpriseId] ASC,
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleModulePage_RoleModuleId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_RoleModulePage_RoleModuleId] ON [dbo].[RoleModulePage]
(
	[RoleModuleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleModulePage_TransactionTypeCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_RoleModulePage_TransactionTypeCommonPropertyId] ON [dbo].[RoleModulePage]
(
	[TransactionTypeCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleModulePageWorkflowMap_RoleModulePageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_RoleModulePageWorkflowMap_RoleModulePageId] ON [dbo].[RoleModulePageWorkflowMap]
(
	[RoleModulePageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RoleRoleModulePageMap_RoleModulePageId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_RoleRoleModulePageMap_RoleModulePageId] ON [dbo].[RoleRoleModulePageMap]
(
	[RoleModulePageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UQ_RoleRolePageMap]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_RoleRolePageMap] ON [dbo].[RoleRoleModulePageMap]
(
	[RoleId] ASC,
	[RoleModulePageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenue_BranchId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenue_BranchId] ON [dbo].[UnearnedRevenue]
(
	[BranchId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenue_ContractDocumentId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenue_ContractDocumentId] ON [dbo].[UnearnedRevenue]
(
	[ContractDocumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenue_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenue_EnterpriseId] ON [dbo].[UnearnedRevenue]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenue_HandlerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenue_HandlerUserProfileId] ON [dbo].[UnearnedRevenue]
(
	[HandlerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenue_PayerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenue_PayerUserProfileId] ON [dbo].[UnearnedRevenue]
(
	[PayerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenue_PaymentMethodCommonPropertyId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenue_PaymentMethodCommonPropertyId] ON [dbo].[UnearnedRevenue]
(
	[PaymentMethodCommonPropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueContractItemMap_ContractItemId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueContractItemMap_ContractItemId] ON [dbo].[UnearnedRevenueContractItemMap]
(
	[ContractItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueRealization_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueRealization_EnterpriseId] ON [dbo].[UnearnedRevenueRealization]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueRealization_FinanceAccountingTypeId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueRealization_FinanceAccountingTypeId] ON [dbo].[UnearnedRevenueRealization]
(
	[FinanceAccountingTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueRealization_InvoiceAllowanceId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueRealization_InvoiceAllowanceId] ON [dbo].[UnearnedRevenueRealization]
(
	[InvoiceAllowanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueRealization_InvoiceItemId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueRealization_InvoiceItemId] ON [dbo].[UnearnedRevenueRealization]
(
	[InvoiceItemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueRealization_UnearnedRevenueId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueRealization_UnearnedRevenueId] ON [dbo].[UnearnedRevenueRealization]
(
	[UnearnedRevenueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UnearnedRevenueRealizationMap_CalendarEventsId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UnearnedRevenueRealizationMap_CalendarEventsId] ON [dbo].[UnearnedRevenueRealizationMap]
(
	[CalendarEventsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserAccountReceivable]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserAccountReceivable] ON [dbo].[UserAccountReceivable]
(
	[IsValid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserAccountReceivable_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserAccountReceivable_EnterpriseId] ON [dbo].[UserAccountReceivable]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserAccountReceivable_OtherAccountingDiaryId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserAccountReceivable_OtherAccountingDiaryId] ON [dbo].[UserAccountReceivable]
(
	[OtherAccountingDiaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserAccountReceivable_PayerUserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserAccountReceivable_PayerUserProfileId] ON [dbo].[UserAccountReceivable]
(
	[PayerUserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserAccountReceivable_UnearnedRevenueId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserAccountReceivable_UnearnedRevenueId] ON [dbo].[UserAccountReceivable]
(
	[UnearnedRevenueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserProfile]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserProfile] ON [dbo].[UserProfile]
(
	[PID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfile_AdministrativeDistrictId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfile_AdministrativeDistrictId] ON [dbo].[UserProfile]
(
	[AdministrativeDistrictId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfile_CoachLevelId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfile_CoachLevelId] ON [dbo].[UserProfile]
(
	[CoachLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfile_CustomerLevelId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfile_CustomerLevelId] ON [dbo].[UserProfile]
(
	[CustomerLevelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfile_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfile_EnterpriseId] ON [dbo].[UserProfile]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfileNote_EnterpriseId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfileNote_EnterpriseId] ON [dbo].[UserProfileNote]
(
	[EnterpriseId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfileNote_UserProfileId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserProfileNote_UserProfileId] ON [dbo].[UserProfileNote]
(
	[UserProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfileOrganizationMap_OrganizationId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfileOrganizationMap_OrganizationId] ON [dbo].[UserProfileOrganizationMap]
(
	[OrganizationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_UserProfileRoleMap_RoleId]    Script Date: 2026/5/17 上午 10:54:20 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfileRoleMap_RoleId] ON [dbo].[UserProfileRoleMap]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AdministrativeArea] ADD  CONSTRAINT [DF_AdministrativeArea_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[AdministrativeDistrict] ADD  CONSTRAINT [DF_AdministrativeDistrict_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[Branch] ADD  CONSTRAINT [DF_Branch_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments] ADD  CONSTRAINT [DF_CalendarEventAttendeeAssessment_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[CalendarEventAttendees] ADD  DEFAULT ('0001-01-01T00:00:00.0000000') FOR [CreateDate]
GO
ALTER TABLE [dbo].[CalendarEventAttendees] ADD  DEFAULT ((0)) FOR [CreateUserProfileId]
GO
ALTER TABLE [dbo].[CalendarEventAttendees] ADD  CONSTRAINT [DF_CalendarEventAttendee_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[CalendarEvents] ADD  CONSTRAINT [DF_CalendarEvent_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[CoachLevel] ADD  CONSTRAINT [DF__CoachLeve__IsVal__3A5795F5]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[CoachLevel] ADD  CONSTRAINT [DF__CoachLeve__Creat__3E2826D9]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Contract] ADD  CONSTRAINT [DF_CourseContract_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractAmendment] ADD  CONSTRAINT [DF_CourseContractRevisable_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractBillSplit] ADD  CONSTRAINT [DF_ContractBillSplit_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractBillSplit] ADD  CONSTRAINT [DF_ContractBillSplit_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[ContractItem] ADD  CONSTRAINT [DF_CourseContractItem_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractPackage] ADD  CONSTRAINT [DF__CourseSub__IsVal__2C09769E]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractPackage] ADD  CONSTRAINT [DF__CourseSub__Creat__2DF1BF10]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[ContractPackagePricing] ADD  CONSTRAINT [DF__CoursePri__IsVal__31C24FF4]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractPackagePricing] ADD  CONSTRAINT [DF_ContractPackagePricing_Currency]  DEFAULT (N'TWD') FOR [Currency]
GO
ALTER TABLE [dbo].[ContractPackagePricing] ADD  CONSTRAINT [DF__CoursePri__Minim__32B6742D]  DEFAULT ((1)) FOR [MaxQuantity]
GO
ALTER TABLE [dbo].[ContractPackagePricing] ADD  CONSTRAINT [DF__CoursePri__Creat__36870511]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[ContractServiceType] ADD  CONSTRAINT [DF_ContractServiceType_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractTag] ADD  CONSTRAINT [DF_ContractTag_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractTag] ADD  CONSTRAINT [DF_ContractTag_ForFree]  DEFAULT (CONVERT([bit],(0))) FOR [ForFree]
GO
ALTER TABLE [dbo].[ContractTag] ADD  CONSTRAINT [DF_ContractTag_ForOneTimeCourse]  DEFAULT (CONVERT([bit],(0))) FOR [ForOneTimeCourse]
GO
ALTER TABLE [dbo].[ContractTemplate] ADD  CONSTRAINT [DF__ContractT__Creat__17F85C50]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[ContractTemplateClause] ADD  CONSTRAINT [DF__ClauseCon__Creat__1AD4C8FB]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[ContractTerminationFeeCharge] ADD  CONSTRAINT [DF_ContractTerminationFeeCharge_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractTypeCategory] ADD  CONSTRAINT [DF__CourseCat__IsVal__26509D48]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[ContractTypeCategory] ADD  CONSTRAINT [DF__CourseCat__Creat__2838E5BA]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[CustomerLevel] ADD  CONSTRAINT [DF_CustomerLevel_CreatedAt]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_DocDate]  DEFAULT (getdate()) FOR [DocDate]
GO
ALTER TABLE [dbo].[Enterprise] ADD  CONSTRAINT [DF_Enterprise_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[Enterprise] ADD  DEFAULT ((0)) FOR [EventLimit]
GO
ALTER TABLE [dbo].[FavoriteInvoiceItem] ADD  CONSTRAINT [DF_FavoriteInvoiceItem_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[FavoriteInvoiceItem] ADD  CONSTRAINT [DF_FavoriteInvoiceItem_CarrierType]  DEFAULT (N'3J0002') FOR [CarrierType]
GO
ALTER TABLE [dbo].[FavoriteItems] ADD  CONSTRAINT [DF_FavoriteItems_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[FinanceAccountingType] ADD  CONSTRAINT [DF_AccountingAbstracts_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[Lesson] ADD  CONSTRAINT [DF_Lesson_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[LessonFitCategory] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[LessonFitDetailCategories] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[LessonFitDetailExercises] ADD  DEFAULT ((0)) FOR [DisplayOrder]
GO
ALTER TABLE [dbo].[LessonFitDetails] ADD  CONSTRAINT [DF_LessonFitDetail_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[LessonGeneralDetails] ADD  CONSTRAINT [DF_LessonGeneralDetail_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[LessonMassageDetails] ADD  CONSTRAINT [DF_LessonMassageDetail_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[LessonTabs] ADD  CONSTRAINT [DF_LessonTab_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[LessonTags] ADD  CONSTRAINT [DF_LessonTag_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[Organization] ADD  CONSTRAINT [DF_Organization_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[OtherAccountingDiary] ADD  CONSTRAINT [DF_OtherAccountingDiary_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[PaymentRefund] ADD  CONSTRAINT [DF_PaymentRefund_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[Role] ADD  CONSTRAINT [DF__Role__CreatedDat__7F41BD1F]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[RoleModule] ADD  CONSTRAINT [DF__RoleModul__IsVal__143CDA05]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[RoleModule] ADD  CONSTRAINT [DF__RoleModul__Creat__16252277]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[RoleModulePage] ADD  CONSTRAINT [DF__RolePage__IsVali__1EBA6878]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[RoleModulePage] ADD  CONSTRAINT [DF__RolePage__Create__20A2B0EA]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[UnearnedRevenue] ADD  CONSTRAINT [DF_AccountingReceivableBills_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization] ADD  CONSTRAINT [DF_UnearnedRevenueRealization_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[UserAccountReceivable] ADD  CONSTRAINT [DF_UserAccountReceivable_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[UserProfile] ADD  CONSTRAINT [DF_UserProfile_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[UserRegistryToken] ADD  CONSTRAINT [DF_UserRegistryToken_IsValid]  DEFAULT (CONVERT([bit],(1))) FOR [IsValid]
GO
ALTER TABLE [dbo].[AdministrativeDistrict]  WITH CHECK ADD  CONSTRAINT [FK_AdministrativeDistrict_AdministrativeArea] FOREIGN KEY([AdministrativeAreaId])
REFERENCES [dbo].[AdministrativeArea] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AdministrativeDistrict] CHECK CONSTRAINT [FK_AdministrativeDistrict_AdministrativeArea]
GO
ALTER TABLE [dbo].[Branch]  WITH CHECK ADD  CONSTRAINT [FK_Branch_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[Branch] CHECK CONSTRAINT [FK_Branch_Enterprise]
GO
ALTER TABLE [dbo].[Branch]  WITH CHECK ADD  CONSTRAINT [FK_Branch_Organization] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organization] ([Id])
GO
ALTER TABLE [dbo].[Branch] CHECK CONSTRAINT [FK_Branch_Organization]
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendeeAssessment_CalendarEvent] FOREIGN KEY([CalendarEventId])
REFERENCES [dbo].[CalendarEvents] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments] CHECK CONSTRAINT [FK_CalendarEventAttendeeAssessment_CalendarEvent]
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendeeAssessment_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments] CHECK CONSTRAINT [FK_CalendarEventAttendeeAssessment_Enterprise]
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendeeAssessment_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[CalendarEventAttendeeAssessments] CHECK CONSTRAINT [FK_CalendarEventAttendeeAssessment_UserProfile]
GO
ALTER TABLE [dbo].[CalendarEventAttendees]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendee_CalendarEvent] FOREIGN KEY([CalendarEventId])
REFERENCES [dbo].[CalendarEvents] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CalendarEventAttendees] CHECK CONSTRAINT [FK_CalendarEventAttendee_CalendarEvent]
GO
ALTER TABLE [dbo].[CalendarEventAttendees]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendee_ContractItem] FOREIGN KEY([ContractItemId])
REFERENCES [dbo].[ContractItem] ([Id])
GO
ALTER TABLE [dbo].[CalendarEventAttendees] CHECK CONSTRAINT [FK_CalendarEventAttendee_ContractItem]
GO
ALTER TABLE [dbo].[CalendarEventAttendees]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendee_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[CalendarEventAttendees] CHECK CONSTRAINT [FK_CalendarEventAttendee_Enterprise]
GO
ALTER TABLE [dbo].[CalendarEventAttendees]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEventAttendee_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[CalendarEventAttendees] CHECK CONSTRAINT [FK_CalendarEventAttendee_UserProfile]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_Branch] FOREIGN KEY([BranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_Branch]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_Contract] FOREIGN KEY([ContractDocumentId])
REFERENCES [dbo].[Contract] ([DocumentId])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_Contract]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_ContractItem] FOREIGN KEY([ContractItemId])
REFERENCES [dbo].[ContractItem] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_ContractItem]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_ContractServiceType] FOREIGN KEY([ContractServiceTypeId])
REFERENCES [dbo].[ContractServiceType] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_ContractServiceType]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_ContractTag] FOREIGN KEY([ContractTagId])
REFERENCES [dbo].[ContractTag] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_ContractTag]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_ContractTypeCategory] FOREIGN KEY([ContractTypeCategoryId])
REFERENCES [dbo].[ContractTypeCategory] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_ContractTypeCategory]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvent_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvent_Enterprise]
GO
ALTER TABLE [dbo].[CalendarEvents]  WITH CHECK ADD  CONSTRAINT [FK_CalendarEvents_UserProfile_OwnerUserProfileId] FOREIGN KEY([OwnerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[CalendarEvents] CHECK CONSTRAINT [FK_CalendarEvents_UserProfile_OwnerUserProfileId]
GO
ALTER TABLE [dbo].[CoachLevel]  WITH CHECK ADD  CONSTRAINT [FK_CoachLevel_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[CoachLevel] CHECK CONSTRAINT [FK_CoachLevel_Enterprise]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_CommonProperty] FOREIGN KEY([StatusCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_CommonProperty]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_ContractAmendment] FOREIGN KEY([NewestContractAmendmentId])
REFERENCES [dbo].[ContractAmendment] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_ContractAmendment]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_CourseLocation] FOREIGN KEY([PaymentBranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_CourseLocation]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_DiscountPromotion] FOREIGN KEY([DiscountPromotionId])
REFERENCES [dbo].[DiscountPromotion] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_DiscountPromotion]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_Document] FOREIGN KEY([DocumentId])
REFERENCES [dbo].[Document] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_Document]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_Enterprise]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_Organization] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organization] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_Organization]
GO
ALTER TABLE [dbo].[Contract]  WITH CHECK ADD  CONSTRAINT [FK_Contract_UserProfile] FOREIGN KEY([OwnerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[Contract] CHECK CONSTRAINT [FK_Contract_UserProfile]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Attachment] FOREIGN KEY([ContractAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Attachment]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Attachment1] FOREIGN KEY([IdCardFrontAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Attachment1]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Attachment2] FOREIGN KEY([IdCardBackAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Attachment2]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Attachment3] FOREIGN KEY([MedicalProofAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Attachment3]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Attachment4] FOREIGN KEY([BankbookCoverAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Attachment4]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_CommonProperty] FOREIGN KEY([ReasonCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_CommonProperty]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_CommonProperty2] FOREIGN KEY([CauseForEndingCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_CommonProperty2]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Contract] FOREIGN KEY([ContractDocumentId])
REFERENCES [dbo].[Contract] ([DocumentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Contract]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_ContractAmendment] FOREIGN KEY([ParentContractAmendmentId])
REFERENCES [dbo].[ContractAmendment] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_ContractAmendment]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_CourseContractTermationFeeCharge] FOREIGN KEY([ContractTerminationFeeChargeId])
REFERENCES [dbo].[ContractTerminationFeeCharge] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_CourseContractTermationFeeCharge]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Document] FOREIGN KEY([DocumentId])
REFERENCES [dbo].[Document] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Document]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_EmployeeReferralUserProfile] FOREIGN KEY([EmployeeReferralUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_EmployeeReferralUserProfile]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_OperatorUserProfile] FOREIGN KEY([OperatorUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_OperatorUserProfile]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_Organization] FOREIGN KEY([ResponsibleOrganizationId])
REFERENCES [dbo].[Organization] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_Organization]
GO
ALTER TABLE [dbo].[ContractAmendment]  WITH CHECK ADD  CONSTRAINT [FK_ContractAmendment_ReferralUserProfile] FOREIGN KEY([ReferralUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[ContractAmendment] CHECK CONSTRAINT [FK_ContractAmendment_ReferralUserProfile]
GO
ALTER TABLE [dbo].[ContractBillSplit]  WITH CHECK ADD  CONSTRAINT [FK_ContractBillSplit_ContractPackage] FOREIGN KEY([ContractPackageId])
REFERENCES [dbo].[ContractPackage] ([Id])
GO
ALTER TABLE [dbo].[ContractBillSplit] CHECK CONSTRAINT [FK_ContractBillSplit_ContractPackage]
GO
ALTER TABLE [dbo].[ContractBillSplit]  WITH CHECK ADD  CONSTRAINT [FK_ContractBillSplit_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[ContractBillSplit] CHECK CONSTRAINT [FK_ContractBillSplit_Enterprise]
GO
ALTER TABLE [dbo].[ContractItem]  WITH CHECK ADD  CONSTRAINT [FK_ContractItem_Contract] FOREIGN KEY([ContractDocumentId])
REFERENCES [dbo].[Contract] ([DocumentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractItem] CHECK CONSTRAINT [FK_ContractItem_Contract]
GO
ALTER TABLE [dbo].[ContractItem]  WITH CHECK ADD  CONSTRAINT [FK_ContractItem_ContractPackage] FOREIGN KEY([ContractPackageId])
REFERENCES [dbo].[ContractPackage] ([Id])
GO
ALTER TABLE [dbo].[ContractItem] CHECK CONSTRAINT [FK_ContractItem_ContractPackage]
GO
ALTER TABLE [dbo].[ContractMember]  WITH CHECK ADD  CONSTRAINT [FK_ContractMember_ContractAmendment] FOREIGN KEY([ContractContractAmendmentId])
REFERENCES [dbo].[ContractAmendment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractMember] CHECK CONSTRAINT [FK_ContractMember_ContractAmendment]
GO
ALTER TABLE [dbo].[ContractMember]  WITH CHECK ADD  CONSTRAINT [FK_ContractMember_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[ContractMember] CHECK CONSTRAINT [FK_ContractMember_UserProfile]
GO
ALTER TABLE [dbo].[ContractPackage]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackage_ContractTypeCategory] FOREIGN KEY([ContractTypeCategoryId])
REFERENCES [dbo].[ContractTypeCategory] ([Id])
GO
ALTER TABLE [dbo].[ContractPackage] CHECK CONSTRAINT [FK_ContractPackage_ContractTypeCategory]
GO
ALTER TABLE [dbo].[ContractPackage]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackage_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[ContractPackage] CHECK CONSTRAINT [FK_ContractPackage_Enterprise]
GO
ALTER TABLE [dbo].[ContractPackagePricing]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricing_ContractPackage] FOREIGN KEY([ContractPackageId])
REFERENCES [dbo].[ContractPackage] ([Id])
GO
ALTER TABLE [dbo].[ContractPackagePricing] CHECK CONSTRAINT [FK_ContractPackagePricing_ContractPackage]
GO
ALTER TABLE [dbo].[ContractPackagePricing]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricing_ContractTag] FOREIGN KEY([ContractTagId])
REFERENCES [dbo].[ContractTag] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[ContractPackagePricing] CHECK CONSTRAINT [FK_ContractPackagePricing_ContractTag]
GO
ALTER TABLE [dbo].[ContractPackagePricing]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricing_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[ContractPackagePricing] CHECK CONSTRAINT [FK_ContractPackagePricing_Enterprise]
GO
ALTER TABLE [dbo].[ContractPackagePricingCoachLevelMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricingCoachLevelMap_CoachLevel] FOREIGN KEY([CoachLevelId])
REFERENCES [dbo].[CoachLevel] ([Id])
GO
ALTER TABLE [dbo].[ContractPackagePricingCoachLevelMap] CHECK CONSTRAINT [FK_ContractPackagePricingCoachLevelMap_CoachLevel]
GO
ALTER TABLE [dbo].[ContractPackagePricingCoachLevelMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricingCoachLevelMap_ContractPackagePricing] FOREIGN KEY([ContractPackagePricingId])
REFERENCES [dbo].[ContractPackagePricing] ([Id])
GO
ALTER TABLE [dbo].[ContractPackagePricingCoachLevelMap] CHECK CONSTRAINT [FK_ContractPackagePricingCoachLevelMap_ContractPackagePricing]
GO
ALTER TABLE [dbo].[ContractPackagePricingCustomerLevelMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricingCustomerLevelMap_ContractPackagePricing] FOREIGN KEY([ContractPackagePricingId])
REFERENCES [dbo].[ContractPackagePricing] ([Id])
GO
ALTER TABLE [dbo].[ContractPackagePricingCustomerLevelMap] CHECK CONSTRAINT [FK_ContractPackagePricingCustomerLevelMap_ContractPackagePricing]
GO
ALTER TABLE [dbo].[ContractPackagePricingCustomerLevelMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackagePricingCustomerLevelMap_CustomerLevel] FOREIGN KEY([CustomerLevelId])
REFERENCES [dbo].[CustomerLevel] ([Id])
GO
ALTER TABLE [dbo].[ContractPackagePricingCustomerLevelMap] CHECK CONSTRAINT [FK_ContractPackagePricingCustomerLevelMap_CustomerLevel]
GO
ALTER TABLE [dbo].[ContractPackageServiceTypeMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackageServiceTypeMap_ContractPackage] FOREIGN KEY([ContractPackageId])
REFERENCES [dbo].[ContractPackage] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractPackageServiceTypeMap] CHECK CONSTRAINT [FK_ContractPackageServiceTypeMap_ContractPackage]
GO
ALTER TABLE [dbo].[ContractPackageServiceTypeMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPackageServiceTypeMap_ContractServiceType] FOREIGN KEY([ContractServiceTypeId])
REFERENCES [dbo].[ContractServiceType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractPackageServiceTypeMap] CHECK CONSTRAINT [FK_ContractPackageServiceTypeMap_ContractServiceType]
GO
ALTER TABLE [dbo].[ContractPaymentMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractPaymentMap_Contract] FOREIGN KEY([ContractDocumentId])
REFERENCES [dbo].[Contract] ([DocumentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractPaymentMap] CHECK CONSTRAINT [FK_ContractPaymentMap_Contract]
GO
ALTER TABLE [dbo].[ContractServiceTypeLessonTabMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractServiceTypeLessonTabMap_ContractServiceType] FOREIGN KEY([ContractServiceTypeId])
REFERENCES [dbo].[ContractServiceType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractServiceTypeLessonTabMap] CHECK CONSTRAINT [FK_ContractServiceTypeLessonTabMap_ContractServiceType]
GO
ALTER TABLE [dbo].[ContractServiceTypeLessonTabMap]  WITH CHECK ADD  CONSTRAINT [FK_ContractServiceTypeLessonTabMap_LessonTab] FOREIGN KEY([LessonTabId])
REFERENCES [dbo].[LessonTabs] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractServiceTypeLessonTabMap] CHECK CONSTRAINT [FK_ContractServiceTypeLessonTabMap_LessonTab]
GO
ALTER TABLE [dbo].[ContractTemplateStructure]  WITH CHECK ADD  CONSTRAINT [FK_ContractTemplateStructure_ContractTemplate] FOREIGN KEY([ContractTemplateId])
REFERENCES [dbo].[ContractTemplate] ([Id])
GO
ALTER TABLE [dbo].[ContractTemplateStructure] CHECK CONSTRAINT [FK_ContractTemplateStructure_ContractTemplate]
GO
ALTER TABLE [dbo].[ContractTemplateStructure]  WITH CHECK ADD  CONSTRAINT [FK_TemplateStructure_Clause] FOREIGN KEY([ContractClauseId])
REFERENCES [dbo].[ContractTemplateClause] ([Id])
GO
ALTER TABLE [dbo].[ContractTemplateStructure] CHECK CONSTRAINT [FK_TemplateStructure_Clause]
GO
ALTER TABLE [dbo].[ContractTerminationFeeCharge]  WITH CHECK ADD  CONSTRAINT [FK_ContractTerminationFeeCharge_ContractPackage] FOREIGN KEY([ContractPackageId])
REFERENCES [dbo].[ContractPackage] ([Id])
GO
ALTER TABLE [dbo].[ContractTerminationFeeCharge] CHECK CONSTRAINT [FK_ContractTerminationFeeCharge_ContractPackage]
GO
ALTER TABLE [dbo].[ContractTerminationFeeCharge]  WITH CHECK ADD  CONSTRAINT [FK_ContractTerminationFeeCharge_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[ContractTerminationFeeCharge] CHECK CONSTRAINT [FK_ContractTerminationFeeCharge_Enterprise]
GO
ALTER TABLE [dbo].[ContractTypeCategory]  WITH CHECK ADD  CONSTRAINT [FK_ContractTypeCategory_ContractTemplate] FOREIGN KEY([ContractTemplateId])
REFERENCES [dbo].[ContractTemplate] ([Id])
GO
ALTER TABLE [dbo].[ContractTypeCategory] CHECK CONSTRAINT [FK_ContractTypeCategory_ContractTemplate]
GO
ALTER TABLE [dbo].[ContractTypeCategory]  WITH CHECK ADD  CONSTRAINT [FK_ContractTypeCategory_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[ContractTypeCategory] CHECK CONSTRAINT [FK_ContractTypeCategory_Enterprise]
GO
ALTER TABLE [dbo].[CustomerLevel]  WITH CHECK ADD  CONSTRAINT [FK_CustomerLevel_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[CustomerLevel] CHECK CONSTRAINT [FK_CustomerLevel_Enterprise]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_DocumentType] FOREIGN KEY([DocumentTypeId])
REFERENCES [dbo].[DocumentType] ([Id])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_DocumentType]
GO
ALTER TABLE [dbo].[DocumentTypeTask]  WITH CHECK ADD  CONSTRAINT [FK_DocumentTypeTask_DocumentType] FOREIGN KEY([DocumentTypeId])
REFERENCES [dbo].[DocumentType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocumentTypeTask] CHECK CONSTRAINT [FK_DocumentTypeTask_DocumentType]
GO
ALTER TABLE [dbo].[EnterpriseContractServiceTypeMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseContractServiceTypeMap_ContractServiceType] FOREIGN KEY([ContractServiceTypeId])
REFERENCES [dbo].[ContractServiceType] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseContractServiceTypeMap] CHECK CONSTRAINT [FK_EnterpriseContractServiceTypeMap_ContractServiceType]
GO
ALTER TABLE [dbo].[EnterpriseContractServiceTypeMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseContractServiceTypeMap_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseContractServiceTypeMap] CHECK CONSTRAINT [FK_EnterpriseContractServiceTypeMap_Enterprise]
GO
ALTER TABLE [dbo].[EnterpriseContractTagMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseContractTagMap_ContractTag] FOREIGN KEY([ContractTagId])
REFERENCES [dbo].[ContractTag] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseContractTagMap] CHECK CONSTRAINT [FK_EnterpriseContractTagMap_ContractTag]
GO
ALTER TABLE [dbo].[EnterpriseContractTagMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseContractTagMap_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseContractTagMap] CHECK CONSTRAINT [FK_EnterpriseContractTagMap_Enterprise]
GO
ALTER TABLE [dbo].[EnterpriseFitEquipmentMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseFitEquipmentMap_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseFitEquipmentMap] CHECK CONSTRAINT [FK_EnterpriseFitEquipmentMap_Enterprise]
GO
ALTER TABLE [dbo].[EnterpriseFitEquipmentMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseFitEquipmentMap_FitEquipment] FOREIGN KEY([FitEquipmentId])
REFERENCES [dbo].[FitEquipment] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseFitEquipmentMap] CHECK CONSTRAINT [FK_EnterpriseFitEquipmentMap_FitEquipment]
GO
ALTER TABLE [dbo].[EnterpriseFitExerciseMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseFitExerciseMap_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseFitExerciseMap] CHECK CONSTRAINT [FK_EnterpriseFitExerciseMap_Enterprise]
GO
ALTER TABLE [dbo].[EnterpriseFitExerciseMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseFitExerciseMap_FitExercise] FOREIGN KEY([FitExerciseId])
REFERENCES [dbo].[FitExercise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseFitExerciseMap] CHECK CONSTRAINT [FK_EnterpriseFitExerciseMap_FitExercise]
GO
ALTER TABLE [dbo].[EnterpriseLessonFitCategoryMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseLessonFitCategoryMap_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseLessonFitCategoryMap] CHECK CONSTRAINT [FK_EnterpriseLessonFitCategoryMap_Enterprise]
GO
ALTER TABLE [dbo].[EnterpriseLessonFitCategoryMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseLessonFitCategoryMap_LessonFitCategory] FOREIGN KEY([LessonFitCategoryId])
REFERENCES [dbo].[LessonFitCategory] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseLessonFitCategoryMap] CHECK CONSTRAINT [FK_EnterpriseLessonFitCategoryMap_LessonFitCategory]
GO
ALTER TABLE [dbo].[EnterpriseRoleModulePageMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseRoleModulePageMap_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseRoleModulePageMap] CHECK CONSTRAINT [FK_EnterpriseRoleModulePageMap_Enterprise]
GO
ALTER TABLE [dbo].[EnterpriseRoleModulePageMap]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseRoleModulePageMap_RoleModulePage] FOREIGN KEY([RoleModulePageId])
REFERENCES [dbo].[RoleModulePage] ([Id])
GO
ALTER TABLE [dbo].[EnterpriseRoleModulePageMap] CHECK CONSTRAINT [FK_EnterpriseRoleModulePageMap_RoleModulePage]
GO
ALTER TABLE [dbo].[FavoriteInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_FavoriteInvoiceItem_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[FavoriteInvoiceItem] CHECK CONSTRAINT [FK_FavoriteInvoiceItem_Enterprise]
GO
ALTER TABLE [dbo].[FavoriteInvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_FavoriteInvoiceItem_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[FavoriteInvoiceItem] CHECK CONSTRAINT [FK_FavoriteInvoiceItem_UserProfile]
GO
ALTER TABLE [dbo].[FavoriteItems]  WITH CHECK ADD  CONSTRAINT [FK_FavoriteItems_CommonProperty] FOREIGN KEY([PaymentTypeCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[FavoriteItems] CHECK CONSTRAINT [FK_FavoriteItems_CommonProperty]
GO
ALTER TABLE [dbo].[FavoriteItems]  WITH CHECK ADD  CONSTRAINT [FK_FavoriteItems_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[FavoriteItems] CHECK CONSTRAINT [FK_FavoriteItems_Enterprise]
GO
ALTER TABLE [dbo].[FinanceAccountingType]  WITH CHECK ADD  CONSTRAINT [FK_AccountingAbstracts_Enterprise1] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[FinanceAccountingType] CHECK CONSTRAINT [FK_AccountingAbstracts_Enterprise1]
GO
ALTER TABLE [dbo].[FinanceAccountingType]  WITH CHECK ADD  CONSTRAINT [FK_FinanceAccountingType_CommonProperty] FOREIGN KEY([PaymentTypeCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[FinanceAccountingType] CHECK CONSTRAINT [FK_FinanceAccountingType_CommonProperty]
GO
ALTER TABLE [dbo].[FitEquipment]  WITH CHECK ADD  CONSTRAINT [FK_FitEquipment_FitEquipmentCategory] FOREIGN KEY([FitEquipmentCategoryId])
REFERENCES [dbo].[FitEquipmentCategory] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FitEquipment] CHECK CONSTRAINT [FK_FitEquipment_FitEquipmentCategory]
GO
ALTER TABLE [dbo].[FitExerciseLessonFitCategoryMap]  WITH CHECK ADD  CONSTRAINT [FK_FitExerciseLessonFitCategoryMap_FitExercise] FOREIGN KEY([FitExerciseId])
REFERENCES [dbo].[FitExercise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FitExerciseLessonFitCategoryMap] CHECK CONSTRAINT [FK_FitExerciseLessonFitCategoryMap_FitExercise]
GO
ALTER TABLE [dbo].[FitExerciseLessonFitCategoryMap]  WITH CHECK ADD  CONSTRAINT [FK_FitExerciseLessonFitCategoryMap_LessonFitCategory] FOREIGN KEY([LessonFitCategoryId])
REFERENCES [dbo].[LessonFitCategory] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FitExerciseLessonFitCategoryMap] CHECK CONSTRAINT [FK_FitExerciseLessonFitCategoryMap_LessonFitCategory]
GO
ALTER TABLE [dbo].[FitExerciseTagMap]  WITH CHECK ADD  CONSTRAINT [FK_FitExerciseTagMap_FitExercise] FOREIGN KEY([FitExerciseId])
REFERENCES [dbo].[FitExercise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FitExerciseTagMap] CHECK CONSTRAINT [FK_FitExerciseTagMap_FitExercise]
GO
ALTER TABLE [dbo].[FitExerciseTagMap]  WITH CHECK ADD  CONSTRAINT [FK_FitExerciseTagMap_FitTag] FOREIGN KEY([FitTagId])
REFERENCES [dbo].[FitTag] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FitExerciseTagMap] CHECK CONSTRAINT [FK_FitExerciseTagMap_FitTag]
GO
ALTER TABLE [dbo].[InvoiceAllowance]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowance_InvoiceItem] FOREIGN KEY([InvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[InvoiceAllowance] CHECK CONSTRAINT [FK_InvoiceAllowance_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceAllowanceCancellation]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceCancellation_InvoiceAllowance] FOREIGN KEY([InvoiceAllowanceId])
REFERENCES [dbo].[InvoiceAllowance] ([Id])
GO
ALTER TABLE [dbo].[InvoiceAllowanceCancellation] CHECK CONSTRAINT [FK_InvoiceAllowanceCancellation_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAmountType]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAmountType_InvoiceItem] FOREIGN KEY([InvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAmountType] CHECK CONSTRAINT [FK_InvoiceAmountType_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceCancellation]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceCancellation_InvoiceItem] FOREIGN KEY([InvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceCancellation] CHECK CONSTRAINT [FK_InvoiceCancellation_InvoiceItem]
GO
ALTER TABLE [dbo].[Lesson]  WITH CHECK ADD  CONSTRAINT [FK_Lesson_CalendarEvent] FOREIGN KEY([CalendarEventId])
REFERENCES [dbo].[CalendarEvents] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Lesson] CHECK CONSTRAINT [FK_Lesson_CalendarEvent]
GO
ALTER TABLE [dbo].[Lesson]  WITH CHECK ADD  CONSTRAINT [FK_Lesson_ContractServiceType] FOREIGN KEY([ContractServiceTypeId])
REFERENCES [dbo].[ContractServiceType] ([Id])
GO
ALTER TABLE [dbo].[Lesson] CHECK CONSTRAINT [FK_Lesson_ContractServiceType]
GO
ALTER TABLE [dbo].[Lesson]  WITH CHECK ADD  CONSTRAINT [FK_Lesson_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[Lesson] CHECK CONSTRAINT [FK_Lesson_Enterprise]
GO
ALTER TABLE [dbo].[LessonFitDetailCategories]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailCategory_LessonFitCategory] FOREIGN KEY([LessonFitCategoryId])
REFERENCES [dbo].[LessonFitCategory] ([Id])
GO
ALTER TABLE [dbo].[LessonFitDetailCategories] CHECK CONSTRAINT [FK_LessonFitDetailCategory_LessonFitCategory]
GO
ALTER TABLE [dbo].[LessonFitDetailCategories]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailCategory_LessonFitDetail] FOREIGN KEY([LessonId])
REFERENCES [dbo].[LessonFitDetails] ([LessonId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitDetailCategories] CHECK CONSTRAINT [FK_LessonFitDetailCategory_LessonFitDetail]
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseEquipmentMap]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailExerciseEquipmentMap_Exercise] FOREIGN KEY([LessonFitDetailExerciseId])
REFERENCES [dbo].[LessonFitDetailExercises] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseEquipmentMap] CHECK CONSTRAINT [FK_LessonFitDetailExerciseEquipmentMap_Exercise]
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseEquipmentMap]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailExerciseEquipmentMap_FitEquipment] FOREIGN KEY([FitEquipmentId])
REFERENCES [dbo].[FitEquipment] ([Id])
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseEquipmentMap] CHECK CONSTRAINT [FK_LessonFitDetailExerciseEquipmentMap_FitEquipment]
GO
ALTER TABLE [dbo].[LessonFitDetailExercises]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailExercise_FitExercise] FOREIGN KEY([FitExerciseId])
REFERENCES [dbo].[FitExercise] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[LessonFitDetailExercises] CHECK CONSTRAINT [FK_LessonFitDetailExercise_FitExercise]
GO
ALTER TABLE [dbo].[LessonFitDetailExercises]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailExercise_LessonFitDetailCategory] FOREIGN KEY([LessonFitDetailCategoryId])
REFERENCES [dbo].[LessonFitDetailCategories] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitDetailExercises] CHECK CONSTRAINT [FK_LessonFitDetailExercise_LessonFitDetailCategory]
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseTagMap]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailExerciseTagMap_Exercise] FOREIGN KEY([LessonFitDetailExerciseId])
REFERENCES [dbo].[LessonFitDetailExercises] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseTagMap] CHECK CONSTRAINT [FK_LessonFitDetailExerciseTagMap_Exercise]
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseTagMap]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetailExerciseTagMap_FitTag] FOREIGN KEY([FitTagId])
REFERENCES [dbo].[FitTag] ([Id])
GO
ALTER TABLE [dbo].[LessonFitDetailExerciseTagMap] CHECK CONSTRAINT [FK_LessonFitDetailExerciseTagMap_FitTag]
GO
ALTER TABLE [dbo].[LessonFitDetails]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitDetail_Lesson] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lesson] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitDetails] CHECK CONSTRAINT [FK_LessonFitDetail_Lesson]
GO
ALTER TABLE [dbo].[LessonGeneralDetails]  WITH CHECK ADD  CONSTRAINT [FK_LessonGeneralDetail_Lesson] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lesson] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonGeneralDetails] CHECK CONSTRAINT [FK_LessonGeneralDetail_Lesson]
GO
ALTER TABLE [dbo].[LessonLessonTagMap]  WITH CHECK ADD  CONSTRAINT [FK_LessonLessonTagMap_Lesson] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lesson] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonLessonTagMap] CHECK CONSTRAINT [FK_LessonLessonTagMap_Lesson]
GO
ALTER TABLE [dbo].[LessonLessonTagMap]  WITH CHECK ADD  CONSTRAINT [FK_LessonLessonTagMap_LessonTag] FOREIGN KEY([LessonTagId])
REFERENCES [dbo].[LessonTags] ([Id])
GO
ALTER TABLE [dbo].[LessonLessonTagMap] CHECK CONSTRAINT [FK_LessonLessonTagMap_LessonTag]
GO
ALTER TABLE [dbo].[LessonMassageDetails]  WITH CHECK ADD  CONSTRAINT [FK_LessonMassageDetail_Lesson] FOREIGN KEY([LessonId])
REFERENCES [dbo].[Lesson] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonMassageDetails] CHECK CONSTRAINT [FK_LessonMassageDetail_Lesson]
GO
ALTER TABLE [dbo].[LessonTags]  WITH CHECK ADD  CONSTRAINT [FK_LessonTag_ContractServiceType] FOREIGN KEY([ContractServiceTypeId])
REFERENCES [dbo].[ContractServiceType] ([Id])
GO
ALTER TABLE [dbo].[LessonTags] CHECK CONSTRAINT [FK_LessonTag_ContractServiceType]
GO
ALTER TABLE [dbo].[Organization]  WITH CHECK ADD  CONSTRAINT [FK_Organization_AdministrativeDistrict] FOREIGN KEY([AdministrativeDistrictId])
REFERENCES [dbo].[AdministrativeDistrict] ([Id])
GO
ALTER TABLE [dbo].[Organization] CHECK CONSTRAINT [FK_Organization_AdministrativeDistrict]
GO
ALTER TABLE [dbo].[Organization]  WITH CHECK ADD  CONSTRAINT [FK_Organization_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[Organization] CHECK CONSTRAINT [FK_Organization_Enterprise]
GO
ALTER TABLE [dbo].[OrganizationProperty]  WITH CHECK ADD  CONSTRAINT [FK_OrganizationProperty_CommonProperty] FOREIGN KEY([CommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[OrganizationProperty] CHECK CONSTRAINT [FK_OrganizationProperty_CommonProperty]
GO
ALTER TABLE [dbo].[OrganizationProperty]  WITH CHECK ADD  CONSTRAINT [FK_OrganizationProperty_Organization] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organization] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OrganizationProperty] CHECK CONSTRAINT [FK_OrganizationProperty_Organization]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_AccountingAbstracts] FOREIGN KEY([FinanceAccountingTypeId])
REFERENCES [dbo].[FinanceAccountingType] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_AccountingAbstracts]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_Branch] FOREIGN KEY([BranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_Branch]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_CommonProperty] FOREIGN KEY([PaymentMethodCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_CommonProperty]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_CommonProperty1] FOREIGN KEY([AccountingCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_CommonProperty1]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_Contract] FOREIGN KEY([ContractDocumentId])
REFERENCES [dbo].[Contract] ([DocumentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_Contract]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_Enterprise]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_InvoiceAllowance] FOREIGN KEY([InvoiceAllowanceId])
REFERENCES [dbo].[InvoiceAllowance] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_InvoiceAllowance]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_InvoiceItem] FOREIGN KEY([InvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_InvoiceItem]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_UserProfile] FOREIGN KEY([PayerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_UserProfile]
GO
ALTER TABLE [dbo].[OtherAccountingDiary]  WITH CHECK ADD  CONSTRAINT [FK_OtherAccountingDiary_UserProfile1] FOREIGN KEY([HandlerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[OtherAccountingDiary] CHECK CONSTRAINT [FK_OtherAccountingDiary_UserProfile1]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_PaymentRefund_Attachment] FOREIGN KEY([IdCardFrontAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_PaymentRefund_Attachment]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_PaymentRefund_Attachment1] FOREIGN KEY([IdCardBackAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_PaymentRefund_Attachment1]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_PaymentRefund_Attachment2] FOREIGN KEY([BankbookCoverAttachmentId])
REFERENCES [dbo].[Attachment] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_PaymentRefund_Attachment2]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_PaymentRefund_CommonProperty] FOREIGN KEY([RefundMethodCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_PaymentRefund_CommonProperty]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_PaymentRefund_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_PaymentRefund_Enterprise]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_PaymentRefund_UserProfile] FOREIGN KEY([HandlerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_PaymentRefund_UserProfile]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_VoidPayment_OtherAccountingDiary] FOREIGN KEY([OtherAccountingDiaryId])
REFERENCES [dbo].[OtherAccountingDiary] ([Id])
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_VoidPayment_OtherAccountingDiary]
GO
ALTER TABLE [dbo].[PaymentRefund]  WITH CHECK ADD  CONSTRAINT [FK_VoidPayment_UnearnedRevenueRealization] FOREIGN KEY([UnearnedRevenueRealizationId])
REFERENCES [dbo].[UnearnedRevenueRealization] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaymentRefund] CHECK CONSTRAINT [FK_VoidPayment_UnearnedRevenueRealization]
GO
ALTER TABLE [dbo].[Role]  WITH CHECK ADD  CONSTRAINT [FK__Role__Enterprise__0035E158] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[Role] CHECK CONSTRAINT [FK__Role__Enterprise__0035E158]
GO
ALTER TABLE [dbo].[RoleModulePage]  WITH CHECK ADD  CONSTRAINT [FK__RolePage__RoleMo__2196D523] FOREIGN KEY([RoleModuleId])
REFERENCES [dbo].[RoleModule] ([Id])
GO
ALTER TABLE [dbo].[RoleModulePage] CHECK CONSTRAINT [FK__RolePage__RoleMo__2196D523]
GO
ALTER TABLE [dbo].[RoleModulePage]  WITH CHECK ADD  CONSTRAINT [FK_RoleModulePage_CommonProperty] FOREIGN KEY([TransactionTypeCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[RoleModulePage] CHECK CONSTRAINT [FK_RoleModulePage_CommonProperty]
GO
ALTER TABLE [dbo].[RoleModulePageWorkflowMap]  WITH CHECK ADD  CONSTRAINT [FK_RoleModulePageWorkflowMap_Enterprise] FOREIGN KEY([EnterPriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[RoleModulePageWorkflowMap] CHECK CONSTRAINT [FK_RoleModulePageWorkflowMap_Enterprise]
GO
ALTER TABLE [dbo].[RoleModulePageWorkflowMap]  WITH CHECK ADD  CONSTRAINT [FK_RoleModulePageWorkflowMap_RoleModulePage] FOREIGN KEY([RoleModulePageId])
REFERENCES [dbo].[RoleModulePage] ([Id])
GO
ALTER TABLE [dbo].[RoleModulePageWorkflowMap] CHECK CONSTRAINT [FK_RoleModulePageWorkflowMap_RoleModulePage]
GO
ALTER TABLE [dbo].[RoleRoleModulePageMap]  WITH CHECK ADD  CONSTRAINT [FK__RoleRoleP__RoleI__247341CE] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[RoleRoleModulePageMap] CHECK CONSTRAINT [FK__RoleRoleP__RoleI__247341CE]
GO
ALTER TABLE [dbo].[RoleRoleModulePageMap]  WITH CHECK ADD  CONSTRAINT [FK__RoleRoleP__RoleP__25676607] FOREIGN KEY([RoleModulePageId])
REFERENCES [dbo].[RoleModulePage] ([Id])
GO
ALTER TABLE [dbo].[RoleRoleModulePageMap] CHECK CONSTRAINT [FK__RoleRoleP__RoleP__25676607]
GO
ALTER TABLE [dbo].[UnearnedRevenue]  WITH CHECK ADD  CONSTRAINT [FK_AccountingReceivableBills_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenue] CHECK CONSTRAINT [FK_AccountingReceivableBills_Enterprise]
GO
ALTER TABLE [dbo].[UnearnedRevenue]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenue_Branch] FOREIGN KEY([BranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenue] CHECK CONSTRAINT [FK_UnearnedRevenue_Branch]
GO
ALTER TABLE [dbo].[UnearnedRevenue]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenue_CommonProperty] FOREIGN KEY([PaymentMethodCommonPropertyId])
REFERENCES [dbo].[CommonProperty] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenue] CHECK CONSTRAINT [FK_UnearnedRevenue_CommonProperty]
GO
ALTER TABLE [dbo].[UnearnedRevenue]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenue_Contract] FOREIGN KEY([ContractDocumentId])
REFERENCES [dbo].[Contract] ([DocumentId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UnearnedRevenue] CHECK CONSTRAINT [FK_UnearnedRevenue_Contract]
GO
ALTER TABLE [dbo].[UnearnedRevenue]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenue_UserProfile] FOREIGN KEY([HandlerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenue] CHECK CONSTRAINT [FK_UnearnedRevenue_UserProfile]
GO
ALTER TABLE [dbo].[UnearnedRevenue]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenue_UserProfile1] FOREIGN KEY([PayerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenue] CHECK CONSTRAINT [FK_UnearnedRevenue_UserProfile1]
GO
ALTER TABLE [dbo].[UnearnedRevenueContractItemMap]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueContractItemMap_ContractItem] FOREIGN KEY([ContractItemId])
REFERENCES [dbo].[ContractItem] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenueContractItemMap] CHECK CONSTRAINT [FK_UnearnedRevenueContractItemMap_ContractItem]
GO
ALTER TABLE [dbo].[UnearnedRevenueContractItemMap]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueContractItemMap_UnearnedRevenue] FOREIGN KEY([UnearnedRevenueId])
REFERENCES [dbo].[UnearnedRevenue] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UnearnedRevenueContractItemMap] CHECK CONSTRAINT [FK_UnearnedRevenueContractItemMap_UnearnedRevenue]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealization_AccountingAbstracts] FOREIGN KEY([FinanceAccountingTypeId])
REFERENCES [dbo].[FinanceAccountingType] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization] CHECK CONSTRAINT [FK_UnearnedRevenueRealization_AccountingAbstracts]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealization_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization] CHECK CONSTRAINT [FK_UnearnedRevenueRealization_Enterprise]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealization_InvoiceAllowance] FOREIGN KEY([InvoiceAllowanceId])
REFERENCES [dbo].[InvoiceAllowance] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization] CHECK CONSTRAINT [FK_UnearnedRevenueRealization_InvoiceAllowance]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealization_InvoiceItem] FOREIGN KEY([InvoiceItemId])
REFERENCES [dbo].[InvoiceItem] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization] CHECK CONSTRAINT [FK_UnearnedRevenueRealization_InvoiceItem]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealization_UnearnedRevenue] FOREIGN KEY([UnearnedRevenueId])
REFERENCES [dbo].[UnearnedRevenue] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UnearnedRevenueRealization] CHECK CONSTRAINT [FK_UnearnedRevenueRealization_UnearnedRevenue]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealizationMap]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealizationMap_CalendarEvents] FOREIGN KEY([CalendarEventsId])
REFERENCES [dbo].[CalendarEvents] ([Id])
GO
ALTER TABLE [dbo].[UnearnedRevenueRealizationMap] CHECK CONSTRAINT [FK_UnearnedRevenueRealizationMap_CalendarEvents]
GO
ALTER TABLE [dbo].[UnearnedRevenueRealizationMap]  WITH CHECK ADD  CONSTRAINT [FK_UnearnedRevenueRealizationMap_UnearnedRevenueRealization] FOREIGN KEY([UnearnedRevenueRealizationId])
REFERENCES [dbo].[UnearnedRevenueRealization] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UnearnedRevenueRealizationMap] CHECK CONSTRAINT [FK_UnearnedRevenueRealizationMap_UnearnedRevenueRealization]
GO
ALTER TABLE [dbo].[UserAccountReceivable]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountReceivable_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[UserAccountReceivable] CHECK CONSTRAINT [FK_UserAccountReceivable_Enterprise]
GO
ALTER TABLE [dbo].[UserAccountReceivable]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountReceivable_OtherAccountingDiary] FOREIGN KEY([OtherAccountingDiaryId])
REFERENCES [dbo].[OtherAccountingDiary] ([Id])
GO
ALTER TABLE [dbo].[UserAccountReceivable] CHECK CONSTRAINT [FK_UserAccountReceivable_OtherAccountingDiary]
GO
ALTER TABLE [dbo].[UserAccountReceivable]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountReceivable_UnearnedRevenue] FOREIGN KEY([UnearnedRevenueId])
REFERENCES [dbo].[UnearnedRevenue] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserAccountReceivable] CHECK CONSTRAINT [FK_UserAccountReceivable_UnearnedRevenue]
GO
ALTER TABLE [dbo].[UserAccountReceivable]  WITH CHECK ADD  CONSTRAINT [FK_UserAccountReceivable_UserProfile] FOREIGN KEY([PayerUserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[UserAccountReceivable] CHECK CONSTRAINT [FK_UserAccountReceivable_UserProfile]
GO
ALTER TABLE [dbo].[UserActivity]  WITH CHECK ADD  CONSTRAINT [FK_UserActivity_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserActivity] CHECK CONSTRAINT [FK_UserActivity_UserProfile]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_AdministrativeDistrict1] FOREIGN KEY([AdministrativeDistrictId])
REFERENCES [dbo].[AdministrativeDistrict] ([Id])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_AdministrativeDistrict1]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_CoachLevel] FOREIGN KEY([CoachLevelId])
REFERENCES [dbo].[CoachLevel] ([Id])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_CoachLevel]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_CustomerLevel] FOREIGN KEY([CustomerLevelId])
REFERENCES [dbo].[CustomerLevel] ([Id])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_CustomerLevel]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_Enterprise]
GO
ALTER TABLE [dbo].[UserProfileNote]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileNote_Enterprise] FOREIGN KEY([EnterpriseId])
REFERENCES [dbo].[Enterprise] ([Id])
GO
ALTER TABLE [dbo].[UserProfileNote] CHECK CONSTRAINT [FK_UserProfileNote_Enterprise]
GO
ALTER TABLE [dbo].[UserProfileNote]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileNote_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserProfileNote] CHECK CONSTRAINT [FK_UserProfileNote_UserProfile]
GO
ALTER TABLE [dbo].[UserProfileOrganizationMap]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileOrganizationMap_Organization] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organization] ([Id])
GO
ALTER TABLE [dbo].[UserProfileOrganizationMap] CHECK CONSTRAINT [FK_UserProfileOrganizationMap_Organization]
GO
ALTER TABLE [dbo].[UserProfileOrganizationMap]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileOrganizationMap_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[UserProfileOrganizationMap] CHECK CONSTRAINT [FK_UserProfileOrganizationMap_UserProfile]
GO
ALTER TABLE [dbo].[UserProfileRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileRoleMap_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[UserProfileRoleMap] CHECK CONSTRAINT [FK_UserProfileRoleMap_Role]
GO
ALTER TABLE [dbo].[UserProfileRoleMap]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileRoleMap_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
GO
ALTER TABLE [dbo].[UserProfileRoleMap] CHECK CONSTRAINT [FK_UserProfileRoleMap_UserProfile]
GO
ALTER TABLE [dbo].[UserRegistryToken]  WITH CHECK ADD  CONSTRAINT [FK_UserRegistryToken_UserProfile] FOREIGN KEY([UserProfileId])
REFERENCES [dbo].[UserProfile] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserRegistryToken] CHECK CONSTRAINT [FK_UserRegistryToken_UserProfile]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'捐贈註記
以”0”表示 非捐贈發票
以”1”表示 為捐贈發票
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'DonateMark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'載具類別
1：悠遊卡
2：UXB2B條碼卡' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'CarrierType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'載具卡號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'CarrierNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'機構代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'DonationCode'
GO

-- Query: List RoleModulePage entries accessible to user with PID = 'admin'
USE [InsightFitPro_Sit];
GO

SET NOCOUNT ON;

SELECT DISTINCT rmp.Id,
       rmp.RoleModuleId,
       rmp.Name,
       rmp.PageName,
       rmp.PageRoute,
       rmp.DisplayOrder,
       rmp.CreateDate,
       up.PID AS UserPID
FROM dbo.RoleModulePage AS rmp
INNER JOIN dbo.RoleRoleModulePageMap AS rrmp ON rrmp.RoleModulePageId = rmp.Id
INNER JOIN dbo.UserProfileRoleMap     AS uprm ON uprm.RoleId = rrmp.RoleId
INNER JOIN dbo.UserProfile            AS up   ON up.Id = uprm.UserProfileId
WHERE up.PID = N'admin'
  AND rmp.IsValid = 1;
GO
