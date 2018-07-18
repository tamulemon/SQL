USE FCAReport

DBCC SHOW_STATISTICS ('raw_tierless_bc', 'PK__raw_tier__3213E83EE574DB78')

DBCC SHOW_STATISTICS ('raw_tierless_bc', 'raw_tierless_bc_ClusteredIndex')



SELECT OBJECT_NAME(s.object_id) AS object_name,  
    COL_NAME(sc.object_id, sc.column_id) AS column_name,  
    s.name AS statistics_name  
FROM sys.stats AS s JOIN sys.stats_columns AS sc  
    ON s.stats_id = sc.stats_id AND s.object_id = sc.object_id  
WHERE s.name = 'raw_tierless_bc'  
ORDER BY s.name; 