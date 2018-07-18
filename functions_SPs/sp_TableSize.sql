USE [master];
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TableSize]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[sp_TableSize];
GO


CREATE PROCEDURE sp_TableSize
/*
	01/08/2007 Yaniv Etrogi   
	http://www.sqlserverutilities.com	
*/

AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT
	(ROW_NUMBER() OVER(ORDER BY t3.name, t2.name))%2 AS l1
	,DB_NAME() AS [database]
	,t3.name AS [schema]
	,t2.name AS [table]
	,t1.rows AS row_count
	,((t1.reserved + ISNULL(a4.reserved,0))* 8) / 1024 AS reserved_MB 
	,(t1.data * 8) / 1024 AS data_MB
	,((CASE WHEN (t1.used + ISNULL(a4.used,0)) > t1.data THEN (t1.used + ISNULL(a4.used,0)) - t1.data ELSE 0 END) * 8) /1024 AS index_size_MB
	,((CASE WHEN (t1.reserved + ISNULL(a4.reserved,0)) > t1.used THEN (t1.reserved + ISNULL(a4.reserved,0)) - t1.used ELSE 0 END) * 8)/1024 AS unused_MB
INTO dbo.#Data
FROM
 (SELECT 
	 ps.object_id
	,SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows]
	,SUM (ps.reserved_page_count) AS reserved
	,SUM (CASE WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count) ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END) AS data
	,SUM (ps.used_page_count) AS used
  FROM sys.dm_db_partition_stats ps
  GROUP BY ps.object_id) AS t1
LEFT OUTER JOIN 
 (SELECT 
	   it.parent_id
	  ,SUM(ps.reserved_page_count) AS reserved
	  ,SUM(ps.used_page_count) AS used
  FROM sys.dm_db_partition_stats ps
  INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id) WHERE it.internal_type IN (202,204)
  GROUP BY it.parent_id) AS a4 ON (a4.parent_id = t1.object_id)
INNER JOIN sys.tables t2  ON ( t1.object_id = t2.object_id) 
INNER JOIN sys.schemas t3 ON (t2.schema_id = t3.schema_id)
WHERE t2.type <> 'S' and t2.type <> 'IT';


SELECT 	
   l1
	,DB_NAME() AS [database]
	,[schema] 
	,[table]
	,row_count
	,reserved_MB
	,data_MB
	,index_size_MB
	,unused_MB
FROM dbo.#Data ORDER BY reserved_MB DESC;
GO


USE MASTER; EXEC sp_ms_marksystemobject 'sp_TableSize';
GO


