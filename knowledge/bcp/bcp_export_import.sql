
4Lky4O*BQb^@ohSg
/***********************************************************/
-- export using BCP

/*****************query out******************/
-- this doesn't work, will say db.schema.table is not supported in this version of SQL server (Azure)
bcp "SELECT ID, OS_dax, OS_clean, isCompetingOS, OS_grouped FROM OC_Win10.dbo.dim_OS" queryout C:\Users\mchen\Documents\testBCP.tsv -c -U pmc-mchen -S ogonyzmvs0.database.windows.net 


-- this works, as it will query directly into the master db
bcp "SELECT * sys.tables" queryout C:\Users\mchen\Documents\testBCP.tsv -c -U pmc-mchen -S ogonyzmvs0.database.windows.net 



-- from local db, this works
bcp "SELECT ID, OS_dax, OS_clean, isCompetingOS, OS_grouped FROM Meng_test.dbo.dim_OS_test" queryout C:\Users\mchen\Documents\testBCP.tsv -c -T 



/*************************************************************/

-- import from TSV
DROP TABLE dim_os_test

CREATE TABLE dim_OS_test
(
	ID int, 
	OS_dax varchar(400), 
	OS_clean varchar(400), 
	Os_grouped varchar(400),
	isCompetingOS bit

)

BULK INSERT dim_OS_test
        FROM 'C:\Users\mchen\Documents\testBCP.tsv'
            WITH
    (
		KEEPNULLS,
        FIELDTERMINATOR = '\t',
		--ROWTERMINATOR = '0x0a' -- hex value for new line, this works
		--ROWTERMINATOR = '\r\n' -- this doesn't work
        ROWTERMINATOR = '\n' -- this also works
    )

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- Import from a .dat file with format file
-- a .dat file requires a .fmt file to be uploaded together

bcp OC_Win10.dbo.dim_OS out C:\Users\mchen\Documents\testBCP_formatted.dat -U pmc-mchen -S ogonyzmvs0.database.windows.net 
-- follow promt to save a format file C:\Users\mchen\Documents\testBCP_formatted.dat
BULK INSERT dim_OS_test
FROM 'C:\Users\mchen\Documents\testBCP_formatted.dat'
WITH
(
	FORMATFILE = 'C:\Users\mchen\bcp_format.fmt'	
)

TRUNCATE TABLE dim_OS_test


--------------------------------------------
-- full workflow :

--export native format
bcp OC_Win10.dbo.dim_OS out C:\Users\mchen\Documents\testBCP_formatted.dat -N -U pmc-mchen -S ogonyzmvs0.database.windows.net
-- bcp create the fmt file, can not figure out how this can work without .fmt file 
bcp OC_Win10.dbo.dim_OS format nul -n -f C:\Users\mchen\Documents\testBCP_formatted.fmt -S ogonyzmvs0.database.windows.net  -U pmc-mchen
-- bcp in with the .fmt file and .dat file
bcp Meng_test.dbo.dim_OS_test in C:\Users\mchen\Documents\testBCP_formatted.dat -f C:\Users\mchen\Documents\testBCP_formatted.fmt -T



-- if without creting the fmt file, this only import the first row, why?
bcp OC_Win10.dbo.dim_OS out C:\Users\mchen\Documents\testBCP_formatted.dat -N -U pmc-mchen -S ogonyzmvs0.database.windows.net
bcp Meng_test.dbo.dim_OS_test in C:\Users\mchen\Documents\testBCP_formatted.dat -T -N 



SELECT *
FROM dim_OS_test

----------------------
CREATE TABLE dim_OS_test2
(
	ID int, 
	OS_dax varchar(400), 
	OS_clean varchar(400), 
	isCompetingOS bit,
	Os_grouped varchar(400)
)

BULK INSERT dim_OS_test2
        FROM 'C:\Users\mchen\Documents\testBCP.tsv'
            WITH
    (
		KEEPNULLS,
        FIELDTERMINATOR = '\t',
        ROWTERMINATOR = '\n' 
    )

SELECT * FROM dim_OS_test2\

--A table has to be created in the db with desired schema for BCP IN to work
-- otherwise this will error out
bcp Meng_test.dbo.dim_OS_test2 IN  'C:\Users\mchen\Documents\testBCP.tsv' -T, -S localhost



---------------------------------------------
-- test export size and performance
bcp OC_Win10.dbo.[Surf_KPIs_Raw$] out C:\Users\mchen\Documents\surf_kpi_formatted.dat -N -U pmc-mchen -S ogonyzmvs0.database.windows.net
-- 24 sec
-- 130 mb
-- 350k rows

bcp OC_Win10.dbo.[Surf_KPIs_Raw$] out C:\Users\mchen\Documents\surf_kpi_formatted.csv -c -U pmc-mchen -S ogonyzmvs0.database.windows.net
-- 15 sec
-- 64 mb


----------------TMO
bcp roboButlerPOC.dbo.tableau_LTMVisits out C:\git\DM-TMO\TMO_visualization\IPS_documentation\full_data_dump.csv -c -U mChen -S tcp:vlif2fbv0j.database.windows.net