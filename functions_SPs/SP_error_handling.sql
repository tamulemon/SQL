USE UORL_META
GO

--------------------------------------------------------------------------------------------------- 
--ETL Framework Begin 
---------------------------------------------------------------------------------------------------

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'load_facebook_dma' 
)
   DROP PROCEDURE load_facebook_dma
GO

/****** Object:  StoredProcedure [dbo].[load_facebook_dma]    Script Date: 05/01/2017 2:55:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************
* PROCEDURE: load_facebook_dma
* PURPOSE:	 Pulls the stage data from source, [PRST_STG_UO_facebook_dma] into the target table [facebook_dma]
*           
* NOTES: These META tables require set up: PROCESS, DATA_OBJECT
*			
*
* CREATED:  2017-05-01   Meng Chen  
* MODIFIED 
*	DATE			AUTHOR         DESCRIPTION 
* -------------------------------------------------------------------
	05/01/2017		MeChen		Create. Work with batch automation
********************************************************************/
CREATE PROCEDURE [dbo].[load_facebook_dma]
(@batch_name VARCHAR(50) = 'weekly_update') --default 

AS 
SET nocount ON 

DECLARE 
/*********variables to keep track of meta data *******/ 
	@component                  VARCHAR(100)
	,@log_comment varchar(200)
	,@proc_name varchar(200)
	,@src_tablename  varchar(50)
	,@tgt_tablename varchar(50)
	,@source_code varchar(50)
	,@file_id bigint =NULL
	,@source_id bigint =NULL
	--------------------------------------
	,@proc_error                 INT,
	@process_name               VARCHAR(100), 
	@process_id                 VARCHAR(10), 
	@process_log_id             BIGINT =-1, 
	@process_log_status         VARCHAR(50), 
	@process_log_status_message VARCHAR(255), 
	@start_time                 DATETIME, 
	@end_time                   DATETIME, 
	@insert_row_count           INT = NULL, 
	@update_row_count           INT = NULL, 
	@delete_row_count           INT = NULL, 
	@tgt_object_id              BIGINT, 
	@src_object_id              BIGINT 
	-- Error handling variables 
	, 
	@error_number               INT, 
	@error_severity             INT, 
	@error_state                INT, 
	@error_procedure            VARCHAR(256), 
	@error_line                 INT, 
	@error_message              NVARCHAR(2046) ,
	@batch_id                   BIGINT ;

	SET @component = Object_name(@@PROCID) 
	SET @start_time = Getdate() 

	PRINT 'Start ' + @component + ' ' + ( CONVERT(VARCHAR(24), @start_time, 121) 
) 

SET @process_name	= OBJECT_NAME(@@PROCID) 
	
IF NOT EXISTS ( SELECT * FROM UORL_META.dbo.PROCESS where Process_name =@process_name) EXECUTE UORL_META.[dbo].[usp_ins_etl_meta_target_load]  @process_name = @process_name
SET @source_code	= 'UO_FACEBOOK_DMA'
SET @src_tablename  = 'PRST_STG_UO_FACEBOOK_DMA';
SET @tgt_tablename	= 'FACEBOOK_DMA' ;
SET @proc_name		= OBJECT_NAME(@@PROCID);

--insert necessary meta info for process/data_object if missing
IF (NOT EXISTS ( SELECT * FROM UORL_META.dbo.PROCESS where Process_name =@process_name) OR NOT EXISTS (SELECT * from UORL_META..DATA_OBJECT where object_name in (@src_tablename,@tgt_tablename)))
EXECUTE UORL_META.[dbo].[usp_ins_etl_meta_target_load]  @process_name = @process_name, @src_object_name = @src_tablename, @tgt_object_name =@tgt_tablename

--set object_id
SELECT @tgt_object_id = object_id from UORL_META..DATA_OBJECT where object_name =@tgt_tablename
SELECT @src_object_id = object_id from UORL_META..DATA_OBJECT where object_name =@src_tablename

--DECLARE @active_file_id TABLE (    file_id bigint,    file_date datetime  , source_id bigint)  --Table

BEGIN TRY 
print 'ETL begin'

DECLARE @cur_list CURSOR

