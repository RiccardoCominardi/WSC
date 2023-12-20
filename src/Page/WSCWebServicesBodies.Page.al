/// <summary>
/// Page WSC Web Services Bodies (ID 81004).
/// </summary>
page 81004 "WSC Web Services Bodies"
{
    Caption = 'Web Services - Bodies';
    PageType = List;
    SourceTable = "WSC Web Services Bodies";

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