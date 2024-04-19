table 81007 "WSC Flows"
{
    Caption = 'Flows (WSC)';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Flows";
    LookupPageId = "WSC Flows";

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; "WSC Descrpition"; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "WSC Enabled"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
        }
        field(4; "WSC Last Flow Status"; Enum "WSC Flow Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(5; "WSC Last Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Date-Time';
        }
    }

    keys
    {
        key(Key1; "WSC Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        FlowsDetails: Record "WSC Flows Details";
    begin
        FlowsDetails.Reset();
        FlowsDetails.SetRange("WSC Flow Code", Rec."WSC Code");
        FlowsDetails.DeleteAll();
    end;

}