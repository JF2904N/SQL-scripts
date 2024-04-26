USE [TempDataLake]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [COMMWEB].[pr_Load_COMM_DAILY_SUMMARY]

AS

BEGIN


-- Declare variables to insert/update RWL.PROCESS_LOG table:
DECLARE @ProcessDate date, @ApplicationName varchar(500), @ProcessZone varchar(500), @PackageName varchar(500), @TaskName varchar(500),
		@SrcTableName varchar(500), @TgtTableName varchar(500), @Comments varchar(500), @ProcessStatus varchar(500), 
		@StartTS datetime, @EndTS datetime,	@RowCount int, @ProcessUser varchar(100)

SET @ProcessDate = GETDATE()
SET @ApplicationName = 'COMMWEB'
SET @ProcessZone = 'Curation'
SET @PackageName = NULL 
SET @TaskName = NULL
SET @SrcTableName= 'commweb_landing.CommDailySummary' 
SET @TgtTableName = 'COMMWEB.COMM_DAILY_SUMMARY'
SET @ProcessStatus = 'Started'
SET @StartTS = GETDATE()
SET @ProcessUser = USER_NAME()


DECLARE @LoadID int

/*-- Get LoadID: */
IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects WHERE id = object_id('tempdb.dbo.#tmpLoadId'))  
 BEGIN  
 DROP TABLE #tmpLoadId  
 END  

CREATE TABLE #tmpLoadId ( LoadId int NULL )

INSERT INTO #tmpLoadId
EXEC RWL.[pr_Insert_PROCESS_LOG_OnBegin] @ProcessDate, @ApplicationName, @ProcessZone, @PackageName, @TaskName,
		@SrcTableName, @TgtTableName, @ProcessStatus, @StartTS, @ProcessUser

SELECT @LoadID = LoadId FROM #tmpLoadId

--SET @LoadID =5

/*-- Archive data before truncating current day table-------------------------------------------------------------------------------------------------------------------------------*/
DECLARE @RowCountCommDAILYSummary INT, @ERROR VARCHAR(1000)

SELECT @RowCountCommDAILYSummary = COUNT(*) FROM [COMMWEB].[COMM_DAILY_SUMMARY]

IF @RowCountCommDAILYSummary = 0
BEGIN
    SET @ERROR = '[COMMWEB].[pr_Load_COMM_DAILY_SUMMARY] failed. [COMMWEB].[COMM_DAILY_SUMMARY] has no data. Process ending.'
    PRINT @ERROR
    RAISERROR (@ERROR, 15, 1)
    RETURN
