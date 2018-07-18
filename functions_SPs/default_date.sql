DROP TABLE test_date
GO

CREATE TABLE test_date
(
	id_num [int] IDENTITY(1,1) NOT NULL,
	upload_time [date] NULL,
	--upload_time [date] NOT NULL DEFAULT(CONVERT(date, GETDATE())),
	test_count int NULL

	PRIMARY KEY (id_num)

) ON [PRIMARY]
GO


INSERT test_date
([test_count])
VALUES (34)


SELECT *
FROM test_date

------------------------------------------------------------
ALTER TABLE test_date 
ADD DEFAULT CONVERT(date, GETDATE()) FOR upload_time

INSERT test_date
([test_count])
VALUES (345)


SELECT *
FROM test_date