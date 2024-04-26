CREATE VIEW [COMMWEB].[VIEW_FLAG_TYPE_CODE]
AS
WITH Split_CTE as (
SELECT *,
    ISNULL(
        CASE WHEN FlagDesc IN ('Trades - FI $50 to $99.99', 'Trades - Insurance', 'Trades - New Issues', 'Trades - Other', 'Trades - PMA NI','Trades - Trades No Payout', 'Trades - Regular Trades','Trades - SMA No Payout','Trades - PMA No Payout','Fees - IAA','Fees - PMA','Fees - SMA','Fees - UMA')
            THEN 'Total Gross, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Trades - Regular Trades','Trades - FI $50 to $99.99','Trades - Trades No Payout')
            THEN 'Regular, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Trades - New Issues')
            THEN 'New Issue, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Trades - Insurance')
            THEN 'Insurance, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Trades - Other')
            THEN 'Other, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Trades - PMA NI','Trades - PMA No Payout','Trades - SMA No Payout')
            THEN 'PMA/SMA No Payout, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Fees - IAA','Fees - PMA','Fees - SMA','Fees - UMA')
            THEN 'Total IAA/ PMA/ SMA/ UMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Fees - IAA')
            THEN 'IAA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Fees - PMA')
            THEN 'PMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Fees - SMA')
            THEN 'SMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Fees - UMA')
            THEN 'UMA Fee, ' ELSE '' END
        +
        CASE WHEN FlagDesc IN ('Trades - FI $50 to $99.99','Trades - New Issues','Trades - Other','Trades - PMA NI','Trades - Trades No Payout','Trades - Regular Trades')
            THEN 'Discount Fee, ' ELSE '' END, 
        ''
    ) AS ATTRIB_MAP
from (
      SELECT 'Trades' AS FlagType, [TradeTypeCode] as FlagCode
              ,'Trades - '+[TradeTypeDescr] as FlagDesc
      FROM [GMPCommission].[dbo].[TradeType]
union
select 'Trades' as FlagType, 'PN' as FlagCode, 'Trades - PMA No Payout' as FlagDesc
      union
      select 'Fees' as Flag_type,FeeTypeCode  as FlagCode ,'Fees - '+FeeTypeDescription as FlagDesc  from [GMPCommission].[SSRS].[udf_GetFeeType]()
      union
      select 'Expense' as Flag_type,ExpenseTypeCode  as FlagCode ,'Expense - '+ExpenseTypeDescription as FlagDesc  from [GMPCommission].[SSRS].[udf_GetExpenseType]()
      union     /* added by Miranda Lam 2017-12: */
      select 'Trades' as FlagType, 'THNP' as FlagCode, 'Trades - HH No Payout' as FlagDesc
      union
      select 'Fees' as FlagType, '6) FHNP' as FlagCode ,'Fees - HH No Payout' as FlagDesc
) as x
where 1=1
)

SELECT 
    sc.FlagType as FLAG_TYPE,
    sc.FlagCode as FLAG_CODE,
    sc.FlagDesc as FLAG_DESC,
    LTRIM(COALESCE(SUBSTRING(ISNULL(sc.ATTRIB_MAP, ''), Number, CHARINDEX(',', ISNULL(sc.ATTRIB_MAP, '') + ',', Number) - Number), '')) AS ATTRIB
FROM 
    Split_CTE sc
LEFT JOIN 
    master..spt_values ON Type = 'P' AND Number <= LEN(ISNULL(sc.ATTRIB_MAP, '')) AND SUBSTRING(',' + ISNULL(sc.ATTRIB_MAP, ''), Number, 1) = ',';