END
ELSE
BEGIN
	-- Copy current date data from COMMWEB.COMM_DAILY_SUMMARY to HIST table

	INSERT INTO [COMMWEB].[COMM_DAILY_SUMMARY_HIST]
				([IA_CODE]
				,[TO_IA_CODE]
				,[BUSINESS_DATE]
				,[GROSS_SPLIT_CODE]
				,[GROSS_SPLIT_PCT]
				,[FEE_REV_PAYOUT_PCT]
				,[TRAN_REV_PAYOUT_PCT]
				,[FI_REV_PAYOUT_PCT]
				,[REG_FEE_PAYOUT_PCT]
				,[TOTAL_GROSS_REV]
				,[TRFITL_GROSS_REV]
				,[NI_PAYOUT_REV]
				,[PMA_NEW_ISSUE_NOPAYOUT_REV]
				,[INS_REV]
				,[OTH_REV]
				,[TOTAL_FEE_REV]
				,[AMA_FEE_REV]
				,[PMA_FEE_REV]
				,[SMA_FEE_REV]
				,[UMA_FEE_REV]
				,[REG_FEE_REV]
				,[EMP_REG_FEE_REV]
				,[TOTAL_NET_PAYOUT]
				,[DISCOUNT_FEE]
				,[AMA_EXCESS_TRADE]
				,[PMA_EXCESS_TRADE]
				,[FINAL_NET_PAYOUT]
				,[TRAN_TR_REV]
				,[TRAN_TL_REV]
				,[FI_REV]
				,[AMA_NOPAY_REV]
				,[PMA_MC_NOPAY_REV]
				,[SMA_SC_NOPAY_REV]
				,[TOTAL_US_FEE_REV]
				,[US_FEE_PMA_REV]
				,[US_FEE_SMA_REV]
				,[TF_FEE_REV]
				,[GIC_COMM_REV]
				,[TRAN_TR_NETPAYOUT]
				,[FI_NETPAYOUT]
				,[NI_NETPAYOUT]
				,[INS_NETPAYOUT]
				,[OTH_NETPAYOUT]
				,[TOTAL_FEE_NETPAYOUT]
				,[AMA_FEE_NETPAYOUT]
				,[PMA_FEE_NETPAYOUT]
				,[SMA_FEE_NETPAYOUT]
				,[UMA_FEE_NETPAYOUT]
				,[REG_FEE_NETPAYOUT]
				,[US_FEE_NETPAYOUT]
				,[US_PMA_FEE_NETPAYOUT]
				,[US_SMA_FEE_NETPAYOUT]
				,[US_FEE_REV_PAYOUT_PCT]
				,[INS_REV_PAYOUT_PCT]
				,[X_ATTRIB1]
				,[X_ATTRIB2]
				,[X_ATTRIB3]
				,[X_ATTRIB4]
				,[X_ATTRIB5]
				,[LOAD_ID]
				,[DL_CREATE_DATE_TS]
				,[DL_UPD_DATE_TS]
				,[DL_CREATE_BY]
				,[DL_UPD_BY])
						
	SELECT  [IA_Code]
			,[TO_IA_CODE]
			,[BUSINESS_DATE]
			,[GROSS_SPLIT_CODE]
			,[GROSS_SPLIT_PCT]
			,[FEE_REV_PAYOUT_PCT]
			,[TRAN_REV_PAYOUT_PCT]
			,[FI_REV_PAYOUT_PCT]
			,[REG_FEE_PAYOUT_PCT]
			,[TOTAL_GROSS_REV]
			,[TRFITL_GROSS_REV]
			,[NI_PAYOUT_REV]
			,[PMA_NEW_ISSUE_NOPAYOUT_REV]
			,[INS_REV]
			,[OTH_REV]
			,[TOTAL_FEE_REV]
			,[AMA_FEE_REV]
			,[PMA_FEE_REV]
			,[SMA_FEE_REV]
			,[UMA_FEE_REV]
			,[REG_FEE_REV]
			,[EMP_REG_FEE_REV]
			,[TOTAL_NET_PAYOUT]
			,[DISCOUNT_FEE]
			,[AMA_EXCESS_TRADE]
			,[PMA_EXCESS_TRADE]
			,[FINAL_NET_PAYOUT]
			,[TRAN_TR_REV]
			,[TRAN_TL_REV]
			,[FI_REV]
			,[AMA_NOPAY_REV]
			,[PMA_MC_NOPAY_REV]
			,[SMA_SC_NOPAY_REV]
			,[TOTAL_US_FEE_REV]
			,[US_FEE_PMA_REV]
			,[US_FEE_SMA_REV]
			,[TF_FEE_REV]
			,[GIC_COMM_REV]
			,[TRAN_TR_NETPAYOUT]
			,[FI_NETPAYOUT]
			,[NI_NETPAYOUT]
			,[INS_NETPAYOUT]
			,[OTH_NETPAYOUT]
			,[TOTAL_FEE_NETPAYOUT]
			,[AMA_FEE_NETPAYOUT]
			,[PMA_FEE_NETPAYOUT]
			,[SMA_FEE_NETPAYOUT]
			,[UMA_FEE_NETPAYOUT]
			,[REG_FEE_NETPAYOUT]
			,[US_FEE_NETPAYOUT]
			,[US_PMA_FEE_NETPAYOUT]
			,[US_SMA_FEE_NETPAYOUT]
			,[US_FEE_REV_PAYOUT_PCT]
			,[INS_REV_PAYOUT_PCT]
			,[X_ATTRIB1]
			,[X_ATTRIB2]
			,[X_ATTRIB3]
			,[X_ATTRIB4]
			,[X_ATTRIB5]
			,[LOAD_ID]
			,[DL_CREATE_DATE_TS]
			,[DL_UPD_DATE_TS]
			,[DL_CREATE_BY]
			,[DL_UPD_BY]
	FROM [COMMWEB].[COMM_DAILY_SUMMARY]
	WHERE [BUSINESS_DATE] = (SELECT MAX([BUSINESS_DATE]) FROM [COMMWEB].[COMM_DAILY_SUMMARY])
