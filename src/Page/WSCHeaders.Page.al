/// <summary>
/// Page WSC Headers (ID 81003).
/// </summary>
page 81003 "WSC Headers"
{
    Caption = 'Headers';
    PageType = List;
    SourceTable = "WSC Headers";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Enabled"; Rec."WSC Enabled")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Key"; Rec."WSC Key")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Value"; Rec."WSC Value")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."WSC Enabled" := true;
    end;
}