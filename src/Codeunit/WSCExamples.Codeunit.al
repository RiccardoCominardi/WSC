/// <summary>
/// Codeunit WSC Examples (ID 82000).
/// </summary>
codeunit 82000 "WSC Examples"
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
        LogCalls: Record "WSC Log Calls";
        WSCManagements: Codeunit "WSC Managements";
        ResponseText: Text;
        WSCodeLog: Code[20];
        WSEntryLog: Integer;
    begin
        Clear(WSCManagements);
        if WSCManagements.ExecuteConnections('TEST', false, LogCalls) then
            Message('Web Service call successful. View the log to see the response')
        else
            Message('Web Service call failed. View the log to see the response');
    end;

    /// <summary>
    /// ExecuteWSCTestCodeWithCustomBody.
    /// </summary>
    procedure ExecuteWSCTestCodeWithCustomBody()
    var
        LogCalls: Record "WSC Log Calls";
        WSCManagements: Codeunit "WSC Managements";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        ResponseText: Text;
        WSCodeLog: Code[20];
        WSEntryLog: Integer;
    begin
        Clear(WSCManagements);
        GenerateCustomBody(TempBlob);
        TempBlob.CreateInStream(InStr);
        WSCManagements.SetCustomBody(InStr);
        if WSCManagements.ExecuteConnections('TEST_CUSTOM_BODY', false, LogCalls) then
            Message('Web Service call successful. View the log to see the response')
        else
            Message('Web Service call failed. View the log to see the response');
    end;

    local procedure ReadZipFile(LogCalls: Record "WSC Log Calls")
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        DataCompression: Codeunit "Data Compression";
        EntryOutStream: OutStream;
        EntryInStream,
        InStr : InStream;
        FileCount: Integer;
        EntryList: List of [Text];
        EntryListKey,
        ZipFileName,
        FileName,
        FileExtension : Text;
    begin
        if not LogCalls."WSC Zip Response" then
            exit;

        LogCalls."WSC Response Message".CreateInStream(InStr);
        //Extract zip file and store files to list type
        DataCompression.OpenZipArchive(InStr, false);
        DataCompression.GetEntryList(EntryList);

        //Loop files from the list type 
        foreach EntryListKey in EntryList do begin
            FileName := CopyStr(FileManagement.GetFileNameWithoutExtension(EntryListKey), 1, MaxStrLen(FileName));
            FileExtension := CopyStr(FileManagement.GetExtension(EntryListKey), 1, MaxStrLen(FileExtension));
            TempBlob.CreateOutStream(EntryOutStream);
            DataCompression.ExtractEntry(EntryListKey, EntryOutStream);
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

    //Add a fixed body for a WebService call. For complex body use the SetCustomBody procedure in Codeunit "WSC WSCManagements";
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Caller", 'OnSetFixBodyMessage', '', false, false)]
    local procedure OnSetFixBodyMessage(var Connections: Record "WSC Connections");
    var
        OutStr: OutStream;
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if Connections."WSC Code" <> 'TEST' then
            exit;

        Connections."WSC Body Message".CreateOutStream(OutStr);
        OutStr.WriteText('This is a fixed body text. You can put a file, contained in an InStream, in Write function');
        //No need to modify record.
    end;

    //Change the authentication for a WebService call
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Caller", 'OnAfterInitializeRequestHeaders', '', false, false)]
    local procedure OnAfterInitializeRequestHeaders(var RequestHeaders: HttpHeaders; Connections: Record "WSC Connections");
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if Connections."WSC Code" <> 'TEST' then
            exit;

        if RequestHeaders.Contains('Authorization') then
            RequestHeaders.Remove('Authorization');

        RequestHeaders.Add('Authorization', CreateBasicAuthHeader('TestUser', 'TestPassword'));
    end;

    //To handle variable parameters in endpoint 

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Caller", 'OnParseVariableParameter', '', false, false)]
    local procedure OnParseVariableParameter(var EndpointString: Text; Parameters: Record "WSC Parameters");
    begin
        //This piece of code is required for WS calls to work properly. Your parameters body must not have affect the parameters of other call
        if Parameters."WSC Code" <> 'FIO_PROD_ORD_COMP' then
            exit;

        case Parameters."WSC Key" of
            '$filter':
                EndpointString := StrSubstNo(EndpointString, 'OPR21-0006799'); //I know that the parameter has only %1
        end;
    end;

    //To handle variable in endpoint
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Caller", 'OnParseEndpoint', '', false, false)]
    local procedure OnParseEndpoint(OldEndPointString: Text; var NewEndPointString: Text; EndPointVariables: Record "WSC EndPoint Variables"; Connections: Record "WSC Connections");
    begin
        //This piece of code is required for WS calls to work properly. Your custom body must not have affect the body of other call
        if Connections."WSC Code" <> 'TEST' then
            exit;

        case EndPointVariables."WSC Variable Name" of
            '[@TestSubstitution]':
                NewEndPointString := OldEndPointString + 'v2';
        end;
    end;

    //To handle custom functions to execute after Web Service Call
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"WSC Functions Managements", 'OnExecuteLinkedFunctions', '', false, false)]
    local procedure OnExecuteLinkedFunctions(Functions: Record "WSC Functions"; LogCalls: Record "WSC Log Calls");
    begin
        case Functions."WSC Code" of
            'TEST':
                //Do Something
                ;
        end;
    end;

    local procedure IsSuccessStatusCode(WSCLogCalls: Record "WSC Log Calls"): Boolean
    begin
        case WSCLogCalls."WSC Result Status Code" of
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