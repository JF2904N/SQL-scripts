USE TempDataLake
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [COMMWEB].[pr_Load_CurationTable_YTD]

AS

BEGIN
-- Declare variables to insert/update RWL.PROCESS_LOG table:
DECLARE @ProcessDate date, @ApplicationName varchar(500), @ProcessZone varchar(500), @PackageName varchar(500), @TaskName varchar(500),
		@SrcTableName varchar(500), @TgtTableName varchar(500), @Comments varchar(500), @ProcessStatus varchar(500), 
		@StartTS datetime, @EndTS datetime,	@RowCount int, @ProcessUser varchar(100)

SET @ProcessDate = GETDATE()
SET @ApplicationName = 'COMMWEB_LANDING'
SET @ProcessZone = 'Curation'
SET @PackageName = NULL 
SET @TaskName = NULL
SET @SrcTableName= 'GMPCommission.[SSRS].[pr_GetPayoutCurrentMonthSummary]' 
SET @TgtTableName = '[commweb_landing].[CommYTDSummary]'
SET @ProcessStatus = 'Started'
SET @StartTS = GETDATE()
SET @ProcessUser = USER_NAME()

-- Variables to be used in stored proc to get Commission Detail Report --
DECLARE @UserID varchar(50) = 'adelaide\mlam'  --review whos ID to use
DECLARE @IACode varchar(10) = '0'
DECLARE @ToIACode varchar(10) = '0'
DECLARE @ProcessingDate datetime 
DECLARE @IncludeInactiveCodes bit = 0
DECLARE @IsWholeMonth bit = 1


/*-- Get LoadID: */
DECLARE @LoadID int
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE id = object_id('tempdb.dbo.#tmpLoadId'))  
 BEGIN  
 DROP TABLE #tmpLoadId  
 END  

CREATE TABLE #tmpLoadId ( LoadId int NULL )

INSERT INTO #tmpLoadId
EXEC RWL.[pr_Insert_PROCESS_LOG_OnBegin] @ProcessDate, @ApplicationName, @ProcessZone, @PackageName, @TaskName,
		@SrcTableName, @TgtTableName, @ProcessStatus, @StartTS, @ProcessUser

SELECT @LoadID = LoadId FROM #tmpLoadId


-- Get most recent date from GMPCommission --
SELECT @ProcessingDate = GMPCommission.[payout].[udf_GetMaxProcessingDate]()	--MAX(ProcessingDate) from GMPCommission.dbo.CMCommissionTrades

DECLARE @YTDStartDate datetime 
SET @YTDStartDate = CAST(CAST(YEAR(@ProcessingDate) as varchar(4)) + '-01-01' as varchar(10))

	--select @ProcessingDate as ProcessingDate, @YTDStartDate as YTDStartDate


-- Create temporary table to store stored proc results --
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE id = object_id('tempdb.dbo.#tmpCurrentMonthSummary'))
	BEGIN
	DROP TABLE #tmpCurrentMonthSummary
	END

