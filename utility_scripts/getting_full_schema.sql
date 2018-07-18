--table
SELECT * 
FROM sys.tables
where name = 'tableau_PGLTMVisitsWeekly'

-- columns
SELECT c.*
FROM sys.columns c
INNER JOIN sys.tables t
ON c.object_id = t.object_id
AND t.name = 'tableau_PGLTMVisitsWeekly'

SELECT *
FROM information_schema.columns 
WHERE table_name ='tableau_PGLTMVisitsWeekly'

-- PK
SELECT t1.*
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE t1
JOIN SYS.OBJECTS t2
ON t1.TABLE_NAME = t2.name
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
AND t2.type_desc = 'USER_TABLE'
and table_name = 'tableau_PGLTMVisitsWeekly'

-- all constraints
SELECT t1.*
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE t1
JOIN SYS.OBJECTS t2
ON t1.TABLE_NAME = t2.name
WHERE 
 t2.type_desc = 'USER_TABLE'
and table_name = 'tableau_PGLTMVisitsWeekly'

-- index
select * from sys.indexes
where object_id = (select object_id from sys.objects where name = 'tableau_PGLTMVisitsWeekly')

