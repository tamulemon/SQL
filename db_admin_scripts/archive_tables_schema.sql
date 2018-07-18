-- create schema
CREATE SCHEMA [test_archive_schema]

-- move table between schemas
ALTER SCHEMA [test_archive_schema] 
    TRANSFER [dbo].[oper_bg_level_agg_daily]


-- doesn't work because default schema is [dbo], 
SELECT *
FROM [oper_bg_level_agg_daily]