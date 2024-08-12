/// <summary>
/// Page WSC EndPoint Var List (ID 81011).
/// </summary>
page 81011 "WSC EndPoint Variables List"
{
    Caption = 'EndPoint Variables (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC EndPoint Variables";
    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Variable Name"; Rec."WSC Variable Name")
                {
                    ApplicationArea = All;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
                field("WSC Custom Var"; Rec."WSC Custom Var")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."WSC Custom Var" := true;
    end;
}