-- percent difference between 2 integer

-- this will be a SQL_SCALAR_FUNCTION
IF OBJECT_ID (N'dbo.fn_integer_percent_diff', N'FN') IS NOT NULL
    DROP FUNCTION fn_integer_percent_diff;
GO

CREATE FUNCTION dbo.fn_integer_percent_diff(@num1 bigint, @num2 bigint)
RETURNS float 
AS 
BEGIN
   RETURN 
	CASE @num2
		WHEN 0 THEN NULL
		ELSE CAST((@num1 - @num2) AS float)/CAST(@num2 AS float)
	END
END;
GO


