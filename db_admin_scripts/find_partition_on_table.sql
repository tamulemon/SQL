SELECT prv.*
FROM sys.tables t
inner join sys.indexes i
on t.object_id = i.object_id
INNER JOIN sys.partition_schemes ps
on i.data_space_id = ps.data_space_id
INNER JOIN sys.partition_functions pf
on ps.function_id = pf.function_id
INNER JOIN sys.partition_range_values prv
on ps.function_id = prv.function_id
where t.name = 'PRST_STG_UO_GATE_SALE'
-- value is the file_id from UORL_META..data_file table

SELECT i.*
FROM sys.tables t
inner join sys.indexes i
on t.object_id = i.object_id
INNER JOIN sys.partition_schemes ps
on i.data_space_id = ps.data_space_id
where t.name = 'PRST_STG_UO_GATE_SALE'
-- 2 indexes

SELECT ic.*
FROM SYS.index_columns ic
INNER JOIN sys.tables t
ON ic.object_id = t.object_id
where t.name = 'PRST_STG_UO_GATE_SALE'
