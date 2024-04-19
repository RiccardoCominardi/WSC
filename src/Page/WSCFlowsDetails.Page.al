page 81020 "WSC Flows Details"
{
    PageType = ListPart;
    SourceTable = "WSC Flows Details";
    SourceTableView = sorting("WSC Sorting");
    AutoSplitKey = false;
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Connection Code"; Rec."WSC Connection Code")
                {
                    ApplicationArea = All;
                    TableRelation = "WSC Connections"."WSC Code" where("WSC Type" = const("WSC Types"::Call));
                    trigger OnValidate()
                    begin
                        Rec.ValidateConnectionsTableRelation();
                    end;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
                field("WCS Sleeping Time Type"; Rec."WCS Sleeping Time Type")
                {
                    ApplicationArea = All;
                }
                field("WCS Sleeping Time"; Rec."WCS Sleeping Time")
                {
                    ApplicationArea = All;
                }
                field("WSC Last Flow Status"; Rec."WSC Last Flow Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = FieldColour;
                }
                field("WSC Last Message Status"; Rec."WSC Last Message Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = FieldColour;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewLog)
            {
                Caption = 'View Log';
                ToolTip = 'View Web Service log for this connection code';
                ApplicationArea = All;
                Image = Log;

                trigger OnAction()
                var
                    LogCalls: Record "WSC Log Calls";
                begin
                    LogCalls.ViewLog(Rec."WSC Connection Code");
                end;
            }
            action(MoveUp)
            {
                ApplicationArea = All;
                Caption = 'Move Up';
                Image = MoveUp;

                trigger OnAction()
                begin
                    Rec.ChangeSorting(-1);
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = All;
                Caption = 'Move Down';
                Image = MoveDown;
                trigger OnAction()
                begin
                    Rec.ChangeSorting(1);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetFieldColour();
    end;

    local procedure SetFieldColour()
    begin
        FieldColour := 'Standard';
        case Rec."WSC Last Flow Status" of
            "WSC Flow Status"::Success:
                FieldColour := 'Favorable';
            "WSC Flow Status"::Error:
                FieldColour := 'Unfavorable';
        end;
    end;

    var

        FieldColour: Text;
}