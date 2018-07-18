IF (OBJECT_ID ('sp_update_dim_tables') IS NOT NULL)
DROP PROCEDURE sp_update_dim_tables
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE sp_update_dim_tables
AS
BEGIN
	EXEC sp_merge_table  
	 @target_table = 'dim_bg_site',
	 @source_table = 'temp_dim_bg_site',
	 @dim_column = 'bg_site_name',
	 @target_dim_column = 'bg_site_name'

	 EXEC sp_merge_table  
	 @target_table = 'dim_entry_bg_site',
	 @source_table = 'temp_dim_entry_bg_site',
	 @dim_column = 'entry_bg_site_name',
	 @target_dim_column = 'entry_bg_site_name'

	EXEC sp_merge_table  
	 @target_table = 'dim_mkt_country',
	 @source_table = 'temp_dim_mkt_country',
	 @dim_column = 'mkt_country_name',
	 @target_dim_column = 'mkt_country_name'

END
GO

--EXEC sp_update_dim_tables