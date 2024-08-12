/// <summary>
/// Query WSC Top 5 Web Service Calls (ID 81001).
/// </summary>
query 81001 "WSC Top 5 Web Service Calls"
{
    Caption = 'Top 5 Web Services Calls';
    OrderBy = descending(TotalCalls);
    TopNumberOfRows = 5;

    elements
    {
        dataitem(LogCalls; "WSC Log Calls")
        {
            DataItemTableFilter = "WSC Bearer Connection" = const(false);
            column(WSCCode; "WSC Code")
            {
                Caption = 'WSC Code';
            }
            column(TotalCalls)
            {
                Caption = 'Total Calls';
                Method = Count;
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}