/// <summary>
/// Page WSC Parameters (ID 81013).
/// </summary>
page 81013 "WSC Parameters"
{
    Caption = 'Parameters';
    PageType = List;
    SourceTable = "WSC Parameters";

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