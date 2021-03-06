USE [roboButlerPOC]
GO
/****** Object:  User [mChen]    Script Date: 10/3/2016 1:15:02 PM ******/
CREATE USER [mChen] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [roboButlerCred]    Script Date: 10/3/2016 1:15:03 PM ******/
CREATE USER [roboButlerCred] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [mChen]
GO
ALTER ROLE [db_owner] ADD MEMBER [roboButlerCred]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_parse_between]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
CREATE  FUNCTION [dbo].[fn_parse_between](@inputString varchar(4000), @leftBorder nvarchar(20), @rightBorder nvarchar(20))
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
/****** Object:  UserDefinedFunction [dbo].[fn_get_business_line]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
CREATE  FUNCTION [dbo].[fn_get_business_line](@inputString varchar(400))
RETURNS nvarchar (400)
WITH SCHEMABINDING

AS
BEGIN
	IF CHARINDEX('_' , @inputString) = 0 
		OR LEN(@inputString) = 0
	RETURN NULL
	
	ELSE
		DECLARE @returnString varchar (100)
		SET @returnString = REVERSE(LEFT(REVERSE(@inputString), CHARINDEX('_',REVERSE(@inputString))-1))
		RETURN @returnString
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_funnel_step]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
 
CREATE  FUNCTION [dbo].[fn_get_funnel_step](@inputString varchar(400))
RETURNS nvarchar (400)
WITH SCHEMABINDING

AS
BEGIN
	IF CHARINDEX('_' , @inputString) = 0 
		OR LEN(@inputString) = 0
	RETURN NULL
	
	ELSE
		DECLARE @index int
		-- trim out 1st position
		SET @index = CHARINDEX('_', @inputString)
		SET @inputString = RIGHT(@inputString, LEN(@inputString) - @index)
		-- take the 1st position, which is the original 2nd position 
		SET @index = CHARINDEX('_', @inputString)
		SET @inputString = LEFT(@inputString, @index - 1)
		RETURN @inputString

END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_integerDivision]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_integerDivision](@nominator bigint, @denominator bigint)
RETURNS float with schemabinding
AS 
BEGIN
   RETURN 
	CASE @denominator
		WHEN 0 THEN NULL
		ELSE CAST(@nominator AS float)/CAST(@denominator AS float)
	END
END;

GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CartReview_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CartReview_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CartReview_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CartReview_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CartReview_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CartReview_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CartReview_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CartReview_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_Consideration_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_Consideration_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_Consideration_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_Consideration_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CustomerInfo_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CustomerInfo_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CustomerInfo_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CustomerInfo_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CustomerInfo_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CustomerInfo_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_CustomerInfo_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_CustomerInfo_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_MultiPageVisits_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_MultiPageVisits_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_MultiPageVisits_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_MultiPageVisits_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_OrderConfirmation_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_OrderConfirmation_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_OrderConfirmation_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_OrderConfirmation_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_OrderConfirmation_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_OrderConfirmation_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_OrderConfirmation_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_OrderConfirmation_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_Pay&Review_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_Pay&Review_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_Pay&Review_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_Pay&Review_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_Pay&Review_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_Pay&Review_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_Pay&Review_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_Pay&Review_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_TotalVisits_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_TotalVisits_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCLastTouchVisits_TotalVisits_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCLastTouchVisits_TotalVisits_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Last_Touch_Marketing_Channel] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[staging_DTCLastTouchVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE VIEW [dbo].[staging_DTCLastTouchVisits] AS SELECT * FROM ((SELECT *, 'DTCLastTouchVisits_CartReview_Customer' AS table_name 
		FROM [DTCLastTouchVisits_CartReview_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CartReview_Postpaid' AS table_name 
		FROM [DTCLastTouchVisits_CartReview_Postpaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CartReview_Prepaid' AS table_name 
		FROM [DTCLastTouchVisits_CartReview_Prepaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CartReview_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_CartReview_Prospect]) UNION ALL (SELECT *, 'DTCLastTouchVisits_Consideration_Customer' AS table_name 
		FROM [DTCLastTouchVisits_Consideration_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_Consideration_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_Consideration_Prospect]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CustomerInfo_Customer' AS table_name 
		FROM [DTCLastTouchVisits_CustomerInfo_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CustomerInfo_Postpaid' AS table_name 
		FROM [DTCLastTouchVisits_CustomerInfo_Postpaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CustomerInfo_Prepaid' AS table_name 
		FROM [DTCLastTouchVisits_CustomerInfo_Prepaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_CustomerInfo_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_CustomerInfo_Prospect]) UNION ALL (SELECT *, 'DTCLastTouchVisits_MultiPageVisits_Customer' AS table_name 
		FROM [DTCLastTouchVisits_MultiPageVisits_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_MultiPageVisits_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_MultiPageVisits_Prospect]) UNION ALL (SELECT *, 'DTCLastTouchVisits_OrderConfirmation_Customer' AS table_name 
		FROM [DTCLastTouchVisits_OrderConfirmation_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_OrderConfirmation_Postpaid' AS table_name 
		FROM [DTCLastTouchVisits_OrderConfirmation_Postpaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_OrderConfirmation_Prepaid' AS table_name 
		FROM [DTCLastTouchVisits_OrderConfirmation_Prepaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_OrderConfirmation_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_OrderConfirmation_Prospect]) UNION ALL (SELECT *, 'DTCLastTouchVisits_Pay&Review_Customer' AS table_name 
		FROM [DTCLastTouchVisits_Pay&Review_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_Pay&Review_Postpaid' AS table_name 
		FROM [DTCLastTouchVisits_Pay&Review_Postpaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_Pay&Review_Prepaid' AS table_name 
		FROM [DTCLastTouchVisits_Pay&Review_Prepaid]) UNION ALL (SELECT *, 'DTCLastTouchVisits_Pay&Review_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_Pay&Review_Prospect]) UNION ALL (SELECT *, 'DTCLastTouchVisits_TotalVisits_Customer' AS table_name 
		FROM [DTCLastTouchVisits_TotalVisits_Customer]) UNION ALL (SELECT *, 'DTCLastTouchVisits_TotalVisits_Prospect' AS table_name 
		FROM [DTCLastTouchVisits_TotalVisits_Prospect]) ) AS t
GO
/****** Object:  Table [dbo].[DTCVisits_CartReview_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CartReview_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CartReview_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CartReview_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CartReview_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CartReview_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CartReview_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CartReview_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_Consideration_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_Consideration_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_Consideration_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_Consideration_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CustomerInfo_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CustomerInfo_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CustomerInfo_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CustomerInfo_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CustomerInfo_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CustomerInfo_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_CustomerInfo_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_CustomerInfo_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_MultiPageVisits_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_MultiPageVisits_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_MultiPageVisits_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_MultiPageVisits_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_OrderConfirmation_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_OrderConfirmation_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_OrderConfirmation_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_OrderConfirmation_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_OrderConfirmation_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_OrderConfirmation_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_OrderConfirmation_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_OrderConfirmation_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_Pay&Review_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_Pay&Review_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_Pay&Review_Postpaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_Pay&Review_Postpaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_Pay&Review_Prepaid]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_Pay&Review_Prepaid](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_Pay&Review_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_Pay&Review_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_TotalVisits_Customer]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_TotalVisits_Customer](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DTCVisits_TotalVisits_Prospect]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DTCVisits_TotalVisits_Prospect](
	[Date] [datetime] NULL,
	[Time_Period] [varchar](max) NULL,
	[Segment] [varchar](max) NULL,
	[Visits] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[staging_DTCVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE VIEW [dbo].[staging_DTCVisits] AS SELECT * FROM ((SELECT *, 'DTCVisits_CartReview_Customer' AS table_name 
		FROM [DTCVisits_CartReview_Customer]) UNION ALL (SELECT *, 'DTCVisits_CartReview_Postpaid' AS table_name 
		FROM [DTCVisits_CartReview_Postpaid]) UNION ALL (SELECT *, 'DTCVisits_CartReview_Prepaid' AS table_name 
		FROM [DTCVisits_CartReview_Prepaid]) UNION ALL (SELECT *, 'DTCVisits_CartReview_Prospect' AS table_name 
		FROM [DTCVisits_CartReview_Prospect]) UNION ALL (SELECT *, 'DTCVisits_Consideration_Customer' AS table_name 
		FROM [DTCVisits_Consideration_Customer]) UNION ALL (SELECT *, 'DTCVisits_Consideration_Prospect' AS table_name 
		FROM [DTCVisits_Consideration_Prospect]) UNION ALL (SELECT *, 'DTCVisits_CustomerInfo_Customer' AS table_name 
		FROM [DTCVisits_CustomerInfo_Customer]) UNION ALL (SELECT *, 'DTCVisits_CustomerInfo_Postpaid' AS table_name 
		FROM [DTCVisits_CustomerInfo_Postpaid]) UNION ALL (SELECT *, 'DTCVisits_CustomerInfo_Prepaid' AS table_name 
		FROM [DTCVisits_CustomerInfo_Prepaid]) UNION ALL (SELECT *, 'DTCVisits_CustomerInfo_Prospect' AS table_name 
		FROM [DTCVisits_CustomerInfo_Prospect]) UNION ALL (SELECT *, 'DTCVisits_MultiPageVisits_Customer' AS table_name 
		FROM [DTCVisits_MultiPageVisits_Customer]) UNION ALL (SELECT *, 'DTCVisits_MultiPageVisits_Prospect' AS table_name 
		FROM [DTCVisits_MultiPageVisits_Prospect]) UNION ALL (SELECT *, 'DTCVisits_OrderConfirmation_Customer' AS table_name 
		FROM [DTCVisits_OrderConfirmation_Customer]) UNION ALL (SELECT *, 'DTCVisits_OrderConfirmation_Postpaid' AS table_name 
		FROM [DTCVisits_OrderConfirmation_Postpaid]) UNION ALL (SELECT *, 'DTCVisits_OrderConfirmation_Prepaid' AS table_name 
		FROM [DTCVisits_OrderConfirmation_Prepaid]) UNION ALL (SELECT *, 'DTCVisits_OrderConfirmation_Prospect' AS table_name 
		FROM [DTCVisits_OrderConfirmation_Prospect]) UNION ALL (SELECT *, 'DTCVisits_Pay&Review_Customer' AS table_name 
		FROM [DTCVisits_Pay&Review_Customer]) UNION ALL (SELECT *, 'DTCVisits_Pay&Review_Postpaid' AS table_name 
		FROM [DTCVisits_Pay&Review_Postpaid]) UNION ALL (SELECT *, 'DTCVisits_Pay&Review_Prepaid' AS table_name 
		FROM [DTCVisits_Pay&Review_Prepaid]) UNION ALL (SELECT *, 'DTCVisits_Pay&Review_Prospect' AS table_name 
		FROM [DTCVisits_Pay&Review_Prospect]) UNION ALL (SELECT *, 'DTCVisits_TotalVisits_Customer' AS table_name 
		FROM [DTCVisits_TotalVisits_Customer]) UNION ALL (SELECT *, 'DTCVisits_TotalVisits_Prospect' AS table_name 
		FROM [DTCVisits_TotalVisits_Prospect]) ) AS t
GO
/****** Object:  View [dbo].[dedup_DTCLastTouchVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[dedup_DTCLastTouchVisits]
AS
(
	SELECT	
		t1.date,	
		'daily' AS Granularity,
		t1.funnel_step,
		t1.last_touch_marketing_channel,
		t1.business_line, 
		t1.visits,
		CAST(ROUND(dbo.fn_integerDivision(t1.visits, t3.sum_channel_visits)* t2.total_visits, 0)AS BIGINT) AS visits_dedup
	FROM
	(
		SELECT 
				date,
				last_touch_marketing_channel,
				visits,
				dbo.fn_get_funnel_step([table_name]) AS funnel_step,
				dbo.fn_get_business_line([table_name])  AS business_line
		FROM [staging_DTCLastTouchVisits]
	)AS t1
	INNER JOIN
	(
		SELECT 
				date AS t2_date,
				visits AS total_visits,
				dbo.fn_get_funnel_step([table_name]) AS t2_funnel_step,
				dbo.fn_get_business_line([table_name]) AS t2_business_line
		FROM [staging_DTCVisits]
	) AS t2
	ON t1.date = t2.t2_date
	AND t1.funnel_step = t2.t2_funnel_step
	AND t1.business_line = t2.t2_business_line
	INNER JOIN
	(
		SELECT 
				date AS t3_date,
				SUM(visits) AS sum_channel_visits,
				dbo.fn_get_funnel_step([table_name]) AS t3_funnel_step,
				dbo.fn_get_business_line([table_name]) AS t3_business_line
		FROM [staging_DTCLastTouchVisits]
		GROUP BY 
			date,
			dbo.fn_get_funnel_step([table_name]),
			dbo.fn_get_business_line([table_name])
	) AS t3
	ON t1.date = t3.t3_date
	AND t1.funnel_step = t3.t3_funnel_step
	AND t1.business_line = t3.t3_business_line
)
GO
/****** Object:  Table [dbo].[tableau_LastTouchVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tableau_LastTouchVisits](
	[date] [date] NOT NULL,
	[granularity] [varchar](20) NOT NULL,
	[funnel_step] [varchar](100) NOT NULL,
	[last_touch_marketing_channel] [varchar](200) NOT NULL,
	[business_line] [varchar](100) NOT NULL,
	[upper_lower_funnel] [varchar](20) NULL,
	[channel_type] [varchar](100) NULL,
	[channel_group] [varchar](100) NULL,
	[visits] [bigint] NOT NULL,
	[visits_dedup] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[date] ASC,
	[granularity] ASC,
	[last_touch_marketing_channel] ASC,
	[funnel_step] ASC,
	[business_line] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[view_tableau_LastTouchVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[view_tableau_LastTouchVisits]
WITH SCHEMABINDING
AS
SELECT 
[date] AS [Date]
,CASE [granularity]
	WHEN 'daily' THEN 'Daily'
	ELSE [granularity] 
END
AS [Granularity]
,CASE [funnel_step] 
	WHEN 'TotalVisits' THEN 'Total Visits'
	WHEN 'Pay&Review' THEN 'Pay & Review'
	WHEN 'CartReview' THEN 'Cart Review'
	WHEN 'MultiPageVisits' THEN 'Multipage Visits'
	WHEN 'CustomerInfo' THEN 'Customer Info'
	WHEN 'OrderConfirmation' THEN 'Order Confirmation'
	ELSE [funnel_step] 
END
AS [Funnel Step]
,[last_touch_marketing_channel] AS [Last Touch Marketing Channel]
,[business_line] AS [Business Line]
,CASE [upper_lower_funnel]
	WHEN 'upper' THEN 'Upper'
	WHEN 'lower' THEN 'Lower'
	ELSE [upper_lower_funnel] 
	END
 AS [Upper/Lower Funnel]
,[channel_type] AS [Channel Type]
,[channel_group] AS [Channel Group]
,[visits_dedup] AS [Visits]
FROM [dbo].[tableau_LastTouchVisits]

GO
/****** Object:  Table [dbo].[Department]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Department](
	[DepartmentNumber] [char](10) NOT NULL,
	[DepartmentName] [varchar](50) NOT NULL,
	[ManagerID] [int] NULL,
	[ParentDepartmentNumber] [char](10) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DepartmentNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[dim_date]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_date](
	[date_key] [int] IDENTITY(1,1) NOT NULL,
	[date] [date] NOT NULL,
	[date_name]  AS (datename(weekday,[date])),
	[month_number]  AS (datepart(month,[date])),
	[month_name]  AS (datename(month,[date])),
	[year_number]  AS (datepart(year,[date])),
	[quarter_number]  AS (datepart(quarter,[date])),
	[date_number]  AS (datepart(day,[date])),
	[fiscal_year]  AS (case when datepart(month,[date])<(7) then datepart(year,[date]) else datepart(year,[date])+(1) end),
	[week_start_date]  AS (dateadd(day,(1)-datepart(weekday,[date]),[date])),
	[month_start_date]  AS (dateadd(day, -(datepart(day,eomonth([date]))-(1)),eomonth([DATE]))),
	[year_start_date]  AS (CONVERT([date],dateadd(year,datediff(year,(0),[date]),(0)))),
PRIMARY KEY CLUSTERED 
(
	[date_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
/****** Object:  Table [dbo].[tb_dedup_DTCLastTouchVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tb_dedup_DTCLastTouchVisits](
	[date] [datetime] NULL,
	[Granularity] [varchar](5) NOT NULL,
	[funnel_step] [nvarchar](400) NULL,
	[last_touch_marketing_channel] [varchar](max) NULL,
	[business_line] [nvarchar](400) NULL,
	[visits] [bigint] NULL,
	[visits_dedup] [bigint] NULL
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[test_fact_table]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test_fact_table](
	[test_fact_id] [int] IDENTITY(1,1) NOT NULL,
	[date_key] [int] NULL,
	[test_data] [int] NULL
)

GO
/****** Object:  Table [dbo].[transform_LastTouchVisits]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[transform_LastTouchVisits](
	[date] [date] NOT NULL,
	[granularity] [varchar](20) NOT NULL,
	[funnel_step] [varchar](100) NOT NULL,
	[last_touch_marketing_channel] [varchar](200) NOT NULL,
	[business_line] [varchar](100) NOT NULL,
	[upper_lower_funnel] [varchar](20) NULL,
	[channel_type] [varchar](100) NULL,
	[channel_group] [varchar](100) NULL,
	[visits] [bigint] NOT NULL,
	[visits_dedup] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[date] ASC,
	[granularity] ASC,
	[last_touch_marketing_channel] ASC,
	[funnel_step] ASC,
	[business_line] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[sp_add_tableName_as_column_and_union]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author: mchen
-- Created: 2016/08/01
-- Description: This SP will take a table naming convension and union all tables fullfil this convension, 
-- create a table named 'staging_[table naming convension]' 
-- =============================================
CREATE PROCEDURE [dbo].[sp_add_tableName_as_column_and_union]
 @table_name_criteria varchar(100)
AS
BEGIN
-- declare all variables. (not parameters)
	DECLARE @sql [nvarchar](4000)
	DECLARE @temp [nvarchar] (400)
	DECLARE @final_table_name [varchar] (100)
	DECLARE @drop_view [varchar] (200)

-- instantiate string variables
	SET @sql = ''
	SET @temp = ''
	SET @final_table_name = ''
	SET @drop_view = ''

-- using a cursor to build dynamic sql for fetching table name and union tables 
--with same prefix specified by user defined parameter
	DECLARE cur CURSOR FOR 
		SELECT 
		'(SELECT *, ''' + TABLE_NAME + ''' AS table_name 
		FROM [' + TABLE_NAME + ']) UNION ALL '
		FROM INFORMATION_SCHEMA.TABLES t1
		INNER JOIN SYS.OBJECTS t2
		ON t1.Table_Name = t2.name
		WHERE t1.Table_Name LIKE @table_name_criteria
		AND t2.type_desc = 'USER_TABLE'
	OPEN cur
	WHILE 1 = 1
	BEGIN
		FETCH cur INTO @temp
		IF @@FETCH_STATUS = 0 
			BEGIN
				SET @sql = @sql + @temp
			END
		ELSE BREAK
	END
-- close and dispose cursor
	CLOSE cur;
	DEALLOCATE cur;
-- take out the extra 'UNION' key word from the end of the dynamic sql string
	SET @sql = LEFT(@sql, LEN(@sql) -9) 
-- define view/table name based on user defined parameter
	SET @final_table_name = 'staging_'+ LEFT(@table_name_criteria, LEN(@table_name_criteria)-1)

-- view need to be dropped before creating to achieve Idempotency	
-- Becuase view creation has to be the first command on the code block, DROP and CREATE are separe
	SET @drop_view = 'IF (OBJECT_ID(''' + @final_table_name + ''', ''V'') IS NOT NULL) DROP VIEW '+ @final_table_name
	SET @sql = 
		' CREATE VIEW ' + @final_table_name +
		' AS SELECT * FROM (' + @sql + ') AS t'
	--PRINT (@drop_view)
	--PRINT (@sql)
	EXEC(@drop_view)
	EXEC (@sql)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_add_tableName_as_column_and_union_table]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author: mchen
-- Created: 2016/09/02
-- Description: This SP will take a table naming convension and union all tables fullfil this convension, 
-- create a table named 'staging_[table naming convension]' 
-- =============================================
CREATE PROCEDURE [dbo].[sp_add_tableName_as_column_and_union_table]
 @table_name_criteria varchar(100)
AS
BEGIN
-- declare all variables. (not parameters)
	DECLARE @sql [nvarchar](4000)
	DECLARE @temp [nvarchar] (400)
	DECLARE @final_table_name [varchar] (100)
	DECLARE @drop_table [varchar] (200)

-- instantiate string variables
	SET @sql = ''
	SET @temp = ''
	SET @final_table_name = ''
	SET @drop_table = ''

-- using a cursor to build dynamic sql for fetching table name and union tables 
--with same prefix specified by user defined parameter
	DECLARE cur CURSOR FOR 
		SELECT 
		'(SELECT *, ''' + TABLE_NAME + ''' AS table_name 
		FROM [' + TABLE_NAME + ']) UNION ALL '
		FROM INFORMATION_SCHEMA.TABLES t1
		INNER JOIN SYS.OBJECTS t2
		ON t1.Table_Name = t2.name
		WHERE t1.Table_Name LIKE @table_name_criteria
		AND t2.type_desc = 'USER_TABLE'
	OPEN cur
	WHILE 1 = 1
	BEGIN
		FETCH cur INTO @temp
		IF @@FETCH_STATUS = 0 
			BEGIN
				SET @sql = @sql + @temp
			END
		ELSE BREAK
	END
-- close and dispose cursor
	CLOSE cur;
	DEALLOCATE cur;
-- take out the extra 'UNION' key word from the end of the dynamic sql string
	SET @sql = LEFT(@sql, LEN(@sql) -9) 
-- define table name based on user defined parameter
	SET @final_table_name = 'staging_'+ LEFT(@table_name_criteria, LEN(@table_name_criteria)-1)

	SET @drop_table = 'IF (OBJECT_ID(''' + @final_table_name + ''', ''U'') IS NOT NULL) DROP TABLE '+ @final_table_name
	SET @sql = 
		' SELECT * INTO ' + @final_table_name +
		' FROM (' + @sql + ') AS t'

	EXEC(@drop_table)
	EXEC (@sql)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dropTable_like]    Script Date: 10/3/2016 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author: mchen
-- Created: 2016/01/20
-- Use: drop tables from database based on user speficied criteria.
--		will execute based on a 'LIKE' statement
-- =============================================
CREATE PROCEDURE [dbo].[sp_dropTable_like]
 @table_name_criteria varchar(100)
AS
BEGIN
	DECLARE @sql varchar(4000)

	-- cursor default to local
	DECLARE cur CURSOR FOR 
		SELECT 'DROP TABLE [' + Table_Name + ']'
		FROM INFORMATION_SCHEMA.TABLES t1
		INNER JOIN SYS.OBJECTS t2
		ON t1.Table_Name = t2.name
		WHERE t1.Table_Name LIKE @table_name_criteria
		-- this is to ensure only drop user defined tables, not system tabless
		AND t2.type_desc = 'USER_TABLE'

	OPEN cur
	WHILE 1 = 1
	BEGIN
		-- retrieve a specific row from cursor into command
		FETCH cur INTO @sql
		-- 0: successful; -1: failed or the row is beyond result set; -2: row fetched is missing
		IF @@FETCH_STATUS != 0 BREAK
		EXEC (@sql)
	END
	CLOSE cur;
	-- remove cursor reference
	DEALLOCATE cur
END

GO
/****** Object:  StoredProcedure [dbo].[sp_find_tables_size]    Script Date: 10/3/2016 1:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_find_tables_size]
	@order_criteria [nvarchar] (max),
	@table_name_like [nvarchar] (max)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL [nvarchar] (max)

	DECLARE @ParamDefinition [nvarchar] (2000) 

	SET @SQL = 
	'SELECT 
		t.NAME AS TableName,
		t.[create_date],
		t.[modify_date],
		p.rows as RowCounts,
		(SUM(a.total_pages) * 8) / 1024 as TotalSpaceMB, 
		(SUM(a.used_pages) * 8) / 1024 as UsedSpaceMB, 
		(SUM(a.data_pages) * 8) / 1024 as DataSpaceMB
	FROM 
		sys.tables t
	INNER JOIN 
		sys.partitions p ON t.object_id = p.OBJECT_ID 
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
	WHERE 
		t.NAME LIKE ' + ''''+ @table_name_like + '''' +
	' GROUP BY t.name,t.[create_date],t.[modify_date], p.rows
	ORDER BY ' + @order_criteria

	PRINT @SQL

	SET @ParamDefinition = 
	'@order_criteria [nvarchar] (max),
	@table_name_like [nvarchar] (max)'
	
	EXEC sp_executesql @SQL, @ParamDefinition, @order_criteria , @table_name_like

END

GO
