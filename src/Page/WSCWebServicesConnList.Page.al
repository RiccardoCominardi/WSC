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
        area(Navigation)
        {
            group(RequestDetails)
            {
                Caption = 'Request Details';
                Image = SetupLines;
                action(Headers)
                {
                    ApplicationArea = All;
                    Image = SetupList;
                    Caption = 'Headers';
                    ToolTip = 'Set Header information for the Web Service call';
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
                    Image = SetupList;

                    trigger OnAction()
                    var
                        WSCWSServicesBodies: Record "WSC Web Services Bodies";
                    begin
                        WSCWSServicesBodies.ViewLog(Rec."WSC Code");
                    end;
                }
            }
            action(ViewLog)
            {
                Caption = 'View Log';
                ToolTip = 'View Web Service log for this Code';
                ApplicationArea = All;
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
                Image = BOMLevel;

                trigger OnAction()
                var
                    WSCWSServicesMgt: Codeunit "WSC Web Services Management";
                begin
                    WSCWSServicesMgt.ShowWSCAsTree();
                end;
            }
        }

        area(Processing)
        {
            action(SendRequest)
            {
                Caption = 'Send Request';
                ToolTip = 'Send the Web Service request';
                ApplicationArea = All;
                Image = "Invoicing-MDL-Send";

                trigger OnAction()
                var
                    WSCWebServicesLogCalls: Record "WSC Web Services Log Calls";
                    WSCWSServicesMgt: Codeunit "WSC Web Services Management";
                begin
                    WSCWSServicesMgt.ExecuteWSCConnections(Rec."WSC Code", WSCWebServicesLogCalls);
                end;
            }
            action(TEST)
            {
                Caption = 'TEST';
                ApplicationArea = All;
                Image = TestFile;
                Visible = false;
                Enabled = false;

                trigger OnAction()
                var
                    WSCWSServicesExamples: Codeunit "WSC Web Services Examples";
                begin
                    WSCWSServicesExamples.ExecuteWSCTestCodeWithCustomBody();
                end;
            }
            action(ImportWSConfiguration)
            {
                Caption = 'Import WS Configuration';
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    ImportExportConfig: Codeunit "WSC Import Export Config.";
                begin
                    ImportExportConfig.ImportWSCFromJson();
                end;
            }
            action(DownloadWSConfiguration)
            {
                Caption = 'Download WS Configuration';
                ApplicationArea = All;
                Image = Download;
                trigger OnAction()
                var
                    ImportExportConfig: Codeunit "WSC Import Export Config.";
                begin
                    ImportExportConfig.ExportWSCJson(Rec."WSC Code");
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(SendRequest_Promoted; SendRequest) { }
                group(Category_Category6)
                {
                    Caption = 'Configuration';
                    Image = Setup;
                    actionref(DownloadWSConfiguration_Promoted; DownloadWSConfiguration) { }
                    actionref(ImportWSConfiguration_Promoted; ImportWSConfiguration) { }
                }
            }
            group(Category_Category5)
            {
                Caption = 'Request Details';

                actionref(Headers_Promoted; Headers) { }
                actionref(Bodies_Promoted; Bodies) { }
            }
            group(Category_Category12)
            {
                Caption = 'Navigate';

                actionref(ViewLog_Promoted; ViewLog) { }
                actionref(ViewAsTree_Promoted; ViewAsTree) { }
            }
        }
    }
}