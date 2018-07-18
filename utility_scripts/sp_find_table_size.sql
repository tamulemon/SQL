IF (OBJECT_ID('sp_find_tables_size') IS NOT NULL)
  DROP PROCEDURE sp_find_tables_size
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.sp_find_tables_size
	@order_criteria [nvarchar] (max),
	@table_name_like [nvarchar] (max)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL [nvarchar] (max)

	DECLARE @ParamDefinition [nvarchar] (2000) 

	SET @SQL = 
	'SELECT 
		t.NAME AS TableName,
		t.[create_date],
		t.[modify_date],
		p.rows as RowCounts,
		(SUM(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
		(SUM(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
		(SUM(a.data_pages) * 8) / 1024 as DataSpaceMB
	FROM 
		sys.tables t
	INNER JOIN 
		sys.partitions p ON t.object_id = p.OBJECT_ID 
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	WHERE 
		t.NAME LIKE ' + ''''+ @table_name_like + '''' +
	' GROUP BY t.name,t.[create_date],t.[modify_date], p.rows
	ORDER BY ' + @order_criteria


	SET @ParamDefinition = 
	'@order_criteria [nvarchar] (max),
	@table_name_like [nvarchar] (max)'
	
	EXEC sp_executesql @SQL, @ParamDefinition, @order_criteria , @table_name_like

END
GO

--EXEC sp_find_tables_size
--@order_criteria = 'TableName',
----@order_criteria = 'RowCounts desc',
--@table_name_like = '%'

