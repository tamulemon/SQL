USE UORL_IP

SELECT COUNT(DISTInCT event_date)
FROM UORL_IP..evs_online

-- partition scheme name and partition function
SELECT t.name, ps.name, pf.name
FROM sys.tables t
JOIN sys.indexes i
on t.object_id = i.object_id
JOIN sys.partition_schemes ps
ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf
on ps.function_id = pf.function_id
--WHERE t.name = 'evs_online'


-- all tables have patitions
select distinct(t.name)
from sys.partitions p
inner join sys.tables t
on p.object_id = t.object_id
where p.partition_number <> 1


-- what are all the partitions of a table
select t.name, p.*
from sys.partitions p
inner join sys.tables t
on p.object_id = t.object_id
where p.partition_number <> 1
and t.name = 'evs_online'