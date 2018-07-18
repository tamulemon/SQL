-- this is safer, because we don't know whether it is a schaler function (FN) or table function (FT)
IF
(SELECT name 
FROM [sys].[all_objects]
WHERE name = 'fn_parse_siteCat_report'
AND type_desc like '%FUNCTION%') IS NOT NULL

DROP FUNCTION fn_parse_siteCat_report
GO
----------------------------------------------------------------------------

 
/****************************************************************************
 function will 
	- parse out a string based on a user defined @deliminater
	- intermediately returns a table with each parsed out position in row
	- finally pivot and return the first 5 position in column format
 Auther: mchen 10/10/2016

*******************************************************************************/ 

CREATE  FUNCTION dbo.fn_parse_siteCat_report(@text varchar(300), @deliminater nvarchar(2))
RETURNS @parse_positions TABLE 
(    
	--input_string nvarchar(300),
	[Site] nvarchar(50),
	[Business Line] nvarchar(50),
	[Product] nvarchar(50),
	[Audience Type] nvarchar(50),
	[Funnel Step] nvarchar(50),
	[Device Type] nvarchar(50)
)
AS 
BEGIN

DECLARE @index int
DECLARE @position int
DECLARE @original_input nvarchar(300)

DECLARE @intermediate_parse TABLE
(
	position int,
	parsed nvarchar(50)
)

SET @index = -1 
SET @position = 1
SET @original_input = @text
 
-- parsing out 8 positions
WHILE (LEN(@text) > 0) 
  BEGIN 
    SET @index = CHARINDEX(@deliminater , @text)  
    IF (@index = 0)
	 BEGIN
		 INSERT INTO @intermediate_parse VALUES (@position, @text)
		 SET @text = NULL
	 END	 

    IF (@index > 1)  
      BEGIN  
        INSERT INTO @intermediate_parse VALUES (@position, LEFT(@text, @index - 1))
		SET @position = @position + 1  
		SET @text = RIGHT(@text, (LEN(@text) - @index))
      END
  END

	INSERT INTO @parse_positions
	(
		[Site], [Business Line], [Product], [Audience Type], [Funnel Step], [Device Type]
	)
	SELECT  *
			FROM 
			(
				SELECT 
				position,
				parsed
				FROM  @intermediate_parse
			) d
			PIVOT
			(
			  max(parsed) -- aggregation function is needed even for string
			  FOR position IN ([1],[2], [3],[4],[5], [6]) -- insert the first 6 positions
			) AS piv
	--UPDATE @parse_positions
	--SET input_string = @original_input

  RETURN
END
GO


--================
-- example

--DECLARE @text varchar (400)
--DECLARE @deliminater varchar(20)
--SET @text  = 'TMO_Prepaid_Total_Customer_Order Confirmation_Mobile'
--SET @deliminater = '_'
--SELECT *
--FROM dbo.fn_parse_siteCat_report(@text, @deliminater)