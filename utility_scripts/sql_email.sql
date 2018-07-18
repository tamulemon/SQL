USE [UORL_QC]
GO

/****** Object:  StoredProcedure [dbo].[rpt_report_analysis]    Script Date: 3/6/2017 2:36:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[rpt_report_analysis]
	@client_id INT = 1,
	@email varchar(2000)
AS
BEGIN
    SET NOCOUNT ON;
 
    DECLARE @tableHTML AS NVARCHAR (MAX);
 	DECLARE @subjectLine as NVARCHAR (MAX);

 
    SET @tableHTML = N'<head><style>'
				   + N'p		{ font-family:Calibri,Arial; font-size: 12px; color: #24220B; } '
				   + N'.product	{ color: #ffffff; font-weight: bold; } '
				   + N'th	{ border-width: 1px; border-style: solid; border-color: #94927B; background-color: #9CB6D6; font-family:Calibri,Arial; font-size: 12px; color: #ffffff; } '
				   + N'td	{ border-width: 1px; border-style: solid; border-color: #94927B; font-family:Calibri,Arial; font-size: 12px; white-space: nowrap } '
				   + N'</style></head> '
				   + N'<p style="font-family:Calibri,Arial; font-size: 18px; color: #94927B; font-weight:bold;">QC Control Reports: Results Analysis</p>'
				   + N'<table border="1">'
				   + N'<tr><th>Batch</th><th>Package Name</th><th>Report Name</th><th>Analysis Type</th><th>Value</th><th>New Count Value</th><th>Old Count Value</th><th>Actual Deviation</th><th>Allowed Deviation</th><th>Result Status</th></tr>';

	BEGIN



	
	
	SET @tableHTML = @tableHTML + N'</table>';

 	SELECT @subjectLine = client_desc + ': QC Control Reports: Results Analysis'
	FROM CLIENT
	WHERE client_id = @client_id
	 
    EXECUTE msdb.dbo.sp_send_dbmail
					@recipients = @email,
					@subject = @subjectLine,
					@body = @tableHTML,
					@body_format = 'HTML';

END




GO


