page 81006 "WSC Flows"
{
    Caption = 'Flows (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Flows";
    CardPageID = "WSC Flow Card";
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Descrpition"; Rec."WSC Descrpition")
                {
                    ApplicationArea = All;
                }
                field("WSC Enabled"; Rec."WSC Enabled")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}