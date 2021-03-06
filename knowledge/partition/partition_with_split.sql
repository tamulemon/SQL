USE [UORL_META]
GO
/****** Object:  StoredProcedure [dbo].[load_evs_online_temp_evs_online]    Script Date: 1/31/2017 4:35:00 PM ******/
-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'load_evs_online_temp_evs_online' 
)
  DROP PROCEDURE [dbo].[load_evs_online_temp_evs_online]
GO


/****** Object:  StoredProcedure [dbo].[load_evs_online_temp_evs_online]    Script Date: 1/31/2017 4:35:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************
* PROCEDURE: [load_evs_online_temp_evs_online]
* PURPOSE:	Load EVS 
*           
* NOTES: This sp loads evs_online from temp_evs_online table

	Issue: Historical load requires a different approach for performance
		   Ongoing weeklt load: temp_evs contains 2 or 3 event_dates for a given load date
		   event_date is the partition key for evs table
		    => work around in this sp 
		 
	Logic:
	1. Create identity_insert table with event_id is an identity insert col starting from the current max_record_id in EVS ( max of evs_online + 1, 1 increment)
	2. Get all the event_date in temp_evs
		If min event_date in temp_evs <  minimum event_date from evs: stop this sp & prompt to change the partition function & scheme on evs manually
		If max event_date in temp_evs is less than the current max_event_date in evs ANd min event_date >= 10/01/15: do HISTORICAL LOAD		
		If max event_date in temp evs > evs's max event_date: do the DAILY LOAD

	HISTORICAL LOAD:
		a. Create a @stg_table on evs's partition function 
		b. Insert all from evs into stg_table
		c. Insert all from identity_insert into stg_table
		d. Create cluster columnstore index on stg_table
		e. Change name stg_table into evs and drop the old one

	
	WEEKLY LOAD: For each date:
		- Run [sp_dmc_setup_daily_fact_stg_tbls] Create the stg_temp table
		- If partition boundary exists for the given event_date in evs_online:
			* Add columnstore index on @stg_table
			* Switch partition from the boundary to evs_online___sp__daily_stg_fact_tbl

			* Drop columnstore index on @stg_table (for performance)
			* Add more records from identity table for the given date
			* Add columnstore index back on @stg_table

			* Add constraints
			* Switch it back to the given boundary
		- ELSE (partition boundary not exists) - new data 
		    * Insert all the new records from identity insert table for the given date into stg_temp
			* Run sp_dmc_setup_daily_fact_tbl_test to switch the stg_temp to the new table

* CREATED: 08/31/2016
* MODIFIED 
* DATE			AUTHOR				DESCRIPTION
* -------------------------------------------------------------------
* 09/16/2016    TTran				Created
* 10/11/2016	TTran				Add meta data id 
							,[ptnr_disp_meta_id]
							,[organic_srch_meta_id]
							,[paid_social_meta_id]
							,[text_ads_meta_id]
							,[ptnr_text_ads_meta_id]
*12/01/2016		TTran		add
						 ,[nielsen_dma_cd]
						,[country_id]
						,[uo_region]
						,[quantity]
						,[revenue]
*12/15/2016		TTran	Add @maxdop to increase parallelism 
						Make @base_table a parameter to work with DCM2 
						dynamically getting column names from the physical table structures
						Add @batch_name
*03/16/2017		TTran	Remove duplicate check for WEEKLY load
						Add HISTORICAL LOAD logic
*03/31/2017		TTran	Remove cluster index creation on stg table
						
********************************************************************/
CREATE PROCEDURE [dbo].[load_evs_online_temp_evs_online]
	(@test_flag BIT =0,
	 @debug BIT =1,
	 @batch_name varchar(30) = 'weekly_update' ,
	 @base_table varchar(100) ='EVS_ONLINE')
AS


