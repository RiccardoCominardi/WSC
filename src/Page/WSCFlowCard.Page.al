page 81009 "WSC Flow Card"
{
    Caption = 'Flow Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "WSC Flows";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Descrpition"; Rec."WSC Descrpition")
                {
                    ApplicationArea = All;
                }
                field("WSC Enabled"; Rec."WSC Enabled")
                {
                    ApplicationArea = All;
                }
                group(LastExecution)
                {
                    Caption = 'Last Execution';
                    field("WSC Last Flow Status"; Rec."WSC Last Flow Status")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        StyleExpr = FieldColour;
                    }
                    field("WSC Last Date-Time"; Rec."WSC Last Date-Time")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        StyleExpr = FieldColour;
                    }

                }
            }
            part(WSCFlowsDetailsToken; "WSC Flows Details Limited")
            {
                ApplicationArea = All;
                SubPageLink = "WSC Flow Code" = field("WSC Code");
                SubPageView = where("WSC Type" = const("WSC Types"::Token));
                Caption = 'Token';
            }
            part(WSCFlowsDetailsCall; "WSC Flows Details")
            {
                ApplicationArea = All;
                SubPageLink = "WSC Flow Code" = field("WSC Code");
                SubPageView = where("WSC Type" = const("WSC Types"::Call));
                UpdatePropagation = Both;
                Caption = 'Call';
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExecuteFlow)
            {
                Caption = 'Execute Flow';
                ToolTip = 'Execute flow manually';
                ApplicationArea = All;
                Image = "Invoicing-MDL-Send";
                trigger OnAction()
                var
                    LogCalls: Record "WSC Log Calls";
                    WebServicesManagement: Codeunit "WSC Managements";
                begin
                    WebServicesManagement.ExecuteFlow(Rec."WSC Code");
                end;
            }
        }

        area(Promoted)
        {
            actionref(ExecuteFlow_Promoted; ExecuteFlow) { }
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