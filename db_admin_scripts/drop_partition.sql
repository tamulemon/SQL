IF EXISTS
(SELECT *
FROM sys.partition_schemes
where name = '<partition_scheme, nvarchar(200), ps_stg_UO_PARTNER_DISPLAY_COST>')
BEGIN
	DROP PARTITION SCHEME <partition_scheme, nvarchar(200), ps_stg_UO_PARTNER_DISPLAY_COST>
END

IF EXISTS
(
	SELECT *
	FROM sys.partition_functions
	where name = '<partition_func, nvarchar(200), pfn_stg_UO_PARTNER_DISPLAY_COST>'
)
BEGIN
	DROP PARTITION FUNCTIOn <partition_func, nvarchar(200), pfn_stg_UO_PARTNER_DISPLAY_COST>
END