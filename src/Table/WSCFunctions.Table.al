/// <summary>
/// Table WSC Functions (ID 81013).
/// </summary>
table 81013 "WSC Functions"
{
    Caption = 'Functions';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Functions";
    LookupPageId = "WSC Functions";

    fields
    {
        field(1; "WSC Connection Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Connection Code';
            TableRelation = "WSC Connections"."WSC Code";
        }
        field(2; "WSC Code"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(3; "WSC Sequence"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sequence';
            trigger OnValidate()
            var
                Functions: Record "WSC Functions";
                Text000Err: Label 'Cannot exits two functions with the same sequence';
            begin
                Functions.Reset();
                Functions.SetRange("WSC Connection Code", Rec."WSC Connection Code");
                Functions.SetRange("WSC Sequence", Rec."WSC Sequence");
                Functions.SetFilter("WSC Code", '<> %1', Rec."WSC Code");
                if not Functions.IsEmpty() then
                    Error(Text000Err);
            end;
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
        field(6; "WSC Custom"; Boolean)
        {
            Caption = 'Custom Function';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "WSC GuiAllowed"; Boolean)
        {
            Caption = 'GuiAllowed';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "WSC Connection Code", "WSC Code")
        {
            Clustered = true;
        }
        key(Key2; "WSC Sequence")
        {
        }
    }

    /// <summary>
    /// ViewFunctions.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    procedure ViewFunctions(WSCCode: Code[20])
    var
        Connections: Record "WSC Connections";
        Functions: Record "WSC Functions";
        FunctionsPage: Page "WSC Functions";
    begin
        Connections.Get(WSCCode);

        Functions.Reset();
        Functions.FilterGroup(2);
        Functions.SetRange("WSC Connection Code", Connections."WSC Code");
        Functions.FilterGroup(0);

        FunctionsPage.SetTableView(Functions);
        FunctionsPage.IsFromConnVisibility(true);
        FunctionsPage.Editable(true);
        FunctionsPage.RunModal();
    end;

    /// <summary>
    /// InitializeSequence.
    /// </summary>
    procedure InitializeSequence()
    var
        Functions: Record "WSC Functions";
    begin
        Functions.Reset();
        Functions.SetRange("WSC Connection Code", Rec."WSC Connection Code");
        if Functions.IsEmpty() then
            Rec."WSC Sequence" := 0
        else begin
            Functions.FindLast();
            Rec."WSC Sequence" := Functions."WSC Sequence" + 1;
        end;
    end;

    /// <summary>
    /// ChangeSequence.
    /// </summary>
    /// <param name="Level">Integer.</param>
    procedure ChangeSequence(Level: Integer)
    var
        Functions: Record "WSC Functions";
    begin
        if not (Level In [-1, 1]) then
            exit;

        Functions.Reset();
        Functions.SetRange("WSC Connection Code", Rec."WSC Connection Code");
        Functions.SetFilter("WSC Code", '<> %1', Rec."WSC Code");
        if Functions.IsEmpty() then
            exit;

        Rec."WSC Sequence" += Level;
        Rec.Modify();
        UpdateRelatedSequence(Rec, Level);
    end;

    local procedure UpdateRelatedSequence(Functions: Record "WSC Functions"; Level: Integer)
    var
        RelatedFunctions: Record "WSC Functions";
    begin
        RelatedFunctions.Reset();
        RelatedFunctions.SetRange("WSC Connection Code", Functions."WSC Connection Code");
        RelatedFunctions.SetRange("WSC Sequence", Functions."WSC Sequence");
        RelatedFunctions.SetFilter("WSC Code", '<> %1', Functions."WSC Code");
        if RelatedFunctions.IsEmpty() then
            exit;

        RelatedFunctions.FindFirst();
        RelatedFunctions."WSC Sequence" -= Level;
        RelatedFunctions.Modify();
        UpdateRelatedSequence(RelatedFunctions, Level);
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