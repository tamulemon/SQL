
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[test_email]
	@title nvarchar(300),
	@email_address nvarchar(2000),
	@debug bit = 1
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

	SET @tableHTML = @tableHTML + N'</table>';

 	SELECT @subjectLine = 'test_email'

	IF @debug = 1
	BEGIN	
		PRINT @tableHTML
	END
	ELSE
	BEGIN
		EXECUTE msdb.dbo.sp_send_dbmail
					@recipients = @email_address,
					@subject = @subjectLine,
					@body = @tableHTML,
					@body_format = 'HTML';
	END
END


---------------------------------
sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
sp_configure 'Database Mail XPs', 1;  
GO  
RECONFIGURE  
GO  



exec [dbo].[test_email]
	@title = 'test_from_local_db',
	@email_address = 'mechen@merkleinc.com',
	@debug = 0


---------------------------------------------------------------------------------
EXEC msdb.dbo.sp_send_dbmail

  @profile_name = 'Adventure Works Administrator',

  @recipients = 'yourfriend@Adventure-Works.com',

  @body = 'The stored procedure finished successfully.',

  @subject = 'Automated Success Message' ;