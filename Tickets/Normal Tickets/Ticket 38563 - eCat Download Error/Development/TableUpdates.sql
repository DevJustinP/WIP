alter table [Export].[Stage_Gabby_Order]
alter column [OrderNotes] varchar(2000);
alter table [Export].[Stage_Gabby_Order]
alter column [LineNotes] varchar(2000);

alter table [Export].[Data_Gabby_Header]
alter column [OrderNotes] varchar(2000);

alter table [Export].[Data_Gabby_Line]
alter column [LineNotes] varchar(2000);

alter table [Export].[Stage_SummerClassics_Contract_Order]
alter column [OrderNotes] varchar(2000);
alter table [Export].[Stage_SummerClassics_Contract_Order]
alter column [LineNotes] varchar(2000);

alter table [Export].[Data_SummerClassics_Contract_Header]
alter column [OrderNotes] varchar(2000);

alter table [Export].[Data_SummerClassics_Contract_Line]
alter column [LineNotes] varchar(2000);

alter table [Export].[Stage_SummerClassics_Retail_Order]
alter column [OrderNotes] varchar(2000);
alter table [Export].[Stage_SummerClassics_Retail_Order]
alter column [LineNotes] varchar(2000);

alter table [Export].[Data_SummerClassics_Retail_Header]
alter column [OrderNotes] varchar(2000);

alter table [Export].[Data_SummerClassics_Retail_Line]
alter column [LineNotes] varchar(2000);

alter table [Export].[Stage_SummerClassics_Wholesale_Order]
alter column [OrderNotes] varchar(2000);
alter table [Export].[Stage_SummerClassics_Wholesale_Order]
alter column [LineNotes] varchar(2000);

alter table [Export].[Data_SummerClassics_Wholesale_Header]
alter column [OrderNotes] varchar(2000);

alter table [Export].[Data_SummerClassics_Wholesale_Line]
alter column [LineNotes] varchar(2000);