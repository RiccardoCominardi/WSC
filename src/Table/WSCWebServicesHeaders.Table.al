/// <summary>
/// Table WSC Web Services Headers (ID 81002).
/// </summary>
table 81002 "WSC Web Services Headers"
{
    Caption = 'Web Services - Headers';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Headers";
    LookupPageId = "WSC Web Services Headers";

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "WSC Web Services Connections"."WSC Code";
        }
        field(2; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
        }
        field(3; "WSC Value"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
        }
        field(4; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "WSC Code", "WSC Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// ViewLog.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    procedure ViewLog(WSCCode: Code[20])
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        WebServicesHeaders: Record "WSC Web Services Headers";
    begin
        WebServicesConnections.Get(WSCCode);

        WebServicesHeaders.Reset();
        WebServicesHeaders.FilterGroup(2);
        WebServicesHeaders.SetRange("WSC Code", WebServicesConnections."WSC Code");
        WebServicesHeaders.FilterGroup(0);
        Page.RunModal(0, WebServicesHeaders);
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