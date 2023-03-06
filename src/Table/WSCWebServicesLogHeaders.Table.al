/// <summary>
/// Table WSC Web Services Log Headers (ID 81005).
/// </summary>
table 81005 "WSC Web Services Log Headers"
{
    Caption = 'Web Services - Log Headers';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Headers";
    LookupPageId = "WSC Web Services Headers";

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
        field(4; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
            Editable = false;
        }
        field(5; "WSC Value"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
            Editable = false;
        }
        field(6; "WSC Description"; Text[100])
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