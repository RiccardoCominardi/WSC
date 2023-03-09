/// <summary>
/// Codeunit WSC Web Services Examples (ID 82000).
/// </summary>
codeunit 82000 "WSC Web Services Examples"
{
    trigger OnRun()
    begin
        //Codeunit with some examples of customization
    end;

    /// <summary>
    /// ExecuteWSCTestCode.
    /// </summary>
    procedure ExecuteWSCTestCode()
    var
        WSCWebServicesLogCalls: Record "WSC Web Services Log Calls";
        WSCWSServicesMgt: Codeunit "WSC Web Services Management";
        ResponseText: Text;
        WSCodeLog: Code[20];
        WSEntryLog: Integer;
    begin
        Clear(WSCWSServicesMgt);
        WSCWSServicesMgt.SetHideMessage(true);
        ResponseText := WSCWSServicesMgt.ExecuteDirectWSCConnections('TEST');
        WSCWSServicesMgt.ParseResponse(ResponseText, WSCodeLog, WSEntryLog);

        WSCWebServicesLogCalls.Get(WSCodeLog, WSEntryLog);
        if IsSuccessStatusCode(WSCWebServicesLogCalls) then
            Message('Web Service call successful. View the log to see the response')
        else
            Message('Web Service call failed. View the log to see the response');
    end;

    //Add a body for a WebService call
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Web Services Caller", 'OnSetBodyMessage', '', false, false)]
    local procedure OnSetBodyMessage(var WSCWSServicesConnections: Record "WSC Web Services Connections");
    var
        OutStr: OutStream;
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if WSCWSServicesConnections."WSC Code" <> 'TEST' then
            exit;

        WSCWSServicesConnections."WSC Body Message".CreateOutStream(OutStr);
        OutStr.WriteText('This is a custom body text. You can put a file, contained in an InStream, in Write function');
        //No need to modify record.
    end;

    //Change the authentication for a WebService call
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Web Services Caller", 'OnAfterInitializeRequestHeaders', '', false, false)]
    local procedure OnAfterInitializeRequestHeaders(var RequestHeaders: HttpHeaders; WSCWSServicesConnections: Record "WSC Web Services Connections");
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if WSCWSServicesConnections."WSC Code" <> 'TEST' then
            exit;

        if RequestHeaders.Contains('Authorization') then
            RequestHeaders.Remove('Authorization');

        RequestHeaders.Add('Authorization', CreateBasicAuthHeader('TestUser', 'TestPassword'));
    end;

    local procedure IsSuccessStatusCode(WSCWebServicesLogCalls: Record "WSC Web Services Log Calls"): Boolean
    begin
        case WSCWebServicesLogCalls."WSC Result Status Code" of
            200,
            201,
            202:
                exit(true);
        end;
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
        TempBlob.CreateOutStream(LocOutStream, TextEncoding::UTF8);
        LocOutStream.WriteText(StrSubstNo(Text001Txt, UserName, Password));
        TempBlob.CreateInStream(LocInStream, TextEncoding::UTF8);
        exit(StrSubstNo(Text002Txt, LocBase64Convert.ToBase64(LocInStream)))
    end;
}