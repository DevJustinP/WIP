declare @Mail_ID varchar(50) = 'Accounting.WellsFargo.BuildFile',
		@Mail_SubCode varchar(50) = 'Missing Cheque',
		@Mail_Type varchar(25) = 'Information',
		@SendNotification bit = 1,
		@ToEmailAddresses varchar(max) = 'LeslieE@summerclassics.com; sheilah@summerclassics.com;',
		@BCCEmailAddresses varchar(max) = 'Softwaredeveloper@summerclassics.com';

insert into [Global].[Settings].EmailHeader ([Mail_ID],[Mail_SubCode],[Mail_Type],[SendNotification],[ToEmailAddresses],[BCCEmailAddresses])
values (@Mail_ID, @Mail_SubCode, @Mail_Type, @SendNotification, @ToEmailAddresses, @BCCEmailAddresses);

declare @Mail_Subject varchar(255) = 'CHEQUE NUMBERS MISSING',
		@Mail_body nvarchar(max) = 
'This is an automated email sent to inform that cheque numbers are missing in the table. Therefore the WF job did not process any data.',
		@Mail_body_format varchar(20) = 'TEXT',
		@Importance varchar(6) = 'HIGH';
insert into [Global].[Settings].EmailMessage([Mail_ID],[Mail_SubCode],[Mail_Type],[mail_subject],[mail_body],[mail_body_format], [mail_importance])
values(@Mail_id,@Mail_SubCode, @Mail_Type, @Mail_Subject, @Mail_body, @Mail_body_format, @Importance)

select * from [Global].[Settings].EmailHeader
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

select * from [Global].[Settings].EmailMessage
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

set @Mail_ID = 'PRODUCT_INFO.dbo.Uniters_ErrorEmail';
set @Mail_SubCode = 'API Error Response';
set @Mail_Type = 'Information';
set @SendNotification = 1;
set @ToEmailAddresses = 'StoreSupport@Summerclassics.com';
set @BCCEmailAddresses = 'Softwaredeveloper@summerclassics.com';

insert into [Global].[Settings].EmailHeader ([Mail_ID],[Mail_SubCode],[Mail_Type],[SendNotification],[ToEmailAddresses],[BCCEmailAddresses])
values (@Mail_ID, @Mail_SubCode, @Mail_Type, @SendNotification, @ToEmailAddresses, @BCCEmailAddresses);

set @Mail_Subject = 'Uniters Failed to send the following policies';
set @Mail_body = 
'<style>
table {
  width: 100%;
  background-color: #ffffff;
  border-collapse: collapse;
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  color: #000000;
}

table td, table th {
  border-width: 2px;
  border-color: #ffcc00;
  border-style: solid;
  padding: 3px;
}

table thead {
  background-color: #ffcc00;
}
</style>

<table>
  <thead>
    <tr>
      <th>SalesOrder</th>
      <th>PolicyType</th>
	  <th>ResponseText</th>
      </tr>
  </thead>
  <tbody></tbody>
</table>';
set @Mail_body_format = 'HTML';
insert into [Global].[Settings].EmailMessage([Mail_ID],[Mail_SubCode],[Mail_Type],[mail_subject],[mail_body],[mail_body_format])
values(@Mail_id,@Mail_SubCode, @Mail_Type, @Mail_Subject, @Mail_body, @Mail_body_format)

select * from [Global].[Settings].EmailHeader
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

select * from [Global].[Settings].EmailMessage
where Mail_ID = @Mail_ID and Mail_SubCode = @Mail_SubCode and Mail_Type = @Mail_Type

USE [Accounting]
GO
/****** Object:  StoredProcedure [WellsFargo].[BuildFile]    Script Date: 9/29/2022 8:28:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 =============================================
 Author:		Michael Barber
 Create date: 9/01/2020
 Description:	Create Pipe Delimited text to send to WellsFargo

CCR: 	CCR Commercial Card—CCER AP Control
CHK: 	CHK Next Day Check
DAC: 	DAC Domestic ACH transaction
IWI:	IWI Foreign currency wire
MTS: 	MTS USD wire
 =============================================
Modify date
Modify comment: ApsubP.ManualRemit added for Checks Rerouted 1/27/2021
If ApsubP.ManualRemit = 'Y' then several fields on the CK Supplemental check record will be changed
 =============================================
Modify Date 07/19/2021 
Comment: WIRES GO LIVE
 =============================================
Modifier Name:	Justin Pope
Modified Date:	2022-09-29
SDM Ticket:		31462
Comment:		Adding Error Email to email
				system
=============================================

EXECUTE [WellsFargo].[BuildFile]
 =============================================
 */
ALTER PROCEDURE [WellsFargo].[BuildFile]
AS
SET XACT_ABORT ON;

BEGIN
	BEGIN TRY
		--We will populate each WellsFargo table with the data from the SQL tables .
		--TRUNCATE ALL TABLES 
		TRUNCATE TABLE [WellsFargo].[WF_AC];

		TRUNCATE TABLE [WellsFargo].[WF_CC];

		TRUNCATE TABLE [WellsFargo].[WF_CK];

		TRUNCATE TABLE [WellsFargo].[WF_DD];

		TRUNCATE TABLE [WellsFargo].[WF_Header];

		TRUNCATE TABLE [WellsFargo].[WF_IN];

		TRUNCATE TABLE [WellsFargo].[WF_PAB];

		TRUNCATE TABLE [WellsFargo].[WF_PAO];

		TRUNCATE TABLE [WellsFargo].[WF_PAR];

		TRUNCATE TABLE [WellsFargo].[WF_PY];

		TRUNCATE TABLE [WellsFargo].[WF_TR];

		TRUNCATE TABLE [WellsFargo].[WF_WR];

		TRUNCATE TABLE [WellsFargo].[WF_FILE];
		--Additional Check added to ensure cheque numbers are in the tables before processing.

	

