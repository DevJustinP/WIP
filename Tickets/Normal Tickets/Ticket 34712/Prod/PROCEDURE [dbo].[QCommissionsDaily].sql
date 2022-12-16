USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[QCommissionsDaily]    Script Date: 12/16/2022 2:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
 Modifier:		Justin Pope
 Modified Date:	2022/10/05
 Ticket 32811

 Addintional Files
 Standardizing Procedure [dbo].[QCommissions WritetoFile]
=============================================
EXEC [dbo].[QCommissionsDaily]
=============================================
*/
ALTER PROCEDURE [dbo].[QCommissionsDaily]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY

	declare @Directory as varchar(500),
			@ArciveLocation as varchar(500),
			@ContractCommissionFile as varchar(500),
			@WholesaleCommissionFile as varchar(500),
			@WinSCP_Settings as varchar(500)

	select
		@Directory = Directory,
		@ArciveLocation = ArchiveLocation,
		@ContractCommissionFile = ContractCommissionFile,
		@WholesaleCommissionFile = WholesaleCommissionFile,
		@WinSCP_Settings = WinSCP_Name
	from [dbo].[QCommissions_Constant]

	DECLARE @cmd VARCHAR(500),
			@const_command varchar(500) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "<filepath>"',
			@replacefilepath_str varchar(20) = '<filepath>',
			@replacetable_str varchar(20) = '<table>',
			@filepath varchar(100)
					
		select 
			* 
		into ##tempQCommissions
		from [PRODUCT_INFO].[dbo].[tvf_QCommissions_Wholesale]()

		IF EXISTS (Select 1 from ##tempQCommissions)
			BEGIN
				set @filepath = @Directory + @WholesaleCommissionFile 
				set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
				set @cmd = REplace(@cmd, @replacetable_str, '##tempQCommissions')
				print @cmd
				EXECUTE master.sys.xp_cmdshell @cmd
				execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, '/GAW/Wholesale/', @ArciveLocation
			END

	select 
		* 
	into ##GW_Commissions_SCCS 
	from [dbo].[tvf_QCommissions_Commission]()
	select * from ##GW_Commissions_SCCS
	
	IF EXISTS (Select 1 from ##GW_Commissions_SCCS)
		BEGIN
			set @filepath = @Directory + @ContractCommissionFile
			set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
			set @cmd = REplace(@cmd, @replacetable_str, '##GW_Commissions_SCCS')
			print @cmd
			EXECUTE master.sys.xp_cmdshell @cmd
			execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, '/GAW/Contract/', @ArciveLocation
		END


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
