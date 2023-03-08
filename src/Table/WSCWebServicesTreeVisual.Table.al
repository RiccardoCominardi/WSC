/// <summary>
/// Table WCS Web Services Tree Visual (ID 81008).
/// </summary>
table 81008 "WCS Web Services Tree Visual"
{
    DataClassification = CustomerContent;
    Caption = 'Web Services - Tree Visual';
    TableType = Temporary;

    fields
    {
        field(1; "WSC Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Group Code';
        }
        field(2; "WSC Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(3; "WSC Indentation"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Indentation';
        }
        field(4; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(5; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Descritpion';
        }
    }

    keys
    {
        key(Key1; "WSC Group Code", "WSC Entry No.")
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