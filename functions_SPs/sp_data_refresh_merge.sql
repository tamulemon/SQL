-- ==========================================================
-- Drop if already exists
-- ==========================================================

IF (OBJECT_ID('sp_data_refresh_merge') IS NOT NULL)
  DROP PROCEDURE sp_data_refresh_merge
GO

-- ==========================================================
-- Create Stored Procedure Template for Windows Azure SQL Database
-- ==========================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Meng Chen>
-- Create date: <2016-02-15>
-- Description:	Instead of hard coding number of columns that need to be match/update/insert, this SP takes
-- a list of comma deliminated string. Allows more flexibility for table merge
-- =============================================
CREATE PROCEDURE sp_data_refresh_merge
	-- Add the parameters for the stored procedure here
	@target_table [nvarchar] (100), 
	@source_table [nvarchar] (100),
	@match_column_list [nvarchar] (max),
	@update_column_list [nvarchar] (max),
	@insert_column_list [nvarchar] (max),
	@delete_additional_criteria [nvarchar] (max)
AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @SQL [nvarchar] (max)
	DECLARE @sub_SQL_match [nvarchar] (max)
	DECLARE @sub_SQL_update [nvarchar] (max)
	DECLARE @sub_SQL_insert [nvarchar] (max)
	DECLARE @temp [nvarchar] (200)

	SET @temp = ''
	SET @sub_SQL_match = ''
	SET @sub_SQL_update = ''
	SET @sub_SQL_insert = ''

	DECLARE @ParamDefinition [nvarchar] (2000) 

	DECLARE @match_table table (match_columns nvarchar (200))
	DECLARE @update_table table (update_columns nvarchar (200))
	DECLARE @insert_table table (insert_columns nvarchar (200))

	-- 3 tables store criteria
	INSERT INTO @match_table
	SELECT Item FROM dbo.fn_split_string(@match_column_list, ',')

	INSERT INTO @update_table
	SELECT Item FROM dbo.fn_split_string(@update_column_list,',')

	INSERT INTO @insert_table
	SELECT Item FROM dbo.fn_split_string(@insert_column_list,',')
----------------------------------------------------------------------------
-- match statement
	DECLARE cur_match CURSOR FOR 
		SELECT 'TARGET.' + match_columns + ' = SOURCE.' + match_columns + ' AND '
	FROM @match_table
	OPEN cur_match
	WHILE 1 = 1
	BEGIN
		FETCH cur_match INTO @temp
		IF @@FETCH_STATUS = 0
			BEGIN
				SET @sub_SQL_match = @sub_SQL_match + @temp
			END
		ELSE BREAK
	END
	CLOSE cur_match;
	SET @sub_SQL_match = LEFT(@sub_SQL_match, LEN(@sub_SQL_match) - 3) --offset the last 'AND'
---------------------------------------------------------------------------------
SET @temp = ''
-- UPDATE statement
	DECLARE cur_update CURSOR FOR 
		SELECT 'TARGET.' + update_columns + ' = SOURCE.' + update_columns + ','
	FROM @update_table
	OPEN cur_update
	WHILE 1 = 1
	BEGIN
		FETCH cur_update INTO @temp
		IF @@FETCH_STATUS = 0
			BEGIN
				SET @sub_SQL_update = @sub_SQL_update + @temp
			END
		ELSE BREAK
	END
	CLOSE cur_update;
	SET @sub_SQL_update = LEFT(@sub_SQL_update, LEN(@sub_SQL_update) - 1) --offset the last ','
-----------------------------------------------------------------------------------------
SET @temp = ''
-- INSERT statement
	DECLARE cur_insert CURSOR FOR 
		SELECT 'SOURCE.' + insert_columns + ','
	FROM @insert_table
	OPEN cur_insert
	WHILE 1 = 1
	BEGIN
		FETCH cur_insert INTO @temp
		IF @@FETCH_STATUS = 0
			BEGIN
				SET @sub_SQL_insert = @sub_SQL_insert + @temp
			END
		ELSE BREAK
	END
	CLOSE cur_insert;
	SET @sub_SQL_insert = LEFT(@sub_SQL_insert, LEN(@sub_SQL_insert) - 1) --offset the last ','
-----------------------------------------------------------------------------------------
SET @SQL = 
	'MERGE ' + @target_table  + ' AS TARGET
	USING ' + @source_table + ' AS SOURCE
	ON ('+ @sub_SQL_match +
	') WHEN MATCHED 
    THEN UPDATE SET ' +  @sub_SQL_update + 
	' WHEN NOT MATCHED BY SOURCE AND ' + @delete_additional_criteria + ' THEN DELETE  
	 WHEN NOT MATCHED BY TARGET 
		THEN INSERT(' + @insert_column_list + ') VALUES ( ' +  @sub_SQL_insert + ' );'


	EXEC (@SQL)

END
GO


-- =============================================
-- Example
-- =============================================
 --EXEC sp_data_refresh_merge
 --@target_table = '[dbo].[tableau_LTMVisits]',
 --@source_table = '[dbo].[transform_LTMVisits]',
 --@match_column_list = '[Granularity],[Date],[Site],[Business Line],[Product],[Funnel Step],[Funnel Section],[Channel Type],[Channel Group],[Last Touch Marketing Channel],[Audience Type],[Device Type]', 
 --@update_column_list = 'Visits',
 --@insert_column_list = '[Granularity],[Date],[Site],[Business Line],[Product],[Funnel Step],[Funnel Section],[Channel Type],[Channel Group],[Last Touch Marketing Channel],[Audience Type],[Device Type], [Visits]', 
 --@delete_additional_criteria = 'TARGET.[Date] IN (SELECT DISTINCT [Date] FROM [transform_LTMVisits])'
  
  --10/17: 3 sec for scanning 11244 rows