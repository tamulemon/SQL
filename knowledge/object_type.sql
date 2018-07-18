select ID from sysobjects where xtype = 'u' and name = '<your table name>'

SELECT OBJECT_ID('<database name>..<your table name>')

Object type. Can be one of these object types: 
C = CHECK constraint
D = Default or DEFAULT constraint
F = FOREIGN KEY constraint
L = Log
FN = Scalar function
IF = Inlined table-function
P = Stored procedure
PK = PRIMARY KEY constraint (type is K)
RF = Replication filter stored procedure 
S = System table
TF = Table function
TR = Trigger
U = User table
UQ = UNIQUE constraint (type is K)
V = View
X = Extended stored procedure