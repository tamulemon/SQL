USE Meng_test
GO  

IF EXISTS (  
SELECT *   
   FROM INFORMATION_SCHEMA.ROUTINES   
   WHERE SPECIFIC_NAME = 'WorkOrdersFor<product_name, nvarchar(50), name>')  
   DROP PROCEDURE dbo.WorkOrdersFor<product_name, nvarchar(50), name>;  
GO  
CREATE PROCEDURE dbo.WorkOrdersFor<product_name, nvarchar(50), name>  
AS  
SELECT Name, WorkOrderID   
FROM Production.WorkOrder AS WO  
JOIN Production.Product AS Prod  
ON WO.ProductID = Prod.ProductID  
WHERE Name = '<product_name, nvarchar(50), name>';  
--Parameters require three elements: 
--the name of the parameter that you want to replace, the data type of the parameter, 
--and a default value for the parameter.