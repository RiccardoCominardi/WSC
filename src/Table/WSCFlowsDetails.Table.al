table 81008 "WSC Flows Details"
{
    Caption = 'Flows Details (WSC)';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "WSC Flow Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Flow Code';
        }
        field(2; "WSC Connection Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Connection Code';
            NotBlank = true;
        }
        field(3; "WSC Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("WSC Connections"."WSC Description" where("WSC Code" = field("WSC Connection Code")));
            Caption = 'Description';
            Editable = false;
        }
        field(4; "WSC Type"; Enum "WSC Types")
        {
            FieldClass = FlowField;
            CalcFormula = lookup("WSC Connections"."WSC Type" where("WSC Code" = field("WSC Connection Code")));
            Caption = 'Type';
            Editable = false;
        }
        field(5; "WSC Sorting"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sorting';
        }
        field(6; "WCS Sleeping Time Type"; Enum "WSC Sleeping Time Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Sleeping Time Type';
            trigger OnValidate()
            begin
                if Rec."WCS Sleeping Time Type" = Rec."WCS Sleeping Time Type"::" " then
                    Rec."WCS Sleeping Time" := 0;
            end;
        }
        field(7; "WCS Sleeping Time"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sleeping Time (ms)';
            BlankZero = true;
            trigger OnValidate()
            begin
                if Rec."WCS Sleeping Time Type" = Rec."WCS Sleeping Time Type"::" " then
                    Rec."WCS Sleeping Time" := 0;
            end;
        }
        field(8; "WSC Last Flow Status"; Enum "WSC Flow Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Last Status';
        }
        field(9; "WSC Last Message Status"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Message Status';
        }
    }

    keys
    {
        key(Key1; "WSC Flow Code", "WSC Connection Code")
        {
            Clustered = true;
        }
        key(Key2; "WSC Sorting")
        {
        }
    }

    trigger OnInsert()
    begin
        UpdateFields();
        InsertTokenCall();
    end;

    trigger OnDelete()
    begin
        DeleteTokenCall();
    end;

    procedure ValidateConnectionsTableRelation()
    var
        Connections: Record "WSC Connections";
    begin
        //Not possible to put tablerelation directly in the table
        Connections.Get(Rec."WSC Connection Code");
        Connections.TestField("WSC Type", Connections."WSC Type"::Call);
    end;

    local procedure UpdateFields()
    var
        FlowsDetails: Record "WSC Flows Details";
    begin
        //Sorting
        FlowsDetails.Reset();
        FlowsDetails.SetCurrentKey("WSC Sorting");
        FlowsDetails.SetRange("WSC Flow Code", Rec."WSC Flow Code");
        FlowsDetails.SetRange("WSC Type", FlowsDetails."WSC Type"::Call);
        FlowsDetails.ReadIsolation := IsolationLevel::ReadUncommitted;
        if FlowsDetails.IsEmpty() then
            Rec."WSC Sorting" := 1
        else begin
            FlowsDetails.FindLast();
            Rec."WSC Sorting" := FlowsDetails."WSC Sorting" + 1;
        end;

        Rec."WSC Type" := Rec."WSC Type"::Call;
    end;

    local procedure InsertTokenCall()
    var
        FlowsDetails: Record "WSC Flows Details";
        Connections: Record "WSC Connections";
    begin
        if Connections.Get(Rec."WSC Connection Code") then
            if Connections."WSC Bearer Connection Code" <> '' then
                if not FlowsDetails.Get(Rec."WSC Flow Code", Connections."WSC Bearer Connection Code") then begin
                    FlowsDetails.Init();
                    FlowsDetails."WSC Flow Code" := Rec."WSC Flow Code";
                    FlowsDetails."WSC Connection Code" := Connections."WSC Bearer Connection Code";
                    FlowsDetails."WSC Type" := FlowsDetails."WSC Type"::Token;
                    FlowsDetails.Insert();
                end;
    end;

    local procedure DeleteTokenCall()
    var
        FlowsDetails: Record "WSC Flows Details";
        Connections: Record "WSC Connections";
    begin
        if Connections.Get(Rec."WSC Connection Code") then
            if Connections."WSC Bearer Connection Code" <> '' then
                if FlowsDetails.Get(Rec."WSC Flow Code", Connections."WSC Bearer Connection Code") then
                    FlowsDetails.Delete();
    end;

    procedure ChangeSorting(Level: Integer)
    var
        FlowsDetails: Record "WSC Flows Details";
    begin
        if not (Level In [-1, 1]) then
            exit;

        FlowsDetails.Reset();
        FlowsDetails.SetRange("WSC Flow Code", Rec."WSC Flow Code");
        FlowsDetails.SetFilter("WSC Connection Code", '<> %1', Rec."WSC Connection Code");
        if FlowsDetails.IsEmpty() then
            exit;

        Rec."WSC Sorting" += Level;
        Rec.Modify();
        UpdateRelatedSorting(Rec, Level);
    end;

    local procedure UpdateRelatedSorting(FlowsDetails: Record "WSC Flows Details"; Level: Integer)
    var
        RelatedFlowsDetails: Record "WSC Flows Details";
    begin
        RelatedFlowsDetails.Reset();
        RelatedFlowsDetails.SetRange("WSC Flow Code", FlowsDetails."WSC Flow Code");
        RelatedFlowsDetails.SetRange("WSC Sorting", FlowsDetails."WSC Sorting");
        RelatedFlowsDetails.SetFilter("WSC Connection Code", '<> %1', FlowsDetails."WSC Connection Code");
        if RelatedFlowsDetails.IsEmpty() then
            exit;

        RelatedFlowsDetails.FindFirst();
        RelatedFlowsDetails."WSC Sorting" -= Level;
        RelatedFlowsDetails.Modify();
        UpdateRelatedSorting(FlowsDetails, Level);
    end;
}