USE [Sysprodb7]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
=============================================================
	Author:			Pope, Justin (contributor: Erickson, Ben)
	Create Date:	2022/12/22
	Description:	Issue:
					SysproV8 has an issue when fulfilling 
					RMAs and does not fill out the 
					SorDetail.MWarehouse column on the return
					order. 
					Resolution:
					A trigger has been set up on the
					insert of AdmOperatorQueue to initiate
					this procedure. @SalesOrder parameter
					is in the perspective of the return 
					order and will link to the original 
					order.
=============================================================
Test
declare @SalesOrder as varchar(20) = ''
execute [Sysprodb7].[dbo].[usp_Update_SorDetail_MWarehouse_RMA_error] @SalesOrder
=============================================================
*/
Create or Alter Procedure [dbo].[usp_Update_SorDetail_MWarehouse_RMA_error](
	@SalesOrder as varchar(20)
)
as
begin
	
	UPDATE SDC
		SET MWarehouse = SDP.MWarehouse
	FROM [SysproCompany100].[dbo].[SorDetail] as SDC
		Cross apply (
						select top 1
							P.MWarehouse
						from [SysproCompany100].[dbo].[SorDetail] as P
						where P.SalesOrder = SDC.SalesOrder
							and P.SalesOrderLine < SDC.SalesOrderLine
							and P.MBomFlag = 'P'
						order by P.SalesOrderLine desc ) as SDP
	where SDC.SalesOrder = @SalesOrder;
end
go

CREATE or Alter TRIGGER [dbo].[trg_AdmOperatorQueue_AfterInsert]
  ON [dbo].[AdmOperatorQueue]
AFTER INSERT
AS
BEGIN

  SET NOCOUNT ON;

	declare @Subject as varchar(255)
	select
		@Subject = [Subject]
	from inserted

	declare @SalesOrder as varchar(11) = substring(@Subject, 10, 11)

	if exists(Select 1 from [SysproCompany100].[dbo].[SorMaster])
		begin
			execute [dbo].[usp_Update_SorDetail_MWarehouse_RMA_error] @SalesOrder
		end

  END;
GO

ALTER TABLE [dbo].[AdmOperatorQueue] ENABLE TRIGGER [trg_AdmOperatorQueue_AfterInsert]
GO