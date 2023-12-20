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
        WSCWSServicesLogHeaders: Record "WSC Web Services Log Headers";
    begin
        WSCWSServicesLogCalls.Get(WSCCode, EntryNo);

        WSCWSServicesLogHeaders.Reset();
        WSCWSServicesLogHeaders.FilterGroup(2);
        WSCWSServicesLogHeaders.SetRange("WSC Code", WSCWSServicesLogCalls."WSC Code");
        WSCWSServicesLogHeaders.SetRange("WSC Entry No.", WSCWSServicesLogCalls."WSC Entry No.");
        WSCWSServicesLogHeaders.FilterGroup(0);
        Page.RunModal(0, WSCWSServicesLogHeaders);
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