
SELECT TOP 100 *
FROM [dbo].[timeSeries_agg_allAttributes] 
WHERE DATEPART (year, userStartMonth) BETWEEN 2013 AND 2015  
AND DATEPART (month, userStartMonth) BETWEEN 5 AND 10

SELECT COLUMN_NAME
	FROM [INFORMATION_SCHEMA].[COLUMNS]
	ORDER BY COLUMN_NAME

/*Declare a local table variable named @statusColumn, that saves all column names based on certain criteria
 and later query based. Because this is a local variable, the code need to be run everytime with the selection statement */

DECLARE  @statusColumns TABLE (Col VARCHAR(100))
INSERT INTO @statusColumns 
	SELECT COLUMN_NAME
	FROM [INFORMATION_SCHEMA].[COLUMNS]
	WHERE COLUMN_NAME LIKE 'has%'

DECLARE @output VARCHAR(1000)
SET @output = N'SELECT ' + @statusColumns + ' FROM [dbo].[timeSeries_agg_officeWrite]'
Exec (@output)

--SELECT * FROM @statusColumns

--CREATE PROCEDURE get_column_names @statusColumns READONLY AS
--	SELECT COLUMN_NAME
--	FROM [INFORMATION_SCHEMA].[COLUMNS]
--	WHERE COLUMN_NAME LIKE 'has%'






--select based on a criteria on COLUMN_NAME column
SELECT COLUMN_NAME
FROM [INFORMATION_SCHEMA].[COLUMNS]
WHERE COLUMN_NAME LIKE 'has%'

/*
- @sql: dynamic SQL command. 
- @sql builds a unicode string that essentially concatenates all column names into one statement.
- An nvarchar column can store any Unicode data. A varchar column is restricted to 8-bit.
  Doesn't matter in this case but @sql only takes nvarchar variable type.
- sp_executesql executes the string containing a Transact-SQL statement or batch. 
*/
DECLARE @sql nvarchar(max)
DECLARE @table_name varchar(100) -- size can be changed
DEClARE @column_name_criteria varchar(100) -- size can be changed 

/*These are some sample parameters. Replace with your parameters here*/
SET @table_name = '[dbo].[timeSeries_agg_linkToSd]'
SET @column_name_criteria = 'hasLinkToSD_2015'


SET @sql = 'SELECT ' -- start building the string
SELECT @sql = @sql + '[' + column_name + '],'
FROM [INFORMATION_SCHEMA].[COLUMNS]
WHERE column_name LIKE @column_name_criteria + '%'
SET @sql = left(@sql, LEN(@sql)-1) -- this is to offset comma
SET @sql = @sql + 'FROM' + @table_name 
EXEC sp_executesql @sql
-- this will actually print out the concated sql code
PRINT @sql


SELECT TOP 10 *
FROM [dbo].[timeSeries_agg_linkToSd]