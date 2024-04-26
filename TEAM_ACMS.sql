IF OBJECT_ID('tempdb..#tempResults') IS NOT NULL DROP TABLE #tempResults
DECLARE @iaCode VARCHAR(10) = 'H'
SELECT
  T1.IACode,
  CASE
    WHEN T1.Name1_E = T2.Name1_E THEN ''
	WHEN T1.Name1_E = '' and T2.Name1_E is NULL then ''
    ELSE ISNULL(T2.Name1_E,'')
  END AS Name1_E,
  CASE
    WHEN T1.Name1_E = T2.Name1_E THEN ''
    ELSE ISNULL(T1.Name1_E,'')
  END AS Name1_E_FCC, 
  CASE
    WHEN T1.Name1_F = T2.Name1_F THEN ''
	WHEN T1.Name1_F = '' and T2.Name1_F IS NULL THEN ''
    ELSE ISNULL(T2.Name1_F,'')
  END AS Name1_F,
  CASE
    WHEN T1.Name1_F = T2.Name1_F THEN ''
    ELSE ISNULL(T1.Name1_F,'')
  END AS Name1_F_FCC,
  CASE
	WHEN T1.URL1 = '' and T2.Url IS NULL THEN ''
    ELSE ISNULL(T2.URL,'')
  END AS URL,
   CASE
    WHEN T1.URL1  = T2.Url THEN ''
    ELSE ISNULL(T1.URL1,'')
  END AS URL_FCC,
  CASE
    WHEN T1.TollFree  = T2.TollFree THEN ''
	WHEN T1.TollFree = '' and T2.TollFree IS NULL THEN ''
    ELSE ISNULL(T2.TollFree,'')
  END AS TollFree,
    CASE
    WHEN T1.TollFree  = T2.TollFree THEN ''
    ELSE ISNULL(T1.TollFree,'')
  END AS TollFree_FCC,
  CASE
    WHEN T1.WorkPhone  = T2.PhoneWork THEN ''
	WHEN T1.WorkPhone = '' and T2.PhoneWork IS NULL THEN ''
    ELSE T2.PhoneWork
  END AS WorkPhone,
  CASE
    WHEN T1.WorkPhone = T2.PhoneWork THEN ''
    ELSE ISNULL(T1.WorkPhone,'')
  END AS WorkPhone_FCC,
  CASE
    WHEN T1.FAX  = T2.FAX THEN ''
	WHEN T1.Fax = '' and T2.Fax IS NULL THEN ''
    ELSE ISNULL(T2.FAX,'')
  END AS FAX,
  CASE
    WHEN T1.FAX  = T2.FAX THEN ''
    ELSE ISNULL(T1.FAX,'')
  END AS FAX_FCC,
  CASE
    WHEN T1.Email  = T2.Email THEN ''
	WHEN T1.Email = '' and T2.Email IS NULL THEN ''
    ELSE ISNULL(T2.Email,'')
  END AS Email,
  CASE
    WHEN T1.Email  = T2.Email THEN ''
    ELSE ISNULL(T1.Email,'')
  END AS Email_FCC,
  CASE
    WHEN T1.Province  = T2.Province THEN ''
	WHEN T1.Province = '' and T2.Province is NULL THEN ''
    ELSE ISNULL(T2.Province,'')
  END AS Province,
  CASE
    WHEN T1.Province  = T2.Province THEN ''
    ELSE ISNULL(T1.Province,'')
  END AS Province_FCC
 INTO #tempResults
FROM (
       SELECT IACode, Name1_E, Name1_F, URL1, TollFree, WorkPhone, FAX, Email, Province 
       FROM RGMPRRAdmin.dbo.udf_GetIACodeStatementTeamInfo(NULL) WHERE IACode like @iaCode + '%'
) AS T1					
FULL OUTER JOIN (
       select a.IACode,
                 r.DisplayValue as Name1_E,
                 d.DisplayValue as Name1_F,
                 tw.Url as Url,
                 i.TollFree as TollFree,
                 i.PhoneWork as PhoneWork,
                 i.Fax as Fax,
                 i.Email as Email,
                 i.Province as Province
       from MainIACode a
       Inner JOIN IACodeInfo i ON i.IACode = a.IACode
       LEFT Join IACodeTeamName t ON t.IACode = a.IACode and t.Seq = 1 and t.LangCD = 'E'
       LEFT JOIN RGMPDomain.dbo.IIROCName r ON r.IIROCNameId = t.IIROCNameId
       LEFT JOIN BizTeamIaCode b ON b.IACode = a.IACode 
       LEFT JOIN IACodeTeamWebAddress w ON w.IACode = a.IACode
       LEFT JOIN RGMPDomain.dbo.WebAddress tw ON tw.WebAddressId = w.WebAddressId
       LEFT JOIN RGMPDomain.dbo.TeamName n ON n.BizTeamCOde = b.BizTeamCOde and n.LangCD = 'F' and n.Seq = 1
       LEFT JOIN RGMPDomain.dbo.IIROCNAME d on d.IIrocnameid = n.IIrocnameid  
       WHERE a.iaCode LIKE @iaCode + '%'
) AS T2
ON T1.IACode = T2.IACode
ORDER BY T2.IACode

IF OBJECT_ID('tempdb..#tempAllRequests') IS NOT NULL DROP TABLE #tempAllRequests
select * into #tempAllRequests from RGMPRRAdmin.dbo.vw_AllRequests where RequestTypeId in (10,20)

SELECT 
    Name1_E, Name1_E_FCC, Name1_F, Name1_F_FCC, URL, URL_FCC, TollFree, TollFree_FCC, WorkPhone, WorkPhone_FCC, 
    Fax, Fax_FCC, Email, Email_FCC, Province, Province_FCC
FROM #tempResults tr
INNER JOIN #tempAllRequests ar ON ar.IACode = tr.IACode 
WHERE 
    (Name1_E <> Name1_E_FCC OR Name1_F <> Name1_F_FCC OR URL <> URL_FCC OR TollFree <> TollFree_FCC 
        OR WorkPhone <> WorkPhone_FCC OR Fax <> Fax_FCC OR Email <> Email_FCC OR Province <> Province_FCC) 
    AND ar.RequestStatusDescr <> 'Pending'
ORDER BY SubmittedDate








