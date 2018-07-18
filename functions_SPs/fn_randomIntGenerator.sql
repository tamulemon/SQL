-- drop existing functions
IF OBJECT_ID (N'dbo.fn_randomIntGenerator', N'FN') IS NOT NULL
    DROP FUNCTION fn_randomIntGenerator;
GO


IF OBJECT_ID (N'dbo.fn_randomFloatGenerator', N'FN') IS NOT NULL
    DROP FUNCTION fn_randomFloatGenerator;
GO


-- can not use side_effect operator NEWID() or RAND() in a function
-- use view as a work-around

CREATE VIEW getNewID 
AS 
(SELECT NEWID() AS new_id) -- a random UUID


CREATE VIEW getRand 
AS 
(SELECT RAND() AS new_rand) -- a randowm float between 0 and 1

---- int function
CREATE FUNCTION fn_randomIntGenerator (@start int, @end int)
RETURNS int
AS
BEGIN
	DECLARE @rndValue uniqueidentifier
	SET @rndValue = (SELECT new_id FROM getNewID)

	RETURN ABS(CHECKSUM(@rndValue)) % (@end - @start) + @start --CHECKSUM will hash the UUID
END;
GO


-- float function
CREATE FUNCTION fn_randomFloatGenerator(@start int, @end int)
RETURNS float
AS 
BEGIN
	DECLARE @rand float
	SET @rand = (SELECT new_rand FROM getRand)

	RETURN @rand * (@end - @start) + @start
END
GO
-------------------------------------------------------------------------
---- Test the function
--get int
--DECLARE @ct int
--SET @ct = 0
--WHILE (@ct < = 20)
--BEGIN
--	PRINT dbo.fn_randomIntGenerator(3, 10)
--	SET @ct = @ct + 1
--END
--GO

------ get float
--DECLARE @ct int
--SET @ct = 0
--WHILE (@ct < = 20)
--BEGIN
--	PRINT dbo.fn_randomFloatGenerator(3, 10)
--	SET @ct = @ct + 1
--END
--GO

------------------------------------------------------------------
-- when execute along, RAND() is random. Run this 3 times all different. 
SELECT RAND()

---- RAND() is called with different seeds in while loop
DECLARE @ct int, @rand float
SET @ct = 0
WHILE (@ct <= 5)
BEGIN
	SELECT RAND()
	SET @ct += 1
END
GO

---- seed is cached in execution plan for RAND()
SELECT RAND()
FROM sys.tables



---- rand() is called with different seeds from the view, so the view basically garantee the seed being replaced each time
DECLARE @ct int, @rand float
SET @ct = 0
WHILE (@ct <= 5)
BEGIN
	select new_rand from getrand
	SET @ct = @ct + 1
END
GO

-- or
SELECT new_rand from getrand