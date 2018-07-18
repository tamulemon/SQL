USE [PerfDB];
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExecuteDatabasesCommand]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[ExecuteDatabasesCommand];
GO

	
CREATE PROCEDURE ExecuteDatabasesCommand
(
	@cmd nvarchar(4000)
)
/*
	01/08/2007 Yaniv Etrogi   
	http://www.sqlserverutilities.com	
*/

AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  


--EXEC PerfDB.dbo.ExecuteDatabasesCommand @cmd = N'[sp_Reindex];';


DECLARE @Data TABLE ([name] sysname);
INSERT @Data ([name])
SELECT [name] FROM sys.databases 
WHERE [state] = 0			/* online */ 
AND database_id > 4		/* exclude system databases */


DECLARE cur CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
SELECT [name] FROM @Data ORDER BY [name];

DECLARE @Database sysname, @Command nvarchar(4000);

OPEN cur;
SET NOCOUNT ON;

FETCH NEXT FROM cur INTO @Database;
WHILE @@FETCH_STATUS = 0 
BEGIN;
	SELECT @Command = 'EXEC [' + @Database + '].[dbo].' + @cmd;
	--PRINT @Command
	EXEC (@Command);

	FETCH NEXT FROM cur INTO @Database;
END; 
CLOSE cur; DEALLOCATE cur;
GO