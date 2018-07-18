SELECT DISTINCT DATE
FROM tableau_LTMVisits

-- database size
SELECT SUM(reserved_page_count)*8.0/1024
FROM sys.dm_db_partition_stats;   

--current connection
SELECT
    e.connection_id,
    s.session_id,
    s.login_name,
    s.last_request_end_time,
    s.cpu_time
FROM
    sys.dm_exec_sessions s
    INNER JOIN sys.dm_exec_connections e
      ON s.session_id = e.session_id;


-- aggregated performance stats
SELECT TOP 5 
	query_stats.query_hash AS [query_hash],
    SUM(query_stats.total_worker_time) AS [total_CPU_time], 
	SUM(query_stats.execution_count) AS [times_being_executed],
    MIN(query_stats.statement_text) AS [statement_text]
FROM
    (SELECT QS.*,
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1, -- offset in byte so divided by 2
    ((CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(ST.text) -- -1 is the end of the batch. DATALENGTH returns byte
        ELSE QS.statement_end_offset END
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats --sql_handle is the token for the batch the query belongs to
GROUP BY query_stats.query_hash
ORDER BY [total_CPU_time] DESC 
-- same as ORDER BY 2 DESC, meaning order by 2nd column



SELECT *
FROM sys.dm_exec_query_stats

SELECT *
FROM sys.dm_exec_sql_text