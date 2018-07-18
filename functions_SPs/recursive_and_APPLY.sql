--Create Employees table and insert values.
CREATE TABLE Employees
(
    empid   int         NOT NULL
    ,mgrid   int         NULL
    ,empname varchar(25) NOT NULL
    ,salary  money       NOT NULL
    CONSTRAINT PK_Employees PRIMARY KEY(empid)
);
GO
INSERT INTO Employees VALUES(1 , NULL, 'Nancy'   , $10000.00);
INSERT INTO Employees VALUES(2 , 1   , 'Andrew'  , $5000.00);
INSERT INTO Employees VALUES(3 , 1   , 'Janet'   , $5000.00);
INSERT INTO Employees VALUES(4 , 1   , 'Margaret', $5000.00);
INSERT INTO Employees VALUES(5 , 2   , 'Steven'  , $2500.00);
INSERT INTO Employees VALUES(6 , 2   , 'Michael' , $2500.00);
INSERT INTO Employees VALUES(7 , 3   , 'Robert'  , $2500.00);
INSERT INTO Employees VALUES(8 , 3   , 'Laura'   , $2500.00);
INSERT INTO Employees VALUES(9 , 3   , 'Ann'     , $2500.00);
INSERT INTO Employees VALUES(10, 4   , 'Ina'     , $2500.00);
INSERT INTO Employees VALUES(11, 7   , 'David'   , $2000.00);
INSERT INTO Employees VALUES(12, 7   , 'Ron'     , $2000.00);
INSERT INTO Employees VALUES(13, 7   , 'Dan'     , $2000.00);
INSERT INTO Employees VALUES(14, 11  , 'James'   , $1500.00);
GO
--Create Departments table and insert values.
CREATE TABLE Departments
(
    deptid    INT NOT NULL PRIMARY KEY
    ,deptname  VARCHAR(25) NOT NULL
    ,deptmgrid INT NULL REFERENCES Employees
);
GO
INSERT INTO Departments VALUES(1, 'HR',           2);
INSERT INTO Departments VALUES(2, 'Marketing',    7);
INSERT INTO Departments VALUES(3, 'Finance',      8);
INSERT INTO Departments VALUES(4, 'R&D',          9);
INSERT INTO Departments VALUES(5, 'Training',     4);
INSERT INTO Departments VALUES(6, 'Gardening', NULL);


------------------------------------------------------------------------

CREATE FUNCTION dbo.fn_getsubtree(@empid AS INT) 
    RETURNS @TREE TABLE
(
    empid   INT NOT NULL
    ,empname VARCHAR(25) NOT NULL
    ,mgrid   INT NULL
    ,lvl     INT NOT NULL
)
AS
BEGIN
  WITH Employees_Subtree(empid, empname, mgrid, lvl)
  AS
  ( 
    -- Anchor Member (AM)
    SELECT empid, empname, mgrid, 0
    FROM Employees
    WHERE empid = @empid

    UNION all
    
    -- Recursive Member (RM)
    SELECT e.empid, e.empname, e.mgrid, es.lvl+1
    FROM Employees AS e
      JOIN Employees_Subtree AS es
        ON e.mgrid = es.empid
  )
  INSERT INTO @TREE
    SELECT * FROM Employees_Subtree;

  RETURN
END
GO

SELECT d.deptid, deptname, e.empname
FROM Departments AS d
LEFT OUTER JOIN Employees AS e
ON d.deptmgrid = e.empid

SELECT D.deptid, D.deptname, D.deptmgrid
    ,ST.empid, ST.empname, ST.mgrid, ST.lvl
FROM Departments AS D
    CROSS APPLY fn_getsubtree(D.deptmgrid) AS ST;





----------------------------------------------------
-- practice on recursion
-------------------------------------------

SELECT * 
FROM Departments
SELECT *
FROM Employees

-- this will give department level information. only show people under the big boss
-- also the highest level manager 'Nancy' is not present because she doesn't have a dept associted
-- that's why it's only a department-level summary

;WITH dept_info
	(
		department_id,
		department_name,
		manager_employee_id,
		manager_name,
		member_employee_id,
		employee_name,
		employee_level
	)
AS
(
	SELECT 
		d.deptid,
		d.deptname,
		d.deptmgrid, 
		e.empname,
		e.empid,
		e.empname,
		0
	FROM Employees AS e
	INNER JOIN Departments AS d
	ON e.empid = d.deptmgrid
	UNION ALL
		SELECT
				di.department_id,
				di.department_name,
				di.manager_employee_id,
				di.manager_name,
				e.empid,
				e.empname,
				di.employee_level + 1
		FROM Employees AS e
		INNER JOIN dept_info di
		ON e.mgrid = di.member_employee_id -- mistake e.mgrid = di.manager_employee_id, this will end with infinite recursion
		-- this makes the direct report mode not represented here
)


SELECT * FROM  dept_info
ORDER BY department_id
	OPTION (maxrecursion 100)



-- direct report hierachy
;WITH direct_report
	(
		--department_id,
		--department_name,
		manager_employee_id,
		manager_name,
		employee_id,
		employee_name,
		employee_level
	)
AS
(
	SELECT 
		--d.deptid,
		--d.deptname,
		--d.deptmgrid,
		e.mgrid, 
		e.empname,
		e.empid,
		e.empname,
		0
	FROM Employees AS e
	WHERE e.mgrid IS NULL -- Nancy
	--INNER JOIN Departments AS d
	--ON e.empid = d.deptmgrid
	UNION ALL
		SELECT
			--di.department_id,
			--di.department_name,
			e.mgrid,
			di.employee_name,
			e.empid,
			e.empname,
			di.employee_level + 1
		FROM Employees AS e
		INNER JOIN direct_report di
		ON e.mgrid = di.employee_id
	)


SELECT * FROM  direct_report
	OPTION (maxrecursion 0)

