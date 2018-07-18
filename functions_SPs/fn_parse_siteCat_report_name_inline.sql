IF(
	SELECT name 
	FROM [sys].[all_objects]
	WHERE name = 'fn_parse_siteCat_report_inline'
	AND type_desc like '%FUNCTION%') IS NOT NULL
BEGIN
	DROP FUNCTION fn_parse_siteCat_report_inline
END
GO
/****************************************************************************
 function will 
	- parse out a string based on a user defined @deliminater using recursive cte

*******************************************************************************/ 

CREATE  FUNCTION dbo.fn_parse_siteCat_report_inline(@text varchar(400), @deliminater nvarchar(2))
RETURNS TABLE 
AS
RETURN
(
	WITH cte
	AS
	(
		SELECT
		1 AS pos,
		CONVERT(varchar(400), NULL) AS parsed,
		@text AS leftover
		UNION ALL
		SELECT
			pos + 1,
			CASE CHARINDEX(@deliminater,leftover) WHEN 0 THEN leftover ELSE LEFT(leftover, CHARINDEX(@deliminater,leftover) - 1) END AS parsed,
			CASE CHARINDEX(@deliminater,leftover) WHEN 0 THEN CONVERT(varchar(400), NULL) ELSE RIGHT(leftover, LEN(leftover) -  CHARINDEX(@deliminater,leftover)) END AS leftover
			FROM cte
			WHERE pos < 7

	)

	SELECT *
	FROM 
		(-- rename each position to corresponding business logic
			SELECT 
			CASE pos
			WHEN 2 THEN 'Site'
			WHEN 3 THEN 'Business Line'
			WHEN 4 THEN 'Product'
			WHEN 5 THEN 'Audience Type'
			WHEN 6 THEN 'Funnel Step' 
			WHEN 7 THEN 'Device Type' 
			END AS pos,
			parsed
			FROM cte
			--WHERE parsed IS NOT NULL
		) AS d
	PIVOT
		(
			MAX(parsed) 
			FOR pos IN ([Site], [Business Line], [Product], [Audience Type], [Funnel Step], [Device Type])
		) AS piv
)
------------------------------------------------------------------------------------------------------

----Example calling 
--SELECT * FROM dbo.fn_parse_siteCat_report_inline('TMO_Prepaid_Total_Customer_Order Confirmation_Mobile', '_') 

------ APPLY to a table!!
--SELECT *
--FROM [dbo].[staging_LastTouchVisits]
--OUTER APPLY dbo.fn_parse_siteCat_report_inline(table_name, '_') 