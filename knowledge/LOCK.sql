SELECT * FROM sys.dm_tran_locks
  WHERE resource_database_id = DB_ID()
  AND resource_associated_entity_id = OBJECT_ID(N'test_meng');

-- no prevelidge 
SELECT *
FROM sys.dm_tran_locks AS l
  JOIN sys.dm_os_waiting_tasks AS wt 
  ON wt.resource_address = l.lock_owner_address

--VIEW SERVER STATE permission was denied on object 'server', database 'master'.
SELECT
t1.resource_type,
t1.resource_database_id,
t1.resource_associated_entity_id,
t1.request_mode,
t1.request_session_id,
t2.blocking_session_id,
o1.name 'object name',
o1.type_desc 'object descr',
p1.partition_id 'partition id',
p1.rows 'partition/page rows',
a1.type_desc 'index descr',
a1.container_id 'index/page container_id'
FROM sys.dm_tran_locks as t1
INNER JOIN sys.dm_os_waiting_tasks as t2
    ON t1.lock_owner_address = t2.resource_address
LEFT OUTER JOIN sys.objects o1 on o1.object_id = t1.resource_associated_entity_id
LEFT OUTER JOIN sys.partitions p1 on p1.hobt_id = t1.resource_associated_entity_id
LEFT OUTER JOIN sys.allocation_units a1 on a1.allocation_unit_id = t1.resource_associated_entity_id


----------------
-- historical record. each session whener a lock is requested, a record is created here
SELECT *
FROM sys.dm_tran_locks

/*
	request mode:
	S: shared lock. A record can not be UPDATE/DELETE when SELECT
	U: update lock. record Can be UPDATE
	X: excludisve. INSERT/UPDATE/DELETE, multiple updates can not be made the same time
	IX: intent exclusive
	BU: bulk update the TABLOCK is implemented. locks allow multiple threads to bulk load data concurrently into the same table while preventing other processes that are not bulk loading data from accessing the table.
	Sch-S:schema stability 
	Sch-M: schema modification locks during a DDL operation, such as adding a column or dropping a table.  prevents concurrent access to the table
*/

--deprecated
SELECT *
FROM sys.syslockinfo

 -- not supported in azure
exec sp_lock
