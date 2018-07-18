DECLARE @MinCount BIGINT ;
SET @MinCount = 1;

SELECT st.[text], qs.execution_count,qs.total_elapsed_time as elapsed_time_microSec
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text( qs.sql_handle ) AS st
WHERE qs.execution_count > @MinCount
ORDER BY qs.execution_count DESC
--ORDER BY elapsed_time_microSec DESC

