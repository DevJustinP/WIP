insert into [dbo].[Uniters] (Status, SalesOrder, Invoice, PolicyType, PolicyExact, DateTransmitted, XmlText, ResponseCode, ResponseText)
select top 20
	[Status],
	SalesOrder,
	Invoice,
	PolicyType,
	PolicyExact,
	getdate() as [DateTransmitted],
	XmlText,
	ResponseCode,
	ResponseText
FROM PRODUCT_INFO.dbo.Uniters as  u
where ResponseCode <> 200 
	and ResponseCode is not null 
	AND  PolicyExact <> 'CUST'