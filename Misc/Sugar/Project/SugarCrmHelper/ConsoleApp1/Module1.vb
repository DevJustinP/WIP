Imports System.IO
Imports System.Net
Imports Microsoft.VisualBasic.FileIO
Imports Newtonsoft.Json
Module Module1

    Dim strXLS_filepath As String = "C:\GitHub\WIP\Tickets\issue\SugarCrm export issue\SalesOrdersMissingSugarCRM.csv"
    Dim strLogLocation As String = "\\talend\c$\TalendLogs\Main_SugarExport\Logs"

    Dim dteStart As DateTime = "2022/12/22 08:00:00"

    Const const_xls_SalesOrder_col As String = "SalesOrder"
    Const const_FilePath_col As String = "filepath"
    Const const_CustomQueueID As String = "CustomQueueID"
    Const const_QueueStatus As String = "Queue Status"
    Const const_TimeStamp As String = "Time Stamp"
    Const const_SugarCrm_Link_col As String = "CRM link"
    Const const_SugarCrm_Link As String = "https://summerclassics.sugarondemand.com/#upsert_CustomQueue"
    Const const_SalesOrder_fileSearch_input As String = "Orders_createjobs_input"

    Dim dtSalesOrders As DataTable
    Dim dtSalesOrdersReturn As DataTable

    Sub Main()

        Console.WriteLine(strXLS_filepath)
        If Directory.Exists(Path.GetDirectoryName(strXLS_filepath)) Then
            BuildTable()
        End If

        Console.Write(strLogLocation)
        If Directory.Exists(strLogLocation) Then
            FindOrder()
        End If

        If dtSalesOrders.Rows.Count > 0 Then
            Dim strPath As String = Path.GetDirectoryName(strXLS_filepath)
            Dim strReportPath As String = strPath + "\SalesOrderReport_" + DateTime.Now.Year.ToString + "_" + DateTime.Now.Month.ToString + "_" + DateTime.Now.Day.ToString + "_" + DateTime.Now.Hour.ToString + "_" + DateTime.Now.Minute.ToString + "_" + DateTime.Now.Second.ToString + "_" + ".csv"
            File.WriteAllText(strReportPath, WriteReport())
        End If

    End Sub

    Sub BuildTable()
        Dim fields As String()
        Dim dr As DataRow
        dtSalesOrders = New DataTable()
        dtSalesOrders.Columns.Add(const_xls_SalesOrder_col)

        dtSalesOrdersReturn = New DataTable()
        dtSalesOrdersReturn.Columns.Add(const_xls_SalesOrder_col)
        dtSalesOrdersReturn.Columns.Add(const_TimeStamp)
        dtSalesOrdersReturn.Columns.Add(const_CustomQueueID)
        dtSalesOrdersReturn.Columns.Add(const_QueueStatus)
        dtSalesOrdersReturn.Columns.Add(const_SugarCrm_Link_col)

        Dim oCSVFile As New TextFieldParser(strXLS_filepath)
        oCSVFile.Delimiters = {","}
        oCSVFile.TextFieldType = FieldType.Delimited

        oCSVFile.ReadLine()
        While oCSVFile.EndOfData = False
            fields = oCSVFile.ReadFields()
            dr = dtSalesOrders.NewRow()
            dr(const_xls_SalesOrder_col) = fields(0)
            dtSalesOrders.Rows.Add(dr)
        End While

    End Sub

    Sub FindOrder()
        Dim dir As New DirectoryInfo(strLogLocation)

        For Each f As FileInfo In dir.GetFiles()
            If Not (f.Name.Contains("Orders") And f.Name.Contains("input")) Then Continue For
            Dim intYear As Integer = CInt(f.Name.Substring(0, 4))
            Dim intMonth As Integer = CInt(f.Name.Substring(5, 2))
            Dim intDay As Integer = CInt(f.Name.Substring(8, 2))
            Dim intHour As Integer = CInt(f.Name.Substring(11, 2))
            Dim intMin As Integer = CInt(f.Name.Substring(14, 2))
            Dim intSec As Integer = CInt(f.Name.Substring(17, 2))
            Dim dteFile As New DateTime(intYear, intMonth, intDay, intHour, intMin, intSec)
            If Not (dteFile < Date.Now And dteFile > dteStart) Then Continue For
            Console.Write(f.Name)
            Dim strInput As String = File.ReadAllText(f.FullName)
            If strInput.Length > 0 Then
                strInput = strInput.Remove((strInput.Length - 4), 4)
                strInput = strInput.Remove(0, 16)
                strInput = strInput.Replace("\", "")
                Dim oJobs As OrderBatch = JsonConvert.DeserializeObject(Of OrderBatch)(strInput)
                Dim strFilePathOutput As String
                If File.Exists(f.FullName.Replace("input", "output")) Then
                    strFilePathOutput = f.FullName.Replace("input", "output")
                    Dim strOutput As String = File.ReadAllText(strFilePathOutput)
                    strOutput = strOutput.Remove(strOutput.Length - 34, 34)
                    strOutput = strOutput.Remove(0, 23)
                    strOutput = strOutput.Replace("\", "")
                    Dim arrOutput As String() = Split(strOutput, ",")
                    For x As Integer = 0 To oJobs.jobs.Count - 1
                        Dim strSplit As String() = Split(arrOutput(x), ":")
                        oJobs.jobs(x).context.fields.CustomQueueID = strSplit(0)
                        oJobs.jobs(x).context.fields.QueueStatus = strSplit(1)
                    Next
                End If

                For Each oJob As OrderJob In oJobs.jobs
                    For Each dr As DataRow In dtSalesOrders.Rows
                        If dr(const_xls_SalesOrder_col) = oJob.context.fields.name Then
                            Dim drEntry As DataRow = dtSalesOrdersReturn.NewRow()
                            drEntry(const_xls_SalesOrder_col) = oJob.context.fields.name
                            drEntry(const_TimeStamp) = dteFile.ToShortDateString + " " + dteFile.ToShortTimeString
                            drEntry(const_CustomQueueID) = oJob.context.fields.CustomQueueID
                            drEntry(const_QueueStatus) = oJob.context.fields.QueueStatus
                            If Not String.IsNullOrEmpty(oJob.context.fields.CustomQueueID) Then
                                drEntry(const_SugarCrm_Link_col) = const_SugarCrm_Link + "\" + oJob.context.fields.CustomQueueID
                            End If
                            dtSalesOrdersReturn.Rows.Add(drEntry)
                        End If
                    Next
                Next
            End If
        Next

    End Sub

    Function WriteReport() As String
        Dim sb As New System.Text.StringBuilder

        For Each dc As DataColumn In dtSalesOrdersReturn.Columns
            sb.Append(dc.ColumnName + ",")
        Next
        sb.AppendLine()
        For Each dr As DataRow In dtSalesOrdersReturn.Rows
            For Each dc As DataColumn In dtSalesOrdersReturn.Columns
                sb.Append(dr(dc) + ",")
            Next
            sb.AppendLine()
        Next

        Return sb.ToString()
    End Function

End Module