END
-- Truncate current day table
TRUNCATE TABLE [COMMWEB].[COMM_DAILY_SUMMARY]

-- Update process log
SET @ProcessStatus = 'Processing DAILY table'
SET @Comments = 'DAILY table processed successfully into HIST'
SET @EndTS = GETDATE()

EXEC RWL.[pr_Update_PROCESS_LOG_OnEnd] @LoadId, @ProcessStatus, @Comments, @EndTS, @RowCount

-- If processing is successful, load the landing table into COMMWEB.COMM_DAILY_SUMMARY table
-- Check that landing table has data:
DECLARE @LandingCount int, @ERROR_MSG varchar(1000)
SELECT @LandingCount = COUNT(*) FROM [commweb_landing].[CommDAILYSummary]
IF @LandingCount = 0
  BEGIN
    SET @ERROR_MSG='[COMMWEB].[pr_Load_COMM_DAILY_SUMMARY] failed. [commweb_landing].[CommDAILYSummary] has no data. Process ending.'
	PRINT @ERROR_MSG 
	RAISERROR (@ERROR_MSG,15,1)
	RETURN
  END

-- If processing is successful, load the landing table into COMMWEB.COMM_DAILY_SUMMARY table
BEGIN TRY
    -- Load data from landing table into COMMWEB.COMM_DAILY_SUMMARY
    INSERT INTO [COMMWEB].[COMM_DAILY_SUMMARY]
		([IA_Code]
		,[TO_IA_CODE]
		,[BUSINESS_DATE]
		,[GROSS_SPLIT_CODE]
		,[GROSS_SPLIT_PCT]
		,[FEE_REV_PAYOUT_PCT]
		,[TRAN_REV_PAYOUT_PCT]
		,[FI_REV_PAYOUT_PCT]
		,[REG_FEE_PAYOUT_PCT]
		,[TOTAL_GROSS_REV]
		,[TRFITL_GROSS_REV]
		,[NI_PAYOUT_REV]
		,[PMA_NEW_ISSUE_NOPAYOUT_REV]
		,[INS_REV]
		,[OTH_REV]
		,[TOTAL_FEE_REV]
		,[AMA_FEE_REV]
		,[PMA_FEE_REV]
		,[SMA_FEE_REV]
		,[UMA_FEE_REV]
		,[REG_FEE_REV]
		,[EMP_REG_FEE_REV]
		,[TOTAL_NET_PAYOUT]
		,[DISCOUNT_FEE]
		,[AMA_EXCESS_TRADE]
		,[PMA_EXCESS_TRADE]
		,[FINAL_NET_PAYOUT]
		,[TRAN_TR_REV]
		,[TRAN_TL_REV]
		,[FI_REV]
		,[AMA_NOPAY_REV]
		,[PMA_MC_NOPAY_REV]
		,[SMA_SC_NOPAY_REV]
		,[TOTAL_US_FEE_REV]
		,[US_FEE_PMA_REV]
		,[US_FEE_SMA_REV]
		,[TF_FEE_REV]
		,[GIC_COMM_REV]
		,[TRAN_TR_NETPAYOUT]
		,[FI_NETPAYOUT]
		,[NI_NETPAYOUT]
		,[INS_NETPAYOUT]
		,[OTH_NETPAYOUT]
		,[TOTAL_FEE_NETPAYOUT]
		,[AMA_FEE_NETPAYOUT]
		,[PMA_FEE_NETPAYOUT]
		,[SMA_FEE_NETPAYOUT]
		,[UMA_FEE_NETPAYOUT]
		,[REG_FEE_NETPAYOUT]
		,[US_FEE_NETPAYOUT]
		,[US_PMA_FEE_NETPAYOUT]
		,[US_SMA_FEE_NETPAYOUT]
		,[US_FEE_REV_PAYOUT_PCT]
		,[INS_REV_PAYOUT_PCT]
		,[X_ATTRIB1]
		,[X_ATTRIB2]
		,[X_ATTRIB3]
		,[X_ATTRIB4]
		,[X_ATTRIB5]
		,[LOAD_ID]
		,[DL_CREATE_DATE_TS]
		,[DL_UPD_DATE_TS]
		,[DL_CREATE_BY]
		,[DL_UPD_BY])
	SELECT [IaId]
		  ,[ToIaId]
		  ,[BusinessDate]
		  ,CAST([IsGrossSplitCode] as int)
		  ,CAST([GrossSplitPct] as decimal(8,4))
		  ,CAST([FeeRevPayoutPct] as decimal(8,4))
		  ,CAST([TranRevPayoutPct] as decimal(8,4))
		  ,CAST([FIRevPayoutPct] as decimal(8,4))
		  ,CAST([RegFeePayoutPct] as decimal(8,4))
		  ,[TotalGrossRevenue_TODAY]
		  ,[RegularRevenue_TODAY]
		  ,[NIRevenue_TODAY]
		  ,[PMANewIssueNoPayoutRevenue_TODAY]
		  ,[InsuranceRevenue_TODAY]
		  ,[OtherRevenue_TODAY]
		  ,[TotalFeeRevenue_TODAY]
		  ,[FeeAMARevenue_TODAY]
		  ,[FeePMARevenue_TODAY]
		  ,[FeeSMARevenue_TODAY]
		  ,[FeeUMARevenue_TODAY]
		  ,[RegFeeRevenue_TODAY]
		  ,[EmpRegFeeRevenue_TODAY]
		  ,[TotalNetPayout_TODAY]
		  ,[DiscountFees_TODAY]
		  ,[AMAExcessTrades_TODAY]
		  ,[PMAExcessTrades_TODAY]
		  ,[FinalNetPayout_TODAY]
		  ,[TranRevenue_TODAY]
		  ,[TranNPRevenue_TODAY]
		  ,[FIRevenue50To100_TODAY]
	      ,[FeeAMARevenueNP_TODAY]
		  ,[PMAMCCommNoPayoutRevenue_TODAY]
		  ,[SMASCCommNoPayoutRevenue_TODAY]
		  ,[TotalUSFeeRevenue_TODAY]
          ,[USFeePMARevenue_TODAY]
          ,[USFeeSMARevenue_TODAY]
		  ,[TrailerFeeRevenue_TODAY]
          ,[GICCommRevenue_TODAY]
          ,[TranNetPayout_TODAY]
          ,[FINetPayout_TODAY]
          ,[NINetPayout_TODAY]
          ,[InsuranceNetPayout_TODAY]
          ,[OtherNetPayout_TODAY]
          ,[TotalFeeNetPayout_TODAY]
          ,[FeeAMANetPayout_TODAY]
          ,[FeePMANetPayout_TODAY]
          ,[FeeSMANetPayout_TODAY]
          ,[FeeUMANetPayout_TODAY]
          ,[RegFeeNetPayout_TODAY]
          ,[USFeeNetPayout_TODAY]
          ,[USFeePMANetPayout_TODAY]
          ,[USFeeSMANetPayout_TODAY]
          ,[USFeeRevPayoutPct]
          ,[InsuranceRevPayoutPct]
		  ,[X_ATTRIB1]
	      ,[X_ATTRIB2]
		  ,[X_ATTRIB3]
		  ,[X_ATTRIB4]
		  ,[X_ATTRIB5]
		  ,@LoadID					
		  --,@SrcTableName	
		  ,GETDATE()
		  ,GETDATE()
		  ,@ProcessUser
		 ,@ProcessUser
  FROM [commweb_landing].[CommDailySummary]

