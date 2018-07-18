USE UORL_IP GO

-- all table with columnstore index
WITH ClusteredColumnstoreIndexes
AS
(SELECT t.object_id AS ObjectID,
         SCHEMA_NAME(t.schema_id) AS SchemaName,
         t.name AS TableName,
         i.name AS IndexName
  FROM sys.indexes AS i
  INNER JOIN sys.tables AS t
  ON i.object_id = t.object_id
WHERE i.type = 5
),
-- row counts
RowGroups
AS
(SELECT csrg.object_id AS ObjectID,
         csrg.total_rows AS TotalRows,
         csrg.deleted_rows AS DeletedRows,
         csrg.deleted_rows * 100.0 / csrg.total_rows AS DeletedPercentage,
         CASE WHEN csrg.total_rows = csrg.deleted_rows
              THEN 1 ELSE 0
         END AS IsEmptySegment
FROM sys.column_store_row_groups AS csrg
)

SELECT cci.ObjectID,
         cci.SchemaName,
         cci.TableName,
         cci.IndexName,
         SUM(rg.TotalRows) AS TotalRows,
         SUM(rg.DeletedRows) AS DeletedRows,
         SUM(rg.DeletedRows) * 100.0 / SUM(rg.TotalRows) AS DeletedPercentage,
         SUM(rg.IsEmptySegment) aS EmptySegments
FROM ClusteredColumnstoreIndexes AS cci
INNER JOIN RowGroups AS rg
ON cci.ObjectID = rg.ObjectID
GROUP BY cci.ObjectID, cci.SchemaName, cci.TableName, cci.IndexName



SELECT ps.* FROM UORL_IP.sys.TABLES t WITH (NOLOCK)
	JOIN UORL_IP.sys.indexes i WITH (NOLOCK) ON t.object_id = i.object_id
	JOIN UORL_IP.sys.partition_schemes ps WITH (NOLOCK) ON i.data_space_id = ps.data_space_id
	WHERE t.name = 'EVS_ONLINE_MENG_BK_20170413'
--ps_EVS_ONLINE_OFFLINE_2

-- This command will force all CLOSED and OPEN rowgroups into the columnstore.  
ALTER INDEX CCSI_EVS_ONLINE 
ON UORL_IP..EVS_ONLINE_MENG_BK_20170413   
REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);  

-- rebuild partition--2:44
ALTER INDEX [CCSI_EVS_ONLINE]
ON UORL_IP..EVS_ONLINE_MENG_BK_20170413
REBUILD PARTITION = ALL
  