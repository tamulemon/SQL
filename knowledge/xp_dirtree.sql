-- find all files under a directory
EXEC sys.xp_dirtree 'c:\temp\',
				0, -- depth --if 0, will traverse all depth, 0 is only under root folder
				1 -- isfile