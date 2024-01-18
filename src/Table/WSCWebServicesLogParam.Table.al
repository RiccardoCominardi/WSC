/// <summary>
/// Table WSC Web Services Log Param. (ID 81011).
/// </summary>
table 81011 "WSC Web Services Log Param."
{
    Caption = 'Web Services - Log Parameters';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Log Param.";
    LookupPageId = "WSC Web Services Log Param.";

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
        WebServicesLogParam: Record "WSC Web Services Log Param.";
    begin
        WebServicesLogCalls.Get(WSCCode, EntryNo);

        WebServicesLogParam.Reset();
        WebServicesLogParam.FilterGroup(2);
        WebServicesLogParam.SetRange("WSC Code", WebServicesLogCalls."WSC Code");
        WebServicesLogParam.SetRange("WSC Log Entry No.", WebServicesLogCalls."WSC Entry No.");
        WebServicesLogParam.FilterGroup(0);
        Page.RunModal(0, WebServicesLogParam);
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