IF EXISTS(Select ([Cheque]) FROM [SysproCompany100].[dbo].ApPayRunDet ApCheck
		INNER JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		INNER JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
		WHERE ApCheck.PaymentType IN ('M','R')
			AND Usr_AutoPmtSent = 0
			AND ApsubP.PaymentType <> '(none)'
			AND ApCheck.Bank = '100-WFPM'
		    AND (LEN([Cheque]) = 0 or [Cheque] IS NULL)
			)
BEGIN
	EXEC [Global].[Settings].[usp_send_email] 'Accounting.WellsFargo.BuildFile', 'Missing Cheque', 'Information'

   RETURN
END

BEGIN TRANSACTION


		--Starting with the PY table - This is our master and the key in this table will link to all the others.
		--Create Master List - This will be used as the base table for all queries except the INV.
		SELECT ROW_NUMBER() OVER(ORDER BY Cheque DESC) as PK 
		    ,ApCheck.PaymentNumber
			,ApCheck.Bank
			,ApCheck.Supplier
			,ApCheck.Cheque
			,ApsubP.PaymentType
			,ApsubP.ManualRemit
			,SUM(NetPayValue) NetPayValue
		INTO #APCHECK
		FROM [SysproCompany100].[dbo].ApPayRunDet ApCheck
		INNER JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		INNER JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
		WHERE ApCheck.PaymentType IN ('M','R')
			AND Usr_AutoPmtSent = 0
			AND ApsubP.PaymentType <> '(none)'
			AND ApCheck.Bank = '100-WFPM'
		GROUP BY ApCheck.PaymentNumber
			,ApCheck.Bank
			,ApCheck.Supplier
			,ApCheck.Cheque
			,ApsubP.PaymentType,
			ApsubP.ManualRemit;

		
