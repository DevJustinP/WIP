USE [PRODUCT_INFO]
GO

alter table [ProdSpec].[Gabby_Ecat] add constraint [FK_Gabby_Ecat_CollectionCode] foreign key (CollectionCode) references ProdSpec.Gabby_Ecat_CollectionCode(CollectionCode)
go


/*
test the foreign constraint 'TESTT' is not a valid collectioncode
insert into [ProdSpec].[Gabby_Ecat](StockCode, UploadToEcat, TradeNameCode, CollectionCode, NewItem, OptionInventory)
values ('TESTCODE', 0, 'TESTT', 'TESTT', 1, 1)
*/