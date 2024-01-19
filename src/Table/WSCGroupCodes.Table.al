/// <summary>
/// Table WSC Group Codes (ID 81007).
/// </summary>
table 81007 "WSC Group Codes"
{
    Caption = 'Web Services - Group Codes';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Group Codes";
    LookupPageId = "WSC Group Codes";

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
        Connections: Record "WSC Connections";
    begin
        if Rec."WSC Code" = '' then
            exit;
        Connections.Reset();
        Connections.SetRange("WSC Group Code", Rec."WSC Code");
        Connections.ModifyAll("WSC Group Code", '');
    end;

    trigger OnRename()
    begin

    end;

}