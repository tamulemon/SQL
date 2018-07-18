-- =========================================================
-- Create Scalar Function template for Windows Azure SQL Database
-- =========================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID (N'dbo.fn_exclude_last_part', N'FN') IS NOT NULL
    DROP FUNCTION fn_exclude_last_part;
GO

-- =============================================
-- Author:		<mchen>
-- Create date: <2016-10-12>
-- Description:	<return text,getting the right most part of a '_' deliminated string.
-- =============================================
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
CREATE  FUNCTION fn_exclude_last_part(@inputString varchar(400))
RETURNS nvarchar (400)
WITH SCHEMABINDING

AS
BEGIN
	IF CHARINDEX('_' , @inputString) = 0 
		OR LEN(@inputString) = 0
	RETURN NULL
	
	ELSE
		DECLARE @returnString varchar (100)
		SET @returnString = REVERSE(RIGHT(REVERSE(@inputString), LEN(@inputString) - CHARINDEX('_',REVERSE(@inputString))))
		RETURN @returnString
END
GO
 
SET QUOTED_IDENTIFIER OFF
GO
 
SET ANSI_NULLS ON
GO


---- Test Function

--DECLARE @inputString nvarchar (4000)
--SET @inputString = 'TMO_Postpaid_All_Prospect_Pay&Review_LastTouchVisits'

--PRINT dbo.fn_exclude_last_part(@inputString)