--Get the list of of active file_id to load for the given @process_name & @source_code and assign for this cursor 
SET @cur_list = CURSOR
FOR 
select file_id, source_id from UORL_META.dbo.FnGetActiveFileID(@source_code, @batch_name) order by file_date asc

--go through cursor
OPEN @cur_list
FETCH NEXT FROM @cur_list INTO @file_id, @source_id
WHILE (@@FETCH_STATUS <> -1)
BEGIN
	-- Start process log by inserting into PROCESS_LOG table		
	EXECUTE UORL_META.dbo.ops_lkp_batch_id		@batch_name = @batch_name,	@batch_id = @batch_id OUTPUT;
	EXECUTE UORL_META.dbo.ops_begin_process_log		@process_name = @process_name  ,@process_log_id = @process_log_id OUTPUT;

	--log comment in sp_procedure_log for debugging
	SET @log_comment = 'The Stored procedure started'
	PRINT @log_comment
	EXEC UORL_META..sp_procedure_log @proc_name,@log_comment, @process_log_id ;
--------------------------------------------------------------------------------------------------- 
--ETL Framework End 
--------------------------------------------------------------------------------------------------- 
	
	--set up tables to get counts
	DECLARE @SummaryOfChanges TABLE(Change VARCHAR(20));  
	--------------------------------------------------------------------------------------------------- 
	-- INSERT ETL CODES HERE
	--------------------------------------------------------------------------------------------------- 
	MERGE INTO UORL_IP..FACEBOOK_DMA AS TARGET
	USING 
	(
		SELECT
			[RecordNum],
			CAST([reporting_start_date] AS DATE) AS [reporting_start_date],
			[campaign_name],
			[dma_region],

			[Impressions],
			[Link Clicks],
			[Amount Spent (USD)],
			[CPC (Cost per Link Click) (USD)],
			[create_user],
			[create_dt],
			s.[file_id],
			@source_id AS source_id
		FROM UORL_STAGE.[dbo].[PRST_STG_UO_facebook_dma] AS s
		WHERE s.file_id = @file_id
		--INNER JOIN @active_file_id AS a
		--ON s.file_id = a.file_id
		AND CAST(s.[reporting_start_date] AS DATE) >= '2016/12/16' -- Facebook DMA was implemented on 2016/12/16. 
		OR (CAST(s.[reporting_start_date] AS DATE) < '2016/12/16' AND s.dma_region = 'Unknown') -- Prior to 2016/12/16, all metrics were rolled upto a row with dma labeled as 'Unknown'		
	)AS SOURCE
	ON TARGET.[date] = SOURCE.[reporting_start_date]		--NK	
	AND TARGET.[campaign] = SOURCE.[campaign_name]			--NK
	AND TARGET.[dma_name] = SOURCE.[dma_region]				--NK

	WHEN MATCHED THEN
	UPDATE
		SET 
		TARGET.[impressions] = SOURCE.[Impressions],		-- updtate metrics
		TARGET.[link_clicks] = SOURCE.[Link Clicks],
		TARGET.[amount_spent] = SOURCE.[Amount Spent (USD)],
		TARGET.[cost_per_link_click] = SOURCE.[CPC (Cost per Link Click) (USD)],

		TARGET.[file_id] = SOURCE.[File_Id],						--ETL
		TARGET.[record_id] = SOURCE.[RecordNum],					--ETL
		TARGET.[update_user] = SUSER_NAME(),						--ETL
		TARGET.[update_dt] = GETDATE(),								--ETL
		TARGET.[update_process_log_id] = @process_log_id			--ETL
	WHEN NOT MATCHED THEN
	INSERT(
			[date],
			[campaign], 
			[dma_name], 
			[impressions], 
			[link_clicks] ,
			[amount_spent],
			[cost_per_link_click], 

			[file_id],
			[source_id],
			[record_id],
			[update_dt],
			[update_user],
			[create_dt],
			[create_user],
			[create_process_log_id],
			[update_process_log_id]
	)
	VALUES
	(
			SOURCE.[reporting_start_date],
			SOURCE.[campaign_name],
			SOURCE.[dma_region],
			SOURCE.[Impressions],
			SOURCE.[Link Clicks],
			SOURCE.[Amount Spent (USD)],
			SOURCE.[CPC (Cost per Link Click) (USD)],

			SOURCE.[File_Id],
			SOURCE.[source_id],
			SOURCE.[RecordNum],
			GETDATE(), 
			SUSER_NAME(), 
			GETDATE(), 
			SUSER_NAME(), 
			@process_log_id, 
			@process_log_id
	)

	--UPDATE  UORL_IP..facebook_dma
	--SET model_category = 
	--------------------------------------------------------------------------------------------------- 
	-- END of INSERT ETL 
	--------------------------------------------------------------------------------------------------- 
	OUTPUT $action INTO @SummaryOfChanges;  --output action

	--get row counts
	SElECT @insert_row_count = COUNT(*) FROM @SummaryOfChanges WHERE Change ='INSERT'
	print 'Inserting row: ' + cast(@insert_row_count  as varchar(max))
	SElECT @update_row_count = COUNT(*) FROM @SummaryOfChanges WHERE Change ='UPDATE'
	print 'Updating row: ' + cast(@update_row_count  as varchar(max))
	SET @delete_row_count =0
	print 'Deleted row: ' + cast(@delete_row_count  as varchar(max))
