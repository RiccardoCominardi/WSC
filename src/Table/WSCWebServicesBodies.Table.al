/// <summary>
/// Table WSC Web Services Bodies (ID 81003).
/// </summary>
table 81003 "WSC Web Services Bodies"
{
    Caption = 'Web Services - Bodies';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Bodies";
    LookupPageId = "WSC Web Services Bodies";

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
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
    begin
        WSCWSServicesConnections.Get(WSCCode);
        if not (WSCWSServicesConnections."WSC Body Type" in [WSCWSServicesConnections."WSC Body Type"::"form data", WSCWSServicesConnections."WSC Body Type"::"x-www-form-urlencoded"]) then
            exit;

        WSCWSServicesBodies.Reset();
        WSCWSServicesBodies.FilterGroup(2);
        WSCWSServicesBodies.SetRange("WSC Code", WSCWSServicesConnections."WSC Code");
        WSCWSServicesBodies.FilterGroup(0);
        Page.RunModal(0, WSCWSServicesBodies);
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