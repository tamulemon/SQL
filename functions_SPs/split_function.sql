SELECT * FROM fn_Split('foo,bar,widget', ',')


--if exists (select * from dbo.sysobjects where id = ob-ject_id(N'[dbo].[fn_Split]') and xtype in (N'FN', N'IF', N'TF'))
--drop function [dbo].[fn_Split]
--GO
 
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
 
CREATE  FUNCTION fn_Split(@text varchar(8000), @delimiter varchar(20) = ' ')
RETURNS @Strings TABLE
(    
  position int IDENTITY PRIMARY KEY,
  value varchar(8000)   
)
AS
BEGIN
 
DECLARE @index int
SET @index = -1 
 
WHILE (LEN(@text) > 0) 
 
  BEGIN 
    SET @index = CHARINDEX(@delimiter , @text)  
    IF (@index = 0) AND (LEN(@text) > 0)  
      BEGIN  
        INSERT INTO @Strings VALUES (@text)
          BREAK  
      END 
 
    IF (@index > 1)  
      BEGIN  
        INSERT INTO @Strings VALUES (LEFT(@text, @index - 1))   
        SET @text = RIGHT(@text, (LEN(@text) - @index))  
      END 
    ELSE
      SET @text = RIGHT(@text, (LEN(@text) - @index)) 
    END
  RETURN
 
END
GO
 
SET QUOTED_IDENTIFIER OFF
GO
 
SET ANSI_NULLS ON
GO
