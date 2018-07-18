IF (OBJECT_ID('sp_monitor_table_growth') IS NOT NULL)
  DROP PROCEDURE sp_monitor_table_growth
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		mchen	
-- Create date: 2016/03/07
-- Description:	monitor table growth daily
-- =============================================
CREATE PROCEDURE sp_monitor_table_growth
@reset bit = 0 -- default value, don't truncate, keep growing
AS
BEGIN
	IF OBJECT_ID('dbo.table_growth', 'U') IS NULL 
		CREATE TABLE [dbo].[table_growth]
		(	
			[query_date] datetime,
			[table_name] varchar(100),
			[create_date] datetime,
			[modify_date] datetime,
			[row_count] int,
			[total_space] int,
			[used_space] int,
			[reserved_page] int,
			[used_page] int,
			[row_count_change] int
		)

	IF @reset = 1
	TRUNCATE TABLE table_growth

	;WITH t2 AS (
			SELECT [table_name], MIN([query_date]) AS min_date, [row_count]
			FROM [table_growth] 
			GROUP BY [table_name], [row_count]
		)  
	INSERT INTO [table_growth]
	(
			[query_date],
			[table_name],
			[create_date],
			[modify_date],
			[row_count],
			[total_space],
			[used_space],
			[reserved_page],
			[used_page],
			[row_count_change]
	)
	SELECT 
		GETDATE(),
		t.NAME,
		t.[create_date],
		t.[modify_date],
		p.rows,
		(SUM(a.total_pages) * 8) / 1024, 
		(SUM(a.used_pages) * 8) / 1024, 
		SUM(ps.reserved_page_count),
		SUM (ps.used_page_count),
		p.rows - t2.[row_count] 
	FROM 
		sys.tables t
	INNER JOIN 
		sys.partitions p 
	ON t.object_id = p.OBJECT_ID 
	INNER JOIN 
		sys.allocation_units a 
	ON p.partition_id = a.container_id
	INNER JOIN 
		sys.dm_db_partition_stats ps
	ON t.object_id = ps.object_id 
	LEFT OUTER JOIN t2
	ON t.[NAME] = t2.[table_name]
	WHERE 
		t.NAME LIKE 'fact%'
		OR t.NAME LIKE 'oper%'
	GROUP BY t.name,t.[create_date],t.[modify_date], p.rows, p.rows - t2.[row_count] 

END

---- example to run the sp. @truncate = 1. table will start fresh
--EXEC sp_monitor_table_growth @reset = 1
---- if @reset is ommitted, will grow
--EXEC sp_monitor_table_growth
