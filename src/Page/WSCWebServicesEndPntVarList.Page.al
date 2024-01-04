/// <summary>
/// Page WSC EndPoint Var List (ID 81011).
/// </summary>
page 81011 "WSC Web Services EndPntVarList"
{
    Caption = 'Web Services - EndPoint Variables';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Web Services EndPoint Var.";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
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
}