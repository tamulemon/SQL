/*
Creating file group is not supported in Azure SQL db. file group is supported in Azure BLOB

*/
USE [Meng_test]
GO


-- add file group
ALTER DATABASE [Meng_test]
ADD FILEGROUP test_archive
GO

--is it created?
SELECT *
FROM sys.filegroups

-- to create and add .ndf file from SSMS
/*
1. right click on the database
2. properties
3. Files
4. Add
5. Select what type of file want to add
*/

-- where is the .ndf located?
SELECT  DB_NAME(database_id) AS [db_name] ,
        type_desc AS [file_type] ,
        name AS [logical_filename] ,
        physical_name AS [file_path]
FROM sys.master_files
ORDER BY db_name, logical_filename



-- Script to add files 
-- give a name to the file
-- use the default path that stores all the data file, in this case, is 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\'
-- Can not manually create a .ndf file through Sublime and save to the path, will get denied

-- Only 1 .ndf file per filegroup, otherwise the same table will be written to all files. duplicated?

ALTER DATABASE [Meng_test]   
ADD FILE   
(  
    NAME = test_add_file_v2,  -- this will dictate the file name
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\ABC.ndf',  -- here only path is used, file name is ignored
    SIZE = 5MB,  
    MAXSIZE = 100MB,  
    FILEGROWTH = 5MB  
)  
TO FILEGROUP test_archive;  
GO  

-- view all objects from all file groups 

SELECT *
FROM sys.filegroups



--move an object from the primary file group to another file group?
-- table with clustered indexed : moving the clustered index moves the base table

-- find what the clustered index is
SELECT so.name, si.name, sc.name, ic.*
FROM sys.indexes si
INNER JOIN sys.objects so
ON si.object_id = so.object_id
INNER JOIN sys.index_columns ic
ON ic.index_id = si.index_id
AND ic.object_id = si.object_id
INNER JOIN sys.columns sc
ON sc.object_id = si.object_id
AND ic.column_id = sc.column_id
WHERE so.name = 'oper_link_name_visits_daily'
AND si.type_desc = 'CLUSTERED'
-- pk name PK__oper_lin__FEFD07B213C13217

-- One step move
CREATE UNIQUE CLUSTERED INDEX PK__oper_lin__FEFD07B213C13217 -- the origin pk name on the table want to move
ON [dbo].[oper_link_name_visits_daily]
	(
	[date_key],
	[bg_site_id],
	[mkt_country_id]
	) 
WITH (DROP_EXISTING =  ON )
ON test_archive
GO
-- only move the PK, All FKs stay in primary?

-- Or, 2 steps. Drop first, create second
-- move PK
ALTER TABLE abc
DROP CONSTRAINT [pk_name_here]
WITH (MOVE TO file_group_group_name)

ALTER TABLE abc
ADD CONSTRAINT [pk_name_here]
PRIMARY KEY ([pk_column])

--==================================================================
-- The following two queries return information about 
-- which objects belongs to which filegroup
SELECT OBJECT_NAME(i.[object_id]) AS [ObjectName]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,i.[data_space_id] AS [DatabaseSpaceID]
    ,f.[name] AS [FileGroup]
    ,d.[physical_name] AS [DatabaseFileName]
FROM [sys].[indexes] i
INNER JOIN [sys].[filegroups] f
    ON f.[data_space_id] = i.[data_space_id]
INNER JOIN [sys].[database_files] d
    ON f.[data_space_id] = d.[data_space_id]
INNER JOIN [sys].[data_spaces] s
    ON f.[data_space_id] = s.[data_space_id]
WHERE OBJECTPROPERTY(i.[object_id], 'IsUserTable') = 1
ORDER BY 
	f.[name],
	OBJECT_NAME(i.[object_id])
    ,i.[data_space_id]


SELECT
p.name AS [Name] ,r.type_desc,r.is_disabled,r.create_date , r.modify_date,r.default_database_name
FROM
sys.server_principals r
INNER JOIN sys.server_role_members m ON r.principal_id = m.role_principal_id
INNER JOIN sys.server_principals p ON
p.principal_id = m.member_principal_id
WHERE r.type = 'R' and r.name = N'sysadmin'