/// <summary>
/// Page WSC Web Services Log Headers (ID 81008).
/// </summary>
page 81008 "WSC Web Services Log Headers"
{
    Caption = 'Web Services - Log Headers';
    PageType = List;
    SourceTable = "WSC Web Services Log Headers";
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