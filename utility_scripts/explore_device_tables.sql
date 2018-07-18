-- need to specify column names for views
SELECT [TABLE_CATALOG], [TABLE_SCHEMA], [TABLE_NAME], [TABLE_TYPE]
FROM [INFORMATION_SCHEMA].[TABLES]

SELECT TOP 10 *
FROM [INFORMATION_SCHEMA].[COLUMNS]
WHERE [COLUMN_NAME] LIKE '%channel%' 

SELECT DISTINCT bg_site
FROM [dbo].[Mapping_BG_Site_2015-10-15]
-- 8 values
/*hololens
health
xbox
hardware
surface
microsoft store
band*/

-- bg_site table
SELECT *
FROM [INFORMATION_SCHEMA].[TABLES]
WHERE TABLE_NAME = 'mapping_BG_Site_2015-10-15'

-- get all the column names in the mapping bg_site table
SELECT COLUMN_NAME
FROM [INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_NAME = 'mapping_BG_Site_2015-10-15'

-- get primary key of the bg_site table
--SELECT *
--FROM [INFORMATION_SCHEMA].[KEY_COLUMN_USAGE]
--WHERE TABLE_NAME like 'Mapping%'
--WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
--AND TABLE_NAME = 'Mapping_BG_Site_2015-10-15' AND TABLE_SCHEMA = 'dbo'


SELECT TOP 10 *
FROM [Mapping_BG_Site_2015-10-15]

--sample 5 rows per bg_site value from bg_site table
-- Partition by + unique value that needs to be sampled on
-- order by + unique values that will seperate the rank. IN this case if group by enrich_url_pg_domain
-- the row num will > 3 because most of the enrich_url_pg_domain valuew are same. sampling stops when 3 unique enrich_url_pg_domain values are reached
SELECT bg_site, enrich_url_pg_domain, enrich_url_pg_uri_stem
FROM
	(
		SELECT bg_site, enrich_url_pg_domain, enrich_url_pg_uri_stem, RANK() OVER(PARTITION BY bg_site ORDER BY enrich_url_pg_uri_stem) num
		FROM [Mapping_BG_Site_2015-10-15]
	) temp
WHERE num <= 3