/// <summary>
/// Table WSC Web Services Log Bodies (ID 81006).
/// </summary>
table 81006 "WSC Web Services Log Bodies"
{
    Caption = 'Web Services - Log Bodies';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Log Bodies";
    LookupPageId = "WSC Web Services Log Bodies";

    fields
    {
        field(1; "WSC Log Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Entry No.';
        }
        field(2; "WSC Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(3; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "WSC Web Services Connections"."WSC Code";
        }
        field(4; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
        }
        field(5; "WSC Value"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
        }
        field(6; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "WSC Code", "WSC Log Entry No.", "WSC Entry No.")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// ViewLog.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    /// <param name="EntryNo">Integer.</param>
    procedure ViewLog(WSCCode: Code[20]; EntryNo: Integer)
    var
        WSCWSServicesLogCalls: Record "WSC Web Services Log Calls";
        WSCWSServicesLogBodies: Record "WSC Web Services Log Bodies";
    begin
        WSCWSServicesLogCalls.Get(WSCCode, EntryNo);

        WSCWSServicesLogBodies.Reset();
        WSCWSServicesLogBodies.FilterGroup(2);
        WSCWSServicesLogBodies.SetRange("WSC Code", WSCWSServicesLogCalls."WSC Code");
        WSCWSServicesLogBodies.SetRange("WSC Entry No.", WSCWSServicesLogCalls."WSC Entry No.");
        WSCWSServicesLogBodies.FilterGroup(0);
        Page.RunModal(0, WSCWSServicesLogBodies);
    end;

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