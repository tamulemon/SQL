-- =============================================
-- Create basic stored procedure template
-- =============================================

-- Drop stored procedure if it already exists
IF (OBJECT_ID('sp_dropTable_like') IS NOT NULL)
  DROP PROCEDURE sp_dropTable_like
GO


-- =============================================
-- Author: mchen
-- Created: 2016/01/20
-- Use: drop tables from database based on user speficied criteria.
--		will execute based on a 'LIKE' statement
-- =============================================
CREATE PROCEDURE dbo.sp_dropTable_like
 @table_name_criteria varchar(100)
AS
BEGIN
	DECLARE @sql varchar(4000)

	-- cursor default to local
	DECLARE cur CURSOR FOR 
		SELECT 'DROP TABLE [' + Table_Name + ']'
		FROM INFORMATION_SCHEMA.TABLES t1
		INNER JOIN SYS.OBJECTS t2
		ON t1.Table_Name = t2.name
		WHERE t1.Table_Name LIKE @table_name_criteria
		-- this is to ensure only drop user defined tables, not system tabless
		AND t2.type_desc = 'USER_TABLE'

	OPEN cur
	WHILE 1 = 1
	BEGIN
		-- retrieve a specific row from cursor into command
		FETCH cur INTO @sql
		-- 0: successful; -1: failed or the row is beyond result set; -2: row fetched is missing
		IF @@FETCH_STATUS != 0 BREAK
		EXEC (@sql)
	END
	CLOSE cur;
	-- remove cursor reference
	DEALLOCATE cur
END
GO

-- =============================================
-- Example to execute the stored procedure
-- =============================================
--EXEC sp_dropTable_like  @table_name_criteria = 'DTC%'
 