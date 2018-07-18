USE [UORL_IP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*******************************************************************
* PROCEDURE: [sp_EVS_stream_deletion]
* PURPOSE:	Delete rows FROM EVS_ONLINE or EVS_OFFLINE based on user defined criteria partition by partition
* Notes
* Why do it by partition switch: Due to the size of EVS tables, their partition and columnstore index,
								a regular DELECT ... FROM ... WHERE.... statement will run slow and create
								a lot of fragments and the tables need to be re-indexed afterwards. Partition switch
								provide an instant way of remove rows without fragments
* Logic:
- For each value in the partition column(in the case of EVS_ONLINE and EVS_OFFLINE, it's event_date), we need 3 tables
	1. base_table: the original table we need delete rows from. (eg. EVS_ONLINE)
	2. archive_table: this table will be used to temporarity host the daily partition switched out of the base_table
	
- Order of operations for each partition_id:
	1. create empty archive_table 
	2. add correct index information to the partition table 
	3. particular partition_id is switched out from base_table to the archive_table
	4. Delete rows from archive_table
	5. add constraint to the archive_table
	6. add columnstore index to the archive_table
	7. switch archive_table back to the base_table into the partition_id
	8. drop archive_table and archive_table
						
********************************************************************/

IF OBJECT_ID('sp_EVS_stream_deletion', 'P')IS NOT NULL
DROP PROCEDURE sp_EVS_stream_deletion
GO

CREATE PROCEDURE [dbo].[sp_EVS_stream_deletion]
	(
	 @debug BIT = 1,						-- if debug, set to 1
	 @test BIT = 1,							-- even not debug, if want to print out all dyn_sql, set to 1
	 @dbname varchar(100) = 'UORL_IP',
	 @base_table varchar(100) ='EVS_ONLINE',-- can be used for EVS_OFFLINE as well
	 @delete_criteria varchar(max) = '')	-- what rows need to be deleted
AS


SET NOCOUNT ON

DECLARE 
		-- ERROR handling variables
		@ERROR_number INT
		,@ERROR_severity INT
		,@ERROR_state INT
		,@ERROR_procedure VARCHAR(256)
		,@ERROR_line INT
		,@ERROR_message NVARCHAR(2046)

		,@cur_date_list CURSOR
		,@the_date date
		,@partition_id int				
	
		--,@stage_table varchar(100)		
		,@archive_table varchar(100)
		,@col_list nvarchar(max) 
		,@constraint varchar(max) 
		,@file_group varchar(100)

		,@insert_row_count bigint  
		,@total_row_count bigint 
		,@delete_row_count bigint
		,@dyn_sql nvarchar(max) 
		,@maxdop nvarchar(10) 		

		,@pf_name  nvarchar(100) 
		,@ps_name  nvarchar(100) 
		,@ccidx_name  nvarchar(100) 

				/*********variables to keep track of meta data *******/
		--,@component varchar(100)   
		--,@proc_ERROR INT
		--,@process_name varchar(100)
		--,@process_id     VARCHAR(10)
		--,@process_log_id		BIGINT 
		--,@process_log_status VARCHAR(50)
		--,@process_log_status_message VARCHAR(255)
		--,@start_time DATETIME
		--,@end_time DATETIME
		--,@row_count int	=0
		--,@tgt_object_id bigint 
		--,@src_object_id	bigint
		--,@batch_id	bigint
		--,@log_comment varchar(max)

--SET @component = OBJECT_NAME(@@PROCID)
--SET @start_time = GETDATE()

--SET @maxdop
SELECT  @maxdop =  CAST(value_in_use AS varchar(22)) FROM   uorl_ip.sys.configurations WITH (NOLOCK) WHERE name = 'max degree of parallelism'
-- UO dev
IF @maxdop = 4
	SET @maxdop = 10
ELSE if @maxdop IS NULL
	SET @maxdop = 0
	  
-----------------------------
---------------------------------------------------------------------------------------------------
SET @archive_table  = @base_table+'___archived_partition'	
SET @constraint = 'cnst_'+ @archive_table+ '_32413'


--- Retrieve FileGroup of base_table
SELECT TOP 1 @file_group = isnull(fg.name,'PRIMARY') 
	FROM sys.partitions p with (nolock)
	INNER JOIN sys.allocation_units au with (nolock) ON au.container_id = p.hobt_id
	INNER JOIN sys.filegroups fg with (nolock) ON fg.data_space_id = au.data_space_id
	WHERE p.object_id = OBJECT_ID(@base_table)

--retrieve partion function
SELECT @pf_name = pf.name FROM UORL_IP.sys.TABLES t WITH (NOLOCK)
	JOIN UORL_IP.sys.indexes i WITH (NOLOCK) ON t.object_id = i.object_id
	JOIN UORL_IP.sys.partition_schemes ps WITH (NOLOCK) ON i.data_space_id = ps.data_space_id
	JOIN UORL_IP.sys.partition_functions pf WITH (NOLOCK) ON ps.function_id = pf.function_id
	WHERE t.name = @base_table
IF @pf_name IS NULL
BEGIN
	RAISERROR('Cannot retrieve partition function', 16, 1)
END

--retrieve partion scheme
SELECT @ps_name = ps.name FROM UORL_IP.sys.TABLES t WITH (NOLOCK)
	JOIN UORL_IP.sys.indexes i WITH (NOLOCK) ON t.object_id = i.object_id
	JOIN UORL_IP.sys.partition_schemes ps WITH (NOLOCK) ON i.data_space_id = ps.data_space_id
	WHERE t.name = @base_table
IF @ps_name IS NULL
BEGIN
	RAISERROR('Cannot retrieve partition scheme', 16, 1)
END
--retriev index FROM base table
SELECT @ccidx_name = i.name	FROM UORL_IP.sys.TABLES t WITH (NOLOCK)
	JOIN UORL_IP.sys.indexes i WITH (NOLOCK) ON t.object_id = i.object_id
	WHERE t.name = @base_table

-- retrieve all column from base table
EXEC UORL_META.dbo.[usp_get_column_list] @table_name =@base_table ,@db_name ='UORL_IP',@table_alias =''	,@col_list = @col_list OUTPUT

------------------------------------------------------
IF @debug = 1 OR @test = 1
BEGIN	
	--PRINT '@stage_table: '+ @stage_table
	PRINT '@archive_table: ' + @archive_table	
	PRINT 'evs @pf_name: '+ @pf_name	
	PRINT 'evs @ps_name: '+ @ps_name	
	PRINT 'evs index name: '+ @ccidx_name	
END


	/****************************************************************************************
		loop through all event_date FROM the table
	****************************************************************************************/

BEGIN TRY
-- distinct event_date
DECLARE @date_table TABLE (the_date date)
SET @dyn_sql  ='SELECT distinct event_date AS event_date FROM UORL_IP..'+ @base_table +' ORDER BY event_date ASC OPTION (MAXDOP '+@maxdop +')' 
IF @debug = 1 OR @test = 1
	PRINT @dyn_sql
INSERT INTO @date_table
EXECUTE UORL_META.[dbo].[um_sp_executesql] @nsql =@dyn_sql, @db = @dbname

SET @cur_date_list = CURSOR FOR SELECT * FROM @date_table
OPEN @cur_date_list
FETCH NEXT FROM @cur_date_list INTO @the_date
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	--------------------------------------------------------------------------------------------------------
	---0. Create empty archive_table
	--------------------------------------------------------------------------------------------------------
	--- Create empty archive_table
	SET @dyn_sql = ''
	select @dyn_sql = replace(create_statement,'table ['+@base_table+']','table ['+@archive_table+']') FROM UORL_IP.dbo.udf_dmc_get_table_syntax_tv(@base_table,'') 
	select @dyn_sql = @dyn_sql +' ON ['+@file_group+']'
	IF @debug = 1 OR @test = 1
		PRINT @dyn_sql
	IF @debug <> 1 
	BEGIN 
		EXEC sp_executesql  @dyn_sql
		IF @@ERROR <> 0 
		BEGIN
			SET @ERROR_message = 'ERROR creating table: '+ @archive_table
			RAISERROR(@ERROR_message,16,1)
		END	
	END
	
	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
	-- get @partition_id for a specific date, need it to swith back in 
	SELECT @partition_id= prng.boundary_id
		FROM UORL_IP.sys.TABLES t WITH (NOLOCK)
		JOIN UORL_IP.sys.indexes i WITH (NOLOCK) ON t.object_id = i.object_id
		JOIN UORL_IP.sys.partition_schemes ps WITH (NOLOCK) ON i.data_space_id = ps.data_space_id
		JOIN UORL_IP.sys.partition_functions pf WITH (NOLOCK) ON ps.function_id = pf.function_id
		INNER JOIN UORL_IP.sys.partition_range_values prng (NOLOCK)	ON prng.function_id=ps.function_id
		WHERE t.name = @base_table
		and CAST(prng.value AS date) = @the_date

	IF @partition_id IS NOT NULL 
	BEGIN		
		PRINT 'operation on event_date: ' + cast(@the_date as varchar(20))
			---------------------------------------------------------------------------
			-- 1: switching out partition to archive table
			--------------------------------------------------------------------------
		-- Add columnstore index ON @archive_table.Ther is not PK or other constraint on EVS_ONLINE table, otherwise all need to be created
			SET @dyn_sql = 'CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_'+ @archive_table + '] 
							ON UORL_IP..'+ @archive_table+' WITH (DROP_EXISTING = OFF, MAXDOP = '+@maxdop+' ) ON [' + @file_group + ']'
			IF @debug = 1 OR @test = 1
				PRINT @dyn_sql	
			IF @debug <> 1
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				IF @@ERROR <> 0
				BEGIN
					SET @ERROR_message = 'ERROR creating COLUMNSTORE INDEX ON '+ @archive_table
					RAISERROR(@ERROR_message,16,1)
				END	
			END
			 -- Switch partition FROM @base_table to @archive_table for the given event_date
		SET @dyn_sql = 'ALTER TABLE UORL_IP..'+ @base_table + ' SWITCH PARTITION '
		+ CAST(@partition_id AS varchar) +' TO UORL_IP..'+ @archive_table
		IF @debug = 1 OR @test = 1	
			PRINT '@dyn_sql switch out:  ' + @dyn_sql
		IF @debug <> 1
		BEGIN
			EXECUTE sp_executesql @dyn_sql;
			IF @@ERROR <> 0
			BEGIN
				SET @ERROR_message = 'ERROR executing partition switching out  '+ @base_table+'  partition '
				+ CAST(@partition_id AS varchar) +' to '+ @archive_table
				RAISERROR(@ERROR_message,16,1)
			END			
		END
			----------------------------------------------------------------------------------
			-- 2: Delete from @archive_table 		
			----------------------------------------------------------------------------------

			SET @dyn_sql = 'DELETE FROM UORL_IP..' + @archive_table + ' 
			WHERE ' + @delete_criteria + ' 
			OPTION (MAXDOP '+ @maxdop +')'

			IF @debug = 1 OR @test = 1 		
				PRINT @dyn_sql
			IF @debug <> 1	
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				IF @@ERROR <> 0
				BEGIN
					SET @ERROR_message = 'ERROR deleting rows from archive table: ' + @archive_table
					RAISERROR(@ERROR_message,16,1)
				END	
				SET @delete_row_count = @@rowcount
			END
			
			PRINT 'Deleted row count for '+ CAST(@the_date AS varchar(20)) + ':' + cast(@delete_row_count AS varchar(100))
			-- set NOCOUNT ON so will be 0

			----------------------------------------------------------------------------------
			--3:switching the @archive_table back into @base_table
			-----------------------------------------------------------------------------------
			--set up new constraint ON @archive_table
			SET @dyn_sql =	' ALTER TABLE UORL_IP..'+ @archive_table +' ADD CONSTRAINT ['+ @constraint+ ']'+ 
							' CHECK ( [event_date] = '''+ cast(@the_date AS varchar(50)) +''' AND [event_date] IS NOT NULL )'
			IF  @debug = 1 OR @test = 1 
				PRINT @dyn_sql	
			IF @debug <> 1
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				IF @@ERROR <> 0 
				BEGIN
					SET @ERROR_message = 'ERROR creating constraint ON '+ @archive_table
					RAISERROR(@ERROR_message,16,1)	
				END
			END

			 -- Switch partition FROM @archive_table back @base_table
			SET @dyn_sql = 'ALTER TABLE UORL_IP..'+ @archive_table 
			+' SWITCH to UORL_IP..'+ @base_table+' PARTITION '+ CAST(@partition_id AS varchar)
			IF @debug = 1 OR @test = 1 
				PRINT '@dyn_sql switch in: ' + @dyn_sql
			IF @debug <> 1
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				IF @@ERROR <> 0 
				BEGIN
					SET @ERROR_message = 'ERROR executing patition switch in: '+ @dyn_sql
					RAISERROR(@ERROR_message,16,1)	
				END
			END

			-- Rebuild Index
			SET @dyn_sql ='ALTER INDEX [CCSI_'+ @base_table + '] 
			  ON UORL_IP..' + @base_table +
			' REBUILD PARTITION = ' + CAST(@partition_id AS varchar(100))  
			IF @debug = 1 OR @test = 1 
				PRINT  @dyn_sql				
			IF @debug <> 1 
				BEGIN
				exec sp_executesql  @dyn_sql	
				IF @@ERROR <> 0 
				BEGIN	
					SET @ERROR_message = 'Can not rebuild columnstore index for the partition. '		
					Raiserror( @ERROR_message, 16,1) 
					RETURN				
				END
			END
	
			PRINT 'Rebuild Index success.'
			--don't need to update statistics
		----------------------------------------------------------------------------------
			--4:clean up. Drop archive table
		----------------------------------------------------------------------------------

		SET @dyn_sql = 'IF OBJECT_ID(''UORL_IP..'+ @archive_table +''') IS NOT NULL	DROP TABLE UORL_IP..'+ @archive_table
		IF @debug = 1 OR @test = 1 			
			PRINT @dyn_sql
		
			IF @debug <> 1
		BEGIN 
			EXECUTE sp_executesql @dyn_sql;
			IF @@ERROR <> 0 
			BEGIN
				SET @ERROR_message = 'Can not drop table '+ @archive_table
				RAISERROR(@ERROR_message,16,1)	
			END
		END

	END -- end of @partition_id is not nul
	
	--get the next date		
	FETCH NEXT FROM @cur_date_list INTO @the_date
END -- end of while loop for the cursor
	CLOSE @cur_date_list
	DEALLOCATE @cur_date_list

	PRINT 'Deletion success.'
	
END TRY

BEGIN CATCH
	SET @ERROR_number = ERROR_NUMBER()
	SET @ERROR_severity = ERROR_SEVERITY()
	SET @ERROR_state = ERROR_STATE()
	SET @ERROR_procedure = ERROR_PROCEDURE()
	SET @ERROR_line = ERROR_LINE()
	SET @ERROR_message = ERROR_MESSAGE()

	GOTO HANDLE_ERROR
END CATCH



---------------------------------------------------------------------------------
---- ERROR Handler
---------------------------------------------------------------------------------
HANDLE_ERROR:
	PRINT 'failed: ' + @ERROR_message







GO


