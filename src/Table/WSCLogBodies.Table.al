/// <summary>
/// Table WSC Log Bodies (ID 81006).
/// </summary>
table 81006 "WSC Log Bodies"
{
    Caption = 'Web Services - Log Bodies';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Log Bodies";
    LookupPageId = "WSC Log Bodies";

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
        LogBodies: Record "WSC Log Bodies";
    begin
        LogCalls.Get(WSCCode, EntryNo);

        LogBodies.Reset();
        LogBodies.FilterGroup(2);
        LogBodies.SetRange("WSC Code", LogCalls."WSC Code");
        LogBodies.SetRange("WSC Log Entry No.", LogCalls."WSC Entry No.");
        LogBodies.FilterGroup(0);
        Page.RunModal(0, LogBodies);
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