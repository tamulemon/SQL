--3:13 7 partitions
DECLARE @row_num bigint
DECLARE @deleted_row int
DECLARE @base_table varchar(100) 
DECLARE @delete_criteria varchar(max)
DECLARE @debug bit = 0
DECLARE @test bit = 1
DECLARE @sql nvarchar(max)
DECLARE @database varchar(20) = 'UORL_IP'
DECLARE @message varchar(max)

SELECT @row_num = COUNT_BIG(*) FROM UORL_IP..EVS_ONLINE_MENG_BK_20170413
SET @base_table = 'EVS_ONLINE_MENG_BK_20170413'
SET @delete_criteria = 'dm_meta_id IS NOT NULL OR em_meta_id <> ''-2'''

WHILE @row_num <> 0
    BEGIN 
        SET ROWCOUNT 1000000
        SET @SQL = 'DELETE FROM '+ @database + '..' + @base_table + ' WHERE ' + @delete_criteria
		IF @debug = 1 or @test = 1
			PRINT @sql
		IF @debug <>1
		BEGIN
			EXEC sp_executesql  @SQL					
			SET @deleted_row = @@ROWCOUNT
			SET @row_num = @deleted_row
			PRINT 'Deleted rows = ' + CAST(@deleted_row AS VARCHAR(10))
			RAISERROR ('', 0, 1) WITH NOWAIT
			
			IF @@ERROR <> 0 
			BEGIN
				DECLARE @error_message varchar(max) = ERROR_MESSAGE()
				Raiserror(@error_message, 16,1)
				RETURN
			END	
        END
	END

USE UORL_IP
ALTER INDEX CCSI_EVS_ONLINE_MENG_BK_20170413
ON EVS_ONLINE_MENG_BK_20170413
REBUILD PARTITION = ALL
--1:17
PRINT 'all done'  

--SELECT t.name, i.name, ps.*
--FROM sys.tables t
--INNER JOIN sys.indexes i
--On t.object_id = i.object_id
--INNER JOIN sys.partition_schemes ps
--ON ps. data_space_id = i.data_space_id
--and t.name = 'EVS_ONLINE_MENG_BK_20170413'