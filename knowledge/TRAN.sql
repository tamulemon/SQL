PRINT @@TRANCOUNT
-- 0 
--Returns the number of BEGIN TRANSACTION statements that have occurred on the current connection.

BEGIN TRAN
	PRINT @@TRANCOUNT
	--1
	BEGIN TRAN
		PRINT @@TRANCOUNT
		--2
	COMMIT
	PRINT @@TRANCOUNT
	-- 1
COMMIT
	