INSERT INTO [WellsFargo].[WF_PY] (
		   [PY_PK_ID]
			,[Record_ID]
			,[Payment_Method]
			,[Credit_Debit]
			,[TransNumber]
			,[VDate]
			,[EDate]
			,[PDate]
			,[PayAmount]
			,[Currency]
			,[Origin_Acc_Type]
			,[Origin_Acc]
			,[Origin_Acc_Currency]
			,[Origin_BankID_Type]
			,[Origin_BankID]
			,[RecPartyAccType]
			,[RecPartyAcc]
			,[RecAcc_Currency]
			,[RecBankPrimIDType]
			,[RecBankPrimID]
			,[RecBankSecondID]
			,[EDD_Code]
			,[PDP_Hand_Code]
			,[EDD_Bill_ID]
			,[Invoice_Manager_Flag]
			,[CEO_Company_ID]
			,[OriginParty_Rec_Party_Info]
			,[Exchange_Rate]
			,[Consumer_Payment]
			,[Filler]
			,[Pay_Purpose_Code]
			,[Pay_Purpose_Desc]
			,[End_End_ID]
			,[Cheque]
			)
		SELECT
		   ApCheck.PK 
		    ,'PY' AS record_ID
			,'Payment_Method' = ApsubP.PaymentType
			,'Credit_Debit' = 'C'
			,'TransNumber' = RIGHT(ApCheck.PaymentNumber, 6) + LEFT(ApCheck.Bank, 3) + RIGHT(ApCheck.Cheque, 6)
			,
			/*
ApCheck.[ChequeDate] as  'Value date',                  --this needs to be change before go-live
''  as 'Effective Date',                                --this needs to be change before go-live
'' as 'Process Date',                                   --this needs to be change before go-live
*/
			'Value date' = GETDATE()
			,--this needs to be change before go-live
			'Effective Date' = GETDATE()
			,--this needs to be change before go-live
			'Process Date' = GETDATE()
			,--this needs to be change before go-live
			'Payment Amount' = ApCheck.NetPayValue
			,'Currency' = (
				CASE 
					WHEN ApsubP.PaymentType = 'IWI'
						THEN --------10/6/2020 BEFORE IWI GO LIVE WE NEED TO CHANGE THIS
							'CAD'
					ELSE 'USD'
					END
				)
			,'Originating Account Type' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN 'D'
					WHEN ApsubP.PaymentType = 'MTS'
						THEN 'D'
					ELSE ''
					END
				)
			,'Originating Account' = '4122030885'
			,'Originating Account Currency' = (
				CASE 
					WHEN ApsubP.PaymentType = 'IWI'
						THEN 'USD'
					ELSE ''
					END
				)
			,'Originating Bank ID Type' = (
				CASE 
					WHEN ApsubP.PaymentType = 'IWI'
						THEN 'ABA'
					ELSE 'ABA'
					END
				)
			,'Originating Bank ID' = '121000248'
			,'Receiving Party Account Type' = (
				CASE 
					WHEN ApsubP.PaymentType = 'CHK'
						OR ApsubP.PaymentType = 'CCR'
						THEN ''
					ELSE 'D'
					END
				)
			,'Receiving Party Account' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN ''
					ELSE RTRIM(LTRIM(Apsub.BankAccount))
					END
				)
			,'Receiving Account Currency' = (
				CASE 
					WHEN ApsubP.PaymentType = 'IWI'
						THEN 'USD'
					ELSE ''
					END
				)
			,'Receiving Bank Primary ID Type' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN 'ABA'
					WHEN ApsubP.PaymentType = 'IWI'
						THEN 'SWT'
					WHEN ApsubP.PaymentType = 'CCR'
						THEN ''
					WHEN ApsubP.PaymentType = 'CHK'
						THEN ''
					ELSE 'ABA'
					END
				)
			,'Receiving Bank Primary ID' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN '' --ApCheck.Supplier
					WHEN ApsubP.PaymentType = 'CCR'
						THEN ''
					WHEN ApsubP.PaymentType = 'CHK'
						THEN ''
					ELSE 'ABA'
					END
				)
			,'' AS 'Receiving Bank Secondary ID'
			,'EDD Handling Code' = (
				CASE 
					WHEN ApsubP.PaymentType = 'PMP'
						THEN 'U'
					ELSE ''
					END
				)
			,'PDP Handling Code' = (
				CASE 
					WHEN ApsubP.PaymentType = 'IWI'
						OR ApsubP.PaymentType = 'MTS'
						THEN 'P'
					WHEN ApsubP.PaymentType = 'CHK'
						THEN ''
					ELSE 'T'
					END
				)
			,'EDD Biller ID' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN ''
					ELSE '10000SMMR'
					END
				)
			,'' AS 'Invoice Manager Flag'
			,'CEO Company ID' = 'SCI979'
			,'Originating Party to Receiving Party Info' = (
				CASE 
					WHEN ApsubP.PaymentType = 'CCR'
						THEN Apsub.Supplier
					ELSE ''
					END
				)
			,'Exchange Rate' = IIF(ApsubP.PaymentType = 'IWI', '90', '')
			,------FIX BELFOREE ZGO-LIVE with IWI 10/5/2020
			'Consumer Payment Indicator' = ''
			,'Filler' = ''
			,'Payment Purpose Code' = ''
			,'Payment Purpose Description' = ''
			,'End to End Identifier' = ''
			,ApCheck.Cheque
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
	

		INSERT INTO [WellsFargo].[WF_PAO] (
		   [FPY_ID]
			,[Record_ID]
			,[Address_Ind]
			,[PA_Name]
			,[Add_name]
			,[ID_Number]
			,[Address_L1]
			,[Address_L2]
			,[Address_L3]
			,[City]
			,[State_Prov]
			,[Postal_Code]
			,[Country_Code]
			,[Country_Name]
			,[Email_Address]
			,[Phone]
			,[Phone_int_code]
			)
		SELECT  
			 ApCheck.PK AS 'FPY_ID'
			,'PA' AS 'Record ID'
			,'PR' AS 'Address Indicator'
			,'Summer Classics' AS 'Name'
			,'' AS 'Additional Name'
			,'' AS 'Identification Number'
			,'3140 Pelham Pkwy ' AS 'Address Line 1'
			,'' AS 'Address Line 2'
			,'' AS 'Address Line 3'
			,'Pelham' AS 'City'
			,'AL' AS 'State / Province'
			,'35124' AS 'Postal Code'
			,'US' AS 'Country Code'
			,'United States' AS 'Country Name'
			,'Ap@SummerClassics.com' AS 'Email Address'
			,'2053589400' AS 'Phone Number'
			,'1' AS 'Phone international access code'
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
	

		INSERT INTO [WellsFargo].[WF_PAR] (
			[FPY_ID]
			,[Record_ID]
			,[Address_Ind]
			,[PA_Name]
			,[Add_name]
			,[ID_Number]
			,[Address_L1]
			,[Address_L2]
			,[Address_L3]
			,[City]
			,[State_Prov]
			,[Postal_Code]
			,[Country_Code]
			,[Country_Name]
			,[Email_Address]
			,[Phone]
			,[Phone_int_code]
			)
		SELECT ApCheck.PK AS 'FPY_ID'
			,'PA' AS 'RECORD ID'
			,'PE' AS 'Address Indicator'
			,Apsub.[SupplierName] AS 'PA Name'
			,'' AS 'Additional Name'
			,Apsub.Supplier AS 'Identification Number'
			,'Address Line 1' = (
				CASE 
					WHEN ApsubP.PaymentType = 'CHK'
						OR ApsubP.PaymentType = 'CCR'
						THEN ApsubA.RemitAddr1
					ELSE ''
					END
				)
			,'Address Line 2' = (
				CASE 
					WHEN ApsubP.PaymentType = 'CHK'
						OR ApsubP.PaymentType = 'CCR'
						THEN ApsubA.RemitAddr2
					ELSE ''
					END
				)
			,'Address Line 3' = ''
			,'City' = CASE 
				WHEN ApsubP.PaymentType = 'CHK'
					OR ApsubP.PaymentType = 'CCR'
					THEN (
							CASE 
								WHEN LEN(ApsubA.RemitAddr3) = 0
									THEN ''
								ELSE REPLACE(LEFT(ApsubA.RemitAddr3, CHARINDEX(',', ApsubA.RemitAddr3)), ',', '')
								END
							)
				ELSE ''
				END
			,'State / Province' = (
				CASE 
					WHEN ApsubP.PaymentType = 'CHK'
						OR ApsubP.PaymentType = 'CCR'
						THEN RIGHT(LTRIM(RTRIM(ApsubA.RemitAddr3)), 2)
					ELSE ''
					END
				)
			,'Postal Code' = (
				CASE 
					WHEN ApsubP.PaymentType = 'CHK'
						THEN LEFT(LTRIM(RTRIM(ApsubA.RemitPostalCode)), 5)
					WHEN ApsubP.PaymentType = 'CCR'
						THEN '35124'
					ELSE ''
					END
				)
			,'Country Code' = Geo.Alpha2Code
			,'Country Name' = ApsubA.RemitAddr5
			,'' AS 'Email Address'
			,'Phone Number' = '' --(CASE
			--    WHEN ApsubP.PaymentType = 'CCR' THEN
			--       REPLACE(Apsub.Telephone, '-', '')
			--  ELSE
			--      ''
			--END)
			,'' AS 'Phone international access code'
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplierAddr] ApsubA ON ApCheck.Supplier = ApsubA.Supplier
		INNER JOIN PRODUCT_INFO.Geo.Country Geo ON UPPER(Geo.CountryName) = UPPER(ApsubA.RemitAddr5)
	

		--    Removed EXCEPT FOR IWI
		--INSERT INTO [WellsFargo].[WF_PAB]
		--           ([FPY_ID]
		--           ,[Record_ID]
		--           ,[Address_Ind]
		--           ,[PA_Name]
		--           ,[Add_name]
		--           ,[ID_Number]
		--           ,[Address_L1]
		--           ,[Address_L2]
		--           ,[Address_L3]
		--           ,[City]
		--           ,[State_Prov]
		--           ,[Postal_Code]
		--           ,[Country_Code]
		--           ,[Country_Name]
		--           ,[Email_Address]
		--           ,[Phone]
		--           ,[Phone_int_code])
		--Select 
		--9999 as 'FPY_ID',
		--'PA' as 'Record ID',
		--'RB' as 'Address Indicator',
		--'REMOVE BANK Savings and Loan' as 'Name', -- 'Need to be requsted - this is an ISSUE that need to solved before go live,
		--'' as  'Additional Name',
		--'' as  'Identification Number',
		--'' as 'Address Line 1',
		--'' as 'Address Line 2',
		--'' as 'Address Line 3',
		--'' as 'City',
		--'' as 'State / Province' ,
		--'' as 'Postal Code',
		--'' as 'Country Code' , ----Need to request from Vendor/WF
		--'' as 'Country Name',
		--'' as 'Email Address',
		--'' as 'Phone Number',
		--'' as 'Phone international access code'
		--FROM #APCHECK ApCheck
		--    INNER JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP
		--        ON ApCheck.Supplier = ApsubP.Supplier
		--    INNER JOIN SysproCompany100.dbo.[ApSupplier] Apsub
		--        ON ApCheck.Supplier = Apsub.Supplier;
		--Where ApsubP.PaymentType = 'DAC'


		INSERT INTO [WellsFargo].[WF_CK] (
			[FPY_ID]
			,[Record_ID]
			,[CheckNumber]
			,[Doc_Temp_Number]
			,[Delivery_Code]
			,[Courier_Name]
			,[Courier_Account]
			,[DeliveryReturn_LocCode]
			,[DeliveryLabelTxt]
			,[Check_IMG_ID]
			,[Check_IMG_Desc]
			,[Print_Ready]
			,[Zelle_Mark_Desc]
			)
		SELECT ApCheck.PK AS 'FPY_ID'
			,'CK' AS 'Record ID'
			,RIGHT(ApCheck.Cheque, 10) AS 'CheckNumber'
			,'SR0500CL2474CS3132' AS 'Doc_Temp_Number'

			-- ,'100' AS 'Delivery_Code'
			, 'Delivery_Code' = (
				CASE 
					WHEN ApCheck.ManualRemit = 'Y'
						THEN 'G10' --= FedEx Standard (next day, no guarantee time)--See Appendix B
					ELSE '100'
					END)

			--,'' AS 'Courier_Name'
			,'Courier_Name' = (
				CASE 
					WHEN ApCheck.ManualRemit = 'Y'
						THEN 'FedEx' --FedEx
					ELSE ''
					END)

			--,'' AS 'Courier_Account'
			, 'Courier_Account' = (
				CASE 
					WHEN ApCheck.ManualRemit = 'Y'
						THEN '649042039' -- (FedEx Account #)
					ELSE ''
					END) 	
						
			--,'' AS 'DeliveryReturn_LocCode' -- This should always be blank per 9/7 meeting

			,'DeliveryReturn_LocCode' = (
				CASE 
					WHEN ApCheck.ManualRemit = 'Y'
						THEN '' -- (FedEx Account #)
					ELSE ''
					END) 	


						--,'' AS 'DeliveryLabelTxt'

			,'DeliveryLabelTxt'	= (
				CASE 
					WHEN ApCheck.ManualRemit = 'Y'
						THEN 'Attn: Accounting' --Attn: Accounting
					ELSE ''
					END) 
			,'' AS 'Check Imaging Identifier'
			,'' AS 'Check Imaging Description'
			,'' AS 'Matching to print-ready documents flag'
			,'' AS 'Disbursement with Zelle Marketing Description'
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
				
		INSERT INTO [WellsFargo].[WF_AC] (
			[FPY_ID]
			,[Record_ID]
			,[ACH_Company_ID]
			,[FX_Contract_Number]
			,[FX_Type]
			,[ACH_Format_Code]
			,[ACH_Inter_TypeCode]
			,[Inter_BankID_Type]
			,[Inter_BankID]
			,[Sec_Inter_BankID_Type]
			,[Sec_Inter_BankID]
			,[SEPA_End_END]
			,[SEPA_Cat_Purpose_Code]
			,[SEPA_Inter_Pay_Purpose_Code]
			,[BatchID]
			)
		SELECT ApCheck.PK AS 'FPY_ID'
			,'AC' AS 'Record ID'
			,'ACH Company ID' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN ''
					ELSE '4630777315'
					END
				)
			,'' AS 'FX Contract Number'
			,'' AS 'FX Type'
			,'ACH Format Code' = (
				CASE 
					WHEN ApsubP.PaymentType = 'DAC'
						THEN IIF(ApsubP.AchFormat = '(none)','CCD',ApsubP.AchFormat)
					ELSE ''
					END
				)
			,'' AS 'ACH International Type Code'
			,'' AS 'Intermediary Bank ID Type'
			,'' AS 'Intermediary Bank ID'
			,'' AS 'Second Intermediary Bank ID Type'
			,'' AS 'Second Intermediary Bank ID'
			,'' AS 'SEPA end to end reference number'
			,'' AS 'SEPA Category Purpose Code'
			,'' AS 'SEPA/International Payment Purpose Code'
			,'' AS 'Batch Identification'
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
	

		INSERT INTO [WellsFargo].[WF_WR] (
			[FPY_ID]
			,[Record_ID]
			,[FX_Contract_Number]
			,[Wire_Type]
			,[Wire_IND]
			,[CEO_TempID]
			,[BatchID]
			,[Operator_ID]
			,[Intermediary_BankID_Type]
			,[Intermediary_BankID]
			,[Sec_Inter_BankID_Type]
			,[Sec_Inter_BankID]
			,[Bank_Bank_Info]
			,[ERI_Format]
			,[Expanded CEO Template ID]
			,[Request_Trans_Int_Code]
			,[Bank_Bank_Bene_BankID]
			,[Request_Trans_Int_Desc]
			)
		SELECT ApCheck.PK AS 'FPY_ID'
			,'WR' AS 'Record ID'
			,'' AS 'FX Contract Number'
			,'' AS 'Wire Payment Format Type'
			,'' AS 'Wire Charges Indicator'
			,'' AS 'CEO Template ID'
			,'' AS 'Batch ID'
			,'' AS 'Operator ID'
			,'' AS 'Intermediary Bank ID Type'
			,'' AS 'Intermediary Bank ID'
			,'' AS 'Second Intermediary Bank ID Type'
			,'' AS 'Second Intermediary Bank ID'
			,'' AS 'Bank-to-bank Information'
			,'' AS 'Wire Extended Remittance (ERI) Format'
			,'' AS 'Expanded CEO Template ID'
			,'' AS 'Request for Transfer Instruction code'
			,'' AS 'Bank-to-bank Beneficiary Bank ID'
			,'' AS 'Request for Transfer Instruction description'
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
	

		INSERT INTO [WellsFargo].[WF_CC] (
			[FPY_ID]
			,[Record_ID]
			,[BatchID]
			,[Expire_Date]
			,[Payeee_type]
			,[Merchant_ID]
			,[MCC_code]
			,[Payee_Email]
			,[Division]
			,[Pay_tolerance_Percent_Over]
			,[Pay_tolerance_Percent_Under]
			)
		SELECT ApCheck.PK AS 'FPY_ID'
			,'CC' AS 'Record ID'
			,'BatchID' = RIGHT(DATEPART(yy, GETDATE()) * 1000 + DATEPART(dy, GETDATE()), 5) + CAST(DATEPART(HOUR, GETDATE()) AS VARCHAR) + '' + CAST(DATEPART(MINUTE, GETDATE()) AS VARCHAR) + '0'
			,'Expiration Date' = (GETDATE() + 30)
			,'Payee Type' = ''
			,'Merchant ID' = Apsub.Supplier
			,'MCC code' = ''
			,'Payee Email' = Apsub.Email
			,'Division' = '11000'
			,'Payment Tolerance Percent Over' = '0'
			,'Payment Tolerance Percent Under' = '0'
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
	

		INSERT INTO [WellsFargo].[WF_DD] (
			[FPY_ID]
			,[Record_ID]
			,[FileFormat]
			,[Delivery_type]
			,[Delivery_Contact]
			,[Delivery_Fax_Number]
			,[Delivery_Email]
			,[Delivery_UserID]
			,[Delivery_CompanyID]
			,[Secure_Type]
			,[Reserved1]
			,[Reserved2]
			,[Reserved3]
			,[Reserved4]
			,[EDD_Rec_Address1]
			,[EDD_Rec_Address2]
			,[EDD_RecCity]
			,[EDD_RecState]
			,[EDD_Rec_Zip]
			,[EDD_Rec_Country]
			,[EDD_DOC_Delivery_Code]
			,[EDD_DOC_Courier_Account]
			,[Rel_Remitt_Doc_Number]
			,[Rel_Remitt_URL]
			,[Rel_Remitt_EDI_Number]
			)
		SELECT ApCheck.PK AS 'FPY_ID'
			,'DD' AS 'Record ID'
			,'File Formet' = (
				CASE 
					WHEN ApsubP.PaymentType = 'PMP'
						OR ApsubP.PaymentType = 'IWI'
						THEN 'PDF'
					WHEN ApsubP.PaymentType = 'MTS'
						THEN 'PDF'
					ELSE ''
					END
				)
			,'Delivery Type' = (
				CASE 
					WHEN ApsubP.PaymentType = 'PMP'
						OR ApsubP.PaymentType = 'IWI'
						THEN 'SDD'
					WHEN ApsubP.PaymentType = 'MTS'
						THEN 'SDD'
					ELSE ''
					END
				)
			,'Delivery Contact Name' = Apsub.Contact
			,'Delivery Fax Number' = ''
			,'Delivery Email Address' = Apsub.Email
			,'Delivery User ID' = ''
			,'Delivery Company ID' = ''
			,'Secure Type' = (
				CASE 
					WHEN ApsubP.PaymentType = 'PMP'
						OR ApsubP.PaymentType = 'IWI'
						THEN 'ACCT'
					WHEN ApsubP.PaymentType = 'MTS'
						THEN 'ACCT'
					ELSE ''
					END
				)
			,'Reserved1' = ''
			,'Reserved2' = ''
			,'Reserved3' = ''
			,'Reserved4' = ''
			,'EDD_Rec_Address1' = ''
			,'EDD_Rec_Address2' = ''
			,'EDD_RecCity' = ''
			,'EDD_RecState' = ''
			,'EDD_Rec_Zip' = ''
			,'EDD_Rec_Country' = ''
			,'EDD_DOC_Delivery_Code' = ''
			,'EDD_DOC_Courier_Account' = ''
			,'Rel_Remitt_Doc_Number' = ''
			,'Rel_Remitt_URL' = ''
			,'Rel_Remitt_EDI_Number' = ''
		FROM #APCHECK ApCheck
		LEFT JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		LEFT JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
		

		INSERT INTO [WellsFargo].[WF_IN] (
			[FPY_ID]
			,[Record_ID]
			,[Inv_Number]
			,[Inv_Date]
			,[Inv_Desc]
			,[Inv_Pay_Amount]
			,[Inv_Gross_Amount]
			,[Disc_Taken]
			,[Related_PO_Number]
			,[Inv_Type]
			,[Facility_Name]
			,[PO_Desc]
			,[SEPA_Doc_Type_Code]
			,[SEPA_Doc_Issuer]
			,[SEPA_Doc_Ref_Number]
			,[Cheque]
			)
		SELECT 99999 AS 'FPY_ID'
			,'IN' AS 'Record ID'
			,'Invoice Number' = ApCheck.Invoice
			,'Inv_Date' = ApCheck.InvoiceDate
			,'Inv_Desc' = ''
			,'Inv_Pay_Amount' = ApCheck.NetPayValue
			,'Inv_Gross_Amount' = ApCheck.[GrossPayValue]
			,'Disc_Taken' = ''
			,'Related_PO_Number' = ''
			,'Inv_Type' = 'IV'
			,'Facility_Name' = ''
			,'Purchase Order Description' = ''
			,'SEPA Document Type Code' = ''
			,'SEPA Document Issuer' = ''
			,'SEPA Document Reference Number' = ''
			,ApCheck.Cheque
		FROM  [SysproCompany100].[dbo].ApPayRunDet ApCheck
		INNER JOIN SysproCompany100.dbo.[ApSupplier+] ApsubP ON ApCheck.Supplier = ApsubP.Supplier
		INNER JOIN SysproCompany100.dbo.[ApSupplier] Apsub ON ApCheck.Supplier = Apsub.Supplier
		WHERE ApCheck.PaymentType IN (
				'M'
				,'R'
				)
			AND Usr_AutoPmtSent = 0
			AND ApsubP.PaymentType <> '(none)'
			AND ApCheck.Bank = '100-WFPM'
	

		--Record the PK_ID from WF_PY and then use it to link to the below tables the other WF Tables
		--Once we get all the tables filled out we can then start to create the txt file using the below logic

		
		
		DECLARE @PK_ID AS INT
			,@PaymentMethod AS CHAR(3)
			,@Cheque AS VARCHAR(15);

		WHILE EXISTS (
				SELECT Process_Flag
				FROM [WellsFargo].[WF_PY] PY
				WHERE Process_Flag = 0
				)
		BEGIN
			SET @PK_ID = (
					SELECT MIN([PY_PK_ID])
					FROM [WellsFargo].[WF_PY]
					WHERE Process_Flag = 0
					);

			IF @PK_ID = 1
			BEGIN
				INSERT INTO [WellsFargo].[WF_FILE]
				SELECT ('HD' + '|' + REPLACE(CONVERT(VARCHAR, GETDATE(), 101), '/', '') + REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '') + '|' + CONVERT(CHAR(10), GETDATE(), 126)) AS BLOB;
			END;

			--We need this variable in order to process INV correctly.
			SET @Cheque = (
					SELECT [Cheque]
					FROM [WellsFargo].[WF_PY]
					WHERE [PY_PK_ID] = @PK_ID
					);
			SET @PaymentMethod = (
					SELECT [Payment_Method]
					FROM [WellsFargo].[WF_PY]
					WHERE [PY_PK_ID] = @PK_ID
					);

			--BEFORE WE INSERT RECORDS in WF_FILE WE NEED TO REMOVE THOSE RECORDS THAT WE DO NOT NEED BY @PaymentMethod
			--We do this by removing the records from the TRANSACTION TABLES
			IF @PaymentMethod = 'CCR'
			BEGIN
				DELETE [WellsFargo].[WF_PAB]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_CK]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_AC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_WR]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_DD]
				WHERE FPY_ID = @PK_ID;
			END;

			IF @PaymentMethod = 'CHK'
			BEGIN
				DELETE [WellsFargo].[WF_PAB]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_AC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_WR]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_CC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_DD]
				WHERE FPY_ID = @PK_ID;
			END;

			IF @PaymentMethod = 'DAC'
			BEGIN
				DELETE [WellsFargo].[WF_PAB]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_CK]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_WR]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_CC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_DD]
				WHERE FPY_ID = @PK_ID;
			END;

			IF @PaymentMethod = 'IWI'
			BEGIN
				DELETE [WellsFargo].[WF_CK]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_AC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_CC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_WR]
				WHERE FPY_ID = @PK_ID;


			END;

			IF @PaymentMethod = 'MTS'
			BEGIN
				DELETE [WellsFargo].[WF_CK]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_AC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_CC]
				WHERE FPY_ID = @PK_ID;

				DELETE [WellsFargo].[WF_WR]
				WHERE FPY_ID = @PK_ID;


			END;

			IF @PaymentMethod = 'PMP' --REMOVE EVERYTHING FROM PMP  UNTIL WE ARE READY FOR THIS TRANSACTION
			BEGIN
				UPDATE [WellsFargo].[WF_PY]
				SET [Process_Flag] = 1
				WHERE [PY_PK_ID] = @PK_ID;

				CONTINUE;
			END;

			INSERT INTO [WellsFargo].[WF_FILE]
			SELECT *
			FROM (
				SELECT ([Record_ID] + '|' + [Payment_Method] + '|' + [Credit_Debit] + '|' + [TransNumber] + '|' + CONVERT(VARCHAR, [VDate]) + '|' + CONVERT(VARCHAR, [EDate]) + '|' + CONVERT(VARCHAR, [PDate]) + '|' + CAST([PayAmount] AS VARCHAR(20)) + '|' + CAST([Currency] AS VARCHAR(20)) + '|' + [Origin_Acc_Type] + '|' + [Origin_Acc] + '|' + [Origin_Acc_Currency] + '|' + [Origin_BankID_Type] + '|' + [Origin_BankID] + '|' + [RecPartyAccType] + '|' + [RecPartyAcc] + '|' + [RecAcc_Currency] + '|' + [RecBankPrimIDType] + '|' + [RecBankPrimID] + '|' + [RecBankSecondID] + '|' + [EDD_Code] + '|' + [PDP_Hand_Code] + '|' + [EDD_Bill_ID] + '|' + [Invoice_Manager_Flag] + '|' + [CEO_Company_ID] + '|' + [OriginParty_Rec_Party_Info] + '|' + [Exchange_Rate] + '|' + [Consumer_Payment] + '|' + [Filler] + '|' + [Pay_Purpose_Code] + '|' + [Pay_Purpose_Desc] + '|' + [End_End_ID] + '|') AS BLOB
				FROM [WellsFargo].[WF_PY]
				WHERE PY_PK_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [Address_Ind] + '|' + [PA_Name] + '|' + [Add_name] + '|' + [ID_Number] + '|' + [Address_L1] + '|' + [Address_L2] + '|' + [Address_L3] + '|' + [City] + '|' + [State_Prov] + '|' + [Postal_Code] + '|' + [Country_Code] + '|' + [Country_Name] + '|' + [Email_Address] + '|' + [Phone] + '|' + [Phone_int_code] + '|') AS BLOB
				FROM [WellsFargo].[WF_PAO]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [Address_Ind] + '|' + [PA_Name] + '|' + [Add_name] + '|' + [ID_Number] + '|' + [Address_L1] + '|' + [Address_L2] + '|' + [Address_L3] + '|' + [City] + '|' + [State_Prov] + '|' + [Postal_Code] + '|' + [Country_Code] + '|' + [Country_Name] + '|' + [Email_Address] + '|' + [Phone] + '|' + [Phone_int_code] + '|') AS BLOB
				FROM [WellsFargo].[WF_PAR]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [Address_Ind] + '|' + [PA_Name] + '|' + [Add_name] + '|' + [ID_Number] + '|' + [Address_L1] + '|' + [Address_L2] + '|' + [Address_L3] + '|' + [City] + '|' + [State_Prov] + '|' + [Postal_Code] + '|' + [Country_Code] + '|' + [Country_Name] + '|' + [Email_Address] + '|' + [Phone] + '|' + [Phone_int_code] + '|') AS BLOB
				FROM [WellsFargo].[WF_PAB]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [CheckNumber] + '|' + [Doc_Temp_Number] + '|' + [Delivery_Code] + '|' + [Courier_Name] + '|' + [Courier_Account] + '|' + [DeliveryReturn_LocCode] + '|' + [DeliveryLabelTxt] + '|' + [Check_IMG_ID] + '|' + [Check_IMG_Desc] + '|' + [Print_Ready] + '|' + [Zelle_Mark_Desc]) AS BLOB
				FROM [WellsFargo].[WF_CK]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [ACH_Company_ID] + '|' + [FX_Contract_Number] + '|' + [FX_Type] + '|' + [ACH_Format_Code] + '|' + [ACH_Inter_TypeCode] + '|' + [Inter_BankID_Type] + '|' + [Inter_BankID] + '|' + [Sec_Inter_BankID_Type] + '|' + [Sec_Inter_BankID] + '|' + [SEPA_End_END] + '|' + [SEPA_Cat_Purpose_Code] + '|' + [SEPA_Inter_Pay_Purpose_Code] + '|' + [BatchID] + '|') AS BLOB
				FROM [WellsFargo].[WF_AC]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [FX_Contract_Number] + '|' + [Wire_Type] + '|' + [Wire_IND] + '|' + [CEO_TempID] + '|' + [BatchID] + '|' + [Operator_ID] + '|' + [Intermediary_BankID_Type] + '|' + [Intermediary_BankID] + '|' + [Sec_Inter_BankID_Type] + '|' + [Sec_Inter_BankID] + '|' + [Bank_Bank_Info] + '|' + [ERI_Format] + '|' + [Expanded CEO Template ID] + '|' + [Request_Trans_Int_Code] + '|' + [Bank_Bank_Bene_BankID] + '|' + [Request_Trans_Int_Desc]) AS BLOB
				FROM [WellsFargo].[WF_WR]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [BatchID] + '|' + CONVERT(VARCHAR, [Expire_Date]) + '|' + [Payeee_type] + '|' + [Merchant_ID] + '|' + [MCC_code] + '|' + [Payee_Email] + '|' + [Division] + '|' + [Pay_tolerance_Percent_Over] + '|' + [Pay_tolerance_Percent_Under]) AS BLOB
				FROM [WellsFargo].[WF_CC]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [FileFormat] + '|' + [Delivery_type] + '|' + [Delivery_Contact] + '|' + [Delivery_Fax_Number] + '|' + [Delivery_Email] + '|' + [Delivery_UserID] + '|' + [Delivery_CompanyID] + '|' + [Secure_Type] + '|' + [Reserved1] + '|' + [Reserved2] + '|' + [Reserved3] + '|' + [Reserved4] + '|' + [EDD_Rec_Address1] + '|' + [EDD_Rec_Address2] + '|' + [EDD_RecCity] + '|' + [EDD_RecState] + '|' + [EDD_Rec_Zip] + '|' + [EDD_Rec_Country] + '|' + [EDD_DOC_Delivery_Code] + '|' + [EDD_DOC_Courier_Account] + '|' + [Rel_Remitt_Doc_Number] + '|' + [Rel_Remitt_URL] + '|' + [Rel_Remitt_EDI_Number]) AS BLOB
				FROM [WellsFargo].[WF_DD]
				WHERE FPY_ID = @PK_ID
				
				UNION ALL
				
				SELECT ([Record_ID] + '|' + [Inv_Number] + '|' + CONVERT(VARCHAR, [Inv_Date]) + '|' + [Inv_Desc] + '|' + [Inv_Pay_Amount] + '|' + [Inv_Gross_Amount] + '|' + [Disc_Taken] + '|' + [Related_PO_Number] + '|' + [Inv_Type] + '|' + [Facility_Name] + '|' + [PO_Desc] + '|' + [SEPA_Doc_Type_Code] + '|' + [SEPA_Doc_Issuer] + '|' + [SEPA_Doc_Ref_Number]) AS BLOB
				FROM [WellsFargo].[WF_IN] WFIN
				WHERE WFIN.[Cheque] = @Cheque
				) A;

			UPDATE [WellsFargo].[WF_PY]
			SET [Process_Flag] = 1
			WHERE [PY_PK_ID] = @PK_ID;
		END;

		DECLARE @PYCOUNT AS INT = 0
			,@PYCheckTotal AS DECIMAL(17, 2);

		SELECT @PYCOUNT = COUNT(*)
			,@PYCheckTotal = SUM([PayAmount])
		FROM [WellsFargo].[WF_PY]
		WHERE [Process_Flag] = 1;

		IF @PYCOUNT <> 0
		BEGIN
		INSERT INTO [WellsFargo].[WF_FILE]
		SELECT ('TR' + '|' + LTRIM(STR(@PYCOUNT)) + '|' + LTRIM(CAST(@PYCheckTotal AS VARCHAR(100)))) AS BLOB;
		END

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		-- Raise an error with the details of the exception
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
go

