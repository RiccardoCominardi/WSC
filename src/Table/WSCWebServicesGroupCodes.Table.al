/// <summary>
/// Table WSC Web Services Group Codes (ID 81007).
/// </summary>
table 81007 "WSC Web Services Group Codes"
{
    Caption = 'Web Services - Group Codes';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Group Codes";
    LookupPageId = "WSC Web Services Group Codes";

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "WSC Code")
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        WebServicesConnections: Record "WSC Web Services Connections";
    begin
        if Rec."WSC Code" = '' then
            exit;
        WebServicesConnections.Reset();
        WebServicesConnections.SetRange("WSC Group Code", Rec."WSC Code");
        WebServicesConnections.ModifyAll("WSC Group Code", '');
    end;

    trigger OnRename()
    begin

    end;

}