SET NOCOUNT ON
--DECLARE VARIABLES	
DECLARE 
		-- Error handling variables
		@error_number INT
		,@error_severity INT
		,@error_state INT
		,@error_procedure VARCHAR(256)
		,@error_line INT
		,@error_message NVARCHAR(2046)

		,@cur_date_list CURSOR
		,@the_date	date				--store event_date in TEMP_EVS
		,@partition_id int				--partition boundary id
		--,@base_table varchar(200)		--Final table (evs_offline) -parameter
		,@stg_table varchar(200)		--temporary table, derived from @base_table
		,@src_table varchar(200)		--TEMP_EVS table where all the ETL data reside
		,@identity_table varchar(200)	--prep table for identity insert
		,@constraint varchar(max)		--constrain on @stg_table
		,@max_record_id			bigint =NULL	--max record # of evs_offline for identity insert
		,@insert_record_count		bigint  --# of new rew records found on TEMP_EVS for a given date
		,@dyn_sql			nvarchar(max)
		,@maxdop nvarchar(10) 	--set degree of parallelism


		,@base_backup_table  nvarchar(100)  --contains new_evs table name, use for HISTORICAL LOAD ONLY
		,@pf_name  nvarchar(100) --contains evs's partition function name, use for HISTORICAL LOAD ONLY
		,@ps_name  nvarchar(100) --contains evs's partition scheme name, use for HISTORICAL LOAD ONLY
		,@ccidx_name  nvarchar(100) --contains evs's partition scheme name, use for HISTORICAL LOAD ONLY

		,@col nvarchar(max) 
		,@src_col_list nvarchar(max) =''
		,@tgt_col_list nvarchar(max) =''
		,@cur_list CURSOR 
		
		,@max_ins_value date
		,@min_ins_value date

				/*********variables to keep track of meta data *******/
		,@component varchar(100)   
		,@proc_error INT
		,@process_name varchar(100)
		,@process_id     VARCHAR(10)
		,@process_log_id		BIGINT 
		,@process_log_status VARCHAR(50)
		,@process_log_status_message VARCHAR(255)
		,@start_time DATETIME
		,@end_time DATETIME
		,@row_count int	=0
		,@tgt_object_id bigint 
		,@src_object_id	bigint
		,@batch_id	bigint
		,@log_comment varchar(max)

SET @component = OBJECT_NAME(@@PROCID)
SET @start_time = GETDATE()

--SET @maxdop
SELECT  @maxdop =  cast(value_in_use as varchar(22)) FROM   uorl_ip.sys.configurations with (nolock) WHERE    name = 'max degree of parallelism'       
--UO dev 
IF @maxdop = 4 SET @maxdop = 10
IF @maxdop IS NULL SET @maxdop = 0 
-----------------------------

--PRINT 'Start ' + @component + ' ' + (CONVERT( VARCHAR(24), @start_time, 121))

---------------------------------------------------------------------------------------------------
--ETL Framework Begin
---------------------------------------------------------------------------------------------------
SET @stg_table  = @base_table+'___sp__daily_stg_fact_tbl'
SET @src_table	= 'TEMP_EVS_ONLINE' 
SET @constraint = 'cnst_'+@stg_table+ '_32413'	
SET @identity_table = @base_table+'_identity_insert'
--the below variable is only used for historical load
SET @base_backup_table = @base_table +'___sp__old'
--set @pf_name from @base_table name = pfn_evs_online
SELECT @pf_name = pf.name	FROM UORL_IP.sys.TABLES t with (nolock)
	JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
	JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
	JOIN UORL_IP.sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id
	where t.name =@base_table

--set @ps_name from @base_table name = ps_evs_online
SELECT @ps_name = ps.name	FROM UORL_IP.sys.TABLES t with (nolock)
	JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
	JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
	where t.name =@base_table

--set @ccidx_name from @base_table name = CCSI_evs_online
SELECT @ccidx_name = i.name	FROM UORL_IP.sys.TABLES t with (nolock)
	JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
	where t.name =@base_table
------------------------------------------------------
IF @debug <> 0 BEGIN	
	print '@stg_table: '+ @stg_table
	print '@constraint: '+ @constraint	
	print '@identity_table: '+ @identity_table	
	print '@base_backup_table: '+ @base_backup_table
	print 'evs @pf_name: '+ @pf_name	
	print 'evs @ps_name: '+ @ps_name	
	print 'evs index name: '+ @ccidx_name	
END

