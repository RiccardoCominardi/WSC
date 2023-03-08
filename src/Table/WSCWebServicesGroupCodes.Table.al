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

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        WSCWebServicesConnections: Record "WSC Web Services Connections";
    begin
        if Rec."WSC Code" = '' then
            exit;
        WSCWebServicesConnections.Reset();
        WSCWebServicesConnections.SetRange("WSC Group Code", Rec."WSC Code");
        WSCWebServicesConnections.ModifyAll("WSC Group Code", '');
    end;

    trigger OnRename()
    begin

    end;

}