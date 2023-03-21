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
                field("WSC Group Code"; Rec."WSC Group Code")
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
                field("WSC Bearer Connection"; Rec."WSC Bearer Connection")
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
                    WSCWSServicesHeaders.ViewLog(Rec."WSC Code");
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

                trigger OnAction()
                var
                    WSCWSServicesBodies: Record "WSC Web Services Bodies";
                begin
                    WSCWSServicesBodies.ViewLog(Rec."WSC Code");
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
                    WSCWSServicesLogCalls.ViewLog(Rec."WSC Code");
                end;
            }
            action(ViewAsTree)
            {
                Caption = 'View As Tree';
                ToolTip = 'View Web Service Calls with tree visualization';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = BOMLevel;

                trigger OnAction()
                var
                    WSCWSServicesMgt: Codeunit "WSC Web Services Management";
                begin
                    WSCWSServicesMgt.ShowWSCAsTree();
                end;
            }
            action(TEST)
            {
                Caption = 'TEST';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = TestFile;

                trigger OnAction()
                var
                    WSCWSServicesExamples: Codeunit "WSC Web Services Examples";
                begin
                    WSCWSServicesExamples.ExecuteWSCTestCodeWithCustomBody();
                end;
            }
        }
    }
}