--Logging the process by inserting a row into PROCESS_LOG table
SET @process_name = 'LOAD_EVS_ONLINE'
SELECT @tgt_object_id = object_id from UORL_META..DATA_OBJECT where object_name =@base_table
SELECT @src_object_id = object_id from UORL_META..DATA_OBJECT where object_name =@src_table

--insert necessary meta info for process/data_object if missing
IF (NOT EXISTS ( SELECT * FROM UORL_META.dbo.PROCESS where Process_name =@process_name) OR NOT EXISTS (SELECT * from UORL_META..DATA_OBJECT where object_name in (@src_table,@base_table)))
EXECUTE UORL_META.[dbo].[usp_ins_etl_meta_target_load]  @process_name = @process_name, @src_object_name = @src_table, @tgt_object_name =@base_table

IF @test_flag = 0
BEGIN
-- get @batch_id from a pre-defined @batch_name
    EXECUTE UORL_META.dbo.ops_lkp_batch_id 	@batch_name = @batch_name, 	@batch_id = @batch_id OUTPUT;
	EXECUTE UORL_META.dbo.ops_begin_process_log		@process_name = @process_name   ,@process_log_id = @process_log_id OUTPUT   
END

BEGIN TRY

--log the beginning of sp
SET @log_comment = 'Start ' + @component + ' ' + (CONVERT( VARCHAR(24), @start_time, 121))
PRINT @log_comment
EXEC UORL_META..sp_procedure_log @procedure_name =@component, @log_comment =@log_comment,  @process_log_id = @process_log_id;
/****************************************************************************************
	 Get process_id
****************************************************************************************/
SELECT	@process_id = p.PROCESS_ID  FROM UORL_META.dbo.PROCESS p     WHERE p.PROCESS_NAME = @process_name 

IF @test_flag <> 0
BEGIN 	IF @process_id IS NULL
		BEGIN
			SET @error_message = 'The process ' + @process_name +' is not found'
			GOTO HANDLE_ERROR 
			RAISERROR(@error_message, 16, 1)
		END
END
/****************************************************************************************
Get TEMP_EVS temp table column list and EVS target table column list
****************************************************************************************/
	--infer the column list from source TEMP_EVS table
	--------------------------------------------------------
	exec UORL_META.dbo.[usp_get_column_list] @table_name =@src_table ,@db_name ='UORL_IP',@table_alias ='stg',@col_list = @src_col_list OUTPUT

	--infer the column list from target table - EVS
	--------------------------------------------------------
	exec UORL_META.dbo.[usp_get_column_list] @table_name =@base_table ,@db_name ='UORL_IP',@table_alias =''	,@col_list = @tgt_col_list OUTPUT

/****************************************************************************************
Get the very first @max_record_id
****************************************************************************************/	
	--GET max_record_id
	SET @dyn_sql = 'SELECT @max_record_id = MAX(event_id) FROM UORL_IP.dbo.'+@base_table +'  OPTION (MAXDOP '+@maxdop +')'
	IF @debug = 1		print @dyn_sql
	IF @test_flag =0	EXECUTE sp_executesql @dyn_sql, N'@max_record_id bigint out', @max_record_id out	
	--Add 1 to get the next record id:
	SET	@max_record_id =ISNULL(@max_record_id,0)+1
	IF @debug=1			PRINT ('@max_record_id: '+cast(@max_record_id as varchar))

/****************************************************************************************
	 Get event_date in TEMP_EVS into temp table
****************************************************************************************/
	declare @date_table table (the_date date)
	set @dyn_sql  ='SELECT distinct event_date as event_date FROM UORL_IP.dbo.'+@src_table+' order by event_date asc' 
	insert into @date_table
	execute UORL_META.[dbo].[um_sp_executesql] @nsql =@dyn_sql, @db ='UORL_IP'

	select @max_ins_value = max(the_date) from @date_table
	select @min_ins_value = min(the_date) from @date_table

	IF @debug=1 PRINT  ('@max_ins_value: '+cast(@max_ins_value as varchar))
	IF @debug=1 PRINT  ('@min_ins_value: '+cast(@min_ins_value as varchar))


