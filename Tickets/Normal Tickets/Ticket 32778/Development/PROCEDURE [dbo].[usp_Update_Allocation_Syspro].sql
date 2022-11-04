USE [SalesOrderAllocation100]
GO
/****** Object:  StoredProcedure [dbo].[usp_Update_Allocation_Syspro]    Script Date: 11/3/2022 2:57:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Created by:  Chris Nelson
Create date: 
Modified by: Chris Nelson
Modify date: Tuesday, October 31st, 2017
Description: Update Sales Order Allocation 
			 for Company 100 - New Version
=============================================
Modifier: Justin Pope
Modified Date: Friday, November 4th, 2022
Description: Allocating the top Allocation 
		     date to the parent kit item
			 from children items
=============================================

Test Case:
EXECUTE dbo.usp_Update_Allocation_Syspro;
=============================================
*/

ALTER PROCEDURE [dbo].[usp_Update_Allocation_Syspro]
AS
SET XACT_ABORT ON
BEGIN

	SET NOCOUNT ON;

	DECLARE @Blank           AS VARCHAR(1) = ''
		   ,@Full            AS VARCHAR(4) = 'Full'
		   ,@None            AS VARCHAR(6) = '(none)'
		   ,@Partial         AS VARCHAR(7) = 'Partial'
		   ,@PlaceholderDate AS DATE       = '2525-12-31'
		   ,@Seperator       AS VARCHAR(3) = ' : ';

	BEGIN TRY

		DECLARE @Allocation AS TABLE (
			 [SalesOrder]         VARCHAR(20)
			,[SalesOrderLine]     INTEGER
			,[SalesOrderInitLine] INTEGER
			,[SupplyType]         VARCHAR(15)
			,[ReferenceType]      VARCHAR(6)
			,[ReferenceValue1]    VARCHAR(30)
			,[ReferenceValue2]    VARCHAR(30)
			,[ReferenceText]      VARCHAR(100)
			,[SupplyDate]         DATE
			,PRIMARY KEY ( 
				 [SalesOrder]
				,[SalesOrderLine]
				,[SalesOrderInitLine]
			)
		);

		WITH LastAllocation AS (
								SELECT 
									 [SalesOrder]           AS [SalesOrder]
									,[SalesOrderLine]       AS [SalesOrderLine]
									,[SalesOrderInitLine]   AS [SalesOrderInitLine]
									,MAX([AllocationRowId]) AS [AllocationRowId]
								FROM dbo.Allocation
								GROUP BY 
									 [SalesOrder]
									,[SalesOrderLine]
									,[SalesOrderInitLine]),
			AllocationType AS (
								SELECT 
									 Allocation.[SalesOrder]            AS [SalesOrder]
									,Allocation.[SalesOrderLine]        AS [SalesOrderLine]
									,Allocation.[SalesOrderInitLine]    AS [SalesOrderInitLine]
									,Allocation.[SupplyType]            AS [SupplyType]
									,Allocation.[ReferenceType]         AS [ReferenceType]
									,Allocation.[ReferenceValue1]       AS [ReferenceValue1]
									,Allocation.[ReferenceValue2]       AS [ReferenceValue2]
									,Allocation.[SupplyDate]            AS [SupplyDate]
									,IIF( Allocation.[NewDemandQty] = 0
										 ,@Full,@Partial)               AS [AllocationType]
								FROM dbo.Allocation
									INNER JOIN LastAllocation ON Allocation.[AllocationRowId] = LastAllocation.[AllocationRowId])
		INSERT INTO @Allocation (
								  [SalesOrder]
								 ,[SalesOrderLine]
								 ,[SalesOrderInitLine]
								 ,[SupplyType]
								 ,[ReferenceType]
								 ,[ReferenceValue1]
								 ,[ReferenceValue2]
								 ,[ReferenceText]
								 ,[SupplyDate])
			SELECT 
				 [SalesOrder]                           AS [SalesOrder]
				,[SalesOrderLine]                       AS [SalesOrderLine]
				,[SalesOrderInitLine]                   AS [SalesOrderInitLine]
				,[SupplyType]                           AS [SupplyType]
				,[ReferenceType]                        AS [ReferenceType]
				,[ReferenceValue1]                      AS [ReferenceValue1]
				,[ReferenceValue2]                      AS [ReferenceValue2]
				,[ReferenceValue1] + 
				IIF([ReferenceValue2] = @None, @Blank, 
					@Seperator + [ReferenceValue2])		AS [ReferenceText]
				,NULLIF([SupplyDate], @PlaceholderDate) AS [SupplyDate]
			FROM AllocationType
			WHERE [AllocationType] = @Full
			UNION
			SELECT 
				 [SalesOrder]         AS [SalesOrder]
				,[SalesOrderLine]     AS [SalesOrderLine]
				,[SalesOrderInitLine] AS [SalesOrderInitLine]
				,@None                AS [SupplyType]
				,@None                AS [ReferenceType]
				,@None                AS [ReferenceValue1]
				,@None                AS [ReferenceValue2]
				,@None                AS [ReferenceText]
				,NULL                 AS [SupplyDate]
			FROM AllocationType
			WHERE [AllocationType] = @Partial;

		BEGIN TRANSACTION;

			update CSDM
				set [AllocationDate] = NULL,
					[AllocationRef] = NULL,
					[AllocationRefVal1] = NULL,
					[AllocationRefVal2] = NULL,
					[AllocationSupType] = NULL,
					[AllocationType] = NULL
			from SysproCompany100.dbo.[CusSorDetailMerch+] as CSDM
			WHERE [InvoiceNumber] = ''
				AND ([AllocationType] IS NOT NULL or
					 [AllocationSupType] IS NOT NULL or
					 [AllocationRefVal2] IS NOT NULL or
					 [AllocationRefVal1] IS NOT NULL or
					 [AllocationRef] IS NOT NULL or
					 [AllocationDate] IS NOT NULL);

			UPDATE [CusSorDetailMerch+]
				SET [CusSorDetailMerch+].[AllocationSupType] = Allocation.[SupplyType]
				   ,[CusSorDetailMerch+].[AllocationType] = Allocation.[ReferenceType]
				   ,[CusSorDetailMerch+].[AllocationRefVal1] = Allocation.[ReferenceValue1]
				   ,[CusSorDetailMerch+].[AllocationRefVal2] = Allocation.[ReferenceValue2]
				   ,[CusSorDetailMerch+].[AllocationRef] = Allocation.[ReferenceText]
				   ,[CusSorDetailMerch+].[AllocationDate] = Allocation.[SupplyDate]
			FROM @Allocation AS Allocation
				INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] ON [CusSorDetailMerch+].[SalesOrder] = Allocation.[SalesOrder]
																	AND [CusSorDetailMerch+].[SalesOrderInitLine] = Allocation.[SalesOrderInitLine]
																	AND [CusSorDetailMerch+].[InvoiceNumber] = @Blank;

			INSERT INTO SysproCompany100.dbo.[CusSorDetailMerch+] (
																	 [SalesOrder]
																	,[SalesOrderInitLine]
																	,[InvoiceNumber]
																	,[AllocationSupType]
																	,[AllocationType]
																	,[AllocationRefVal1]
																	,[AllocationRefVal2]
																	,[AllocationRef]
																	,[AllocationDate])
			SELECT 
				 Allocation.[SalesOrder]         AS [SalesOrder]
				,Allocation.[SalesOrderInitLine] AS [SalesOrderInitLine]
				,@Blank                          AS [InvoiceNumber]
				,Allocation.[SupplyType]         AS [AllocationSupType]
				,Allocation.[ReferenceType]      AS [AllocationType]
				,Allocation.[ReferenceValue1]    AS [AllocationRefVal1]
				,Allocation.[ReferenceValue2]    AS [AllocationRefVal2]
				,Allocation.[ReferenceText]      AS [AllocationRef]
				,Allocation.[SupplyDate]         AS [AllocationDate]
			FROM @Allocation AS Allocation
				LEFT OUTER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] ON [CusSorDetailMerch+].[SalesOrder] = Allocation.[SalesOrder]
																		 AND [CusSorDetailMerch+].[SalesOrderInitLine] = Allocation.[SalesOrderInitLine]
																		 AND [CusSorDetailMerch+].[InvoiceNumber] = @Blank
			WHERE [CusSorDetailMerch+].[SalesOrderInitLine] IS NULL;
			
		COMMIT TRANSACTION;

		/*
			We are going to roll up the latest Allocation date to the kit parent for kit items
		*/

		declare @ParentAllocation table (
			 [SalesOrder]         VARCHAR(20)
			,[SalesOrderLine]     INTEGER
			,[SalesOrderInitLine] INTEGER
			,[AllocationDate]     DATE
			,PRIMARY KEY ( 
				 [SalesOrder]
				,[SalesOrderLine]
				,[SalesOrderInitLine]
			)
		)

		insert into @ParentAllocation
			select
				SM.SalesOrder,
				pSD.SalesOrderLine,
				pSD.SalesOrderInitLine,
				max(isnull(cCSD.AllocationDate, @PlaceholderDate)) as [AllocationDate]
			from SysproCompany100.dbo.SorMaster as SM
				inner join SysproCompany100.dbo.SorDetail as cSD on cSD.SalesOrder = SM.SalesOrder
																and cSD.LineType = 1
																and cSD.MBomFlag = 'C'
																AND cSD.MBackOrderQty > 0
				inner join SysproCompany100.dbo.[CusSorDetailMerch+] as cCSD on cCSD.SalesOrder = cSD.SalesOrder
																			and cCSD.SalesOrderInitLine = cSD.SalesOrderInitLine
																			and cCSD.InvoiceNumber = ''
				cross apply (
								Select
									max(pSD.SalesOrderLine) as SalesOrderLine
								from SysproCompany100.dbo.SorDetail as pSD
								where pSD.SalesOrder = SM.SalesOrder
									and pSD.MBomFlag = 'P'
									and pSD.SalesOrderLine < cSD.SalesOrderLine
								) as tSD
				inner join SysproCompany100.dbo.[SorDetail] as pSD on pSD.SalesOrder = cSD.SalesOrder
																and pSD.SalesOrderLine = tSD.SalesOrderLine
			WHERE SM.OrderStatus IN ('S','1','2','3','4','8','0')
				AND SM.DocumentType = 'O'
			group by SM.SalesOrder, pSD.SalesOrderLine, pSD.SalesOrderInitLine

		begin transaction

			UPDATE [CusSorDetailMerch+]
				SET [CusSorDetailMerch+].[AllocationDate] = iif(Allocation.AllocationDate = @PlaceholderDate, null, Allocation.AllocationDate)
			FROM @ParentAllocation AS Allocation
				INNER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] ON [CusSorDetailMerch+].[SalesOrder] = Allocation.[SalesOrder]
																	AND [CusSorDetailMerch+].[SalesOrderInitLine] = Allocation.[SalesOrderInitLine]
																	AND [CusSorDetailMerch+].[InvoiceNumber] = @Blank

			INSERT INTO SysproCompany100.dbo.[CusSorDetailMerch+] (
																	 [SalesOrder]
																	,[SalesOrderInitLine]
																	,[InvoiceNumber]
																	,[AllocationDate])
			SELECT 
				 Allocation.[SalesOrder]															AS [SalesOrder]
				,Allocation.[SalesOrderInitLine]													AS [SalesOrderInitLine]
				,@Blank																				AS [InvoiceNumber]
				,iif(Allocation.AllocationDate = @PlaceholderDate, null, Allocation.AllocationDate) AS [AllocationDate]
			FROM @ParentAllocation AS Allocation
				LEFT OUTER JOIN SysproCompany100.dbo.[CusSorDetailMerch+] ON [CusSorDetailMerch+].[SalesOrder] = Allocation.[SalesOrder]
																		 AND [CusSorDetailMerch+].[SalesOrderInitLine] = Allocation.[SalesOrderInitLine]
																		 AND [CusSorDetailMerch+].[InvoiceNumber] = @Blank
			WHERE [CusSorDetailMerch+].[SalesOrderInitLine] IS NULL;

		commit transaction

		RETURN 0;

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

END;