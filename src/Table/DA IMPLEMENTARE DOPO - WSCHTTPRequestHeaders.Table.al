/*
/// <summary>
/// Table WSC HTTP Headers (ID 81003).
/// </summary>
table 81003 "WSC HTTP Headers"
{
    Caption = 'HTTP Headers';
    DataClassification = CustomerContent;
    //DrillDownPageId = "WSC Web Services Headers";
    //LookupPageId = "WSC Web Services Headers";
    fields
    {
        field(1; "WSC HTTP Header"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'HTTP Header';
        }
        field(2; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "WSC Example"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Example';
        }
        field(4; "WSC Status"; Enum "WSC HTTP Headers Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(5; "WSC Standard"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Standard';
        }
    }

    keys
    {
        key(Key1; "WSC HTTP Header")
        {
            Clustered = true;
        }
    }
}
*/