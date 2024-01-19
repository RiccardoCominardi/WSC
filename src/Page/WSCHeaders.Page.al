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