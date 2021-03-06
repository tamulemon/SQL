/****** Script for SelectTopNRows command from SSMS  ******/
SELECT t.*
FROM [sys].[tables] AS t
INNER JOIN [sys].[partitions] AS p
ON t.object_id = p.object_id
WHERE t.name = 'mapping_market_area_2015-10-15'


SELECT COUNT(*)
FROM firstAddTable_12_04_2015

SELECT count(*), count(distinct container_id)
FROM  sys.allocation_units

SELECT container_id, count(container_id)
FROM sys.allocation_units
GROUP BY container_id
HAVING COUNT(container_id) > 1