--------------------------------------------------------------------------------------------------- 
--ETL Framework Begin 
--------------------------------------------------------------------------------------------------- 
	SET @process_log_status = 'Completed'
	SET @process_log_status_message =  @component +  ' ' + @process_log_status

	-- end process_log, assigning batch_id, file_id, row count, target and object id
	EXECUTE UORL_META.dbo.ops_end_process_log
		  @process_log_id = @process_log_id
		,@INSERTED_ROWS =	@insert_row_count
		,@UPDATED_ROWS =	@update_row_count
		,@DELETED_ROWS =	@delete_row_count
		, @STATUS_MESSAGE = @process_log_status_message
		, @STATUS = @process_log_status
		, @tgt_object_id = @tgt_object_id
		, @src_object_id = @src_object_id
		,@src_file_id =@file_id
		,@batch_id= @batch_id

	SET @log_comment = 'The Stored procedure completed successfully'
    PRINT @log_comment
    EXEC UORL_META..sp_procedure_log @proc_name, @log_comment, @process_log_id = @process_log_id;
	--get the next file
	FETCH NEXT FROM @cur_list INTO @file_id, @source_id
END

CLOSE @cur_list
DEALLOCATE @cur_list
END try 

BEGIN catch 
SET @error_number = Error_number() 
SET @error_severity = Error_severity() 
SET @error_state = Error_state() 
SET @error_procedure = Error_procedure() 
SET @error_line = Error_line() 
SET @error_message = Error_message() 

GOTO handle_error 
END catch 


SUCCESS:

	PRINT 'End OK ' + @component + ' ' + ( CONVERT(VARCHAR(24), Getdate(), 121) 
) 

RETURN 0 

------------------------------------------------------------------------------- 
-- Error Handler 
------------------------------------------------------------------------------- 
HANDLE_ERROR:

SET @process_log_status = 'FAILED'
	SET @process_log_status_message = @component +' : '+ @error_message

print 'get to HANDLE_ERROR'
	SET @log_comment = 'The Stored procedure completed failed. ' + @error_message
	PRINT @log_comment

	EXEC UORL_META..sp_procedure_log @proc_name, @log_comment, @process_log_id = @process_log_id;

	-- end process_log, assigning batch_id, file_id, row count, target and object id
   	EXECUTE UORL_META.dbo.ops_end_process_log
		  @process_log_id = @process_log_id
		,@INSERTED_ROWS =	@insert_row_count
		,@UPDATED_ROWS =	@update_row_count
		,@DELETED_ROWS =	@delete_row_count
		, @STATUS_MESSAGE = @process_log_status_message
		, @STATUS = @process_log_status
		, @tgt_object_id = @tgt_object_id
		, @src_object_id = @src_object_id
		,@src_file_id =@file_id
		,@batch_id= @batch_id

PRINT 'End NOTOK ' + @component + ' ' + (CONVERT( VARCHAR(24), GETDATE(), 121))
RAISERROR(@error_message, 16, 1)
RETURN @error_number


--------------------------------------------------------------------------------------------------- 
--ETL Framework End 
--------------------------------------------------------------------------------------------------- 