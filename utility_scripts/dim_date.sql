IF EXISTS (
	SELECT table_name
	FROM INFORMATION_SCHEMA.TABLES
	WHERE table_name='dim_date_test'
)
BEGIN
	DROP TABLE dim_date_test
END

/***********************************************************/

CREATE TABLE dim_date_test
(
	date_key int IDENTITY(1,1) NOT NULL,
	[date] date NOT NULL,
	date_name AS DATENAME(WEEKDAY, [date]),
	month_number AS DATEPART(MONTH, [date]),
	month_name AS DATENAME(MONTH, [date]),
	year_number AS DATEPART(YEAR, [date]),
	quarter_number AS DATEPART(QUARTER, [date]),
	day_number AS DATEPART(DAY, [date]),
-- Microsoft fiscal year starts on July/01
	fiscal_year AS (
		CASE WHEN DATEPART(MONTH, [date]) < 7 THEN DATEPART(YEAR, [date])
		ELSE DATEPART(YEAR, [date]) + 1
		END),
	week_start_date AS DATEADD(DAY, 1-DATEPART(WEEKDAY, [date]), [date]),
	month_start_date AS DATEADD(DAY, -(DATEPART(DAY,EOMONTH([date])) - 1), EOMONTH([DATE])),
	year_start_date AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0))

	-- also correct
	--year_name AS CAST([year_number] AS varchar(20)),
	--month_start_date AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),

	PRIMARY KEY ([date_key])

) on [primary]

/**********************************************************/
-- populate

DECLARE @StartDate date
DECLARE @CutoffDate date
DECLARE @ct int
SET @StartDate = '2014-01-01'
SET @CutoffDate = '2017-01-01'
SET @ct = 0

WHILE @ct < DATEDIFF(DAY, @StartDate, @CutoffDate)
BEGIN
	INSERT dim_date_test([date]) 
	SELECT d
	FROM 
	(
		SELECT d = DATEADD(DAY, @ct, @StartDate)
	) t
	SET @ct = @ct + 1
END


--INSERT dim_date_test([date]) 
--SELECT d
--FROM
--(
--  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
--  FROM 
--  (
--    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) --this is basically just get continuous number for 1 going on
--      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
--    FROM sys.all_objects AS s1
--    ORDER BY s1.[object_id]
--  ) AS t1
--) AS t2

SELECT *
FROM dim_date_test