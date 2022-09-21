USE [SysproDocument]
GO

SET NOCOUNT ON;

--CREATE ROLE [db_SysproUser]
--GO

--GRANT INSERT ON [SysproDocument].[SOH].[SorMaster_Process_Staged] TO [db_SysproUser]
--GO

/***********************************
************************************
	ADD existing _SYSPRO and DS- users in SysproDocument to db_SysproUser role
************************************
***********************************/


DECLARE @ID					AS INT
				,@LoginName	AS VARCHAR(255)
				,@UsernName	AS VARCHAR(255)
				,@Command		AS VARCHAR(MAX) = '';

DROP TABLE IF EXISTS #Logins;
CREATE TABLE #Logins
(
	ID					INT IDENTITY(1,1) PRIMARY KEY
	,LoginName	VARCHAR(255)
)


INSERT INTO #Logins
SELECT server_principals.[name]
FROM master.sys.server_principals
LEFT JOIN sys.database_principals
	ON server_principals.[name] COLLATE DATABASE_DEFAULT = database_principals.[name]
WHERE	(	server_principals.[name] LIKE '%_SYSPRO'
				OR server_principals.[name] LIKE 'DS-%'
			)
			AND database_principals.[name] IS NULL;

PRINT 'USE SysproDocument;'					 

SET @ID = (	SELECT MAX(ID)
						FROM #Logins)

WHILE @ID > 0
BEGIN
	
	SET @LoginName =	(	SELECT LoginName
											FROM #Logins
											WHERE ID = @ID)

	SET @Command =	'CREATE USER [' + @LoginName + '] FOR LOGIN [' + @LoginName + '] WITH DEFAULT_SCHEMA = dbo;' + CHAR(13) +
									'ALTER ROLE [db_SysproUser] ADD MEMBER [' + @LoginName + '];' + CHAR(13)


	PRINT @Command;

	SET @ID -= 1;
END
