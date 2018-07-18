-- =========================================================
-- Create Scalar Function template for Windows Azure SQL Database
-- =========================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID (N'dbo.fn_parse_between', N'FN') IS NOT NULL
    DROP FUNCTION fn_parse_between;
GO

-- =============================================
-- Author:		<mchen>
-- Create date: <2016-01-29>
-- Description:	<takes 2 parameters. The left boarder and the right boarder that the string will be parsed on. 
-- will return the substring inbetween the first occurence of the 2 boarders. return Null is not both characters are found>
-- =============================================
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
CREATE  FUNCTION fn_parse_between(@inputString varchar(4000), @leftBorder nvarchar(20), @rightBorder nvarchar(20))
RETURNS nvarchar (4000)

AS
BEGIN
	IF CHARINDEX(@leftBorder , @inputString) = 0 
		OR CHARINDEX(@rightBorder , @inputString) = 0 
		OR LEN(@inputString) = 0
	RETURN NULL
	
	ELSE
		DECLARE @index1 int
		DECLARE @index2 int
		DECLARE @subString nvarchar (4000)
	

		SET @index1 = CHARINDEX(@leftBorder , @inputString)  

		--SET @subStringAfterLeftBorder = SUBSTRING(@inputString, @index1 + LEN(@leftBorder), len(@inputString))
		SET @index2 = CHARINDEX(@rightBorder, @inputString, @index1 + LEN(@leftBorder))

		IF @index2 < @index1
			RETURN NULL
		ELSE
			SET @subString = SUBSTRING(@inputString, @index1 + LEN(@leftBorder), @index2 - @index1 - LEN(@leftBorder))
			RETURN @subString
		
END
GO
 
SET QUOTED_IDENTIFIER OFF
GO
 
SET ANSI_NULLS ON
GO


-- Test FUnction

--DECLARE @inputString nvarchar (4000)
--DECLARE @leftBorder nvarchar(20)
--DECLARE @rightBorder nvarchar(20)

---- za.microsoftstore.com
----SET @inputString = 'http://za.microsoftstore.com/products/xbox-live-gold-membership-12-months?icid=Homepage_S_hero_xboxgold_211215&variant=8311158273'

---- NULL
--SET @inputString = './AccountInformation.aspx'

--SET @leftBorder = '//'
--SET @rightBorder = '/'

--PRINT dbo.fn_parse_between(@inputString, @leftBorder, @rightBorder)

---- a table test
--SELECT targetUrl_name, dbo.fn_parse_between(targetUrl_name, '//', '/')
--FROM dim_targetUrl