 declare @name nvarchar(max)
set @name='UO_TICKETING_PRODUCT_EXTRACT'
DECLARE @len int, @nname nvarchar(max) =''

SET @len = LEN(@name); 

WHILE (@len > 1)
    BEGIN    
            declare @w varchar(10) =left(@name,1)
			if @w like '%[a-z]%'  set @w= ('[' +UPPER(@w) + lower(@w) +']')
			
			select @nname =@nname + @w
			SELECT @name = RIGHT(@name, @len - 1); 
			
	
			SET @len = LEN(@name); 
			
    END 

	print @nname