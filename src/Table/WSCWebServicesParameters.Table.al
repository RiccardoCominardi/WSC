/// <summary>
/// Table WSC Web Services Parameters (ID 81010).
/// </summary>
table 81010 "WSC Web Services Parameters"
{
    Caption = 'Web Services - Parameters';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Parameters";
    LookupPageId = "WSC Web Services Parameters";

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
        WebServicesParameters: Record "WSC Web Services Parameters";
    begin
        WebServicesConnections.Get(WSCCode);

        WebServicesParameters.Reset();
        WebServicesParameters.FilterGroup(2);
        WebServicesParameters.SetRange("WSC Code", WebServicesConnections."WSC Code");
        WebServicesParameters.FilterGroup(0);
        Page.RunModal(0, WebServicesParameters);
    end;

    /// <summary>
    /// IsVariableValues.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure IsVariableValues(): Boolean
    begin
        if StrPos(Rec."WSC Value", '%') > 0 then
            exit(true);
        exit(false);
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