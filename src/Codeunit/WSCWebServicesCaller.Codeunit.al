/// <summary>
/// Codeunit WSC Web Services Caller (ID 81002).
/// </summary>
codeunit 81002 "WSC Web Services Caller"
{
    TableNo = "WSC Web Services Connections";
    trigger OnRun()
    begin
        ClearGlobalVariables();
        AcquireGlobalWSCConnection(Rec."WSC Code");
        PrepareAndExecuteRequest();
    end;

    /// <summary>
    /// RetrieveGlobalVariables.
    /// </summary>
    /// <param name="ParBodyInStream">VAR InStream.</param>
    /// <param name="ParResponseInStream">VAR InStream.</param>
    /// <param name="ParCallExecution">VAR Boolean.</param>
    /// <param name="ParHttpStatusCode">VAR Integer.</param>
    /// <param name="ParLastMessageText">VAR Text.</param>
    procedure RetrieveGlobalVariables(var ParBodyInStream: InStream; var ParResponseInStream: InStream; var ParCallExecution: Boolean; var ParHttpStatusCode: Integer; var ParLastMessageText: Text)
    begin
        ParBodyInStream := BodyInStream;
        ParResponseInStream := ResponseInStream;
        ParCallExecution := CallExecution;
        ParHttpStatusCode := HttpStatusCode;
        ParLastMessageText := LastMessageText;
    end;

    local procedure ClearGlobalVariables()
    begin
        Clear(GlobalWSCWebServConn);
        Clear(ResponseInStream);
        Clear(BodyInStream);
        Clear(CallExecution);
        Clear(HttpStatusCode);
        Clear(LastMessageText);
    end;

    local procedure AcquireGlobalWSCConnection(WSCCode: Code[20])
    begin
        GlobalWSCWebServConn.Get(WSCCode);
    end;

    local procedure PrepareAndExecuteRequest()
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        //Initialize Stream Variables
        TempBlob.CreateInStream(BodyInStream);
        TempBlob.CreateInStream(ResponseInStream);

        //Split of Calls
        if GlobalWSCWebServConn."WSC Bearer Connection" then
            TokenRequest()
        else
            NormalRequest();
    end;

    local procedure TokenRequest()
    var
        Base64Convert: Codeunit "Base64 Convert";
        WSCWSSelBodyFile: Page "WSC Web Service Sel. Body File";
        FileInBase64: Text;
        OutStr: OutStream;
        InStr: InStream;
        Text000Err: Label 'Connection not estabilished';
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

        if HasBodyValues() then
            RequestContent.GetHeaders(ContentHeaders)
        else
            RequestMessage.GetHeaders(ContentHeaders);

        //Bodies Values
        ContentHeaders.Clear();
        if GlobalWSCWebServConn."WSC Body Type" in [GlobalWSCWebServConn."WSC Body Type"::"form data", GlobalWSCWebServConn."WSC Body Type"::"x-www-form-urlencoded"] then
            CollectBodies(RequestContent)
        else begin
            if GuiAllowed then begin
                if GlobalWSCWebServConn."WSC HTTP Method" <> GlobalWSCWebServConn."WSC HTTP Method"::Get then begin //Get Method not need body
                    Clear(WSCWSSelBodyFile);
                    WSCWSSelBodyFile.RunModal();
                    WSCWSSelBodyFile.GetBodyString(FileInBase64);
                    GlobalWSCWebServConn."WSC Body Message".CreateOutStream(OutStr);
                    Base64Convert.FromBase64(FileInBase64, OutStr);
                end;
            end else
                OnSetBodyMessageTokenRequest(GlobalWSCWebServConn);

            GlobalWSCWebServConn.CalcFields("WSC Body Message");
            if GlobalWSCWebServConn."WSC Body Message".HasValue() then begin
                GlobalWSCWebServConn."WSC Body Message".CreateInStream(InStr);
                BodyInStream := InStr;
                RequestContent.WriteFrom(InStr);
            end;
        end;

        //Prepare Call
        CollectHeaders(ContentHeaders);
        RequestMessage.Method := Format(GlobalWSCWebServConn."WSC HTTP Method");
        RequestMessage.SetRequestUri(GlobalWSCWebServConn."WSC EndPoint");
        if HasBodyValues() then
            RequestMessage.Content(RequestContent);

        //Execute Call & Response Management
        ClearLastError();
        if Client.Send(RequestMessage, ResponseMessage) then
            EvaluateResponse(ResponseMessage)
        else
            LastMessageText := Text000Err;
    end;

    local procedure NormalRequest()
    var
        Base64Convert: Codeunit "Base64 Convert";
        WSCWSSelBodyFile: Page "WSC Web Service Sel. Body File";
        FileInBase64: Text;
        OutStr: OutStream;
        InStr: InStream;
        Text000Err: Label 'Connection not estabilished';
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
        case GlobalWSCWebServConn."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                RequestHeaders.Add('Authorization', CreateBasicAuthHeader(GlobalWSCWebServConn."WSC Username", GlobalWSCWebServConn."WSC Password"));
            "WSC Authorization Types"::"bearer token":
                RequestHeaders.Add('Authorization', CreateBearerAuthHeader());
        //None: Autenticazione gestita nel Body, vedi esempi di chiamata Bartolini o GLS
        //Bearer: Autenticazione gestita con le Headers
        end;

        if HasBodyValues() then
            RequestContent.GetHeaders(ContentHeaders)
        else
            RequestMessage.GetHeaders(ContentHeaders);

        //Bodies Values
        ContentHeaders.Clear();
        if GlobalWSCWebServConn."WSC Body Type" in [GlobalWSCWebServConn."WSC Body Type"::"form data", GlobalWSCWebServConn."WSC Body Type"::"x-www-form-urlencoded"] then
            CollectBodies(RequestContent)
        else begin
            if GuiAllowed then begin
                if GlobalWSCWebServConn."WSC HTTP Method" <> GlobalWSCWebServConn."WSC HTTP Method"::Get then begin //Get Method not need body
                    Clear(WSCWSSelBodyFile);
                    WSCWSSelBodyFile.RunModal();
                    WSCWSSelBodyFile.GetBodyString(FileInBase64);
                    GlobalWSCWebServConn."WSC Body Message".CreateOutStream(OutStr);
                    Base64Convert.FromBase64(FileInBase64, OutStr);
                end;
            end else
                OnSetBodyMessageTokenRequest(GlobalWSCWebServConn);

            GlobalWSCWebServConn.CalcFields("WSC Body Message");
            if GlobalWSCWebServConn."WSC Body Message".HasValue() then begin
                GlobalWSCWebServConn."WSC Body Message".CreateInStream(InStr);
                BodyInStream := InStr;
                RequestContent.WriteFrom(InStr);
            end;
        end;

        //Prepare Call
        CollectHeaders(ContentHeaders);
        RequestMessage.Method := Format(GlobalWSCWebServConn."WSC HTTP Method");
        RequestMessage.SetRequestUri(GlobalWSCWebServConn."WSC EndPoint");
        if HasBodyValues() then
            RequestMessage.Content(RequestContent);

        //Execute Call & Response Management
        ClearLastError();
        if Client.Send(RequestMessage, ResponseMessage) then
            EvaluateResponse(ResponseMessage)
        else
            LastMessageText := Text000Err;
    end;

    local procedure EvaluateResponse(var ResponseMessage: HttpResponseMessage)
    var
        ResponseText: Text;
        JsonObjectReader: JsonObject;
    begin
        CallExecution := false;
        ResponseMessage.Content.ReadAs(ResponseInStream); //Risposta completa sotto forma di file
        if ResponseMessage.IsSuccessStatusCode() then begin
            if ResponseMessage.Content.ReadAs(ResponseText) then
                if (ResponseText = '') and (GlobalWSCWebServConn."WSC Allow Blank Response") then
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

    local procedure CreateBasicAuthHeader(UserName: Text; Password: Text): Text
    var
        LocBase64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        LocInStream: InStream;
        LocOutStream: OutStream;
        Text001Txt: Label '%1:%2';
        Text002Txt: Label 'Basic %1';
    begin
        if GlobalWSCWebServConn."WSC Convert Auth. Base64" then begin
            TempBlob.CreateOutStream(LocOutStream, TextEncoding::UTF8);
            LocOutStream.WriteText(StrSubstNo(Text001Txt, UserName, Password));
            TempBlob.CreateInStream(LocInStream, TextEncoding::UTF8);
            exit(StrSubstNo(Text002Txt, LocBase64Convert.ToBase64(LocInStream)))
        end else
            exit(StrSubstNo(Text002Txt, StrSubstNo(Text001Txt, UserName, Password)));
    end;

    local procedure CreateBearerAuthHeader(): Text
    var
        WSCConnBearer: Record "WSC Web Services Connections";
        Bearer: Text;
        InStr: InStream;
        Text001Txt: Label 'Bearer must have a value in this type of call';
        Text002Txt: Label 'Bearer %1';
    begin
        WSCConnBearer.Get(GlobalWSCWebServConn."WSC Bearer Connection Code");
        WSCConnBearer.CalcFields("WSC Access Token");
        if not WSCConnBearer."WSC Access Token".HasValue() then
            Error(Text001Txt);
        WSCConnBearer."WSC Access Token".CreateInStream(InStr);
        InStr.ReadText(Bearer);
        exit(StrSubstNo(Text002Txt, Bearer));
    end;

    local procedure CollectHeaders(var ParContentHeaders: HttpHeaders)
    var
        WSCWSServicesHeaders: Record "WSC Web Services Headers";
    begin
        WSCWSServicesHeaders.Reset();
        WSCWSServicesHeaders.SetRange("WSC Code", GlobalWSCWebServConn."WSC Code");
        WSCWSServicesHeaders.SetFilter("WSC Key", '<> %1', '');
        if WSCWSServicesHeaders.IsEmpty() then
            exit;

        WSCWSServicesHeaders.FindSet();
        repeat
            if ParContentHeaders.Contains(WSCWSServicesHeaders."WSC Key") then
                ParContentHeaders.Remove(WSCWSServicesHeaders."WSC Key");
            ParContentHeaders.Add(WSCWSServicesHeaders."WSC Key", WSCWSServicesHeaders."WSC Value");
        until WSCWSServicesHeaders.Next() = 0;
    end;

    local procedure CollectBodies(var ParRequestContent: HttpContent)
    var
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
        Text000Lbl: Label '%1=%2';
        BodyToWrite: Text;
    begin
        WSCWSServicesBodies.Reset();
        WSCWSServicesBodies.SetRange("WSC Code", GlobalWSCWebServConn."WSC Code");
        WSCWSServicesBodies.SetFilter("WSC Key", '<> %1', '');
        if WSCWSServicesBodies.IsEmpty() then
            exit;

        WSCWSServicesBodies.FindSet();
        repeat
            BodyToWrite += StrSubstNo(Text000Lbl, WSCWSServicesBodies."WSC Key", WSCWSServicesBodies."WSC Value") + '&';
        until WSCWSServicesBodies.Next() = 0;
        BodyToWrite := CopyStr(BodyToWrite, 1, StrLen(BodyToWrite) - 1);
        ParRequestContent.WriteFrom(BodyToWrite);
    end;

    local procedure HasBodyValues(): Boolean;
    var
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
    begin
        WSCWSServicesBodies.Reset();
        WSCWSServicesBodies.SetRange("WSC Code", GlobalWSCWebServConn."WSC Code");
        WSCWSServicesBodies.SetFilter("WSC Key", '<> %1', '');
        if not WSCWSServicesBodies.IsEmpty() then
            exit(true);
        exit(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetBodyMessageTokenRequest(WSCWSServicesConnections: Record "WSC Web Services Connections")
    begin
        //Modify is not needed
    end;

    var
        GlobalWSCWebServConn: Record "WSC Web Services Connections";
        LastMessageText: Text;
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CallExecution: Boolean;
        HttpStatusCode: Integer;
}