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
                field("WSC Enabled"; Rec."WSC Enabled")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Key"; Rec."WSC Key")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Value"; Rec."WSC Value")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field(IsVariableValue; IsVariableValue)
                {
                    ApplicationArea = All;
                    Caption = 'Variable Value';
                    Editable = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."WSC Enabled" := true;
    end;

    trigger OnAfterGetRecord()
    begin
        IsVariableValue := Rec.IsVariableValues();
    end;

    var
        IsVariableValue: Boolean;
}