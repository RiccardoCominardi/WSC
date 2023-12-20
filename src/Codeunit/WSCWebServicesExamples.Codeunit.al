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
        if WSCWSServicesMgt.ExecuteWSCConnections('TEST', WSCWebServicesLogCalls) then
            Message('Web Service call successful. View the log to see the response')
        else
            Message('Web Service call failed. View the log to see the response');
    end;

    /// <summary>
    /// ExecuteWSCTestCodeWithCustomBody.
    /// </summary>
    procedure ExecuteWSCTestCodeWithCustomBody()
    var
        WSCWebServicesLogCalls: Record "WSC Web Services Log Calls";
        WSCWSServicesMgt: Codeunit "WSC Web Services Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        ResponseText: Text;
        WSCodeLog: Code[20];
        WSEntryLog: Integer;
    begin
        Clear(WSCWSServicesMgt);
        GenerateCustomBody(TempBlob);
        TempBlob.CreateInStream(InStr);
        WSCWSServicesMgt.SetCustomBody(InStr);
        WSCWSServicesMgt.SetHideMessage(true);
        if WSCWSServicesMgt.ExecuteWSCConnections('TEST_CUSTOM_BODY', WSCWebServicesLogCalls) then
            Message('Web Service call successful. View the log to see the response')
        else
            Message('Web Service call failed. View the log to see the response');
    end;

    local procedure ReadZipFile(WSCWebServicesLogCalls: Record "WSC Web Services Log Calls")
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DataCompression: Codeunit "Data Compression";
        EntryOutStream: OutStream;
        EntryInStream,
        InStr : InStream;
        FileCount,
        Length : Integer;
        EntryList: List of [Text];
        EntryListKey,
        ZipFileName,
        FileName,
        FileExtension : Text;
    begin
        if not WSCWebServicesLogCalls."WSC Zip Response" then
            exit;

        WSCWebServicesLogCalls."WSC Response Message".CreateInStream(InStr);
        //Extract zip file and store files to list type
        DataCompression.OpenZipArchive(InStr, false);
        DataCompression.GetEntryList(EntryList);

        //Loop files from the list type
        foreach EntryListKey in EntryList do begin
            FileName := CopyStr(FileManagement.GetFileNameWithoutExtension(EntryListKey), 1, MaxStrLen(FileName));
            FileExtension := CopyStr(FileManagement.GetExtension(EntryListKey), 1, MaxStrLen(FileExtension));
            TempBlob.CreateOutStream(EntryOutStream);
            DataCompression.ExtractEntry(EntryListKey, EntryOutStream, Length);
            TempBlob.CreateInStream(EntryInStream);

            //Import or do something with each file here
            //EntryInStream contains the unzipped file. In that case contains the ResponseMessage.Json file
            FileCount += 1;
        end;

        //Close the zip file
        DataCompression.CloseZipArchive();
    end;

    local procedure GenerateCustomBody(var TempBlob: Codeunit "Temp Blob")
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText('This is a custom body text. You can put a file, contained in an InStream, in Write function');
    end;

    //Add a fixed body for a WebService call. For complex body use the SetCustomBody procedure in Codeunit "WSC Web Services Management";
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Web Services Caller", 'OnSetFixBodyMessage', '', false, false)]
    local procedure OnSetFixBodyMessage(var WSCWSServicesConnections: Record "WSC Web Services Connections");
    var
        OutStr: OutStream;
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if WSCWSServicesConnections."WSC Code" <> 'TEST' then
            exit;

        WSCWSServicesConnections."WSC Body Message".CreateOutStream(OutStr);
        OutStr.WriteText('This is a fixed body text. You can put a file, contained in an InStream, in Write function');
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

    //To handle custom endpoint variables    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Web Services Caller", 'OnParseEndpoint', '', false, false)]
    local procedure OnParseEndpoint(OldEndPointString: Text; var NewEndPointString: Text; WSCWebServicesEndPointVar: Record "WSC Web Services EndPoint Var."; WSCWSServicesConnections: Record "WSC Web Services Connections");
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if WSCWSServicesConnections."WSC Code" <> 'TEST' then
            exit;

        case WSCWebServicesEndPointVar."WSC Variable Name" of
            '[@TestSubstitution]':
                NewEndPointString := OldEndPointString + 'v2';
        end;
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