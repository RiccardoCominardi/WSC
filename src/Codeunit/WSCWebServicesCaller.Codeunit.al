/// <summary>
/// Codeunit WSC Web Services Caller (ID 81002).
/// </summary>
codeunit 81002 "WSC Web Services Caller"
{
    TableNo = "WSC Web Services Connections";
    trigger OnRun()
    begin
        ClearGlobalVariables();
        AcquireGlobalWSConnection(Rec."WSC Code");
        PrepareRequest();
    end;

    #region CallFunctions
    local procedure PrepareRequest()
    var
        TempBlob: Codeunit "Temp Blob";
        IsHandled: Boolean;
    begin
        //Initialize Stream Variables
        TempBlob.CreateInStream(BodyInStream);
        TempBlob.CreateInStream(ResponseInStream);

        OnBeforeCalls(IsHandled, GlobalWebServConn);
        if IsHandled then
            exit;

        //Execute Web Service Request
        ExecuteRequest();
    end;

    local procedure ExecuteRequest()
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        FileInBase64: Text;
        OutStr: OutStream;
        InStr: InStream;
        FileInStream: InStream;
        Text000Err: Label 'Connection not estabilished';
        FileName: Text;
        /*Web Service Connection Variables*/
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ContentHeaders: HttpHeaders;
    begin
        //Authentication
        RequestHeaders := Client.DefaultRequestHeaders();
        case GlobalWebServConn."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                RequestHeaders.Add('Authorization', CreateBasicAuthHeader());
            "WSC Authorization Types"::"bearer token":
                RequestHeaders.Add('Authorization', CreateBearerAuthHeader());
        //None: Autenticazione gestita nel Body, vedi esempi di chiamata Bartolini o GLS
        //Bearer: Autenticazione gestita con le Headers
        end;
        OnAfterInitializeRequestHeaders(RequestHeaders, GlobalWebServConn);

        case GlobalWebServConn."WSC HTTP Method" of
            GlobalWebServConn."WSC HTTP Method"::Get,
            GlobalWebServConn."WSC HTTP Method"::Delete:
                if HasBodyValues() then
                    RequestContent.GetHeaders(ContentHeaders)
                else
                    RequestMessage.GetHeaders(ContentHeaders);
            GlobalWebServConn."WSC HTTP Method"::Post,
            GlobalWebServConn."WSC HTTP Method"::Put,
            GlobalWebServConn."WSC HTTP Method"::Patch:
                RequestContent.GetHeaders(ContentHeaders);
        end;

        //Bodies Values
        ContentHeaders.Clear();
        case GlobalWebServConn."WSC Body Type" of
            "WSC Body Types"::"form data",
            "WSC Body Types"::"x-www-form-urlencoded":
                CollectBodies(RequestContent);
            "WSC Body Types"::binary,
            "WSC Body Types"::raw:
                begin
                    case GlobalWebServConn."WSC Body Method" of
                        "WSC Body Methods"::"fixed file":
                            OnSetFixBodyMessage(GlobalWebServConn);
                        "WSC Body Methods"::"request file":
                            begin
                                ImportWithFilter(TempBlob, FileName);
                                if FileName <> '' then begin
                                    GlobalWebServConn."WSC Body Message".CreateOutStream(OutStr);
                                    TempBlob.CreateInStream(FileInStream);
                                    CopyStream(OutStr, FileInStream);
                                end;
                            end;
                        else
                            HandleCustomBodyMethods(GlobalWebServConn);
                    end;

                    GlobalWebServConn.CalcFields("WSC Body Message");
                    if GlobalWebServConn."WSC Body Message".HasValue() then begin
                        GlobalWebServConn."WSC Body Message".CreateInStream(InStr);
                        BodyInStream := InStr;
                        RequestContent.WriteFrom(InStr);
                    end;
                end;
            else
                HandleCustomBodyTypes(GlobalWebServConn, RequestContent);
        end;

        //Prepare Call
        CollectHeaders(ContentHeaders);
        OnAfterSetContentHeaders(ContentHeaders, GlobalWebServConn);
        RequestMessage.Method := Format(GlobalWebServConn."WSC HTTP Method");
        NewEndPoint := ParseEndPoint(GlobalWebServConn."WSC EndPoint");
        RequestMessage.SetRequestUri(NewEndPoint);

        OnBeforeSetRequestContent(RequestContent, GlobalWebServConn);
        case GlobalWebServConn."WSC HTTP Method" of
            GlobalWebServConn."WSC HTTP Method"::Get,
            GlobalWebServConn."WSC HTTP Method"::Delete:
                if HasBodyValues() then
                    RequestMessage.Content(RequestContent);
            GlobalWebServConn."WSC HTTP Method"::Post,
            GlobalWebServConn."WSC HTTP Method"::Put,
            GlobalWebServConn."WSC HTTP Method"::Patch:
                RequestMessage.Content(RequestContent);
        end;

        //Execute Call & Response Management
        ClearLastError();
        OnBeforeSendRequest(Client, GlobalWebServConn);
        if Client.Send(RequestMessage, ResponseMessage) then
            EvaluateResponse(ResponseMessage)
        else
            LastMessageText := Text000Err;
    end;

    local procedure EvaluateResponse(var ResponseMessage: HttpResponseMessage)
    var
        ResponseText: Text;
        IsHandled: Boolean;
        JsonObjectReader: JsonObject;
    begin
        OnBeforeEvaluateResponse(IsHandled, ResponseMessage, CallExecution, LastMessageText, HttpStatusCode);
        if IsHandled then
            exit;

        CallExecution := false;
        ResponseMessage.Content.ReadAs(ResponseInStream); //Risposta completa sotto forma di file
        if ResponseMessage.IsSuccessStatusCode() then begin
            if ResponseMessage.Content.ReadAs(ResponseText) then
                if (ResponseText = '') and (GlobalWebServConn."WSC Allow Blank Response") then
                    CallExecution := true
                else begin
                    CallExecution := JsonObjectReader.ReadFrom(ResponseText);
                    LastMessageText := GetLastErrorText();
                end;
        end else begin
            if ResponseMessage.Content.ReadAs(ResponseText) then
                JsonObjectReader.ReadFrom(ResponseText);
            LastMessageText := ResponseMessage.ReasonPhrase(); //Messaggio di errore del server
        end;
        HttpStatusCode := ResponseMessage.HttpStatusCode;
    end;
    #endregion CallFunctions
    #region GeneralFunctions
    local procedure ParseEndPoint(EndPointUrl: Text): Text
    var
        WebServicesEndPointVar: Record "WSC Web Services EndPoint Var.";
        Company: Record Company;
        NewString: Text;
    begin
        WebServicesEndPointVar.Reset();
        if WebServicesEndPointVar.IsEmpty() then
            exit(EndPointUrl);

        NewString := EndPointUrl;
        WebServicesEndPointVar.FindSet();
        repeat
            case WebServicesEndPointVar."WSC Variable Name" of
                '[@CompanyName]':
                    if StrPos(NewString, '[@CompanyName]') > 0 then
                        NewString := EndPointUrl.Replace('[@CompanyName]', CompanyName());
                '[@CompanyID]':
                    if StrPos(NewString, '[@CompanyID]') > 0 then begin
                        Company.Get(CompanyName());
                        NewString := EndPointUrl.Replace('[@CompanyID]', DelChr(Company.Id, '=', '{}'));
                    end;
                '[@UserID]':
                    if StrPos(NewString, '[@UserID]') > 0 then
                        NewString := EndPointUrl.Replace('[@UserID]', UserId());
            end;
            OnParseEndpoint(EndPointUrl, NewString, WebServicesEndPointVar, GlobalWebServConn);
        until WebServicesEndPointVar.Next() = 0;
        exit(NewString);
    end;

    local procedure AcquireGlobalWSConnection(WSCCode: Code[20])
    begin
        GlobalWebServConn.Get(WSCCode);
    end;

    /// <summary>
    /// RetrieveGlobalVariables.
    /// </summary>
    /// <param name="ParBodyInStream">VAR InStream.</param>
    /// <param name="ParResponseInStream">VAR InStream.</param>
    /// <param name="ParCallExecution">VAR Boolean.</param>
    /// <param name="ParHttpStatusCode">VAR Integer.</param>
    /// <param name="ParLastMessageText">VAR Text.</param>
    /// <param name="ParNewEndPoint">VAR Text.</param>
    procedure RetrieveGlobalVariables(var ParBodyInStream: InStream; var ParResponseInStream: InStream; var ParCallExecution: Boolean; var ParHttpStatusCode: Integer; var ParLastMessageText: Text; var ParNewEndPoint: Text)
    begin
        ParBodyInStream := BodyInStream;
        ParResponseInStream := ResponseInStream;
        ParCallExecution := CallExecution;
        ParHttpStatusCode := HttpStatusCode;
        ParLastMessageText := LastMessageText;
        ParNewEndPoint := NewEndPoint;
    end;

    local procedure ClearGlobalVariables()
    begin
        Clear(GlobalWebServConn);
        Clear(ResponseInStream);
        Clear(BodyInStream);
        Clear(CallExecution);
        Clear(HttpStatusCode);
        Clear(LastMessageText);
        Clear(NewEndPoint);
    end;

    [NonDebuggable]
    local procedure CreateBasicAuthHeader(): Text
    var
        LocBase64Convert: Codeunit "Base64 Convert";
        SecurityManagements: Codeunit "WSC Security Managements";
        TempBlob: Codeunit "Temp Blob";
        LocInStream: InStream;
        LocOutStream: OutStream;
        Text001Txt: Label '%1:%2';
        Text002Txt: Label 'Basic %1';
        Text000Err: Label 'Password must have a value in this type of call';
    begin
        if not SecurityManagements.HasToken(GlobalWebServConn."WSC Password", GlobalWebServConn.GetTokenDataScope()) then
            Error(Text000Err);

        TempBlob.CreateOutStream(LocOutStream, TextEncoding::UTF8);
        LocOutStream.WriteText(StrSubstNo(Text001Txt, GlobalWebServConn."WSC Username", SecurityManagements.GetToken(GlobalWebServConn."WSC Password", GlobalWebServConn.GetTokenDataScope())));
        TempBlob.CreateInStream(LocInStream, TextEncoding::UTF8);
        exit(StrSubstNo(Text002Txt, LocBase64Convert.ToBase64(LocInStream)))
    end;

    [NonDebuggable]
    local procedure CreateBearerAuthHeader(): Text
    var
        WSCConnBearer: Record "WSC Web Services Connections";
        SecurityManagements: Codeunit "WSC Security Managements";
        Bearer: Text;
        InStr: InStream;
        Text001Txt: Label 'Bearer must have a value in this type of call';
        Text002Txt: Label 'Bearer %1';
    begin
        WSCConnBearer.Get(GlobalWebServConn."WSC Bearer Connection Code");
        WSCConnBearer.CalcFields("WSC Access Token");
        if not SecurityManagements.HasToken(WSCConnBearer."WSC Access Token", WSCConnBearer.GetTokenDataScope()) then
            Error(Text001Txt);
        exit(StrSubstNo(Text002Txt, SecurityManagements.GetToken(WSCConnBearer."WSC Access Token", WSCConnBearer.GetTokenDataScope())));
    end;

    local procedure CollectHeaders(var ParContentHeaders: HttpHeaders)
    var
        WebServicesHeaders: Record "WSC Web Services Headers";
    begin
        WebServicesHeaders.Reset();
        WebServicesHeaders.SetRange("WSC Code", GlobalWebServConn."WSC Code");
        WebServicesHeaders.SetFilter("WSC Key", '<> %1', '');
        if WebServicesHeaders.IsEmpty() then
            exit;

        WebServicesHeaders.FindSet();
        repeat
            if ParContentHeaders.Contains(WebServicesHeaders."WSC Key") then
                ParContentHeaders.Remove(WebServicesHeaders."WSC Key");
            ParContentHeaders.Add(WebServicesHeaders."WSC Key", WebServicesHeaders."WSC Value");
        until WebServicesHeaders.Next() = 0;
    end;

    [NonDebuggable]
    local procedure CollectBodies(var ParRequestContent: HttpContent)
    var
        WebServicesBodies: Record "WSC Web Services Bodies";
        Text000Lbl: Label '%1=%2';
        BodyToWrite: Text;
    begin
        WebServicesBodies.Reset();
        WebServicesBodies.SetRange("WSC Code", GlobalWebServConn."WSC Code");
        WebServicesBodies.SetFilter("WSC Key", '<> %1', '');
        if WebServicesBodies.IsEmpty() then
            exit;

        WebServicesBodies.FindSet();
        repeat
            BodyToWrite += StrSubstNo(Text000Lbl, WebServicesBodies."WSC Key", WebServicesBodies.GetValue()) + '&';
        until WebServicesBodies.Next() = 0;
        BodyToWrite := CopyStr(BodyToWrite, 1, StrLen(BodyToWrite) - 1);
        ParRequestContent.WriteFrom(BodyToWrite);
    end;

    local procedure HasBodyValues(): Boolean;
    var
        WebServicesBodies: Record "WSC Web Services Bodies";
    begin
        WebServicesBodies.Reset();
        WebServicesBodies.SetRange("WSC Code", GlobalWebServConn."WSC Code");
        WebServicesBodies.SetFilter("WSC Key", '<> %1', '');
        if not WebServicesBodies.IsEmpty() then
            exit(true);
        exit(false);
    end;

    local procedure ImportWithFilter(var TempBlob: Codeunit "Temp Blob"; var FileName: Text)
    var
        FileManagement: Codeunit "File Management";
        IsHandled: Boolean;
        FromRecRef: RecordRef;
        FileDialogTxt: Label 'Attachments (%1)|%1', Comment = '%1=file types, such as *.txt or *.docx';
        FilterTxt: Label '*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.tiff;*.tif;*.pdf;*.docx;*.doc;*.xlsx;*.xls;*.pptx;*.ppt;*.msg;*.xml;*.json;*.*', Locked = true;
        ImportTxt: Label 'Attach a document.';
    begin
        IsHandled := false;
        FromRecRef.GetTable(GlobalWebServConn);
        OnBeforeImportWithFilter(TempBlob, FileName, IsHandled, FromRecRef);
        if IsHandled then
            exit;

        FileName := FileManagement.BLOBImportWithFilter(
            TempBlob, ImportTxt, FileName, StrSubstNo(FileDialogTxt, FilterTxt), FilterTxt);
    end;

    #endregion GeneralFunctions
    #region IntegrationEvents

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalls(var IsHandled: Boolean; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitializeRequestHeaders(var RequestHeaders: HttpHeaders; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetFixBodyMessage(var WebServicesConnections: Record "WSC Web Services Connections")
    begin
        //Modify is not needed
    end;

    [IntegrationEvent(false, false)]
    local procedure HandleCustomBodyMethods(var WebServicesConnections: Record "WSC Web Services Connections")
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure HandleCustomBodyTypes(var WebServicesConnections: Record "WSC Web Services Connections"; var RequestContent: HttpContent)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetContentHeaders(var ContentHeaders: HttpHeaders; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetRequestContent(var RequestContent: HttpContent; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendRequest(var Client: HttpClient; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEvaluateResponse(var IsHandled: Boolean; var ResponseMessage: HttpResponseMessage; var CallExecution: Boolean; var LastMessageText: Text; var HttpStatusCode: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeImportWithFilter(var TempBlob: Codeunit "Temp Blob"; var FileName: Text; var IsHandled: Boolean; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnParseEndpoint(OldEndPointString: Text; var NewEndPointString: Text; WebServicesEndPointVar: Record "WSC Web Services EndPoint Var."; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;
    #endregion IntegrationEvents
    var
        GlobalWebServConn: Record "WSC Web Services Connections";
        NewEndPoint: Text;
        LastMessageText: Text;
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CallExecution: Boolean;
        HttpStatusCode: Integer;
}