-- create a new schema
CREATE SCHEMA [test_archive_schema]
GO

ALTER SCHEMA [oper_bg_level_agg_daily]
    TRANSFER [dbo].[DTCLastTouchVisits_TotalVisits_Prospect]


-- look at all server principles
SELECT
p.name AS [Name] ,r.name, r.type_desc,r.is_disabled,r.create_date , r.modify_date,r.default_database_name
FROM
sys.server_principals r
INNER JOIN sys.server_role_members m ON r.principal_id = m.role_principal_id
INNER JOIN sys.server_principals p ON
p.principal_id = m.member_principal_id
--WHERE r.type = 'R' and r.name = N'sysadmin'

-- role member relationship table
SELECT *
FROM sys.server_role_members


-- all existing priciples
SELECT *
FROM sys.server_principals

-- a better way to display all principles
SELECT name AS Login_Name, type_desc AS Account_Type
FROM sys.server_principals 
WHERE TYPE IN ('U', 'S', 'G')
and name not like '%##%'
ORDER BY name, type_desc


-- 'sa' is a special login ?
DROP LOGIN sa
GO



--- create a login with pwd first\
-- on Azure db, this has to be done on master
CREATE LOGIN [test_db_owner]   
    WITH PASSWORD = '340$Uuxwp7Mcxo7Khy'  
GO  

-- switch to the target db
-- create a user corresponding to the login
CREATE USER [test_db_owner] FOR LOGIN [test_db_owner] 
WITH DEFAULT_SCHEMA=[dbo]
GO

-- assign a role to a user
-- this sp will 'append' role to a user so a user can have multiple roles
-- to drop role, sp_droprolemember
EXEC sp_addrolemember 'db_owner', 'test_db_owner'
EXEC sp_addrolemember 'db_ddladmin', 'test_db_owner'

-- show all db users and their role
select db_name() as [database_name], r.[name] as [role], p.[name] as [member] from  
    sys.database_role_members m 
join 
    sys.database_principals r on m.role_principal_id = r.principal_id 
join 
    sys.database_principals p on m.member_principal_id = p.principal_id 


/*
db_owner	Members of the db_owner fixed database role can perform all configuration and maintenance activities on the database, and can also drop the database in SQL Server. (In SQL Database and SQL Data Warehouse, some maintenance activities require server-level permissions and cannot be performed by db_owners.)
db_securityadmin	Members of the db_securityadmin fixed database role can modify role membership and manage permissions. Adding principals to this role could enable unintended privilege escalation.
db_accessadmin	Members of the db_accessadmin fixed database role can add or remove access to the database for Windows logins, Windows groups, and SQL Server logins.
db_backupoperator	Members of the db_backupoperator fixed database role can back up the database.
db_ddladmin	Members of the db_ddladmin fixed database role can run any Data Definition Language (DDL) command in a database.
db_datawriter	Members of the db_datawriter fixed database role can add, delete, or change data in all user tables.
db_datareader	Members of the db_datareader fixed database role can read all data from all user tables.
db_denydatawriter	Members of the db_denydatawriter fixed database role cannot add, modify, or delete any data in the user tables within a database.
db_denydatareader	Members of the db_denydatareader fixed database role cannot read any data in the user tables within a database.
*/



-- hide schema from user
-- if user is a db_owner, this doesn't work
DENY VIEW DEFINITION ON SCHEMA:: test_archive_schema
TO test_db_owner

-- change role of the user to read only
EXEC sp_addrolemember 'db_datareader', 'test_db_owner' -- read only role
EXEC sp_droprolemember 'db_owner', 'test_db_owner' -- once the user has only read only role, the schema will be hidden from the user

--EXEC sp_addrolemember 'db_owner', 'test_db_owner' -- db_owner by default has permission
