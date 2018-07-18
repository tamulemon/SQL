DECLARE @ct int
SET @ct = 0
WHILE (@ct < = 20)
BEGIN
	PRINT dbo.fn_randomIntGenerator(3, 89)
	SET @ct = @ct + 1
END
GO
