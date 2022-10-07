USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[QCommissions WritetoFile]    Script Date: 10/5/2022 10:35:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
 Author:		Michael Barber
 Create date:	3/14/2022
 Ticket 27737
=============================================
 Modifier:		Michael Barber
 Description:	Create CSV to send to QCommissions
 Modify Date:	6/2/2022
 Ticket 30211

 Add additional file per request David S
=============================================
 Modifier:		Justin Pope
 Modified Date:	2022/10/05
 Ticket 32811

 Addintional Files
 Standardizing Procedure
=============================================
EXEC [dbo].[QCommissions WritetoFile]
=============================================
*/
ALTER     PROCEDURE [dbo].[QCommissions WritetoFile]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY

	
	DECLARE @cmd VARCHAR(500)

		DROP TABLE IF EXISTS ##tempQCommissions
		
		select 
			* 
		into ##tempQCommissions
		from [PRODUCT_INFO].[dbo].[tvf_QCommissions_Wholesale]()


		IF EXISTS (Select 1 from ##tempQCommissions)
		BEGIN
				EXECUTE master.sys.xp_cmdshell 'sqlcmd -s, -W -Q "set nocount on; select * from ##tempQCommissions" | findstr /v /c:"-" /b > "\\sql08\SSIS\Data\Live\QCommissions\GW_Commissions_Wholesale-SCPL.csv""'
		END


		DROP TABLE IF EXISTS ##GW_Commissions_SCCS


	select 
		* 
	into ##GW_Commissions_SCCS 
	from [dbo].[tvf_QCommissions_Commission]()
	
	IF EXISTS (Select 1 from ##GW_Commissions_SCCS)
		BEGIN
				EXECUTE master.sys.xp_cmdshell 'sqlcmd -s, -W -Q "set nocount on; select * from ##GW_Commissions_SCCS" | findstr /v /c:"-" /b > "\\sql08\SSIS\Data\Live\QCommissions\GW_Commissions_SCCS.csv""'
		END

	if (datediff(DAY, '2022-7-5', GETDATE()) % 14) = 0
	begin



	end

	DROP TABLE IF EXISTS ##tempQCommissions
	DROP TABLE IF EXISTS ##GW_Commissions_SCCS

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE @ErrMsg NVARCHAR(4000)
			,@ErrSeverity INT;

		SELECT @ErrMsg = ERROR_MESSAGE()
			,@ErrSeverity = ERROR_SEVERITY();

		RAISERROR (
				@ErrMsg
				,@ErrSeverity
				,1
				);
	END CATCH;

	RETURN @@ERROR;
END;
