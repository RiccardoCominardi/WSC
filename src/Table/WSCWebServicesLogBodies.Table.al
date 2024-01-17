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
        WebServicesLogCalls: Record "WSC Web Services Log Calls";
        WebServicesLogBodies: Record "WSC Web Services Log Bodies";
    begin
        WebServicesLogCalls.Get(WSCCode, EntryNo);

        WebServicesLogBodies.Reset();
        WebServicesLogBodies.FilterGroup(2);
        WebServicesLogBodies.SetRange("WSC Code", WebServicesLogCalls."WSC Code");
        WebServicesLogBodies.SetRange("WSC Entry No.", WebServicesLogCalls."WSC Entry No.");
        WebServicesLogBodies.FilterGroup(0);
        Page.RunModal(0, WebServicesLogBodies);
    end;

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