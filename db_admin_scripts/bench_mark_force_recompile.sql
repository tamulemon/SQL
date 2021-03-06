SET STATISTICS TIME ON

SELECT * FROM [dbo].[tb_dedup_DTCLastTouchVisits]

OPTION (RECOMPILE)



-------------------------------
-- if the 2 UDF(parsing functions) were not set to schema-binding 
-- query will not return after 2.5 min. Had to kill it.
-- even with schema-binding, UDF become deterministic, still takes 9 sec

SET STATISTICS TIME ON

--SET SHOWPLAN_TEXT  ON 
--GO

SELECT * FROM [dbo].[dedup_DTCLastTouchVisits]
OPTION (RECOMPILE)


SET STATISTICS TIME OFF
GO
--SET SHOWPLAN_TEXT  OFF
--GO
-- an view performs much worse then a table when UDF is called

/*
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 3 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 0 ms, elapsed time = 1 ms.

(1572 row(s) affected)

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 5 ms.

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.
SQL Server parse and compile time: 
   CPU time = 87 ms, elapsed time = 87 ms.

(1572 row(s) affected)

 SQL Server Execution Times:
   CPU time = 63 ms,  elapsed time = 9271 ms.

*/

SELECT * 
FROM sys.dm_exec_requests


select *
from [dbo].[DTCVisits_TotalVisits_Customer]

EXEC sp_helptext  '[dbo].[fn_get_business_line]'