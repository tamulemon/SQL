SELECT count(distinct event_date)
FROM UORL_IP..evs_ONLINE
--459 partitions total in prod

SELECT COUNT(*)
FROM UORL_IP..EVS_ONLINE
where dm_meta_id is not null
or em_meta_id <> '-2'
--203,340,983 prod

SELECT COUNT_big(*)
FROM UORL_IP..EVS_ONLINE
--5,424,244,576 prod

USE UORL_IP
GO

-- check what is the column the table is partitioned on
SELECT	c.name, i.data_type
from  sys.index_columns  ic  with (nolock)
join  sys.columns         c  with (nolock)
		on(c.object_id = ic.object_id 
		and c.column_id = ic.column_id)  
join INFORMATION_SCHEMA.COLUMNS i  with (nolock)
on c.object_id =  object_id(i.TABLE_NAME)
and c.name = i.COLUMN_NAME
where ic.partition_ordinal > 0 
and i.table_name = 'EVS_ONLINE'

---------------------------------------------------
-- in preparation for testing. setting up bk table with 2 days
select min(event_date)
from UORL_IP..EVS_ONLINE

-- row counts for 2 dates
SELECT event_date, count(*)
from UORL_IP..EVS_ONLINE
WHERE event_date between '2016-05-31' and '2016-06-01'
GROUP BY event_date
/*event_date	(No column name)
2016-05-31	12700261
2016-06-01	19481734*/

-- deletion scope for 2 dates
SELECT event_date, count(*)
from UORL_IP..EVS_ONLINE
WHERE event_date between '2016-05-31' and '2016-06-01'
and (dm_meta_id is not null or em_meta_id <> '-2')
GROUP BY event_date
/*
event_date	(No column name)
2016-06-01	297427
2016-05-31	142665
*/

-- so many. Boundary_id is related to how partition function and scheme is defined. Doesn't mean the table
-- actually have all the partition in place
SELECT prng.boundary_id
FROM UORL_IP.sys.TABLES t WITH (NOLOCK)
JOIN UORL_IP.sys.indexes i WITH (NOLOCK) ON t.object_id = i.object_id
JOIN UORL_IP.sys.partition_schemes ps WITH (NOLOCK) ON i.data_space_id = ps.data_space_id
JOIN UORL_IP.sys.partition_functions pf WITH (NOLOCK) ON ps.function_id = pf.function_id
INNER JOIN UORL_IP.sys.partition_range_values prng (NOLOCK)	ON prng.function_id=ps.function_id
WHERE t.name = 'EVS_ONLINE_MENG_BK_20170413'


DROP TABLE  UORL_IP..EVS_ONLINE_MENG_BK_20170413

----select into
SELECT * INTO UORL_IP..EVS_ONLINE_MENG_BK_20170413
FROM UORL_IP..EVS_ONLINE
WHERE event_date between '2016-05-31' and '2016-06-01'
--32181995
USE UORL_IP


--EVS_ONLINE doesn't have PK and constraint

---- add column index
--CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_EVS_ONLINE] ON UORL_IP..EVS_ONLINE_MENG_BK_20170413 WITH (DROP_EXISTING = OFF, MAXDOP = 4); 


--create partition
--use exisitng partion_fn and partion_schema
SELECT ps.*, pf.*
		FROM UORL_IP.sys.TABLES t with (nolock)
		JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
		JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
		JOIN UORL_IP.sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id
		where t.name = 'EVS_ONLINE'
--ps_EVS_ONLINE_OFFLINE_2 --ps
--pfn_EVS_ONLINE_OFFLINE_2 --pfn

-------------------------------------------------------------------------------------------------
---- woops need to drop exisiting column store index first
--DROP INDEX CCSI_EVS_ONLINE ON UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]  

-- 1. recreate the index with partition
CREATE CLUSTERED INDEX CCSI_EVS_ONLINE ON UORL_IP.[PCLC0\mechen].[EVS_ONLINE_MENG_BK_20170413]  ([event_date])  
--WITH(DROP_EXISTING = ON) -- if not dropped before this
ON ps_EVS_ONLINE_OFFLINE_2([event_date]) 

SELECT ps.*, pf.*
		FROM UORL_IP.sys.TABLES t with (nolock)
		JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
		JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
		JOIN UORL_IP.sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id
		where t.name = 'EVS_ONLINE_MENG_BK_20170413'

--2. recreate the column store index
CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_EVS_ONLINE]
 ON UORL_IP..EVS_ONLINE_MENG_BK_20170413 WITH (DROP_EXISTING = ON, MAXDOP = 4); 

 -- partition is stilll there after columnstore index rebuild
 SELECT ps.*, pf.*
		FROM UORL_IP.sys.TABLES t with (nolock)
		JOIN UORL_IP.sys.indexes i with (nolock) ON t.object_id = i.object_id
		JOIN UORL_IP.sys.partition_schemes ps with (nolock) ON i.data_space_id = ps.data_space_id
		JOIN UORL_IP.sys.partition_functions pf with (nolock) ON ps.function_id = pf.function_id
		where t.name = 'EVS_ONLINE_MENG_BK_20170413'

---EVS_ONLINE_MENG_BK_20170413 table ready for testing
