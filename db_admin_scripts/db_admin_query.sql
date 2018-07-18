
/*********************************************************/ 
--monitor connection status
/*********************************************************/ 

exec sp_who
-- active query
exec sp_who2 'active'

SELECT *
FROM sys.dm_exec_requests

-- will show status 
-- if block, will show who is blocking
SELECT *
FROM sys.sysprocesses


-- check wether user is server admin
SELECT * FROM fn_my_permissions(NULL, 'SERVER')


--Find Current SQL Statements that are Running
SELECT   SPID           = er.session_id
        ,STATUS         = ses.STATUS
        ,[Login]        = ses.login_name
        ,Host           = ses.host_name
        ,BlkBy          = er.blocking_session_id
        ,DBName         = DB_Name(er.database_id)
        ,CommandType    = er.command
        ,ObjectName     = OBJECT_NAME(st.objectid)
        ,CPUTime        = er.cpu_time
        ,StartTime      = er.start_time
        ,TimeElapsed    = CAST(GETDATE() - er.start_time AS TIME)
        ,SQLStatement   = st.text
FROM    sys.dm_exec_requests er
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
    LEFT JOIN sys.dm_exec_sessions ses
        ON ses.session_id = er.session_id
    LEFT JOIN sys.dm_exec_connections con
        ON con.session_id = ses.session_id
WHERE   st.text IS NOT NULL

-- find out wait statistics of all waits
SELECT *
FROM sys.dm_os_wait_stats
order by wait_time_ms desc



/*********************************************/
-- quick look at the healthiness of query
/**********************************************/
SELECT * 
FROM sys.dm_exec_requests
--SOS_SCHEDULER_YIELD: means yield itself so other thread can get a chance to run

SELECT *
FROM sys.dm_os_schedulers
--The user does not have permission to perform this action.

-- query status
SELECT *
FROM sys.dm_exec_query_stats


/*********************************************/
-- find out most expensive query
-- The query that used lots of resources but is not cached will not be caught here.
/**********************************************/
SELECT SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,
((CASE qs.statement_end_offset
WHEN -1 THEN DATALENGTH(qt.TEXT)
ELSE qs.statement_end_offset
END - qs.statement_start_offset)/2)+1),
qs.execution_count,
qs.total_logical_reads, qs.last_logical_reads,
qs.total_logical_writes, qs.last_logical_writes,
qs.total_worker_time,
qs.last_worker_time,
qs.total_elapsed_time/1000000 total_elapsed_time_in_S,
qs.last_elapsed_time/1000000 last_elapsed_time_in_S,
qs.last_execution_time,
qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time DESC -- CPU time


/*********************************************/
-- kill a SPID
/**********************************************/
KILL 133

/*********************************************/
-- look at the status, remaining time of a rollback
/**********************************************/
KILL 115 WITH statusonly


/*********************************************/
-- look at details of a kill/rollback cmd
/**********************************************/
SELECT spid
,kpid
,login_time
,last_batch
,status
,hostname
,nt_username
,loginame
,hostprocess
,cpu
,memusage
,physical_io
FROM sys.sysprocesses
WHERE cmd = 'KILLED/ROLLBACK'

/*********************************************************/ 
-- view text execuation plan
/*********************************************************/ 

SET SHOWPLAN_ALL ON;
GO


SELECT max(day)
FROM [dbo].[BrandMoments]


SET SHOWPLAN_ALL OFF
GO



/*********************************************************/ 
-- Find text for stored procedure
/*********************************************************/ 
EXEC sp_helptext N'sp_tablecollations_100' 





/*********************************************************/ 
-- Index usage and fragmentation of index
/*********************************************************/ 

SELECT OBJECT_NAME(OBJECT_ID) AS DatabaseName, last_user_update,*
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID( 'OC_Win10')

SELECT *
FROM sys.dm_db_index_usage_stats


SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent desc




/*********************************************************/ 
-- Query profiler
/*********************************************************/ 

DECLARE @MinCount BIGINT ;
SET @MinCount = 1;

