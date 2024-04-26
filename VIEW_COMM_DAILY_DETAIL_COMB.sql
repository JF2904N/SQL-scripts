CREATE VIEW [COMMWEB].[VIEW_COMM_DAILY_DETAIL_COMB]
AS
SELECT
	[IA_CODE] as [IA Code],
	[TO_IA_CODE] as [To IA Code],
	[TRADE_NBR] as [Trade Num],
	[TRADE_DATE_TS] as [Trade Date],
	[PROCESS_DATE_TS] as [Proc Date],
	[BUSINESS_DATE] as [Business Date],
	[ORDER_NBR] as [Order #],
	[ORDER_DATE_TS] as [Order Date],
	[SETTLEMENT_DATE_TS] as [Settle Date],
	[ACCT_ID] as [Acct ID],
	[PORT_TYPE] as [Port Type],
	[CLIENT_NAME] as [Client Name],
	[TRADE_RR] as [Trade RR],
	[FLAG] as [Flag],
	[BUY_SELL] as [Buy Sell],
	[QTY],
	[SYMBOL_DESC] as [Symbol Desc],
	[CUSIP],
	[SEC_CLASS] as [Sec Class],
	[SEC_TYPE_CLASS] as [Sec Type Class],
	[PRICE] as [Price],
	[GROSS_TRADE_AMT] as [Gross Amount],
	[GROSS_COMM] as [Gross Comm],
	[GROSS_COMM_CAD] as [Gross Comm CAD],
	[CURR] as [Curr],
	[MC_GROSS_COMM_CAD] as [MC Gross Comm CAD],
	[MC_GROSS_COMM] as [MC Gross Comm],
	[SC_GROSS_COMM_CAD] as [SC Gross Comm Cad],
	[SC_GROSS_COMM] as [SC Gross Comm],
	[GROSS_SPLIT_PCT] as [Gross Split %],
	[PAYOUT_PCT] as [Payout %],
	[NET_COMM] as [Net Comm],
	[TICKET_CHARGE] as [Ticket Charge],
	[NET_TO_RR] as [Net To RR],
	[IS_DISCOUNT_FREE] as [Disc free],
	[COMM_PCT] as [Comm %],
	[GROUP_SEQ] as [Group Seq],
	[ROW_ORDER] as [Row Order],
	[PMA_MZ_EXCESS_FEE] as [PMA MZ Excess Fee],
	[PAYOUT_STATUS] as [Payout Status],
	[FAMILY_HH_ID] as [FHID]
FROM [COMMWEB].[COMM_DAILY_DETAIL]
union all 
select 
	   [IA_CODE]
      ,[TO_IA_CODE]
      ,[TRADE_NBR]
      ,[TRADE_DATE_TS]
      ,[PROCESS_DATE_TS]
      ,[BUSINESS_DATE]
      ,[ORDER_NBR]
      ,[ORDER_DATE_TS]
      ,[SETTLEMENT_DATE_TS]
      ,[ACCT_ID]
      ,[PORT_TYPE]
      ,[CLIENT_NAME]
      ,[TRADE_RR]
      ,[FLAG]
      ,[BUY_SELL]
      ,[QTY]
      ,[SYMBOL_DESC]
      ,[CUSIP]
      ,[SEC_CLASS]
      ,[SEC_TYPE_CLASS]
      ,[PRICE]
      ,[GROSS_TRADE_AMT]
      ,[GROSS_COMM]
      ,[GROSS_COMM_CAD]
      ,[CURR]
      ,[MC_GROSS_COMM_CAD]
      ,[MC_GROSS_COMM]
      ,[SC_GROSS_COMM_CAD]
      ,[SC_GROSS_COMM]
      ,[GROSS_SPLIT_PCT]
      ,[PAYOUT_PCT]
      ,[NET_COMM]
      ,[TICKET_CHARGE]
      ,[NET_TO_RR]
      ,[IS_DISCOUNT_FREE]
      ,[COMM_PCT]
      ,[GROUP_SEQ]
      ,[ROW_ORDER]
      ,[PMA_MZ_EXCESS_FEE]
      ,[PAYOUT_STATUS]
      ,[FAMILY_HH_ID]
FROM [COMMWEB].[COMM_DAILY_DETAIL_HIST]

