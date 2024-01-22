/// <summary>
/// Page WSC Connections List (ID 81001).
/// </summary>
page 81001 "WSC Connections List"
{
    Caption = 'Connections List (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Connections";
    CardPageID = "WSC Connection Card";
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
                action(Parameters)
                {
                    ApplicationArea = All;
                    Image = SetupList;
                    Caption = 'Parameters';
                    ToolTip = 'Set Parameter information for the Web Service call';
                    trigger OnAction()
                    var
                        Parameters: Record "WSC Parameters";
                    begin
                        Parameters.ViewLog(Rec."WSC Code");
                    end;
                }
                action(Headers)
                {
                    ApplicationArea = All;
                    Image = SetupList;
                    Caption = 'Headers';
                    ToolTip = 'Set Header information for the Web Service call';
                    trigger OnAction()
                    var
                        Headers: Record "WSC Headers";
                    begin
                        Headers.ViewLog(Rec."WSC Code");
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
                        Bodies: Record "WSC Bodies";
                    begin
                        Bodies.ViewLog(Rec."WSC Code");
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
                    LogCalls: Record "WSC Log Calls";
                begin
                    LogCalls.ViewLog(Rec."WSC Code");
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
                    WebServicesManagement: Codeunit "WSC Managements";
                begin
                    WebServicesManagement.ShowWSCAsTree();
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
                    LogCalls: Record "WSC Log Calls";
                    WebServicesManagement: Codeunit "WSC Managements";
                begin
                    WebServicesManagement.ExecuteConnections(Rec."WSC Code", LogCalls);
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
                    Examples: Codeunit "WSC Examples";
                begin
                    Examples.ExecuteWSCTestCodeWithCustomBody();
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

                actionref(Parameters_Promoted; Parameters) { }
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