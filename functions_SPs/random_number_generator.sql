--------------------------
-- newid will generate a string of UUID per row
DECLARE @id nvarchar(50)
SET @id = NEWID()
PRINT @id


----------------------------
SELECT NEWID()
FROM [dbo].[dim_date]

-----------------------------

DECLARE @id1 nvarchar(50),  @id2 nvarchar(50)
SELECT @id1 = NEWID(),
	@id2 = CHECKSUM(@id1)
PRINT @id1 
PRINT @id2
/*
C76FA02A-F9B8-4E10-ACD5-32D384030D23
-- how is checksum calculated? it's probably a logic and a hash function, that is one way but consistant
1350907971
*/