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


    local procedure ClearGlobalVariables()
    begin
        Clear(GlobalWSCWebServConn);
        Clear(ResponseInStream);
        Clear(BodyInStream);
        Clear(CallExecution);
        Clear(HttpStatusCode);
        Clear(LastMessageText);
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

    local procedure AcquireGlobalWSCConnection(WSCCode: Code[20])
    begin
        GlobalWSCWebServConn.Get(WSCCode);
    end;

    local procedure PrepareAndExecuteRequest()
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        WSCWSSelBodyFile: Page "WSC Web Service Sel. Body File";
        ResponseText: Text;
        FileInBase64: Text;
        InStr: InStream;
        OutStr: OutStream;
        Text000Err: Label 'Connection not estabilished';
        /*Web Service Connection Variables*/
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ContentHeaders: HttpHeaders;
        JsonObjectReader: JsonObject;
    begin
        //Initialize Stream Variables
        TempBlob.CreateInStream(BodyInStream);
        TempBlob.CreateInStream(ResponseInStream);

        //Authentication
        RequestHeaders := Client.DefaultRequestHeaders();
        case GlobalWSCWebServConn."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                RequestHeaders.Add('Authorization', CreateBasicAuthHeader(GlobalWSCWebServConn."WSC Username", GlobalWSCWebServConn."WSC Password"));
        //None: Autenticazione gestita nel Body, vedi esempi di chiamata Bartolini o GLS
        //Bearer: Autenticazione gestita con le Headers
        end;

        //Headers Values
        case GlobalWSCWebServConn."WSC HTTP Method" of
            "WSC HTTP Methods"::Get:
                RequestMessage.GetHeaders(ContentHeaders);
            "WSC HTTP Methods"::Post:
                RequestContent.GetHeaders(ContentHeaders);
        end;

        ContentHeaders.Clear();
        CollectHeaders(ContentHeaders);

        //Bodies Values
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
                OnSetBodyMessage(GlobalWSCWebServConn);

            GlobalWSCWebServConn.CalcFields("WSC Body Message");
            if GlobalWSCWebServConn."WSC Body Message".HasValue() then begin
                GlobalWSCWebServConn."WSC Body Message".CreateInStream(InStr);
                BodyInStream := InStr;
                RequestContent.WriteFrom(InStr);
            end;
        end;

        //Prepare Final Message
        RequestMessage.Method := Format(GlobalWSCWebServConn."WSC HTTP Method");
        RequestMessage.SetRequestUri(GlobalWSCWebServConn."WSC EndPoint");
        case GlobalWSCWebServConn."WSC HTTP Method" of
            "WSC HTTP Methods"::Get:
                ;
            "WSC HTTP Methods"::Post:
                RequestMessage.Content(RequestContent);
        end;

        //Call Execution & Response Management
        CallExecution := false;
        ClearLastError();
        Clear(TempBlob);
        if Client.Send(RequestMessage, ResponseMessage) then begin
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
        end else
            LastMessageText := Text000Err;
        HttpStatusCode := ResponseMessage.HttpStatusCode;

    end;

    local procedure CreateBasicAuthHeader(UserName: Text; Password: Text): Text
    var
        LocBase64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        LocInStream: InStream;
        LocOutStream: OutStream;
        LocText001Txt: Label '%1:%2';
        LocText002Txt: Label 'Basic %1';
    begin
        if GlobalWSCWebServConn."WSC Convert Auth. Base64" then begin
            TempBlob.CreateOutStream(LocOutStream, TextEncoding::UTF8);
            LocOutStream.WriteText(StrSubstNo(LocText001Txt, UserName, Password));
            TempBlob.CreateInStream(LocInStream, TextEncoding::UTF8);
            exit(StrSubstNo(LocText002Txt, LocBase64Convert.ToBase64(LocInStream)))
        end else
            exit(StrSubstNo(LocText002Txt, StrSubstNo(LocText001Txt, UserName, Password)));
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


    [IntegrationEvent(false, false)]
    local procedure OnSetBodyMessage(WSCWSServicesConnections: Record "WSC Web Services Connections")
    begin
        //Modidy is not needed
    end;

    var
        GlobalWSCWebServConn: Record "WSC Web Services Connections";
        LastMessageText: Text;
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CallExecution: Boolean;
        HttpStatusCode: Integer;
}