--If @min_ins_value  < minimum event_date from evs: stop this sp & prompt to change the partition function & scheme on evs manually
IF  @min_ins_value < (select min(prng.value) --get the minimum date from evs from partition function
	FROM UORL_IP.sys.TABLES t with (nolock)	JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id	JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id	JOIN UORL_IP.sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id	INNER JOIN UORL_IP.sys.partition_range_values prng (NOLOCK)		ON prng.function_id=ps.function_id
	WHERE t.name =@base_table ) 
	BEGIN
		SET @error_message = 'Event_date from Temp_evs is out of partition boundary. Manually change the partition function and rerun this sp.'
		GOTO HANDLE_ERROR 
		RAISERROR(@error_message, 16, 1)
	END



/****************************************************************************************
Populate the @identity_insert --Insert from temp_evs for ones that not exists in EVS and set up idenity insert
****************************************************************************************/

/*03/19/2017: This part is used when need to check temp_evs against evs to prevent duplicate loads
--create index for temp_evs
IF NOT EXISTS ( select * from UORL_IP.sys.indexes where object_id = (select object_id from UORL_IP.sys.objects where name = @src_table))
BEGIN
	SET @dyn_sql = 'CREATE CLUSTERED COLUMNSTORE INDEX ccidx_'+@src_table+' ON UORL_IP.dbo.'+@src_table+''
	IF @debug = 1 		print @dyn_sql
	IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;
END
*/

