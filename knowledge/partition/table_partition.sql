-- Create dummy data
DROP TABLE EmployeeReports

CREATE TABLE EmployeeReports
(
ReportID int IDENTITY (1,1) NOT NULL,
ReportName varchar (100),
ReportNumber varchar (20),
ReportDescription varchar (max)
CONSTRAINT EReport_PK PRIMARY KEY CLUSTERED (ReportID)
)
 
DECLARE @i int
SET @i = 1
 
BEGIN TRAN
	WHILE @i<3000
		BEGIN
			INSERT INTO EmployeeReports
			(
			ReportName,
			ReportNumber,
			ReportDescription
			)
			VALUES
			(
			'ReportName',
			CONVERT (varchar (20), @i),
			REPLICATE ('Report', 1000)
			)
			SET @i=@i+1
		END
COMMIT TRAN
GO

SELECT COUNT(*)
FROM EmployeeReports
--2999


--- 2017/06/06 streamlined
-- create function
CREATE PARTITION FUNCTION fn_partition_int (int)
AS RANGE RIGHT FOR VALUES(1500)

-- create PS
CREATE PARTITION SCHEME part_scheme
AS PARTITION fn_partition_int
ALL TO ([PRIMARY]) -- everything on PRIMARY

ALTER PARTITION SCHEME part_scheme 
NEXT USED [PRIMARY] 

--move PK
-- haha, this doesn't work
--CREATE CLUSTERED INDEX EReport_PK ON EmployeeReports  (ReportID)  
--WITH(DROP_EXISTING = ON) 
--ON part_scheme([event_date]) 

ALTER TABLE EmployeeReports
DROP CONSTRAINT EReport_PK
WITH(MOVE TO part_scheme([ReportID]))


--- boundaries
SELECT prv.value
FROM sys.TABLES t with (nolock)
JOIN sys.indexes i with (nolock) ON t.object_id = i.object_id
JOIN sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id
JOIN sys.partition_range_values prv ON pf.function_id = pf.function_id
where t.name = 'EmployeeReports'



--split boundary
ALTER PARTITION FUNCTION fn_partition_int ()
SPLIT RANGE (500) -- this means, at 500, split to 2 partitions within partition


ALTER PARTITION FUNCTION fn_partition_int ()
SPLIT RANGE (2000) -- this means, add another boundary at 2000 (expand) need to ALTER Partition scheme, make NEXT USED [PRIMARY] 
-- other wise will error out saying no next filegroup




-- ===============================================================================
-- Partition functions
-- Have to drop partition scheme before partition function can be dropped

SELECT *
FROM sys.partition_schemes

-- drop scheme
IF EXISTS
(SELECT * FROM sys.partition_schemes
WHERE NAME = 'part_scheme')
BEGIN
	DROP PARTITION SCHEME part_scheme
END

-- drop function
IF EXISTS
(SELECT * FROM sys.partition_functions
WHERE NAME = 'fn_partition_int')
BEGIN
	DROP PARTITION FUNCTION fn_partition_int
END



-- ===================================================
-- Create partition function
CREATE PARTITION FUNCTION fn_partition_int (int)
AS RANGE RIGHT FOR VALUES(1500)

SELECT *
FROM sys.partition_functions



-- ======================================================================
-- CREATE partition scheme
---==================================
-- local sql db
-- create a file group
ALTER DATABASE [tmo-dev]
ADD FILEGROUP low_priority
GO

-- Create partition scheme
CREATE PARTITION SCHEME part_scheme
AS PARTITION fn_partition_int
TO (LowerPriority_file_group, [PRIMARY]) -- anything left to the partition criteria, put it in the low_priority file group, 
-- the right put in the PRIMARY file group

ALTER TABLE existing_table
DROP CONSTRAINT pk_abc
WITH(MOVE TO fn_partition_int(ReportNumber))) -- usually move to a file group, but can also specify to move to a partition scheme

--==================================================================================================================================

-- Azure SQL doesn't support file group, everything will be on PRIMARY. Behind the scene the storage engine will balance the load

CREATE PARTITION SCHEME part_scheme
AS PARTITION fn_partition_int
ALL TO ([PRIMARY]) -- everything on PRIMARY
--MSSG: Partition scheme 'part_scheme' has been created successfully. 'PRIMARY' is marked as the next used filegroup in partition scheme 'part_scheme'.

-- error message: Invalid partition scheme 'fn_partition_int' specified.
ALTER TABLE EmployeeReports
DROP CONSTRAINT EReport_PK
WITH(MOVE TO fn_partition_int([ReportID]))



-- the WITH MOVE TO function didn't work for Azure
ALTER TABLE EmployeeReports
DROP CONSTRAINT EReport_PK
WITH(MOVE TO part_scheme([ReportID])) -- Need to use partition_scheme([column_you_partition_on])
-- For some reason when using this 1 step solution on Azure, the constraint/pk was not rebuilt after move.So partition didn't happen correctly


--======= try 2 steps approach
-- WORKS!

ALTER TABLE EmployeeReports
DROP CONSTRAINT EReport_PK

ALTER TABLE EmployeeReports
ADD CONSTRAINT EReport_PK_new PRIMARY KEY CLUSTERED ([ReportID])
ON part_scheme([ReportID])

--===================================================================================================
-- check partition on the table

SELECT DISTINCT t.name, p.partition_number, p.rows, p.filestream_filegroup_id
FROM sys.partitions p
INNER JOIN sys.tables t
ON p.object_id = t.object_id
WHERE p.partition_number <> 1 -- many of the tables has 1 partition, so this will filter out them

--=============
-- check rows are partitioned correctly

--Returns the partition number into which a set of partitioning column values would be mapped for any specified partition function
--[ database_name. ] $PARTITION.partition_function_name(expression)  

SELECT $PARTITION.fn_partition_int([ReportID])
FROM [dbo].[EmployeeReports]
  WHERE [ReportID] = 1499
--1

SELECT $PARTITION.fn_partition_int([ReportID])
FROM [dbo].[EmployeeReports]
  WHERE [ReportID] = 1500
-- 2
--RANGE RIGHT FOR VALUES(1500) so partition boundary is put into right side

-- test partition
SELECT $PARTITION.fn_partition_int(14999)
-- 1

SELECT $PARTITION.fn_partition_int(15000)
-- 2