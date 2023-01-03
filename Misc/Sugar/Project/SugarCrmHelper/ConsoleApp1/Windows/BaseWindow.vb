Public MustInherit Class BaseWindow

    Private p_MainWindow As String()

    Public MustOverride Sub LoadWindow()

    Public Sub New()
        p_MainWindow = New String(1)
    End Sub

    Public Sub MainWindowLine(pStrLine As String)

    End Sub

    Public Sub PrintMainWindow()
        PrintWindow(p_MainWindow)
    End Sub

    Public Sub PrintWindow(pWindow As String())

        Console.Clear()
        For Each strRow As String In pWindow
            Console.WriteLine(strRow)
        Next

    End Sub

    Public Sub MessageWithPause(pMessage As String)
        Console.WriteLine(pMessage)
        Console.ReadLine()
    End Sub

    Public Function MessageWithResponse(pMessage As String, Optional pResponses As List(Of MessageResponse) = Nothing, Optional pValidateReponse As Boolean = False) As String
        Dim rtn As String
        Console.WriteLine(pMessage)
        PrintReponses(pResponses)
        rtn = Console.ReadLine()
        If pValidateReponse Then
            Dim blnValid As Boolean = False
            While (Not blnValid)
                blnValid = MessageResponseValidation(rtn, pResponses)
            End While
        End If
        Return rtn
    End Function

    Public Sub PrintReponses(pResponses As List(Of MessageResponse))

        For Each oResponse As MessageResponse In pResponses
            Console.WriteLine(oResponse.KeyValue + " : " + oResponse.ResponseMessage)
        Next

    End Sub

    Public Function MessageResponseValidation(ByRef pSelection As String, pResponse As List(Of MessageResponse)) As Boolean

        For Each oResponse As MessageResponse In pResponse
            Select Case oResponse.ExactMatch
                Case True
                    If oResponse.KeyValue = pSelection Then
                        Return True
                    End If
                Case Else
                    If oResponse.KeyValue.ToLower() = pSelection.ToLower() Then
                        Return True
                    End If
            End Select
        Next

        Return False
    End Function

End Class

Public Class MessageResponse

    Public Property KeyValue As String
    Public Property ResponseMessage As String
    Public Property ExactMatch As Boolean

End Class
