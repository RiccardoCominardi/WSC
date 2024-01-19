/// <summary>
/// Table WSC Parameters (ID 81010).
/// </summary>
table 81010 "WSC Parameters"
{
    Caption = 'Web Services - Parameters';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Parameters";
    LookupPageId = "WSC Parameters";

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
        Connections: Record "WSC Connections";
        Parameters: Record "WSC Parameters";
    begin
        Connections.Get(WSCCode);

        Parameters.Reset();
        Parameters.FilterGroup(2);
        Parameters.SetRange("WSC Code", Connections."WSC Code");
        Parameters.FilterGroup(0);
        Page.RunModal(0, Parameters);
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