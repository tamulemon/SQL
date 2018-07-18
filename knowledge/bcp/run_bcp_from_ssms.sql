--https://www.simple-talk.com/sql/database-administration/working-with-the-bcp-command-line-utility/

SELECT @@SERVERNAME


--first need to enable the sp
EXEC sp_configure 'show advanced options', 1
GO
-- To update the currently configured value for advanced options.
RECONFIGURE
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1
GO
-- To update the currently configured value for this feature.
RECONFIGURE
GO

-- Notes: output file will automatically overwrite if the file exists

-- example : local db using a trusted connection. will use windows auth, execute from SSMS using SP
-- if omitted, will be promted to specify data type for each field
-- if export file is specified as .txt, will automatically save a formatting file in the end
exec master.dbo.xp_cmdshell 'bcp [Meng_test].[dbo].[DTCVisits_TotalVisits_Customer] out C:\Users\mchen\Documents\testBCP.dat -S mchen-102615 -T -c'


--example: remote server, SQL auth, using cmd
-- supposedly password can be support by -P but never works for me from SSMS or cmd
exec master.dbo.xp_cmdshell 'bcp OC_Win10.dbo.dim_OS out C:\Users\mchen\Documents\testBCP.dat -U pmc-mchen -S ogonyzmvs0.database.windows.net -P 4Lky4O*BQb^@ohSg'

-- this works, but doesn't give header
bcp OC_Win10.dbo.dim_OS out C:\Users\mchen\Documents\testBCP.tsv -c -U pmc-mchen -S ogonyzmvs0.database.windows.net 
-- dat all hex code
-- csv
-- wait for the prompt and past in password
4Lky4O*BQb^@ohSg

/*
-n (native format): The bcp utility retains the database native data types when bulk copying the data to the data file. Microsoft recommends that you use this format to bulk copy data between instances of SQL Server. However, you should use this format option only when the data file should not support extended or double-byte character set (DBCS) characters.
-N (Unicode native format): The bcp utility uses the database native data types for non-character data and uses Unicode for character data for the bulk copy operation. Microsoft recommends that you use this format to bulk copy data between SQL Server instances when the data file should support extended or DBCS characters.
-w (Unicode character format): The bcp utility uses Unicode characters when bulk copying data to the data file. This format option is intended for bulk copying data between SQL Server instances. Note, however, that the Unicode native format (-N) offers a higher performance alternative.
-c (character format): The bcp utility uses character data for the bulk copy operation. Microsoft recommends that you use this format to bulk copy data between SQL Server and other applications, such as Microsoft Excel.
*/


-- bcp AdventureWorks2008.HumanResources.Employee out C:\Data\EmployeeData_c.dat -c -t, -S localhost\SqlSrv2008 -T
--, the command includes the -t argument following by a comma, so each field in the data file will be terminated with a comma, rather than a tab

--bcp AdventureWorks2008.HumanResources.Employee out C:\Data\EmployeeData_c.dat -c -S localhost\SqlSrv2008 -T -F 101 -L 200
--When your bcp command retrieves data from a table or view, it copies all the data. However, you have some control over which rows are copied to the data file. In a bcp command, you can use the -F argument to specify the first row to be retrieved and the -L argument to specify the last row. In the following example, the first row I retrieve is 101 and the last row is 200:

bcp OC_Win10.dbo.dim_OS out C:\Users\mchen\Documents\testBCP.tsv -c -U pmc-mchen -S ogonyzmvs0.database.windows.net 
-- dat all hex code
-- csv
-- wait for the prompt and past in password
4Lky4O*BQb^@ohSg


bcp C:\Users\mchen\Documents\testBCP.tsv IN OC_Win10.dbo.dim_OS_test -U pmc-mchen -S ogonyzmvs0.database.windows.net 

-- not supported in Azure
BULK INSERT dim_OS_test
        FROM 'C:\Users\mchen\Documents\testBCP.tsv'
            WITH
    (
                FIELDTERMINATOR = '\t',
                ROWTERMINATOR = '\n'
    )
GO

/*Msg 141, Level 15, State 1, Line 58
A SELECT statement that assigns a value to a variable must not be combined with data-retrieval operations.
Msg 10734, Level 15, State 1, Line 66
Variable assignment is not allowed in a statement containing a top level UNION, INTERSECT or EXCEPT operator.
*/
DECLARE @col varchar(500)
SET @col = ''
SELECT @col +=  c.name + ','
		FROM sys.columns AS c
		INNER JOIN sys.tables AS t
		ON c.object_id = t.object_id
		WHERE t.name = 'dim_OS'
UNION 
SELECT top 100 *
FROM dim_OS




-------------------------------------------------------------------------------------------------------------------------------
SELECT c.name 
FROM sys.columns AS c
INNER JOIN sys.tables AS t
ON c.object_id = t.object_id
WHERE t.name = 'dim_OS'

SELECT 'ID', 'OS_dax', 'OS_clean', 'Os_grouped', 'isCompetingOS'
UNION 
SELECT *
FROM dim_OS

bcp  "SELECT 'ID', 'OS_dax', 'OS_clean', 'Os_grouped', 'isCompetingOS' UNION SELECT * FROM dim_OS" queryout  C:\Users\mchen\Documents\testBCP.tsv -c -U pmc-mchen -S ogonyzmvs0.database.windows.net 