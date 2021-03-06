-- =============================================
-- Create basic stored procedure template
-- =============================================

-- Drop stored procedure if it already exists
IF (OBJECT_ID('sp_add_tableName_as_column_and_union') IS NOT NULL)
  DROP PROCEDURE sp_add_tableName_as_column_and_union
GO


-- =============================================
-- Author: mchen
-- Created: 2016/10/17
-- Description: This SP will take a table naming convension and union all tables fullfil this convension, 
-- create a table named 'staging_[table naming convension]' 
-- =============================================
CREATE PROCEDURE sp_add_tableName_as_column_and_union
 @table_name_criteria varchar(100)
AS
BEGIN
-- declare all variables. (not parameters)
	DECLARE @sql [nvarchar](max)
	DECLARE @temp [nvarchar] (max)
	DECLARE @final_table_name [varchar] (100)
	DECLARE @drop_table [nvarchar] (200)

-- instantiate string variables
	SET @sql = ''
	SET @temp = ''
	SET @final_table_name = ''
	SET @drop_table = ''

-- using a cursor to build dynamic sql for fetching table name and union tables 
--with same prefix specified by user defined parameter
	DECLARE cur CURSOR FOR 
		SELECT 
		'(SELECT *, ''' + TABLE_NAME + ''' AS table_name 
		FROM [' + TABLE_NAME + ']) UNION ALL '
		FROM INFORMATION_SCHEMA.TABLES t1
		INNER JOIN SYS.OBJECTS t2
		ON t1.Table_Name = t2.name
		WHERE t1.Table_Name LIKE @table_name_criteria
		AND t2.type_desc = 'USER_TABLE'
	OPEN cur
	WHILE 1 = 1
	BEGIN
		FETCH cur INTO @temp
		IF @@FETCH_STATUS = 0 
			BEGIN
				SET @sql = @sql + @temp
			END
		ELSE BREAK
	END
-- close and dispose cursor
	CLOSE cur;
	DEALLOCATE cur;
-- take out the extra 'UNION' key word from the end of the dynamic sql string
	SET @sql = LEFT(@sql, LEN(@sql) -9) 
-- define view/table name based on user defined parameter
	--SET @final_table_name = 'staging_'+ LEFT(@table_name_criteria, LEN(@table_name_criteria)-1)
	SET @final_table_name = 'staging_'+ RIGHT(@table_name_criteria, PATINDEX ('%[^a-zA-Z0-9]%', REVERSE(@table_name_criteria)) - 1) + '_union'

-- Take the drop-and-recreate method because don't know what are the columns will be, have to use '*'.
-- shouldn't be too costly because each batch of data shouldn't be huge
	SET @drop_table = 'IF (OBJECT_ID(''' + @final_table_name + ''', ''U'') IS NOT NULL) DROP TABLE '+ @final_table_name
	SET @sql = 'SELECT * INTO ' + @final_table_name + ' FROM (' + @sql + ') AS t'
	--PRINT (@drop_table)
	--PRINT (LEN(@sql)) -- can not print out the whole thing as PRINT only print out 4000 char
	EXEC(@drop_table)
	EXEC (@sql)
END
GO

-- =============================================
-- Example to execute the stored procedure
---- =============================================
-- _ is a wildcard in sql, Matches one character.
-- to escape it, need to put [] around
--EXEC sp_add_tableName_as_column_and_union  @table_name_criteria = '%[_]Visits'

--EXEC sp_add_tableName_as_column_and_union  @table_name_criteria = '%[_]LastTouchVisits'

--EXEC sp_add_tableName_as_column_and_union  @table_name_criteria = '%[_]PGVisits'

--EXEC sp_add_tableName_as_column_and_union  @table_name_criteria = '%[_]PGLTMVisits'

/*
10/13: 6986 rows 7 sec, 
27304 rows 6 sec

10/17: 11244 rows 3 sec
*/