/// <summary>
/// Page WSC Connection Card (ID 81002).
/// </summary>
page 81002 "WSC Connection Card"
{
    Caption = 'Connection Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "WSC Connections";

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
                    MultiLine = true;
                }
                field("WSC EndPointWithVar"; EndPointWithVar)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    StyleExpr = EndPointColor;
                }
                field("WSC Allow Blank Response"; Rec."WSC Allow Blank Response")
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
                    trigger OnValidate()
                    begin
                        case Rec."WSC Body Type" of
                            Rec."WSC Body Type"::none,
                            Rec."WSC Body Type"::"form data",
                            Rec."WSC Body Type"::GraphQL,
                            Rec."WSC Body Type"::"x-www-form-urlencoded":
                                Rec."WSC Body Method" := Rec."WSC Body Method"::" ";
                        end;
                        CurrPage.Update(true);
                    end;
                }
                field("WSC Body Method"; Rec."WSC Body Method")
                {
                    ApplicationArea = All;
                    Editable = BodyMethodEditable;
                }
                field("WSC Zip Response"; Rec."WSC Zip Response")
                {
                    ApplicationArea = All;
                }
                field("WSC Store Parameters Datas"; Rec."WSC Store Parameters Datas")
                {
                    ApplicationArea = All;
                }

                field("WSC Store Headers Datas"; Rec."WSC Store Headers Datas")
                {
                    ApplicationArea = All;
                }
                field("WSC Store Body Datas"; Rec."WSC Store Body Datas")
                {
                    ApplicationArea = All;
                }

                group(Credentials)
                {
                    Caption = 'Credentials';
                    field("WSC Username"; Rec."WSC Username")
                    {
                        ApplicationArea = All;
                        Editable = CredentialsEditable;
                    }
                    field("WSC Password"; Password)
                    {
                        ApplicationArea = All;
                        Caption = 'Password';
                        Editable = CredentialsEditable;
                        trigger OnValidate()
                        begin
                            SecurityManagements.SetToken(Rec."WSC Password", Password, Rec.GetTokenDataScope());
                        end;
                    }
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
                field("WSC Access Token"; TokenPresent)
                {
                    Caption = 'Access Token Active';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("WSC Authorization Time"; TokenAuth)
                {
                    Caption = 'Authorization Time';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("WSC TokenStatus"; TokenStatus)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    StyleExpr = TokenColor;
                }
            }
        }
        area(factboxes)
        {
            part(EndPointVariables; "WSC EndPoint Variables Factbox")
            {
                ApplicationArea = All;
                Caption = 'EndPoint Variables';
            }
            part(WebServicesParamFactbox; "WSC Parameters Factbox")
            {
                ApplicationArea = All;
                Caption = 'Parameters';
                SubPageLink = "WSC Code" = field("WSC Code");
            }
            part("WSC Top Calls Charts"; "WSC Top Calls Charts")
            {
                ApplicationArea = All;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
                ToolTip = 'Set Parameter information for the Web Service call';
                Caption = 'Parameters';
                ApplicationArea = All;
                Image = SetupList;
                trigger OnAction()
                var
                    Parameters: Record "WSC Parameters";
                begin
                    Parameters.ViewLog(Rec."WSC Code");
                end;
            }
            action(Headers)
            {
                Caption = 'Headers';
                ToolTip = 'Set Header information for the Web Service call';
                ApplicationArea = All;
                Image = SetupList;

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
                    CurrPage."WSC Top Calls Charts".Page.UpdateChart();
                end;
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
            action(ViewAccessToken)
            {
                Caption = 'View Access Token';
                ToolTip = 'View last Access Token saved';
                ApplicationArea = All;
                Image = View;

                trigger OnAction()
                var
                    SecurityManagements: Codeunit "WSC Security Managements";
                begin
                    Message(SecurityManagements.GetToken(Rec."WSC Access Token", Rec.GetTokenDataScope()));
                end;
            }
        }

        area(Promoted)
        {
            actionref(Functions_Promoted; Functions) { }
            actionref(Parameters_Promoted; Parameters) { }
            actionref(Headers_Promoted; Headers) { }
            actionref(Bodies_Promoted; Bodies) { }
            actionref(SendRequest_Promoted; SendRequest) { }
            actionref(ViewLog_Promoted; ViewLog) { }
            actionref(ViewAccessToken_Promoted; ViewAccessToken) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetEditableVariables();
        SetTokenFields();
        SetEndPointFields();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Password := SecurityManagements.GetToken(Rec."WSC Password", Rec.GetTokenDataScope());
    end;

    local procedure SetEditableVariables()
    begin
        CredentialsEditable := Rec."WSC Auth. Type" = Rec."WSC Auth. Type"::Basic;
        BodyMethodEditable := Rec."WSC Body Type" in [Rec."WSC Body Type"::raw, Rec."WSC Body Type"::binary];
    end;

    local procedure SetEndPointFields()
    var
        EndPointVariables: Record "WSC EndPoint Variables";
        Text000Lbl: Label 'EndPoint containes variables';
        Found: Boolean;
    begin
        Found := false;
        EndPointColor := 'Standard';
        EndPointWithVar := '';
        EndPointVariables.Reset();
        if EndPointVariables.IsEmpty() then
            exit;

        EndPointVariables.FindSet();
        repeat
            if StrPos(Rec."WSC EndPoint", EndPointVariables."WSC Variable Name") > 0 then begin
                Found := true;
                EndPointColor := 'Ambiguous';
                EndPointWithVar := Text000Lbl;
            end

        until (EndPointVariables.Next() = 0) or Found;
    end;

    local procedure SetTokenFields()
    var
        ConnectionBearer: Record "WSC Connections";
        Text000Lbl: Label 'No Token';
        Text001Lbl: Label 'Token Expired';
        Text002Lbl: Label 'Token Available';
    begin
        TokenPresent := false;
        TokenAuth := 0DT;
        TokenColor := 'Standard';
        TokenStatus := Text000Lbl;
        if Rec."WSC Bearer Connection" then begin
            TokenPresent := SecurityManagements.HasToken(Rec."WSC Access Token", Rec.GetTokenDataScope());
            TokenAuth := Rec."WSC Authorization Time";
            if IsExpiredToken(TokenAuth, Rec."WSC Expires In") then begin
                TokenStatus := Text001Lbl;
                TokenColor := 'Unfavorable'
            end else begin
                TokenStatus := Text002Lbl;
                TokenColor := 'Favorable';
            end;
        end else
            if Rec."WSC Bearer Connection Code" <> '' then
                if ConnectionBearer."WSC Code" <> Rec."WSC Bearer Connection Code" then begin
                    if ConnectionBearer.Get(Rec."WSC Bearer Connection Code") then begin
                        TokenPresent := SecurityManagements.HasToken(ConnectionBearer."WSC Access Token", ConnectionBearer.GetTokenDataScope());
                        TokenAuth := ConnectionBearer."WSC Authorization Time";
                        if IsExpiredToken(TokenAuth, ConnectionBearer."WSC Expires In") then begin
                            TokenStatus := Text001Lbl;
                            TokenColor := 'Unfavorable'
                        end else begin
                            TokenStatus := Text002Lbl;
                            TokenColor := 'Favorable';
                        end;
                    end;
                end;
    end;

    local procedure IsExpiredToken(ParTokenAuth: DateTime; ParExpireIn: Integer): Boolean
    var
        ElapsedSecs: Integer;
    begin
        if ParTokenAuth = 0DT then
            exit(true);

        ElapsedSecs := Round((CurrentDateTime() - ParTokenAuth) / 1000, 1, '>');
        if (ElapsedSecs < ParExpireIn) and (ElapsedSecs < 3600) then
            exit(false)
        else
            exit(true);
    end;

    var
        SecurityManagements: Codeunit "WSC Security Managements";
        CredentialsEditable,
        BodyMethodEditable,
        TokenPresent : Boolean;
        TokenAuth: DateTime;
        Password,
        TokenStatus,
        TokenColor,
        EndPointWithVar,
        EndPointColor : Text;
}