--drop identity table in case already exists
SET @dyn_sql = 'IF OBJECT_ID(''UORL_IP.dbo.'+@identity_table+''') IS NOT NULL	DROP TABLE UORL_IP.dbo.'+@identity_table
IF @debug = 1 		print @dyn_sql
IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;

/*03/19/2017: Un-comment this part when need to check temp_evs against evs to prevent duplicate loads*/
SET @dyn_sql = '
SELECT	event_id = IDENTITY(bigint,'+cast(@max_record_id as varchar)+',1) 
			'+@src_col_list+ ' 
INTO  UORL_IP.dbo.'+@identity_table+'
FROM UORL_IP.dbo.'+@src_table+' stg
LEFT OUTER JOIN 
(SELECT file_id,record_id from UORL_IP.dbo.'+@base_table+' WHERE cast(event_date as date) between '''+cast(@min_ins_value as varchar)+''' and  '''+cast(@max_ins_value as varchar)+''') t 
on t.file_id = stg.file_id	AND t.record_id = stg.record_id
WHERE (t.file_id IS NULL OR t.record_id IS NULL)
OPTION (MAXDOP '+@maxdop+')'
IF @debug = 1 		print @dyn_sql
IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;
/*03/19/2017: End of part*/

 --Set up identity_table from @max_record_id and temp_evs
/*03/19/2017: Un-comment this part when need to by pass dupes checl
SET @dyn_sql = '
SELECT	event_id = IDENTITY(bigint,'+cast(@max_record_id as varchar)+',1) 
			'+@src_col_list+ ' 
INTO  UORL_IP.dbo.'+@identity_table+'
FROM UORL_IP.dbo.'+@src_table+' stg
OPTION (MAXDOP '+@maxdop+')'
IF @debug = 1 		print @dyn_sql
IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;
03/19/2017: End of part*/


	IF @debug = 1	print 'STARTED INCREMENTAL WEEKLY LOAD'
	/*
	--create index for indentity table
	SET @dyn_sql = 'CREATE CLUSTERED INDEX ccidx_'+@identity_table+' ON UORL_IP.dbo.'+@identity_table+' (event_date)'
	IF @debug = 1 		print @dyn_sql
	IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;*/

	SET @cur_date_list= CURSOR 
	FOR select * from @date_table
	/****************************************************************************************
		 For each event_date
	****************************************************************************************/
	OPEN @cur_date_list
	FETCH NEXT FROM @cur_date_list INTO @the_date
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN

	---------------------------------------------------------------------------
	---------------SETTING UP table/variable-----------------------------------
		IF @debug <> 0 print '-----------------------------------------------------------------					 '
			
		--CREATE stg table
		IF @debug = 1	print 'EXEC UORL_IP.dbo.[sp_dmc_setup_daily_fact_stg_tbls]	@base_table ='''+@base_table+''',@execute  = ''Y'',@setup_default =''N'' '
		IF @test_flag =0	EXEC UORL_IP.dbo.[sp_dmc_setup_daily_fact_stg_tbls]		@base_table =@base_table	,@execute  = 'Y'	,@setup_default ='N'
	
		--SET/reset the partition id
		SET @partition_id =NULL		

	---------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------
		--Find boundary to see if the given date is in EVS (base table
		SELECT @partition_id= prng.boundary_id
		FROM UORL_IP.sys.TABLES t with (nolock)
		JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
		JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
		JOIN UORL_IP.sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id
		INNER JOIN UORL_IP.sys.partition_range_values prng (NOLOCK)		ON prng.function_id=ps.function_id
		where t.name =@base_table
		and cast(prng.value as date) =@the_date


		/****************************************************************************************
		If @the_date partition is found on evs_offline
		****************************************************************************************/
		IF @partition_id IS NOT NULL 
		BEGIN		
			---------------------------------------------------------------------------
			--PART 1: switching out partition------------------------------------------
			IF @debug = 1	print ( '**the date:' + cast(@the_date as varchar(max)) )

			 -- Add columnstore index on @stg_table 
			SET @dyn_sql = 'CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_'+@stg_table+'] ON UORL_IP.dbo.'+@stg_table+' WITH (DROP_EXISTING = OFF, MAXDOP = '+@maxdop+' ) ON [PRIMARY]'
			IF @debug =1 PRINT @dyn_sql	
			IF @test_flag =0
			BEGIN
				EXECUTE sp_executesql @dyn_sql;
				IF @@error <> 0
				BEGIN
					SET @error_message = 'Error creating index on '+ @stg_table
					RAISERROR(@error_message,16,1)
				END			
			END

			 -- Switch partition from @base_table to @stg_table for the given event_date
			SET @dyn_sql = 'ALTER TABLE UORL_IP.dbo.'+@base_table+' switch partition '+cast(@partition_id as varchar) +' to UORL_IP.dbo.'+@stg_table
			IF @debug = 1	PRINT '@dyn_sql switch - ' + @dyn_sql
			IF @test_flag =0
			BEGIN
				EXECUTE sp_executesql @dyn_sql;
				IF @@error <> 0
				BEGIN
					SET @error_message = 'Error switching out  '+@base_table+'  partition '+cast(@partition_id as varchar) +' to '+@stg_table
					RAISERROR(@error_message,16,1)
				END			
			END
		
			--drop index -prepping for insert
			SET @dyn_sql = 'DROP INDEX [CCSI_'+@stg_table+'] ON UORL_IP.dbo.'+@stg_table+'  WITH ( ONLINE = OFF, MAXDOP = '+@maxdop+' )'
			IF @debug =1 PRINT @dyn_sql	
			IF @test_flag =0	BEGIN
				EXECUTE sp_executesql @dyn_sql;
				IF @@error <> 0
				BEGIN
					SET @error_message = 'Error dropping index on '+ @stg_table
					RAISERROR(@error_message,16,1)
				END			
			END
	
			----------------------------------------------------------------------------------
			--PART 2:insert new records to @stg_table-----------------------------------------
	
			--construct INSERT query - FROM table with event_id to stg_table
			SET @dyn_sql = '
			INSERT INTO UORL_IP.[dbo].'+@stg_table+' WITH (TABLOCK)
					('+substring(@tgt_col_list,2, len(@tgt_col_list)) +')
			SELECT	'+substring(@tgt_col_list,2, len(@tgt_col_list))+'
			FROM UORL_IP.dbo.'+@identity_table+' 
			WHERE event_date = '''+cast(@the_date as nvarchar)+'''
			OPTION (MAXDOP '+@maxdop+')'
			IF @debug = 1 		print @dyn_sql
			IF @test_flag =0	BEGIN
				EXECUTE sp_executesql @dyn_sql
				SET @insert_record_count=@@rowcount
			END

			--get row_count of this event_date transaction
			SET @row_count = @row_count + @insert_record_count 		
			IF  @debug <>0 		print '@row_count: '+ cast(@row_count as varchar)
				
			----------------------------------------------------------------------------------
			--PART 3:switching the new table back in------------------------------------------	
			--create columnstore index (only if it's already dropped) 
			SET @dyn_sql = 'CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_'+@stg_table+'] ON UORL_IP.dbo.'+@stg_table+' WITH (DROP_EXISTING = OFF) ON [PRIMARY]'
			IF @debug =1  PRINT @dyn_sql	
			IF @test_flag =0 	BEGIN
				EXECUTE sp_executesql @dyn_sql;
				IF @@error <> 0
				BEGIN
					SET @error_message = 'Error creating index on '+ @stg_table
					RAISERROR(@error_message,16,1)
				END			
			END
		

			--drop existing constraint if found
			IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WITH (NOLOCK) WHERE TABLE_NAME = @stg_table AND CONSTRAINT_NAME = @constraint) 
			BEGIN
				SET @dyn_sql = 'ALTER TABLE [UORL_IP].[dbo].['+@stg_table+'] DROP CONSTRAINT ['+@constraint+']'
				IF  @debug = 1 print @dyn_sql	
				IF @test_flag =0
				BEGIN
					EXECUTE sp_executesql @dyn_sql
					IF @@ERROR <> 0 
					BEGIN
						SET @error_message = 'Error dropping constraint on '+ @stg_table
						RAISERROR(@error_message,16,1)	
					END
				END
			END		

			--set up new constraint on @stg_table
			SET @dyn_sql =	' ALTER TABLE UORL_IP.dbo.'+@stg_table +' ADD CONSTRAINT ['+@constraint+ ']'+ 
							' CHECK ( [event_date] = '''+ cast(@the_date as varchar(50)) +''' AND [event_date] IS NOT NULL )'
			IF  @debug = 1 print @dyn_sql	
			IF @test_flag =0
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				IF @@ERROR <> 0 
				BEGIN
					SET @error_message = 'Error creating constraint on '+ @stg_table
					RAISERROR(@error_message,16,1)	
				END
			END

			 -- Switch partition from @stg_table back @base_table
			SET @dyn_sql = 'alter table UORL_IP.dbo.'+@stg_table+' switch to UORL_IP.dbo.'+@base_table+' partition '+cast(@partition_id as varchar)
			IF @debug = 1 PRINT '@dyn_sql switch - ' + @dyn_sql
			IF @test_flag =0
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				IF @@ERROR <> 0 
				BEGIN
					SET @error_message = 'Error executing: '+ @dyn_sql
					RAISERROR(@error_message,16,1)	
				END
			END


		END -- end of @partition_id is not null

		/****************************************************************************************
		If @the_date partition is new
		****************************************************************************************/
		ELSE BEGIN
			IF @debug = 1	print ( '**the date:' + cast(@the_date as varchar(max)) )

			--insert all new records into __sp__daily_stg_fact_tbl table
			SET @dyn_sql = '
			INSERT INTO UORL_IP.[dbo].'+@stg_table+' WITH (TABLOCK)
					('+substring(@tgt_col_list,2, len(@tgt_col_list)) +')
			SELECT	'+substring(@tgt_col_list,2, len(@tgt_col_list))+'
			FROM UORL_IP.dbo.'+@identity_table+' 
			WHERE  event_date = '''+cast(@the_date as nvarchar)+'''
			OPTION (MAXDOP '+@maxdop+')'
			IF @debug = 1 	print @dyn_sql
			IF @test_flag =0
			BEGIN
				EXECUTE sp_executesql @dyn_sql
				SET @insert_record_count =@@rowcount --get record count to populate rowcount 
				IF @@ERROR <> 0 
				BEGIN
					SET @error_message = 'Error executing: '+ @dyn_sql
					RAISERROR(@error_message,16,1)	
				END
			END

			--get row_count of this event_date transaction
			SET @row_count = @row_count + @insert_record_count 
			IF  @debug <>0 		print '@row_count: '+ cast(@row_count as varchar)

			--do the switch	from  _sp__daily_stg_fact_tbl to evs_offline
			IF @test_flag =0	EXEC UORL_IP.dbo.[sp_dmc_setup_daily_fact_tbl] 	@base_table = @base_table , @replace_existing = 'N',@execute = 'Y'
			ELSE print 'EXEC UORL_IP.dbo.[sp_dmc_setup_daily_fact_tbl_test] 	@base_table = '''+@base_table+''' , @replace_existing = ''N'',	@execute = ''Y'''
	
		END-- end of @partition_id is null


		--clean up
		SET @dyn_sql = 'IF OBJECT_ID(''UORL_IP.dbo.'+@stg_table+''') IS NOT NULL	DROP TABLE UORL_IP.dbo.'+@stg_table
		IF @debug = 1 			print @dyn_sql
		IF @test_flag =0		EXECUTE sp_executesql @dyn_sql;

		--get the next date		
		FETCH NEXT FROM @cur_date_list INTO @the_date
	END
	CLOSE @cur_date_list
	DEALLOCATE @cur_date_list


	IF @debug = 1	print 'Start Cleaning up'
	--Cleaning up	--drop identity_insert table
	SET @dyn_sql = 'IF OBJECT_ID(''UORL_IP.dbo.'+@identity_table+''') IS NOT NULL	DROP TABLE UORL_IP.dbo.'+@identity_table
	IF @debug = 1 	print @dyn_sql
	IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;
	--Cleaning up	--drop @stg table
	SET @dyn_sql = 'IF OBJECT_ID(''UORL_IP.dbo.'+@stg_table+''') IS NOT NULL	DROP TABLE UORL_IP.dbo.'+@stg_table
	IF @debug = 1 	print @dyn_sql
	IF @test_flag =0	EXECUTE sp_executesql @dyn_sql;

END TRY
BEGIN CATCH
	SET @error_number = ERROR_NUMBER()
	SET @error_severity = ERROR_SEVERITY()
	SET @error_state = ERROR_STATE()
	SET @error_procedure = ERROR_PROCEDURE()
	SET @error_line = ERROR_LINE()
	SET @error_message = ERROR_MESSAGE()

	GOTO HANDLE_ERROR
END CATCH


SUCCESS:

	SET @process_log_status = 'Completed'
	SET @process_log_status_message =  @component +  ' ' + @process_log_status

	IF @test_flag = 0
	BEGIN
		EXECUTE UORL_META.dbo.ops_end_process_log
			  @process_log_id = @process_log_id
			, @INSERTED_ROWS = @row_count
			, @STATUS_MESSAGE = @process_log_status_message
			, @STATUS = @process_log_status
			, @tgt_object_id = @tgt_object_id
			, @src_object_id = @src_object_id
			,@batch_id = @batch_id

	SET @end_time = getdate()

	END

---------------------------------------------------------------------------------------------------
--ETL Framework End
---------------------------------------------------------------------------------------------------
--log the end of sp
SET @log_comment = 'End OK ' + @component + ' ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
PRINT @log_comment
EXEC UORL_META..sp_procedure_log @procedure_name =@component, @log_comment =@log_comment,  @process_log_id = @process_log_id;

RETURN 0

-------------------------------------------------------------------------------
-- Error Handler
-------------------------------------------------------------------------------
HANDLE_ERROR:

SET @process_log_status = 'FAILED'
SET @process_log_status_message = @component +' : '+ @error_message 
--log failure
SET @log_comment = @process_log_status_message
PRINT @log_comment
EXEC UORL_META..sp_procedure_log @procedure_name =@component, @log_comment =@log_comment,  @process_log_id = @process_log_id;

IF @test_flag = 0
BEGIN
	EXECUTE UORL_META.dbo.ops_end_process_log
		  @process_log_id = @process_log_id
		, @INSERTED_ROWS = @row_count
		, @STATUS_MESSAGE = @process_log_status_message
		, @STATUS = @process_log_status
		, @tgt_object_id = @tgt_object_id
		, @src_object_id = @src_object_id
		,@batch_id = @batch_id
END

PRINT 'End NOTOK ' + @component + ' ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
RAISERROR(@error_message, 16, 1)
RETURN @error_number










GO


