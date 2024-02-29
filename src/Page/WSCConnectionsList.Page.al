page 81001 "WSC Connections List"
{
    Caption = 'Connections List (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Connections";
    SourceTableView = sorting("WSC Group Code", "WSC Indentation", "WSC Code");
    CardPageID = "WSC Connection Card";
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                IndentationColumn = Rec."WSC Indentation";
                IndentationControls = "WSC Description";
                ShowAsTree = true;

                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Emphasize;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Emphasize;
                }
                field("WSC Type"; Rec."WSC Type")
                {
                    ApplicationArea = All;
                }
                field("WSC HTTP Method"; Rec."WSC HTTP Method")
                {
                    ApplicationArea = All;
                    HideValue = HideValue;
                }
                field("WSC EndPoint"; Rec."WSC EndPoint")
                {
                    ApplicationArea = All;
                }
                field("WSC Auth. Type"; Rec."WSC Auth. Type")
                {
                    ApplicationArea = All;
                    HideValue = HideValue;
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

                action(Functions)
                {
                    ToolTip = 'Set Functions to execute after the Web Service call';
                    Caption = 'Functions';
                    ApplicationArea = All;
                    Image = Process;
                    trigger OnAction()
                    var
                        Functions: Record "WSC Functions";
                    begin
                        Functions.ViewFunctions(Rec."WSC Code");
                    end;
                }

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
                    WebServicesManagement.ExecuteConnections(Rec."WSC Code", true, LogCalls);
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
                    CurrPage.Update(true);
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

            group(Category_Category5)
            {
                Caption = 'Request Details';
                actionref(Functions_Promoted; Functions) { }
                actionref(Parameters_Promoted; Parameters) { }
                actionref(Headers_Promoted; Headers) { }
                actionref(Bodies_Promoted; Bodies) { }
            }
            actionref(SendRequest_Promoted; SendRequest) { }
            group(Category_Category6)
            {
                Caption = 'Configuration';
                Image = Setup;
                actionref(DownloadWSConfiguration_Promoted; DownloadWSConfiguration) { }
                actionref(ImportWSConfiguration_Promoted; ImportWSConfiguration) { }
            }
            actionref(ViewLog_Promoted; ViewLog) { }
        }
    }
    trigger OnAfterGetRecord()
    begin
        Emphasize := (Rec."WSC Indentation" in [0, 1]);
        HideValue := not (Rec."WSC Type" in [Rec."WSC Type"::Token, Rec."WSC Type"::Call]);
    end;

    var
        HideValue,
        Emphasize : Boolean;
}