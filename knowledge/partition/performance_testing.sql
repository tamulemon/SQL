USE UORL_IP
GO

DROP TABLE [PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413___archived_partition]
DROP TABLE [PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413___remaining_rows]
-----------------------------------------------------------------------------------
DROP TABLE  UORL_IP..EVS_ONLINE_MENG_BK_20170413
GO
----select into
SELECT * INTO UORL_IP..EVS_ONLINE_MENG_BK_20170413
FROM UORL_IP..EVS_ONLINE
WHERE event_date between '2016-05-31' and '2016-06-05'
--32181995
-- 5: 49 for 91611384 rows


CREATE CLUSTERED INDEX CCSI_EVS_ONLINE_MENG_BK_20170413 ON UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]  ([event_date])  
ON ps_EVS_ONLINE_OFFLINE_2([event_date]) 

CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_EVS_ONLINE_MENG_BK_20170413]
ON UORL_IP..EVS_ONLINE_MENG_BK_20170413 WITH (DROP_EXISTING = ON, MAXDOP = 10); 


/**********************************************************************/
-- test v2. with SELECT INTO
-- 4:52 for 7 partitions
-- 1:40 for 2 partitions
EXEC UORL_IP..[sp_EVS_stream_deletion]
	 @debug = 0,
	 @test = 1,
	 @dbname = 'UORL_IP',
	 @base_table ='EVS_ONLINE_MENG_BK_20170413', 
	 @remain_criteria = 'dm_meta_id is null AND (em_meta_id IS NULL OR em_meta_id = ''-2'')'


/**********************************************************************/

-- test v3. delete from archive_table
-- 3:18 for 7 partition with index rebuild
-- In prod: 38min for deletion
-- 45min for updat index
EXEC UORL_IP..[sp_EVS_stream_deletion]
	 @debug = 0,
	 @test = 1,
	 @dbname = 'UORL_IP',
	 @base_table ='EVS_ONLINE_MENG_BK_20170413', 
	 @delete_criteria = 'dm_meta_id IS NOT NULL OR em_meta_id <> ''-2'''


-- em_meta_id =-2 OR  ([dm_meta_id] is null  AND  em_meta_id is null) -- view logic
-- (dm_meta_id IS NULL AND em_meta_id = -2) OR (dm_meta_id IS NULL AND em_meta_id IS NULL) -- remaining logic of deletion
-- when em_meta_id = -2, all dm_meta_id is NULL. so above are equal


/**********************************************************************/
/**********************************************************************/

-- test v4. delete from archive_table
-- 7 partition with index rebuild, 8 min not completed yet. Bad
EXEC UORL_IP..[sp_EVS_stream_deletion]
	 @debug = 0,
	 @test = 1,
	 @dbname = 'UORL_IP',
	 @base_table ='EVS_ONLINE_MENG_BK_20170413', 
	 @delete_criteria = 'dm_meta_id IS NOT NULL OR em_meta_id <> ''-2'''


-- test direct delete from table
-- 0:04 for 2 partitions
-- 0:09 for 7 partition. REbuild index 2:44. so total 2:53
	DELETE
	FROM UORL_IP..EVS_ONLINE_MENG_BK_20170413
	WHERE dm_meta_id IS NOT null OR em_meta_id <> '-2'


	-- rebuild index
	-- instant
	SELECT *   
	FROM sys.column_store_row_groups    
	WHERE object_id  = object_id('EVS_ONLINE_MENG_BK_20170413')  
	ORDER BY row_group_id;  

	-- rebuild partition
	-- 2:44
	ALTER INDEX CCSI_EVS_ONLINE
	ON EVS_ONLINE_MENG_BK_20170413
	REBUILD PARTITION = ALL
  
  
  --91611384 total
  --1192097 delete
  SELECT COUNT(*)
  FROM UORL_IP..EVS_ONLINE_MENG_BK_20170413
  --91151384
  WHERE dm_meta_id IS NOT null OR em_meta_id <> '-2'


  SELECT COUNT(*)
  FROM UORL_IP.[dbo].[EVS_ONLINE_OFFLINE_DEV]
  WHERE dm_meta_id IS NOT null OR em_meta_id <> '-2'
  ---185756055


  SELECT DISTINCT dm_meta_id
FROM UORL_IP.[dbo].[EVS_ONLINE_OFFLINE_DEV]
 WHERE dm_meta_id IS NOT null



  SELECT COUNT(distinct event_date)
FROM UORL_IP.[dbo].[EVS_ONLINE_OFFLINE_DEV]
--315 