SELECT Top 100 *
from [dbo].[VW_NextGen_executive_funnel]

-- 10 sec
/*

SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 11 ms.

(868 row(s) affected)

 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 10192 ms.

*/

SELECT 
	curr_date, 
	DATEDIFF(DAY,curr_date, next_date) AS date_diff
FROM
	(SELECT 
		ecomm_date AS curr_date,
		LEAD(ecomm_date, 1, NULL) OVER (ORDER BY ecomm_date)AS next_date
	FROM
		(SELECT DISTINCT DATE AS ecomm_date
		FROM TABLEAU_LTMVisits) t1) t2
WHERE DATEDIFF(DAY,curr_date, next_date) <> 1



SET STATISTICS TIME ON

SELECT 
[Date],
SUM([visits]),
LAG(SUM([visits]), 1,0) OVER (ORDER BY [date]) AS pre_visit 
FROM [VW_NextGen_executive_funnel]
GROUP BY date


/*
SQL Server parse and compile time: 
   CPU time = 11 ms, elapsed time = 11 ms.

(24304 row(s) affected)

 SQL Server Execution Times:
   CPU time = 62 ms,  elapsed time = 20110 ms.

*/
SELECT 
	[Date],
	[site],
	[business line],
	[funnel step],
	SUM([visits]),
	LAG(SUM([visits]), 1,0) OVER (PARTITION BY [Date],
												[site],
												[business line],
												[funnel step]
							ORDER BY [date]) AS pre_visit 
FROM [VW_NextGen_executive_funnel]
GROUP BY 
	[Date],
	[site],
	[business line],
	[funnel step]

-- 20 sec
SELECT 
	[Date],
	[site],
	[business line],
	[funnel step],
	max([visits]),
	LAG(max([visits]), 1,0) OVER (PARTITION BY [Date],
												[site],
												[business line],
												[funnel step]
							ORDER BY [date]) AS pre_visit 
FROM [VW_NextGen_executive_funnel]
GROUP BY 
	[Date],
	[site],
	[business line],
	[funnel step]
--------------------------------------------
CREATE TABLE #temp_test
(
	date date, 
	[site] varchar(100),
	[business line] varchar(100),
	[funnel step] varchar(100),
	[max visits] int
)

INSERT INTO #temp_test
SELECT 	[Date],
	[site],
	[business line],
	[funnel step], 
	max(visits)
FROM [VW_NextGen_executive_funnel]
GROUP BY 
	[Date],
	[site],
	[business line],
	[funnel step]

SELECT top 100 *
FROM #temp_test

SELECT 
[Date],
[max visits],
LAG([max visits], 1,0) OVER (PARTITION BY [Date],
												[site],
												[business line],
												[funnel step]
							ORDER BY [date], [site],
												[business line],
												[funnel step]) AS pre_visit 
FROM #temp_test
GROUP BY [Date],
		[site],
		[business line],
		[funnel step]