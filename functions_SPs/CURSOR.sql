DROP TABLE IF EXISTS test_cursor

CREATE TABLE test_cursor
(
	id int,
	value varchar (25)
)

INSERT INTO test_cursor
VALUES
(1, 'test1'),
(2, 'test2'),
(3, 'test3'),
(24, 'test4'),
(5, 'test5'),
(6, 'test6'),
(7, 'test7'),
(8, 'test8'),
(9, 'test9'),
(10, 'test10')

----------------------------------------

DECLARE @temp_int int

DECLARE test_cur CURSOR
FOR SELECT id from test_cursor
WHERE id%2 = 0 -- I want the even id
OPEN test_cur
FETCH FROM test_cur INTO @temp_int -- Perform the first fetch.  
-- same as FETCH NEXT FROM test_cur INTO @temp_int. 'NEXT' is default as oppose to 'PRIOR', 'FIRST'..
-- same as FETCH test_cur INTO @temp_int
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		PRINT @temp_int
		FETCH FROM test_cur INTO @temp_int -- This is executed as long as the previous fetch succeeds.
	END
CLOSE test_cur
DEALLOCATE test_cur

-----------------------------
-- first fetching needs to happen outside of while loop, because without fetching
-- the @@FETCH_STATUS is null
-- so this won't run
WHILE (@@FETCH_STATUS = 0)
	BEGIN	
		FETCH FROM test_cur INTO @temp_int -- This is executed as long as the previous fetch succeeds.
		PRINT @temp_int
	END
----------------------------------------

DECLARE @temp_int int

DECLARE test_cur CURSOR
FOR SELECT id from test_cursor
WHERE id%2 != 0
OPEN test_cur

WHILE (1 = 1)
BEGIN
	FETCH test_cur INTO @temp_int -- to bring fetching inside WHILE loop, need a WHILE TRUE loop and BREAK
	WHILE 
	IF (@@FETCH_STATUS =0)
		PRINT @temp_int
	ELSE 
	BREAK
END
CLOSE test_cur
DEALLOCATE test_cur