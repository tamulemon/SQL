-- row counts for 2 dates
SELECT event_date, count(*)
from UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]
WHERE event_date between '2016-05-31' and '2016-06-01'
GROUP BY event_date
/*event_date	(No column name)
2016-05-31	12700261
2016-06-01	19481734
*/

-- deletion scope for 2 dates
SELECT event_date, count(*)
from UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]
WHERE event_date between '2016-05-31' and '2016-06-01'
and (dm_meta_id is not null or em_meta_id <> '-2')
GROUP BY event_date
/*
event_date	(No column name)
2016-05-31	142665
2016-06-01	297427
*/

SELECT event_date, count(*)
from UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]
WHERE event_date between '2016-05-31' and '2016-06-01'
and (dm_meta_id is null OR em_meta_id = '-2')
GROUP BY event_date
-- all the rows
/*
event_date	(No column name)
2016-05-31	12700261
2016-06-01	19481734
*/


SELECT event_date, count(*)
from UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]
WHERE event_date between '2016-05-31' and '2016-06-01'
AND (dm_meta_id is null AND (em_meta_id IS NULL OR em_meta_id = -2))
GROUP BY event_date
/*
event_date	(No column name)
2016-05-31	12557596
2016-06-01	19184307
*/


-----------------------------------------------------------------------------------------------------------------------

--test create empty stage table
DECLARE @base_table varchar(100) = 'EVS_ONLINE_MENG_BK_20170413'
DECLARE @stage_table varchar(100) = 'EVS_ONLINE_MENG_BK_20170413___remaining_partition'
DECLARE @SQL varchar(max)
DECLARE @file_group varchar(100) = 'PRIMARY'
DECLARE @debug bit = 1

select @SQL = replace(create_statement,'table ['+@base_table+']','table ['+@stage_table+']') from UORL_IP.dbo.udf_dmc_get_table_syntax_tv(@base_table,'')
		SET @SQL = 	@SQL +' ON ['+@file_group+']'
if @debug = 1
PRINT @SQL
----------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---manual testing switch out/in
-- create archive table
USE UORL_IP
GO
create table [EVS_ONLINE_MENG_BK_20170413___exisiting_partition] (  [event_id] bigint  NOT NULL ,   [disp_meta_id] int  NULL ,   [source_id] int  NOT NULL ,   [cr_link_id] nvarchar(255)  NULL ,   [event_type_descr] nvarchar(50)  NOT NULL ,   [event_type_cat] nvarchar(50)  NOT NULL ,   [event_timestamp] datetime  NULL ,   [event_date] date  NULL ,   [order_id] nvarchar(255)  NULL ,   [file_id] int  NOT NULL ,   [record_id] int  NOT NULL ,   [ps_meta_id] int  NULL ,   [em_meta_id] int  NULL ,   [dm_meta_id] int  NULL ,   [ptnr_disp_meta_id] int  NULL ,   [organic_srch_meta_id] int  NULL ,   [paid_social_meta_id] int  NULL ,   [text_ads_meta_id] int  NULL ,   [ptnr_text_ads_meta_id] int  NULL ,   [nielsen_dma_cd] nvarchar(100)  NULL ,   [country_id] nvarchar(100)  NULL ,   [uo_region] nvarchar(100)  NULL ,   [quantity] int  NULL ,   [revenue] decimal(10, 2)  NULL ,   [active_imp_flag] nvarchar(100)  NULL , ) ON [PRIMARY]

CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_EVS_ONLINE_MENG_BK_20170413___exisiting_partition] ON UORL_IP.. EVS_ONLINE_MENG_BK_20170413___exisiting_partition
WITH (DROP_EXISTING = OFF, MAXDOP = 4 ) ON [PRIMARY]

-- manual switch out
-- after switch out the .EVS_ONLINE_MENG_BK_20170413___exisiting_partition table maintain the original columnstore index
ALTER TABLE UORL_IP..EVS_ONLINE_MENG_BK_20170413 SWITCH PARTITION 246 TO UORL_IP..EVS_ONLINE_MENG_BK_20170413___exisiting_partition

