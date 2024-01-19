/// <summary>
/// Page WSC Group Codes (ID 81006).
/// </summary>
page 81006 "WSC Group Codes"
{
    Caption = 'Group Codes (WSC)';
    PageType = List;
    SourceTable = "WSC Group Codes";

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
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}