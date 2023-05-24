declare @TableName varchar(1000) = 'InvMaster+'

select
	*
from (
		select
			t.[name] as [TableName],
			c.[name] as [ColumnName],
			ty.[name] as [DataType],
			c.[max_length] as [Length],
			c.[precision] as [precision]
		from [SysproCompany100].[sys].[tables] t
			left join [SysproCompany100].[sys].[columns] c on c.[object_id] = t.[object_id]
			left join [SysproCompany100].[sys].[types] ty on ty.[system_type_id] = c.[system_type_id]
		where t.[name] = @TableName
		) as [table]
	full outer join (
		Select
			s.[name] as [SchemaName],
			t.[name] as [TableName],
			c.[name] as [ColumnName],
			ty.[name] as [DataType],
			c.[max_length] as [Length],
			c.[precision] as [precision]
		from [SysproCompany100_Audit].[sys].[tables] t
			left join [SysproCompany100_Audit].[sys].[schemas] s on s.[schema_id] = t.[schema_id]
			left join [SysproCompany100_Audit].[sys].[columns] c on c.[object_id] = t.[object_id]
			left join [SysproCompany100_Audit].[sys].[types] ty on ty.[system_type_id] = c.[system_type_id]
		where t.[name] = @TableName
		) as [audit] on [audit].[TableName] = [table].[TableName] and
						  ( [audit].[ColumnName] = [table].[ColumnName] or
							[audit].[ColumnName] = [table].[ColumnName] + '_Old' or
							[audit].[ColumnName] = [table].[ColumnName] + '_New' )
order by [audit].[SchemaName] desc