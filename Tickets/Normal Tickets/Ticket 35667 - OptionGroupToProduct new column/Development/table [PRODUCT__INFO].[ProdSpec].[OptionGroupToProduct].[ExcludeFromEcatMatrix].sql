use [PRODUCT_INFO]
go

alter table [ProdSpec].[OptionGroupToProduct]
add ExcludeFromEcatMatrix bit default 0;