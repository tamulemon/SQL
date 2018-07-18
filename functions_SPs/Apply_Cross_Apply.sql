-- CROSS APPLY
--returns only those rows from left table expression (in its final output) if it matches with right table expression
-- like INNER JOIN

-- OUTER APPLY
--returns all the rows from left table expression irrespective of its match with the right table expression
-- like LEFT OUT JOIn

use [Meng_test]

SELECT *
FROM [dbo].[Employees]

SELECT *
FROM [dbo].[Departments]

-- this will only pull Exployee if they are manager
SELECT *
FROM [Employees] e
CROSS APPLY
(
	SELECT *
	FROM Departments d
	WHERE e.empid = d.deptmgrid
)t

-- all employee
SELECT e.*, d.deptid
FROM [Employees] e
OUTER APPLY
(
	SELECT *
	FROM Departments d
	WHERE e.empid = d.deptmgrid
)t

---how to pull depid from the manager?
