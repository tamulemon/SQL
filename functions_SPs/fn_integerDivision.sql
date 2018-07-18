-- rewrite to return integer 
-- mchen 2016/10/17

IF OBJECT_ID (N'dbo.fn_integerDivision', N'FN') IS NOT NULL
    DROP FUNCTION fn_integerDivision;
GO

CREATE FUNCTION dbo.fn_integerDivision(@numerator bigint, @denominator bigint)
RETURNS float
AS 
BEGIN
DECLARE @output float
	IF @denominator = 0 
			IF @numerator = 0
				RETURN 0
			ELSE
				RETURN NULL
	ELSE 
		SET @output = CAST(@numerator AS float)/CAST(@denominator AS float)
	RETURN @output
END;

GO


-- to use the function
SELECT dbo.fn_integerDivision(0,0) -- 0
SELECT dbo.fn_integerDivision(3,0) -- NULL

SELECT dbo.fn_integerDivision(1,2) --1
SELECT dbo.fn_integerDivision(1,3) -- 0