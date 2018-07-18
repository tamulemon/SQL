exec sp_who2

USE UORL_IP

SELECT  *
FROM sys.dm_exec_requests

Select total_elapsed_time,
 * from sys.dm_exec_sessions where session_id= 77

SELECT status,* FROM sys.sysprocesses


 SELECT SUM(signal_wait_time_ms) * 100 / SUM(wait_time_ms) AS
       cpu_pressure_percentage,
       SUM(signal_wait_time_ms)                           AS cpu_wait,
       SUM(wait_time_ms - signal_wait_time_ms)            AS resource_wait,
       SUM(wait_time_ms)                                  AS total_wait_time
FROM   sys.dm_os_wait_stats

 

SELECT scheduler_id,
       cpu_id,
       current_tasks_count,
       runnable_tasks_count,
       current_workers_count,
       active_workers_count,
       work_queue_count
FROM   sys.dm_os_schedulers
WHERE  scheduler_id < 255; 