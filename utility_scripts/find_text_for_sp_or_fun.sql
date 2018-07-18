
-- Find text for stored procedure
EXEC sp_helptext N'sp_tablecollations_100'  


-- Find text for function
EXEC sp_helptext N'[dbo].[ufn_OCID_8]' 

--SELECT 
--    so.name, su.name, so.crdate 
--FROM
--    SYS.sysobjects so 
--JOIN 
--    SYS.sysusers su 
--ON so.uid = su.uid  
--ORDER BY crdate DESC

