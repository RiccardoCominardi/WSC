/// <summary>
/// Page WSC EndPoint Variables Factbox (ID 81010).
/// </summary>
page 81010 "WSC EndPoint Variables Factbox"
{
    Caption = 'EndPoint Variables';
    PageType = ListPart;
    SourceTable = "WSC EndPoint Variables";
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