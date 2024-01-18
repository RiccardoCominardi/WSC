/// <summary>
/// Table WSC Web Services Log Headers (ID 81005).
/// </summary>
table 81005 "WSC Web Services Log Headers"
{
    Caption = 'Web Services - Log Headers';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Log Headers";
    LookupPageId = "WSC Web Services Log Headers";

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
        WebServicesLogHeaders: Record "WSC Web Services Log Headers";
    begin
        WebServicesLogCalls.Get(WSCCode, EntryNo);

        WebServicesLogHeaders.Reset();
        WebServicesLogHeaders.FilterGroup(2);
        WebServicesLogHeaders.SetRange("WSC Code", WebServicesLogCalls."WSC Code");
        WebServicesLogHeaders.SetRange("WSC Log Entry No.", WebServicesLogCalls."WSC Entry No.");
        WebServicesLogHeaders.FilterGroup(0);
        Page.RunModal(0, WebServicesLogHeaders);
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