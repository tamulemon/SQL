-- ==========================================================
-- Drop if already exists
-- ==========================================================

IF (OBJECT_ID('sp_drop_all_temp_tables') IS NOT NULL)
  DROP PROCEDURE sp_drop_all_temp_tables
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
-- Create date: <2016/01/21>
-- Description:	<execute an existing sp to drop any table starts with 'temp_'>
-- =============================================
CREATE PROCEDURE sp_drop_all_temp_tables
	AS
BEGIN
	-- the temp fk need to be dropped before temp tables can be dropped.
	EXEC sp_drop_all_temp_fk

	EXEC sp_dropTable_like  @table_name_criteria = 'temp_%'

END
GO

