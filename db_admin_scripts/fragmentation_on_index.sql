/*
sys.dm_db_index_physical_stats (   
    { database_id | NULL | 0 | DEFAULT }  
  , { object_id | NULL | 0 | DEFAULT }  
  , { index_id | NULL | 0 | -1 | DEFAULT }  
  , { partition_number | NULL | 0 | DEFAULT }  
  , { mode | NULL | DEFAULT }  
)  

*/
SELECT dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (
DB_ID(), -- db id
NULL, --object id, if NULL, get all tables
NULL, -- index id. if object id is null, has to be null
NULL, --partition number
NULL) --mode
AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
and dbtables.name = 'tableau_LTMVisits'
--ORDER BY indexstats.avg_fragmentation_in_percent desc

SELECT *
FROm sys.tables
where name  =  'tableau_NG_daily_executive'
-- object id = 573245097

SELECT *
FROM sys.dm_db_index_physical_stats (DB_ID(), 1759397387, DEFAULT, DEFAULT, DEFAULT)