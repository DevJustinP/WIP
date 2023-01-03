Imports GWC.SQL
Imports System.Collections.Generic
Imports System.Data

Public Class DataContext

    Private oSQLHandler As SQLHandler

    Public Sub New(pConnection As String)

        oSQLHandler = New SQLHandler("TalendSugarCrmHelper", pConnection)

    End Sub

    Public Function GetAccountsReference(pAccounts As List(Of String)) As DataTable
        Dim strSQL As String = "select * from [PRODUCT_INFO].[SugarCrm].[ArCustomer_Ref] where Customer in (<accounts>)"
        Dim strCust As String = Nothing
        For Each strCustomer As String In pAccounts
            If strCust = String.Empty Then
                strCust = $"'{strCustomer}'"
            Else
                strCust = $",'{strCustomer}'"
            End If
        Next
        strSQL = strSQL.Replace("<accounts>", strCust)

        Dim dtRTN As DataTable = oSQLHandler.ExecuteCommand(strSQL, SQLHandler.ReturnType.DataTable)

        Return dtRTN
    End Function

    Public Function GetQuotes(pQuotes As List(Of String)) As DataTable
        Dim strSQL As String = "select * from [PRODUCT_INFO].[SugarCrm].["
    End Function

End Class
