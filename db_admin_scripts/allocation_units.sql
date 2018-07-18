USE UORL_IP
Go

select *
from sys.allocation_units
where type <>1
/*Type of allocation unit:

0 = Dropped

1 = In-row data (all data types, except LOB data types)

2 = Large object (LOB) data (text, ntext, image, xml, large value types, and CLR user-defined types)

3 = Row-overflow data
*/




SELECT *
FROM sys.filegroups


-- index column and data type
select	
c.name,
i.DATA_TYPE
	from  sys.index_columns  ic  with (nolock)
	join  sys.columns         c  with (nolock)
			on(c.object_id = ic.object_id 
			and c.column_id = ic.column_id)  
	join INFORMATION_SCHEMA.COLUMNS i  with (nolock)
	on c.object_id =  object_id(i.TABLE_NAME)
	and c.name = i.COLUMN_NAME
	where ic.partition_ordinal > 0 
	and object_name(ic.object_id)  = 'EVS_ONLINE'

SELECT *
FROM 
sys.computed_columns 
WHERE object_name(object_id)  = 'EVS_ONLINE'