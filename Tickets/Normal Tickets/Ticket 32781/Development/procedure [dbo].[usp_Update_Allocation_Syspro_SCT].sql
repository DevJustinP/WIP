use [SalesOrderAllocation100]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:  Justin Pope
Create date: Thurseday, November 10th, 2022
Description: Update Sales Order SCT 
			 Allocation for Company 100
=============================================
Test:

execute dbo.usp_Update_Allocation_Syspro_SCT;
=============================================
*/

create procedure [dbo].[usp_Update_Allocation_Syspro_SCT]
as
set xact_abort on
begin
	
	set nocount on;

	declare @Blank		as varchar(1)	= '',
			@NullDate	as datetime		= '1900-01-01';

	begin try

		declare @SCT_Allocation as table(
			 [SalesOrder]			VARCHAR(20)
			,[SalesOrderInitLine]	INTEGER
			,[AllocationDate]		datetime
			,[AllocationRef]		varchar(50)
			,[AllocationRefVal1]	varchar(50)
			,[AllocationRefVal2]	varchar(50)
			,[AllocationSupType]	varchar(15)
			,PRIMARY KEY (
				[SalesOrder]
				,[SalesOrderInitLine]
			)
		);
		/*
			Pulling SCT information and relating it to the original order
		*/
		insert into @SCT_Allocation
			SELECT SM.SalesOrder
				   ,SD.SalesOrderInitLine
				   ,SCT_CSDM.AllocationDate	as [AllocationDate]
				   ,SCT_SM.SalesOrder		as [AllocationRef]
				   ,SCT_SD.SalesOrderLine	as [AllocationVal1]
				   ,SCT_CSDM.AllocationRef  as [AllocationRefVal2]
				   ,CASE 
						WHEN SCT_SD.MBackOrderQty >0			THEN 'Backordered'
						WHEN SCT_SD.QtyReserved >0				THEN 'Reserved'
						WHEN SCT_SD.MShipQty >0					THEN 'In Shipping'
	  					WHEN SCT_MD.SalesOrderLine IS NOT NULL	THEN 'Dispatched'
	  					WHEN SCT_GD.SalesOrderLine IS NOT NULL	THEN 'In Transit'
	  					ELSE 'Unknown'
					END						as [AllocationSupType]
			FROM SysproCompany100.dbo.SorMaster SM
				INNER JOIN SysproCompany100.dbo.SorDetail SD ON SM.SalesOrder = SD.SalesOrder AND SD.LineType = 1
				INNER JOIN SysproCompany100.dbo.SorDetail SCT_SD on SCT_SD.MCreditOrderNo = SD.SalesOrder
																and SCT_SD.MCreditOrderLine = SD.SalesOrderLine
				INNER JOIN SysproCompany100.dbo.SorMaster SCT_SM on SCT_SM.SalesOrder = SCT_SD.SalesOrder
																and SCT_SM.OrderStatus NOT IN ('*','\','/')
				LEFT JOIN SysproCompany100.dbo.[CusSorDetailMerch+] SCT_CSDM on SCT_CSDM.SalesOrder = SCT_SD.SalesOrder
																			and SCT_CSDM.SalesOrderInitLine = SCT_SD.SalesOrderInitLine
				left join SysproCompany100.dbo.MdnMaster SCT_MM on SCT_MM.SalesOrder = SCT_SM.SalesOrder
															   and SCT_MM.DispatchNoteStatus IN ('3','5','7')
				LEFT JOIN SysproCompany100.dbo.MdnDetail SCT_MD on SCT_MD.DispatchNote = SCT_MM.DispatchNote
															   and SCT_MD.SalesOrder = SCT_SD.SalesOrder
															   and SCT_MD.SalesOrderLine = SCT_SD.SalesOrderLine
				LEFT JOIN SysproCompany100.dbo.GtrDetail SCT_GD on SCT_GD.SalesOrder = SCT_SD.SalesOrder
															   and SCT_GD.SalesOrderLine = SCT_SD.SalesOrderLine
															   and SCT_GD.TransferComplete <> 'Y'
			WHERE SD.MBackOrderQty >0
			  AND SM.OrderStatus IN ('1','2','3','4','S','8')
			  AND SD.MReviewFlag = 'S';
		
		Begin Transaction;

			update CSDM
				set  CSDM.[AllocationDate] = SCTA.AllocationDate
					,CSDM.[AllocationRef] = SCTA.AllocationRef
					,CSDM.[AllocationRefVal1] = SCTA.AllocationRefVal1
					,CSDM.[AllocationRefVal2] = SCTA.AllocationRefVal2
					,CSDM.[AllocationSupType] = SCTA.AllocationSupType
			from [SysproCompany100].[dbo].[CusSorDetailMerch+] as CSDM
				inner join @SCT_Allocation as SCTA on SCTA.SalesOrder = CSDM.SalesOrder
												  and SCTA.SalesOrderInitLine = CSDM.SalesOrderInitLine
												  and CSDM.InvoiceNumber = @Blank
			where SCTA.AllocationDate > isnull(CSDM.AllocationDate, @NullDate)
		
			insert into SysproCompany100.dbo.[CusSorDetailMerch+] (
																	[SalesOrder], 
																	[SalesOrderInitLine], 
																	[InvoiceNumber], 
																	[AllocationDate], 
																	[AllocationRef], 
																	[AllocationRefVal1], 
																	[AllocationRefVal2], 
																	[AllocationSupType]	)
				Select
					 a.[SalesOrder]			
					,a.[SalesOrderInitLine]	
					,@Blank
					,a.[AllocationDate]		
					,a.[AllocationRef]		
					,a.[AllocationRefVal1]	
					,a.[AllocationRefVal2]	
					,a.[AllocationSupType]
				from @SCT_Allocation as a
					left join SysproCompany100.dbo.[CusSorDetailMerch+] as CSDM on CSDM.SalesOrder = a.SalesOrder
																			   and CSDM.SalesOrderInitLine = a.SalesOrderInitLine
																			   and CSDM.InvoiceNumber = @Blank
				where CSDM.SalesOrderInitLine is null;

		Commit Transaction;

		return 0;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
		BEGIN

			ROLLBACK TRANSACTION;

		END;

		SELECT ERROR_NUMBER()    AS [ErrorNumber]
			  ,ERROR_SEVERITY()  AS [ErrorSeverity]
			  ,ERROR_STATE()     AS [ErrorState]
			  ,ERROR_PROCEDURE() AS [ErrorProcedure]
			  ,ERROR_LINE()      AS [ErrorLine]
			  ,ERROR_MESSAGE()   AS [ErrorMessage];

		THROW;

		RETURN 1;

	END CATCH;
end
go