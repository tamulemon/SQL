SELECT @@ServerName AS server
 ,NAME AS dbname
 ,COUNT(STATUS) AS number_of_connections
 ,GETDATE() AS timestamp
FROM sys.databases sd
LEFT JOIN sysprocesses sp ON sd.database_id = sp.dbid
WHERE database_id NOT BETWEEN 1 AND 4
GROUP BY NAME


SELECT @@ServerName AS SERVER
 ,NAME
 ,login_time
 ,last_batch
 ,getdate() AS DATE
 ,STATUS
 ,hostname
 ,program_name
 ,nt_username
 ,loginame
FROM sys.databases d
LEFT JOIN sysprocesses sp ON d.database_id = sp.dbid
WHERE database_id NOT BETWEEN 0
  AND 4
 AND loginame IS NOT NULL

 SELECT *
 FROM sys.dm_db_index_usage_stats

SELECT
last_user_seek = MIN(last_user_seek),
last_user_scan = MIN(last_user_scan),
last_user_lookup = MIN(last_user_lookup),
last_user_update = MIN(last_user_update)
FROM
sys.dm_db_index_usage_stats
WHERE
[database_id] = DB_ID()

