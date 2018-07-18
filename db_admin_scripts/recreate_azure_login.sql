USE [master]
GO

/****** Object:  Login [mChen]    Script Date: 4/3/2017 1:08:59 PM ******/
DROP LOGIN [mchen]
GO

DROP USER [mchen]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [mChen]    Script Date: 4/3/2017 1:08:59 PM ******/
CREATE LOGIN [mchen] WITH PASSWORD=N'slBPw2ju7V'
GO

ALTER LOGIN [mchen] ENABLE
GO

CREATE USER mchen FROM LOGIN mchen


----------------------------------------------------------------------------
select m.name as Member, r.name as Role
from sys.database_role_members
inner join sys.database_principals m 
on sys.database_role_members.member_principal_id = m.principal_id
inner join sys.database_principals r 
on sys.database_role_members.role_principal_id = r.principal_id

-- only 1 role group?
SELECT *
FROM sys.database_role_members

------------------------------------
SELECT
p.* ,r.*
FROM
sys.database_principals r
INNER JOIN sys.database_role_members m ON r.principal_id = m.role_principal_id
INNER JOIN sys.database_principals p ON
p.principal_id = m.member_principal_id

--------------------
SELECT name AS Login_Name, type_desc AS Account_Type
FROM sys.database_principals 
WHERE TYPE IN ('U', 'S', 'G')
and name not like '%##%'
ORDER BY name, type_desc
-------------------------------------
--- all users
SELECT * 
FROM sys.database_principals 
where (type='S' or type = 'U')
-----------------------------



--- drop inactive users
DROP LOGIN sfriedel
GO

DROP USER sfriedel
GO
-----------------
DROP LOGIN sHong
GO

DROP USER sHong
GO

