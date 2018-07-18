/* this stored procedure will select all columns from a user specified table where column name matches certain user specified criteria*/

--drop the stored precedure if namespace already exists
IF (OBJECT_ID('sp_selectColumns') IS NOT NULL)
  DROP PROCEDURE sp_selectColumns
GO

--create stored procedure
CREATE PROCEDURE sp_selectColumns
 @table_name varchar(100),
 @column_name_criteria varchar(1000) 
AS
BEGIN
	DECLARE @sql nvarchar(max)
	DECLARE @ParamDefinition NVarchar(2000) 
	SET @sql = 'SELECT '

	IF @table_name IS NOT NULL AND @column_name_criteria IS NOT NULL 
		SELECT @sql = @sql + '[' + column_name + '],'
		FROM [INFORMATION_SCHEMA].[COLUMNS]
		WHERE column_name LIKE @column_name_criteria + '%'
		SET @sql = left(@sql, LEN(@sql)-1) 
		SET @sql = @sql + 'FROM' + @table_name 

	SET @ParamDefinition = '@table_name varchar(100),
							@column_name_criteria varchar(1000)'

	EXEC sp_executesql @sql, @ParamDefinition, @table_name , @column_name_criteria 

	-- error handling
 --   IF @@ERROR <> 0 
	--	BEGIN
	--	-- return -1 to indicate failure
	--		PRINT @@ERROR;
	--		PRINT N'Error! Script is not run successfully';
	--		RETURN -1;
	--	END
	--ELSE
	--	BEGIN
	--	-- Return 0 to the calling program to indicate success.
	--		PRINT N'Script is run successfully';
	--		RETURN 0;
	--	END

END
GO

------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_selectColumns  @table_name = '[dbo].[timeSeries_agg_linkToSd]',  @column_name_criteria = 'hasLinkToSD_offset'
 

SELECT TOP 100 *
FROM [dbo].[timeSeries_agg_linkToSd]