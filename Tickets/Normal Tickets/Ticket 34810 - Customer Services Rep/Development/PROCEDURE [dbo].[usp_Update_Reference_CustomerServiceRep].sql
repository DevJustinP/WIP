USE [PRODUCT_INFO]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
==================================================================
	Created By:		?
	Create Date:	?
	Purpose:		This procedure uses the power shell script
					Update_Reference_CustomerServiceRep.ps1 to
					populate CustomerServiceRep with members of
					Customer Service groups exstablished in 
					Active Directory
==================================================================\
	Modifier:		Justin Pope
	Modified Date:	2023 - 05 - 05
	Description:	Updated procedure to look at the Sysprodb7
					AdmOperator table to populate the table
==================================================================
Test:
	execute [dbo].[usp_Update_Reference_CustomerServiceRep]
==================================================================
*/
Create or Alter PROCEDURE [dbo].[usp_Update_Reference_CustomerServiceRep]
AS
SET XACT_ABORT ON
BEGIN

  SET NOCOUNT ON;

  BEGIN TRY

    BEGIN TRANSACTION;

      With CustomerReps as (
							select
								o.[Name],
								o.[Email]
							from [Sysprodb7].[dbo].[AdmOperator] o
								inner join [SysproCompany100].[dbo].[AdmOperator+] as op on op.Operator = o.Operator
							where op.IncludeInCsrList = 'Y' )

	merge into PRODUCT_INFO.dbo.CustomerServiceRep R
	using CustomerReps T on T.[Name] = R.[CustomerServiceRep]
	when Matched then
		update set [EmailAddress] = T.[Email]
	when not matched by TARGET then
		insert ([CustomerServiceRep],[EmailAddress])
		values (T.[Name],T.[Email])
	when not matched by SOURCE then
		delete;

    COMMIT TRANSACTION;

  END TRY

  BEGIN CATCH

    ROLLBACK TRANSACTION;

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
go