Imports GWC

Module modDatacontext

    Dim oSQL As SQL.SQLHandler

    Private Sub ConstructSQLHanlder()
        If oSQL IsNot Nothing Then Exit Sub
        oSQL = New SQL.SQLHandler("", My.Resources.ConnectionString)
    End Sub

    Private Sub AddSQLParameter(ByRef pParmList As List(Of SQL.SQLHandler.ParameterValue), pParameterName As String, pParameterValue As Object)
        Dim oParm As New SQL.SQLHandler.ParameterValue
        oParm.ParameterName = pParameterName
        oParm.ParameterValue = pParameterValue

        If pParmList Is Nothing Then
            pParmList = New List(Of SQL.SQLHandler.ParameterValue)
        End If
        pParmList.Add(oParm)

    End Sub

    Public Function GetApplicationSettings() As String
        ConstructSQLHanlder()
        Dim lstParms As New List(Of SQL.SQLHandler.ParameterValue)
        AddSQLParameter(lstParms, "ApplicationId", 48)

        Return oSQL.ExecuteProcedure("[SysproDocument].[dbo].[usp_Setting_Get]", lstParms, SQL.SQLHandler.ReturnType.Scalar)
    End Function

#Region "ExportQueries"

    Private Function QueryAccounts() As DataTable
        Dim dtRtn As DataTable = Nothing
        Dim strSQL As String = "
                select
	                Customer,
	                [TimeStamp]
                from [PRODUCT_INFO].[SugarCrm].[CustomerExport_Audit]
                where Customer in (<ARRAY>)
	                and [TimeStamp] >"

        Return dtRtn
    End Function

    Private Function QueryQuote() As DataTable
        Dim dtRtn As DataTable = Nothing

        Return dtRtn
    End Function

    Private Function QueryQuoteLines() As DataTable
        Dim dtRtn As DataTable = Nothing

        Return dtRtn
    End Function

    Private Function QuerySalesOrders() As DataTable
        Dim dtRtn As DataTable = Nothing

        Return dtRtn
    End Function

    Private Function QuerySalesOrdersLines() As DataTable
        Dim dtRtn As DataTable = Nothing

        Return dtRtn
    End Function
#End Region

End Module