SELECT st.[text], qs.execution_count,qs.total_elapsed_time as elapsed_time_microSec
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text( qs.sql_handle ) AS st
WHERE qs.execution_count > @MinCount
ORDER BY qs.execution_count DESC
--ORDER BY elapsed_time_microSec DESC




/*********************************************************/ 
-- Sort tables by modified date
/*********************************************************/ 
IF (OBJECT_ID('sp_find_tables_size') IS NOT NULL)
  DROP PROCEDURE sp_find_tables_size
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_find_tables_size
	@order_criteria [nvarchar] (max),
	@table_name_like [nvarchar] (max)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL [nvarchar] (max)

	DECLARE @ParamDefinition [nvarchar] (2000) 

	SET @SQL = 
	'SELECT 
		t.NAME AS TableName,
		t.[create_date],
		t.[modify_date],
		p.rows as RowCounts,
		(SUM(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
		(SUM(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
		(SUM(a.data_pages) * 8) / 1024 as DataSpaceMB
	FROM 
		sys.tables t
	INNER JOIN 
		sys.partitions p ON t.object_id = p.OBJECT_ID 
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	WHERE 
		t.NAME LIKE ' + ''''+ @table_name_like + '''' +
	' GROUP BY t.name,t.[create_date],t.[modify_date], p.rows
	ORDER BY ' + @order_criteria

	PRINT @SQL

	SET @ParamDefinition = 
	'@order_criteria [nvarchar] (max),
	@table_name_like [nvarchar] (max)'
	
	EXEC sp_executesql @SQL, @ParamDefinition, @order_criteria , @table_name_like

END
GO

EXEC sp_find_tables_size
@order_criteria = 'modify_date desc',
--@order_criteria = 'RowCounts desc',
@table_name_like = '%'



/*********************************************************/ 
---- find PK of tables
/*********************************************************/ 
SELECT t1.*
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE t1
JOIN SYS.OBJECTS t2
ON t1.TABLE_NAME = t2.name
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
AND t2.type_desc = 'USER_TABLE'
ORDER BY TABLE_NAME


/*********************************************************/ 
-- find all FK in a database

/*********************************************************/ 
SELECT
    K_Table = FK.TABLE_NAME,
    FK_Column = CU.COLUMN_NAME,
    PK_Table = PK.TABLE_NAME,
    PK_Column = PT.COLUMN_NAME,
    Constraint_Name = C.CONSTRAINT_NAME
FROM
    INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS C
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS FK
    ON C.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
INNER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS PK
    ON C.UNIQUE_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE CU
    ON C.CONSTRAINT_NAME = CU.CONSTRAINT_NAME
INNER JOIN (
            SELECT
                i1.TABLE_NAME,
                i2.COLUMN_NAME
            FROM
                INFORMATION_SCHEMA.TABLE_CONSTRAINTS i1
            INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE i2
                ON i1.CONSTRAINT_NAME = i2.CONSTRAINT_NAME
            WHERE
                i1.CONSTRAINT_TYPE = 'PRIMARY KEY'
           ) PT
    ON PT.TABLE_NAME = PK.TABLE_NAME
--WHERE FK.TABLE_NAME like 'oper_%'
ORDER BY FK.TABLE_NAME, CU.COLUMN_NAME


select sys.dm_exec_sessions.session_id,
sys.dm_exec_sessions.host_name,
sys.dm_exec_sessions.program_name,
sys.dm_exec_sessions.client_interface_name,
sys.dm_exec_sessions.login_name,
sys.dm_exec_sessions.nt_domain,
sys.dm_exec_sessions.nt_user_name,
sys.dm_exec_connections.client_net_address,
sys.dm_exec_connections.local_net_address,
sys.dm_exec_connections.connection_id,
sys.dm_exec_connections.parent_connection_id,
sys.dm_exec_connections.most_recent_sql_handle
from sys.dm_exec_sessions inner join sys.dm_exec_connections
on sys.dm_exec_connections.session_id=sys.dm_exec_sessions.session_id
--where host_name like '%ADMPWWRPT0002%' 