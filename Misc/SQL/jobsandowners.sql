select
	j.[name],
	j.[description],
	sp.[name]
from msdb.dbo.sysjobs as j
	join sys.server_principals as sp on sp.[sid] = j.[owner_sid]