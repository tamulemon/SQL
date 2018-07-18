ALTER TABLE EmployeeReports
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = NONE)


-- row compression
ALTER TABLE EmployeeReports
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = ROW) -- compress out the empty cells


ALTER TABLE EmployeeReports
REBUILD PARTITION = ALL
WITH (DATA_COMPRESSION = PAGE) -- looks for patterns in the data , column compression 

-- performance over head
-- when retrieve compressed data, will de-compress the data