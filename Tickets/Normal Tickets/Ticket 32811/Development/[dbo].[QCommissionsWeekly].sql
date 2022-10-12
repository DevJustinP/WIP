USE [PRODUCT_INFO]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
 Modifier:		Justin Pope
 Modified Date:	2022/10/07
 Ticket 32811

 Addintional Files for the QCommissions
 transmission
=============================================
EXEC [PRODUCT_INFO].[dbo].[QCommissionsWeekly]
=============================================
*/
alter PROCEDURE [dbo].[QCommissionsWeekly]
AS
SET XACT_ABORT ON

BEGIN
	BEGIN TRY
	
		declare @Directory as varchar(500),
				@ArciveLocation as varchar(500),
				@UnitersCommissionFile as varchar(500),
				@WrittenSalesCommissionFile as varchar(500),
				@WinSCP_Settings as varchar(500)

		select
			@Directory = Directory,
			@ArciveLocation = ArchiveLocation,
			@UnitersCommissionFile = UnitersCommissionFile,
			@WrittenSalesCommissionFile = WrittenSalesCommissionFile,
			@WinSCP_Settings = WinSCP_Name
		from [dbo].[QCommissions_Constant]

		DECLARE @cmd VARCHAR(500),
				@const_command varchar(500) = 'sqlcmd -s, -W -Q "set nocount on; select * from <table>" | findstr /v /c:"-" /b > "<filepath>"',
				@replacefilepath_str varchar(20) = '<filepath>',
				@replacetable_str varchar(20) = '<table>',
				@filepath varchar(100)

		select
			*
		into ##QCommissions_Uniters
		from [dbo].[tvf_QCommissions_UnitersPlanSales]()
	
		IF EXISTS (Select 1 from ##QCommissions_Uniters)
			BEGIN
				set @filepath = @Directory + @UnitersCommissionFile
				set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
				set @cmd = REplace(@cmd, @replacetable_str, '##QCommissions_Uniters')
				print @cmd
				EXECUTE master.sys.xp_cmdshell @cmd
				execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Retail/', @ArciveLocation
			END

		select
			*
		into ##QCommissions_WrittenSales
		from [dbo].[tvf_QCommissions_WrittenSales]()
	
		IF EXISTS (Select 1 from ##QCommissions_Uniters)
			BEGIN
				set @filepath = @Directory + @UnitersCommissionFile
				set @cmd = REPLACE(@const_command, @replacefilepath_str, @filepath)
				set @cmd = REplace(@cmd, @replacetable_str, '##QCommissions_WrittenSales')
				print @cmd
				EXECUTE master.sys.xp_cmdshell @cmd
				execute [Global].[dbo].[WINSCP_SendFile] @filepath, @WinSCP_Settings, 'Retail/', @ArciveLocation
			END

		
		DROP TABLE IF EXISTS ##QCommissions_Uniters
		DROP TABLE IF EXISTS ##QCommissions_WrittenSales
	
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
END