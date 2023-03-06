/// <summary>
/// Table WSC Web Services Log Bodies (ID 81006).
/// </summary>
table 81006 "WSC Web Services Log Bodies"
{
    Caption = 'Web Services - Log Bodies';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Bodies";
    LookupPageId = "WSC Web Services Bodies";

    fields
    {
        field(1; "WSC Log Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Entry No.';
            Editable = false;
        }
        field(2; "WSC Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            Editable = false;
        }
        field(3; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            Editable = false;
        }
        field(4; "WSC Body Type"; Enum "WSC Body Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
            Editable = false;
        }
        field(5; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
            Editable = false;
        }
        field(6; "WSC Value"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
            Editable = false;
        }
        field(7; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "WSC Log Entry No.", "WSC Entry No.")
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
    begin

    end;

    trigger OnRename()
    begin

    end;

}