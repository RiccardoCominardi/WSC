/// <summary>
/// Page WSC Web Services Log Bodies (ID 81007).
/// </summary>
page 81007 "WSC Web Services Log Bodies"
{
    Caption = 'Web Services - Log Bodies';
    PageType = List;
    SourceTable = "WSC Web Services Log Bodies";
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