-- manual switch back
ALTER TABLE UORL_IP..EVS_ONLINE_MENG_BK_20170413___exisiting_partition 
SWITCH TO UORL_IP..EVS_ONLINE_MENG_BK_20170413 PARTITION 246
--Check constraints of source table 'UORL_IP.PCLC0\mechen.EVS_ONLINE_MENG_BK_20170413___exisiting_partition' allow values that are not allowed by range defined by partition 246 on target table 'UORL_IP..EVS_ONLINE_MENG_BK_20170413
-- failed becasue constraint not in place

-- manually set up constraint
--first drop exisiting constraint
SELECT *
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WITH (NOLOCK) 
WHERE TABLE_NAME = 'EVS_ONLINE_MENG_BK_20170413___exisiting_partition'
AND CONSTRAINT_NAME = 'cnst_EVS_ONLINE_MENG_BK_20170413___exisiting_partition_32413'
-- no constraint				

ALTER TABLE UORL_IP..EVS_ONLINE_MENG_BK_20170413___exisiting_partition 
ADD CONSTRAINT [cnst_EVS_ONLINE_MENG_BK_20170413___exisiting_partition_32413]
CHECK ( [event_date] = '2016-05-31'AND [event_date] IS NOT NULL)
-- error: The ALTER TABLE statement conflicted with the CHECK constraint 

--why becaue it's 2016, not 2017!!!
SELECT event_date,  count(*)
FROM EVS_ONLINE_MENG_BK_20170413___exisiting_partition
--WHERE event_date <> '2017-05-31'
GROUP BY [event_date] 

----------------------
-- try switch again
ALTER TABLE UORL_IP..EVS_ONLINE_MENG_BK_20170413___exisiting_partition 
SWITCH TO UORL_IP..EVS_ONLINE_MENG_BK_20170413 PARTITION 246
-- worked!!

--EVS_ONLINE_MENG_BK_20170413___exisiting_partition: is empty now
--EVS_ONLINE_MENG_BK_20170413: has all data back


-------------------------------------------------------------------------------
-- test sp
-- 2:25
EXEC UORL_IP..[sp_EVS_stream_deletion_v2]
	 @debug = 0,
	 @test = 1,
	 @dbname = 'UORL_IP',
	 @base_table ='EVS_ONLINE_MENG_BK_20170413', 
	 @remain_criteria = 'dm_meta_id is null AND (em_meta_id IS NULL OR em_meta_id = ''-2'')'

-----------------------------------------------------------------------------
-- test simple deletion
--0:04, what?
DELETE 
FROM UORL_IP..EVS_ONLINE_MENG_BK_20170413
WHERE dm_meta_id is not null OR em_meta_id <> '-2'

-- count after SP. Dropped
SELECT event_date, count(*)
from UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]
GROUP BY event_date
/*
event_date	(No column name)
2016-05-31	12557596
2016-06-01	19184307
*/
----
--fix
--why becaue it's 2016, not 2017!!!
ALTER TABLE UORL_IP..EVS_ONLINE_MENG_BK_20170413___archived_partition 
ADD CONSTRAINT [cnst_EVS_ONLINE_MENG_BK_20170413___archived_partition_32413]
CHECK ( [event_date] = '2016-05-31'AND [event_date] IS NOT NULL)
----------------------
-- try switch again
ALTER TABLE UORL_IP..EVS_ONLINE_MENG_BK_20170413___archived_partition 
SWITCH TO UORL_IP..EVS_ONLINE_MENG_BK_20170413 PARTITION 246

DROP TABLE [PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413___archived_partition]
DROP TABLE [PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413___remaining_rows]

------------------

DECLARE @dyn_sql nvarchar(max)
DECLARE @total_row_count bigint
SET @dyn_sql = 'SELECT @cnt = COUNT_BIG(*) FROM EVS_ONLINE_MENG_BK_20170413'
EXECUTE sp_executesql @dyn_sql, N'@cnt bigint OUT', @cnt = @total_row_count OUT
SELECT @total_row_count


SELECT replace(convert(char(10), '2017-09-01', 111), '-', '')

--USE UORL_IP
--DROP TABLE[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413_archived_partition_2016/05/31]
--DROP TABLE[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413_archived_partition_20160531]
--DROP TABLE[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413_archived_partition_2016-05-31]
--DROP TABLE[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413_remaining_rows_2016/05/31]
--DROP TABLE[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413_remaining_rows_20160531]
--DROP TABLE[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413_remaining_rows_2016-05-31]