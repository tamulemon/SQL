DECLARE @test_date date
SELECT @test_date = date_number
	FROM 
	(
		SELECT ROW_NUMBER() OVER (ORDER BY date_key) AS row_num, date_number 
		FROM dim_date
	) t1
	WHERE row_num = 823
PRINT @test_date
--2015-09-29

SET @test_date = DATEADD(day, 1, @test_date)
PRINT @test_date