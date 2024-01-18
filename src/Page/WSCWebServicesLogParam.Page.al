/// <summary>
/// Page WSC Web Services Log Param. (ID 81014).
/// </summary>
page 81014 "WSC Web Services Log Param."
{
    Caption = 'Web Services - Log Parameters';
    PageType = List;
    SourceTable = "WSC Web Services Log Param.";
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