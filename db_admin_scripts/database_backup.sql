ALTER DATABASE
SET RECOVERY FULL

BACKUP DATABASE
TO DISK = 'C:\Backup\test_backup.bak'
WITH FORMAT

ALTER DATABASE ... SET OFFLINE WITH ROLLBACK IMMEDIATE
DROP DATABASE ...

RESTORE DATABASE ...
FILEGROUP = 'PRIMARY'
FROM DISK = ''
WITH PARTIAL, RECOVERY, REPLACE