CREATE TABLE #tmpCurrentMonthSummary
(
	[IaId] [varchar](10) NULL,
	[ToIaId] [varchar](10) NULL,
	[IsGrossSplitCode] [decimal] (18,4) NULL,
	[GrossSplitPct] [decimal] (18,4) NULL,
	[FeeRevPayoutPct] [decimal] (18,4) NULL,
	[TranRevPayoutPct] [decimal] (18,4) NULL,
	[FIRevPayoutPct] [decimal] (18,4) NULL,
	[RegFeePayoutPct] [decimal] (18,4) NULL,
	[TotalGrossRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[TRFITLGrossRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[NIPayoutRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[PMANewIssueNoPayoutRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[InsuranceRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[OtherRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[TotalFeeRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[FeeAMARevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[FeePMARevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[FeeSMARevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[FeeUMARevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[RegFeeRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[EmpRegFeeRevenue_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[TotalNetPayout_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[DiscountFees_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[AMAExcessTrades_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[PMAExcessTrades_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	[FinalNetPayout_TODAY] [decimal] (18,4) NULL DEFAULT 0,
	
	[TotalGrossRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[TRFITLGrossRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[NIPayoutRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[PMANewIssueNoPayoutRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[InsuranceRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[OtherRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[TotalFeeRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeeAMARevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeePMARevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeeSMARevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeeUMARevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[RegFeeRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[EmpRegFeeRevenue_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[TotalNetPayout_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[DiscountFees_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[AMAExcessTrades_MTD] [decimal] (18,4) NULL DEFAULT 0,
	[PMAExcessTrades_MTD] [decimal] (18,4) NULL DEFAULT 0,	
	[FinalNetPayout_MTD] [decimal] (18,4) NULL DEFAULT 0,
	
	[TotalGrossRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[TRFITLGrossRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[NIPayoutRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[PMANewIssueNoPayoutRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[InsuranceRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[OtherRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[TotalFeeRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeeAMARevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeePMARevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeeSMARevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[FeeUMARevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[RegFeeRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[EmpRegFeeRevenue_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[TotalNetPayout_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[DiscountFees_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[AMAExcessTrades_YTD] [decimal] (18,4) NULL DEFAULT 0,
	[PMAExcessTrades_YTD] [decimal] (18,4) NULL DEFAULT 0,			
	[FinalNetPayout_YTD] [decimal] (18,4) NULL DEFAULT 0
)


INSERT INTO #tmpCurrentMonthSummary
  EXEC GMPCommission.[SSRS].[pr_GetPayoutCurrentMonthSummary] @UserID, @IACode, @ToIACode, @ProcessingDate, @IncludeInactiveCodes


CREATE INDEX idx_IaId ON #tmpCurrentMonthSummary(IaId)
CREATE INDEX idx_ToIaId ON #tmpCurrentMonthSummary(ToIaId)

	--select * from #tmpCurrentMonthSummary


-- Try to figure which month to use --
DECLARE @CommProcessId INT	--, @CommProcessIdStart INT, @CommProcessIdEnd INT
DECLARE @MonthEndDate as datetime, @PrevMonthEndDate as datetime
SET @MonthEndDate = DATEADD(d, -1, DATEADD(m, 1, CAST(CONVERT(Varchar(8), @ProcessingDate, 120) + '01' AS DATETIME)))
SET @PrevMonthEndDate = DATEADD(d, -1, CAST(CONVERT(Varchar(8), @ProcessingDate, 120) + '01' AS DATETIME))
	
DECLARE @ToMonth INT
SET @ToMonth = MONTH(@ProcessingDate) 
			+ case 
				when GMPCommission.payout.udf_IsClosedMonth(@ProcessingDate)=1 then -1 -- exclude closed month
				when GMPCommission.payout.udf_IsClosedMonth(@ProcessingDate)=0 and GMPCommission.payout.udf_IsCurrentMonth(@ProcessingDate)=0 then -1 -- previous month not close
				when GMPCommission.payout.udf_IsClosedMonth(@ProcessingDate)=0 and GMPCommission.payout.udf_IsCurrentMonth(@ProcessingDate)=1 -- current month not close
					and GMPCommission.payout.udf_IsClosedMonth(@PrevMonthEndDate)=0 then -2 -- and previous month not close
				else -1 -- current month not close and previous month closed
				end



/*------------------------------------------------------------
	 Get YTD Data from MonthlyCommissionSummary table 
	   and insert YTD data into #tmpFinalYTDSummary
	 (available only after biz day 4 & 6)	
------------------------------------------------------------*/
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE id = object_id('tempdb.dbo.#tmpYTDSummary'))
	BEGIN
	DROP TABLE #tmpYTDSummary
	END

;WITH tmpTF as	-- Summarize monthly trailer fees
  (
	SELECT  tf.CommProcessId, 
			CASE WHEN tf.IsGrossSplitCode = 1 THEN ajs.IaId ELSE tf.IaId END as IaId, 
			CASE WHEN tf.IsGrossSplitCode = 1 THEN ajs.ToIaId ELSE tf.IaId END as ToIaId,
		   SUM(CASE WHEN tf.IsGrossSplitCode = 1 THEN ajs.AdjAmount ELSE tf.AdjAmount END) as MonthlyTFRevenue
	FROM GMPCommission.dbo.Adjustments tf	
	LEFT JOIN GMPCommission.dbo.AdjustmentsSplits ajs on tf.CommProcessId = ajs.CommProcessId and tf.AdjId = ajs.AdjId 
				and isnull(ajs.ProcessingDate,'9999-12-31') = isnull(tf.ProcessingDate,'9999-12-31')
	--LEFT JOIN #tmpGrossRevenueSplits sp on tf.IaId = sp.IaId and tf.CommProcessId = sp.CommProcessId
	WHERE tf.Bucket IN ('TF','ST')
		AND tf.ProcessingDate between @YTDStartDate and @PrevMonthEndDate
	GROUP BY tf.CommProcessId, 
			 CASE WHEN tf.IsGrossSplitCode = 1 THEN ajs.IaId ELSE tf.IaId END, 
			 CASE WHEN tf.IsGrossSplitCode = 1 THEN ajs.ToIaId ELSE tf.IaId END
	HAVING SUM(tf.AdjAmount) <> 0
  )

, tmpGIC as		-- Summarize monthly GIC Commissions
  (
	SELECT  g.CommProcessId, 
			CASE WHEN g.IsGrossSplitCode = 1 THEN ajs.IaId ELSE g.IaId END as IaId, 
			CASE WHEN g.IsGrossSplitCode = 1 THEN ajs.ToIaId ELSE g.IaId END as ToIaId,
		   SUM(CASE WHEN g.IsGrossSplitCode = 1 THEN ajs.AdjAmount ELSE g.AdjAmount END) as MonthlyGICComm
	FROM GMPCommission.dbo.Adjustments g	
	LEFT JOIN GMPCommission.dbo.AdjustmentsSplits ajs on g.CommProcessId = ajs.CommProcessId and g.AdjId = ajs.AdjId 
				and isnull(ajs.ProcessingDate,'9999-12-31') = isnull(g.ProcessingDate,'9999-12-31')
	WHERE g.Bucket = 'GC'
		AND g.ProcessingDate between @YTDStartDate and @PrevMonthEndDate
	GROUP BY g.CommProcessId, 
			 CASE WHEN g.IsGrossSplitCode = 1 THEN ajs.IaId ELSE g.IaId END, 
			 CASE WHEN g.IsGrossSplitCode = 1 THEN ajs.ToIaId ELSE g.IaId END
	HAVING SUM(g.AdjAmount) <> 0
  )

, tmpSMASCComm AS
  (
	SELECT	ct.CommProcessId,
			CASE WHEN ct.IsGrossSplitCode = 1 THEN cts.IaId ELSE ct.TradeRR END as IaId, 
			CASE WHEN ct.IsGrossSplitCode = 1 THEN cts.ToIaId ELSE ct.TradeRR END as ToIaId, 
			SUM(CASE WHEN ct.IsGrossSplitCode = 1 THEN cts.GrossCommissionCAD ELSE ct.GrossCommissionCAD END) AS SMASCCommNPRevenue	
	FROM GMPCommission.dbo.CommissionTrades ct 
	INNER JOIN GMPCommission.dbo.CodeConfig cc on ct.PortType = cc.Code_Value and cc.Category = 'SMA' and cc.IsDisabled = 0
	LEFT JOIN GMPCommission.dbo.CommissionTradesSplits cts on cts.CommProcessId = ct.CommProcessId
		and cts.ProcessingDate = ct.ProcessingDate
		and cts.TradeNumber = ct.TradeNumber
	WHERE ABS(GrossCommission) = 10
	GROUP BY ct.CommProcessId,
			 CASE WHEN ct.IsGrossSplitCode = 1 THEN cts.IaId ELSE ct.TradeRR END, 
			 CASE WHEN ct.IsGrossSplitCode = 1 THEN cts.ToIaId ELSE ct.TradeRR END
	HAVING SUM(CASE WHEN ct.IsGrossSplitCode = 1 THEN cts.GrossCommissionCAD ELSE ct.GrossCommissionCAD END) <> 0
  )
		

SELECT s.IaId, s.ToIaId, @ProcessingDate as BusinessDate,
		SUM(s.TradeGrossRev) as TradeGrossRev_YTD, 
		SUM(s.TradeLessGrossRev) as TradeLessGrossRev_YTD, 
		SUM(s.FIGrossRev) as FIGrossRev_YTD, 
		SUM(s.AMANoPayout_GrossRev) AS AMANPGrossRev_YTD, 
		SUM(s.PMAMCGrossRev) as PMAMCGrossRev_YTD, 
		SUM(IsNull(sc.SMASCCommNPRevenue,0)) as SMASCCommNPRev_YTD, 
		SUM(s.USFeeGrossRev) as USFeeGrossRev_YTD, 
		SUM(s.USPMA_GrossRev) as USPMAGrossRev_YTD, 
		SUM(s.USSMA_GrossRev) as USSMAGrossRev_YTD, 
		SUM(IsNull(tf.MonthlyTFRevenue,0)) as TrailerFeeGrossRev_YTD, 
		SUM(IsNull(gi.MonthlyGICComm,0)) AS GICCommGrossRev_YTD, 
		SUM(S.TradeNetPayout) AS TradeNetPayout_YTD, 
		SUM(s.FINetPayout) as FINetPayout_YTD, 
		SUM(s.NINetPayout) as NINetPayout_YTD, 
		SUM(s.InsuranceNetPayout) as InsuranceNetPayout_YTD, 
		SUM(s.OtherNetPayout) as OtherNetPayout_YTD, 
		SUM(s.FeeNetPayout) + SUM(s.USFeeNetPayout) as TotalFeeNetPayout_YTD, 	
		SUM(s.AMA_GrossRev * s.FeeRevPayoutPct/100) as AMAFeeNetPayout_YTD, 
		SUM(s.PMA_GrossRev * s.FeeRevPayoutPct/100) 
		  + SUM(s.USPMA_GrossRev * s.USFeeRevPayoutPct/100) as PMAFeeNetPayout_YTD, 
		SUM(s.SMA_GrossRev * s.FeeRevPayoutPct/100) 
		  + SUM(s.USSMA_GrossRev * s.USFeeRevPayoutPct/100) as SMAFeeNetPayout_YTD, 	
		SUM(s.UMA_GrossRev * s.FeeRevPayoutPct/100) as UMAFeeNetPayout_YTD, 
		SUM(s.RegNetPayout) as RegFeeNetPayout_YTD, 
		SUM(s.USFeeNetPayout) as USFeeNetPayout_YTD, 
		SUM(s.USPMA_GrossRev * s.USFeeRevPayoutPct/100) as USPMAFeeNetPayout_YTD, 
		SUM(s.USSMA_GrossRev * s.USFeeRevPayoutPct/100) as USSMAFeeNetPayout_YTD
INTO #tmpYTDSummary
FROM GMPCommission.dbo.MonthlyCommissionSummary s
LEFT JOIN tmpTF tf on s.CommProcessId = tf.CommProcessId and s.IaId = tf.IaId and s.ToIaId = tf.ToIaId
LEFT JOIN tmpGIC gi on s.CommProcessId = gi.CommProcessId and s.IaId = gi.IaId and s.ToIaId = gi.ToIaId
LEFT JOIN tmpSMASCComm sc on s.CommProcessId = sc.CommProcessId and s.IaId = sc.IaId and s.ToIaId = sc.ToIaId
WHERE s.ProcessYear = YEAR(@ProcessingDate) and s.ProcessMonth between 1 and @ToMonth
GROUP BY s.IaId, s.ToIaId
	
	

BEGIN TRY
/**  Summarize all YTD data, add MTD data to #tmpYTDSummary  **/
INSERT INTO [commweb_landing].[CommYTDSummary]
SELECT
	ytd.IaId, ytd.ToIaId, @ProcessingDate as BusinessDate,
	ytd.TotalGrossRevenue_YTD,
	ytd.TRFITLGrossRevenue_YTD,
	ytd.NIPayoutRevenue_YTD,
	ytd.PMANewIssueNoPayoutRevenue_YTD,
	ytd.InsuranceRevenue_YTD,
	ytd.OtherRevenue_YTD,
	ytd.TotalFeeRevenue_YTD,
	ytd.FeeAMARevenue_YTD,
	ytd.FeePMARevenue_YTD,
	ytd.FeeSMARevenue_YTD,
	ytd.FeeUMARevenue_YTD,
	ytd.RegFeeRevenue_YTD,
	ytd.EmpRegFeeRevenue_YTD,
	ytd.TotalNetPayout_YTD,
	ytd.DiscountFees_YTD,
	ytd.AMAExcessTrades_YTD,
	ytd.PMAExcessTrades_YTD,
	ytd.FinalNetPayout_YTD,

	s.TradeGrossRev_YTD + m.TranRevenue_MTD as TranRevenue_YTD,
	s.TradeLessGrossRev_YTD + m.TranNPRevenue_MTD as TranNPRevenue_YTD,
	s.FIGrossRev_YTD + m.FIRevenue50To100_MTD as FIRevenue50To100_YTD,
	s.AMANPGrossRev_YTD + m.FeeAMARevenueNP_MTD as FeeAMARevenueNP_YTD,
	s.PMAMCGrossRev_YTD + m.PMAMCCommNoPayoutRevenue_MTD as PMAMCCommNoPayoutRevenue_YTD,
	s.SMASCCommNPRev_YTD + m.SMASCCommNoPayoutRevenue_MTD as SMASCCommNoPayoutRevenue_YTD,
	s.USFeeGrossRev_YTD + m.TotalUSFeeRevenue_MTD as TotalUSFeeRevenue_YTD,
	s.USPMAGrossRev_YTD + m.USFeePMARevenue_MTD as USFeePMARevenue_YTD,
	s.USSMAGrossRev_YTD + m.USFeeSMARevenue_MTD as USFeeSMARevenue_YTD,
	s.TrailerFeeGrossRev_YTD + m.TrailerFeeRevenue_MTD as TrailerFeeRevenue_YTD,
	s.GICCommGrossRev_YTD + m.GICCommRevenue_MTD as GICCommRevenue_YTD,
	s.TradeNetPayout_YTD + m.TranNetPayout_MTD as TranNetPayout_YTD,
	s.FINetPayout_YTD + m.FINetPayout_MTD as FINetPayout_YTD,
	s.NINetPayout_YTD + m.NINetPayout_MTD as NINetPayout_YTD,
	s.InsuranceNetPayout_YTD + m.InsuranceNetPayout_MTD as InsuranceNetPayout_YTD,
	s.OtherNetPayout_YTD + m.OtherNetPayout_MTD as OtherNetPayout_YTD,
	s.TotalFeeNetPayout_YTD + m.TotalFeeNetPayout_MTD as TotalFeeNetPayout_YTD,
	s.AMAFeeNetPayout_YTD + m.FeeAMANetPayout_MTD as FeeAMANetPayout_YTD,
	s.PMAFeeNetPayout_YTD + m.FeePMANetPayout_MTD as FeePMANetPayout_YTD,
	s.SMAFeeNetPayout_YTD + m.FeeSMANetPayout_MTD as FeeSMANetPayout_YTD,
	s.UMAFeeNetPayout_YTD + m.FeeUMANetPayout_MTD as FeeUMANetPayout_YTD,
	s.RegFeeNetPayout_YTD + m.RegFeeNetPayout_MTD as RegFeeNetPayout_YTD,
	s.USFeeNetPayout_YTD + m.USFeeNetPayout_MTD as USFeeNetPayout_YTD,
	s.USPMAFeeNetPayout_YTD + m.USFeePMANetPayout_MTD as USFeePMANetPayout_YTD,
	s.USSMAFeeNetPayout_YTD + m.USFeeSMANetPayout_MTD as USFeeSMANetPayout_YTD

FROM #tmpCurrentMonthSummary ytd 
LEFT JOIN #tmpYTDSummary s on ytd.IaId = s.IaId and ytd.ToIaId = s.ToIaId 
LEFT JOIN TempDataLake.commweb_landing.CommMTDSummary m on m.IaId = ytd.IaId and m.ToIaId = ytd.ToIaId

SELECT @RowCount=Count(*) FROM [commweb_landing].[CommYTDSummary] WHERE [BusinessDate]=(SELECT MAX([BUSINESSDATE]) FROM [commweb_landing].[CommYTDSummary])
	IF @RowCount > 0	-- Load is successful
		SET @ProcessStatus='Completed Successfully'	
		SET @Comments='SUCCESS: commweb_landing.CommYTDSummary Loaded'
		SET @EndTS = GETDATE()
		
		EXEC RWL.[pr_Update_PROCESS_LOG_OnEnd] @LoadId, @ProcessStatus, @Comments, @EndTS, @RowCount
END TRY
BEGIN CATCH
    -- If there is an error
    SET @ProcessStatus = 'Error while loading'
    SET @Comments = 'ErrNum=' + CAST(ERROR_NUMBER() AS varchar(20)) + ' ' + ERROR_MESSAGE()
    SET @EndTS = GETDATE()

    EXEC RWL.[pr_Update_PROCESS_LOG_OnFailure] @LoadId, @ProcessStatus, @Comments, @EndTS
END CATCH
END
GO