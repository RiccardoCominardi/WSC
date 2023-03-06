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
        Clear(ResponseText);
        Clear(ResponseInStream);
        Clear(BodyInStream);
        Clear(CallExecution);
        Clear(HttpStatusCode);
    end;

    /// <summary>
    /// RetrieveGlobalVariables.
    /// </summary>
    /// <param name="ParResponseText">VAR Text.</param>
    /// <param name="ParBodyInStream">VAR InStream.</param>
    /// <param name="ParResponseInStream">VAR InStream.</param>
    /// <param name="ParCallExecution">VAR Boolean.</param>
    /// <param name="ParHttpStatusCode">VAR Integer.</param>
    procedure RetrieveGlobalVariables(var ParResponseText: Text; var ParBodyInStream: InStream; var ParResponseInStream: InStream; var ParCallExecution: Boolean; var ParHttpStatusCode: Integer)
    begin
        ParResponseText := ResponseText;
        ParBodyInStream := BodyInStream;
        ParResponseInStream := ResponseInStream;
        ParCallExecution := CallExecution;
        ParHttpStatusCode := HttpStatusCode;
    end;

    local procedure AcquireGlobalWSCConnection(WSCCode: Code[20])
    begin
        GlobalWSCWebServConn.Get(WSCCode);
    end;

    local procedure PrepareAndExecuteRequest()
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        ContentHeaders: HttpHeaders;
        InStr: InStream;
        JsonObjectReader: JsonObject;
    begin
        //Authentication
        RequestHeaders := Client.DefaultRequestHeaders();
        case GlobalWSCWebServConn."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                RequestHeaders.Add('Authorization', CreateBasicAuthHeader(GlobalWSCWebServConn."WSC Username", GlobalWSCWebServConn."WSC Password"));
        //None: Autenticazione gestita nel Body, vedi esempi di chiamata Bartolini o GLS
        //Bearer: Autenticazione gestita con le Headers
        end;

        //Headers Values
        RequestContent.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        CollectHeaders(RequestContent, ContentHeaders);

        //Bodies Values
        if GlobalWSCWebServConn."WSC Body Type" in [GlobalWSCWebServConn."WSC Body Type"::"form data", GlobalWSCWebServConn."WSC Body Type"::"x-www-form-urlencoded"] then
            CollectBodies(RequestContent, ContentHeaders)
        else begin
            GlobalWSCWebServConn."WSC Body Message".CreateInStream(InStr);
            BodyInStream := InStr;
            RequestContent.WriteFrom(InStr);
        end;

        //Prepare Final Message
        RequestMessage.GetHeaders(RequestHeaders);
        RequestMessage.Method := Format(GlobalWSCWebServConn."WSC HTTP Method");
        RequestMessage.Content(RequestContent);

        //Call Execution
        CallExecution := false;
        if Client.Send(RequestMessage, ResponseMessage) then begin
            ResponseMessage.Content.ReadAs(ResponseInStream);
            if ResponseMessage.IsSuccessStatusCode() then begin
                if ResponseMessage.Content.ReadAs(ResponseText) then
                    CallExecution := JsonObjectReader.ReadFrom(ResponseText);
            end else
                if ResponseMessage.Content.ReadAs(ResponseText) then
                    JsonObjectReader.ReadFrom(ResponseText);
        end else
            ResponseText := 'Non so che errore mettere';

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

    local procedure CollectHeaders(var ParRequestContent: HttpContent; var ParContentHeaders: HttpHeaders)
    var
        WSCWSServicesHeaders: Record "WSC Web Services Headers";
    begin
        WSCWSServicesHeaders.Reset();
        WSCWSServicesHeaders.SetRange("WSC Code", GlobalWSCWebServConn."WSC Code");
        if WSCWSServicesHeaders.IsEmpty() then
            exit;

        repeat
            ParContentHeaders.Add(WSCWSServicesHeaders."WSC Key", WSCWSServicesHeaders."WSC Value");
        until WSCWSServicesHeaders.Next() = 0;
    end;

    local procedure CollectBodies(var ParRequestContent: HttpContent; var ParContentHeaders: HttpHeaders)
    var
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
    begin
        WSCWSServicesBodies.Reset();
        WSCWSServicesBodies.SetRange("WSC Code", GlobalWSCWebServConn."WSC Code");
        if WSCWSServicesBodies.IsEmpty() then
            exit;

        repeat
            ParContentHeaders.Add(WSCWSServicesBodies."WSC Key", WSCWSServicesBodies."WSC Value");
        until WSCWSServicesBodies.Next() = 0;
    end;


    var
        GlobalWSCWebServConn: Record "WSC Web Services Connections";
        ResponseText: Text;
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CallExecution: Boolean;
        HttpStatusCode: Integer;
}