/// <summary>
/// Page WSC Bodies (ID 81004).
/// </summary>
page 81004 "WSC Bodies"
{
    Caption = 'Bodies';
    PageType = List;
    SourceTable = "WSC Bodies";

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
                field("WSC ValueAsText"; ValueAsText)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                    trigger OnValidate()
                    begin
                        Rec.SetValue(ValueAsText);
                    end;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Is Secret"; Rec."WSC Is Secret")
                {
                    ApplicationArea = All;
                    Editable = Rec."WSC Enabled";
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                    trigger OnValidate()
                    begin
                        Rec.ConvertValue();
                    end;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."WSC Enabled" := true;
        ValueAsText := '';
    end;

    trigger OnAfterGetRecord()
    begin
        ValueAsText := Rec.GetValue();
    end;

    protected var

        ValueAsText: Text;
}