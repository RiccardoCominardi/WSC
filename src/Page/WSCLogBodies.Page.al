/// <summary>
/// Page WSC Log Bodies (ID 81007).
/// </summary>
page 81007 "WSC Log Bodies"
{
    Caption = 'Log Bodies';
    PageType = List;
    SourceTable = "WSC Log Bodies";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
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