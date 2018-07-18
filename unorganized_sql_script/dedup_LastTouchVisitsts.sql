-- create a temp table for deduping
DROP TABLE IF EXISTS #temp_dedup_LTMVisits 

SELECT * INTO #temp_dedup_LTMVisits
FROM
(
	SELECT	
		t1.date,	
		'daily' AS Granularity,
		t1.[Last_Touch_Marketing_Channel],
		t1.[Visits],
		t1.[table_name],
		CAST(ROUND(dbo.fn_integerDivision(t1.[Visits], t3.sum_channel_visits)* t2.total_visits, 0)AS BIGINT) AS Visits_Dedup
	FROM
	(
		SELECT 
				date,
				[Last_Touch_Marketing_Channel],			
				[Visits],
				[table_name],
				dbo.fn_exclude_last_part([table_name]) AS funnel_name
		FROM dbo.[staging_LastTouchVisits_union]
	)AS t1
	INNER JOIN
	(
		SELECT 
				date AS t2_date,
				[Visits] AS total_visits,
				dbo.fn_exclude_last_part([table_name]) AS funnel_name
		FROM dbo.[staging_Visits_union]
	) AS t2
	ON t1.date = t2.t2_date
	AND t1.funnel_name = t2.funnel_name
	INNER JOIN
	(
		SELECT 
				date,
				SUM([Visits]) AS sum_channel_visits,
				dbo.fn_exclude_last_part([table_name]) AS funnel_name
		FROM dbo.[staging_LastTouchVisits_union]
		GROUP BY 
			date,
			dbo.fn_exclude_last_part([table_name])
	) AS t3
	ON t1.date = t3.date
	AND t1.funnel_name = t3.funnel_name
) AS t


--if table exists, truncate and insert
-- else SELECT INTO
IF OBJECT_ID('dedup_LTMVisits', 'U') IS NOT NULL
	BEGIN 	
		TRUNCATE TABLE [dbo].[dedup_LTMVisits]
		INSERT INTO [dbo].[dedup_LTMVisits]
		SELECT * FROM #temp_dedup_LTMVisits
		--OUTER APPLY dbo.fn_parse_siteCat_report_inline(table_name, '_') 
		OUTER APPLY dbo.fn_parse_siteCat_report(table_name, '_') 
	END
ELSE
	BEGIN
		SELECT * INTO [dbo].[dedup_LTMVisits]
		FROM #temp_dedup_LTMVisits
		OUTER APPLY dbo.fn_parse_siteCat_report(table_name, '_') 		
	END

--10/04
--(26779 row(s) affected)
-- 17sec. 1575 rows/sec

--10/17: 11244 row, 8 sec


