Module modJSONObjects

    Public Class Log
        Property log As String
    End Class

    Public Class OrderBatch
        Property jobs As List(Of OrderJob)
    End Class

    Public Class OrderJob
        Property job_module As String
        Property job As String
        Property context As context
    End Class

    Public Class context
        Property source As Source
        Property fields As Fields
    End Class

    Public Class Source
        Property database As String
        Property server As String
    End Class

    Public Class Fields
        Property order_date_c As Date
        Property name As String
        Property po_number_c As String
        Property web_order_number_c As String
        Property shipping_address_street_c As String
        Property shipping_address_city_c As String
        Property shipping_address_state_c As String
        Property shipping_address_postalcode_c As String
        Property shipping_address_country_c As String
        Property market_segment_c As String
        Property shipment_request_c As String
        Property branch_c As String
        Property channel_c As String
        Property order_status_c As String
        Property DocumentType As String
        Property lookup_account_number As String
        Property lookup_specifier_account_number As String
        Property lookup_purchaser_account_number As String
        Property lookup_assigned_user_email As String
        Property CustomQueueID As String
        Property QueueStatus As String
    End Class

    Public Class OrderReturn

    End Class

End Module
