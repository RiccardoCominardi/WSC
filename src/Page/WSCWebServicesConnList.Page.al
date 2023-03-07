/// <summary>
/// Page WSC Web Services Conn. List (ID 81001).
/// </summary>
page 81001 "WSC Web Services Conn. List"
{
    Caption = 'Web Services Connections';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Web Services Connections";
    CardPageID = "WSC Web Service Conn. Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
                field("WSC HTTP Method"; Rec."WSC HTTP Method")
                {
                    ApplicationArea = All;
                }
                field("WSC EndPoint"; Rec."WSC EndPoint")
                {
                    ApplicationArea = All;
                }
                field("WSC Auth. Type"; Rec."WSC Auth. Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Headers)
            {
                Caption = 'Headers';
                ToolTip = 'Set Header information for the Web Service call';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = SetupList;

                trigger OnAction()
                var
                    WSCWSServicesHeaders: Record "WSC Web Services Headers";
                begin
                    WSCWSServicesHeaders.Reset();
                    WSCWSServicesHeaders.FilterGroup(2);
                    WSCWSServicesHeaders.SetRange("WSC Code", Rec."WSC Code");
                    WSCWSServicesHeaders.FilterGroup(0);
                    Page.RunModal(0, WSCWSServicesHeaders);
                end;
            }
            action(Bodies)
            {
                Caption = 'Bodies';
                ToolTip = 'Set Bodies information for the Web Service call';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = SetupList;
                Visible = BodiesVisible;

                trigger OnAction()
                var
                    WSCWSServicesBodies: Record "WSC Web Services Bodies";
                begin
                    WSCWSServicesBodies.Reset();
                    WSCWSServicesBodies.FilterGroup(2);
                    WSCWSServicesBodies.SetRange("WSC Code", Rec."WSC Code");
                    WSCWSServicesBodies.FilterGroup(0);
                    Page.RunModal(0, WSCWSServicesBodies);
                end;
            }
            action(SendRequest)
            {
                Caption = 'Send Request';
                ToolTip = 'Send the Web Service request';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = "Invoicing-MDL-Send";

                trigger OnAction()
                var
                    WSCWSServicesMgt: Codeunit "WSC Web Services Management";
                begin
                    WSCWSServicesMgt.ExecuteDirectWSCConnections(Rec."WSC Code");
                end;
            }
            action(ViewLog)
            {
                Caption = 'View Log';
                ToolTip = 'View Web Service log for this Code';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = Log;

                trigger OnAction()
                var
                    WSCWSServicesLogCalls: Record "WSC Web Services Log Calls";
                begin
                    WSCWSServicesLogCalls.Reset();
                    WSCWSServicesLogCalls.FilterGroup(2);
                    WSCWSServicesLogCalls.SetRange("WSC Code", Rec."WSC Code");
                    WSCWSServicesLogCalls.FilterGroup(0);
                    Page.RunModal(0, WSCWSServicesLogCalls);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetEditableVariables();
    end;

    local procedure SetEditableVariables()
    begin
        CredentialsEditable := Rec."WSC Auth. Type" = Rec."WSC Auth. Type"::Basic;
    end;

    local procedure SetVisibleVariables()
    begin
        BodiesVisible := Rec."WSC Body Type" in [Rec."WSC Body Type"::"Form Data", Rec."WSC Body Type"::"x-www-form-urlencoded"];
    end;

    var
        CredentialsEditable: Boolean;
        BodiesVisible: Boolean;
}