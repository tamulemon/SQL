

/*************************************************/
--  Memory usage
/*************************************************/
--Run DBCC MEMORYSTATUS and observe the values for buffer distribution table.
SELECT * 
FROM SYS.SYSPERFINFO 
WHERE
OBJECT_NAME='SQLSERVER:BUFFER MANAGER' AND
(COUNTER_NAME='TARGET PAGES' OR
COUNTER_NAME='TOTAL PAGES' OR
COUNTER_NAME='DATABASE PAGES' OR
COUNTER_NAME='STOLEN PAGES' OR
COUNTER_NAME='FREE PAGES')

-- To determine which SQL Server components are consuming the most amount of memory, 
--and observe how this changes over time:
SELECT TYPE, SUM(PAGES_KB) 
FROM SYS.DM_OS_MEMORY_CLERKS 
WHERE PAGES_KB != 0 
GROUP BY TYPE


--This query will show which SQL Server objects are consuming memory:
SELECT *
FROM SYS.DM_OS_MEMORY_OBJECTS 
WHERE PAGE_ALLOCATOR_ADDRESS IN 
(
SELECT TOP 10 PAGE_ALLOCATOR_ADDRESS 
FROM SYS.DM_OS_MEMORY_CLERKS 
ORDER BY PAGES_KB DESC) 


--To get an idea of which individual processes are taking up memory, use the following query:

SELECT TOP 10 
SESSION_ID, LOGIN_TIME, HOST_NAME,
PROGRAM_NAME, LOGIN_NAME, NT_DOMAIN, 
NT_USER_NAME, STATUS, CPU_TIME, MEMORY_USAGE, 
TOTAL_SCHEDULED_TIME, TOTAL_ELAPSED_TIME, 
LAST_REQUEST_START_TIME,
LAST_REQUEST_END_TIME, READS, WRITES, 
LOGICAL_READS, TRANSACTION_ISOLATION_LEVEL, 
LOCK_TIMEOUT, DEADLOCK_PRIORITY, ROW_COUNT, 
PREV_ERROR 
FROM SYS.DM_EXEC_SESSIONS 
ORDER BY MEMORY_USAGE DESC

/*************************************************/
--  disc usage
/*************************************************/
-- query that lists the top 25 tables experiencing I/O waits.
SELECT TOP 25 
DB_NAME(D.DATABASE_ID) AS DATABASE_NAME, 
QUOTENAME(OBJECT_SCHEMA_NAME(D.OBJECT_ID, D.DATABASE_ID)) + N'.' + QUOTENAME(OBJECT_NAME(D.OBJECT_ID,D.DATABASE_ID)) AS OBJECT_NAME, 
D.DATABASE_ID, 
D.OBJECT_ID, 
D.PAGE_IO_LATCH_WAIT_COUNT,
D.PAGE_IO_LATCH_WAIT_IN_MS, 
D.RANGE_SCANS,
D.INDEX_LOOKUPS 
FROM (
SELECT 
DATABASE_ID, 
OBJECT_ID, 
ROW_NUMBER() OVER (PARTITION BY
			DATABASE_ID ORDER BY
			SUM(PAGE_IO_LATCH_WAIT_IN_MS) DESC) AS ROW_NUMBER, 
SUM(PAGE_IO_LATCH_WAIT_COUNT) AS PAGE_IO_LATCH_WAIT_COUNT, 
SUM(PAGE_IO_LATCH_WAIT_IN_MS) AS PAGE_IO_LATCH_WAIT_IN_MS, 
SUM(RANGE_SCAN_COUNT) AS RANGE_SCANS, 
SUM(SINGLETON_LOOKUP_COUNT) AS INDEX_LOOKUPS 
FROM SYS.DM_DB_INDEX_OPERATIONAL_STATS(NULL, NULL, NULL, NULL) 
WHERE PAGE_IO_LATCH_WAIT_COUNT > 0
GROUP BY DATABASE_ID, OBJECT_ID ) AS D 
LEFT JOIN
(SELECT DISTINCT DATABASE_ID, 
OBJECT_ID 
FROM SYS.DM_DB_MISSING_INDEX_DETAILS) AS MID 
ON MID.DATABASE_ID = D.DATABASE_ID 
AND MID.OBJECT_ID = D.OBJECT_ID 
WHERE D.ROW_NUMBER>20 
ORDER BY PAGE_IO_LATCH_WAIT_COUNT DESC

--You can also generate a list of columns that should have indexes on them:

SELECT * FROM 
SYS.DM_DB_MISSING_INDEX_GROUPS G 
JOIN SYS.DM_DB_MISSING_INDEX_GROUP_STATS GS
ON GS.GROUP_HANDLE = G.INDEX_GROUP_HANDLE
JOIN SYS.DM_DB_MISSING_INDEX_DETAILS D 
ON G.INDEX_HANDLE = D.INDEX_HANDLE


/*************************************************/
--  CPU usage
/*************************************************/
--One of the most frequent contributors to high CPU consumption is stored procedure recompilation. DIsplay list of the top 25 recompilations:
SELECT TOP 25 
SQL_TEXT.TEXT, 
SQL_HANDLE, 
PLAN_GENERATION_NUM, 
EXECUTION_COUNT, 
DBID, 
OBJECTID 
FROM SYS.DM_EXEC_QUERY_STATS A
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) 
AS SQL_TEXT WHERE PLAN_GENERATION_NUM >1
ORDER BY PLAN_GENERATION_NUM DESC


SELECT TOP 50 
SUM(QS.TOTAL_WORKER_TIME) AS TOTAL_CPU_TIME, 
SUM(QS.EXECUTION_COUNT) AS TOTAL_EXECUTION_COUNT, COUNT(*) AS NUMBER_OF_STATEMENTS, 
SQL_TEXT.TEXT, 
QS.PLAN_HANDLE 
FROM SYS.DM_EXEC_QUERY_STATS QS 
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) AS SQL_TEXT
GROUP BY SQL_TEXT.TEXT,QS.PLAN_HANDLE ORDER
BY SUM(QS.TOTAL_WORKER_TIME) DESC
