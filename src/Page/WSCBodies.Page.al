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
                field("WSC Key"; Rec."WSC Key")
                {
                    ApplicationArea = All;
                }
                field("WSC ValueAsText"; ValueAsText)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    trigger OnValidate()
                    begin
                        Rec.SetValue(ValueAsText);
                    end;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
                field("WSC Is Secret"; Rec."WSC Is Secret")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.ConvertValue();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ValueAsText := Rec.GetValue();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ValueAsText := '';
    end;

    protected var

        ValueAsText: Text;
}