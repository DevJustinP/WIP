Imports System.Xml
Imports System.IO

Module modMain
#Region "Varialbes"
    Public Enum SugarCRMExports
        Accounts
        Quotes
        QuoteLines
        SalesOrders
        SalesOrderLines
        Invoices
        InvoiceLines
    End Enum

    Public g_LogLocation As String

    Private Const c_SQL08_server As String = "\\SQL08\"
    Private Const c_SQL08_local_P_directory As String = "P:"
    Private Const c_SQL08_remote_P_directory As String = "P$"

    Private Const c_Custom_Queue As String = "https://summerclassicsdev.sugarondemand.com/"
#End Region
    Sub Main()

        GetSettings()

    End Sub

    Function GetSettings() As Boolean

        Dim strSettings As String = modDatacontext.GetApplicationSettings()
        Dim oXMLDocumnet As New XmlDocument()
        oXMLDocumnet.LoadXml(strSettings)
        Dim strPath As String = oXMLDocumnet.SelectSingleNode("/Setting/SugarFileDirectory").InnerText
        strPath = strPath.Replace(c_SQL08_local_P_directory, c_SQL08_server + c_SQL08_remote_P_directory)
        If Directory.Exists(strPath) Then
            Console.WriteLine("SugarCrm Log Directory: " + strPath)
            g_LogLocation = strPath
        Else
            Console.WriteLine(strPath + " does not exists")
            Console.ReadKey()
            Return False
        End If

        Return True
    End Function

End Module
