/// <summary>
/// Table WSC Web Services Log Calls (ID 81004).
/// </summary>
table 81004 "WSC Web Services Log Calls"
{
    Caption = 'Web Services Log Calls';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Log Calls";
    LookupPageId = "WSC Web Services Log Calls";

    fields
    {
        field(1; "WSC Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(3; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(4; "WSC HTTP Method"; Enum "WSC HTTP Methods")
        {
            DataClassification = CustomerContent;
            Caption = 'HTTP Method';
        }
        field(5; "WSC EndPoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint';
        }
        field(6; "WSC Auth. Type"; Enum "WSC Authorization Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Auth. Type';
        }
        field(7; "WSC Bearer Connection"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Bearer Connection';
        }
        field(8; "WSC Bearer Connection Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bearer Connection Code';
            TableRelation = "WSC Web Services Connections"."WSC Code" where("WSC Bearer Connection" = const(true));
        }
        field(9; "WSC Body Type"; Enum "WSC Body Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Body Type';
        }
        field(10; "WSC Body Message"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Body Message';
        }
        field(11; "WSC Link To Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Link To Entry No';
        }
        field(200; "WSC Response Message"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Response Message';
        }
        field(201; "WSC Result Status Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Result Status Code';
        }
        field(202; "WSC Execution Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Date-Time';
        }
        field(203; "WSC Execution UserID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Execution UserID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "WSC Entry No.")
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
    begin

    end;

    trigger OnRename()
    begin

    end;

}