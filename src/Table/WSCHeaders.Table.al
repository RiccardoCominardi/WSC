/// <summary>
/// Table WSC Headers (ID 81002).
/// </summary>
table 81002 "WSC Headers"
{
    Caption = 'Web Services - Headers';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Headers";
    LookupPageId = "WSC Headers";

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "WSC Connections"."WSC Code";
        }
        field(2; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
        }
        field(3; "WSC Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
        }
        field(4; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(5; "WSC Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
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
        Connections: Record "WSC Connections";
        Headers: Record "WSC Headers";
    begin
        Connections.Get(WSCCode);

        Headers.Reset();
        Headers.FilterGroup(2);
        Headers.SetRange("WSC Code", Connections."WSC Code");
        Headers.FilterGroup(0);
        Page.RunModal(0, Headers);
    end;

    trigger OnInsert()
    begin
        Rec."WSC Enabled" := true;
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