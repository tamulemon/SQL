--- make exisiting column IDENTITY column
-- DOES NO WORK!!

DROP TABLE test_meng
DROP TABLE test_meng_1
DROP TABLE test_meng_2

CREATE TABLE test_meng
(
	id int NOT NULL,
	name varchar(10)
)

INSERT INTO test_meng
VALUES(99, 'row1'),
(2, 'row2'),
(3, 'row3')


CREATE TABLE test_meng_1
(
	id int IDENTITY(1,1) NOT NULL,
	name varchar(10)
)
ALTER TABLE dbo.test_meng SWITCH TO dbo.test_meng_1;


SELECT *
FROM test_meng

SELECT *
FROM test_meng_1

----------------
insert into test_meng_1
(name)
VALUES ('newrow')

insert into test_meng_1
(name)
VALUES ('newrow2')

-- why it has two id=2
/*
id	name
99	row1
2	row2
3	row3
1	newrow
2	newrow2

*/


SELECT *
FROM test_meng_1
where id = 2

-------------------------------------
-----------------------------------------------
-- this works

CREATE TABLE test_meng_2
(
	id int IDENTITY(1,1) NOT NULL,
	name varchar(10)
)
SET IDENTITY_INSERT test_meng_2 ON

INSERT INTO test_meng_2
(id, name)
SELECT * FROM test_meng_1 WHERE id <>2

SET IDENTITY_INSERT test_meng_2 OFF

SELECT *
FROM test_meng_2

INSERT INTO test_meng_2
(name)
VALUES ('newrow3')

SELECT *
FROM test_meng_2 -- start increment from the largested number