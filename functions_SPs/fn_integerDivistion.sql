SELECT *
FROM [sys].[all_objects]
ORDER BY type_desc


-- to find all custome function
SELECT name AS function_name ,SCHEMA_NAME(schema_id) AS schema_name,type_desc
FROM sys.objects
WHERE type_desc LIKE '%FUNCTION%';
GO


IF OBJECT_ID (N'dbo.integerDivision', N'FN') IS NOT NULL
    DROP FUNCTION integerDivision;
GO

CREATE FUNCTION dbo.integerDivision(@nominator int, @denominator int)
RETURNS float
AS 
BEGIN
   RETURN CASE @denominator
   WHEN 0 THEN -1
   ELSE CAST(@nominator AS float)/CAST(@denominator AS float)
   END
END;
GO

