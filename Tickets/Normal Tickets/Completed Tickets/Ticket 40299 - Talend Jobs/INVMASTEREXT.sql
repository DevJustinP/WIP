select IM.StockCode,MakeToOrderFlag

FROM	 [dbo].[InvMaster] IM
inner join [dbo].[InvMaster+] [IM+] on [IM+].StockCode = IM.StockCode