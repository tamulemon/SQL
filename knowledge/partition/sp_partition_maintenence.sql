/****** Object:  StoredProcedure [dbo].[sp_partition_maintenence]    Script Date: 4/12/2017 3:38:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec sp_partition_maintenence 'tmob_saf_r2'
ALTER proc [dbo].[sp_partition_maintenence]
@dbname varchar(100)
as
set nocount on 
declare @tbname varchar(500),@part varchar(500),@insert_date varchar(500),@stg_table varchar(500),@sqltext nvarchar(max),@fileid bigint,@archive_tbname varchar(500)

set @stg_table= @tbname+'_____onetime_purge'
set @archive_tbname= @tbname+'_____ARCHIVE'

declare eventdate cursor local for  
       select tbname,insert_date,partition
       FROM [merkledba].[dbo].[meta_archive] 
       where ([cnt_orig]-[cnt1]) >0 
       and  dbname=@dbname
       and active_flg ='y' and status is null
       group by tbname,insert_date,partition
       order by 1 desc


open eventdate 
fetch next from eventdate into @tbname,@insert_date,@part

while @@fetch_status = 0   
begin   
       set @stg_table=''+@tbname+'_____onetime_purge'
       set @archive_tbname= @dbname+'.dbo.'+@tbname+'_____ARCHIVE'
	   --declare  @consname varchar(100)=CK_insertedate__getdate

-- Main code 

IF OBJECT_ID (@stg_table, N'U') IS NOT NULL 
             BEGIN
                    SET @sqltext = 'DROP TABLE '+ @stg_table
                    print @sqltext
                    exec sp_executesql       @sqltext
                    IF @@ERROR <> 0 
                    BEGIN
                           Raiserror( @sqltext, 16,1) 
                           RETURN
                    END
             END          

-- Create stage table 
SET @sqltext='select  * into '+@stg_table+' from '+@archive_tbname+' 
where file_id not in ( select file_id from merkledba..meta_archive where tbname='''+@tbname+''' and active_flg =''y''  and insert_date='''+@insert_date+''') 
and insert_date='''+@insert_date+''''
       PRINT @sqltext
	   exec sp_executesql       @sqltext
       
                    IF @@ERROR <> 0 
                    BEGIN
                           Raiserror( @sqltext, 16,1) 
                           RETURN
                    END


-- Create IDX to stage table
-- Create clusted col store idx
SET @sqltext = 'CREATE CLUSTERED COLUMNSTORE INDEX [CCSI_'+@tbname+'] ON '+@stg_table+' WITH (DROP_EXISTING = off,maxdop=0) ' 
PRINT @sqltext
exec sp_executesql @sqltext
                    IF @@ERROR <> 0 
                    BEGIN
                           Raiserror( @sqltext, 16,1) 
                           RETURN
                    END


-- Create constraint
     SET @sqltext = 'Alter table  '+@stg_table+' Add Constraint CK_insertedate CHECK (insert_date='''+@insert_date+''' and [insert_date] IS NOT NULL);' 
     PRINT @sqltext
	exec sp_executesql @sqltext
                    IF @@ERROR <> 0 
                    BEGIN
                           Raiserror( @sqltext, 16,1) 
                           RETURN
                    END  

-- Switch in 
SET @sqltext = 'Alter table '+@stg_table+' Switch to '+@tbname+' partition '+@part+';'
					print @sqltext
                   exec sp_executesql @sqltext
                    IF @@ERROR <> 0 
                    BEGIN
                           Raiserror( @sqltext, 16,1) 
                           RETURN
                    END

-- Update meta 
SET @sqltext ='update merkledba..meta_archive set status=''done'' where tbname='''+@tbname+''' and partition='+@part+' 
and insert_date='''+@insert_date+''' and active_flg =''y'''

print @sqltext
exec sp_executesql @sqltext

IF OBJECT_ID (@stg_table, N'U') IS NOT NULL 
             BEGIN
                    SET @sqltext = 'DROP TABLE '+ @stg_table
                    print @sqltext
                    exec sp_executesql       @sqltext
                    IF @@ERROR <> 0 
                    BEGIN
                           Raiserror( @sqltext, 16,1) 
                           RETURN
                    END
             END          

fetch next from eventdate into @tbname,@insert_date,@part

end

close eventdate
deallocate eventdate


