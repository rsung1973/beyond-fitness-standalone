USE [BeyondFitnessProd2]
GO
/****** Object:  Schema [BG]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE SCHEMA [BG]
GO
/****** Object:  Schema [KPI]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE SCHEMA [KPI]
GO
/****** Object:  Schema [Project]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE SCHEMA [Project]
GO
/****** Object:  Schema [Report]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE SCHEMA [Report]
GO
/****** Object:  Schema [tmp]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE SCHEMA [tmp]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetMinDate]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetMinDate]
(
    @date_A DATETIME,
    @date_B DATETIME
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @result DATETIME;

    -- 判斷哪個日期比較小
    IF (@date_A IS NULL AND @date_B IS NULL)
        SET @result = NULL;
    ELSE IF (@date_A IS NULL)
        SET @result = @date_B;
    ELSE IF (@date_B IS NULL)
        SET @result = @date_A;
    ELSE
        SET @result = CASE 
                        WHEN @date_A <= @date_B THEN @date_A
                        ELSE @date_B
                      END;

    RETURN @result;
END
GO
/****** Object:  Table [Report].[CoachMonthlySalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[CoachMonthlySalary](
	[CoachID] [int] NOT NULL,
	[SettlementID] [int] NOT NULL,
	[WorkPlace] [int] NULL,
	[LevelID] [int] NOT NULL,
	[GradeIndex] [decimal](18, 2) NOT NULL,
	[ManagerBonus] [int] NULL,
	[SpecialBonus] [int] NULL,
	[PerformanceAchievement] [int] NULL,
	[AchievementShareRatio] [decimal](18, 2) NULL,
	[VoidShare] [int] NULL,
	[PTAttendanceCount] [int] NULL,
	[PTAverageUnitPrice] [int] NULL,
	[AttendanceBonus] [int] NULL,
	[AchievementBonus] [int] NULL,
	[Year] [int] NULL,
	[AvgFlag] [bit] NULL,
	[AttendedByOther] [int] NULL,
	[AttendedByOtherAvgPrice] [int] NULL,
	[AttendedShare] [int] NULL,
	[EmploymentDurationGradeIndex] [int] NULL,
	[TSAttendanceCount] [int] NULL,
	[ManagementBonusGrade] [decimal](6, 4) NULL,
	[JobTenureInDays] [int] NULL,
	[BasicWage] [int] NULL,
	[StaffWelfareFund] [int] NULL,
	[TSBonus] [int] NULL,
	[PIAttendanceCount] [int] NULL,
	[PIBonus] [int] NULL,
	[GroupXAttendanceCount] [int] NULL,
	[GroupXBonus] [int] NULL,
 CONSTRAINT [PK_CoachMonthlySalary_1] PRIMARY KEY CLUSTERED 
(
	[CoachID] ASC,
	[SettlementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[CoachBranchMonthlyBonus]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[CoachBranchMonthlyBonus](
	[CoachID] [int] NOT NULL,
	[SettlementID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[Tuition] [int] NULL,
	[AttendanceBonus] [int] NULL,
	[AchievementAttendanceCount] [decimal](18, 2) NULL,
	[BranchTotalAttendanceCount] [int] NULL,
	[BranchTotalTuition] [int] NULL,
	[VoidShare] [int] NULL,
	[BranchTotalPTCount] [int] NULL,
	[BranchTotalPTTuition] [int] NULL,
 CONSTRAINT [PK_CoachBranchMonthlyBonus] PRIMARY KEY CLUSTERED 
(
	[CoachID] ASC,
	[SettlementID] ASC,
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[YearlySettlement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[YearlySettlement](
	[Year] [int] NOT NULL,
 CONSTRAINT [PK_YearlySettlement] PRIMARY KEY CLUSTERED 
(
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_YearlyReview]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_YearlyReview]
AS
SELECT  Year
       ,CoachID
       ,COUNT(SettlementID)                                           AS DataCount
       ,SUM(PerformanceAchievement)                                   AS PerformanceAchievement
       ,cast(AVG(case AvgFlag when 1 then cast(PerformanceAchievement AS decimal) else null end )+0.5 AS int) AS PerformanceAchievementAVG
       ,AVG(AchievementShareRatio)                                    AS AchievementShareRatio
       ,SUM(VoidShare)                                                AS VoidShare
       ,AVG(VoidShare)                                                AS VoidShareAVG
       ,SUM(PTAttendanceCount)                                        AS PTAttendanceCount
       ,cast(AVG(cast(PTAttendanceCount AS decimal))+0.5 AS int)      AS PTAttendanceCountAVG
       ,AVG(case AvgFlag when 1 then PTAverageUnitPrice else null end)                                       AS PTAverageUnitPrice
       ,SUM(Tuition)                                                  AS Tuition
       ,SUM(AchievementAttendanceCount)                               AS AchievementAttendanceCount
       ,SUM(BranchTotalAttendanceCount)                               AS BranchTotalAttendanceCount
       ,SUM(BranchTotalTuition)                                       AS BranchTotalTuition
       ,SUM(BranchTotalPTCount)                                       AS BranchTotalPTCount
       ,SUM(BranchTotalPTTuition)                                     AS BranchTotalPTTuition
	   ,SUM(AttendedShare)											  AS AttendedShare
FROM
(
	SELECT  t.Year
	       ,t.CoachID
	       ,t.SettlementID
	       ,t.PerformanceAchievement
	       ,t.AchievementShareRatio
	       ,t.VoidShare
	       ,t.PTAttendanceCount
	       ,t.PTAverageUnitPrice
	       ,t.Tuition
	       ,t.AchievementAttendanceCount
	       ,t.BranchTotalAttendanceCount
	       ,t.BranchTotalTuition
	       ,t.BranchTotalPTCount
	       ,t.BranchTotalPTTuition
	       ,t.AvgFlag
		   ,t.AttendedShare
	FROM
	(
		SELECT  Report.CoachMonthlySalary.CoachID
		       ,Report.CoachMonthlySalary.SettlementID
		       ,Report.CoachMonthlySalary.PerformanceAchievement
		       ,Report.CoachMonthlySalary.AchievementShareRatio
		       ,Report.CoachMonthlySalary.VoidShare
		       ,Report.CoachMonthlySalary.PTAttendanceCount
		       ,Report.CoachMonthlySalary.PTAverageUnitPrice
		       ,s.Tuition
		       ,s.AchievementAttendanceCount
		       ,s.BranchTotalAttendanceCount
		       ,s.BranchTotalTuition
		       ,s.BranchTotalPTCount
		       ,s.BranchTotalPTTuition
		       ,Report.CoachMonthlySalary.Year
		       ,Report.CoachMonthlySalary.AvgFlag
			   ,Report.CoachMonthlySalary.AttendedShare
		FROM Report.CoachMonthlySalary
		LEFT OUTER JOIN
		(
			SELECT  CoachID
			       ,SettlementID
			       ,SUM(Tuition)                    AS Tuition
			       ,SUM(AchievementAttendanceCount) AS AchievementAttendanceCount
			       ,SUM(BranchTotalAttendanceCount) AS BranchTotalAttendanceCount
			       ,SUM(BranchTotalTuition)         AS BranchTotalTuition
			       ,SUM(BranchTotalPTCount)         AS BranchTotalPTCount
			       ,SUM(BranchTotalPTTuition)       AS BranchTotalPTTuition
			FROM Report.CoachBranchMonthlyBonus
			GROUP BY  CoachID
			         ,SettlementID
		) AS s
		ON s.CoachID = Report.CoachMonthlySalary.CoachID AND s.SettlementID = Report.CoachMonthlySalary.SettlementID
	) AS t
	INNER JOIN YearlySettlement
	ON t.Year = YearlySettlement.Year
) AS v
GROUP BY  Year
         ,CoachID
GO
/****** Object:  Table [dbo].[Settlement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Settlement](
	[SettlementID] [int] IDENTITY(1,1) NOT NULL,
	[SettlementDate] [datetime] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndExclusiveDate] [datetime] NOT NULL,
	[Status] [int] NULL,
	[Year] [int] NULL,
 CONSTRAINT [PK_Settlement] PRIMARY KEY CLUSTERED 
(
	[SettlementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[BranchMonthlySummary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[BranchMonthlySummary](
	[SettlementID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[AchievementRatio] [decimal](18, 2) NOT NULL,
 CONSTRAINT [PK_BranchMonthlySummary] PRIMARY KEY CLUSTERED 
(
	[SettlementID] ASC,
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_BranchYearlySummary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_BranchYearlySummary]
AS
SELECT   dbo.Settlement.Year, Report.BranchMonthlySummary.BranchID, COUNT(Report.BranchMonthlySummary.SettlementID) AS DataCount, AVG(Report.BranchMonthlySummary.AchievementRatio) AS AchievementRatio
FROM     Report.BranchMonthlySummary INNER JOIN
             dbo.Settlement ON Report.BranchMonthlySummary.SettlementID = dbo.Settlement.SettlementID INNER JOIN
             dbo.YearlySettlement ON dbo.Settlement.Year = dbo.YearlySettlement.Year AND dbo.Settlement.Year = dbo.YearlySettlement.Year
GROUP BY dbo.Settlement.Year, Report.BranchMonthlySummary.BranchID
GO
/****** Object:  Table [dbo].[CourseContract]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContract](
	[ContractID] [int] IDENTITY(1,1) NOT NULL,
	[ContractType] [int] NOT NULL,
	[ContractDate] [datetime] NULL,
	[Subject] [nvarchar](8) NULL,
	[ValidFrom] [datetime] NULL,
	[Expiration] [datetime] NULL,
	[OwnerID] [int] NOT NULL,
	[SequenceNo] [int] NULL,
	[Lessons] [int] NULL,
	[PriceID] [int] NOT NULL,
	[Remark] [nvarchar](256) NULL,
	[FitnessConsultant] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[AgentID] [int] NOT NULL,
	[ContractNo] [nvarchar](64) NULL,
	[TotalCost] [int] NULL,
	[EffectiveDate] [datetime] NULL,
	[Installment] [bit] NULL,
	[Renewal] [bit] NULL,
	[InstallmentID] [int] NULL,
	[PayoffDue] [datetime] NULL,
	[ValidTo] [datetime] NULL,
	[Entrusted] [bit] NULL,
	[SupervisorID] [int] NULL,
 CONSTRAINT [PK_CourseContract] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractMember]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractMember](
	[ContractID] [int] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_CourseContractMember] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_ContractLearnerStatus]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_ContractLearnerStatus]
AS
SELECT   dbo.CourseContractMember.UID, MAX(dbo.CourseContract.Expiration) AS NotAfter
FROM     dbo.CourseContract INNER JOIN
             dbo.CourseContractMember ON dbo.CourseContract.ContractID = dbo.CourseContractMember.ContractID
GROUP BY dbo.CourseContractMember.UID
GO
/****** Object:  Table [dbo].[LearnerCoachProperty]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearnerCoachProperty](
	[UID] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_LearnerCoachProperty] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[CoachID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BranchStore]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BranchStore](
	[BranchID] [int] NOT NULL,
	[BranchName] [nvarchar](32) NULL,
	[ManagerID] [int] NULL,
	[ViceManagerID] [int] NULL,
	[Status] [int] NULL,
	[EPOS_SID] [nvarchar](64) NULL,
	[EPOS_MID] [nvarchar](64) NULL,
	[EPOS_TID] [nvarchar](64) NULL,
 CONSTRAINT [PK_BranchStore] PRIMARY KEY CLUSTERED 
(
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GroupingLessonDiscount]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupingLessonDiscount](
	[GroupingMemberCount] [int] NOT NULL,
	[PercentageOfDiscount] [int] NULL,
 CONSTRAINT [PK_GroupingLessonDiscount] PRIMARY KEY CLUSTERED 
(
	[GroupingMemberCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonPlan]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPlan](
	[LessonID] [int] NOT NULL,
	[Remark] [nvarchar](max) NULL,
	[Warming] [nvarchar](max) NULL,
	[RecentStatus] [nvarchar](max) NULL,
	[EndingOperation] [nvarchar](max) NULL,
	[FeedBack] [nvarchar](max) NULL,
	[FeedBackDate] [datetime] NULL,
	[CommitAttendance] [datetime] NULL,
	[AttachmentID] [int] NULL,
	[CommitAttendanceIP] [nvarchar](32) NULL,
	[Signature] [nvarchar](max) NULL,
 CONSTRAINT [PK_LessonPlan] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonAttendance]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonAttendance](
	[LessonID] [int] NOT NULL,
	[CompleteDate] [datetime] NOT NULL,
	[ActorID] [int] NULL,
 CONSTRAINT [PK_LessonAttendance] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseCourseContent]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseCourseContent](
	[ContractID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
	[Lessons] [int] NULL,
	[ListPrice] [int] NULL,
	[DurationInMinutes] [int] NULL,
	[CoachPayoff] [int] NULL,
 CONSTRAINT [PK_EnterpriseCourseContent] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterLessonEnterprise]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterLessonEnterprise](
	[RegisterID] [int] NOT NULL,
	[ContractID] [int] NULL,
	[TypeID] [int] NULL,
 CONSTRAINT [PK_RegisterLessonEnterprise] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonPriceType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPriceType](
	[PriceID] [int] NOT NULL,
	[Description] [nvarchar](64) NULL,
	[ListPrice] [int] NULL,
	[Status] [int] NULL,
	[UsageType] [int] NULL,
	[CoachPayoff] [int] NULL,
	[CoachPayoffCreditCard] [int] NULL,
	[ExcludeQuestionnaire] [int] NULL,
	[LowerLimit] [int] NULL,
	[UpperBound] [int] NULL,
	[BranchID] [int] NULL,
	[DiscountedPrice] [int] NULL,
	[DurationInMinutes] [int] NULL,
	[SeriesID] [int] NULL,
	[BundleCount] [int] NULL,
	[EffectiveMonths] [int] NULL,
 CONSTRAINT [PK_LessonPriceType] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseLessonType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseLessonType](
	[TypeID] [int] NOT NULL,
	[Status] [int] NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_EnterpriseLessonType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterLesson](
	[RegisterID] [int] IDENTITY(1,1) NOT NULL,
	[RegisterDate] [datetime] NOT NULL,
	[Lessons] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[ClassLevel] [int] NULL,
	[Attended] [int] NULL,
	[RegisterGroupID] [int] NULL,
	[GroupingMemberCount] [int] NOT NULL,
	[AdvisorID] [int] NULL,
	[AttendedLessons] [int] NULL,
	[BranchID] [int] NULL,
	[MasterRegistration] [bit] NULL,
	[Expiration] [datetime] NULL,
 CONSTRAINT [PK_RegisterLesson] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonTime]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonTime](
	[LessonID] [int] IDENTITY(1,1) NOT NULL,
	[RegisterID] [int] NOT NULL,
	[ClassTime] [datetime] NULL,
	[DurationInMinutes] [int] NULL,
	[InvitedCoach] [int] NULL,
	[AttendingCoach] [int] NULL,
	[GroupID] [int] NULL,
	[TrainingBySelf] [int] NULL,
	[BranchID] [int] NULL,
	[HourOfClassTime] [int] NULL,
	[Place] [nvarchar](512) NULL,
 CONSTRAINT [PK_LessonTime] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_LessonTime]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_LessonTime]
AS
SELECT        LessonTime.LessonID, LessonTime.ClassTime, LessonTime.AttendingCoach, LessonTime.GroupID, LessonTime.BranchID, LessonAttendance.LessonID AS CoachAttendance, LessonAttendance.CompleteDate, 
                         LessonPlan.CommitAttendance, LessonPriceType.PriceID, LessonPriceType.Status AS PriceStatus, EnterpriseLessonType.Status AS ELStatus, RegisterLesson.RegisterID, RegisterLesson.GroupingMemberCount, 
                         LessonPriceType.ListPrice, RegisterLessonEnterprise.RegisterID AS EnterpriseRegisterID, EnterpriseCourseContent.ListPrice AS EnterpriseListPrice, RegisterLessonEnterprise.ContractID AS EnterpriseContractID, 
                         LessonPriceType.CoachPayoff, EnterpriseCourseContent.CoachPayoff AS EnterpriseCoachPayoff, RegisterLesson.UID
FROM            EnterpriseCourseContent INNER JOIN
                         RegisterLessonEnterprise ON EnterpriseCourseContent.ContractID = RegisterLessonEnterprise.ContractID AND EnterpriseCourseContent.TypeID = RegisterLessonEnterprise.TypeID INNER JOIN
                         EnterpriseLessonType ON EnterpriseCourseContent.TypeID = EnterpriseLessonType.TypeID RIGHT OUTER JOIN
                         LessonTime INNER JOIN
                         LessonPlan ON LessonTime.LessonID = LessonPlan.LessonID INNER JOIN
                         RegisterLesson ON LessonTime.RegisterID = RegisterLesson.RegisterID INNER JOIN
                         LessonPriceType ON RegisterLesson.ClassLevel = LessonPriceType.PriceID ON RegisterLessonEnterprise.RegisterID = RegisterLesson.RegisterID LEFT OUTER JOIN
                         LessonAttendance ON LessonTime.LessonID = LessonAttendance.LessonID


GO
/****** Object:  Table [dbo].[ServingCoach]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServingCoach](
	[CoachID] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[LevelID] [int] NULL,
	[EmploymentDate] [date] NULL,
	[LeavedDate] [date] NULL,
 CONSTRAINT [PK_ServingCoach] PRIMARY KEY CLUSTERED 
(
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoachWorkplace]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoachWorkplace](
	[CoachID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
 CONSTRAINT [PK_CoachWorkplace] PRIMARY KEY CLUSTERED 
(
	[CoachID] ASC,
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_WorkPlace]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_WorkPlace]
AS
SELECT        ServingCoach.CoachID, s.WorkPlace, ISNULL(BranchStore.BranchName, '其他') AS OfficeLocation
FROM            ServingCoach LEFT OUTER JOIN
                         BranchStore INNER JOIN
                             (SELECT        CoachID, MIN(BranchID) AS WorkPlace
                               FROM            CoachWorkplace AS c
                               GROUP BY CoachID
                               HAVING         (COUNT(*) = 1)) AS s ON BranchStore.BranchID = s.WorkPlace ON ServingCoach.CoachID = s.CoachID

GO
/****** Object:  Table [dbo].[RegisterLessonContract]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterLessonContract](
	[RegisterID] [int] NOT NULL,
	[ContractID] [int] NOT NULL,
	[ForShared] [bit] NULL,
	[Title] [nvarchar](64) NULL,
 CONSTRAINT [PK_RegisterLessonContract] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonTimeSettlement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonTimeSettlement](
	[LessonID] [int] NOT NULL,
	[ProfessionalLevelID] [int] NOT NULL,
	[MarkedGradeIndex] [decimal](18, 2) NULL,
	[SettlementStatus] [int] NULL,
	[CoachWorkPlace] [int] NULL,
	[SettlementID] [int] NULL,
 CONSTRAINT [PK_LessonTimeSettlement] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_Tuition]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[V_Tuition]
as
SELECT  V_LessonTime.LessonID, V_LessonTime.ClassTime, V_LessonTime.AttendingCoach, V_LessonTime.GroupID, V_LessonTime.BranchID, 
               V_LessonTime.CoachAttendance, V_LessonTime.CompleteDate, V_LessonTime.CommitAttendance, V_LessonTime.PriceID, V_LessonTime.PriceStatus, 
               V_LessonTime.ELStatus, 
			   CASE 
					WHEN PriceStatus = 103 OR ELStatus = 103 
						THEN 0.5 
					WHEN PriceStatus = 1006 OR ELStatus = 1006
						THEN (CASE 
							WHEN CoachAttendance IS NOT NULL 
								THEN 1
							ELSE 0
						END) 
					ELSE (CASE 
							WHEN CoachAttendance IS NOT NULL 
								THEN (CASE 
										WHEN CommitAttendance IS NOT NULL 
											THEN 1 
										ELSE 0.5 
									END) 
							WHEN CoachAttendance IS NULL 
								THEN (CASE 
										WHEN CommitAttendance IS NOT NULL 
											THEN 0.5 
										ELSE 0 
									END) 
						END) 
				END AS AchievementIndex, 
               CASE 
					WHEN PriceStatus = 103 OR ELStatus = 103 
						THEN 0 
					WHEN PriceStatus = 1006 OR ELStatus = 1006
						THEN (CASE 
							WHEN CoachAttendance IS NOT NULL 
								THEN 1
							ELSE 0
						END)
					ELSE (CASE 
							WHEN CoachAttendance IS NOT NULL 
								THEN (CASE 
										WHEN CommitAttendance IS NOT NULL 
											THEN 1 
										ELSE 0.5 
									END) 
							WHEN CoachAttendance IS NULL 
								THEN (CASE 
										WHEN CommitAttendance IS NOT NULL 
											THEN 0.5 
										ELSE 0 
									END) 
						END) 
				END AS TuitionIndex, 
               V_LessonTime.RegisterID, V_LessonTime.GroupingMemberCount, V_LessonTime.ListPrice, GroupingLessonDiscount.PercentageOfDiscount, 
               LessonTimeSettlement.ProfessionalLevelID, LessonTimeSettlement.MarkedGradeIndex, BranchStore.BranchName, V_WorkPlace.OfficeLocation, 
               V_LessonTime.EnterpriseRegisterID, V_LessonTime.EnterpriseListPrice, V_WorkPlace.WorkPlace, V_LessonTime.EnterpriseContractID, 
               RegisterLessonContract.ContractID, LessonTimeSettlement.SettlementStatus, LessonTimeSettlement.CoachWorkPlace, LessonTimeSettlement.SettlementID,V_LessonTime.CoachPayoff,V_LessonTime.EnterpriseCoachPayoff,V_LessonTime.UID
FROM     V_LessonTime INNER JOIN
               GroupingLessonDiscount ON V_LessonTime.GroupingMemberCount = GroupingLessonDiscount.GroupingMemberCount INNER JOIN
               LessonTimeSettlement ON V_LessonTime.LessonID = LessonTimeSettlement.LessonID INNER JOIN
               BranchStore ON V_LessonTime.BranchID = BranchStore.BranchID INNER JOIN
               V_WorkPlace ON V_LessonTime.AttendingCoach = V_WorkPlace.CoachID LEFT OUTER JOIN
               RegisterLessonContract ON V_LessonTime.RegisterID = RegisterLessonContract.RegisterID
WHERE   (V_LessonTime.PriceStatus IN (0, 1, 103, 1003, 1006, 1007, 1010, 1012, 1013, 1014, 1015))

GO
/****** Object:  View [dbo].[V_TuitionCoach]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_TuitionCoach]
AS
SELECT  V_Tuition.LessonID, V_Tuition.ClassTime, V_Tuition.AttendingCoach, V_Tuition.GroupID, V_Tuition.BranchID, V_Tuition.CoachAttendance, 
               V_Tuition.CompleteDate, V_Tuition.CommitAttendance, V_Tuition.PriceID, V_Tuition.PriceStatus, V_Tuition.ELStatus, V_Tuition.AchievementIndex, 
               V_Tuition.TuitionIndex, V_Tuition.RegisterID, V_Tuition.GroupingMemberCount, V_Tuition.ListPrice, V_Tuition.PercentageOfDiscount, 
               V_Tuition.ProfessionalLevelID, V_Tuition.MarkedGradeIndex, V_Tuition.BranchName, V_Tuition.OfficeLocation, V_Tuition.EnterpriseRegisterID, 
               V_Tuition.EnterpriseListPrice, V_Tuition.WorkPlace, V_Tuition.EnterpriseContractID, V_Tuition.ContractID, V_Tuition.SettlementStatus, 
               V_Tuition.CoachWorkPlace, V_Tuition.SettlementID, V_Tuition.CoachPayoff, V_Tuition.EnterpriseCoachPayoff, V_Tuition.UID, 
               LearnerCoachProperty.CoachID AS PrimaryCoach, LearnerCoachProperty.PropertyID
FROM     V_Tuition LEFT OUTER JOIN
               LearnerCoachProperty ON V_Tuition.UID = LearnerCoachProperty.UID
GO
/****** Object:  Table [dbo].[Payment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payment](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[PayoffAmount] [int] NULL,
	[PayoffDate] [datetime] NULL,
	[Status] [int] NULL,
	[HandlerID] [int] NULL,
	[PaymentType] [nvarchar](32) NULL,
	[InvoiceID] [int] NULL,
	[TransactionType] [int] NULL,
	[Remark] [nvarchar](256) NULL,
	[AllowanceID] [int] NULL,
	[AdjustmentAmount] [int] NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VoidPayment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VoidPayment](
	[VoidID] [int] NOT NULL,
	[Status] [int] NULL,
	[VoidDate] [datetime] NULL,
	[HandlerID] [int] NULL,
	[Remark] [nvarchar](256) NULL,
	[Drawback] [bit] NULL,
 CONSTRAINT [PK_VoidPayment] PRIMARY KEY CLUSTERED 
(
	[VoidID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TuitionAchievement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TuitionAchievement](
	[InstallmentID] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
	[ShareAmount] [int] NULL,
	[CommitShare] [datetime] NULL,
	[CoachWorkPlace] [int] NULL,
	[VoidShare] [int] NULL,
 CONSTRAINT [PK_TuitionAchievement] PRIMARY KEY CLUSTERED 
(
	[InstallmentID] ASC,
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_PerformanceShare]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[V_PerformanceShare]
as 
SELECT  s.PaymentID, s.PayoffAmount, s.PayoffDate, TuitionAchievement.CoachID, TuitionAchievement.ShareAmount
FROM     (SELECT  PaymentID, PayoffAmount, PayoffDate
               FROM      Payment
               WHERE   (PaymentID NOT IN
                                   (SELECT  VoidID
                                   FROM     VoidPayment))) AS s INNER JOIN
               TuitionAchievement ON s.PaymentID = TuitionAchievement.InstallmentID
GO
/****** Object:  View [dbo].[V_ContractTuition]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[V_ContractTuition]
as
SELECT  V_Tuition.LessonID, V_Tuition.ClassTime, V_Tuition.AttendingCoach, V_Tuition.GroupID, V_Tuition.BranchID, V_Tuition.CoachAttendance, 
               V_Tuition.CompleteDate, V_Tuition.CommitAttendance, V_Tuition.PriceID, V_Tuition.PriceStatus, V_Tuition.ELStatus, V_Tuition.AchievementIndex, 
               V_Tuition.TuitionIndex, V_Tuition.RegisterID, V_Tuition.GroupingMemberCount, V_Tuition.ListPrice, V_Tuition.PercentageOfDiscount, 
               V_Tuition.ProfessionalLevelID, V_Tuition.MarkedGradeIndex, V_Tuition.BranchName, V_Tuition.OfficeLocation, V_Tuition.EnterpriseRegisterID, 
               V_Tuition.EnterpriseListPrice, V_Tuition.WorkPlace, RegisterLessonContract.ContractID
FROM     V_Tuition INNER JOIN
               RegisterLessonContract ON V_Tuition.RegisterID = RegisterLessonContract.RegisterID



GO
/****** Object:  Table [dbo].[UserProfileExtension]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileExtension](
	[UID] [int] NOT NULL,
	[Gender] [nvarchar](8) NULL,
	[AthleticLevel] [int] NULL,
	[CurrentTrial] [int] NULL,
	[EmergencyContactPhone] [nvarchar](32) NULL,
	[EmergencyContactPerson] [nvarchar](16) NULL,
	[Relationship] [nvarchar](16) NULL,
	[IDNo] [nvarchar](16) NULL,
	[AdministrativeArea] [nvarchar](16) NULL,
	[Signature] [nvarchar](max) NULL,
	[RegisterStatus] [bit] NULL,
	[LineID] [nvarchar](64) NULL,
	[VipStatus] [int] NULL,
	[GeoCode] [nvarchar](max) NULL,
	[CarrierType] [nvarchar](16) NULL,
	[CarrierNo] [nvarchar](64) NULL,
	[PIN] [nvarchar](64) NULL,
	[PINExpiration] [datetime] NULL,
	[AttendanceSignature] [bit] NULL,
	[CountryCode] [nvarchar](8) NULL,
 CONSTRAINT [PK_UserProfileExtension] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfile]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfile](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](40) NULL,
	[PID] [nvarchar](256) NOT NULL,
	[Password] [nvarchar](64) NULL,
	[ExternalID] [nvarchar](64) NULL,
	[Expiration] [datetime] NULL,
	[Creator] [int] NULL,
	[AuthID] [int] NULL,
	[LevelID] [int] NULL,
	[ThemeName] [nvarchar](16) NULL,
	[Password2] [nvarchar](64) NULL,
	[MemberCode] [nvarchar](16) NULL,
	[PictureID] [int] NULL,
	[RealName] [nvarchar](40) NULL,
	[Address] [nvarchar](128) NULL,
	[Phone] [nvarchar](32) NULL,
	[RecentStatus] [nvarchar](max) NULL,
	[Birthday] [date] NULL,
	[Nickname] [nvarchar](40) NULL,
	[BirthdateIndex] [int] NULL,
	[CreateTime] [datetime] NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UserProfile] UNIQUE NONCLUSTERED 
(
	[PID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitnessAssessmentItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitnessAssessmentItem](
	[ItemID] [int] NOT NULL,
	[ItemName] [nvarchar](64) NOT NULL,
	[Unit] [nvarchar](8) NOT NULL,
	[GroupID] [int] NULL,
	[UseSingleSide] [bit] NULL,
	[UseCustom] [bit] NULL,
 CONSTRAINT [PK_FitnessAssessmentItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearnerFitnessAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearnerFitnessAssessment](
	[AssessmentID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[AssessmentDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LearnerFitnessAssessment] PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearnerFitnessAssessmentResult]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearnerFitnessAssessmentResult](
	[AssessmentID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[Assessment] [decimal](12, 2) NOT NULL,
 CONSTRAINT [PK_LearnerFitnessAssessmentResult] PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_LearnerFitenessAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[V_LearnerFitenessAssessment]
AS
SELECT  dbo.UserProfile.UID, dbo.UserProfileExtension.Gender, dbo.UserProfileExtension.AthleticLevel, dbo.UserProfile.Birthday, 
               dbo.LearnerFitnessAssessment.AssessmentDate, dbo.FitnessAssessmentItem.ItemID, dbo.FitnessAssessmentItem.ItemName, 
               dbo.FitnessAssessmentItem.Unit, dbo.LearnerFitnessAssessmentResult.Assessment, YEAR(dbo.LearnerFitnessAssessment.AssessmentDate) 
               - YEAR(dbo.UserProfile.Birthday) AS Years
FROM     dbo.UserProfile INNER JOIN
               dbo.UserProfileExtension ON dbo.UserProfile.UID = dbo.UserProfileExtension.UID INNER JOIN
               dbo.LearnerFitnessAssessment ON dbo.UserProfile.UID = dbo.LearnerFitnessAssessment.UID INNER JOIN
               dbo.LearnerFitnessAssessmentResult ON 
               dbo.LearnerFitnessAssessment.AssessmentID = dbo.LearnerFitnessAssessmentResult.AssessmentID INNER JOIN
               dbo.FitnessAssessmentItem ON dbo.LearnerFitnessAssessmentResult.ItemID = dbo.FitnessAssessmentItem.ItemID

GO
/****** Object:  Table [dbo].[LessonPriceSeries]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPriceSeries](
	[PriceID] [int] NOT NULL,
	[Year] [int] NULL,
	[PeriodNo] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_LessonPriceSeries] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonPriceProperty]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPriceProperty](
	[PriceID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_LessonPriceProperty] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_LessonUnitPrice]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create VIEW [dbo].[V_LessonUnitPrice]
AS
SELECT        dbo.LessonPriceSeries.Year, dbo.LessonPriceSeries.PeriodNo, dbo.LessonPriceType.PriceID, dbo.LessonPriceType.Description, dbo.LessonPriceType.ListPrice, dbo.LessonPriceType.Status, dbo.LessonPriceType.UsageType,
                          dbo.LessonPriceType.CoachPayoff, dbo.LessonPriceType.CoachPayoffCreditCard, dbo.LessonPriceType.ExcludeQuestionnaire, dbo.LessonPriceType.LowerLimit, dbo.LessonPriceType.UpperBound, 
                         dbo.LessonPriceType.BranchID, dbo.LessonPriceType.DiscountedPrice, dbo.LessonPriceType.DurationInMinutes, dbo.LessonPriceType.SeriesID
FROM            dbo.LessonPriceSeries INNER JOIN
                         dbo.LessonPriceType ON dbo.LessonPriceSeries.PriceID = dbo.LessonPriceType.SeriesID
WHERE        (dbo.LessonPriceSeries.Status = 1) AND (dbo.LessonPriceType.LowerLimit = 1) AND (NOT EXISTS
                             (SELECT        NULL 
                               FROM            dbo.LessonPriceProperty
                               WHERE        (PriceID = dbo.LessonPriceType.PriceID) AND (PropertyID = 1008)))


GO
/****** Object:  Table [dbo].[UserRoleAuthorization]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoleAuthorization](
	[UID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
 CONSTRAINT [PK_UserRoleAuthorization] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[V_BranchStaff]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create VIEW [dbo].[V_BranchStaff]
AS
SELECT        dbo.UserProfile.UID, dbo.CoachWorkplace.BranchID
FROM            (SELECT        CoachID
                          FROM            dbo.CoachWorkplace AS P
                          GROUP BY CoachID
                          HAVING         (COUNT(*) = 1)) AS w INNER JOIN
                         dbo.CoachWorkplace ON w.CoachID = dbo.CoachWorkplace.CoachID RIGHT OUTER JOIN
                         dbo.UserProfile ON w.CoachID = dbo.UserProfile.UID
WHERE        EXISTS
                             (SELECT        NULL AS Expr1
                               FROM            dbo.UserRoleAuthorization
                               WHERE        (dbo.UserProfile.UID = UID) AND (RoleID IN (1, 2, 6, 7, 8, 9, 10, 12)))
GO
/****** Object:  Table [BG].[AwardingItemCategory]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[AwardingItemCategory](
	[ItemID] [int] NOT NULL,
	[TransactionID] [int] NOT NULL,
 CONSTRAINT [PK_AwardingItemCategory] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC,
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[AwardingLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[AwardingLesson](
	[AwardID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
 CONSTRAINT [PK_AwardingLesson] PRIMARY KEY CLUSTERED 
(
	[AwardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[AwardingLessonGift]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[AwardingLessonGift](
	[AwardID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
 CONSTRAINT [PK_AwardingLessonGift] PRIMARY KEY CLUSTERED 
(
	[AwardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusAwardingIndication]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusAwardingIndication](
	[ItemID] [int] NOT NULL,
	[Indication] [nvarchar](32) NULL,
 CONSTRAINT [PK_BonusAwardingIndication] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusAwardingItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusAwardingItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [nvarchar](64) NOT NULL,
	[SampleUrl] [nvarchar](256) NULL,
	[PointValue] [int] NOT NULL,
	[Price] [int] NULL,
	[ExchangeableOnline] [bit] NULL,
	[OrderIndex] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_BonusAwardingItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusAwardingItemProperty]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusAwardingItemProperty](
	[ItemID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[WeightIndex] [int] NULL,
 CONSTRAINT [PK_BonusAwardingItemProperty] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusAwardingLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusAwardingLesson](
	[ItemID] [int] NOT NULL,
	[PriceID] [int] NOT NULL,
 CONSTRAINT [PK_BonusAwardingLesson] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusDepositAccount]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusDepositAccount](
	[UID] [int] NOT NULL,
	[DepositPoint] [int] NOT NULL,
 CONSTRAINT [PK_BonusDepositAccount] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusDepositSettlement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusDepositSettlement](
	[UID] [int] NOT NULL,
	[TransactionID] [int] NOT NULL,
	[SettlementDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BonusDepositSettlement] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusExchange]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusExchange](
	[AwardID] [int] NOT NULL,
	[TaskID] [int] NOT NULL,
 CONSTRAINT [PK_BonusExchange] PRIMARY KEY CLUSTERED 
(
	[AwardID] ASC,
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusTransaction]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusTransaction](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[TransactionDate] [datetime] NOT NULL,
	[TransactionPoint] [int] NOT NULL,
	[AwardID] [int] NULL,
	[Reason] [nvarchar](256) NULL,
	[BonusID] [int] NULL,
	[BalanceID] [int] NULL,
	[ExpirationDate] [datetime] NULL,
 CONSTRAINT [PK_BonusTransaction] PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusYearlyBalance]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusYearlyBalance](
	[BalanceID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[Year] [int] NOT NULL,
 CONSTRAINT [PK_BonusYearlyBalance] PRIMARY KEY CLUSTERED 
(
	[BalanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[BonusYearlySettlement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[BonusYearlySettlement](
	[UID] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[YearlyExpiringTotalGains] [int] NOT NULL,
	[YearlyTotalConsumption] [int] NOT NULL,
	[LastYearConsumptionDiscount] [int] NOT NULL,
 CONSTRAINT [PK_BonusYearlySettlement] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[CampaignMission]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[CampaignMission](
	[MissionID] [int] NOT NULL,
	[Mission] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_CampaignMission] PRIMARY KEY CLUSTERED 
(
	[MissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[CampaignMissionBonus]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[CampaignMissionBonus](
	[BonusID] [int] IDENTITY(1,1) NOT NULL,
	[CompleteDate] [datetime] NOT NULL,
 CONSTRAINT [PK_CampaignMissionBonus] PRIMARY KEY CLUSTERED 
(
	[BonusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[ExerciseTips]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[ExerciseTips](
	[TipsID] [int] NOT NULL,
	[Tips] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ExerciseTips] PRIMARY KEY CLUSTERED 
(
	[TipsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [BG].[FeedbackSurvey]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[FeedbackSurvey](
	[QuestionID] [int] NOT NULL,
	[Question] [nvarchar](1024) NOT NULL,
	[QuestionType] [int] NULL,
	[RequiredLevel] [int] NULL,
 CONSTRAINT [PK_FeedbackSurvey] PRIMARY KEY CLUSTERED 
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[FeedbackSurveyType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[FeedbackSurveyType](
	[QuestionID] [int] NOT NULL,
	[ClassType] [int] NOT NULL,
	[QuestionNo] [nvarchar](16) NULL,
 CONSTRAINT [PK_FeedbackSurveyType] PRIMARY KEY CLUSTERED 
(
	[QuestionID] ASC,
	[ClassType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[GameLevel]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[GameLevel](
	[LevelID] [int] NOT NULL,
	[LevelCode] [int] NOT NULL,
	[DisplayName] [nvarchar](64) NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_GameLevel] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[GameLevelRequirement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[GameLevelRequirement](
	[LevelID] [int] NOT NULL,
	[MissionID] [int] NOT NULL,
	[Threshold] [int] NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [PK_GameLevelRequirement] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC,
	[MissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[GameLevelReward]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[GameLevelReward](
	[LevelID] [int] NOT NULL,
	[RewardID] [int] NOT NULL,
	[Reward] [int] NOT NULL,
 CONSTRAINT [PK_GameLevelReward] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC,
	[RewardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[LearnerAward]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[LearnerAward](
	[AwardID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[AwardDate] [datetime] NOT NULL,
	[ActorID] [int] NOT NULL,
 CONSTRAINT [PK_LearnerAward] PRIMARY KEY CLUSTERED 
(
	[AwardID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[LessonFeedbackSurvey]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[LessonFeedbackSurvey](
	[LessonID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[QuestionID] [int] NOT NULL,
	[Score] [int] NULL,
	[Answer] [nvarchar](max) NULL,
 CONSTRAINT [PK_LessonFeedbackSurvey] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC,
	[RegisterID] ASC,
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [BG].[LessonMissionBonus]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[LessonMissionBonus](
	[BonusID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[LessonID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[BonusStatus] [int] NULL,
 CONSTRAINT [PK_LessonMissionBonus] PRIMARY KEY CLUSTERED 
(
	[BonusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[LessonMissionBonusAwardingItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[LessonMissionBonusAwardingItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[MissionID] [int] NOT NULL,
	[PriceID] [int] NOT NULL,
	[PointValue] [int] NOT NULL,
 CONSTRAINT [PK_LessonMissionBonusAwardingItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[LessonSelfAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[LessonSelfAssessment](
	[LessonID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[Assessment] [nvarchar](32) NOT NULL,
	[Score] [decimal](12, 2) NULL,
	[Answer] [nvarchar](max) NULL,
	[SelectedIndex] [int] NULL,
 CONSTRAINT [PK_LessonSelfAssessment] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC,
	[RegisterID] ASC,
	[Assessment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [BG].[Player]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[Player](
	[UID] [int] NOT NULL,
	[ProgressID] [int] NOT NULL,
	[PlayerLevel] [int] NULL,
 CONSTRAINT [PK_Player] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[ProgressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[StageProgress]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[StageProgress](
	[ProgressID] [int] IDENTITY(1,1) NOT NULL,
	[StartDate] [datetime] NULL,
	[EndExclusiveDate] [datetime] NULL,
 CONSTRAINT [PK_StageProgress] PRIMARY KEY CLUSTERED 
(
	[ProgressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BG].[TipsArticleRelation]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BG].[TipsArticleRelation](
	[DocID] [int] NOT NULL,
	[TipsID] [int] NOT NULL,
 CONSTRAINT [PK_TipsArticleRelation] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC,
	[TipsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[$tmp]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[$tmp](
	[UID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[$tmpSalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[$tmpSalary](
	[CoachID] [int] NOT NULL,
	[SettlementID] [int] NOT NULL,
	[WorkPlace] [int] NULL,
	[LevelID] [int] NOT NULL,
	[GradeIndex] [decimal](18, 2) NOT NULL,
	[ManagerBonus] [int] NULL,
	[SpecialBonus] [int] NULL,
	[PerformanceAchievement] [int] NULL,
	[AchievementShareRatio] [decimal](18, 2) NULL,
	[VoidShare] [int] NULL,
	[PTAttendanceCount] [int] NULL,
	[PTAverageUnitPrice] [int] NULL,
	[AttendanceBonus] [int] NULL,
	[AchievementBonus] [int] NULL,
	[Year] [int] NULL,
	[AvgFlag] [bit] NULL,
	[AttendedByOther] [int] NULL,
	[AttendedByOtherAvgPrice] [int] NULL,
	[AttendedShare] [int] NULL,
	[EmploymentDurationGradeIndex] [int] NULL,
	[TSAttendanceCount] [int] NULL,
	[ManagementBonusGrade] [decimal](6, 4) NULL,
	[JobTenureInDays] [int] NULL,
	[BasicWage] [int] NULL,
	[StaffWelfareFund] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Article]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Article](
	[DocID] [int] NOT NULL,
	[Title] [nvarchar](256) NULL,
	[ArticleContent] [nvarchar](max) NULL,
	[AuthorID] [int] NULL,
	[Illustration] [int] NULL,
	[Subtitle] [nvarchar](256) NULL,
 CONSTRAINT [PK_Article] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attachment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attachment](
	[AttachmentID] [int] IDENTITY(1,1) NOT NULL,
	[StoredPath] [nvarchar](256) NOT NULL,
	[DocID] [int] NULL,
 CONSTRAINT [PK_Attachment] PRIMARY KEY CLUSTERED 
(
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlogArticle]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlogArticle](
	[DocID] [int] NOT NULL,
	[Title] [nvarchar](256) NULL,
	[AuthorID] [int] NULL,
	[Subtitle] [nvarchar](256) NULL,
	[BlogID] [nvarchar](64) NOT NULL,
	[NotAfter] [datetime] NULL,
	[Youtube] [nvarchar](256) NULL,
 CONSTRAINT [PK_BlogArticle] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlogCategoryDefinition]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlogCategoryDefinition](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Category] [nvarchar](32) NOT NULL,
	[Description] [nvarchar](64) NULL,
	[CategoryIndication] [nvarchar](256) NULL,
 CONSTRAINT [PK_BlogCategoryDefinition] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlogCategoryLocale]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlogCategoryLocale](
	[CategoryID] [int] NOT NULL,
	[Language] [nvarchar](8) NOT NULL,
	[Category] [nvarchar](32) NOT NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_BlogCategoryLocale] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC,
	[Language] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlogTag]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlogTag](
	[DocID] [int] NOT NULL,
	[CategoryID] [int] NOT NULL,
 CONSTRAINT [PK_BlogTag] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC,
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BodyDiagnosis]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BodyDiagnosis](
	[DiagnosisID] [int] IDENTITY(1,1) NOT NULL,
	[DiagnosisDate] [datetime] NOT NULL,
	[LearnerID] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
	[LevelID] [int] NOT NULL,
	[Goal] [nvarchar](256) NULL,
	[Description] [nvarchar](256) NULL,
 CONSTRAINT [PK_BodyDiagnosis] PRIMARY KEY CLUSTERED 
(
	[DiagnosisID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BodyParts]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BodyParts](
	[PartID] [int] NOT NULL,
	[Part] [nvarchar](64) NULL,
 CONSTRAINT [PK_BodyParts] PRIMARY KEY CLUSTERED 
(
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BodySuffering]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BodySuffering](
	[DiagnosisID] [int] NOT NULL,
	[PartID] [int] NOT NULL,
 CONSTRAINT [PK_BodySuffering] PRIMARY KEY CLUSTERED 
(
	[DiagnosisID] ASC,
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoachCertificate]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoachCertificate](
	[CoachID] [int] NOT NULL,
	[CertificateID] [int] NOT NULL,
	[Expiration] [datetime] NULL,
	[Status] [int] NULL,
	[AttachmentID] [int] NULL,
	[ApprovedBy] [int] NULL,
	[ApprovedDate] [datetime] NULL,
 CONSTRAINT [PK_CoachCertificate] PRIMARY KEY CLUSTERED 
(
	[CoachID] ASC,
	[CertificateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CoachRating]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CoachRating](
	[RatingID] [int] IDENTITY(1,1) NOT NULL,
	[CoachID] [int] NOT NULL,
	[RatingDate] [datetime] NOT NULL,
	[AttendanceCount] [int] NULL,
	[TuitionSummary] [int] NULL,
	[LevelID] [int] NOT NULL,
 CONSTRAINT [PK_CoachRating] PRIMARY KEY CLUSTERED 
(
	[RatingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractElement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractElement](
	[ContractID] [int] NOT NULL,
	[OriginalFitnessConsultant] [int] NOT NULL,
	[ElementID] [int] IDENTITY(1,1) NOT NULL,
	[RevisionID] [int] NOT NULL,
 CONSTRAINT [PK_ContractElement] PRIMARY KEY CLUSTERED 
(
	[ElementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractInstallment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractInstallment](
	[InstallmentID] [int] IDENTITY(1,1) NOT NULL,
	[Installments] [int] NOT NULL,
 CONSTRAINT [PK_ContractInstallment] PRIMARY KEY CLUSTERED 
(
	[InstallmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractMonthlySummary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractMonthlySummary](
	[ContractID] [int] NOT NULL,
	[SettlementDate] [datetime] NOT NULL,
	[TotalPrepaid] [int] NOT NULL,
	[TotalLessonCost] [int] NOT NULL,
	[RemainedAmount] [int] NOT NULL,
	[TotalAllowanceAmount] [int] NULL,
 CONSTRAINT [PK_ContractMonthlySummary] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[SettlementDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractPayment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPayment](
	[PaymentID] [int] NOT NULL,
	[ContractID] [int] NOT NULL,
 CONSTRAINT [PK_ContractPayment] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTrustSettlement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTrustSettlement](
	[ContractID] [int] NOT NULL,
	[SettlementID] [int] NOT NULL,
	[TotalTrustAmount] [int] NOT NULL,
	[InitialTrustAmount] [int] NOT NULL,
	[BookingTrustAmount] [int] NULL,
	[CurrentLiableAmount] [int] NULL,
 CONSTRAINT [PK_ContractTrustSettlement] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[SettlementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTrustTrack]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTrustTrack](
	[TrustID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[TrustType] [nvarchar](8) NOT NULL,
	[SettlementID] [int] NULL,
	[LessonID] [int] NULL,
	[PaymentID] [int] NULL,
	[VoidID] [int] NULL,
	[ReturnAmount] [int] NULL,
 CONSTRAINT [PK_ContractTrustTrack] PRIMARY KEY CLUSTERED 
(
	[TrustID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContractTrustTrackBak]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractTrustTrackBak](
	[TrustID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [int] NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[TrustType] [nvarchar](8) NOT NULL,
	[SettlementID] [int] NULL,
	[LessonID] [int] NULL,
	[PaymentID] [int] NULL,
	[VoidID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractAction]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractAction](
	[ContractID] [int] NOT NULL,
	[ActionID] [int] NOT NULL,
 CONSTRAINT [PK_CourseContractAction] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[ActionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractExtension]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractExtension](
	[ContractID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[RevisionTrackingID] [int] NULL,
	[SettlementPrice] [int] NULL,
	[PaymentMethod] [nvarchar](64) NULL,
	[Version] [int] NULL,
	[AttachmentID] [int] NULL,
	[SignOnline] [bit] NULL,
	[UnitPriceID] [int] NULL,
	[UnitPriceAdjustmentType] [int] NULL,
	[CoursePlace] [int] NULL,
	[SignerPIN] [nvarchar](64) NULL,
	[BRByLearner] [int] NULL,
	[BRByCoach] [int] NULL,
	[SignerPINExpiration] [datetime] NULL,
 CONSTRAINT [PK_CourseContractExtension] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractLessonExchange]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractLessonExchange](
	[ExchangeID] [int] IDENTITY(1,1) NOT NULL,
	[RevisionID] [int] NOT NULL,
	[TargetPriceID] [int] NULL,
	[TargetRegisterID] [int] NULL,
	[TargetSubtotal] [int] NULL,
	[OriginalRemainedCount] [int] NULL,
 CONSTRAINT [PK_CourseContractLessonExchange] PRIMARY KEY CLUSTERED 
(
	[ExchangeID] ASC,
	[RevisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractLevel]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractLevel](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [int] NOT NULL,
	[LevelDate] [datetime] NOT NULL,
	[ExecutorID] [int] NOT NULL,
	[LevelID] [int] NOT NULL,
 CONSTRAINT [PK_CourseContractLevel] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractOrder]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractOrder](
	[ContractID] [int] NOT NULL,
	[PriceID] [int] NOT NULL,
	[Lessons] [int] NOT NULL,
	[SeqNo] [int] NULL,
	[Title] [nvarchar](64) NULL,
 CONSTRAINT [PK_CourseContractOrder] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractRevision]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractRevision](
	[RevisionID] [int] NOT NULL,
	[OriginalContract] [int] NULL,
	[RevisionNo] [int] NOT NULL,
	[Reason] [nvarchar](16) NULL,
	[OperationMode] [int] NULL,
	[AttachmentID] [int] NULL,
	[MonthExtension] [int] NULL,
	[BySelf] [int] NULL,
	[ProcessingFee] [int] NULL,
	[CauseForEnding] [int] NULL,
 CONSTRAINT [PK_CourseContractRevision] PRIMARY KEY CLUSTERED 
(
	[RevisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractRevisionItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractRevisionItem](
	[RevisionID] [int] NOT NULL,
	[FitnessConsultant] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
 CONSTRAINT [PK_CourseContractRevisionItem] PRIMARY KEY CLUSTERED 
(
	[RevisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractSignature]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractSignature](
	[SignatureID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[SignatureName] [nvarchar](64) NULL,
	[Signature] [varchar](max) NULL,
 CONSTRAINT [PK_CourseContractSignature] PRIMARY KEY CLUSTERED 
(
	[SignatureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractStatistic]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractStatistic](
	[ContractID] [int] NOT NULL,
	[LifeDays] [int] NULL,
	[AttendanceDurationDays] [int] NULL,
	[TotalAttendanceCount] [int] NULL,
 CONSTRAINT [PK_CourseContractStatistic] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractTermination]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractTermination](
	[RevisionID] [int] NOT NULL,
	[AccountInfo] [int] NULL,
	[BankID] [nvarchar](8) NULL,
	[BankAccount] [nvarchar](32) NULL,
	[FeeChargeStatus] [int] NULL,
 CONSTRAINT [PK_CourseContractTermination] PRIMARY KEY CLUSTERED 
(
	[RevisionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractTrust]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractTrust](
	[ContractID] [int] NOT NULL,
	[CurrentSettlement] [int] NOT NULL,
 CONSTRAINT [PK_CourseContractTrust] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractType](
	[TypeID] [int] NOT NULL,
	[TypeName] [nvarchar](32) NULL,
	[ContractCode] [nvarchar](8) NULL,
	[IsGroup] [bit] NULL,
	[GroupingMemberCount] [int] NULL,
	[OnlineCourse] [bit] NULL,
	[TrustType] [int] NULL,
 CONSTRAINT [PK_CourseContractType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CourseContractView]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseContractView](
	[TypeID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[ViewPath] [nvarchar](256) NULL,
 CONSTRAINT [PK_CourseContractView] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC,
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DailyWorkingHour]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DailyWorkingHour](
	[Hour] [int] NOT NULL,
 CONSTRAINT [PK_DailyWorkingHour] PRIMARY KEY CLUSTERED 
(
	[Hour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DerivedDocument]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DerivedDocument](
	[DocID] [int] NOT NULL,
	[SourceID] [int] NOT NULL,
 CONSTRAINT [PK_DerivedDocument] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DiagnosisAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiagnosisAssessment](
	[DiagnosisID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[Assessment] [decimal](12, 2) NULL,
	[Judgement] [nvarchar](64) NULL,
	[DiagnosisAction] [nvarchar](256) NULL,
	[Description] [nvarchar](256) NULL,
	[AdditionalAssessment] [decimal](12, 2) NULL,
 CONSTRAINT [PK_DiagnosisAssessment] PRIMARY KEY CLUSTERED 
(
	[DiagnosisID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DiagnosisJudgement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiagnosisJudgement](
	[JudgementID] [int] IDENTITY(1,1) NOT NULL,
	[FitnessID] [int] NOT NULL,
	[RangeStart] [decimal](18, 2) NULL,
	[RangeEnd] [decimal](18, 2) NULL,
	[Judgement] [nvarchar](64) NULL,
 CONSTRAINT [PK_DiagnosisJudgement] PRIMARY KEY CLUSTERED 
(
	[JudgementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Document]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document](
	[DocID] [int] IDENTITY(1,1) NOT NULL,
	[DocType] [int] NULL,
	[DocDate] [datetime] NOT NULL,
	[CurrentStep] [int] NULL,
	[ChannelID] [int] NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentPrintLog]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentPrintLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[DocID] [int] NOT NULL,
	[PrintDate] [datetime] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_DocumentPrintLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentPrintQueue]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentPrintQueue](
	[DocID] [int] NOT NULL,
	[UID] [int] NULL,
	[SubmitDate] [datetime] NULL,
 CONSTRAINT [PK_DocumentPrintQueue] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentType](
	[TypeID] [int] NOT NULL,
	[TypeName] [nvarchar](128) NULL,
 CONSTRAINT [PK_DocumentType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmployeeWelfare]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeWelfare](
	[UID] [int] NOT NULL,
	[MonthlyGiftLessons] [int] NULL,
 CONSTRAINT [PK_EmployeeWelfare] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseCourseContract]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseCourseContract](
	[ContractID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[Remark] [nvarchar](64) NULL,
	[Subject] [nvarchar](64) NULL,
	[ContractNo] [nvarchar](64) NULL,
	[TotalCost] [int] NULL,
	[BranchID] [int] NULL,
	[ValidFrom] [datetime] NULL,
	[Expiration] [datetime] NULL,
	[GroupingMemberCount] [int] NOT NULL,
 CONSTRAINT [PK_EnterpriseCourseContract_1] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseCourseMember]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseCourseMember](
	[ContractID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[GroupID] [int] NULL,
 CONSTRAINT [PK_EnterpriseCourseMember] PRIMARY KEY CLUSTERED 
(
	[ContractID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseCoursePayment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseCoursePayment](
	[PaymentID] [int] NOT NULL,
	[ContractID] [int] NOT NULL,
 CONSTRAINT [PK_EnterpriseCoursePayment] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExerciseGameContestant]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExerciseGameContestant](
	[UID] [int] NOT NULL,
	[Status] [int] NULL,
	[TotalScope] [int] NULL,
	[Rank] [int] NULL,
 CONSTRAINT [PK_ExerciseGameContestant] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExerciseGameItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExerciseGameItem](
	[ExerciseID] [int] NOT NULL,
	[Exercise] [nvarchar](32) NOT NULL,
	[Unit] [nvarchar](16) NULL,
	[Descending] [bit] NULL,
 CONSTRAINT [PK_ExerciseGameItem] PRIMARY KEY CLUSTERED 
(
	[ExerciseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExerciseGamePersonalRank]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExerciseGamePersonalRank](
	[UID] [int] NOT NULL,
	[TotalScope] [int] NOT NULL,
	[Rank] [int] NOT NULL,
 CONSTRAINT [PK_ExerciseGamePersonalRank] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExerciseGameRank]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExerciseGameRank](
	[UID] [int] NOT NULL,
	[ExerciseID] [int] NOT NULL,
	[RecordID] [int] NULL,
	[RankingScore] [int] NULL,
	[Rank] [int] NULL,
 CONSTRAINT [PK_ExerciseGameRank] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[ExerciseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExerciseGameResult]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExerciseGameResult](
	[TestID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[ExerciseID] [int] NOT NULL,
	[Score] [decimal](12, 4) NOT NULL,
	[TestDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ExerciseGameResult] PRIMARY KEY CLUSTERED 
(
	[TestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FavoriteLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FavoriteLesson](
	[ExecutionID] [int] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_FavoriteLesson] PRIMARY KEY CLUSTERED 
(
	[ExecutionID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitnessAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitnessAssessment](
	[LessonID] [int] NOT NULL,
	[Flexibility] [int] NULL,
	[Cardiopulmonary] [int] NULL,
	[Strength] [int] NULL,
	[Endurance] [int] NULL,
	[ExplosiveForce] [int] NULL,
	[SportsPerformance] [int] NULL,
 CONSTRAINT [PK_FitnessAssessment] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitnessAssessmentGroup]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitnessAssessmentGroup](
	[GroupID] [int] NOT NULL,
	[MajorID] [int] NULL,
	[GroupName] [nvarchar](32) NULL,
 CONSTRAINT [PK_FitnessAssessmentGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FitnessDiagnosis]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FitnessDiagnosis](
	[FitnessID] [int] IDENTITY(1,1) NOT NULL,
	[ItemID] [int] NOT NULL,
	[Gender] [nvarchar](8) NULL,
	[YearsOldStart] [int] NULL,
	[YearsOldEnd] [int] NULL,
 CONSTRAINT [PK_FitnessDiagnosis] PRIMARY KEY CLUSTERED 
(
	[FitnessID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ForEmployee]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ForEmployee](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[EmploymentDate] [date] NULL,
	[LeavedDate] [date] NULL,
 CONSTRAINT [PK_ForEmployee] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GoalAboutPDQ]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoalAboutPDQ](
	[GoalID] [int] NOT NULL,
	[Goal] [nvarchar](64) NULL,
 CONSTRAINT [PK_GoalAboutPDQ] PRIMARY KEY CLUSTERED 
(
	[GoalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GroupEvent]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupEvent](
	[EventID] [int] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_GroupEvent] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GroupingLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GroupingLesson](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_GroupingLesson] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IntuitionCharge]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IntuitionCharge](
	[RegisterID] [int] NOT NULL,
	[Payment] [nvarchar](32) NOT NULL,
	[FeeShared] [int] NULL,
	[ByInstallments] [int] NULL,
 CONSTRAINT [PK_IntuitionCharge] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowance]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowance](
	[AllowanceID] [int] NOT NULL,
	[AllowanceNumber] [nvarchar](16) NULL,
	[AllowanceType] [tinyint] NULL,
	[AllowanceDate] [datetime] NULL,
	[TotalAmount] [decimal](18, 5) NULL,
	[TaxAmount] [decimal](18, 5) NULL,
	[InvoiceID] [int] NULL,
	[SellerId] [nvarchar](10) NULL,
	[BuyerId] [nvarchar](10) NULL,
 CONSTRAINT [PK_InvoiceAllowance] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceBuyer]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceBuyer](
	[AllowanceID] [int] NOT NULL,
	[BuyerID] [int] NULL,
	[Name] [nvarchar](128) NULL,
	[CustomerName] [nvarchar](64) NULL,
	[ReceiptNo] [nvarchar](10) NULL,
	[PostCode] [nvarchar](8) NULL,
	[Address] [nvarchar](128) NULL,
	[CustomerID] [nvarchar](64) NULL,
	[ContactName] [nvarchar](64) NULL,
	[Phone] [nvarchar](64) NULL,
	[EMail] [nvarchar](512) NULL,
	[Fax] [nvarchar](64) NULL,
	[PersonInCharge] [nvarchar](64) NULL,
	[RoleRemark] [nvarchar](64) NULL,
 CONSTRAINT [PK_InvoiceAllowanceBuyer] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceCancellation]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceCancellation](
	[AllowanceID] [int] NOT NULL,
	[CancelDate] [datetime] NULL,
	[Remark] [nvarchar](256) NULL,
	[CancelReason] [nvarchar](256) NULL,
 CONSTRAINT [PK_InvoiceAllowanceCancellation] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceDetails]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceDetails](
	[AllowanceID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceAllowanceDetails] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceDispatch]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceDispatch](
	[AllowanceID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceAllowanceDispatch] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceDispatchLog]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceDispatchLog](
	[AllowanceID] [int] NOT NULL,
	[DispatchDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_InvoiceAllowanceDispatchLog] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[No] [smallint] NULL,
	[InvoiceNo] [nvarchar](16) NULL,
	[Piece] [decimal](18, 5) NULL,
	[Amount] [decimal](18, 5) NULL,
	[Tax] [decimal](18, 5) NULL,
	[ProductItemID] [int] NULL,
	[InvoiceDate] [datetime] NULL,
	[ItemNo] [nvarchar](16) NULL,
	[OriginalSequenceNo] [smallint] NULL,
	[PieceUnit] [nvarchar](16) NULL,
	[OriginalDescription] [nvarchar](256) NULL,
	[TaxType] [tinyint] NULL,
	[UnitCost] [decimal](18, 5) NULL,
	[UnitCost2] [decimal](18, 5) NULL,
	[Piece2] [decimal](18, 5) NULL,
	[Amount2] [decimal](18, 5) NULL,
	[PieceUnit2] [nvarchar](16) NULL,
	[Remark] [nvarchar](max) NULL,
 CONSTRAINT [PK_InvoiceAllowanceItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAllowanceSeller]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAllowanceSeller](
	[AllowanceID] [int] NOT NULL,
	[SellerID] [int] NULL,
	[Name] [nvarchar](128) NULL,
	[CustomerName] [nvarchar](64) NULL,
	[ReceiptNo] [nvarchar](10) NULL,
	[PostCode] [nvarchar](8) NULL,
	[Address] [nvarchar](128) NULL,
	[CustomerID] [nvarchar](64) NULL,
	[ContactName] [nvarchar](64) NULL,
	[Phone] [nvarchar](64) NULL,
	[EMail] [nvarchar](512) NULL,
	[Fax] [nvarchar](64) NULL,
	[PersonInCharge] [nvarchar](64) NULL,
	[RoleRemark] [nvarchar](64) NULL,
 CONSTRAINT [PK_InvoiceAllowanceSeller] PRIMARY KEY CLUSTERED 
(
	[AllowanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceAmountType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceAmountType](
	[InvoiceID] [int] NOT NULL,
	[TaxType] [tinyint] NULL,
	[SalesAmount] [decimal](18, 5) NULL,
	[TaxAmount] [decimal](18, 5) NULL,
	[TaxRate] [decimal](18, 5) NULL,
	[TotalAmount] [decimal](18, 5) NULL,
	[TotalAmountInChinese] [nvarchar](32) NULL,
	[DiscountAmount] [decimal](18, 5) NULL,
	[Adjustment] [decimal](18, 5) NULL,
	[OriginalCurrencyAmount] [decimal](18, 5) NULL,
	[ExchangeRate] [decimal](18, 5) NULL,
	[CurrencyID] [int] NULL,
 CONSTRAINT [PK_InvoiceAmountType] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceBuyer]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceBuyer](
	[InvoiceID] [int] NOT NULL,
	[ReceiptNo] [nvarchar](10) NULL,
	[PostCode] [nvarchar](8) NULL,
	[Address] [nvarchar](128) NULL,
	[Name] [nvarchar](128) NULL,
	[BuyerID] [int] NULL,
	[CustomerID] [nvarchar](64) NULL,
	[ContactName] [nvarchar](64) NULL,
	[Phone] [nvarchar](64) NULL,
	[EMail] [nvarchar](512) NULL,
	[CustomerName] [nvarchar](64) NULL,
	[Fax] [nvarchar](64) NULL,
	[PersonInCharge] [nvarchar](64) NULL,
	[RoleRemark] [nvarchar](64) NULL,
	[CustomerNumber] [nvarchar](20) NULL,
 CONSTRAINT [PK_InvoiceBuyer] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceCancellation]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceCancellation](
	[CancellationNo] [nvarchar](16) NULL,
	[CancelDate] [datetime] NULL,
	[CancelReason] [nvarchar](256) NULL,
	[ReturnTaxDocumentNo] [nvarchar](64) NULL,
	[Remark] [nvarchar](256) NULL,
	[InvoiceID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceCancellation] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceCancellationDispatch]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceCancellationDispatch](
	[InvoiceID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceCancellationDispatch] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceCancellationDispatchLog]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceCancellationDispatchLog](
	[InvoiceID] [int] NOT NULL,
	[DispatchDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_InvoiceCancellationDispatchLog] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceCarrier]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceCarrier](
	[InvoiceID] [int] NOT NULL,
	[CarrierType] [nvarchar](16) NOT NULL,
	[CarrierNo] [nvarchar](64) NULL,
	[CarrierNo2] [nvarchar](64) NULL,
 CONSTRAINT [PK_InvoiceCarrier] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceDetails]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceDetails](
	[InvoiceID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceDetails] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceDonation]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceDonation](
	[InvoiceID] [int] NOT NULL,
	[AgencyCode] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_InvoiceDonation] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItem](
	[InvoiceID] [int] NOT NULL,
	[No] [nvarchar](16) NULL,
	[InvoiceDate] [datetime] NULL,
	[CheckNo] [nvarchar](10) NULL,
	[Remark] [nvarchar](256) NULL,
	[BuyerRemark] [nvarchar](1) NULL,
	[CustomsClearanceMark] [nvarchar](1) NULL,
	[TaxCenter] [nvarchar](40) NULL,
	[PermitDate] [datetime] NULL,
	[PermitWord] [nvarchar](40) NULL,
	[PermitNumber] [nvarchar](20) NULL,
	[Category] [nvarchar](2) NULL,
	[RelateNumber] [nvarchar](20) NULL,
	[InvoiceType] [tinyint] NULL,
	[GroupMark] [nvarchar](2) NULL,
	[DonateMark] [nvarchar](1) NULL,
	[SellerID] [int] NULL,
	[DonationID] [int] NULL,
	[RandomNo] [nvarchar](10) NULL,
	[TrackCode] [nvarchar](2) NULL,
	[BondedAreaConfirm] [tinyint] NULL,
	[PrintMark] [nvarchar](1) NULL,
 CONSTRAINT [PK_InvoiceItem] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceItemDispatch]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItemDispatch](
	[InvoiceID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceItemDispatch] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceItemDispatchLog]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItemDispatchLog](
	[InvoiceID] [int] NOT NULL,
	[DispatchDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_InvoiceItemDispatchLog] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceNoAssignment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceNoAssignment](
	[InvoiceID] [int] NOT NULL,
	[IntervalID] [int] NULL,
	[InvoiceNo] [int] NULL,
 CONSTRAINT [PK_InvoiceNoAssignment] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceNoInterval]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceNoInterval](
	[IntervalID] [int] IDENTITY(1,1) NOT NULL,
	[TrackID] [int] NOT NULL,
	[SellerID] [int] NOT NULL,
	[StartNo] [int] NOT NULL,
	[EndNo] [int] NOT NULL,
	[GroupID] [int] NULL,
 CONSTRAINT [PK_InvoiceNoInterval] PRIMARY KEY CLUSTERED 
(
	[IntervalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceNoIntervalGroup]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceNoIntervalGroup](
	[GroupID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_InvoiceNoIntervalGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceProduct]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceProduct](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[Brief] [nvarchar](256) NULL,
 CONSTRAINT [PK_InvoiceProduct] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceProductItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceProductItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[No] [smallint] NULL,
	[Spec] [nvarchar](128) NULL,
	[Piece] [decimal](18, 5) NULL,
	[Piece2] [decimal](18, 5) NULL,
	[PieceUnit] [nvarchar](16) NULL,
	[PieceUnit2] [nvarchar](16) NULL,
	[Weight] [decimal](18, 5) NULL,
	[WeightUnit] [nvarchar](16) NULL,
	[UnitFreight] [decimal](18, 5) NULL,
	[UnitCost] [decimal](18, 5) NULL,
	[UnitCost2] [decimal](18, 5) NULL,
	[FreightAmount] [decimal](18, 5) NULL,
	[CostAmount] [decimal](18, 5) NULL,
	[CostAmount2] [decimal](18, 5) NULL,
	[OriginalPrice] [decimal](18, 5) NULL,
	[Remark] [nvarchar](128) NULL,
	[RelateNumber] [nvarchar](64) NULL,
	[TaxType] [tinyint] NULL,
	[ItemNo] [nvarchar](16) NULL,
 CONSTRAINT [PK_InvoiceProductItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoicePurchaseOrder]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoicePurchaseOrder](
	[InvoiceID] [int] NOT NULL,
	[UploadID] [int] NULL,
	[OrderNo] [nvarchar](64) NULL,
	[PurchaseDate] [datetime] NULL,
 CONSTRAINT [PK_InvoicePurchaseOrder] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceSeller]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceSeller](
	[InvoiceID] [int] NOT NULL,
	[ReceiptNo] [nvarchar](10) NULL,
	[PostCode] [nvarchar](8) NULL,
	[Address] [nvarchar](128) NULL,
	[Name] [nvarchar](128) NULL,
	[SellerID] [int] NULL,
	[CustomerID] [nvarchar](64) NULL,
	[ContactName] [nvarchar](64) NULL,
	[Phone] [nvarchar](64) NULL,
	[EMail] [nvarchar](512) NULL,
	[CustomerName] [nvarchar](64) NULL,
	[Fax] [nvarchar](64) NULL,
	[PersonInCharge] [nvarchar](64) NULL,
	[RoleRemark] [nvarchar](64) NULL,
 CONSTRAINT [PK_InvoiceSeller] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceTrackCode]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceTrackCode](
	[TrackID] [int] IDENTITY(1,1) NOT NULL,
	[TrackCode] [nvarchar](2) NOT NULL,
	[Year] [smallint] NOT NULL,
	[PeriodNo] [smallint] NOT NULL,
	[StartNo] [int] NULL,
	[EndNo] [int] NULL,
 CONSTRAINT [PK_InvoiceTrackCode] PRIMARY KEY CLUSTERED 
(
	[TrackID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceTrackCodeAssignment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceTrackCodeAssignment](
	[TrackID] [int] NOT NULL,
	[SellerID] [int] NOT NULL,
 CONSTRAINT [PK_InvoiceTrackCodeAssignment] PRIMARY KEY CLUSTERED 
(
	[TrackID] ASC,
	[SellerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InvoiceWinningNumber]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceWinningNumber](
	[WinningNO] [nvarchar](16) NOT NULL,
	[Year] [int] NOT NULL,
	[MonthFrom] [tinyint] NOT NULL,
	[MonthTo] [tinyint] NOT NULL,
	[WinningType] [nvarchar](64) NULL,
	[InvoiceID] [int] NOT NULL,
	[TrackCode] [nvarchar](2) NULL,
	[DataType] [nvarchar](1) NULL,
	[BonusDescription] [nvarchar](32) NULL,
	[WinningID] [int] NULL,
	[DownloadDate] [datetime] NULL,
 CONSTRAINT [PK_InvoiceWinningNumber] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IsInternalLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IsInternalLesson](
	[PriceID] [int] NOT NULL,
 CONSTRAINT [PK_IsInternalLesson] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IsWelfareGiftLesson]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IsWelfareGiftLesson](
	[PriceID] [int] NOT NULL,
 CONSTRAINT [PK_IsWelfareGiftLesson] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LearnerFitnessAdvisor]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LearnerFitnessAdvisor](
	[UID] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
 CONSTRAINT [PK_LearnerFitnessAdvisor] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonAttendanceDueDate]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonAttendanceDueDate](
	[DueDate] [date] NOT NULL,
 CONSTRAINT [PK_LessonAttendanceDueDate] PRIMARY KEY CLUSTERED 
(
	[DueDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonComment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonComment](
	[CommentID] [int] IDENTITY(1,1) NOT NULL,
	[SpeakerID] [int] NOT NULL,
	[HearerID] [int] NOT NULL,
	[Comment] [nvarchar](max) NULL,
	[CommentDate] [datetime] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_LessonComment] PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFeedBack]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFeedBack](
	[LessonID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[FeedBack] [nvarchar](max) NULL,
	[FeedBackDate] [datetime] NULL,
	[Remark] [nvarchar](max) NULL,
	[RemarkDate] [datetime] NULL,
	[Status] [int] NULL,
	[CommitAssessment] [datetime] NULL,
	[CommitAssessmentIP] [nvarchar](32) NULL,
	[AssessmentSignature] [nvarchar](max) NULL,
 CONSTRAINT [PK_LessonFeedBack] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC,
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitnessAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitnessAssessment](
	[AssessmentID] [int] IDENTITY(1,1) NOT NULL,
	[LessonID] [int] NULL,
	[UID] [int] NOT NULL,
	[AssessmentDate] [datetime] NULL,
	[FeedBackDate] [datetime] NULL,
	[Remark] [nvarchar](max) NULL,
	[FeedBack] [nvarchar](max) NULL,
 CONSTRAINT [PK_LessonFitnessAssessment] PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonFitnessAssessmentReport]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonFitnessAssessmentReport](
	[AssessmentID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[TotalAssessment] [decimal](12, 2) NULL,
	[SingleAssessment] [decimal](12, 2) NULL,
	[ByTimes] [int] NULL,
	[BySingleSide] [bit] NULL,
	[ByCustom] [nvarchar](64) NULL,
 CONSTRAINT [PK_LessonFitnessAssessmentReport] PRIMARY KEY CLUSTERED 
(
	[AssessmentID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonPriceExchange]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPriceExchange](
	[SourceID] [int] NOT NULL,
	[TargetID] [int] NOT NULL,
	[ExchangeRate] [decimal](12, 2) NOT NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_LessonPriceExchange] PRIMARY KEY CLUSTERED 
(
	[SourceID] ASC,
	[TargetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonPricePackage]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonPricePackage](
	[PriceID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[Lessons] [int] NULL,
	[Title] [nvarchar](64) NULL,
 CONSTRAINT [PK_LessonPricePackage] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonTimeExpansion]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonTimeExpansion](
	[ClassDate] [date] NOT NULL,
	[Hour] [int] NOT NULL,
	[LessonID] [int] NOT NULL,
	[ExpansionID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_LessonTimeExpansion] PRIMARY KEY CLUSTERED 
(
	[ExpansionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonTrend]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonTrend](
	[LessonID] [int] NOT NULL,
	[ActionLearning] [int] NULL,
	[PostureRedress] [int] NULL,
	[Training] [int] NULL,
	[Counseling] [int] NULL,
 CONSTRAINT [PK_LessonTrend] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LessonUnitPrice]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LessonUnitPrice](
	[PriceID] [int] NOT NULL,
	[UnitID] [int] NOT NULL,
 CONSTRAINT [PK_LessonUnitPrice] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LevelExpression]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LevelExpression](
	[LevelID] [int] NOT NULL,
	[Expression] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
 CONSTRAINT [PK_LevelExpression] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MerchandiseTransaction]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MerchandiseTransaction](
	[TransactionID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
 CONSTRAINT [PK_MerchandiseTransaction] PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MerchandiseTransactionType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MerchandiseTransactionType](
	[TransactionID] [int] NOT NULL,
	[TransactionType] [nvarchar](16) NULL,
	[CategorySourceID] [int] NULL,
	[Subtitle] [nvarchar](64) NULL,
 CONSTRAINT [PK_MerchandiseTransactionType] PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MerchandiseWindow]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MerchandiseWindow](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](32) NOT NULL,
	[UnitPrice] [int] NULL,
	[Status] [int] NULL,
	[SampleUrl] [nvarchar](256) NULL,
	[ListingDate] [datetime] NULL,
	[RemovalDate] [datetime] NULL,
 CONSTRAINT [PK_MerchandiseWindow] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organization]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organization](
	[ContactName] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[LogoURL] [nvarchar](200) NULL,
	[CompanyName] [nvarchar](128) NULL,
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[ReceiptNo] [nvarchar](10) NULL,
	[Phone] [nvarchar](64) NULL,
	[ContactFax] [nvarchar](20) NULL,
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
	[UndertakerFax] [nvarchar](20) NULL,
	[UndertakerMobilePhone] [nvarchar](20) NULL,
	[InvoiceSignature] [nvarchar](64) NULL,
	[UndertakerID] [nvarchar](16) NULL,
	[ContactTitle] [nvarchar](16) NULL,
	[TaxNo] [nvarchar](16) NULL,
 CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentAudit]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentAudit](
	[PaymentID] [int] NOT NULL,
	[AuditorID] [int] NULL,
	[AuditDate] [datetime] NULL,
 CONSTRAINT [PK_PaymentAudit_1] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentContractTermination]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentContractTermination](
	[PaymentID] [int] NOT NULL,
	[RevisionID] [int] NOT NULL,
 CONSTRAINT [PK_PaymentContractTermination] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentOnLine]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentOnLine](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[PaymentID] [int] NOT NULL,
	[mid] [nvarchar](15) NULL,
	[tid] [nvarchar](8) NULL,
	[oid] [nvarchar](40) NOT NULL,
	[pan] [nvarchar](16) NULL,
	[transCode] [int] NULL,
	[transMode] [int] NULL,
	[transDate] [nvarchar](8) NULL,
	[transTime] [nvarchar](6) NULL,
	[transAmt] [nvarchar](8) NULL,
	[approveCode] [nvarchar](8) NULL,
	[responseCode] [nvarchar](3) NULL,
	[responseMsg] [nvarchar](60) NULL,
	[installmentType] [nvarchar](1) NULL,
	[installment] [int] NULL,
	[firstAmt] [int] NULL,
	[eachAmt] [int] NULL,
	[fee] [int] NULL,
	[redeemType] [nvarchar](1) NULL,
	[redeemUsed] [int] NULL,
	[redeemBalance] [int] NULL,
	[creditAmt] [int] NULL,
	[secureStatus] [nvarchar](1) NULL,
 CONSTRAINT [PK_PaymentOnLine] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentOrder]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentOrder](
	[PaymentID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductCount] [int] NOT NULL,
 CONSTRAINT [PK_PaymentOrder] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentTransaction]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentTransaction](
	[PaymentID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[PayerID] [int] NULL,
 CONSTRAINT [PK_PaymentTransaction] PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQGroup]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQGroup](
	[GroupID] [int] NOT NULL,
	[GroupName] [nvarchar](64) NOT NULL,
	[ConclusionID] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_PDQGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQQuestion]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQQuestion](
	[QuestionID] [int] IDENTITY(1,1) NOT NULL,
	[Question] [nvarchar](1024) NULL,
	[QuestionType] [int] NULL,
	[RightAnswer] [bit] NULL,
	[QuestionNo] [int] NULL,
	[GroupID] [int] NULL,
	[AskerID] [int] NULL,
 CONSTRAINT [PK_PDQQuestion] PRIMARY KEY CLUSTERED 
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQQuestionExtension]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQQuestionExtension](
	[QuestionID] [int] NOT NULL,
	[BonusPoint] [int] NULL,
	[Status] [int] NULL,
	[CreationTime] [datetime] NULL,
	[AwardingAction] [int] NULL,
 CONSTRAINT [PK_PDQQuestionExtension] PRIMARY KEY CLUSTERED 
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQSuggestion]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQSuggestion](
	[SuggestionID] [int] IDENTITY(1,1) NOT NULL,
	[QuestionID] [int] NOT NULL,
	[Suggestion] [nvarchar](256) NULL,
	[RightAnswer] [bit] NULL,
 CONSTRAINT [PK_PDQSuggestion] PRIMARY KEY CLUSTERED 
(
	[SuggestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQTask]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQTask](
	[TaskID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[SuggestionID] [int] NULL,
	[QuestionID] [int] NULL,
	[PDQAnswer] [nvarchar](max) NULL,
	[YesOrNo] [bit] NULL,
	[TaskDate] [datetime] NULL,
	[QuestionnaireID] [int] NULL,
 CONSTRAINT [PK_PDQTask] PRIMARY KEY CLUSTERED 
(
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQTaskBonus]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQTaskBonus](
	[TaskID] [int] NOT NULL,
	[BonusPoint] [int] NULL,
 CONSTRAINT [PK_PDQTaskBonus] PRIMARY KEY CLUSTERED 
(
	[TaskID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQTaskItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQTaskItem](
	[TaskID] [int] NOT NULL,
	[SuggestionID] [int] NOT NULL,
 CONSTRAINT [PK_PDQTaskItem] PRIMARY KEY CLUSTERED 
(
	[TaskID] ASC,
	[SuggestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQType](
	[QuestionID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
 CONSTRAINT [PK_PDQType] PRIMARY KEY CLUSTERED 
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PDQUserAssessment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PDQUserAssessment](
	[UID] [int] NOT NULL,
	[GoalID] [int] NULL,
	[LevelID] [int] NULL,
	[StyleID] [int] NULL,
 CONSTRAINT [PK_PDQUserAssessment] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonalExercisePurpose]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonalExercisePurpose](
	[UID] [int] NOT NULL,
	[Purpose] [nvarchar](16) NULL,
	[PowerAbility] [nvarchar](16) NULL,
	[Flexibility] [int] NULL,
	[Cardiopulmonary] [int] NULL,
	[MuscleStrength] [int] NULL,
	[AbilityStyle] [nvarchar](16) NULL,
	[AbilityLevel] [int] NULL,
 CONSTRAINT [PK_PersonalExercisePurpose] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonalExercisePurposeItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonalExercisePurposeItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[PurposeItem] [nvarchar](256) NOT NULL,
	[CompleteDate] [datetime] NULL,
	[NoticeStatus] [int] NULL,
	[InitialDate] [datetime] NULL,
 CONSTRAINT [PK_PersonalExercisePurposeItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PreferredLessonTime]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PreferredLessonTime](
	[LessonID] [int] NOT NULL,
	[ApproverID] [int] NULL,
	[ApprovalDate] [datetime] NULL,
 CONSTRAINT [PK_PreferredLessonTime] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProfessionalCertificate]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfessionalCertificate](
	[CertificateID] [int] NOT NULL,
	[Description] [nvarchar](64) NULL,
	[Statement] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[SampleUrl] [nvarchar](256) NULL,
	[CategoryID] [int] NULL,
 CONSTRAINT [PK_ProfessionalCertificate] PRIMARY KEY CLUSTERED 
(
	[CertificateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProfessionalLevel]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfessionalLevel](
	[LevelID] [int] NOT NULL,
	[LevelName] [nvarchar](16) NOT NULL,
	[GradeIndex] [decimal](18, 2) NULL,
	[CategoryID] [int] NULL,
	[DisplayName] [nvarchar](16) NULL,
 CONSTRAINT [PK_ProfessionalLevel] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProfessionalLevelBasicSalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfessionalLevelBasicSalary](
	[LevelID] [int] NOT NULL,
	[SalaryID] [int] NOT NULL,
 CONSTRAINT [PK_ProfessionalLevelBasicSalary] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProfessionalLevelReview]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProfessionalLevelReview](
	[LevelID] [int] NOT NULL,
	[PromotionID] [int] NULL,
	[DemotionID] [int] NULL,
	[CheckLevel] [int] NOT NULL,
	[NormalAttendanceCount] [int] NULL,
	[NormalAchievement] [int] NULL,
	[PromotionAttendanceCount] [int] NULL,
	[PromotionAchievement] [int] NULL,
	[NormalAcademicGrades] [int] NULL,
	[PromotionAcademicGrades] [int] NULL,
	[NormalTechnicalGrades] [int] NULL,
	[PromotionTechnicalGrades] [int] NULL,
	[NormalCertificateCount] [int] NULL,
	[PromotionCertificateCount] [int] NULL,
 CONSTRAINT [PK_ProfessionalLevelReview] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Publication]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Publication](
	[DocID] [int] NOT NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [PK_Publication] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuestionnaireCoachBypass]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionnaireCoachBypass](
	[QuestionnaireID] [int] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_QuestionnaireCoachBypass] PRIMARY KEY CLUSTERED 
(
	[QuestionnaireID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuestionnaireCoachFinish]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionnaireCoachFinish](
	[QuestionnaireID] [int] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_QuestionnaireCoachFinish] PRIMARY KEY CLUSTERED 
(
	[QuestionnaireID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuestionnaireGroup]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionnaireGroup](
	[GroupID] [int] NOT NULL,
 CONSTRAINT [PK_QuestionnaireGroup] PRIMARY KEY CLUSTERED 
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QuestionnaireRequest]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuestionnaireRequest](
	[QuestionnaireID] [int] IDENTITY(1,1) NOT NULL,
	[RequestDate] [datetime] NULL,
	[GroupID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[Status] [int] NULL,
	[RegisterID] [int] NULL,
	[PartID] [int] NULL,
	[CreatorID] [int] NULL,
 CONSTRAINT [PK_QuestionnaireRequest] PRIMARY KEY CLUSTERED 
(
	[QuestionnaireID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterLessonBooking]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterLessonBooking](
	[BookingID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[BookingTime] [datetime] NULL,
	[LessonID] [int] NULL,
 CONSTRAINT [PK_RegisterLessonBooking] PRIMARY KEY CLUSTERED 
(
	[BookingID] ASC,
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterLessonSharing]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterLessonSharing](
	[RegisterID] [int] NOT NULL,
	[ShareID] [int] NOT NULL,
 CONSTRAINT [PK_RegisterLessonSharing] PRIMARY KEY CLUSTERED 
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResetPassword]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResetPassword](
	[ResetID] [uniqueidentifier] NOT NULL,
	[UID] [int] NOT NULL,
 CONSTRAINT [PK_ResetPassword] PRIMARY KEY CLUSTERED 
(
	[ResetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SalaryDetails]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalaryDetails](
	[SalaryID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[PermanentWage] [int] NULL,
	[ApprenticeWage] [int] NULL,
	[CommissionGrade] [decimal](18, 2) NULL,
	[AnnualGrade] [decimal](18, 2) NULL,
	[EmploymentGradeIndex] [int] NULL,
 CONSTRAINT [PK_SalaryDetails] PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServingCoachProperty]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServingCoachProperty](
	[CoachID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_ServingCoachProperty] PRIMARY KEY CLUSTERED 
(
	[CoachID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StyleAboutPDQ]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StyleAboutPDQ](
	[StyleID] [int] NOT NULL,
	[Style] [nvarchar](64) NULL,
 CONSTRAINT [PK_StyleAboutPDQ] PRIMARY KEY CLUSTERED 
(
	[StyleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SystemEventBulletin]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemEventBulletin](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](256) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[ActionName] [nvarchar](64) NULL,
	[ControllerName] [nvarchar](32) NULL,
	[PopupContent] [nvarchar](64) NULL,
 CONSTRAINT [PK_SystemEventBulletin] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TmpSalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TmpSalary](
	[CoachID] [int] NULL,
	[SettlementID] [int] NULL,
	[員工姓名] [nvarchar](64) NULL,
	[薪資] [int] NULL,
	[伙食津貼] [int] NULL,
	[職務加給] [int] NULL,
	[自願提繳] [int] NULL,
	[勞保費] [int] NULL,
	[健保費] [int] NULL,
	[上課獎金] [int] NULL,
	[業績獎金] [int] NULL,
	[特別獎金] [int] NULL,
	[管理獎金] [int] NULL,
	[所得稅] [int] NULL,
	[二代健保] [int] NULL,
	[職福金] [int] NULL,
	[應收金額] [int] NULL,
	[備註] [nvarchar](256) NULL,
	[病假(半薪)] [int] NULL,
	[事假(無薪)] [int] NULL,
	[公司提撥退休金] [int] NULL,
	[公司提撥勞保費] [int] NULL,
	[公司提撥健保費] [int] NULL,
	[備註二] [nvarchar](256) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingAids]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingAids](
	[AidID] [int] IDENTITY(1,1) NOT NULL,
	[ItemName] [nvarchar](16) NOT NULL,
	[StageID] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TrainingAids] PRIMARY KEY CLUSTERED 
(
	[AidID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingExecution]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingExecution](
	[ExecutionID] [int] NOT NULL,
	[BreakIntervalInSecond] [nvarchar](32) NULL,
	[Repeats] [nvarchar](32) NULL,
	[ActualBreakIntervalInSecond] [int] NULL,
	[ActualRepeats] [int] NULL,
	[Conclusion] [nvarchar](max) NULL,
	[ExecutionFeedBack] [nvarchar](max) NULL,
	[ExecutionFeedBackDate] [datetime] NULL,
	[Emphasis] [nvarchar](32) NULL,
 CONSTRAINT [PK_TrainingExecution] PRIMARY KEY CLUSTERED 
(
	[ExecutionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingExecutionStage]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingExecutionStage](
	[ExecutionID] [int] NOT NULL,
	[StageID] [int] NOT NULL,
	[TotalMinutes] [decimal](6, 2) NULL,
 CONSTRAINT [PK_TrainingExecutionStage] PRIMARY KEY CLUSTERED 
(
	[ExecutionID] ASC,
	[StageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[TrainingID] [int] NULL,
	[GoalTurns] [nvarchar](512) NULL,
	[GoalStrength] [nvarchar](512) NULL,
	[ExecutionID] [int] NOT NULL,
	[Description] [nvarchar](512) NULL,
	[ActualStrength] [nvarchar](512) NULL,
	[ActualTurns] [nvarchar](512) NULL,
	[Remark] [nvarchar](512) NULL,
	[BreakIntervalInSecond] [nvarchar](32) NULL,
	[Repeats] [nvarchar](32) NULL,
	[Sequence] [int] NULL,
	[ExecutionFeedBack] [nvarchar](max) NULL,
	[ExecutionFeedBackDate] [datetime] NULL,
	[DurationInMinutes] [decimal](6, 2) NULL,
	[PurposeID] [int] NULL,
 CONSTRAINT [PK_TrainingItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingItemAids]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingItemAids](
	[ItemID] [int] NOT NULL,
	[AidID] [int] NOT NULL,
 CONSTRAINT [PK_TrainingItemAids] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC,
	[AidID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingLevelAboutPDQ]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingLevelAboutPDQ](
	[LevelID] [int] NOT NULL,
	[TrainingLevel] [nvarchar](64) NULL,
 CONSTRAINT [PK_TrainingLevelAboutPDQ] PRIMARY KEY CLUSTERED 
(
	[LevelID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingPlan]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingPlan](
	[LessonID] [int] NOT NULL,
	[ExecutionID] [int] IDENTITY(1,1) NOT NULL,
	[PlanStatus] [int] NULL,
	[RegisterID] [int] NULL,
 CONSTRAINT [PK_TrainingPlan_1] PRIMARY KEY CLUSTERED 
(
	[ExecutionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingStage]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingStage](
	[StageID] [int] NOT NULL,
	[Stage] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_TrainingStage] PRIMARY KEY CLUSTERED 
(
	[StageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingStageItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingStageItem](
	[TrainingID] [int] NOT NULL,
	[StageID] [int] NOT NULL,
 CONSTRAINT [PK_TrainingStageItem] PRIMARY KEY CLUSTERED 
(
	[TrainingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TrainingType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TrainingType](
	[TrainingID] [int] IDENTITY(1,1) NOT NULL,
	[BodyParts] [nvarchar](16) NULL,
	[BreakMark] [bit] NULL,
	[OrderIndex] [int] NULL,
 CONSTRAINT [PK_TrainingType] PRIMARY KEY CLUSTERED 
(
	[TrainingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TuitionInstallment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TuitionInstallment](
	[InstallmentID] [int] NOT NULL,
	[RegisterID] [int] NOT NULL,
	[PayoffAmount] [int] NULL,
	[PayoffDate] [datetime] NULL,
 CONSTRAINT [PK_TuitionInstallment] PRIMARY KEY CLUSTERED 
(
	[InstallmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UniformInvoiceWinningNumber]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniformInvoiceWinningNumber](
	[WinningID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Period] [int] NOT NULL,
	[Rank] [int] NOT NULL,
	[WinningNO] [nvarchar](16) NOT NULL,
	[PrizeType] [nvarchar](16) NULL,
	[Bonus] [int] NULL,
 CONSTRAINT [PK_UniformInvoiceWinningNumber] PRIMARY KEY CLUSTERED 
(
	[WinningID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UsageType]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsageType](
	[UsageID] [int] NOT NULL,
	[Usage] [nvarchar](64) NULL,
 CONSTRAINT [PK_UsageType] PRIMARY KEY CLUSTERED 
(
	[UsageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserContractStatistic]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserContractStatistic](
	[UID] [int] NOT NULL,
	[ContractID] [int] NOT NULL,
	[FirstClassTime] [datetime] NULL,
	[LastClassTime] [datetime] NULL,
	[AttendanceCount] [int] NULL,
 CONSTRAINT [PK_UserContractStatistic] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[ContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserEvent]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserEvent](
	[EventID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[Title] [nvarchar](256) NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[ActivityProgram] [nvarchar](256) NULL,
	[Accompanist] [nvarchar](256) NULL,
	[BranchID] [int] NULL,
	[EventType] [int] NULL,
	[SystemEventID] [int] NULL,
	[Place] [nvarchar](64) NULL,
 CONSTRAINT [PK_UserEvent] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserEventCommitment]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserEventCommitment](
	[EventID] [int] NOT NULL,
	[CommitmentDate] [datetime] NOT NULL,
 CONSTRAINT [PK_UserEventCommitment] PRIMARY KEY CLUSTERED 
(
	[EventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfileProperty]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileProperty](
	[UID] [int] NOT NULL,
	[PropertyID] [int] NOT NULL,
	[CommitmentDate] [datetime] NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_UserProfileProperty] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfileRegistration]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileRegistration](
	[UID] [int] NOT NULL,
	[RegistrationDate] [datetime] NOT NULL,
	[BranchID] [int] NOT NULL,
 CONSTRAINT [PK_UserProfileRegistration] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[RegistrationDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfileStatistic]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfileStatistic](
	[UID] [int] NOT NULL,
	[Cohort_PayoffAmount] [int] NULL,
	[InitDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[TenureInDays] [int] NULL,
	[AvgContractLifeDays] [float] NULL,
	[TotalContractCount] [int] NULL,
	[ExpectedContractCount] [int] NULL,
	[RenewalRate] [float] NULL,
	[CohortValue] [decimal](18, 6) NULL,
	[TotalLessonCount] [int] NULL,
	[TotalContractCost] [int] NULL,
	[AvgLessonTimeExpense] [float] NULL,
	[LearnerBRCount] [int] NULL,
	[CoachBRCount] [int] NULL,
	[BranchID] [int] NULL,
	[AdvisorCoach] [int] NULL,
	[LastContractDate] [datetime] NULL,
	[EffectiveContractCount] [int] NULL,
	[LastClassTime] [datetime] NULL,
	[CountryID] [int] NULL,
	[LastAttendingCoach] [int] NULL,
	[CurrentTrial] [int] NULL,
	[TotalAttendanceCount] [int] NULL,
	[LastCompleteDate] [datetime] NULL,
 CONSTRAINT [PK_UserProfileStatistic] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRelationship]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRelationship](
	[LeaderID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[Memo] [nvarchar](16) NULL,
	[RelationFor] [int] NULL,
 CONSTRAINT [PK_UserRelationship_1] PRIMARY KEY CLUSTERED 
(
	[LeaderID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[UID] [int] NOT NULL,
	[RoleID] [int] NOT NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRoleDefinition]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoleDefinition](
	[RoleID] [int] NOT NULL,
	[SiteMenu] [nvarchar](64) NULL,
	[Role] [nvarchar](16) NOT NULL,
 CONSTRAINT [PK_UserRoleDefinition] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [IX_UserRoleDefinition] UNIQUE NONCLUSTERED 
(
	[Role] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserSignature]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSignature](
	[SignatureID] [int] IDENTITY(1,1) NOT NULL,
	[UID] [int] NOT NULL,
	[Signature] [nvarchar](max) NULL,
 CONSTRAINT [PK_UserSignature] PRIMARY KEY CLUSTERED 
(
	[SignatureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VacantInvoiceNo]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VacantInvoiceNo](
	[VacancyID] [int] IDENTITY(1,1) NOT NULL,
	[IntervalID] [int] NOT NULL,
	[InvoiceNo] [int] NOT NULL,
	[PrevID] [int] NULL,
	[NextID] [int] NULL,
 CONSTRAINT [PK_VacantInvoiceNo] PRIMARY KEY CLUSTERED 
(
	[VacancyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VoidPaymentLevel]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VoidPaymentLevel](
	[VoidID] [int] NOT NULL,
	[LevelDate] [datetime] NOT NULL,
	[ExecutorID] [int] NOT NULL,
	[LevelID] [int] NOT NULL,
 CONSTRAINT [PK_VoidPaymentLevel] PRIMARY KEY CLUSTERED 
(
	[VoidID] ASC,
	[LevelDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyBranchIndicator]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyBranchIndicator](
	[PeriodID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[RiskPrediction] [nvarchar](max) NULL,
	[Strategy] [nvarchar](max) NULL,
	[Comment] [nvarchar](max) NULL,
 CONSTRAINT [PK_MonthlyBranchIndicator] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyBranchRevenueGoal]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyBranchRevenueGoal](
	[PeriodID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[GradeID] [int] NOT NULL,
	[ActualLessonAchievement] [int] NULL,
	[ActualSharedAchievement] [int] NULL,
	[ActualCompleteLessonCount] [int] NULL,
	[CustomIndicatorPercentage] [decimal](18, 2) NULL,
	[CustomRevenueGoal] [int] NULL,
	[AchievementGoal] [int] NULL,
	[CompleteLessonsGoal] [int] NULL,
	[LessonTuitionGoal] [int] NULL,
	[NewContractCount] [int] NULL,
	[RenewContractCount] [int] NULL,
	[ActualCompleteTSCount] [int] NULL,
	[ActualCompletePICount] [int] NULL,
	[NewContractSubtotal] [int] NULL,
	[RenewContractSubtotal] [int] NULL,
	[InstallmentCount] [int] NULL,
	[InstallmentSubtotal] [int] NULL,
	[NewContractAchievement] [int] NULL,
	[RenewContractAchievement] [int] NULL,
	[InstallmentAchievement] [int] NULL,
	[VoidShare] [int] NULL,
	[ATCount] [int] NULL,
	[ATAchievement] [int] NULL,
	[SRCount] [int] NULL,
	[SRAchievement] [int] NULL,
	[SDCount] [int] NULL,
	[SDAchievement] [int] NULL,
	[LessonTuitionIndicatorPercentage] [decimal](18, 2) NULL,
	[SRLessonsGoal] [int] NULL,
	[SRLessonTuitionGoal] [int] NULL,
	[GroupXCount] [int] NULL,
	[GroupXAchievement] [int] NULL,
 CONSTRAINT [PK_MonthlyBranchRevenueGoal] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[BranchID] ASC,
	[GradeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyBranchRevenueIndicator]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyBranchRevenueIndicator](
	[PeriodID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[GradeID] [int] NOT NULL,
	[RevenueGoal] [int] NOT NULL,
 CONSTRAINT [PK_MonthlyBranchRevenueIndicator] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[BranchID] ASC,
	[GradeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyCoachLearnerReview]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyCoachLearnerReview](
	[PeriodID] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
	[AdvisingCountWithContract] [int] NULL,
	[AdvisingCountNoContract] [int] NULL,
	[ConductingCount] [int] NULL,
	[AttendanceRate] [decimal](6, 2) NULL,
 CONSTRAINT [PK_MonthlyCoachLearnerReview] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyCoachRevenueIndicator]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyCoachRevenueIndicator](
	[PeriodID] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
	[AchievementGoal] [int] NULL,
	[CompleteLessonsGoal] [int] NULL,
	[AverageLessonPrice] [int] NULL,
	[LessonTuitionGoal] [int] NULL,
	[BranchID] [int] NULL,
	[ActualCompleteLessonCount] [int] NULL,
	[ActualSharedPIAchievement] [int] NULL,
	[ActualSharedMerchandiseAchievement] [int] NULL,
	[ActualNewContractAchievement] [int] NULL,
	[ActualRenewContractAchievement] [int] NULL,
	[ActualLessonAchievement] [int] NULL,
	[LevelID] [int] NULL,
	[ActualCompleteTSCount] [int] NULL,
	[ActualCompletePICount] [int] NULL,
	[BRCount] [int] NULL,
	[STCount] [int] NULL,
	[RenewContractCount] [int] NULL,
	[NewContractCount] [int] NULL,
	[NewContractSubtotal] [int] NULL,
	[RenewContractSubtotal] [int] NULL,
	[InstallmentCount] [int] NULL,
	[InstallmentSubtotal] [int] NULL,
	[InstallmentAchievement] [int] NULL,
	[VoidShare] [int] NULL,
	[ATCount] [int] NULL,
	[ATAchievement] [int] NULL,
	[SRCount] [int] NULL,
	[SRAchievement] [int] NULL,
	[SDCount] [int] NULL,
	[SDAchievement] [int] NULL,
	[AcademicGrades] [int] NULL,
	[TechnicalGrades] [int] NULL,
	[ActualBRCount] [int] NULL,
	[PTCount] [int] NULL,
	[DealedCountWithBR] [int] NULL,
	[TrialDealedCount] [int] NULL,
	[BRTrialCount] [int] NULL,
	[ExamTrialCount] [int] NULL,
	[AdjustActualBRCount] [int] NULL,
	[AdjustDealedCountWithBR] [int] NULL,
	[AdjustTrialDealedCount] [int] NULL,
	[GroupXCount] [int] NULL,
	[GroupXAchievement] [int] NULL,
 CONSTRAINT [PK_MonthlyCoachRevenuIndicator] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyIndicator]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyIndicator](
	[PeriodID] [int] IDENTITY(1,1) NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndExclusiveDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonthlyIndicator] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyLearnerReview]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyLearnerReview](
	[PeriodID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[Attendance] [bit] NULL,
 CONSTRAINT [PK_MonthlyLearnerReview] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyRevenueGoal]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyRevenueGoal](
	[PeriodID] [int] NOT NULL,
	[GradeID] [int] NOT NULL,
	[CustomIndicatorPercentage] [decimal](18, 2) NULL,
	[CustomRevenueGoal] [int] NULL,
	[ActualLessonAchievement] [int] NULL,
	[ActualSharedAchievement] [int] NULL,
	[ActualCompleteLessonCount] [int] NULL,
	[AchievementGoal] [int] NULL,
	[CompleteLessonsGoal] [int] NULL,
	[LessonTuitionGoal] [int] NULL,
	[NewContractCount] [int] NULL,
	[RenewContractCount] [int] NULL,
	[ActualCompleteTSCount] [int] NULL,
	[ActualCompletePICount] [int] NULL,
	[NewContractSubtotal] [int] NULL,
	[RenewContractSubtotal] [int] NULL,
	[InstallmentCount] [int] NULL,
	[InstallmentSubtotal] [int] NULL,
	[NewContractAchievement] [int] NULL,
	[RenewContractAchievement] [int] NULL,
	[InstallmentAchievement] [int] NULL,
	[VoidShare] [int] NULL,
	[ATCount] [int] NULL,
	[ATAchievement] [int] NULL,
	[SRCount] [int] NULL,
	[SRAchievement] [int] NULL,
	[SDCount] [int] NULL,
	[SDAchievement] [int] NULL,
	[LessonTuitionIndicatorPercentage] [decimal](18, 2) NULL,
	[SRLessonsGoal] [int] NULL,
	[SRLessonTuitionGoal] [int] NULL,
	[GroupXCount] [int] NULL,
	[GroupXAchievement] [int] NULL,
 CONSTRAINT [PK_MonthlyRevenueGoal] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[GradeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyRevenueGrade]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyRevenueGrade](
	[GradeID] [int] NOT NULL,
	[IndicatorPercentage] [int] NOT NULL,
	[Description] [nvarchar](16) NULL,
 CONSTRAINT [PK_MonthlyRevenueGrade] PRIMARY KEY CLUSTERED 
(
	[GradeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [KPI].[MonthlyRevenueIndicator]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [KPI].[MonthlyRevenueIndicator](
	[PeriodID] [int] NOT NULL,
	[GradeID] [int] NOT NULL,
	[RevenueGoal] [int] NOT NULL,
 CONSTRAINT [PK_MonthlyRevenueIndicator] PRIMARY KEY CLUSTERED 
(
	[PeriodID] ASC,
	[GradeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Project].[ObjectiveContractLessonPrice]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Project].[ObjectiveContractLessonPrice](
	[ContractType] [int] NOT NULL,
	[PriceID] [int] NOT NULL,
 CONSTRAINT [PK_ObjectiveContractLessonPrice_1] PRIMARY KEY CLUSTERED 
(
	[ContractType] ASC,
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Project].[ObjectiveLessonCatalog]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Project].[ObjectiveLessonCatalog](
	[CatalogID] [int] NOT NULL,
	[Description] [nvarchar](64) NULL,
 CONSTRAINT [PK_ObjectiveLessonCatalog] PRIMARY KEY CLUSTERED 
(
	[CatalogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Project].[ObjectiveLessonLocation]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Project].[ObjectiveLessonLocation](
	[CatalogID] [int] NOT NULL,
	[BranchID] [int] NOT NULL,
	[PreferredUrl] [nvarchar](1024) NULL,
 CONSTRAINT [PK_ObjectiveLessonLocation] PRIMARY KEY CLUSTERED 
(
	[CatalogID] ASC,
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Project].[ObjectiveLessonPrice]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Project].[ObjectiveLessonPrice](
	[CatalogID] [int] NOT NULL,
	[PriceID] [int] NOT NULL,
 CONSTRAINT [PK_ObjectiveLessonPrice] PRIMARY KEY CLUSTERED 
(
	[CatalogID] ASC,
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[CoachYearlyAdditionalPay]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[CoachYearlyAdditionalPay](
	[Year] [int] NOT NULL,
	[CoachID] [int] NOT NULL,
	[WorkPlace] [int] NULL,
	[LevelID] [int] NOT NULL,
	[GradeIndex] [decimal](18, 2) NOT NULL,
	[ManagerBonus] [int] NULL,
	[SpecialBonus] [int] NULL,
	[AttendanceBonus] [int] NULL,
	[AchievementBonus] [int] NULL,
	[AchievementShareRatio] [decimal](18, 2) NULL,
 CONSTRAINT [PK_CoachYearlyAdditionalPay] PRIMARY KEY CLUSTERED 
(
	[Year] ASC,
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[EmployeeSalaryExtension]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[EmployeeSalaryExtension](
	[UID] [int] NOT NULL,
	[DutyAllowance] [int] NULL,
 CONSTRAINT [PK_EmployeeSalaryExtension] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[MonthlySalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[MonthlySalary](
	[SalaryID] [int] IDENTITY(1,1) NOT NULL,
	[Payday] [date] NULL,
	[SalaryType] [int] NULL,
 CONSTRAINT [PK_MonthlySalary] PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[MonthlySalaryDetails]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[MonthlySalaryDetails](
	[SalaryID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[SettlementID] [int] NULL,
	[Salary] [int] NULL,
	[SalaryDutyAllowance] [int] NULL,
	[Subsistence] [int] NULL,
	[SpecialBonus] [int] NULL,
	[WillingContribution] [int] NULL,
	[LaborInsurrance] [int] NULL,
	[HealthInsurrance] [int] NULL,
	[Tax] [int] NULL,
	[ActualAmount] [int] NULL,
	[Remark] [nvarchar](256) NULL,
	[SickLeave] [int] NULL,
	[PersonalLeave] [int] NULL,
	[EpidemicPL] [int] NULL,
	[BasicWage] [int] NULL,
	[DutyAllowance] [int] NULL,
	[HealthSupplement] [int] NULL,
	[LaborInsurranceByEmployer] [int] NULL,
	[HealthInsurranceByEmployer] [int] NULL,
	[Pension] [int] NULL,
	[StaffWelfareFund] [int] NULL,
	[AchievementBonus] [int] NULL,
	[AttendanceBonus] [int] NULL,
	[AchievementRemark] [nvarchar](256) NULL,
	[ManagementBonus] [int] NULL,
 CONSTRAINT [PK_MonthlySalaryDetails] PRIMARY KEY CLUSTERED 
(
	[SalaryID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[PromptLessonQuestion]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[PromptLessonQuestion](
	[LessonID] [int] NOT NULL,
	[UID] [int] NOT NULL,
	[TaskID] [int] NULL,
 CONSTRAINT [PK_PromptLessonQuestion] PRIMARY KEY CLUSTERED 
(
	[LessonID] ASC,
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Report].[PromptLessonRequirement]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Report].[PromptLessonRequirement](
	[PriceID] [int] NOT NULL,
	[RequiredCount] [int] NULL,
 CONSTRAINT [PK_PromptLessonRequirement] PRIMARY KEY CLUSTERED 
(
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[BeyondHelp]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[BeyondHelp](
	[HelpID] [int] NOT NULL,
	[Achievement] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_BeyondHelp] PRIMARY KEY CLUSTERED 
(
	[HelpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[ContactTime]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[ContactTime](
	[UID] [int] NOT NULL,
	[TimeID] [int] NOT NULL,
 CONSTRAINT [PK_ContactTime] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[TimeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[HealthcareInstitution]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[HealthcareInstitution](
	[HID] [int] NOT NULL,
	[Institution] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_HealthcareInstitution] PRIMARY KEY CLUSTERED 
(
	[HID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[HowToKnow]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[HowToKnow](
	[UID] [int] NOT NULL,
	[MediaID] [int] NOT NULL,
 CONSTRAINT [PK_HowToKnow] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[MediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[MediaPlatform]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[MediaPlatform](
	[MediaID] [int] NOT NULL,
	[Platform] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_MediaPlatform] PRIMARY KEY CLUSTERED 
(
	[MediaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[ReferralFrom]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[ReferralFrom](
	[UID] [int] NOT NULL,
	[HID] [int] NOT NULL,
 CONSTRAINT [PK_ReferralFrom] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[HID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [tmp].[TrialLearner]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[TrialLearner](
	[UID] [int] IDENTITY(1,1) NOT NULL,
	[Gender] [nvarchar](8) NULL,
	[UserName] [nvarchar](40) NULL,
	[Email] [nvarchar](64) NULL,
	[Phone] [nvarchar](32) NULL,
	[BranchID] [int] NOT NULL,
	[Question] [nvarchar](max) NULL,
	[SubmitDate] [datetime] NULL,
	[NormalUID] [int] NULL,
	[AssigneeID] [int] NULL,
	[AttendingCoach] [int] NULL,
	[Status] [int] NULL,
	[AssignDate] [datetime] NULL,
	[ReserveDate] [datetime] NULL,
	[IsClosed] [bit] NULL,
	[ContactSupplement] [nvarchar](512) NULL,
	[AssignmentSupplement] [nvarchar](512) NULL,
 CONSTRAINT [PK_TrialLearner] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [tmp].[TrialLearnerPurpose]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tmp].[TrialLearnerPurpose](
	[UID] [int] NOT NULL,
	[HelpID] [int] NOT NULL,
 CONSTRAINT [PK_TrialLearnerPurpose] PRIMARY KEY CLUSTERED 
(
	[UID] ASC,
	[HelpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_BonusYearlyBalance]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_BonusYearlyBalance] ON [BG].[BonusYearlyBalance]
(
	[UID] ASC,
	[Year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FeedbackSurveyType]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_FeedbackSurveyType] ON [BG].[FeedbackSurveyType]
(
	[QuestionNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonMissionBonusAwardingItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LessonMissionBonusAwardingItem] ON [BG].[LessonMissionBonusAwardingItem]
(
	[MissionID] ASC,
	[PriceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StageProgress]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_StageProgress] ON [BG].[StageProgress]
(
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StageProgress_EndDate]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_StageProgress_EndDate] ON [BG].[StageProgress]
(
	[EndExclusiveDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_BlogArticle]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_BlogArticle] ON [dbo].[BlogArticle]
(
	[BlogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BlogArticle_NotAfter]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_BlogArticle_NotAfter] ON [dbo].[BlogArticle]
(
	[NotAfter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CourseContract]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_CourseContract] ON [dbo].[CourseContract]
(
	[ContractNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseContract_FitnessConsultant]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_CourseContract_FitnessConsultant] ON [dbo].[CourseContract]
(
	[FitnessConsultant] ASC
)
INCLUDE([ContractID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseContract_Lessons_IntallmentID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_CourseContract_Lessons_IntallmentID] ON [dbo].[CourseContract]
(
	[Status] ASC
)
INCLUDE([ContractID],[Lessons],[InstallmentID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CourseContractMember_UID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_CourseContractMember_UID] ON [dbo].[CourseContractMember]
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CourseContractRevision]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_CourseContractRevision] ON [dbo].[CourseContractRevision]
(
	[Reason] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DocumentPrintLog_DocID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_DocumentPrintLog_DocID] ON [dbo].[DocumentPrintLog]
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ForEmployee]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_ForEmployee] ON [dbo].[ForEmployee]
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InvoiceItem]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InvoiceItem] ON [dbo].[InvoiceItem]
(
	[TrackCode] ASC,
	[No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InvoiceItem_InvoiceType_PrintMark]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_InvoiceItem_InvoiceType_PrintMark] ON [dbo].[InvoiceItem]
(
	[InvoiceType] ASC,
	[PrintMark] ASC
)
INCLUDE([InvoiceID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LearnerCoachProperty_CoachID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LearnerCoachProperty_CoachID] ON [dbo].[LearnerCoachProperty]
(
	[CoachID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LearnerCoachProperty_PropertyID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LearnerCoachProperty_PropertyID] ON [dbo].[LearnerCoachProperty]
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LearnerCoachProperty_UID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LearnerCoachProperty_UID] ON [dbo].[LearnerCoachProperty]
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonComment]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonComment] ON [dbo].[LessonComment]
(
	[CommentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTime_AttendingCoach]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTime_AttendingCoach] ON [dbo].[LessonTime]
(
	[AttendingCoach] ASC
)
INCLUDE([RegisterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTime_AttendingCoach_BranchID_ClassTime]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTime_AttendingCoach_BranchID_ClassTime] ON [dbo].[LessonTime]
(
	[AttendingCoach] ASC,
	[BranchID] ASC,
	[ClassTime] ASC
)
INCLUDE([LessonID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTime_ClassTime]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTime_ClassTime] ON [dbo].[LessonTime]
(
	[ClassTime] ASC
)
INCLUDE([LessonID],[RegisterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTime_ClassTime_GroupID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTime_ClassTime_GroupID] ON [dbo].[LessonTime]
(
	[ClassTime] ASC
)
INCLUDE([GroupID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTime_GroupID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTime_GroupID] ON [dbo].[LessonTime]
(
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LessonTime_RegisterID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_LessonTime_RegisterID] ON [dbo].[LessonTime]
(
	[RegisterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Payment_TransactionType]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_Payment_TransactionType] ON [dbo].[Payment]
(
	[TransactionType] ASC
)
INCLUDE([PaymentID],[PayoffAmount],[PayoffDate],[Status],[HandlerID],[PaymentType],[InvoiceID],[Remark],[AllowanceID],[AdjustmentAmount]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PDQQuestionExtension]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_PDQQuestionExtension] ON [dbo].[PDQQuestionExtension]
(
	[AwardingAction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RegisterLesson_ClassLevel_RegisterID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_RegisterLesson_ClassLevel_RegisterID] ON [dbo].[RegisterLesson]
(
	[ClassLevel] ASC
)
INCLUDE([RegisterID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RegisterLesson_G1]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_RegisterLesson_G1] ON [dbo].[RegisterLesson]
(
	[Attended] ASC,
	[RegisterGroupID] ASC
)
INCLUDE([RegisterID],[Lessons],[UID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RegisterLesson_G2]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_RegisterLesson_G2] ON [dbo].[RegisterLesson]
(
	[UID] ASC,
	[RegisterGroupID] ASC
)
INCLUDE([RegisterID],[Lessons],[Attended]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_RegisterLesson_RegisterGroupID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_RegisterLesson_RegisterGroupID] ON [dbo].[RegisterLesson]
(
	[RegisterGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TrainingItem_ExecutionID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_TrainingItem_ExecutionID] ON [dbo].[TrainingItem]
(
	[ExecutionID] ASC
)
INCLUDE([ItemID],[TrainingID],[GoalTurns],[GoalStrength],[Description],[ActualStrength],[ActualTurns],[Remark],[BreakIntervalInSecond],[Repeats],[Sequence],[ExecutionFeedBack],[ExecutionFeedBackDate],[DurationInMinutes],[PurposeID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TrainingPlan_LessonID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_TrainingPlan_LessonID] ON [dbo].[TrainingPlan]
(
	[LessonID] ASC
)
INCLUDE([ExecutionID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TuitionInstallment_RegisterID]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_TuitionInstallment_RegisterID] ON [dbo].[TuitionInstallment]
(
	[RegisterID] ASC
)
INCLUDE([InstallmentID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserProfile_1]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfile_1] ON [dbo].[UserProfile]
(
	[ExternalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserProfile_2]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfile_2] ON [dbo].[UserProfile]
(
	[Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserProfileExtension]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfileExtension] ON [dbo].[UserProfileExtension]
(
	[IDNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserProfileExtension_1]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE NONCLUSTERED INDEX [IX_UserProfileExtension_1] ON [dbo].[UserProfileExtension]
(
	[LineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_MonthlyIndicator]    Script Date: 2026/5/16 上午 11:05:08 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_MonthlyIndicator] ON [KPI].[MonthlyIndicator]
(
	[Year] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [BG].[BonusDepositAccount] ADD  CONSTRAINT [DF_BonusDepositAccount_DepositAmount]  DEFAULT ((0)) FOR [DepositPoint]
GO
ALTER TABLE [BG].[CampaignMissionBonus] ADD  CONSTRAINT [DF_CampaignMissionBonus_CompleteDate]  DEFAULT (getdate()) FOR [CompleteDate]
GO
ALTER TABLE [dbo].[ContractTrustSettlement] ADD  CONSTRAINT [DF_ContractTrustSettlement_InitialTrustAmount]  DEFAULT ((0)) FOR [InitialTrustAmount]
GO
ALTER TABLE [dbo].[Document] ADD  CONSTRAINT [DF_Document_DocDate]  DEFAULT (getdate()) FOR [DocDate]
GO
ALTER TABLE [dbo].[DocumentPrintQueue] ADD  CONSTRAINT [DF_DocumentPrintQueue_SubmitDate_1]  DEFAULT (getdate()) FOR [SubmitDate]
GO
ALTER TABLE [dbo].[EnterpriseCourseContract] ADD  CONSTRAINT [DF_EnterpriseCourseContract_GroupingMemberCount]  DEFAULT ((1)) FOR [GroupingMemberCount]
GO
ALTER TABLE [dbo].[RegisterLesson] ADD  CONSTRAINT [DF_RegisterLesson_RegisterDate]  DEFAULT (getdate()) FOR [RegisterDate]
GO
ALTER TABLE [BG].[AwardingItemCategory]  WITH CHECK ADD  CONSTRAINT [FK_AwardingItemCategory_BonusAwardingItem] FOREIGN KEY([ItemID])
REFERENCES [BG].[BonusAwardingItem] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[AwardingItemCategory] CHECK CONSTRAINT [FK_AwardingItemCategory_BonusAwardingItem]
GO
ALTER TABLE [BG].[AwardingItemCategory]  WITH CHECK ADD  CONSTRAINT [FK_AwardingItemCategory_MerchandiseTransactionType] FOREIGN KEY([TransactionID])
REFERENCES [dbo].[MerchandiseTransactionType] ([TransactionID])
GO
ALTER TABLE [BG].[AwardingItemCategory] CHECK CONSTRAINT [FK_AwardingItemCategory_MerchandiseTransactionType]
GO
ALTER TABLE [BG].[AwardingLesson]  WITH CHECK ADD  CONSTRAINT [FK_AwardingLesson_LearnerAward] FOREIGN KEY([AwardID])
REFERENCES [BG].[LearnerAward] ([AwardID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[AwardingLesson] CHECK CONSTRAINT [FK_AwardingLesson_LearnerAward]
GO
ALTER TABLE [BG].[AwardingLesson]  WITH CHECK ADD  CONSTRAINT [FK_AwardingLesson_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
GO
ALTER TABLE [BG].[AwardingLesson] CHECK CONSTRAINT [FK_AwardingLesson_RegisterLesson]
GO
ALTER TABLE [BG].[AwardingLessonGift]  WITH CHECK ADD  CONSTRAINT [FK_AwardingLessonGift_LearnerAward] FOREIGN KEY([AwardID])
REFERENCES [BG].[LearnerAward] ([AwardID])
GO
ALTER TABLE [BG].[AwardingLessonGift] CHECK CONSTRAINT [FK_AwardingLessonGift_LearnerAward]
GO
ALTER TABLE [BG].[AwardingLessonGift]  WITH CHECK ADD  CONSTRAINT [FK_AwardingLessonGift_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
GO
ALTER TABLE [BG].[AwardingLessonGift] CHECK CONSTRAINT [FK_AwardingLessonGift_RegisterLesson]
GO
ALTER TABLE [BG].[BonusAwardingIndication]  WITH CHECK ADD  CONSTRAINT [FK_BonusAwardingIndication_BonusAwardingItem] FOREIGN KEY([ItemID])
REFERENCES [BG].[BonusAwardingItem] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusAwardingIndication] CHECK CONSTRAINT [FK_BonusAwardingIndication_BonusAwardingItem]
GO
ALTER TABLE [BG].[BonusAwardingItemProperty]  WITH CHECK ADD  CONSTRAINT [FK_BonusAwardingItemProperty_BonusAwardingItem] FOREIGN KEY([ItemID])
REFERENCES [BG].[BonusAwardingItem] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusAwardingItemProperty] CHECK CONSTRAINT [FK_BonusAwardingItemProperty_BonusAwardingItem]
GO
ALTER TABLE [BG].[BonusAwardingLesson]  WITH CHECK ADD  CONSTRAINT [FK_BonusAwardingLesson_BonusAwardingItem] FOREIGN KEY([ItemID])
REFERENCES [BG].[BonusAwardingItem] ([ItemID])
GO
ALTER TABLE [BG].[BonusAwardingLesson] CHECK CONSTRAINT [FK_BonusAwardingLesson_BonusAwardingItem]
GO
ALTER TABLE [BG].[BonusAwardingLesson]  WITH CHECK ADD  CONSTRAINT [FK_BonusAwardingLesson_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [BG].[BonusAwardingLesson] CHECK CONSTRAINT [FK_BonusAwardingLesson_LessonPriceType]
GO
ALTER TABLE [BG].[BonusDepositAccount]  WITH CHECK ADD  CONSTRAINT [FK_BonusDepositAccount_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusDepositAccount] CHECK CONSTRAINT [FK_BonusDepositAccount_UserProfile]
GO
ALTER TABLE [BG].[BonusDepositSettlement]  WITH CHECK ADD  CONSTRAINT [FK_BonusDepositSettlement_BonusDepositAccount] FOREIGN KEY([UID])
REFERENCES [BG].[BonusDepositAccount] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusDepositSettlement] CHECK CONSTRAINT [FK_BonusDepositSettlement_BonusDepositAccount]
GO
ALTER TABLE [BG].[BonusDepositSettlement]  WITH CHECK ADD  CONSTRAINT [FK_BonusDepositSettlement_BonusTransaction] FOREIGN KEY([TransactionID])
REFERENCES [BG].[BonusTransaction] ([TransactionID])
GO
ALTER TABLE [BG].[BonusDepositSettlement] CHECK CONSTRAINT [FK_BonusDepositSettlement_BonusTransaction]
GO
ALTER TABLE [BG].[BonusExchange]  WITH CHECK ADD  CONSTRAINT [FK_BonusExchange_LearnerAward] FOREIGN KEY([AwardID])
REFERENCES [BG].[LearnerAward] ([AwardID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusExchange] CHECK CONSTRAINT [FK_BonusExchange_LearnerAward]
GO
ALTER TABLE [BG].[BonusExchange]  WITH CHECK ADD  CONSTRAINT [FK_BonusExchange_PDQTaskBonus] FOREIGN KEY([TaskID])
REFERENCES [dbo].[PDQTaskBonus] ([TaskID])
GO
ALTER TABLE [BG].[BonusExchange] CHECK CONSTRAINT [FK_BonusExchange_PDQTaskBonus]
GO
ALTER TABLE [BG].[BonusTransaction]  WITH CHECK ADD  CONSTRAINT [FK_BonusTransaction_BonusDepositAccount] FOREIGN KEY([UID])
REFERENCES [BG].[BonusDepositAccount] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusTransaction] CHECK CONSTRAINT [FK_BonusTransaction_BonusDepositAccount]
GO
ALTER TABLE [BG].[BonusTransaction]  WITH CHECK ADD  CONSTRAINT [FK_BonusTransaction_BonusYearlyBalance] FOREIGN KEY([BalanceID])
REFERENCES [BG].[BonusYearlyBalance] ([BalanceID])
GO
ALTER TABLE [BG].[BonusTransaction] CHECK CONSTRAINT [FK_BonusTransaction_BonusYearlyBalance]
GO
ALTER TABLE [BG].[BonusTransaction]  WITH CHECK ADD  CONSTRAINT [FK_BonusTransaction_CampaignMissionBonus] FOREIGN KEY([BonusID])
REFERENCES [BG].[CampaignMissionBonus] ([BonusID])
GO
ALTER TABLE [BG].[BonusTransaction] CHECK CONSTRAINT [FK_BonusTransaction_CampaignMissionBonus]
GO
ALTER TABLE [BG].[BonusTransaction]  WITH CHECK ADD  CONSTRAINT [FK_BonusTransaction_LearnerAward] FOREIGN KEY([AwardID])
REFERENCES [BG].[LearnerAward] ([AwardID])
GO
ALTER TABLE [BG].[BonusTransaction] CHECK CONSTRAINT [FK_BonusTransaction_LearnerAward]
GO
ALTER TABLE [BG].[BonusYearlyBalance]  WITH CHECK ADD  CONSTRAINT [FK_BonusYearlyBalance_BonusYearlySettlement] FOREIGN KEY([UID], [Year])
REFERENCES [BG].[BonusYearlySettlement] ([UID], [Year])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusYearlyBalance] CHECK CONSTRAINT [FK_BonusYearlyBalance_BonusYearlySettlement]
GO
ALTER TABLE [BG].[BonusYearlySettlement]  WITH CHECK ADD  CONSTRAINT [FK_BonusYearlySettlement_BonusDepositAccount] FOREIGN KEY([UID])
REFERENCES [BG].[BonusDepositAccount] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[BonusYearlySettlement] CHECK CONSTRAINT [FK_BonusYearlySettlement_BonusDepositAccount]
GO
ALTER TABLE [BG].[BonusYearlySettlement]  WITH CHECK ADD  CONSTRAINT [FK_BonusYearlySettlement_YearlySettlement] FOREIGN KEY([Year])
REFERENCES [dbo].[YearlySettlement] ([Year])
GO
ALTER TABLE [BG].[BonusYearlySettlement] CHECK CONSTRAINT [FK_BonusYearlySettlement_YearlySettlement]
GO
ALTER TABLE [BG].[FeedbackSurvey]  WITH CHECK ADD  CONSTRAINT [FK_FeedbackSurvey_LevelExpression] FOREIGN KEY([QuestionType])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [BG].[FeedbackSurvey] CHECK CONSTRAINT [FK_FeedbackSurvey_LevelExpression]
GO
ALTER TABLE [BG].[FeedbackSurveyType]  WITH CHECK ADD  CONSTRAINT [FK_FeedbackSurveyType_FeedbackSurvey] FOREIGN KEY([QuestionID])
REFERENCES [BG].[FeedbackSurvey] ([QuestionID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[FeedbackSurveyType] CHECK CONSTRAINT [FK_FeedbackSurveyType_FeedbackSurvey]
GO
ALTER TABLE [BG].[FeedbackSurveyType]  WITH CHECK ADD  CONSTRAINT [FK_FeedbackSurveyType_LevelExpression] FOREIGN KEY([ClassType])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [BG].[FeedbackSurveyType] CHECK CONSTRAINT [FK_FeedbackSurveyType_LevelExpression]
GO
ALTER TABLE [BG].[GameLevelRequirement]  WITH CHECK ADD  CONSTRAINT [FK_GameLevelRequirement_CampaignMission] FOREIGN KEY([MissionID])
REFERENCES [BG].[CampaignMission] ([MissionID])
GO
ALTER TABLE [BG].[GameLevelRequirement] CHECK CONSTRAINT [FK_GameLevelRequirement_CampaignMission]
GO
ALTER TABLE [BG].[GameLevelRequirement]  WITH CHECK ADD  CONSTRAINT [FK_GameLevelRequirement_GameLevel] FOREIGN KEY([LevelID])
REFERENCES [BG].[GameLevel] ([LevelID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[GameLevelRequirement] CHECK CONSTRAINT [FK_GameLevelRequirement_GameLevel]
GO
ALTER TABLE [BG].[GameLevelReward]  WITH CHECK ADD  CONSTRAINT [FK_GameLevelReward_GameLevel] FOREIGN KEY([LevelID])
REFERENCES [BG].[GameLevel] ([LevelID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[GameLevelReward] CHECK CONSTRAINT [FK_GameLevelReward_GameLevel]
GO
ALTER TABLE [BG].[LearnerAward]  WITH CHECK ADD  CONSTRAINT [FK_LearnerAward_BonusAwardingItem] FOREIGN KEY([ItemID])
REFERENCES [BG].[BonusAwardingItem] ([ItemID])
GO
ALTER TABLE [BG].[LearnerAward] CHECK CONSTRAINT [FK_LearnerAward_BonusAwardingItem]
GO
ALTER TABLE [BG].[LearnerAward]  WITH CHECK ADD  CONSTRAINT [FK_LearnerAward_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [BG].[LearnerAward] CHECK CONSTRAINT [FK_LearnerAward_UserProfile]
GO
ALTER TABLE [BG].[LearnerAward]  WITH CHECK ADD  CONSTRAINT [FK_LearnerAward_UserProfile1] FOREIGN KEY([ActorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [BG].[LearnerAward] CHECK CONSTRAINT [FK_LearnerAward_UserProfile1]
GO
ALTER TABLE [BG].[LessonFeedbackSurvey]  WITH CHECK ADD  CONSTRAINT [FK_LessonFeedbackSurvey_FeedbackSurvey] FOREIGN KEY([QuestionID])
REFERENCES [BG].[FeedbackSurvey] ([QuestionID])
GO
ALTER TABLE [BG].[LessonFeedbackSurvey] CHECK CONSTRAINT [FK_LessonFeedbackSurvey_FeedbackSurvey]
GO
ALTER TABLE [BG].[LessonFeedbackSurvey]  WITH CHECK ADD  CONSTRAINT [FK_LessonFeedbackSurvey_LessonFeedBack] FOREIGN KEY([LessonID], [RegisterID])
REFERENCES [dbo].[LessonFeedBack] ([LessonID], [RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[LessonFeedbackSurvey] CHECK CONSTRAINT [FK_LessonFeedbackSurvey_LessonFeedBack]
GO
ALTER TABLE [BG].[LessonMissionBonus]  WITH CHECK ADD  CONSTRAINT [FK_LessonMissionBonus_CampaignMissionBonus] FOREIGN KEY([BonusID])
REFERENCES [BG].[CampaignMissionBonus] ([BonusID])
GO
ALTER TABLE [BG].[LessonMissionBonus] CHECK CONSTRAINT [FK_LessonMissionBonus_CampaignMissionBonus]
GO
ALTER TABLE [BG].[LessonMissionBonus]  WITH CHECK ADD  CONSTRAINT [FK_LessonMissionBonus_LessonFeedBack] FOREIGN KEY([LessonID], [RegisterID])
REFERENCES [dbo].[LessonFeedBack] ([LessonID], [RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[LessonMissionBonus] CHECK CONSTRAINT [FK_LessonMissionBonus_LessonFeedBack]
GO
ALTER TABLE [BG].[LessonMissionBonus]  WITH CHECK ADD  CONSTRAINT [FK_LessonMissionBonus_LessonMissionBonusAwardingItem] FOREIGN KEY([ItemID])
REFERENCES [BG].[LessonMissionBonusAwardingItem] ([ItemID])
GO
ALTER TABLE [BG].[LessonMissionBonus] CHECK CONSTRAINT [FK_LessonMissionBonus_LessonMissionBonusAwardingItem]
GO
ALTER TABLE [BG].[LessonMissionBonusAwardingItem]  WITH CHECK ADD  CONSTRAINT [FK_LessonMissionBonusAwardingItem_CampaignMission] FOREIGN KEY([MissionID])
REFERENCES [BG].[CampaignMission] ([MissionID])
GO
ALTER TABLE [BG].[LessonMissionBonusAwardingItem] CHECK CONSTRAINT [FK_LessonMissionBonusAwardingItem_CampaignMission]
GO
ALTER TABLE [BG].[LessonMissionBonusAwardingItem]  WITH CHECK ADD  CONSTRAINT [FK_LessonMissionBonusAwardingItem_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [BG].[LessonMissionBonusAwardingItem] CHECK CONSTRAINT [FK_LessonMissionBonusAwardingItem_LessonPriceType]
GO
ALTER TABLE [BG].[LessonSelfAssessment]  WITH CHECK ADD  CONSTRAINT [FK_LessonSelfAssessment_LessonFeedBack] FOREIGN KEY([LessonID], [RegisterID])
REFERENCES [dbo].[LessonFeedBack] ([LessonID], [RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[LessonSelfAssessment] CHECK CONSTRAINT [FK_LessonSelfAssessment_LessonFeedBack]
GO
ALTER TABLE [BG].[Player]  WITH CHECK ADD  CONSTRAINT [FK_Player_GameLevel] FOREIGN KEY([PlayerLevel])
REFERENCES [BG].[GameLevel] ([LevelID])
GO
ALTER TABLE [BG].[Player] CHECK CONSTRAINT [FK_Player_GameLevel]
GO
ALTER TABLE [BG].[Player]  WITH CHECK ADD  CONSTRAINT [FK_Player_StageProgress] FOREIGN KEY([ProgressID])
REFERENCES [BG].[StageProgress] ([ProgressID])
GO
ALTER TABLE [BG].[Player] CHECK CONSTRAINT [FK_Player_StageProgress]
GO
ALTER TABLE [BG].[Player]  WITH CHECK ADD  CONSTRAINT [FK_Player_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[Player] CHECK CONSTRAINT [FK_Player_UserProfile]
GO
ALTER TABLE [BG].[TipsArticleRelation]  WITH CHECK ADD  CONSTRAINT [FK_TipsArticleRelation_BlogArticle] FOREIGN KEY([DocID])
REFERENCES [dbo].[BlogArticle] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [BG].[TipsArticleRelation] CHECK CONSTRAINT [FK_TipsArticleRelation_BlogArticle]
GO
ALTER TABLE [BG].[TipsArticleRelation]  WITH CHECK ADD  CONSTRAINT [FK_TipsArticleRelation_ExerciseTips] FOREIGN KEY([TipsID])
REFERENCES [BG].[ExerciseTips] ([TipsID])
GO
ALTER TABLE [BG].[TipsArticleRelation] CHECK CONSTRAINT [FK_TipsArticleRelation_ExerciseTips]
GO
ALTER TABLE [dbo].[Article]  WITH CHECK ADD  CONSTRAINT [FK_Article_Attachment] FOREIGN KEY([Illustration])
REFERENCES [dbo].[Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[Article] CHECK CONSTRAINT [FK_Article_Attachment]
GO
ALTER TABLE [dbo].[Article]  WITH CHECK ADD  CONSTRAINT [FK_Article_Document] FOREIGN KEY([DocID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Article] CHECK CONSTRAINT [FK_Article_Document]
GO
ALTER TABLE [dbo].[Article]  WITH CHECK ADD  CONSTRAINT [FK_Article_UserProfile] FOREIGN KEY([AuthorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[Article] CHECK CONSTRAINT [FK_Article_UserProfile]
GO
ALTER TABLE [dbo].[Attachment]  WITH CHECK ADD  CONSTRAINT [FK_Attachment_Document] FOREIGN KEY([DocID])
REFERENCES [dbo].[Document] ([DocID])
GO
ALTER TABLE [dbo].[Attachment] CHECK CONSTRAINT [FK_Attachment_Document]
GO
ALTER TABLE [dbo].[BlogArticle]  WITH CHECK ADD  CONSTRAINT [FK_BlogArticle_Document] FOREIGN KEY([DocID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BlogArticle] CHECK CONSTRAINT [FK_BlogArticle_Document]
GO
ALTER TABLE [dbo].[BlogArticle]  WITH CHECK ADD  CONSTRAINT [FK_BlogArticle_UserProfile] FOREIGN KEY([AuthorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[BlogArticle] CHECK CONSTRAINT [FK_BlogArticle_UserProfile]
GO
ALTER TABLE [dbo].[BlogCategoryLocale]  WITH CHECK ADD  CONSTRAINT [FK_BlogCategoryLocale_BlogCategoryDefinition] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[BlogCategoryDefinition] ([CategoryID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BlogCategoryLocale] CHECK CONSTRAINT [FK_BlogCategoryLocale_BlogCategoryDefinition]
GO
ALTER TABLE [dbo].[BlogTag]  WITH CHECK ADD  CONSTRAINT [FK_BlogTag_BlogArticle] FOREIGN KEY([DocID])
REFERENCES [dbo].[BlogArticle] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BlogTag] CHECK CONSTRAINT [FK_BlogTag_BlogArticle]
GO
ALTER TABLE [dbo].[BlogTag]  WITH CHECK ADD  CONSTRAINT [FK_BlogTag_BlogCategoryDefinition] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[BlogCategoryDefinition] ([CategoryID])
GO
ALTER TABLE [dbo].[BlogTag] CHECK CONSTRAINT [FK_BlogTag_BlogCategoryDefinition]
GO
ALTER TABLE [dbo].[BodyDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_BodyDiagnosis_LevelExpression] FOREIGN KEY([LevelID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[BodyDiagnosis] CHECK CONSTRAINT [FK_BodyDiagnosis_LevelExpression]
GO
ALTER TABLE [dbo].[BodyDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_BodyDiagnosis_UserProfile] FOREIGN KEY([LearnerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[BodyDiagnosis] CHECK CONSTRAINT [FK_BodyDiagnosis_UserProfile]
GO
ALTER TABLE [dbo].[BodyDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_BodyDiagnosis_UserProfile1] FOREIGN KEY([CoachID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[BodyDiagnosis] CHECK CONSTRAINT [FK_BodyDiagnosis_UserProfile1]
GO
ALTER TABLE [dbo].[BodySuffering]  WITH CHECK ADD  CONSTRAINT [FK_BodySuffering_BodyDiagnosis] FOREIGN KEY([DiagnosisID])
REFERENCES [dbo].[BodyDiagnosis] ([DiagnosisID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BodySuffering] CHECK CONSTRAINT [FK_BodySuffering_BodyDiagnosis]
GO
ALTER TABLE [dbo].[BodySuffering]  WITH CHECK ADD  CONSTRAINT [FK_BodySuffering_BodyParts] FOREIGN KEY([PartID])
REFERENCES [dbo].[BodyParts] ([PartID])
GO
ALTER TABLE [dbo].[BodySuffering] CHECK CONSTRAINT [FK_BodySuffering_BodyParts]
GO
ALTER TABLE [dbo].[BranchStore]  WITH CHECK ADD  CONSTRAINT [FK_BranchStore_Organization] FOREIGN KEY([BranchID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[BranchStore] CHECK CONSTRAINT [FK_BranchStore_Organization]
GO
ALTER TABLE [dbo].[BranchStore]  WITH NOCHECK ADD  CONSTRAINT [FK_BranchStore_UserProfile] FOREIGN KEY([ManagerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[BranchStore] CHECK CONSTRAINT [FK_BranchStore_UserProfile]
GO
ALTER TABLE [dbo].[BranchStore]  WITH NOCHECK ADD  CONSTRAINT [FK_BranchStore_UserProfile1] FOREIGN KEY([ViceManagerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[BranchStore] CHECK CONSTRAINT [FK_BranchStore_UserProfile1]
GO
ALTER TABLE [dbo].[CoachCertificate]  WITH CHECK ADD  CONSTRAINT [FK_CoachCertificate_Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CoachCertificate] CHECK CONSTRAINT [FK_CoachCertificate_Attachment]
GO
ALTER TABLE [dbo].[CoachCertificate]  WITH CHECK ADD  CONSTRAINT [FK_CoachCertificate_ProfessionalCertificate] FOREIGN KEY([CertificateID])
REFERENCES [dbo].[ProfessionalCertificate] ([CertificateID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoachCertificate] CHECK CONSTRAINT [FK_CoachCertificate_ProfessionalCertificate]
GO
ALTER TABLE [dbo].[CoachCertificate]  WITH CHECK ADD  CONSTRAINT [FK_CoachCertificate_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[CoachCertificate] CHECK CONSTRAINT [FK_CoachCertificate_ServingCoach]
GO
ALTER TABLE [dbo].[CoachCertificate]  WITH CHECK ADD  CONSTRAINT [FK_CoachCertificate_UserProfile] FOREIGN KEY([ApprovedBy])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CoachCertificate] CHECK CONSTRAINT [FK_CoachCertificate_UserProfile]
GO
ALTER TABLE [dbo].[CoachRating]  WITH CHECK ADD  CONSTRAINT [FK_CoachRating_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [dbo].[CoachRating] CHECK CONSTRAINT [FK_CoachRating_ProfessionalLevel]
GO
ALTER TABLE [dbo].[CoachRating]  WITH CHECK ADD  CONSTRAINT [FK_CoachRating_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoachRating] CHECK CONSTRAINT [FK_CoachRating_ServingCoach]
GO
ALTER TABLE [dbo].[CoachWorkplace]  WITH CHECK ADD  CONSTRAINT [FK_CoachWorkplace_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[CoachWorkplace] CHECK CONSTRAINT [FK_CoachWorkplace_BranchStore]
GO
ALTER TABLE [dbo].[CoachWorkplace]  WITH CHECK ADD  CONSTRAINT [FK_CoachWorkplace_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CoachWorkplace] CHECK CONSTRAINT [FK_CoachWorkplace_ServingCoach]
GO
ALTER TABLE [dbo].[ContractElement]  WITH CHECK ADD  CONSTRAINT [FK_ContractElement_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractElement] CHECK CONSTRAINT [FK_ContractElement_CourseContract]
GO
ALTER TABLE [dbo].[ContractElement]  WITH CHECK ADD  CONSTRAINT [FK_ContractElement_CourseContractRevision] FOREIGN KEY([RevisionID])
REFERENCES [dbo].[CourseContractRevision] ([RevisionID])
GO
ALTER TABLE [dbo].[ContractElement] CHECK CONSTRAINT [FK_ContractElement_CourseContractRevision]
GO
ALTER TABLE [dbo].[ContractElement]  WITH CHECK ADD  CONSTRAINT [FK_ContractElement_ServingCoach] FOREIGN KEY([OriginalFitnessConsultant])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[ContractElement] CHECK CONSTRAINT [FK_ContractElement_ServingCoach]
GO
ALTER TABLE [dbo].[ContractMonthlySummary]  WITH CHECK ADD  CONSTRAINT [FK_ContractMonthlySummary_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractMonthlySummary] CHECK CONSTRAINT [FK_ContractMonthlySummary_CourseContract]
GO
ALTER TABLE [dbo].[ContractPayment]  WITH CHECK ADD  CONSTRAINT [FK_ContractPayment_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractPayment] CHECK CONSTRAINT [FK_ContractPayment_CourseContract]
GO
ALTER TABLE [dbo].[ContractPayment]  WITH NOCHECK ADD  CONSTRAINT [FK_ContractPayment_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractPayment] CHECK CONSTRAINT [FK_ContractPayment_Payment]
GO
ALTER TABLE [dbo].[ContractTrustSettlement]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustSettlement_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
GO
ALTER TABLE [dbo].[ContractTrustSettlement] CHECK CONSTRAINT [FK_ContractTrustSettlement_CourseContract]
GO
ALTER TABLE [dbo].[ContractTrustSettlement]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustSettlement_Settlement] FOREIGN KEY([SettlementID])
REFERENCES [dbo].[Settlement] ([SettlementID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractTrustSettlement] CHECK CONSTRAINT [FK_ContractTrustSettlement_Settlement]
GO
ALTER TABLE [dbo].[ContractTrustTrack]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustTrack_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractTrustTrack] CHECK CONSTRAINT [FK_ContractTrustTrack_CourseContract]
GO
ALTER TABLE [dbo].[ContractTrustTrack]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustTrack_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractTrustTrack] CHECK CONSTRAINT [FK_ContractTrustTrack_LessonTime]
GO
ALTER TABLE [dbo].[ContractTrustTrack]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustTrack_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ContractTrustTrack] CHECK CONSTRAINT [FK_ContractTrustTrack_Payment]
GO
ALTER TABLE [dbo].[ContractTrustTrack]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustTrack_Settlement] FOREIGN KEY([SettlementID])
REFERENCES [dbo].[Settlement] ([SettlementID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[ContractTrustTrack] CHECK CONSTRAINT [FK_ContractTrustTrack_Settlement]
GO
ALTER TABLE [dbo].[ContractTrustTrack]  WITH CHECK ADD  CONSTRAINT [FK_ContractTrustTrack_VoidPayment] FOREIGN KEY([VoidID])
REFERENCES [dbo].[VoidPayment] ([VoidID])
GO
ALTER TABLE [dbo].[ContractTrustTrack] CHECK CONSTRAINT [FK_ContractTrustTrack_VoidPayment]
GO
ALTER TABLE [dbo].[CourseContract]  WITH CHECK ADD  CONSTRAINT [FK_CourseContract_ContractInstallment] FOREIGN KEY([InstallmentID])
REFERENCES [dbo].[ContractInstallment] ([InstallmentID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_ContractInstallment]
GO
ALTER TABLE [dbo].[CourseContract]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContract_CourseContractType] FOREIGN KEY([ContractType])
REFERENCES [dbo].[CourseContractType] ([TypeID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_CourseContractType]
GO
ALTER TABLE [dbo].[CourseContract]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContract_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_LessonPriceType]
GO
ALTER TABLE [dbo].[CourseContract]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContract_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_LevelExpression]
GO
ALTER TABLE [dbo].[CourseContract]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContract_ServingCoach] FOREIGN KEY([FitnessConsultant])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_ServingCoach]
GO
ALTER TABLE [dbo].[CourseContract]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContract_UserProfile] FOREIGN KEY([OwnerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_UserProfile]
GO
ALTER TABLE [dbo].[CourseContract]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContract_UserProfile1] FOREIGN KEY([AgentID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_UserProfile1]
GO
ALTER TABLE [dbo].[CourseContract]  WITH CHECK ADD  CONSTRAINT [FK_CourseContract_UserProfile2] FOREIGN KEY([SupervisorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContract] CHECK CONSTRAINT [FK_CourseContract_UserProfile2]
GO
ALTER TABLE [dbo].[CourseContractAction]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractAction_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractAction] CHECK CONSTRAINT [FK_CourseContractAction_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[Attachment] ([AttachmentID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_Attachment]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_BranchStore]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_BranchStore1] FOREIGN KEY([CoursePlace])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_BranchStore1]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_CourseContractRevision] FOREIGN KEY([RevisionTrackingID])
REFERENCES [dbo].[CourseContractRevision] ([RevisionID])
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_CourseContractRevision]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_LessonPriceType] FOREIGN KEY([UnitPriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_LessonPriceType]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_UserProfile] FOREIGN KEY([BRByLearner])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_UserProfile]
GO
ALTER TABLE [dbo].[CourseContractExtension]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractExtension_UserProfile1] FOREIGN KEY([BRByCoach])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContractExtension] CHECK CONSTRAINT [FK_CourseContractExtension_UserProfile1]
GO
ALTER TABLE [dbo].[CourseContractLessonExchange]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractLessonExchange_CourseContractRevision] FOREIGN KEY([RevisionID])
REFERENCES [dbo].[CourseContractRevision] ([RevisionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractLessonExchange] CHECK CONSTRAINT [FK_CourseContractLessonExchange_CourseContractRevision]
GO
ALTER TABLE [dbo].[CourseContractLessonExchange]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractLessonExchange_LessonPriceType] FOREIGN KEY([TargetPriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[CourseContractLessonExchange] CHECK CONSTRAINT [FK_CourseContractLessonExchange_LessonPriceType]
GO
ALTER TABLE [dbo].[CourseContractLessonExchange]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractLessonExchange_RegisterLessonContract1] FOREIGN KEY([TargetRegisterID])
REFERENCES [dbo].[RegisterLessonContract] ([RegisterID])
GO
ALTER TABLE [dbo].[CourseContractLessonExchange] CHECK CONSTRAINT [FK_CourseContractLessonExchange_RegisterLessonContract1]
GO
ALTER TABLE [dbo].[CourseContractLevel]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractLevel_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractLevel] CHECK CONSTRAINT [FK_CourseContractLevel_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractLevel]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractLevel_LevelExpression] FOREIGN KEY([LevelID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[CourseContractLevel] CHECK CONSTRAINT [FK_CourseContractLevel_LevelExpression]
GO
ALTER TABLE [dbo].[CourseContractLevel]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractLevel_UserProfile] FOREIGN KEY([ExecutorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContractLevel] CHECK CONSTRAINT [FK_CourseContractLevel_UserProfile]
GO
ALTER TABLE [dbo].[CourseContractMember]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractMember_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractMember] CHECK CONSTRAINT [FK_CourseContractMember_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractMember]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContractMember_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[CourseContractMember] CHECK CONSTRAINT [FK_CourseContractMember_UserProfile]
GO
ALTER TABLE [dbo].[CourseContractOrder]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractOrder_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractOrder] CHECK CONSTRAINT [FK_CourseContractOrder_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractOrder]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractOrder_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[CourseContractOrder] CHECK CONSTRAINT [FK_CourseContractOrder_LessonPriceType]
GO
ALTER TABLE [dbo].[CourseContractRevision]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractRevision_Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CourseContractRevision] CHECK CONSTRAINT [FK_CourseContractRevision_Attachment]
GO
ALTER TABLE [dbo].[CourseContractRevision]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContractRevision_CourseContract] FOREIGN KEY([RevisionID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractRevision] CHECK CONSTRAINT [FK_CourseContractRevision_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractRevision]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContractRevision_CourseContract1] FOREIGN KEY([OriginalContract])
REFERENCES [dbo].[CourseContract] ([ContractID])
GO
ALTER TABLE [dbo].[CourseContractRevision] CHECK CONSTRAINT [FK_CourseContractRevision_CourseContract1]
GO
ALTER TABLE [dbo].[CourseContractRevisionItem]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractRevisionItem_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[CourseContractRevisionItem] CHECK CONSTRAINT [FK_CourseContractRevisionItem_BranchStore]
GO
ALTER TABLE [dbo].[CourseContractRevisionItem]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractRevisionItem_CourseContractRevision] FOREIGN KEY([RevisionID])
REFERENCES [dbo].[CourseContractRevision] ([RevisionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractRevisionItem] CHECK CONSTRAINT [FK_CourseContractRevisionItem_CourseContractRevision]
GO
ALTER TABLE [dbo].[CourseContractRevisionItem]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractRevisionItem_ServingCoach] FOREIGN KEY([FitnessConsultant])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[CourseContractRevisionItem] CHECK CONSTRAINT [FK_CourseContractRevisionItem_ServingCoach]
GO
ALTER TABLE [dbo].[CourseContractSignature]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractSignature_CourseContractMember] FOREIGN KEY([ContractID], [UID])
REFERENCES [dbo].[CourseContractMember] ([ContractID], [UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractSignature] CHECK CONSTRAINT [FK_CourseContractSignature_CourseContractMember]
GO
ALTER TABLE [dbo].[CourseContractStatistic]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractStatistic_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractStatistic] CHECK CONSTRAINT [FK_CourseContractStatistic_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractTermination]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractTermination_Attachment] FOREIGN KEY([AccountInfo])
REFERENCES [dbo].[Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[CourseContractTermination] CHECK CONSTRAINT [FK_CourseContractTermination_Attachment]
GO
ALTER TABLE [dbo].[CourseContractTermination]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractTermination_CourseContractRevision] FOREIGN KEY([RevisionID])
REFERENCES [dbo].[CourseContractRevision] ([RevisionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractTermination] CHECK CONSTRAINT [FK_CourseContractTermination_CourseContractRevision]
GO
ALTER TABLE [dbo].[CourseContractTrust]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractTrust_ContractTrustSettlement] FOREIGN KEY([ContractID], [CurrentSettlement])
REFERENCES [dbo].[ContractTrustSettlement] ([ContractID], [SettlementID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractTrust] CHECK CONSTRAINT [FK_CourseContractTrust_ContractTrustSettlement]
GO
ALTER TABLE [dbo].[CourseContractTrust]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractTrust_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CourseContractTrust] CHECK CONSTRAINT [FK_CourseContractTrust_CourseContract]
GO
ALTER TABLE [dbo].[CourseContractType]  WITH NOCHECK ADD  CONSTRAINT [FK_CourseContractType_GroupingLessonDiscount] FOREIGN KEY([GroupingMemberCount])
REFERENCES [dbo].[GroupingLessonDiscount] ([GroupingMemberCount])
GO
ALTER TABLE [dbo].[CourseContractType] CHECK CONSTRAINT [FK_CourseContractType_GroupingLessonDiscount]
GO
ALTER TABLE [dbo].[CourseContractView]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractView_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[CourseContractView] CHECK CONSTRAINT [FK_CourseContractView_BranchStore]
GO
ALTER TABLE [dbo].[CourseContractView]  WITH CHECK ADD  CONSTRAINT [FK_CourseContractView_CourseContractType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[CourseContractType] ([TypeID])
GO
ALTER TABLE [dbo].[CourseContractView] CHECK CONSTRAINT [FK_CourseContractView_CourseContractType]
GO
ALTER TABLE [dbo].[DerivedDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_DerivedDocument_Document] FOREIGN KEY([DocID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DerivedDocument] CHECK CONSTRAINT [FK_DerivedDocument_Document]
GO
ALTER TABLE [dbo].[DerivedDocument]  WITH NOCHECK ADD  CONSTRAINT [FK_DerivedDocument_Document1] FOREIGN KEY([SourceID])
REFERENCES [dbo].[Document] ([DocID])
GO
ALTER TABLE [dbo].[DerivedDocument] CHECK CONSTRAINT [FK_DerivedDocument_Document1]
GO
ALTER TABLE [dbo].[DiagnosisAssessment]  WITH CHECK ADD  CONSTRAINT [FK_DiagnosisAssessment_BodyDiagnosis] FOREIGN KEY([DiagnosisID])
REFERENCES [dbo].[BodyDiagnosis] ([DiagnosisID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DiagnosisAssessment] CHECK CONSTRAINT [FK_DiagnosisAssessment_BodyDiagnosis]
GO
ALTER TABLE [dbo].[DiagnosisAssessment]  WITH CHECK ADD  CONSTRAINT [FK_DiagnosisAssessment_FitnessAssessmentItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[FitnessAssessmentItem] ([ItemID])
GO
ALTER TABLE [dbo].[DiagnosisAssessment] CHECK CONSTRAINT [FK_DiagnosisAssessment_FitnessAssessmentItem]
GO
ALTER TABLE [dbo].[DiagnosisJudgement]  WITH CHECK ADD  CONSTRAINT [FK_DiagnosisJudgement_FitnessDiagnosis] FOREIGN KEY([FitnessID])
REFERENCES [dbo].[FitnessDiagnosis] ([FitnessID])
GO
ALTER TABLE [dbo].[DiagnosisJudgement] CHECK CONSTRAINT [FK_DiagnosisJudgement_FitnessDiagnosis]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_DocumentType] FOREIGN KEY([DocType])
REFERENCES [dbo].[DocumentType] ([TypeID])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_DocumentType]
GO
ALTER TABLE [dbo].[Document]  WITH CHECK ADD  CONSTRAINT [FK_Document_LevelExpression] FOREIGN KEY([CurrentStep])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[Document] CHECK CONSTRAINT [FK_Document_LevelExpression]
GO
ALTER TABLE [dbo].[DocumentPrintLog]  WITH CHECK ADD  CONSTRAINT [FK_DocumentPrintLog_Document] FOREIGN KEY([DocID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocumentPrintLog] CHECK CONSTRAINT [FK_DocumentPrintLog_Document]
GO
ALTER TABLE [dbo].[DocumentPrintLog]  WITH CHECK ADD  CONSTRAINT [FK_DocumentPrintLog_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[DocumentPrintLog] CHECK CONSTRAINT [FK_DocumentPrintLog_UserProfile]
GO
ALTER TABLE [dbo].[DocumentPrintQueue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentPrintQueue_Document] FOREIGN KEY([DocID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocumentPrintQueue] CHECK CONSTRAINT [FK_DocumentPrintQueue_Document]
GO
ALTER TABLE [dbo].[DocumentPrintQueue]  WITH CHECK ADD  CONSTRAINT [FK_DocumentPrintQueue_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocumentPrintQueue] CHECK CONSTRAINT [FK_DocumentPrintQueue_UserProfile]
GO
ALTER TABLE [dbo].[EmployeeWelfare]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeWelfare_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EmployeeWelfare] CHECK CONSTRAINT [FK_EmployeeWelfare_UserProfile]
GO
ALTER TABLE [dbo].[EnterpriseCourseContent]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseContent_EnterpriseCourseContract1] FOREIGN KEY([ContractID])
REFERENCES [dbo].[EnterpriseCourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseCourseContent] CHECK CONSTRAINT [FK_EnterpriseCourseContent_EnterpriseCourseContract1]
GO
ALTER TABLE [dbo].[EnterpriseCourseContent]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseContent_EnterpriseLessonType] FOREIGN KEY([TypeID])
REFERENCES [dbo].[EnterpriseLessonType] ([TypeID])
GO
ALTER TABLE [dbo].[EnterpriseCourseContent] CHECK CONSTRAINT [FK_EnterpriseCourseContent_EnterpriseLessonType]
GO
ALTER TABLE [dbo].[EnterpriseCourseContract]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseContract_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[EnterpriseCourseContract] CHECK CONSTRAINT [FK_EnterpriseCourseContract_BranchStore]
GO
ALTER TABLE [dbo].[EnterpriseCourseContract]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseContract_Organization] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[EnterpriseCourseContract] CHECK CONSTRAINT [FK_EnterpriseCourseContract_Organization]
GO
ALTER TABLE [dbo].[EnterpriseCourseMember]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseMember_EnterpriseCourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[EnterpriseCourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseCourseMember] CHECK CONSTRAINT [FK_EnterpriseCourseMember_EnterpriseCourseContract]
GO
ALTER TABLE [dbo].[EnterpriseCourseMember]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseMember_GroupingLesson] FOREIGN KEY([GroupID])
REFERENCES [dbo].[GroupingLesson] ([GroupID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[EnterpriseCourseMember] CHECK CONSTRAINT [FK_EnterpriseCourseMember_GroupingLesson]
GO
ALTER TABLE [dbo].[EnterpriseCourseMember]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCourseMember_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[EnterpriseCourseMember] CHECK CONSTRAINT [FK_EnterpriseCourseMember_UserProfile]
GO
ALTER TABLE [dbo].[EnterpriseCoursePayment]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCoursePayment_EnterpriseCourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[EnterpriseCourseContract] ([ContractID])
GO
ALTER TABLE [dbo].[EnterpriseCoursePayment] CHECK CONSTRAINT [FK_EnterpriseCoursePayment_EnterpriseCourseContract]
GO
ALTER TABLE [dbo].[EnterpriseCoursePayment]  WITH CHECK ADD  CONSTRAINT [FK_EnterpriseCoursePayment_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[EnterpriseCoursePayment] CHECK CONSTRAINT [FK_EnterpriseCoursePayment_Payment]
GO
ALTER TABLE [dbo].[ExerciseGameContestant]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGameContestant_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExerciseGameContestant] CHECK CONSTRAINT [FK_ExerciseGameContestant_UserProfile]
GO
ALTER TABLE [dbo].[ExerciseGamePersonalRank]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGamePersonalRank_ExerciseGameContestant] FOREIGN KEY([UID])
REFERENCES [dbo].[ExerciseGameContestant] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExerciseGamePersonalRank] CHECK CONSTRAINT [FK_ExerciseGamePersonalRank_ExerciseGameContestant]
GO
ALTER TABLE [dbo].[ExerciseGameRank]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGameRank_ExerciseGameContestant] FOREIGN KEY([UID])
REFERENCES [dbo].[ExerciseGameContestant] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExerciseGameRank] CHECK CONSTRAINT [FK_ExerciseGameRank_ExerciseGameContestant]
GO
ALTER TABLE [dbo].[ExerciseGameRank]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGameRank_ExerciseGameItem] FOREIGN KEY([ExerciseID])
REFERENCES [dbo].[ExerciseGameItem] ([ExerciseID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExerciseGameRank] CHECK CONSTRAINT [FK_ExerciseGameRank_ExerciseGameItem]
GO
ALTER TABLE [dbo].[ExerciseGameRank]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGameRank_ExerciseGameResult] FOREIGN KEY([RecordID])
REFERENCES [dbo].[ExerciseGameResult] ([TestID])
GO
ALTER TABLE [dbo].[ExerciseGameRank] CHECK CONSTRAINT [FK_ExerciseGameRank_ExerciseGameResult]
GO
ALTER TABLE [dbo].[ExerciseGameResult]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGameResult_ExerciseGameContestant] FOREIGN KEY([UID])
REFERENCES [dbo].[ExerciseGameContestant] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExerciseGameResult] CHECK CONSTRAINT [FK_ExerciseGameResult_ExerciseGameContestant]
GO
ALTER TABLE [dbo].[ExerciseGameResult]  WITH CHECK ADD  CONSTRAINT [FK_ExerciseGameResult_ExerciseGameItem] FOREIGN KEY([ExerciseID])
REFERENCES [dbo].[ExerciseGameItem] ([ExerciseID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExerciseGameResult] CHECK CONSTRAINT [FK_ExerciseGameResult_ExerciseGameItem]
GO
ALTER TABLE [dbo].[FavoriteLesson]  WITH CHECK ADD  CONSTRAINT [FK_FavoriteLesson_TrainingPlan] FOREIGN KEY([ExecutionID])
REFERENCES [dbo].[TrainingPlan] ([ExecutionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FavoriteLesson] CHECK CONSTRAINT [FK_FavoriteLesson_TrainingPlan]
GO
ALTER TABLE [dbo].[FavoriteLesson]  WITH CHECK ADD  CONSTRAINT [FK_FavoriteLesson_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[FavoriteLesson] CHECK CONSTRAINT [FK_FavoriteLesson_UserProfile]
GO
ALTER TABLE [dbo].[FitnessAssessment]  WITH CHECK ADD  CONSTRAINT [FK_FitnessAssessment_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FitnessAssessment] CHECK CONSTRAINT [FK_FitnessAssessment_LessonTime]
GO
ALTER TABLE [dbo].[FitnessAssessmentGroup]  WITH CHECK ADD  CONSTRAINT [FK_FitnessAssessmentGroup_FitnessAssessmentItem] FOREIGN KEY([MajorID])
REFERENCES [dbo].[FitnessAssessmentItem] ([ItemID])
GO
ALTER TABLE [dbo].[FitnessAssessmentGroup] CHECK CONSTRAINT [FK_FitnessAssessmentGroup_FitnessAssessmentItem]
GO
ALTER TABLE [dbo].[FitnessAssessmentItem]  WITH CHECK ADD  CONSTRAINT [FK_FitnessAssessmentItem_FitnessAssessmentGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[FitnessAssessmentGroup] ([GroupID])
GO
ALTER TABLE [dbo].[FitnessAssessmentItem] CHECK CONSTRAINT [FK_FitnessAssessmentItem_FitnessAssessmentGroup]
GO
ALTER TABLE [dbo].[FitnessDiagnosis]  WITH CHECK ADD  CONSTRAINT [FK_FitnessDiagnosis_FitnessAssessmentItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[FitnessAssessmentItem] ([ItemID])
GO
ALTER TABLE [dbo].[FitnessDiagnosis] CHECK CONSTRAINT [FK_FitnessDiagnosis_FitnessAssessmentItem]
GO
ALTER TABLE [dbo].[ForEmployee]  WITH CHECK ADD  CONSTRAINT [FK_ForEmployee_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[ForEmployee] CHECK CONSTRAINT [FK_ForEmployee_UserProfile]
GO
ALTER TABLE [dbo].[GroupEvent]  WITH CHECK ADD  CONSTRAINT [FK_GroupEvent_UserEvent] FOREIGN KEY([EventID])
REFERENCES [dbo].[UserEvent] ([EventID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GroupEvent] CHECK CONSTRAINT [FK_GroupEvent_UserEvent]
GO
ALTER TABLE [dbo].[GroupEvent]  WITH CHECK ADD  CONSTRAINT [FK_GroupEvent_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[GroupEvent] CHECK CONSTRAINT [FK_GroupEvent_UserProfile]
GO
ALTER TABLE [dbo].[IntuitionCharge]  WITH CHECK ADD  CONSTRAINT [FK_IntuitionCharge_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IntuitionCharge] CHECK CONSTRAINT [FK_IntuitionCharge_RegisterLesson]
GO
ALTER TABLE [dbo].[InvoiceAllowance]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowance_Document] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[Document] ([DocID])
GO
ALTER TABLE [dbo].[InvoiceAllowance] CHECK CONSTRAINT [FK_InvoiceAllowance_Document]
GO
ALTER TABLE [dbo].[InvoiceAllowance]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowance_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
GO
ALTER TABLE [dbo].[InvoiceAllowance] CHECK CONSTRAINT [FK_InvoiceAllowance_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceAllowanceBuyer]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceBuyer_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceBuyer] CHECK CONSTRAINT [FK_InvoiceAllowanceBuyer_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAllowanceBuyer]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceBuyer_Organization] FOREIGN KEY([BuyerID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[InvoiceAllowanceBuyer] CHECK CONSTRAINT [FK_InvoiceAllowanceBuyer_Organization]
GO
ALTER TABLE [dbo].[InvoiceAllowanceCancellation]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceAllowanceCancellation_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
GO
ALTER TABLE [dbo].[InvoiceAllowanceCancellation] CHECK CONSTRAINT [FK_InvoiceAllowanceCancellation_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAllowanceDetails]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceDetails_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceDetails] CHECK CONSTRAINT [FK_InvoiceAllowanceDetails_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAllowanceDetails]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceDetails_InvoiceAllowanceItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[InvoiceAllowanceItem] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceDetails] CHECK CONSTRAINT [FK_InvoiceAllowanceDetails_InvoiceAllowanceItem]
GO
ALTER TABLE [dbo].[InvoiceAllowanceDispatch]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceDispatch_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceDispatch] CHECK CONSTRAINT [FK_InvoiceAllowanceDispatch_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAllowanceDispatchLog]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceDispatchLog_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceDispatchLog] CHECK CONSTRAINT [FK_InvoiceAllowanceDispatchLog_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAllowanceItem]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceAllowanceItem_InvoiceProductItem] FOREIGN KEY([ProductItemID])
REFERENCES [dbo].[InvoiceProductItem] ([ItemID])
GO
ALTER TABLE [dbo].[InvoiceAllowanceItem] CHECK CONSTRAINT [FK_InvoiceAllowanceItem_InvoiceProductItem]
GO
ALTER TABLE [dbo].[InvoiceAllowanceSeller]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceSeller_Document] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceSeller] CHECK CONSTRAINT [FK_InvoiceAllowanceSeller_Document]
GO
ALTER TABLE [dbo].[InvoiceAllowanceSeller]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceSeller_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAllowanceSeller] CHECK CONSTRAINT [FK_InvoiceAllowanceSeller_InvoiceAllowance]
GO
ALTER TABLE [dbo].[InvoiceAllowanceSeller]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAllowanceSeller_Organization] FOREIGN KEY([SellerID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[InvoiceAllowanceSeller] CHECK CONSTRAINT [FK_InvoiceAllowanceSeller_Organization]
GO
ALTER TABLE [dbo].[InvoiceAmountType]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceAmountType_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceAmountType] CHECK CONSTRAINT [FK_InvoiceAmountType_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceBuyer]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceBuyer_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceBuyer] CHECK CONSTRAINT [FK_InvoiceBuyer_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceBuyer]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceBuyer_Organization] FOREIGN KEY([BuyerID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[InvoiceBuyer] CHECK CONSTRAINT [FK_InvoiceBuyer_Organization]
GO
ALTER TABLE [dbo].[InvoiceCancellation]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceCancellation_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceCancellation] CHECK CONSTRAINT [FK_InvoiceCancellation_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceCancellationDispatch]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceCancellationDispatch_InvoiceCancellation] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceCancellation] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceCancellationDispatch] CHECK CONSTRAINT [FK_InvoiceCancellationDispatch_InvoiceCancellation]
GO
ALTER TABLE [dbo].[InvoiceCancellationDispatchLog]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceCancellationDispatchLog_InvoiceCancellation] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceCancellation] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceCancellationDispatchLog] CHECK CONSTRAINT [FK_InvoiceCancellationDispatchLog_InvoiceCancellation]
GO
ALTER TABLE [dbo].[InvoiceCarrier]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceCarrier_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceCarrier] CHECK CONSTRAINT [FK_InvoiceCarrier_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceDetails]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetails_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceDetails] CHECK CONSTRAINT [FK_InvoiceDetails_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceDetails]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceDetails_InvoiceProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[InvoiceProduct] ([ProductID])
GO
ALTER TABLE [dbo].[InvoiceDetails] CHECK CONSTRAINT [FK_InvoiceDetails_InvoiceProduct]
GO
ALTER TABLE [dbo].[InvoiceDonation]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDonation_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceDonation] CHECK CONSTRAINT [FK_InvoiceDonation_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_Document] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[Document] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_Document]
GO
ALTER TABLE [dbo].[InvoiceItem]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItem_Organization] FOREIGN KEY([SellerID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[InvoiceItem] CHECK CONSTRAINT [FK_InvoiceItem_Organization]
GO
ALTER TABLE [dbo].[InvoiceItemDispatch]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItemDispatch_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceItemDispatch] CHECK CONSTRAINT [FK_InvoiceItemDispatch_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceItemDispatchLog]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceItemDispatchLog_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceItemDispatchLog] CHECK CONSTRAINT [FK_InvoiceItemDispatchLog_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceNoAssignment]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceNoAssignment_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceNoAssignment] CHECK CONSTRAINT [FK_InvoiceNoAssignment_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceNoAssignment]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceNoAssignment_InvoiceNoInterval] FOREIGN KEY([IntervalID])
REFERENCES [dbo].[InvoiceNoInterval] ([IntervalID])
GO
ALTER TABLE [dbo].[InvoiceNoAssignment] CHECK CONSTRAINT [FK_InvoiceNoAssignment_InvoiceNoInterval]
GO
ALTER TABLE [dbo].[InvoiceNoInterval]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceNoInterval_InvoiceNoIntervalGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[InvoiceNoIntervalGroup] ([GroupID])
GO
ALTER TABLE [dbo].[InvoiceNoInterval] CHECK CONSTRAINT [FK_InvoiceNoInterval_InvoiceNoIntervalGroup]
GO
ALTER TABLE [dbo].[InvoiceNoInterval]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceNoInterval_InvoiceTrackCodeAssignment] FOREIGN KEY([TrackID], [SellerID])
REFERENCES [dbo].[InvoiceTrackCodeAssignment] ([TrackID], [SellerID])
GO
ALTER TABLE [dbo].[InvoiceNoInterval] CHECK CONSTRAINT [FK_InvoiceNoInterval_InvoiceTrackCodeAssignment]
GO
ALTER TABLE [dbo].[InvoiceProductItem]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceProductItem_InvoiceProduct] FOREIGN KEY([ProductID])
REFERENCES [dbo].[InvoiceProduct] ([ProductID])
GO
ALTER TABLE [dbo].[InvoiceProductItem] CHECK CONSTRAINT [FK_InvoiceProductItem_InvoiceProduct]
GO
ALTER TABLE [dbo].[InvoicePurchaseOrder]  WITH CHECK ADD  CONSTRAINT [FK_InvoicePurchaseOrder_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoicePurchaseOrder] CHECK CONSTRAINT [FK_InvoicePurchaseOrder_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceSeller]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceSeller_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceSeller] CHECK CONSTRAINT [FK_InvoiceSeller_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceSeller]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceSeller_Organization] FOREIGN KEY([SellerID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[InvoiceSeller] CHECK CONSTRAINT [FK_InvoiceSeller_Organization]
GO
ALTER TABLE [dbo].[InvoiceTrackCodeAssignment]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceTrackCodeAssignment_InvoiceTrackCode] FOREIGN KEY([TrackID])
REFERENCES [dbo].[InvoiceTrackCode] ([TrackID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceTrackCodeAssignment] CHECK CONSTRAINT [FK_InvoiceTrackCodeAssignment_InvoiceTrackCode]
GO
ALTER TABLE [dbo].[InvoiceTrackCodeAssignment]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceTrackCodeAssignment_Organization] FOREIGN KEY([SellerID])
REFERENCES [dbo].[Organization] ([CompanyID])
GO
ALTER TABLE [dbo].[InvoiceTrackCodeAssignment] CHECK CONSTRAINT [FK_InvoiceTrackCodeAssignment_Organization]
GO
ALTER TABLE [dbo].[InvoiceWinningNumber]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceWinningNumber_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InvoiceWinningNumber] CHECK CONSTRAINT [FK_InvoiceWinningNumber_InvoiceItem]
GO
ALTER TABLE [dbo].[InvoiceWinningNumber]  WITH NOCHECK ADD  CONSTRAINT [FK_InvoiceWinningNumber_UniformInvoiceWinningNumber] FOREIGN KEY([WinningID])
REFERENCES [dbo].[UniformInvoiceWinningNumber] ([WinningID])
GO
ALTER TABLE [dbo].[InvoiceWinningNumber] CHECK CONSTRAINT [FK_InvoiceWinningNumber_UniformInvoiceWinningNumber]
GO
ALTER TABLE [dbo].[IsInternalLesson]  WITH CHECK ADD  CONSTRAINT [FK_IsInternalLesson_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[IsInternalLesson] CHECK CONSTRAINT [FK_IsInternalLesson_LessonPriceType]
GO
ALTER TABLE [dbo].[IsWelfareGiftLesson]  WITH CHECK ADD  CONSTRAINT [FK_IsWelfareGiftLesson_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[IsWelfareGiftLesson] CHECK CONSTRAINT [FK_IsWelfareGiftLesson_LessonPriceType]
GO
ALTER TABLE [dbo].[LearnerCoachProperty]  WITH CHECK ADD  CONSTRAINT [FK_LearnerCoachProperty_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[LearnerCoachProperty] CHECK CONSTRAINT [FK_LearnerCoachProperty_ServingCoach]
GO
ALTER TABLE [dbo].[LearnerCoachProperty]  WITH CHECK ADD  CONSTRAINT [FK_LearnerCoachProperty_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearnerCoachProperty] CHECK CONSTRAINT [FK_LearnerCoachProperty_UserProfile]
GO
ALTER TABLE [dbo].[LearnerFitnessAdvisor]  WITH CHECK ADD  CONSTRAINT [FK_LearnerFitnessAdvisor_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[LearnerFitnessAdvisor] CHECK CONSTRAINT [FK_LearnerFitnessAdvisor_ServingCoach]
GO
ALTER TABLE [dbo].[LearnerFitnessAdvisor]  WITH CHECK ADD  CONSTRAINT [FK_LearnerFitnessAdvisor_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LearnerFitnessAdvisor] CHECK CONSTRAINT [FK_LearnerFitnessAdvisor_UserProfile]
GO
ALTER TABLE [dbo].[LearnerFitnessAssessment]  WITH CHECK ADD  CONSTRAINT [FK_LearnerFitnessAssessment_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[LearnerFitnessAssessment] CHECK CONSTRAINT [FK_LearnerFitnessAssessment_UserProfile]
GO
ALTER TABLE [dbo].[LearnerFitnessAssessmentResult]  WITH CHECK ADD  CONSTRAINT [FK_LearnerFitnessAssessmentResult_FitnessAssessmentItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[FitnessAssessmentItem] ([ItemID])
GO
ALTER TABLE [dbo].[LearnerFitnessAssessmentResult] CHECK CONSTRAINT [FK_LearnerFitnessAssessmentResult_FitnessAssessmentItem]
GO
ALTER TABLE [dbo].[LearnerFitnessAssessmentResult]  WITH CHECK ADD  CONSTRAINT [FK_LearnerFitnessAssessmentResult_LearnerFitnessAssessment] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[LearnerFitnessAssessment] ([AssessmentID])
GO
ALTER TABLE [dbo].[LearnerFitnessAssessmentResult] CHECK CONSTRAINT [FK_LearnerFitnessAssessmentResult_LearnerFitnessAssessment]
GO
ALTER TABLE [dbo].[LessonAttendance]  WITH CHECK ADD  CONSTRAINT [FK_LessonAttendance_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonAttendance] CHECK CONSTRAINT [FK_LessonAttendance_LessonTime]
GO
ALTER TABLE [dbo].[LessonAttendance]  WITH CHECK ADD  CONSTRAINT [FK_LessonAttendance_UserProfile] FOREIGN KEY([ActorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[LessonAttendance] CHECK CONSTRAINT [FK_LessonAttendance_UserProfile]
GO
ALTER TABLE [dbo].[LessonComment]  WITH CHECK ADD  CONSTRAINT [FK_LessonComment_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[LessonComment] CHECK CONSTRAINT [FK_LessonComment_LevelExpression]
GO
ALTER TABLE [dbo].[LessonComment]  WITH CHECK ADD  CONSTRAINT [FK_LessonComment_UserProfile] FOREIGN KEY([SpeakerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[LessonComment] CHECK CONSTRAINT [FK_LessonComment_UserProfile]
GO
ALTER TABLE [dbo].[LessonComment]  WITH CHECK ADD  CONSTRAINT [FK_LessonComment_UserProfile1] FOREIGN KEY([HearerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[LessonComment] CHECK CONSTRAINT [FK_LessonComment_UserProfile1]
GO
ALTER TABLE [dbo].[LessonFeedBack]  WITH CHECK ADD  CONSTRAINT [FK_LessonFeedBack_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFeedBack] CHECK CONSTRAINT [FK_LessonFeedBack_LessonTime]
GO
ALTER TABLE [dbo].[LessonFeedBack]  WITH CHECK ADD  CONSTRAINT [FK_LessonFeedBack_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[LessonFeedBack] CHECK CONSTRAINT [FK_LessonFeedBack_LevelExpression]
GO
ALTER TABLE [dbo].[LessonFeedBack]  WITH CHECK ADD  CONSTRAINT [FK_LessonFeedBack_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
GO
ALTER TABLE [dbo].[LessonFeedBack] CHECK CONSTRAINT [FK_LessonFeedBack_RegisterLesson]
GO
ALTER TABLE [dbo].[LessonFitnessAssessment]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitnessAssessment_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitnessAssessment] CHECK CONSTRAINT [FK_LessonFitnessAssessment_LessonTime]
GO
ALTER TABLE [dbo].[LessonFitnessAssessment]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitnessAssessment_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[LessonFitnessAssessment] CHECK CONSTRAINT [FK_LessonFitnessAssessment_UserProfile]
GO
ALTER TABLE [dbo].[LessonFitnessAssessmentReport]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitnessAssessmentReport_FitnessAssessmentItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[FitnessAssessmentItem] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitnessAssessmentReport] CHECK CONSTRAINT [FK_LessonFitnessAssessmentReport_FitnessAssessmentItem]
GO
ALTER TABLE [dbo].[LessonFitnessAssessmentReport]  WITH CHECK ADD  CONSTRAINT [FK_LessonFitnessAssessmentReport_LessonFitnessAssessment] FOREIGN KEY([AssessmentID])
REFERENCES [dbo].[LessonFitnessAssessment] ([AssessmentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonFitnessAssessmentReport] CHECK CONSTRAINT [FK_LessonFitnessAssessmentReport_LessonFitnessAssessment]
GO
ALTER TABLE [dbo].[LessonPlan]  WITH CHECK ADD  CONSTRAINT [FK_LessonPlan_Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[Attachment] ([AttachmentID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[LessonPlan] CHECK CONSTRAINT [FK_LessonPlan_Attachment]
GO
ALTER TABLE [dbo].[LessonPlan]  WITH CHECK ADD  CONSTRAINT [FK_LessonPlan_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonPlan] CHECK CONSTRAINT [FK_LessonPlan_LessonTime]
GO
ALTER TABLE [dbo].[LessonPriceExchange]  WITH CHECK ADD  CONSTRAINT [FK_LessonPriceExchange_LessonPriceType] FOREIGN KEY([SourceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[LessonPriceExchange] CHECK CONSTRAINT [FK_LessonPriceExchange_LessonPriceType]
GO
ALTER TABLE [dbo].[LessonPriceExchange]  WITH CHECK ADD  CONSTRAINT [FK_LessonPriceExchange_LessonPriceType1] FOREIGN KEY([TargetID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[LessonPriceExchange] CHECK CONSTRAINT [FK_LessonPriceExchange_LessonPriceType1]
GO
ALTER TABLE [dbo].[LessonPricePackage]  WITH CHECK ADD  CONSTRAINT [FK_LessonPricePackage_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[LessonPricePackage] CHECK CONSTRAINT [FK_LessonPricePackage_LessonPriceType]
GO
ALTER TABLE [dbo].[LessonPricePackage]  WITH CHECK ADD  CONSTRAINT [FK_LessonPricePackage_LessonPriceType1] FOREIGN KEY([ItemID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[LessonPricePackage] CHECK CONSTRAINT [FK_LessonPricePackage_LessonPriceType1]
GO
ALTER TABLE [dbo].[LessonPriceProperty]  WITH NOCHECK ADD  CONSTRAINT [FK_LessonPriceProperty_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonPriceProperty] CHECK CONSTRAINT [FK_LessonPriceProperty_LessonPriceType]
GO
ALTER TABLE [dbo].[LessonPriceProperty]  WITH NOCHECK ADD  CONSTRAINT [FK_LessonPriceProperty_LevelExpression] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[LessonPriceProperty] CHECK CONSTRAINT [FK_LessonPriceProperty_LevelExpression]
GO
ALTER TABLE [dbo].[LessonPriceSeries]  WITH NOCHECK ADD  CONSTRAINT [FK_LessonPriceSeries_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonPriceSeries] CHECK CONSTRAINT [FK_LessonPriceSeries_LessonPriceType]
GO
ALTER TABLE [dbo].[LessonPriceSeries]  WITH NOCHECK ADD  CONSTRAINT [FK_LessonPriceSeries_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[LessonPriceSeries] CHECK CONSTRAINT [FK_LessonPriceSeries_LevelExpression]
GO
ALTER TABLE [dbo].[LessonPriceType]  WITH NOCHECK ADD  CONSTRAINT [FK_LessonPriceType_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[LessonPriceType] CHECK CONSTRAINT [FK_LessonPriceType_BranchStore]
GO
ALTER TABLE [dbo].[LessonPriceType]  WITH NOCHECK ADD  CONSTRAINT [FK_LessonPriceType_LessonPriceSeries] FOREIGN KEY([SeriesID])
REFERENCES [dbo].[LessonPriceSeries] ([PriceID])
GO
ALTER TABLE [dbo].[LessonPriceType] CHECK CONSTRAINT [FK_LessonPriceType_LessonPriceSeries]
GO
ALTER TABLE [dbo].[LessonPriceType]  WITH CHECK ADD  CONSTRAINT [FK_LessonPriceType_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[LessonPriceType] CHECK CONSTRAINT [FK_LessonPriceType_LevelExpression]
GO
ALTER TABLE [dbo].[LessonPriceType]  WITH CHECK ADD  CONSTRAINT [FK_LessonPriceType_UsageType] FOREIGN KEY([UsageType])
REFERENCES [dbo].[UsageType] ([UsageID])
GO
ALTER TABLE [dbo].[LessonPriceType] CHECK CONSTRAINT [FK_LessonPriceType_UsageType]
GO
ALTER TABLE [dbo].[LessonTime]  WITH CHECK ADD  CONSTRAINT [FK_LessonTime_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[LessonTime] CHECK CONSTRAINT [FK_LessonTime_BranchStore]
GO
ALTER TABLE [dbo].[LessonTime]  WITH CHECK ADD  CONSTRAINT [FK_LessonTime_DailyWorkingHour] FOREIGN KEY([HourOfClassTime])
REFERENCES [dbo].[DailyWorkingHour] ([Hour])
GO
ALTER TABLE [dbo].[LessonTime] CHECK CONSTRAINT [FK_LessonTime_DailyWorkingHour]
GO
ALTER TABLE [dbo].[LessonTime]  WITH CHECK ADD  CONSTRAINT [FK_LessonTime_GroupingLesson] FOREIGN KEY([GroupID])
REFERENCES [dbo].[GroupingLesson] ([GroupID])
GO
ALTER TABLE [dbo].[LessonTime] CHECK CONSTRAINT [FK_LessonTime_GroupingLesson]
GO
ALTER TABLE [dbo].[LessonTime]  WITH CHECK ADD  CONSTRAINT [FK_LessonTime_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
GO
ALTER TABLE [dbo].[LessonTime] CHECK CONSTRAINT [FK_LessonTime_RegisterLesson]
GO
ALTER TABLE [dbo].[LessonTime]  WITH CHECK ADD  CONSTRAINT [FK_LessonTime_ServingCoach] FOREIGN KEY([InvitedCoach])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[LessonTime] CHECK CONSTRAINT [FK_LessonTime_ServingCoach]
GO
ALTER TABLE [dbo].[LessonTime]  WITH CHECK ADD  CONSTRAINT [FK_LessonTime_ServingCoach1] FOREIGN KEY([AttendingCoach])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[LessonTime] CHECK CONSTRAINT [FK_LessonTime_ServingCoach1]
GO
ALTER TABLE [dbo].[LessonTimeExpansion]  WITH CHECK ADD  CONSTRAINT [FK_LessonTimeExpansion_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonTimeExpansion] CHECK CONSTRAINT [FK_LessonTimeExpansion_LessonTime]
GO
ALTER TABLE [dbo].[LessonTimeSettlement]  WITH CHECK ADD  CONSTRAINT [FK_LessonTimeSettlement_BranchStore] FOREIGN KEY([CoachWorkPlace])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[LessonTimeSettlement] CHECK CONSTRAINT [FK_LessonTimeSettlement_BranchStore]
GO
ALTER TABLE [dbo].[LessonTimeSettlement]  WITH CHECK ADD  CONSTRAINT [FK_LessonTimeSettlement_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonTimeSettlement] CHECK CONSTRAINT [FK_LessonTimeSettlement_LessonTime]
GO
ALTER TABLE [dbo].[LessonTimeSettlement]  WITH CHECK ADD  CONSTRAINT [FK_LessonTimeSettlement_ProfessionalLevel] FOREIGN KEY([ProfessionalLevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [dbo].[LessonTimeSettlement] CHECK CONSTRAINT [FK_LessonTimeSettlement_ProfessionalLevel]
GO
ALTER TABLE [dbo].[LessonTimeSettlement]  WITH CHECK ADD  CONSTRAINT [FK_LessonTimeSettlement_Settlement] FOREIGN KEY([SettlementID])
REFERENCES [dbo].[Settlement] ([SettlementID])
ON UPDATE SET NULL
GO
ALTER TABLE [dbo].[LessonTimeSettlement] CHECK CONSTRAINT [FK_LessonTimeSettlement_Settlement]
GO
ALTER TABLE [dbo].[LessonTrend]  WITH CHECK ADD  CONSTRAINT [FK_LessonTrend_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonTrend] CHECK CONSTRAINT [FK_LessonTrend_LessonTime]
GO
ALTER TABLE [dbo].[LessonUnitPrice]  WITH CHECK ADD  CONSTRAINT [FK_LessonUnitPrice_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LessonUnitPrice] CHECK CONSTRAINT [FK_LessonUnitPrice_LessonPriceType]
GO
ALTER TABLE [dbo].[LessonUnitPrice]  WITH CHECK ADD  CONSTRAINT [FK_LessonUnitPrice_LessonPriceType1] FOREIGN KEY([UnitID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[LessonUnitPrice] CHECK CONSTRAINT [FK_LessonUnitPrice_LessonPriceType1]
GO
ALTER TABLE [dbo].[MerchandiseTransaction]  WITH NOCHECK ADD  CONSTRAINT [FK_MerchandiseTransaction_MerchandiseTransactionType] FOREIGN KEY([TransactionID])
REFERENCES [dbo].[MerchandiseTransactionType] ([TransactionID])
GO
ALTER TABLE [dbo].[MerchandiseTransaction] CHECK CONSTRAINT [FK_MerchandiseTransaction_MerchandiseTransactionType]
GO
ALTER TABLE [dbo].[MerchandiseTransaction]  WITH NOCHECK ADD  CONSTRAINT [FK_MerchandiseTransaction_MerchandiseWindow] FOREIGN KEY([ProductID])
REFERENCES [dbo].[MerchandiseWindow] ([ProductID])
GO
ALTER TABLE [dbo].[MerchandiseTransaction] CHECK CONSTRAINT [FK_MerchandiseTransaction_MerchandiseWindow]
GO
ALTER TABLE [dbo].[MerchandiseTransactionType]  WITH CHECK ADD  CONSTRAINT [FK_MerchandiseTransactionType_MerchandiseTransactionType] FOREIGN KEY([CategorySourceID])
REFERENCES [dbo].[MerchandiseTransactionType] ([TransactionID])
GO
ALTER TABLE [dbo].[MerchandiseTransactionType] CHECK CONSTRAINT [FK_MerchandiseTransactionType_MerchandiseTransactionType]
GO
ALTER TABLE [dbo].[MerchandiseWindow]  WITH NOCHECK ADD  CONSTRAINT [FK_MerchandiseWindow_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[MerchandiseWindow] CHECK CONSTRAINT [FK_MerchandiseWindow_LevelExpression]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_InvoiceAllowance] FOREIGN KEY([AllowanceID])
REFERENCES [dbo].[InvoiceAllowance] ([AllowanceID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_InvoiceAllowance]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_InvoiceItem] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[InvoiceItem] ([InvoiceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_InvoiceItem]
GO
ALTER TABLE [dbo].[Payment]  WITH NOCHECK ADD  CONSTRAINT [FK_Payment_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_LevelExpression]
GO
ALTER TABLE [dbo].[Payment]  WITH NOCHECK ADD  CONSTRAINT [FK_Payment_UserProfile] FOREIGN KEY([HandlerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_UserProfile]
GO
ALTER TABLE [dbo].[PaymentAudit]  WITH NOCHECK ADD  CONSTRAINT [FK_PaymentAudit_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaymentAudit] CHECK CONSTRAINT [FK_PaymentAudit_Payment]
GO
ALTER TABLE [dbo].[PaymentAudit]  WITH NOCHECK ADD  CONSTRAINT [FK_PaymentAudit_UserProfile] FOREIGN KEY([AuditorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[PaymentAudit] CHECK CONSTRAINT [FK_PaymentAudit_UserProfile]
GO
ALTER TABLE [dbo].[PaymentContractTermination]  WITH CHECK ADD  CONSTRAINT [FK_PaymentContractTermination_CourseContractTermination] FOREIGN KEY([RevisionID])
REFERENCES [dbo].[CourseContractTermination] ([RevisionID])
GO
ALTER TABLE [dbo].[PaymentContractTermination] CHECK CONSTRAINT [FK_PaymentContractTermination_CourseContractTermination]
GO
ALTER TABLE [dbo].[PaymentContractTermination]  WITH CHECK ADD  CONSTRAINT [FK_PaymentContractTermination_PaymentTransaction] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[PaymentTransaction] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaymentContractTermination] CHECK CONSTRAINT [FK_PaymentContractTermination_PaymentTransaction]
GO
ALTER TABLE [dbo].[PaymentOnLine]  WITH CHECK ADD  CONSTRAINT [FK_PaymentOnLine_PaymentTransaction] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[PaymentTransaction] ([PaymentID])
GO
ALTER TABLE [dbo].[PaymentOnLine] CHECK CONSTRAINT [FK_PaymentOnLine_PaymentTransaction]
GO
ALTER TABLE [dbo].[PaymentOrder]  WITH NOCHECK ADD  CONSTRAINT [FK_PaymentOrder_MerchandiseWindow] FOREIGN KEY([ProductID])
REFERENCES [dbo].[MerchandiseWindow] ([ProductID])
GO
ALTER TABLE [dbo].[PaymentOrder] CHECK CONSTRAINT [FK_PaymentOrder_MerchandiseWindow]
GO
ALTER TABLE [dbo].[PaymentOrder]  WITH NOCHECK ADD  CONSTRAINT [FK_PaymentOrder_PaymentTransaction] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[PaymentTransaction] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaymentOrder] CHECK CONSTRAINT [FK_PaymentOrder_PaymentTransaction]
GO
ALTER TABLE [dbo].[PaymentTransaction]  WITH NOCHECK ADD  CONSTRAINT [FK_PaymentTransaction_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[PaymentTransaction] CHECK CONSTRAINT [FK_PaymentTransaction_BranchStore]
GO
ALTER TABLE [dbo].[PaymentTransaction]  WITH NOCHECK ADD  CONSTRAINT [FK_PaymentTransaction_Payment] FOREIGN KEY([PaymentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaymentTransaction] CHECK CONSTRAINT [FK_PaymentTransaction_Payment]
GO
ALTER TABLE [dbo].[PaymentTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PaymentTransaction_UserProfile] FOREIGN KEY([PayerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[PaymentTransaction] CHECK CONSTRAINT [FK_PaymentTransaction_UserProfile]
GO
ALTER TABLE [dbo].[PDQGroup]  WITH CHECK ADD  CONSTRAINT [FK_PDQGroup_PDQQuestion] FOREIGN KEY([ConclusionID])
REFERENCES [dbo].[PDQQuestion] ([QuestionID])
GO
ALTER TABLE [dbo].[PDQGroup] CHECK CONSTRAINT [FK_PDQGroup_PDQQuestion]
GO
ALTER TABLE [dbo].[PDQQuestion]  WITH CHECK ADD  CONSTRAINT [FK_PDQQuestion_LevelExpression] FOREIGN KEY([QuestionType])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[PDQQuestion] CHECK CONSTRAINT [FK_PDQQuestion_LevelExpression]
GO
ALTER TABLE [dbo].[PDQQuestion]  WITH CHECK ADD  CONSTRAINT [FK_PDQQuestion_PDQGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[PDQGroup] ([GroupID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQQuestion] CHECK CONSTRAINT [FK_PDQQuestion_PDQGroup]
GO
ALTER TABLE [dbo].[PDQQuestion]  WITH CHECK ADD  CONSTRAINT [FK_PDQQuestion_UserProfile] FOREIGN KEY([AskerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[PDQQuestion] CHECK CONSTRAINT [FK_PDQQuestion_UserProfile]
GO
ALTER TABLE [dbo].[PDQQuestionExtension]  WITH CHECK ADD  CONSTRAINT [FK_PDQQuestionExtension_PDQQuestion] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[PDQQuestion] ([QuestionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQQuestionExtension] CHECK CONSTRAINT [FK_PDQQuestionExtension_PDQQuestion]
GO
ALTER TABLE [dbo].[PDQSuggestion]  WITH CHECK ADD  CONSTRAINT [FK_PDQSuggestion_PDQQuestion] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[PDQQuestion] ([QuestionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQSuggestion] CHECK CONSTRAINT [FK_PDQSuggestion_PDQQuestion]
GO
ALTER TABLE [dbo].[PDQTask]  WITH CHECK ADD  CONSTRAINT [FK_PDQTask_PDQQuestion] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[PDQQuestion] ([QuestionID])
GO
ALTER TABLE [dbo].[PDQTask] CHECK CONSTRAINT [FK_PDQTask_PDQQuestion]
GO
ALTER TABLE [dbo].[PDQTask]  WITH CHECK ADD  CONSTRAINT [FK_PDQTask_PDQSuggestion] FOREIGN KEY([SuggestionID])
REFERENCES [dbo].[PDQSuggestion] ([SuggestionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQTask] CHECK CONSTRAINT [FK_PDQTask_PDQSuggestion]
GO
ALTER TABLE [dbo].[PDQTask]  WITH CHECK ADD  CONSTRAINT [FK_PDQTask_QuestionnaireRequest] FOREIGN KEY([QuestionnaireID])
REFERENCES [dbo].[QuestionnaireRequest] ([QuestionnaireID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQTask] CHECK CONSTRAINT [FK_PDQTask_QuestionnaireRequest]
GO
ALTER TABLE [dbo].[PDQTask]  WITH CHECK ADD  CONSTRAINT [FK_PDQTask_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[PDQTask] CHECK CONSTRAINT [FK_PDQTask_UserProfile]
GO
ALTER TABLE [dbo].[PDQTaskBonus]  WITH CHECK ADD  CONSTRAINT [FK_PDQTaskBonus_PDQTask] FOREIGN KEY([TaskID])
REFERENCES [dbo].[PDQTask] ([TaskID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQTaskBonus] CHECK CONSTRAINT [FK_PDQTaskBonus_PDQTask]
GO
ALTER TABLE [dbo].[PDQTaskItem]  WITH CHECK ADD  CONSTRAINT [FK_PDQTaskItem_PDQSuggestion] FOREIGN KEY([SuggestionID])
REFERENCES [dbo].[PDQSuggestion] ([SuggestionID])
GO
ALTER TABLE [dbo].[PDQTaskItem] CHECK CONSTRAINT [FK_PDQTaskItem_PDQSuggestion]
GO
ALTER TABLE [dbo].[PDQTaskItem]  WITH CHECK ADD  CONSTRAINT [FK_PDQTaskItem_PDQTask] FOREIGN KEY([TaskID])
REFERENCES [dbo].[PDQTask] ([TaskID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQTaskItem] CHECK CONSTRAINT [FK_PDQTaskItem_PDQTask]
GO
ALTER TABLE [dbo].[PDQType]  WITH CHECK ADD  CONSTRAINT [FK_PDQType_LevelExpression] FOREIGN KEY([TypeID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[PDQType] CHECK CONSTRAINT [FK_PDQType_LevelExpression]
GO
ALTER TABLE [dbo].[PDQType]  WITH CHECK ADD  CONSTRAINT [FK_PDQType_PDQQuestion] FOREIGN KEY([QuestionID])
REFERENCES [dbo].[PDQQuestion] ([QuestionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQType] CHECK CONSTRAINT [FK_PDQType_PDQQuestion]
GO
ALTER TABLE [dbo].[PDQUserAssessment]  WITH CHECK ADD  CONSTRAINT [FK_PDQUserAssessment_GoalAboutPDQ] FOREIGN KEY([GoalID])
REFERENCES [dbo].[GoalAboutPDQ] ([GoalID])
GO
ALTER TABLE [dbo].[PDQUserAssessment] CHECK CONSTRAINT [FK_PDQUserAssessment_GoalAboutPDQ]
GO
ALTER TABLE [dbo].[PDQUserAssessment]  WITH CHECK ADD  CONSTRAINT [FK_PDQUserAssessment_StyleAboutPDQ] FOREIGN KEY([StyleID])
REFERENCES [dbo].[StyleAboutPDQ] ([StyleID])
GO
ALTER TABLE [dbo].[PDQUserAssessment] CHECK CONSTRAINT [FK_PDQUserAssessment_StyleAboutPDQ]
GO
ALTER TABLE [dbo].[PDQUserAssessment]  WITH CHECK ADD  CONSTRAINT [FK_PDQUserAssessment_TrainingLevelAboutPDQ] FOREIGN KEY([LevelID])
REFERENCES [dbo].[TrainingLevelAboutPDQ] ([LevelID])
GO
ALTER TABLE [dbo].[PDQUserAssessment] CHECK CONSTRAINT [FK_PDQUserAssessment_TrainingLevelAboutPDQ]
GO
ALTER TABLE [dbo].[PDQUserAssessment]  WITH CHECK ADD  CONSTRAINT [FK_PDQUserAssessment_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PDQUserAssessment] CHECK CONSTRAINT [FK_PDQUserAssessment_UserProfile]
GO
ALTER TABLE [dbo].[PersonalExercisePurpose]  WITH CHECK ADD  CONSTRAINT [FK_PersonalExercisePurpose_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PersonalExercisePurpose] CHECK CONSTRAINT [FK_PersonalExercisePurpose_UserProfile]
GO
ALTER TABLE [dbo].[PersonalExercisePurposeItem]  WITH CHECK ADD  CONSTRAINT [FK_PersonalExercisePurposeItem_PersonalExercisePurpose] FOREIGN KEY([UID])
REFERENCES [dbo].[PersonalExercisePurpose] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PersonalExercisePurposeItem] CHECK CONSTRAINT [FK_PersonalExercisePurposeItem_PersonalExercisePurpose]
GO
ALTER TABLE [dbo].[PreferredLessonTime]  WITH CHECK ADD  CONSTRAINT [FK_PreferredLessonTime_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PreferredLessonTime] CHECK CONSTRAINT [FK_PreferredLessonTime_LessonTime]
GO
ALTER TABLE [dbo].[PreferredLessonTime]  WITH CHECK ADD  CONSTRAINT [FK_PreferredLessonTime_UserProfile] FOREIGN KEY([ApproverID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[PreferredLessonTime] CHECK CONSTRAINT [FK_PreferredLessonTime_UserProfile]
GO
ALTER TABLE [dbo].[ProfessionalLevel]  WITH CHECK ADD  CONSTRAINT [FK_ProfessionalLevel_LevelExpression] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[ProfessionalLevel] CHECK CONSTRAINT [FK_ProfessionalLevel_LevelExpression]
GO
ALTER TABLE [dbo].[ProfessionalLevelBasicSalary]  WITH CHECK ADD  CONSTRAINT [FK_ProfessionalLevelBasicSalary_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProfessionalLevelBasicSalary] CHECK CONSTRAINT [FK_ProfessionalLevelBasicSalary_ProfessionalLevel]
GO
ALTER TABLE [dbo].[ProfessionalLevelBasicSalary]  WITH CHECK ADD  CONSTRAINT [FK_ProfessionalLevelBasicSalary_SalaryDetails] FOREIGN KEY([SalaryID])
REFERENCES [dbo].[SalaryDetails] ([SalaryID])
GO
ALTER TABLE [dbo].[ProfessionalLevelBasicSalary] CHECK CONSTRAINT [FK_ProfessionalLevelBasicSalary_SalaryDetails]
GO
ALTER TABLE [dbo].[ProfessionalLevelReview]  WITH CHECK ADD  CONSTRAINT [FK_ProfessionalLevelReview_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProfessionalLevelReview] CHECK CONSTRAINT [FK_ProfessionalLevelReview_ProfessionalLevel]
GO
ALTER TABLE [dbo].[ProfessionalLevelReview]  WITH CHECK ADD  CONSTRAINT [FK_ProfessionalLevelReview_ProfessionalLevel1] FOREIGN KEY([PromotionID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [dbo].[ProfessionalLevelReview] CHECK CONSTRAINT [FK_ProfessionalLevelReview_ProfessionalLevel1]
GO
ALTER TABLE [dbo].[ProfessionalLevelReview]  WITH CHECK ADD  CONSTRAINT [FK_ProfessionalLevelReview_ProfessionalLevel2] FOREIGN KEY([DemotionID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [dbo].[ProfessionalLevelReview] CHECK CONSTRAINT [FK_ProfessionalLevelReview_ProfessionalLevel2]
GO
ALTER TABLE [dbo].[Publication]  WITH CHECK ADD  CONSTRAINT [FK_Publication_Article] FOREIGN KEY([DocID])
REFERENCES [dbo].[Article] ([DocID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Publication] CHECK CONSTRAINT [FK_Publication_Article]
GO
ALTER TABLE [dbo].[QuestionnaireCoachBypass]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireCoachBypass_QuestionnaireRequest] FOREIGN KEY([QuestionnaireID])
REFERENCES [dbo].[QuestionnaireRequest] ([QuestionnaireID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuestionnaireCoachBypass] CHECK CONSTRAINT [FK_QuestionnaireCoachBypass_QuestionnaireRequest]
GO
ALTER TABLE [dbo].[QuestionnaireCoachBypass]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireCoachBypass_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[QuestionnaireCoachBypass] CHECK CONSTRAINT [FK_QuestionnaireCoachBypass_UserProfile]
GO
ALTER TABLE [dbo].[QuestionnaireCoachFinish]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireCoachFinish_QuestionnaireRequest] FOREIGN KEY([QuestionnaireID])
REFERENCES [dbo].[QuestionnaireRequest] ([QuestionnaireID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuestionnaireCoachFinish] CHECK CONSTRAINT [FK_QuestionnaireCoachFinish_QuestionnaireRequest]
GO
ALTER TABLE [dbo].[QuestionnaireCoachFinish]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireCoachFinish_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[QuestionnaireCoachFinish] CHECK CONSTRAINT [FK_QuestionnaireCoachFinish_UserProfile]
GO
ALTER TABLE [dbo].[QuestionnaireGroup]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireGroup_PDQGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[PDQGroup] ([GroupID])
GO
ALTER TABLE [dbo].[QuestionnaireGroup] CHECK CONSTRAINT [FK_QuestionnaireGroup_PDQGroup]
GO
ALTER TABLE [dbo].[QuestionnaireRequest]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireRequest_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[QuestionnaireRequest] CHECK CONSTRAINT [FK_QuestionnaireRequest_LevelExpression]
GO
ALTER TABLE [dbo].[QuestionnaireRequest]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireRequest_PDQGroup] FOREIGN KEY([GroupID])
REFERENCES [dbo].[PDQGroup] ([GroupID])
GO
ALTER TABLE [dbo].[QuestionnaireRequest] CHECK CONSTRAINT [FK_QuestionnaireRequest_PDQGroup]
GO
ALTER TABLE [dbo].[QuestionnaireRequest]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireRequest_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
GO
ALTER TABLE [dbo].[QuestionnaireRequest] CHECK CONSTRAINT [FK_QuestionnaireRequest_RegisterLesson]
GO
ALTER TABLE [dbo].[QuestionnaireRequest]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireRequest_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[QuestionnaireRequest] CHECK CONSTRAINT [FK_QuestionnaireRequest_UserProfile]
GO
ALTER TABLE [dbo].[QuestionnaireRequest]  WITH CHECK ADD  CONSTRAINT [FK_QuestionnaireRequest_UserProfile_AsCreator] FOREIGN KEY([CreatorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[QuestionnaireRequest] CHECK CONSTRAINT [FK_QuestionnaireRequest_UserProfile_AsCreator]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_BranchStore]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_GroupingLesson] FOREIGN KEY([RegisterGroupID])
REFERENCES [dbo].[GroupingLesson] ([GroupID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_GroupingLesson]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_GroupingLessonDiscount] FOREIGN KEY([GroupingMemberCount])
REFERENCES [dbo].[GroupingLessonDiscount] ([GroupingMemberCount])
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_GroupingLessonDiscount]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_LessonPriceType] FOREIGN KEY([ClassLevel])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_LessonPriceType]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_LevelExpression] FOREIGN KEY([Attended])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_LevelExpression]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_ServingCoach] FOREIGN KEY([AdvisorID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_ServingCoach]
GO
ALTER TABLE [dbo].[RegisterLesson]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLesson_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLesson] CHECK CONSTRAINT [FK_RegisterLesson_UserProfile]
GO
ALTER TABLE [dbo].[RegisterLessonBooking]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonBooking_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[RegisterLessonBooking] CHECK CONSTRAINT [FK_RegisterLessonBooking_LessonTime]
GO
ALTER TABLE [dbo].[RegisterLessonBooking]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonBooking_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLessonBooking] CHECK CONSTRAINT [FK_RegisterLessonBooking_RegisterLesson]
GO
ALTER TABLE [dbo].[RegisterLessonContract]  WITH NOCHECK ADD  CONSTRAINT [FK_RegisterLessonContract_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLessonContract] CHECK CONSTRAINT [FK_RegisterLessonContract_CourseContract]
GO
ALTER TABLE [dbo].[RegisterLessonContract]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonContract_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLessonContract] CHECK CONSTRAINT [FK_RegisterLessonContract_RegisterLesson]
GO
ALTER TABLE [dbo].[RegisterLessonEnterprise]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonEnterprise_EnterpriseCourseContent] FOREIGN KEY([ContractID], [TypeID])
REFERENCES [dbo].[EnterpriseCourseContent] ([ContractID], [TypeID])
GO
ALTER TABLE [dbo].[RegisterLessonEnterprise] CHECK CONSTRAINT [FK_RegisterLessonEnterprise_EnterpriseCourseContent]
GO
ALTER TABLE [dbo].[RegisterLessonEnterprise]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonEnterprise_EnterpriseCourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[EnterpriseCourseContract] ([ContractID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLessonEnterprise] CHECK CONSTRAINT [FK_RegisterLessonEnterprise_EnterpriseCourseContract]
GO
ALTER TABLE [dbo].[RegisterLessonEnterprise]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonEnterprise_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLessonEnterprise] CHECK CONSTRAINT [FK_RegisterLessonEnterprise_RegisterLesson]
GO
ALTER TABLE [dbo].[RegisterLessonSharing]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonSharing_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RegisterLessonSharing] CHECK CONSTRAINT [FK_RegisterLessonSharing_RegisterLesson]
GO
ALTER TABLE [dbo].[RegisterLessonSharing]  WITH CHECK ADD  CONSTRAINT [FK_RegisterLessonSharing_RegisterLesson1] FOREIGN KEY([ShareID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
GO
ALTER TABLE [dbo].[RegisterLessonSharing] CHECK CONSTRAINT [FK_RegisterLessonSharing_RegisterLesson1]
GO
ALTER TABLE [dbo].[ResetPassword]  WITH CHECK ADD  CONSTRAINT [FK_ResetPassword_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ResetPassword] CHECK CONSTRAINT [FK_ResetPassword_UserProfile]
GO
ALTER TABLE [dbo].[ServingCoach]  WITH CHECK ADD  CONSTRAINT [FK_ServingCoach_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [dbo].[ServingCoach] CHECK CONSTRAINT [FK_ServingCoach_ProfessionalLevel]
GO
ALTER TABLE [dbo].[ServingCoach]  WITH CHECK ADD  CONSTRAINT [FK_ServingCoach_UserProfile] FOREIGN KEY([CoachID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ServingCoach] CHECK CONSTRAINT [FK_ServingCoach_UserProfile]
GO
ALTER TABLE [dbo].[ServingCoachProperty]  WITH CHECK ADD  CONSTRAINT [FK_ServingCoachProperty_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[ServingCoachProperty] CHECK CONSTRAINT [FK_ServingCoachProperty_ServingCoach]
GO
ALTER TABLE [dbo].[Settlement]  WITH CHECK ADD  CONSTRAINT [FK_Settlement_YearlySettlement] FOREIGN KEY([Year])
REFERENCES [dbo].[YearlySettlement] ([Year])
GO
ALTER TABLE [dbo].[Settlement] CHECK CONSTRAINT [FK_Settlement_YearlySettlement]
GO
ALTER TABLE [dbo].[TrainingAids]  WITH CHECK ADD  CONSTRAINT [FK_TrainingAids_TrainingStage] FOREIGN KEY([StageID])
REFERENCES [dbo].[TrainingStage] ([StageID])
GO
ALTER TABLE [dbo].[TrainingAids] CHECK CONSTRAINT [FK_TrainingAids_TrainingStage]
GO
ALTER TABLE [dbo].[TrainingExecution]  WITH CHECK ADD  CONSTRAINT [FK_TrainingExecution_TrainingPlan] FOREIGN KEY([ExecutionID])
REFERENCES [dbo].[TrainingPlan] ([ExecutionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainingExecution] CHECK CONSTRAINT [FK_TrainingExecution_TrainingPlan]
GO
ALTER TABLE [dbo].[TrainingExecutionStage]  WITH CHECK ADD  CONSTRAINT [FK_TrainingExecutionStage_TrainingExecution] FOREIGN KEY([ExecutionID])
REFERENCES [dbo].[TrainingExecution] ([ExecutionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainingExecutionStage] CHECK CONSTRAINT [FK_TrainingExecutionStage_TrainingExecution]
GO
ALTER TABLE [dbo].[TrainingExecutionStage]  WITH CHECK ADD  CONSTRAINT [FK_TrainingExecutionStage_TrainingStage] FOREIGN KEY([StageID])
REFERENCES [dbo].[TrainingStage] ([StageID])
GO
ALTER TABLE [dbo].[TrainingExecutionStage] CHECK CONSTRAINT [FK_TrainingExecutionStage_TrainingStage]
GO
ALTER TABLE [dbo].[TrainingItem]  WITH CHECK ADD  CONSTRAINT [FK_TrainingItem_PersonalExercisePurposeItem] FOREIGN KEY([PurposeID])
REFERENCES [dbo].[PersonalExercisePurposeItem] ([ItemID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[TrainingItem] CHECK CONSTRAINT [FK_TrainingItem_PersonalExercisePurposeItem]
GO
ALTER TABLE [dbo].[TrainingItem]  WITH CHECK ADD  CONSTRAINT [FK_TrainingItem_TrainingExecution] FOREIGN KEY([ExecutionID])
REFERENCES [dbo].[TrainingExecution] ([ExecutionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainingItem] CHECK CONSTRAINT [FK_TrainingItem_TrainingExecution]
GO
ALTER TABLE [dbo].[TrainingItem]  WITH CHECK ADD  CONSTRAINT [FK_TrainingItem_TrainingType] FOREIGN KEY([TrainingID])
REFERENCES [dbo].[TrainingType] ([TrainingID])
GO
ALTER TABLE [dbo].[TrainingItem] CHECK CONSTRAINT [FK_TrainingItem_TrainingType]
GO
ALTER TABLE [dbo].[TrainingItemAids]  WITH CHECK ADD  CONSTRAINT [FK_TrainingItemAids_TrainingAids] FOREIGN KEY([AidID])
REFERENCES [dbo].[TrainingAids] ([AidID])
GO
ALTER TABLE [dbo].[TrainingItemAids] CHECK CONSTRAINT [FK_TrainingItemAids_TrainingAids]
GO
ALTER TABLE [dbo].[TrainingItemAids]  WITH CHECK ADD  CONSTRAINT [FK_TrainingItemAids_TrainingItem] FOREIGN KEY([ItemID])
REFERENCES [dbo].[TrainingItem] ([ItemID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainingItemAids] CHECK CONSTRAINT [FK_TrainingItemAids_TrainingItem]
GO
ALTER TABLE [dbo].[TrainingPlan]  WITH CHECK ADD  CONSTRAINT [FK_TrainingPlan_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainingPlan] CHECK CONSTRAINT [FK_TrainingPlan_LessonTime]
GO
ALTER TABLE [dbo].[TrainingPlan]  WITH CHECK ADD  CONSTRAINT [FK_TrainingPlan_LevelExpression] FOREIGN KEY([PlanStatus])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[TrainingPlan] CHECK CONSTRAINT [FK_TrainingPlan_LevelExpression]
GO
ALTER TABLE [dbo].[TrainingPlan]  WITH CHECK ADD  CONSTRAINT [FK_TrainingPlan_RegisterLesson] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[RegisterLesson] ([RegisterID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[TrainingPlan] CHECK CONSTRAINT [FK_TrainingPlan_RegisterLesson]
GO
ALTER TABLE [dbo].[TrainingStageItem]  WITH CHECK ADD  CONSTRAINT [FK_TrainingStageItem_TrainingStage] FOREIGN KEY([StageID])
REFERENCES [dbo].[TrainingStage] ([StageID])
GO
ALTER TABLE [dbo].[TrainingStageItem] CHECK CONSTRAINT [FK_TrainingStageItem_TrainingStage]
GO
ALTER TABLE [dbo].[TrainingStageItem]  WITH CHECK ADD  CONSTRAINT [FK_TrainingStageItem_TrainingType] FOREIGN KEY([TrainingID])
REFERENCES [dbo].[TrainingType] ([TrainingID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TrainingStageItem] CHECK CONSTRAINT [FK_TrainingStageItem_TrainingType]
GO
ALTER TABLE [dbo].[TuitionAchievement]  WITH CHECK ADD  CONSTRAINT [FK_TuitionAchievement_BranchStore] FOREIGN KEY([CoachWorkPlace])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[TuitionAchievement] CHECK CONSTRAINT [FK_TuitionAchievement_BranchStore]
GO
ALTER TABLE [dbo].[TuitionAchievement]  WITH NOCHECK ADD  CONSTRAINT [FK_TuitionAchievement_Payment] FOREIGN KEY([InstallmentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TuitionAchievement] CHECK CONSTRAINT [FK_TuitionAchievement_Payment]
GO
ALTER TABLE [dbo].[TuitionAchievement]  WITH CHECK ADD  CONSTRAINT [FK_TuitionAchievement_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[TuitionAchievement] CHECK CONSTRAINT [FK_TuitionAchievement_ServingCoach]
GO
ALTER TABLE [dbo].[TuitionInstallment]  WITH CHECK ADD  CONSTRAINT [FK_TuitionInstallment_IntuitionCharge] FOREIGN KEY([RegisterID])
REFERENCES [dbo].[IntuitionCharge] ([RegisterID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TuitionInstallment] CHECK CONSTRAINT [FK_TuitionInstallment_IntuitionCharge]
GO
ALTER TABLE [dbo].[TuitionInstallment]  WITH CHECK ADD  CONSTRAINT [FK_TuitionInstallment_Payment] FOREIGN KEY([InstallmentID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TuitionInstallment] CHECK CONSTRAINT [FK_TuitionInstallment_Payment]
GO
ALTER TABLE [dbo].[UserContractStatistic]  WITH CHECK ADD  CONSTRAINT [FK_UserContractStatistic_CourseContract] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CourseContract] ([ContractID])
GO
ALTER TABLE [dbo].[UserContractStatistic] CHECK CONSTRAINT [FK_UserContractStatistic_CourseContract]
GO
ALTER TABLE [dbo].[UserContractStatistic]  WITH CHECK ADD  CONSTRAINT [FK_UserContractStatistic_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[UserContractStatistic] CHECK CONSTRAINT [FK_UserContractStatistic_UserProfile]
GO
ALTER TABLE [dbo].[UserEvent]  WITH CHECK ADD  CONSTRAINT [FK_UserEvent_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[UserEvent] CHECK CONSTRAINT [FK_UserEvent_BranchStore]
GO
ALTER TABLE [dbo].[UserEvent]  WITH CHECK ADD  CONSTRAINT [FK_UserEvent_SystemEventBulletin] FOREIGN KEY([SystemEventID])
REFERENCES [dbo].[SystemEventBulletin] ([EventID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserEvent] CHECK CONSTRAINT [FK_UserEvent_SystemEventBulletin]
GO
ALTER TABLE [dbo].[UserEvent]  WITH CHECK ADD  CONSTRAINT [FK_UserEvent_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserEvent] CHECK CONSTRAINT [FK_UserEvent_UserProfile]
GO
ALTER TABLE [dbo].[UserEventCommitment]  WITH CHECK ADD  CONSTRAINT [FK_UserEventCommitment_UserEvent] FOREIGN KEY([EventID])
REFERENCES [dbo].[UserEvent] ([EventID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserEventCommitment] CHECK CONSTRAINT [FK_UserEventCommitment_UserEvent]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_Attachment] FOREIGN KEY([PictureID])
REFERENCES [dbo].[Attachment] ([AttachmentID])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_Attachment]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_LevelExpression] FOREIGN KEY([LevelID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_LevelExpression]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_UserProfile] FOREIGN KEY([Creator])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_UserProfile]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_UserProfile_UserProfile1] FOREIGN KEY([AuthID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK_UserProfile_UserProfile1]
GO
ALTER TABLE [dbo].[UserProfileExtension]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileExtension_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserProfileExtension] CHECK CONSTRAINT [FK_UserProfileExtension_UserProfile]
GO
ALTER TABLE [dbo].[UserProfileProperty]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileProperty_LevelExpression] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[UserProfileProperty] CHECK CONSTRAINT [FK_UserProfileProperty_LevelExpression]
GO
ALTER TABLE [dbo].[UserProfileProperty]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileProperty_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserProfileProperty] CHECK CONSTRAINT [FK_UserProfileProperty_UserProfile]
GO
ALTER TABLE [dbo].[UserProfileRegistration]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileRegistration_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[UserProfileRegistration] CHECK CONSTRAINT [FK_UserProfileRegistration_BranchStore]
GO
ALTER TABLE [dbo].[UserProfileRegistration]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileRegistration_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserProfileRegistration] CHECK CONSTRAINT [FK_UserProfileRegistration_UserProfile]
GO
ALTER TABLE [dbo].[UserProfileStatistic]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileStatistic_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [dbo].[UserProfileStatistic] CHECK CONSTRAINT [FK_UserProfileStatistic_BranchStore]
GO
ALTER TABLE [dbo].[UserProfileStatistic]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileStatistic_ServingCoach] FOREIGN KEY([AdvisorCoach])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[UserProfileStatistic] CHECK CONSTRAINT [FK_UserProfileStatistic_ServingCoach]
GO
ALTER TABLE [dbo].[UserProfileStatistic]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileStatistic_ServingCoach1] FOREIGN KEY([LastAttendingCoach])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [dbo].[UserProfileStatistic] CHECK CONSTRAINT [FK_UserProfileStatistic_ServingCoach1]
GO
ALTER TABLE [dbo].[UserProfileStatistic]  WITH CHECK ADD  CONSTRAINT [FK_UserProfileStatistic_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserProfileStatistic] CHECK CONSTRAINT [FK_UserProfileStatistic_UserProfile]
GO
ALTER TABLE [dbo].[UserRelationship]  WITH CHECK ADD  CONSTRAINT [FK_UserRelationship_Leader] FOREIGN KEY([LeaderID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[UserRelationship] CHECK CONSTRAINT [FK_UserRelationship_Leader]
GO
ALTER TABLE [dbo].[UserRelationship]  WITH CHECK ADD  CONSTRAINT [FK_UserRelationship_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[UserRelationship] CHECK CONSTRAINT [FK_UserRelationship_UserProfile]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_UserProfile]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_UserRoleDefinition] FOREIGN KEY([RoleID])
REFERENCES [dbo].[UserRoleDefinition] ([RoleID])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_UserRoleDefinition]
GO
ALTER TABLE [dbo].[UserRoleAuthorization]  WITH CHECK ADD  CONSTRAINT [FK_UserRoleAuthorization_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserRoleAuthorization] CHECK CONSTRAINT [FK_UserRoleAuthorization_UserProfile]
GO
ALTER TABLE [dbo].[UserRoleAuthorization]  WITH CHECK ADD  CONSTRAINT [FK_UserRoleAuthorization_UserRoleDefinition] FOREIGN KEY([RoleID])
REFERENCES [dbo].[UserRoleDefinition] ([RoleID])
GO
ALTER TABLE [dbo].[UserRoleAuthorization] CHECK CONSTRAINT [FK_UserRoleAuthorization_UserRoleDefinition]
GO
ALTER TABLE [dbo].[UserSignature]  WITH NOCHECK ADD  CONSTRAINT [FK_UserSignature_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[UserSignature] CHECK CONSTRAINT [FK_UserSignature_UserProfile]
GO
ALTER TABLE [dbo].[VacantInvoiceNo]  WITH CHECK ADD  CONSTRAINT [FK_VacantInvoiceNo_InvoiceNoInterval] FOREIGN KEY([IntervalID])
REFERENCES [dbo].[InvoiceNoInterval] ([IntervalID])
GO
ALTER TABLE [dbo].[VacantInvoiceNo] CHECK CONSTRAINT [FK_VacantInvoiceNo_InvoiceNoInterval]
GO
ALTER TABLE [dbo].[VacantInvoiceNo]  WITH CHECK ADD  CONSTRAINT [FK_VacantInvoiceNo_VacantInvoiceNo] FOREIGN KEY([PrevID])
REFERENCES [dbo].[VacantInvoiceNo] ([VacancyID])
GO
ALTER TABLE [dbo].[VacantInvoiceNo] CHECK CONSTRAINT [FK_VacantInvoiceNo_VacantInvoiceNo]
GO
ALTER TABLE [dbo].[VacantInvoiceNo]  WITH CHECK ADD  CONSTRAINT [FK_VacantInvoiceNo_VacantInvoiceNo1] FOREIGN KEY([NextID])
REFERENCES [dbo].[VacantInvoiceNo] ([VacancyID])
GO
ALTER TABLE [dbo].[VacantInvoiceNo] CHECK CONSTRAINT [FK_VacantInvoiceNo_VacantInvoiceNo1]
GO
ALTER TABLE [dbo].[VoidPayment]  WITH NOCHECK ADD  CONSTRAINT [FK_VoidPayment_LevelExpression] FOREIGN KEY([Status])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[VoidPayment] CHECK CONSTRAINT [FK_VoidPayment_LevelExpression]
GO
ALTER TABLE [dbo].[VoidPayment]  WITH CHECK ADD  CONSTRAINT [FK_VoidPayment_Payment] FOREIGN KEY([VoidID])
REFERENCES [dbo].[Payment] ([PaymentID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[VoidPayment] CHECK CONSTRAINT [FK_VoidPayment_Payment]
GO
ALTER TABLE [dbo].[VoidPayment]  WITH NOCHECK ADD  CONSTRAINT [FK_VoidPayment_UserProfile] FOREIGN KEY([HandlerID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[VoidPayment] CHECK CONSTRAINT [FK_VoidPayment_UserProfile]
GO
ALTER TABLE [dbo].[VoidPaymentLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_VoidPaymentLevel_LevelExpression] FOREIGN KEY([LevelID])
REFERENCES [dbo].[LevelExpression] ([LevelID])
GO
ALTER TABLE [dbo].[VoidPaymentLevel] CHECK CONSTRAINT [FK_VoidPaymentLevel_LevelExpression]
GO
ALTER TABLE [dbo].[VoidPaymentLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_VoidPaymentLevel_UserProfile] FOREIGN KEY([ExecutorID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [dbo].[VoidPaymentLevel] CHECK CONSTRAINT [FK_VoidPaymentLevel_UserProfile]
GO
ALTER TABLE [dbo].[VoidPaymentLevel]  WITH NOCHECK ADD  CONSTRAINT [FK_VoidPaymentLevel_VoidPayment] FOREIGN KEY([VoidID])
REFERENCES [dbo].[VoidPayment] ([VoidID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[VoidPaymentLevel] CHECK CONSTRAINT [FK_VoidPaymentLevel_VoidPayment]
GO
ALTER TABLE [KPI].[MonthlyBranchIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchIndicator_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [KPI].[MonthlyBranchIndicator] CHECK CONSTRAINT [FK_MonthlyBranchIndicator_BranchStore]
GO
ALTER TABLE [KPI].[MonthlyBranchIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchIndicator_MonthlyIndicator] FOREIGN KEY([PeriodID])
REFERENCES [KPI].[MonthlyIndicator] ([PeriodID])
GO
ALTER TABLE [KPI].[MonthlyBranchIndicator] CHECK CONSTRAINT [FK_MonthlyBranchIndicator_MonthlyIndicator]
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueGoal]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchRevenueGoal_MonthlyBranchRevenueIndicator] FOREIGN KEY([PeriodID], [BranchID], [GradeID])
REFERENCES [KPI].[MonthlyBranchRevenueIndicator] ([PeriodID], [BranchID], [GradeID])
ON DELETE CASCADE
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueGoal] CHECK CONSTRAINT [FK_MonthlyBranchRevenueGoal_MonthlyBranchRevenueIndicator]
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchRevenueIndicator_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyBranchRevenueIndicator_BranchStore]
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchRevenueIndicator_MonthlyBranchIndicator] FOREIGN KEY([PeriodID], [BranchID])
REFERENCES [KPI].[MonthlyBranchIndicator] ([PeriodID], [BranchID])
ON DELETE CASCADE
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyBranchRevenueIndicator_MonthlyBranchIndicator]
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchRevenueIndicator_MonthlyIndicator] FOREIGN KEY([PeriodID])
REFERENCES [KPI].[MonthlyIndicator] ([PeriodID])
ON DELETE CASCADE
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyBranchRevenueIndicator_MonthlyIndicator]
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyBranchRevenueIndicator_MonthlyRevenueGrade] FOREIGN KEY([GradeID])
REFERENCES [KPI].[MonthlyRevenueGrade] ([GradeID])
GO
ALTER TABLE [KPI].[MonthlyBranchRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyBranchRevenueIndicator_MonthlyRevenueGrade]
GO
ALTER TABLE [KPI].[MonthlyCoachLearnerReview]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyCoachLearnerReview_MonthlyIndicator] FOREIGN KEY([PeriodID])
REFERENCES [KPI].[MonthlyIndicator] ([PeriodID])
GO
ALTER TABLE [KPI].[MonthlyCoachLearnerReview] CHECK CONSTRAINT [FK_MonthlyCoachLearnerReview_MonthlyIndicator]
GO
ALTER TABLE [KPI].[MonthlyCoachLearnerReview]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyCoachLearnerReview_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [KPI].[MonthlyCoachLearnerReview] CHECK CONSTRAINT [FK_MonthlyCoachLearnerReview_ServingCoach]
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyCoachRevenuIndicator_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyCoachRevenuIndicator_BranchStore]
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyCoachRevenuIndicator_MonthlyIndicator] FOREIGN KEY([PeriodID])
REFERENCES [KPI].[MonthlyIndicator] ([PeriodID])
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyCoachRevenuIndicator_MonthlyIndicator]
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyCoachRevenuIndicator_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyCoachRevenuIndicator_ProfessionalLevel]
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyCoachRevenuIndicator_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [KPI].[MonthlyCoachRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyCoachRevenuIndicator_ServingCoach]
GO
ALTER TABLE [KPI].[MonthlyLearnerReview]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyLearnerReview_MonthlyIndicator] FOREIGN KEY([PeriodID])
REFERENCES [KPI].[MonthlyIndicator] ([PeriodID])
ON DELETE CASCADE
GO
ALTER TABLE [KPI].[MonthlyLearnerReview] CHECK CONSTRAINT [FK_MonthlyLearnerReview_MonthlyIndicator]
GO
ALTER TABLE [KPI].[MonthlyLearnerReview]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyLearnerReview_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [KPI].[MonthlyLearnerReview] CHECK CONSTRAINT [FK_MonthlyLearnerReview_UserProfile]
GO
ALTER TABLE [KPI].[MonthlyRevenueGoal]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyRevenueGoal_MonthlyRevenueIndicator] FOREIGN KEY([PeriodID], [GradeID])
REFERENCES [KPI].[MonthlyRevenueIndicator] ([PeriodID], [GradeID])
ON DELETE CASCADE
GO
ALTER TABLE [KPI].[MonthlyRevenueGoal] CHECK CONSTRAINT [FK_MonthlyRevenueGoal_MonthlyRevenueIndicator]
GO
ALTER TABLE [KPI].[MonthlyRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyRevenueIndicator_MonthlyIndicator] FOREIGN KEY([PeriodID])
REFERENCES [KPI].[MonthlyIndicator] ([PeriodID])
GO
ALTER TABLE [KPI].[MonthlyRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyRevenueIndicator_MonthlyIndicator]
GO
ALTER TABLE [KPI].[MonthlyRevenueIndicator]  WITH CHECK ADD  CONSTRAINT [FK_MonthlyRevenueIndicator_MonthlyRevenueGrade] FOREIGN KEY([GradeID])
REFERENCES [KPI].[MonthlyRevenueGrade] ([GradeID])
GO
ALTER TABLE [KPI].[MonthlyRevenueIndicator] CHECK CONSTRAINT [FK_MonthlyRevenueIndicator_MonthlyRevenueGrade]
GO
ALTER TABLE [Project].[ObjectiveContractLessonPrice]  WITH CHECK ADD  CONSTRAINT [FK_ObjectiveContractLessonPrice_CourseContractType] FOREIGN KEY([ContractType])
REFERENCES [dbo].[CourseContractType] ([TypeID])
GO
ALTER TABLE [Project].[ObjectiveContractLessonPrice] CHECK CONSTRAINT [FK_ObjectiveContractLessonPrice_CourseContractType]
GO
ALTER TABLE [Project].[ObjectiveContractLessonPrice]  WITH CHECK ADD  CONSTRAINT [FK_ObjectiveContractLessonPrice_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [Project].[ObjectiveContractLessonPrice] CHECK CONSTRAINT [FK_ObjectiveContractLessonPrice_LessonPriceType]
GO
ALTER TABLE [Project].[ObjectiveLessonLocation]  WITH CHECK ADD  CONSTRAINT [FK_ObjectiveLessonLocation_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [Project].[ObjectiveLessonLocation] CHECK CONSTRAINT [FK_ObjectiveLessonLocation_BranchStore]
GO
ALTER TABLE [Project].[ObjectiveLessonLocation]  WITH CHECK ADD  CONSTRAINT [FK_ObjectiveLessonLocation_ObjectiveLessonCatalog] FOREIGN KEY([CatalogID])
REFERENCES [Project].[ObjectiveLessonCatalog] ([CatalogID])
GO
ALTER TABLE [Project].[ObjectiveLessonLocation] CHECK CONSTRAINT [FK_ObjectiveLessonLocation_ObjectiveLessonCatalog]
GO
ALTER TABLE [Project].[ObjectiveLessonPrice]  WITH CHECK ADD  CONSTRAINT [FK_ObjectiveLessonPrice_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
GO
ALTER TABLE [Project].[ObjectiveLessonPrice] CHECK CONSTRAINT [FK_ObjectiveLessonPrice_LessonPriceType]
GO
ALTER TABLE [Project].[ObjectiveLessonPrice]  WITH CHECK ADD  CONSTRAINT [FK_ObjectiveLessonPrice_ObjectiveLessonCatalog] FOREIGN KEY([CatalogID])
REFERENCES [Project].[ObjectiveLessonCatalog] ([CatalogID])
GO
ALTER TABLE [Project].[ObjectiveLessonPrice] CHECK CONSTRAINT [FK_ObjectiveLessonPrice_ObjectiveLessonCatalog]
GO
ALTER TABLE [Report].[BranchMonthlySummary]  WITH CHECK ADD  CONSTRAINT [FK_BranchMonthlySummary_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [Report].[BranchMonthlySummary] CHECK CONSTRAINT [FK_BranchMonthlySummary_BranchStore]
GO
ALTER TABLE [Report].[BranchMonthlySummary]  WITH CHECK ADD  CONSTRAINT [FK_BranchMonthlySummary_Settlement] FOREIGN KEY([SettlementID])
REFERENCES [dbo].[Settlement] ([SettlementID])
GO
ALTER TABLE [Report].[BranchMonthlySummary] CHECK CONSTRAINT [FK_BranchMonthlySummary_Settlement]
GO
ALTER TABLE [Report].[CoachBranchMonthlyBonus]  WITH CHECK ADD  CONSTRAINT [FK_CoachBranchMonthlyBonus_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [Report].[CoachBranchMonthlyBonus] CHECK CONSTRAINT [FK_CoachBranchMonthlyBonus_BranchStore]
GO
ALTER TABLE [Report].[CoachBranchMonthlyBonus]  WITH CHECK ADD  CONSTRAINT [FK_CoachBranchMonthlyBonus_CoachMonthlySalary] FOREIGN KEY([CoachID], [SettlementID])
REFERENCES [Report].[CoachMonthlySalary] ([CoachID], [SettlementID])
ON DELETE CASCADE
GO
ALTER TABLE [Report].[CoachBranchMonthlyBonus] CHECK CONSTRAINT [FK_CoachBranchMonthlyBonus_CoachMonthlySalary]
GO
ALTER TABLE [Report].[CoachMonthlySalary]  WITH CHECK ADD  CONSTRAINT [FK_CoachMonthlySalary_BranchStore] FOREIGN KEY([WorkPlace])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [Report].[CoachMonthlySalary] CHECK CONSTRAINT [FK_CoachMonthlySalary_BranchStore]
GO
ALTER TABLE [Report].[CoachMonthlySalary]  WITH CHECK ADD  CONSTRAINT [FK_CoachMonthlySalary_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [Report].[CoachMonthlySalary] CHECK CONSTRAINT [FK_CoachMonthlySalary_ProfessionalLevel]
GO
ALTER TABLE [Report].[CoachMonthlySalary]  WITH CHECK ADD  CONSTRAINT [FK_CoachMonthlySalary_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [Report].[CoachMonthlySalary] CHECK CONSTRAINT [FK_CoachMonthlySalary_ServingCoach]
GO
ALTER TABLE [Report].[CoachMonthlySalary]  WITH CHECK ADD  CONSTRAINT [FK_CoachMonthlySalary_Settlement] FOREIGN KEY([SettlementID])
REFERENCES [dbo].[Settlement] ([SettlementID])
ON DELETE CASCADE
GO
ALTER TABLE [Report].[CoachMonthlySalary] CHECK CONSTRAINT [FK_CoachMonthlySalary_Settlement]
GO
ALTER TABLE [Report].[CoachMonthlySalary]  WITH CHECK ADD  CONSTRAINT [FK_CoachMonthlySalary_YearlySettlement] FOREIGN KEY([Year])
REFERENCES [dbo].[YearlySettlement] ([Year])
GO
ALTER TABLE [Report].[CoachMonthlySalary] CHECK CONSTRAINT [FK_CoachMonthlySalary_YearlySettlement]
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay]  WITH CHECK ADD  CONSTRAINT [FK_CoachYearlyAdditionalPay_BranchStore] FOREIGN KEY([WorkPlace])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay] CHECK CONSTRAINT [FK_CoachYearlyAdditionalPay_BranchStore]
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay]  WITH CHECK ADD  CONSTRAINT [FK_CoachYearlyAdditionalPay_ProfessionalLevel] FOREIGN KEY([LevelID])
REFERENCES [dbo].[ProfessionalLevel] ([LevelID])
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay] CHECK CONSTRAINT [FK_CoachYearlyAdditionalPay_ProfessionalLevel]
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay]  WITH CHECK ADD  CONSTRAINT [FK_CoachYearlyAdditionalPay_ServingCoach] FOREIGN KEY([CoachID])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay] CHECK CONSTRAINT [FK_CoachYearlyAdditionalPay_ServingCoach]
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay]  WITH CHECK ADD  CONSTRAINT [FK_CoachYearlyAdditionalPay_YearlySettlement] FOREIGN KEY([Year])
REFERENCES [dbo].[YearlySettlement] ([Year])
GO
ALTER TABLE [Report].[CoachYearlyAdditionalPay] CHECK CONSTRAINT [FK_CoachYearlyAdditionalPay_YearlySettlement]
GO
ALTER TABLE [Report].[EmployeeSalaryExtension]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeSalaryExtension_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [Report].[EmployeeSalaryExtension] CHECK CONSTRAINT [FK_EmployeeSalaryExtension_UserProfile]
GO
ALTER TABLE [Report].[MonthlySalaryDetails]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySalaryDetails_MonthlySalary] FOREIGN KEY([SalaryID])
REFERENCES [Report].[MonthlySalary] ([SalaryID])
ON DELETE CASCADE
GO
ALTER TABLE [Report].[MonthlySalaryDetails] CHECK CONSTRAINT [FK_MonthlySalaryDetails_MonthlySalary]
GO
ALTER TABLE [Report].[MonthlySalaryDetails]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySalaryDetails_Settlement] FOREIGN KEY([SettlementID])
REFERENCES [dbo].[Settlement] ([SettlementID])
GO
ALTER TABLE [Report].[MonthlySalaryDetails] CHECK CONSTRAINT [FK_MonthlySalaryDetails_Settlement]
GO
ALTER TABLE [Report].[MonthlySalaryDetails]  WITH CHECK ADD  CONSTRAINT [FK_MonthlySalaryDetails_UserProfile] FOREIGN KEY([UID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [Report].[MonthlySalaryDetails] CHECK CONSTRAINT [FK_MonthlySalaryDetails_UserProfile]
GO
ALTER TABLE [Report].[PromptLessonQuestion]  WITH CHECK ADD  CONSTRAINT [FK_PromptLessonQuestion_LessonTime] FOREIGN KEY([LessonID])
REFERENCES [dbo].[LessonTime] ([LessonID])
ON DELETE CASCADE
GO
ALTER TABLE [Report].[PromptLessonQuestion] CHECK CONSTRAINT [FK_PromptLessonQuestion_LessonTime]
GO
ALTER TABLE [Report].[PromptLessonQuestion]  WITH CHECK ADD  CONSTRAINT [FK_PromptLessonQuestion_PDQTask] FOREIGN KEY([TaskID])
REFERENCES [dbo].[PDQTask] ([TaskID])
ON DELETE SET NULL
GO
ALTER TABLE [Report].[PromptLessonQuestion] CHECK CONSTRAINT [FK_PromptLessonQuestion_PDQTask]
GO
ALTER TABLE [Report].[PromptLessonRequirement]  WITH CHECK ADD  CONSTRAINT [FK_PromptLessonRequirement_LessonPriceType] FOREIGN KEY([PriceID])
REFERENCES [dbo].[LessonPriceType] ([PriceID])
ON DELETE CASCADE
GO
ALTER TABLE [Report].[PromptLessonRequirement] CHECK CONSTRAINT [FK_PromptLessonRequirement_LessonPriceType]
GO
ALTER TABLE [tmp].[ContactTime]  WITH CHECK ADD  CONSTRAINT [FK_ContactTime_TrialLearner] FOREIGN KEY([UID])
REFERENCES [tmp].[TrialLearner] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [tmp].[ContactTime] CHECK CONSTRAINT [FK_ContactTime_TrialLearner]
GO
ALTER TABLE [tmp].[HowToKnow]  WITH CHECK ADD  CONSTRAINT [FK_HowToKnow_MediaPlatform] FOREIGN KEY([MediaID])
REFERENCES [tmp].[MediaPlatform] ([MediaID])
GO
ALTER TABLE [tmp].[HowToKnow] CHECK CONSTRAINT [FK_HowToKnow_MediaPlatform]
GO
ALTER TABLE [tmp].[HowToKnow]  WITH CHECK ADD  CONSTRAINT [FK_HowToKnow_TrialLearner] FOREIGN KEY([UID])
REFERENCES [tmp].[TrialLearner] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [tmp].[HowToKnow] CHECK CONSTRAINT [FK_HowToKnow_TrialLearner]
GO
ALTER TABLE [tmp].[ReferralFrom]  WITH CHECK ADD  CONSTRAINT [FK_ReferralFrom_HealthcareInstitution] FOREIGN KEY([HID])
REFERENCES [tmp].[HealthcareInstitution] ([HID])
GO
ALTER TABLE [tmp].[ReferralFrom] CHECK CONSTRAINT [FK_ReferralFrom_HealthcareInstitution]
GO
ALTER TABLE [tmp].[ReferralFrom]  WITH CHECK ADD  CONSTRAINT [FK_ReferralFrom_TrialLearner] FOREIGN KEY([UID])
REFERENCES [tmp].[TrialLearner] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [tmp].[ReferralFrom] CHECK CONSTRAINT [FK_ReferralFrom_TrialLearner]
GO
ALTER TABLE [tmp].[TrialLearner]  WITH CHECK ADD  CONSTRAINT [FK_TrialLearner_BranchStore] FOREIGN KEY([BranchID])
REFERENCES [dbo].[BranchStore] ([BranchID])
GO
ALTER TABLE [tmp].[TrialLearner] CHECK CONSTRAINT [FK_TrialLearner_BranchStore]
GO
ALTER TABLE [tmp].[TrialLearner]  WITH CHECK ADD  CONSTRAINT [FK_TrialLearner_ServingCoach1] FOREIGN KEY([AttendingCoach])
REFERENCES [dbo].[ServingCoach] ([CoachID])
GO
ALTER TABLE [tmp].[TrialLearner] CHECK CONSTRAINT [FK_TrialLearner_ServingCoach1]
GO
ALTER TABLE [tmp].[TrialLearner]  WITH CHECK ADD  CONSTRAINT [FK_TrialLearner_UserProfile] FOREIGN KEY([NormalUID])
REFERENCES [dbo].[UserProfile] ([UID])
ON DELETE SET NULL
GO
ALTER TABLE [tmp].[TrialLearner] CHECK CONSTRAINT [FK_TrialLearner_UserProfile]
GO
ALTER TABLE [tmp].[TrialLearner]  WITH CHECK ADD  CONSTRAINT [FK_TrialLearner_UserProfile1] FOREIGN KEY([AssigneeID])
REFERENCES [dbo].[UserProfile] ([UID])
GO
ALTER TABLE [tmp].[TrialLearner] CHECK CONSTRAINT [FK_TrialLearner_UserProfile1]
GO
ALTER TABLE [tmp].[TrialLearnerPurpose]  WITH CHECK ADD  CONSTRAINT [FK_TrialLearnerPurpose_BeyondHelp] FOREIGN KEY([HelpID])
REFERENCES [tmp].[BeyondHelp] ([HelpID])
GO
ALTER TABLE [tmp].[TrialLearnerPurpose] CHECK CONSTRAINT [FK_TrialLearnerPurpose_BeyondHelp]
GO
ALTER TABLE [tmp].[TrialLearnerPurpose]  WITH CHECK ADD  CONSTRAINT [FK_TrialLearnerPurpose_TrialLearner] FOREIGN KEY([UID])
REFERENCES [tmp].[TrialLearner] ([UID])
ON DELETE CASCADE
GO
ALTER TABLE [tmp].[TrialLearnerPurpose] CHECK CONSTRAINT [FK_TrialLearnerPurpose_TrialLearner]
GO
/****** Object:  StoredProcedure [dbo].[DeleteRedundantTrack]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteRedundantTrack]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DELETE FROM ContractTrustTrack
	FROM     ContractTrustTrack INNER JOIN
					CourseContract ON ContractTrustTrack.ContractID = CourseContract.ContractID
	WHERE   (CourseContract.ContractDate < '2018/2/14')


	DELETE FROM ContractTrustTrack
	FROM     ContractTrustTrack INNER JOIN
					Payment ON ContractTrustTrack.PaymentID = Payment.PaymentID INNER JOIN
					VoidPayment ON Payment.PaymentID = VoidPayment.VoidID
	WHERE   EXISTS
						(SELECT  NULL AS Expr1
						FROM     InvoiceCancellation
						WHERE   (InvoiceID = Payment.InvoiceID))

	delete FROM ContractTrustTrack
	where ContractID in (SELECT  c.ContractID
	FROM     CourseContract AS c INNER JOIN
					CourseContractExtension ON c.ContractID = CourseContractExtension.ContractID INNER JOIN
					CourseContractRevision ON CourseContractExtension.RevisionTrackingID = CourseContractRevision.RevisionID INNER JOIN
					CourseContract AS o ON CourseContractRevision.OriginalContract = o.ContractID
	WHERE   (o.EffectiveDate < '2018/2/14'))

END


GO
/****** Object:  StoredProcedure [dbo].[InquireAllVacantNo]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[InquireAllVacantNo]
	( 
		@Year		int,
		@PeriodNo	int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  VacantInvoiceNo.InvoiceNo, InvoiceTrackCode.Year, InvoiceTrackCode.PeriodNo, InvoiceTrackCode.TrackCode, InvoiceNoInterval.StartNo, 
				InvoiceNoInterval.EndNo, InvoiceNoInterval.TrackID, InvoiceNoInterval.SellerID, VacantInvoiceNo.NextID AS CheckNext, 
				VacantInvoiceNo.PrevID AS CheckPrev
	FROM     VacantInvoiceNo INNER JOIN
				InvoiceNoInterval ON VacantInvoiceNo.IntervalID = InvoiceNoInterval.IntervalID INNER JOIN
				InvoiceTrackCodeAssignment ON InvoiceNoInterval.TrackID = InvoiceTrackCodeAssignment.TrackID AND 
				InvoiceNoInterval.SellerID = InvoiceTrackCodeAssignment.SellerID INNER JOIN
				InvoiceTrackCode ON InvoiceTrackCodeAssignment.TrackID = InvoiceTrackCode.TrackID
	WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo) AND 
				(VacantInvoiceNo.NextID IS NULL OR VacantInvoiceNo.PrevID IS NULL)
	ORDER BY VacantInvoiceNo.IntervalID, VacantInvoiceNo.InvoiceNo

END



GO
/****** Object:  StoredProcedure [dbo].[InquireVacantNo]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[InquireVacantNo]
	( 
		@SellerID	int,
		@Year		int,
		@PeriodNo	int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  VacantInvoiceNo.InvoiceNo, InvoiceTrackCode.Year, InvoiceTrackCode.PeriodNo, InvoiceTrackCode.TrackCode, InvoiceNoInterval.StartNo, 
				InvoiceNoInterval.EndNo, InvoiceNoInterval.TrackID, InvoiceNoInterval.SellerID, VacantInvoiceNo.NextID AS CheckNext, 
				VacantInvoiceNo.PrevID AS CheckPrev
	FROM     VacantInvoiceNo INNER JOIN
				InvoiceNoInterval ON VacantInvoiceNo.IntervalID = InvoiceNoInterval.IntervalID INNER JOIN
				InvoiceTrackCodeAssignment ON InvoiceNoInterval.TrackID = InvoiceTrackCodeAssignment.TrackID AND 
				InvoiceNoInterval.SellerID = InvoiceTrackCodeAssignment.SellerID INNER JOIN
				InvoiceTrackCode ON InvoiceTrackCodeAssignment.TrackID = InvoiceTrackCode.TrackID
	WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo) AND (InvoiceNoInterval.SellerID = @SellerID) AND 
				(VacantInvoiceNo.NextID IS NULL OR VacantInvoiceNo.PrevID IS NULL)
	ORDER BY VacantInvoiceNo.IntervalID, VacantInvoiceNo.InvoiceNo

END



GO
/****** Object:  StoredProcedure [dbo].[PaySalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PaySalary]
	( 
		@Payday	date,
		@SalaryType	int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @SalaryID	int
	INSERT INTO [Report].[MonthlySalary]
				 (Payday, SalaryType)
	VALUES (@Payday,@SalaryType)

	set @SalaryID = IDENT_CURRENT('[Report].[MonthlySalary]')

	INSERT INTO Report.MonthlySalaryDetails
               (SalaryID, UID, SettlementID, Salary, Subsistence, SpecialBonus, WillingContribution, LaborInsurrance, HealthInsurrance, Tax, ActualAmount, Remark, 
               SickLeave, PersonalLeave, HealthSupplement, DutyAllowance, BasicWage, Pension, LaborInsurranceByEmployer, HealthInsurranceByEmployer, AchievementBonus, AttendanceBonus, AchievementRemark, ManagementBonus, StaffWelfareFund)
	SELECT  @SalaryID, UserProfile.UID, TmpSalary.SettlementID, TmpSalary.薪資, TmpSalary.伙食津貼, TmpSalary.特別獎金, TmpSalary.自願提繳, 
				   TmpSalary.勞保費, TmpSalary.健保費, TmpSalary.所得稅, TmpSalary.應收金額, TmpSalary.備註, TmpSalary.[病假(半薪)], TmpSalary.[事假(無薪)], 
				   TmpSalary.二代健保, Report.EmployeeSalaryExtension.DutyAllowance, s.PermanentWage, TmpSalary.公司提撥退休金, TmpSalary.公司提撥勞保費, 
				   TmpSalary.公司提撥健保費, TmpSalary.業績獎金, TmpSalary.上課獎金, TmpSalary.備註二, TmpSalary.管理獎金, TmpSalary.職福金
	FROM     UserProfile INNER JOIN
				   TmpSalary ON UserProfile.UID = TmpSalary.CoachID AND UserProfile.RealName = TmpSalary.員工姓名 LEFT OUTER JOIN
				   Report.EmployeeSalaryExtension ON UserProfile.UID = Report.EmployeeSalaryExtension.UID LEFT OUTER JOIN
				   ServingCoach AS c INNER JOIN
				   ProfessionalLevel AS p ON c.LevelID = p.LevelID INNER JOIN
				   ProfessionalLevelBasicSalary AS b ON p.LevelID = b.LevelID INNER JOIN
				   SalaryDetails AS s ON b.SalaryID = s.SalaryID ON UserProfile.UID = c.CoachID

	TRUNCATE TABLE TmpSalary
	
END
GO
/****** Object:  StoredProcedure [dbo].[ProcessInvoiceNo]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ProcessInvoiceNo]
	( 
		@SellerID	int,
		@Year		int,
		@PeriodNo	int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @theYear	DateTime
	set @theYear = DATEFROMPARTS(@Year,1,1)
	declare @startDate	DateTime = DATEADD(MONTH,@PeriodNo*2-2,@theYear)
	declare @endDate	DateTime = DATEADD(MONTH,@PeriodNo*2,@theYear)
	--select @theYear,@startDate,@endDate

	INSERT INTO InvoiceNoAssignment
					(InvoiceID, IntervalID, InvoiceNo)
	SELECT  i.InvoiceID, s.IntervalID,i.No
	FROM     InvoiceItem AS i INNER JOIN
						(SELECT  InvoiceTrackCode.TrackCode, InvoiceTrackCodeAssignment.SellerID, InvoiceNoInterval.StartNo, InvoiceNoInterval.EndNo, 
										InvoiceNoInterval.IntervalID
						FROM     InvoiceTrackCode INNER JOIN
										InvoiceTrackCodeAssignment ON InvoiceTrackCode.TrackID = InvoiceTrackCodeAssignment.TrackID INNER JOIN
										InvoiceNoInterval ON InvoiceTrackCodeAssignment.TrackID = InvoiceNoInterval.TrackID AND 
										InvoiceTrackCodeAssignment.SellerID = InvoiceNoInterval.SellerID
						WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo)) AS s ON i.SellerID = s.SellerID AND i.TrackCode = s.TrackCode AND 
					i.No >= s.StartNo AND i.No <= s.EndNo
	WHERE   (i.InvoiceDate >= @startDate) AND (i.InvoiceDate < @endDate) AND (i.SellerID = @SellerID)
	and InvoiceID not in (select InvoiceID from InvoiceNoAssignment)

	UPDATE VacantInvoiceNo
	SET        PrevID = NULL, NextID = NULL
	FROM     VacantInvoiceNo INNER JOIN
				   InvoiceNoInterval ON VacantInvoiceNo.IntervalID = InvoiceNoInterval.IntervalID INNER JOIN
				   InvoiceTrackCodeAssignment ON InvoiceNoInterval.TrackID = InvoiceTrackCodeAssignment.TrackID AND 
				   InvoiceNoInterval.SellerID = InvoiceTrackCodeAssignment.SellerID INNER JOIN
				   InvoiceTrackCode ON InvoiceTrackCodeAssignment.TrackID = InvoiceTrackCode.TrackID
	WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo) AND (InvoiceTrackCodeAssignment.SellerID = @SellerID)

	DELETE FROM VacantInvoiceNo
	FROM     VacantInvoiceNo INNER JOIN
				   InvoiceNoInterval ON VacantInvoiceNo.IntervalID = InvoiceNoInterval.IntervalID INNER JOIN
				   InvoiceTrackCodeAssignment ON InvoiceNoInterval.TrackID = InvoiceTrackCodeAssignment.TrackID AND 
				   InvoiceNoInterval.SellerID = InvoiceTrackCodeAssignment.SellerID INNER JOIN
				   InvoiceTrackCode ON InvoiceTrackCodeAssignment.TrackID = InvoiceTrackCode.TrackID
	WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo) AND (InvoiceTrackCodeAssignment.SellerID = @SellerID)

	declare @TotalRows int
	SELECT @TotalRows = ISNull(sum(InvoiceNoInterval.EndNo-InvoiceNoInterval.StartNo+1),0)
	FROM     InvoiceNoInterval INNER JOIN
				   InvoiceTrackCodeAssignment ON InvoiceNoInterval.TrackID = InvoiceTrackCodeAssignment.TrackID AND 
				   InvoiceNoInterval.SellerID = InvoiceTrackCodeAssignment.SellerID INNER JOIN
				   InvoiceTrackCode ON InvoiceTrackCodeAssignment.TrackID = InvoiceTrackCode.TrackID 
	WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo) AND (InvoiceTrackCodeAssignment.SellerID = @SellerID)

	;
	with v as (
		select * from (
	SELECT TOP (@TotalRows) InvoiceNoInterval.IntervalID, ROW_NUMBER() over (partition by IntervalID order by IntervalID ) + StartNo-1 as InvoiceNo,
		 InvoiceNoInterval.StartNo, InvoiceNoInterval.EndNo
	FROM     InvoiceNoInterval INNER JOIN
				   InvoiceTrackCodeAssignment ON InvoiceNoInterval.TrackID = InvoiceTrackCodeAssignment.TrackID AND 
				   InvoiceNoInterval.SellerID = InvoiceTrackCodeAssignment.SellerID INNER JOIN
				   InvoiceTrackCode ON InvoiceTrackCodeAssignment.TrackID = InvoiceTrackCode.TrackID CROSS JOIN
				   sys.objects a cross join sys.objects b --cross join sys.objects c
	WHERE   (InvoiceTrackCode.Year = @Year) AND (InvoiceTrackCode.PeriodNo = @PeriodNo) AND (InvoiceTrackCodeAssignment.SellerID = @SellerID)
	) t where InvoiceNo<=EndNo
	)
	INSERT INTO VacantInvoiceNo
				   (IntervalID, InvoiceNo)
	select IntervalID,InvoiceNo from v
	where Not Exists (select null from InvoiceNoAssignment where IntervalID=v.IntervalID and InvoiceNo=v.InvoiceNo)

	--DELETE FROM VacantInvoiceNo
	--FROM     VacantInvoiceNo INNER JOIN
	--			   InvoiceNoAssignment ON VacantInvoiceNo.IntervalID = InvoiceNoAssignment.IntervalID AND 
	--			   VacantInvoiceNo.InvoiceNo = InvoiceNoAssignment.InvoiceNo

	UPDATE VacantInvoiceNo
	SET        NextID = v2.VacancyID
	FROM     VacantInvoiceNo INNER JOIN
				   VacantInvoiceNo AS v2 ON VacantInvoiceNo.IntervalID = v2.IntervalID AND VacantInvoiceNo.InvoiceNo + 1 = v2.InvoiceNo

	UPDATE VacantInvoiceNo
	SET        PrevID = v2.VacancyID
	FROM     VacantInvoiceNo INNER JOIN
				   VacantInvoiceNo AS v2 ON VacantInvoiceNo.IntervalID = v2.IntervalID AND VacantInvoiceNo.InvoiceNo - 1 = v2.InvoiceNo

	
	
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateSalary]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateSalary]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE Report.MonthlySalaryDetails
	SET        SpecialBonus = TmpSalary.特別獎金, WillingContribution = TmpSalary.自願提繳, LaborInsurrance = TmpSalary.勞保費, 
				   HealthInsurrance = TmpSalary.健保費, Tax = TmpSalary.所得稅, ActualAmount = TmpSalary.應收金額, Remark = TmpSalary.備註, 
				   SickLeave = TmpSalary.[病假(半薪)], PersonalLeave = TmpSalary.[事假(無薪)], HealthSupplement = TmpSalary.二代健保, 
				   Pension = TmpSalary.公司提撥退休金, LaborInsurranceByEmployer = TmpSalary.公司提撥勞保費, 
				   HealthInsurranceByEmployer = TmpSalary.公司提撥健保費, Salary = TmpSalary.薪資, SalaryDutyAllowance = TmpSalary.職務加給, 
				   Subsistence = TmpSalary.伙食津貼, AchievementBonus = TmpSalary.業績獎金, AttendanceBonus = TmpSalary.上課獎金, AchievementRemark = TmpSalary.備註二, 
				   ManagementBonus = TmpSalary.管理獎金, StaffWelfareFund = TmpSalary.職福金
	FROM     TmpSalary INNER JOIN
				   Report.MonthlySalaryDetails ON TmpSalary.CoachID = Report.MonthlySalaryDetails.UID AND 
				   TmpSalary.SettlementID = Report.MonthlySalaryDetails.SettlementID

	TRUNCATE TABLE TmpSalary
	
END
GO
/****** Object:  Trigger [BG].[TR_LessonMissionBonus]    Script Date: 2026/5/16 上午 11:05:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [BG].[TR_LessonMissionBonus]
   ON [BG].[LessonMissionBonus]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM BG.BonusDepositSettlement
	FROM     BG.BonusTransaction INNER JOIN
				   deleted ON BG.BonusTransaction.BonusID = deleted.BonusID INNER JOIN
				   BG.BonusDepositSettlement ON BG.BonusTransaction.TransactionID = BG.BonusDepositSettlement.TransactionID

	DELETE FROM BG.BonusTransaction
	FROM     BG.BonusTransaction INNER JOIN
               deleted ON BG.BonusTransaction.BonusID = deleted.BonusID

	DELETE FROM BG.CampaignMissionBonus
	FROM     BG.CampaignMissionBonus INNER JOIN
               deleted ON BG.CampaignMissionBonus.BonusID = deleted.BonusID

    -- Insert statements for trigger here

END
GO
ALTER TABLE [BG].[LessonMissionBonus] ENABLE TRIGGER [TR_LessonMissionBonus]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Document', @level2type=N'COLUMN',@level2name=N'DocDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統文件主檔' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Document'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentType', @level2type=N'COLUMN',@level2name=N'TypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentType', @level2type=N'COLUMN',@level2name=N'TypeName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'文件定對檔' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DocumentType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EnterpriseCourseContract', @level2type=N'COLUMN',@level2name=N'CompanyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'折讓證明單號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowance', @level2type=N'COLUMN',@level2name=N'AllowanceNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'折讓種類
1:買方開立折讓證明單
2:賣方折讓證明單通知
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowance', @level2type=N'COLUMN',@level2name=N'AllowanceType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'折讓證明單日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowance', @level2type=N'COLUMN',@level2name=N'AllowanceDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'金額(不含稅之進貨額)合計' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowance', @level2type=N'COLUMN',@level2name=N'TotalAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'營業稅額合計' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowance', @level2type=N'COLUMN',@level2name=N'TaxAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作廢日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowanceCancellation', @level2type=N'COLUMN',@level2name=N'CancelDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作廢折讓備註
作廢折讓時必填，填寫作廢原因' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAllowanceCancellation', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'課稅別
1：應稅
2：零稅率
3：免稅
9：混合應稅與免稅或零稅率 (限收銀機發票無法分辨時使用)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'TaxType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'應稅銷售額合計(新台幣)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'SalesAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'營業稅額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'TaxAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'稅率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'TaxRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'總計
整數
(應稅銷售額合計+免稅銷售額合計+零稅率銷售額合計+營業稅額=此總計欄位) ，可為負數' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'TotalAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中文國字大寫金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'TotalAmountInChinese'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'扣抵金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'DiscountAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'角分調整' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'Adjustment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'原幣金額' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'OriginalCurrencyAmount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'匯率' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceAmountType', @level2type=N'COLUMN',@level2name=N'ExchangeRate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作廢發票號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCancellation', @level2type=N'COLUMN',@level2name=N'CancellationNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作廢日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCancellation', @level2type=N'COLUMN',@level2name=N'CancelDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'專案作廢核准文號
若發票的作廢時間超過申報期間，則此欄位為必填欄位。若不填寫由上傳營業人自行負責。' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCancellation', @level2type=N'COLUMN',@level2name=N'ReturnTaxDocumentNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'作廢備註
作廢發票時必填，填寫作廢原因' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCancellation', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCancellationDispatchLog', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCarrier', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'載具類別
1：悠遊卡
2：UXB2B條碼卡' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCarrier', @level2type=N'COLUMN',@level2name=N'CarrierType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'載具卡號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceCarrier', @level2type=N'COLUMN',@level2name=N'CarrierNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceDonation', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'機構代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceDonation', @level2type=N'COLUMN',@level2name=N'AgencyCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'發票號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'No'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'發票日期' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'InvoiceDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'發票檢查碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'CheckNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'總備註' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'Remark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'買受人註記欄
1：得抵扣之進貨及費用；
2：得抵扣之固定資產；
3：不得抵扣之進貨及費用；
4：不得抵扣之固定資產
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'BuyerRemark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'通關方式註記
1：非經海關出口;
2：經海關出口(零稅率時，為必要欄位)
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'CustomsClearanceMark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'稅捐稽徵處名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'TaxCenter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准日' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'PermitDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准文' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'PermitWord'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'核准號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'PermitNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'沖帳別' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'Category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'相關號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'RelateNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'發票類別
1: 三聯式;
2: 二聯式;
3: 二聯式收銀機;
4. 特種稅額;
5: 電子計算機;
6: 三聯式收銀機
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'InvoiceType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'彙開註記
以”*”表示 彙開' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'GroupMark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'捐贈註記
以”0”表示 非捐贈發票
以”1”表示 為捐贈發票
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'DonateMark'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'發票防偽隨機碼
前端隨機產生' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItem', @level2type=N'COLUMN',@level2name=N'RandomNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItemDispatch', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceItemDispatchLog', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'中獎號碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InvoiceWinningNumber', @level2type=N'COLUMN',@level2name=N'WinningNO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'連絡人' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'ContactName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'傳真' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'Fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'機關名稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'CompanyName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'主鍵' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'CompanyID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'統一編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'ReceiptNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'電話' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'Phone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'負責人姓名' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'UndertakerName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'地址' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'Addr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'連絡人電子郵件' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'ContactEmail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'連絡人職稱' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'ContactTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Payment', @level2type=N'COLUMN',@level2name=N'InvoiceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'載具類別
1：悠遊卡
2：UXB2B條碼卡' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserProfileExtension', @level2type=N'COLUMN',@level2name=N'CarrierType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'載具卡號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'UserProfileExtension', @level2type=N'COLUMN',@level2name=N'CarrierNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "UserProfile"
            Begin Extent = 
               Top = 9
               Left = 57
               Bottom = 189
               Right = 276
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UserProfileExtension"
            Begin Extent = 
               Top = 9
               Left = 333
               Bottom = 164
               Right = 552
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LearnerFitnessAssessment"
            Begin Extent = 
               Top = 9
               Left = 609
               Bottom = 164
               Right = 841
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LearnerFitnessAssessmentResult"
            Begin Extent = 
               Top = 9
               Left = 898
               Bottom = 164
               Right = 1117
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FitnessAssessmentItem"
            Begin Extent = 
               Top = 9
               Left = 1174
               Bottom = 164
               Right = 1393
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Fil' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_LearnerFitenessAssessment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'ter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_LearnerFitenessAssessment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'V_LearnerFitenessAssessment'
GO
