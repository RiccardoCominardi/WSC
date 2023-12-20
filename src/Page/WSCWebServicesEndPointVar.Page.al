/// <summary>
/// Page WSC Web Services EndPoint Var. (ID 81010).
/// </summary>
page 81010 "WSC Web Services EndPoint Var."
{
    Caption = 'EndPoint Variables';
    PageType = ListPart;
    SourceTable = "WSC Web Services EndPoint Var.";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

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