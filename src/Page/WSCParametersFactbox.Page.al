/// <summary>
/// Page WSC Parameters Factbox (ID 81015).
/// </summary>
page 81015 "WSC Parameters Factbox"
{
    Caption = 'Parameters';
    PageType = ListPart;
    SourceTable = "WSC Parameters";
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
                field("WSC Key"; Rec."WSC Key")
                {
                    ApplicationArea = All;
                }
                field("WSC Value"; Rec."WSC Value")
                {
                    ApplicationArea = All;
                }
                field(IsVariableValue; IsVariableValue)
                {
                    ApplicationArea = All;
                    Caption = 'Variable Value';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsVariableValue := Rec.IsVariableValues();
    end;

    var
        IsVariableValue: Boolean;
}