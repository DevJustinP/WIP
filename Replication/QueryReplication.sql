select
	Publication,
	count(*) as Articles
from [DBAdmin].[Repl].PubObject
group by Publication