SELECT @RowCount=Count(*) FROM COMMWEB.COMM_DAILY_SUMMARY WHERE [Business_Date]=(SELECT MAX([BUSINESS_DATE]) FROM COMMWEB.COMM_DAILY_SUMMARY)
	IF @RowCount > 0	-- Load is successful
		SET @ProcessStatus='Completed Successfully'	
		SET @Comments='SUCCESS: COMMWEB.COMM_DAILY_SUMMARY Loaded'
		SET @EndTS = GETDATE()
		
		EXEC RWL.[pr_Update_PROCESS_LOG_OnEnd] @LoadId, @ProcessStatus, @Comments, @EndTS, @RowCount

END TRY

BEGIN CATCH
    -- If there is an error
    SET @ProcessStatus = 'Error while loading'
    SET @Comments = 'ErrNum=' + CAST(ERROR_NUMBER() AS varchar(20)) + ' ' + ERROR_MESSAGE()
    SET @EndTS = GETDATE()

    EXEC RWL.[pr_Update_PROCESS_LOG_OnFailure] @LoadId, @ProcessStatus, @Comments, @EndTS

    -- Truncate current day table and recover from history table by finding data of the max business date
    TRUNCATE TABLE [COMMWEB].[COMM_DAILY_SUMMARY]

    INSERT INTO [COMMWEB].[COMM_DAILY_SUMMARY_HIST]
			([IA_CODE]
			,[TO_IA_CODE]
			,[BUSINESS_DATE]
			,[GROSS_SPLIT_CODE]
			,[GROSS_SPLIT_PCT]
			,[FEE_REV_PAYOUT_PCT]
			,[TRAN_REV_PAYOUT_PCT]
			,[FI_REV_PAYOUT_PCT]
			,[REG_FEE_PAYOUT_PCT]
			,[TOTAL_GROSS_REV]
			,[TRFITL_GROSS_REV]
			,[NI_PAYOUT_REV]
			,[PMA_NEW_ISSUE_NOPAYOUT_REV]
			,[INS_REV]
			,[OTH_REV]
			,[TOTAL_FEE_REV]
			,[AMA_FEE_REV]
			,[PMA_FEE_REV]
			,[SMA_FEE_REV]
			,[UMA_FEE_REV]
			,[REG_FEE_REV]
			,[EMP_REG_FEE_REV]
			,[TOTAL_NET_PAYOUT]
			,[DISCOUNT_FEE]
			,[AMA_EXCESS_TRADE]
			,[PMA_EXCESS_TRADE]
			,[FINAL_NET_PAYOUT]
			,[TRAN_TR_REV]
			,[TRAN_TL_REV]
			,[FI_REV]
			,[AMA_NOPAY_REV]
			,[PMA_MC_NOPAY_REV]
			,[SMA_SC_NOPAY_REV]
			,[TOTAL_US_FEE_REV]
			,[US_FEE_PMA_REV]
			,[US_FEE_SMA_REV]
			,[TF_FEE_REV]
			,[GIC_COMM_REV]
			,[TRAN_TR_NETPAYOUT]
			,[FI_NETPAYOUT]
			,[NI_NETPAYOUT]
			,[INS_NETPAYOUT]
			,[OTH_NETPAYOUT]
			,[TOTAL_FEE_NETPAYOUT]
			,[AMA_FEE_NETPAYOUT]
			,[PMA_FEE_NETPAYOUT]
			,[SMA_FEE_NETPAYOUT]
			,[UMA_FEE_NETPAYOUT]
			,[REG_FEE_NETPAYOUT]
			,[US_FEE_NETPAYOUT]
			,[US_PMA_FEE_NETPAYOUT]
			,[US_SMA_FEE_NETPAYOUT]
			,[US_FEE_REV_PAYOUT_PCT]
			,[INS_REV_PAYOUT_PCT]
			,[X_ATTRIB1]
			,[X_ATTRIB2]
			,[X_ATTRIB3]
			,[X_ATTRIB4]
			,[X_ATTRIB5]
			,[LOAD_ID]
			,[DL_CREATE_DATE_TS]
			,[DL_UPD_DATE_TS]
			,[DL_CREATE_BY]
			,[DL_UPD_BY])
						
	SELECT  [IA_Code]
			,[TO_IA_CODE]
			,[BUSINESS_DATE]
			,[GROSS_SPLIT_CODE]
			,[GROSS_SPLIT_PCT]
			,[FEE_REV_PAYOUT_PCT]
			,[TRAN_REV_PAYOUT_PCT]
			,[FI_REV_PAYOUT_PCT]
			,[REG_FEE_PAYOUT_PCT]
			,[TOTAL_GROSS_REV]
			,[TRFITL_GROSS_REV]
			,[NI_PAYOUT_REV]
			,[PMA_NEW_ISSUE_NOPAYOUT_REV]
			,[INS_REV]
			,[OTH_REV]
			,[TOTAL_FEE_REV]
			,[AMA_FEE_REV]
			,[PMA_FEE_REV]
			,[SMA_FEE_REV]
			,[UMA_FEE_REV]
			,[REG_FEE_REV]
			,[EMP_REG_FEE_REV]
			,[TOTAL_NET_PAYOUT]
			,[DISCOUNT_FEE]
			,[AMA_EXCESS_TRADE]
			,[PMA_EXCESS_TRADE]
			,[FINAL_NET_PAYOUT]
			,[TRAN_TR_REV]
			,[TRAN_TL_REV]
			,[FI_REV]
			,[AMA_NOPAY_REV]
			,[PMA_MC_NOPAY_REV]
			,[SMA_SC_NOPAY_REV]
			,[TOTAL_US_FEE_REV]
			,[US_FEE_PMA_REV]
			,[US_FEE_SMA_REV]
			,[TF_FEE_REV]
			,[GIC_COMM_REV]
			,[TRAN_TR_NETPAYOUT]
			,[FI_NETPAYOUT]
			,[NI_NETPAYOUT]
			,[INS_NETPAYOUT]
			,[OTH_NETPAYOUT]
			,[TOTAL_FEE_NETPAYOUT]
			,[AMA_FEE_NETPAYOUT]
			,[PMA_FEE_NETPAYOUT]
			,[SMA_FEE_NETPAYOUT]
			,[UMA_FEE_NETPAYOUT]
			,[REG_FEE_NETPAYOUT]
			,[US_FEE_NETPAYOUT]
			,[US_PMA_FEE_NETPAYOUT]
			,[US_SMA_FEE_NETPAYOUT]
			,[US_FEE_REV_PAYOUT_PCT]
			,[INS_REV_PAYOUT_PCT]
			,[X_ATTRIB1]
			,[X_ATTRIB2]
			,[X_ATTRIB3]
			,[X_ATTRIB4]
			,[X_ATTRIB5]
			,[LOAD_ID]
			,[DL_CREATE_DATE_TS]
			,[DL_UPD_DATE_TS]
			,[DL_CREATE_BY]
			,[DL_UPD_BY]
	FROM [COMMWEB].[COMM_DAILY_SUMMARY]
    WHERE [BUSINESS_DATE] = (SELECT MAX([BUSINESS_DATE]) FROM [COMMWEB].[COMM_DAILY_SUMMARY_HIST])

    RETURN 0

END CATCH

END
GO
 
