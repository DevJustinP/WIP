USE [SysproCompany100]
GO

/****** Object:  View [dbo].[vw_Optio_SorMaster]    Script Date: 9/14/2022 11:28:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_Optio_SorMaster]
AS

  WITH DispatchNote
         AS (SELECT MdnMaster.[SalesOrder]               AS [SalesOrder]
                   ,[CusMdnMaster+].[KeyInvoice]         AS [InvoiceNumber]
                   ,[CusMdnMaster+].[BillOfLadingNumber] AS [BillOfLadingNumber]
                   ,[CusMdnMaster+].[CarrierId]          AS [CarrierId]
                   ,[CusMdnMaster+].[CreditApprovalDate] AS [CreditApprovalDate]
                   ,[CusMdnMaster+].[ProNumber]          AS [ProNumber]
             FROM dbo.MdnMaster WITH (NOLOCK)
             INNER JOIN dbo.[CusMdnMaster+] WITH (NOLOCK)
               ON MdnMaster.[DispatchNote] = [CusMdnMaster+].[DispatchNote])
      ,SalesOrder
         AS (SELECT [CusSorMaster+].[SalesOrder]         AS [SalesOrder]
                   ,ArTrnSummary.[Invoice]               AS [InvoiceNumber]
                   ,[CusSorMaster+].[BillOfLadingNumber] AS [BillOfLadingNumber]
                   ,[CusSorMaster+].[CarrierId]          AS [CarrierId]
                   ,[CusSorMaster+].[CreditApprovalDate] AS [CreditApprovalDate]
                   ,[CusSorMaster+].[ProNumber]          AS [ProNumber]
             FROM dbo.[CusSorMaster+] WITH (NOLOCK)
             INNER JOIN dbo.ArTrnSummary WITH (NOLOCK)
               ON     [CusSorMaster+].[SalesOrder] = ArTrnSummary.[SalesOrder]
                  AND [CusSorMaster+].[InvoiceNumber] = '')
      ,DispatchNoteFirst
         AS (SELECT DispatchNote.[SalesOrder]
                   ,DispatchNote.[InvoiceNumber]
                   ,DispatchNote.[BillOfLadingNumber]
                   ,DispatchNote.[CarrierId]
                   ,DispatchNote.[CreditApprovalDate]
                   ,DispatchNote.[ProNumber]
             FROM DispatchNote
             INNER JOIN SalesOrder
               ON     DispatchNote.[SalesOrder] = SalesOrder.[SalesOrder]
                  AND DispatchNote.[InvoiceNumber] = SalesOrder.[InvoiceNumber])
      ,SalesOrderSecond
         AS (SELECT SalesOrder.[SalesOrder]
                   ,SalesOrder.[InvoiceNumber]
                   ,SalesOrder.[BillOfLadingNumber]
                   ,SalesOrder.[CarrierId]
                   ,SalesOrder.[CreditApprovalDate]
                   ,SalesOrder.[ProNumber]
             FROM SalesOrder
             LEFT OUTER JOIN DispatchNote
               ON     SalesOrder.[SalesOrder] = DispatchNote.[SalesOrder]
                  AND SalesOrder.[InvoiceNumber] = DispatchNote.[InvoiceNumber]
             WHERE DispatchNote.[InvoiceNumber] IS NULL)
      ,Combined
         AS (SELECT [SalesOrder]
                   ,[InvoiceNumber]
                   ,[BillOfLadingNumber]
                   ,[CreditApprovalDate]
                   ,[CarrierId]
                   ,[ProNumber]
             FROM DispatchNoteFirst
             UNION
             SELECT [SalesOrder]
                   ,[InvoiceNumber]
                   ,[BillOfLadingNumber]
                   ,[CreditApprovalDate]
                   ,[CarrierId]
                   ,[ProNumber]
             FROM SalesOrderSecond)
  SELECT Combined.[SalesOrder]                                AS [SalesOrder]
        ,Combined.[InvoiceNumber]                             AS [InvoiceNumber]
        ,Combined.[BillOfLadingNumber]                        AS [BillOfLadingNumber]
        ,Combined.[CarrierId]                                 AS [CarrierId]
        ,CONVERT(VARCHAR, Combined.[CreditApprovalDate], 110) AS [CADate]
        ,AdmFormValidation.[Description]                      AS [Description]
        ,Combined.[ProNumber]                                 AS [ProNumber]
  FROM Combined
  LEFT OUTER JOIN dbo.AdmFormValidation
    ON     AdmFormValidation.[FormType] = 'ORD'
       AND AdmFormValidation.[FieldName] = 'CARRID'
       AND AdmFormValidation.[Item] = Combined.[CarrierId];

/*

  SELECT [CusSorMaster+].[SalesOrder]                                AS [SalesOrder]
        ,ArTrnSummary.[Invoice]                                      AS [InvoiceNumber]
        ,[CusSorMaster+].[CarrierId]                                 AS [CarrierId]
        ,[CusSorMaster+].[ProNumber]                                 AS [ProNumber]
        ,[CusSorMaster+].[BillOfLadingNumber]                        AS [BillOfLadingNumber]
        ,CONVERT(VARCHAR, [CusSorMaster+].[CreditApprovalDate], 110) AS [CADate]
        ,AdmFormValidation.[Description]                             AS [Description]
  FROM dbo.[CusSorMaster+]
  INNER JOIN dbo.ArTrnSummary
    ON     [CusSorMaster+].[SalesOrder] = ArTrnSummary.[SalesOrder]
       AND [CusSorMaster+].[InvoiceNumber] = ''
  LEFT OUTER JOIN dbo.AdmFormValidation
    ON     AdmFormValidation.[FormType] = 'ORD'
       AND AdmFormValidation.[FieldName] = 'CARRID'
       AND AdmFormValidation.[Item] = [CusSorMaster+].[CarrierId];

*/

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[38] 4[31] 2[18] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[47] 2[23] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CusSorMaster+"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 38
         End
         Begin Table = "AdmFormValidation"
            Begin Extent = 
               Top = 5
               Left = 389
               Bottom = 177
               Right = 559
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 6135
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Optio_SorMaster'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_Optio_SorMaster'
GO


