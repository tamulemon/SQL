-- ==========================================================
-- Create Stored Procedure Template for Windows Azure SQL Database
-- ==========================================================

IF (OBJECT_ID('sp_drop_all_fact_oper_fk') IS NOT NULL)
  DROP PROCEDURE sp_drop_all_fact_oper_fk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		mchen	
-- Create date: 2016/01/25
-- Description:	drop all temporary fk related to temp_tables. so temp tables can be dropped freely when done
-- =============================================
CREATE PROCEDURE sp_drop_all_fact_oper_fk
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @sql varchar(4000)

	DECLARE @fk_table TABLE
	(
		table_name varchar(200),
		fk_name varchar(200)
	);
	
	INSERT INTO @fk_table
	SELECT t1.name AS table_name, fk.name AS fk_name
		FROM SYS.FOREIGN_KEYS fk
		INNER JOIN SYS.TABLES t1
		ON fk.parent_object_id = t1.object_id
		INNER JOIN SYS.OBJECTS t2
		ON t1.object_id = t2.object_id
		WHERE (t1.name LIKE 'fact_%' 
		OR t1.name LIKE 'oper_%')
		AND t2.type_desc = 'USER_TABLE'
		ORDER BY t1.name, fk.name

	DECLARE cur CURSOR FOR
		SELECT 'ALTER TABLE [dbo].[' + table_name + '] DROP CONSTRAINT [' + fk_name + ']' 
		FROM @fk_table

	OPEN cur
	WHILE 1 = 1
	BEGIN
		FETCH cur INTO @sql
		IF @@FETCH_STATUS != 0
		BREAK
		EXEC(@sql)
	END
	CLOSE cur
	DEALLOCATE cur
END
GO
---------------------------------------------------------------------------------------------------------------------------------

--EXEC sp_drop_all_fact_oper_fk
