/// <summary>
/// Table WSC Log Parameters (ID 81011).
/// </summary>
table 81011 "WSC Log Parameters"
{
    Caption = 'Web Services - Log Parameters';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Log Parameters";
    LookupPageId = "WSC Log Parameters";

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
        LogCalls: Record "WSC Log Calls";
        LogParameters: Record "WSC Log Parameters";
    begin
        LogCalls.Get(WSCCode, EntryNo);

        LogParameters.Reset();
        LogParameters.FilterGroup(2);
        LogParameters.SetRange("WSC Code", LogCalls."WSC Code");
        LogParameters.SetRange("WSC Log Entry No.", LogCalls."WSC Entry No.");
        LogParameters.FilterGroup(0);
        Page.RunModal(0, LogParameters);
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