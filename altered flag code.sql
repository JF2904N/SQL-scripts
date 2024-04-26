USE [TempDataLake]
GO

/****** Object:  View [COMMWEB].[VIEW_FLAG_TYPE_CODE]    Script Date: 4/17/2024 1:34:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [COMMWEB].[VIEW_FLAG_TYPE_CODE]
AS
WITH Split_CTE as (
SELECT *,
    ISNULL(S
        CASE WHEN FlagDesc IN ('FI $50 to $99.99', 'Insurance', 'New Issues', 'Other', 'PMA NI','Trades No Payout', 'Regular Trades','SMA No Payout','PMA No Payout','IAA','PMA','SMA','UMA')
            THEN 'Total Gross, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Regular Trades','FI $50 to $99.99','Trades No Payout')
            THEN 'Regular, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('New Issues')
            THEN 'New Issue, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Insurance')
            THEN 'Insurance, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Other')
            THEN 'Other, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('PMA NI','PMA No Payout','SMA No Payout')
            THEN 'PMA/SMA No Payout, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('IAA','PMA','SMA','UMA')
            THEN 'Total IAA/ PMA/ SMA/ UMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('IAA')
            THEN 'IAA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('PMA')
            THEN 'PMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('SMA')
            THEN 'SMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('UMA')
            THEN 'UMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('FI $50 to $99.99','New Issues','Other','PMA NI','Trades No Payout','Regular Trades')
            THEN 'Discount Fee, ' ELSE '' END, 
        ''
    ) AS ATTRIB_MAP
from (
      SELECT 'Trades' AS FlagType, [TradeTypeCode] as FlagCode
              ,[TradeTypeDescr] as FlagDesc
      FROM [GMPCommission].[dbo].[TradeType]
union
select 'Trades' as FlagType, 'PN' as FlagCode, 'PMA No Payout' as FlagDesc
      union
      select 'Fees' as Flag_type,FeeTypeCode  as FlagCode ,FeeTypeDescription as FlagDesc  from [GMPCommission].[SSRS].[udf_GetFeeType]()
      union
      select 'Expense' as Flag_type,ExpenseTypeCode  as FlagCode ,ExpenseTypeDescription as FlagDesc  from [GMPCommission].[SSRS].[udf_GetExpenseType]()
      union     /* added by Miranda Lam 2017-12: */
      select 'Trades' as FlagType, 'THNP' as FlagCode, 'HH No Payout' as FlagDesc
      union
      select 'Fees' as FlagType, '6) FHNP' as FlagCode ,'HH No Payout' as FlagDesc
) as x
where 1=1
)

SELECT 
    sc.FlagType as FLAG_TYPE,
    sc.FlagCode as FLAG_CODE,
    sc.FlagDesc as FLAG_DESC,
    LTRIM(COALESCE(SUBSTRING(ISNULL(sc.ATTRIB_MAP, ''), Number, CHARINDEX(',', ISNULL(sc.ATTRIB_MAP, '') + ',', Number) - Number), '')) AS REPORT_ATTRIB
FROM 
    Split_CTE sc
LEFT JOIN 
    master..spt_values ON Type = 'P' AND Number <= LEN(ISNULL(sc.ATTRIB_MAP, '')) AND SUBSTRING(',' + ISNULL(sc.ATTRIB_MAP, ''), Number, 1) = ',';
GO


