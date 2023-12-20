/// <summary>
/// Page WSC Web Services Group Codes (ID 81006).
/// </summary>
page 81006 "WSC Web Services Group Codes"
{
    Caption = 'Web Services - Group Codes';
    PageType = List;
    SourceTable = "WSC Web Services Group Codes";

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