USE [PRODUCT_INFO]
GO
/****** Object:  StoredProcedure [dbo].[Uniters_ErrorEmail]    Script Date: 9/28/2022 10:45:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
=============================================
Author name: Michael Barber
Create date: Monday, July 21st, 2021
Description: Uniters - [Uniters_ErrorEmail]
=============================================
Modifier Name:	Justin Pope
Modified Date:	2022-09-28
SDM Ticket:		31462
Comment:		Adding Error Email to email
				system
=============================================

exec [dbo].[Uniters_ErrorEmail]
 
=============================================
*/

ALTER PROCEDURE [dbo].[Uniters_ErrorEmail]
AS
SET XACT_ABORT ON
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY

		IF  EXISTS( SELECT * FROM PRODUCT_INFO.dbo.Uniters 
					WHERE DATEADD(dd, DATEDIFF(dd, 0, DateTransmitted), 0) in(	Select 
																					DATEADD(dd, DATEDIFF(dd, 0, Max(DateTransmitted)), 0) 
																				FROM PRODUCT_INFO.dbo.Uniters) 
						and ResponseCode <> 200 
						and ResponseCode is not null 
						AND PolicyExact <> 'CUST'  )
		BEGIN


			declare @Mail_ID as varchar(50) = 'PRODUCT_INFO.dbo.Uniters_ErrorEmail',
					@Mail_SubCode as varchar(50) = 'API Error Response',
					@Mail_Type as varchar(25) = 'Info';

			DECLARE @body_content nvarchar(max) = (	select 
														mail_body 
													from [Global].[Settings].[EmailMessage]
													where Mail_ID = @Mail_ID 
														and Mail_SubCode = @Mail_SubCode 
														and Mail_Type = @Mail_Type);

			declare @BODY_Target nvarchar(50) = N'<tbody></tbody>';
			declare @BODY_Table nvarchar(1000) =
			N'<tbody>' +
			CAST(
			    (Select 
				td = SalesOrder, '',
				td = PolicyType, '',
				td = ResponseText , ''
				FROM PRODUCT_INFO.dbo.Uniters 
				where DATEADD(dd, DATEDIFF(dd, 0, DateTransmitted), 0) in(	Select 
																				DATEADD(dd, DATEDIFF(dd, 0, Max(DateTransmitted)), 0) 
																			FROM PRODUCT_INFO.dbo.Uniters) 
					and ResponseCode <> 200 
					and ResponseCode is not null 
					AND  PolicyExact <> 'CUST'
			    FOR XML PATH('tr'), TYPE) AS nvarchar(max) ) +
			N'</tbody>';
			
			set @body_content = REPLACE(@body_content, @BODY_Target, @BODY_Table)
			
			execute [Global].[Settings].[usp_Send_Email] @Mail_ID, 
															@Mail_SubCode, 
															@Mail_Type, 
															@Mail_Body = @body_content
			


		END

		RETURN 0;

	END TRY

	BEGIN CATCH

		THROW;

		WHILE  @@TRANCOUNT> 0 

			BEGIN ROLLBACK TRAN;

			END


		RETURN 1;

	END CATCH;

END;
go