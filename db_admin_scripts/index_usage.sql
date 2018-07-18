/*
sys.dm_db_index_operational_stats (    
    { database_id | NULL | 0 | DEFAULT }    
  , { object_id | NULL | 0 | DEFAULT }    
  , { index_id | 0 | NULL | -1 | DEFAULT }    
  , { partition_number | NULL | 0 | DEFAULT }    
)  
*/

SELECT *
FROM   SYS.DM_DB_INDEX_OPERATIONAL_STATS (
DB_ID(), 
OBJECT_ID(N'roboButlerPOC_copy.dbo.tableau_LTMVisits'), 
DEFAULT, 
DEFAULT
) A 
INNER JOIN SYS.INDEXES AS I 
ON I.[OBJECT_ID] = A.[OBJECT_ID] 
AND I.INDEX_ID = A.INDEX_ID 
WHERE  OBJECTPROPERTY(A.[OBJECT_ID],'IsUserTable') = 1



SELECT OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
   I.[NAME] AS [INDEX_NAME], 
   USER_SEEKS, 
   USER_SCANS, 
   USER_LOOKUPS, 
   USER_UPDATES 
FROM   SYS.DM_DB_INDEX_USAGE_STATS AS S 
   INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] 
AND I.INDEX_ID = S.INDEX_ID 
WHERE  OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
AND S.database_id = DB_ID()
ANd i.name IS NOT NULl