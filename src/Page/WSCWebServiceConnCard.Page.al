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
            part(WebServicesEndPointVar; "WSC Web Services EndPoint Var.")
            {
                ApplicationArea = All;
                Caption = 'EndPoint Variables';
            }
            part(WebServicesParamFactbox; "WSC Web Services Param Factbox")
            {
                ApplicationArea = All;
                Caption = 'Parameters';
                SubPageLink = "WSC Code" = field("WSC Code");
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
            action(Parameters)
            {
                ToolTip = 'Set Parameter information for the Web Service call';
                Caption = 'Parameters';
                ApplicationArea = All;
                Image = SetupList;
                trigger OnAction()
                var
                    WebServicesParameters: Record "WSC Web Services Parameters";
                begin
                    WebServicesParameters.ViewLog(Rec."WSC Code");
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
                    WebServicesHeaders: Record "WSC Web Services Headers";
                begin
                    WebServicesHeaders.ViewLog(Rec."WSC Code");
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
                    WebServicesBodies: Record "WSC Web Services Bodies";
                begin
                    WebServicesBodies.ViewLog(Rec."WSC Code");
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
                    WebServicesLogCalls: Record "WSC Web Services Log Calls";
                    WebServicesManagement: Codeunit "WSC Web Services Management";
                begin
                    WebServicesManagement.ExecuteWSCConnections(Rec."WSC Code", WebServicesLogCalls);
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
                    WebServicesLogCalls: Record "WSC Web Services Log Calls";
                begin
                    WebServicesLogCalls.ViewLog(Rec."WSC Code");
                end;
            }
        }

        area(Promoted)
        {
            actionref(Parameters_Promoted; Parameters) { }
            actionref(Headers_Promoted; Headers) { }
            actionref(Bodies_Promoted; Bodies) { }
            actionref(SendRequest_Promoted; SendRequest) { }
            actionref(ViewLog_Promoted; ViewLog) { }
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
        WebServicesEndPointVar: Record "WSC Web Services EndPoint Var.";
        Text000Lbl: Label 'EndPoint containes variables';
        Found: Boolean;
    begin
        Found := false;
        EndPointColor := 'Standard';
        EndPointWithVar := '';
        WebServicesEndPointVar.Reset();
        if WebServicesEndPointVar.IsEmpty() then
            exit;

        WebServicesEndPointVar.FindSet();
        repeat
            if StrPos(Rec."WSC EndPoint", WebServicesEndPointVar."WSC Variable Name") > 0 then begin
                Found := true;
                EndPointColor := 'Ambiguous';
                EndPointWithVar := Text000Lbl;
            end

        until (WebServicesEndPointVar.Next() = 0) or Found;
    end;

    local procedure SetTokenFields()
    var
        WSCConnBearer: Record "WSC Web Services Connections";
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
                if WSCConnBearer."WSC Code" <> Rec."WSC Bearer Connection Code" then begin
                    WSCConnBearer.Get(Rec."WSC Bearer Connection Code");
                    TokenPresent := SecurityManagements.HasToken(WSCConnBearer."WSC Access Token", WSCConnBearer.GetTokenDataScope());
                    TokenAuth := WSCConnBearer."WSC Authorization Time";
                    if IsExpiredToken(TokenAuth, WSCConnBearer."WSC Expires In") then begin
                        TokenStatus := Text001Lbl;
                        TokenColor := 'Unfavorable'
                    end else begin
                        TokenStatus := Text002Lbl;
                        TokenColor := 'Favorable';
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