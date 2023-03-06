/// <summary>
/// Page WSC Web Services Headers (ID 81003).
/// </summary>
page 81003 "WSC Web Services Headers"
{
    Caption = 'Web Services - Headers';
    PageType = List;
    SourceTable = "WSC Web Services Headers";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Key"; Rec."WSC Key")
                {
                    ApplicationArea = All;
                }
                field("WSC Value"; Rec."WSC Value")
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