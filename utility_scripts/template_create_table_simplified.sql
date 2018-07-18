/*
date of execution: 
author:
purpose:
note:  
*/

/* columns and data source
example:
date_key						fact_semiAdd_hasKhronos_bg
mkt_country_id					fact_semiAdd_hasKhronos_bg
visit_type						?			
*/

-- drop table if exists
IF EXISTS 
(
	SELECT [TABLE_NAME]
	FROM [INFORMATION_SCHEMA].[TABLES]
	WHERE [TABLE_NAME] = 'your_table_name'
)
BEGIN 
	DROP TABLE [your_table_name]
END

-- create table with your table name
-- if using a composite pk consists with multiple columns, all columns need to be not null
-- fk: specify reference 
CREATE TABLE [dbo].[your_table_name] 
(
-- add column name, data type, and other attributes as needed. eg, length for nvarchar, null/not null...
-- if surrogate key is desired, add the following line
-- [id] INT IDENTITY (1,1) NOT null, 
-- some example columns as following
    [column_a] [int] NOT NULL,
	[column_b] [nvarchar] (100) NOT NULL,
	[column_c] [nvarchar] (100) NULL

-- if clustered index is not desired, use PRIMARY KEY instead and specify index  
-- all columns as part of composite key have to be NOT NULL
	--PRIMARY KEY
	PRIMARY KEY CLUSTERED 
	(
	[your_composite_key_column1], 
	[your_composite_key_column2]
	),

	FOREIGN KEY ([your_column_name]) 
    REFERENCES [dbo].[your_dim_table] ([your_column_name]) 
    ON DELETE CASCADE
    ON UPDATE CASCADE

) ON [PRIMARY]
GO

-- make and populate temp tables if needed to facilitate joins
-- everything will be the same except table name will start with #. temp tables only live on a working session. Once the session is ended, the table is gone
-- enable appropriate index/constraint on temp table as you will do to a regular table
CREATE TABLE #temp_table_1
()
 

-- populate table
INSERT INTO [dbo].[your_table_name] 
(
	[your_column1],
	[your_column2]
)
SELECT
	[source_column1],
	[source_column2]
FROM [dbo].[source_table]
-- user regular WHERE, and GROUP BY clause to select specific rows to insert into your table


-- check output of the table
SELECT TOP 100 *
FROM [dbo].[your_table_name]