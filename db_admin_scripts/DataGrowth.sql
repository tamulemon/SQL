USE PerfDB;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DataGrowth]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DataGrowth];
GO


CREATE PROCEDURE DataGrowth   
(
	 @StartDate datetime = NULL
	,@EndDate datetime = NULL
	,@Delta_MB int = 200  
)

/*
	01/08/2007 Yaniv Etrogi   
	http://www.sqlserverutilities.com	
*/

AS   
SET NOCOUNT ON;  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  


/*
DECLARE @StartDate datetime,@EndDate datetime ,@Delta_MB int; 
SELECT  @StartDate = '20101021',@EndDate = '20101028',@Delta_MB = 1500;
*/


-- Set the start date to 30 days back if no value provided
IF @StartDate IS NULL SELECT @StartDate = DATEADD(DAY, -30, CURRENT_TIMESTAMP); 

-- Set the EndDate to the current time if not value provided
IF @EndDate IS NULL SELECT @EndDate = CURRENT_TIMESTAMP;

  
-- Get all data for the requested time period
SELECT  
			RowId 
     ,[Database]    
		 ,[Schema]  
		 ,[Table]  
     ,[row_count]    
     ,[reserved_MB]    
     ,[data_MB]    
     ,[index_size_MB]    
     ,[unused_MB]
INTO  #Data
FROM  dbo.TableSizeHistory
WHERE InsertTime BETWEEN @StartDate AND @EndDate  
			AND [row_count] <> 0    
      AND [data_MB] <> 0   
GROUP BY [RowId], [Database], [Table], [Schema], [row_count], [reserved_MB], [data_MB], [index_size_MB], [unused_MB];
  
  
-- get the max Id of each table
SELECT 
			[RowId]
     ,[Database]    
		 ,[Schema]  
		 ,[Table]  
INTO #T1
FROM #Data 
WHERE RowId IN (SELECT MAX(RowId) FROM #Data AS D 
		WHERE D.[Database] = #Data.[Database] AND D.[Schema] = #Data.[Schema] AND D.[Table] = #Data.[Table])
GROUP BY [RowId], [Database], [Schema], [Table];  


-- get the min Id of each table
SELECT 
			[RowId]
     ,[Database]    
		 ,[Schema]  
		 ,[Table]  
INTO #T2
FROM #Data 
WHERE RowId IN (SELECT MIN(RowId) FROM #Data AS D 
	WHERE D.[Database] = #Data.[Database] AND D.[Schema] = #Data.[Schema] AND D.[Table] = #Data.[Table])
GROUP BY [RowId], [Database], [Schema], [Table];


-- Get the most recent data per each table
SELECT 
	  [Database]    
	 ,[Schema]
	 ,[Table]    
	 ,[row_count]
 	 ,reserved_MB 
	 ,data_MB 
	 ,index_size_MB
	 ,unused_MB 
INTO #Max
FROM #Data
WHERE RowId IN (SELECT RowId FROM #T1);


-- Get the oldest data per each table
SELECT 
	  [Database]    
	 ,[Schema]
	 ,[Table]    
	 ,[row_count]
 	 ,reserved_MB 
	 ,data_MB 
	 ,index_size_MB 
	 ,unused_MB 
INTO #Min
FROM #Data
WHERE RowId IN (SELECT RowId FROM #T2);


-- Final output, get the delta and return to the client
SELECT DISTINCT 
	  #Data.[Database]    
	 ,#Data.[Schema]
	 ,#Data.[Table]    
 	 ,#Max.row_count - #Min.row_count					AS Delta_row_count
 	 ,#Max.reserved_MB - #Min.reserved_MB			AS Delta_reserved_MB 
	 ,#Max.data_MB - #Min.data_MB							AS Delta_data_MB 
	 ,#Max.index_size_MB - #Min.index_size_MB AS Delta_index_size_MB 
	 ,#Max.unused_MB - #Min.unused_MB					AS Delta_unused_MB 
FROM #Data
INNER JOIN #Max ON #Max.[Database] = #Data.[Database] AND #Max.[Schema] = #Data.[Schema] AND #Max.[Table] = #Data.[Table]
INNER JOIN #Min ON #Min.[Database] = #Data.[Database] AND #Min.[Schema] = #Data.[Schema] AND #Min.[Table] = #Data.[Table]
WHERE  #Max.reserved_MB - #Min.reserved_MB > @Delta_MB    
ORDER BY Delta_reserved_MB DESC, #Data.[Database], #Data.[Table], #Data.[Schema];
GO