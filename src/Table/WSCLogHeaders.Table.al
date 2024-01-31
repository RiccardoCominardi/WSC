/// <summary>
/// Table WSC Log Headers (ID 81005).
/// </summary>
table 81005 "WSC Log Headers"
{
    Caption = 'Web Services - Log Headers';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Log Headers";
    LookupPageId = "WSC Log Headers";

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
            TableRelation = "WSC Connections"."WSC Code";
        }
        field(4; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
        }
        field(5; "WSC Value"; Text[250])
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
        LogCalls: Record "WSC Log Calls";
        LogHeaders: Record "WSC Log Headers";
    begin
        LogCalls.Get(WSCCode, EntryNo);

        LogHeaders.Reset();
        LogHeaders.FilterGroup(2);
        LogHeaders.SetRange("WSC Code", LogCalls."WSC Code");
        LogHeaders.SetRange("WSC Log Entry No.", LogCalls."WSC Entry No.");
        LogHeaders.FilterGroup(0);
        Page.RunModal(0, LogHeaders);
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