/// <summary>
/// Page WSC Web Service Conn. Card (ID 81002).
/// </summary>
page 81002 "WSC Web Service Conn. Card"
{
    Caption = 'Web Service Connection Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "WSC Web Services Connections";

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
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("WSC Body Type"; Rec."WSC Body Type")
                {
                    ApplicationArea = All;
                }
                field("WSC Password"; Rec."WSC Password")
                {
                    ApplicationArea = All;
                    Editable = CredentialsEditable;
                }
                field("WSC Username"; Rec."WSC Username")
                {
                    ApplicationArea = All;
                    Editable = CredentialsEditable;
                }
            }
            group(Token)
            {
                Caption = 'Token';

                field("WSC Bearer Connection"; Rec."WSC Bearer Connection")
                {
                    ApplicationArea = All;
                }
                field("WSC Bearer Connection Code"; Rec."WSC Bearer Connection Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Access Token"; Rec."WSC Access Token".HasValue)
                {
                    Caption = 'Access Token Active';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("WSC Refresh Token"; Rec."WSC Refresh Token".HasValue)
                {
                    Caption = 'Refresh Token Active';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("WSC Authorization Time"; Rec."WSC Authorization Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("WSC Expire In"; Rec."WSC Expire In")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    WSCWSServicesBodies.SetRange("WSC Body Type", Rec."WSC Body Type");
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