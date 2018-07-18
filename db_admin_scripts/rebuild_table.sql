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

-------------------------------------

-- when fragment:5%~30%
-- rebuild is always online
ALTER INDEX ind_prod
ON tableau_LTMVisits REORGANIZE

-- when fragment> 30%
ALTER INDEX ind_mob ON tableau_LTMVisits
REBUILD WITH (ONLINE = ON)

--- to rebuild all index
ALTER INDEX ALL ON tableau_LTMVisits
REBUILD WITH (
ONLINE = ON
FILLFACTOR = 80, 
SORT_IN_TEMPDB = ON,
STATISTICS_NORECOMPUTE = ON);





---------------
SELECT  first_page
FROM    sys.partitions sp
JOIN	sys.system_internals_allocation_units siau --not available in Azure
ON		sp.partition_id = siau.container_id
WHERE   sp.OBJECT_ID = OBJECT_ID('table_name') 
        AND sp.index_id = 0



