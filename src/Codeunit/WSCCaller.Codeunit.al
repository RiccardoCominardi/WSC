/// <summary>
/// Codeunit WSC Caller (ID 81002).
/// </summary>
codeunit 81002 "WSC Caller"
{
    TableNo = "WSC Connections";
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

        OnBeforeCalls(IsHandled, GlobalConnection);
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
        StartingDateTime,
        EndingDateTime : DateTime;
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
        case GlobalConnection."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                RequestHeaders.Add('Authorization', CreateBasicAuthHeader());
            "WSC Authorization Types"::"bearer token":
                RequestHeaders.Add('Authorization', CreateBearerAuthHeader());
        //None: Autenticazione gestita nel Body, vedi esempi di chiamata Bartolini o GLS
        //Bearer: Autenticazione gestita con le Headers
        end;
        OnAfterInitializeRequestHeaders(RequestHeaders, GlobalConnection);

        case GlobalConnection."WSC HTTP Method" of
            GlobalConnection."WSC HTTP Method"::Get,
            GlobalConnection."WSC HTTP Method"::Delete:
                if HasBodyValues() then
                    RequestContent.GetHeaders(ContentHeaders)
                else
                    RequestMessage.GetHeaders(ContentHeaders);
            GlobalConnection."WSC HTTP Method"::Post,
            GlobalConnection."WSC HTTP Method"::Put,
            GlobalConnection."WSC HTTP Method"::Patch:
                RequestContent.GetHeaders(ContentHeaders);
        end;

        //Bodies Values
        ContentHeaders.Clear();
        case GlobalConnection."WSC Body Type" of
            "WSC Body Types"::"form data",
            "WSC Body Types"::"x-www-form-urlencoded":
                CollectBodies(RequestContent);
            "WSC Body Types"::binary,
            "WSC Body Types"::raw:
                begin
                    case GlobalConnection."WSC Body Method" of
                        "WSC Body Methods"::"fixed file":
                            OnSetFixBodyMessage(GlobalConnection);
                        "WSC Body Methods"::"request file":
                            begin
                                ImportWithFilter(TempBlob, FileName);
                                if FileName <> '' then begin
                                    GlobalConnection."WSC Body Message".CreateOutStream(OutStr);
                                    TempBlob.CreateInStream(FileInStream);
                                    CopyStream(OutStr, FileInStream);
                                end;
                            end;
                        else
                            HandleCustomBodyMethods(GlobalConnection);
                    end;

                    GlobalConnection.CalcFields("WSC Body Message");
                    if GlobalConnection."WSC Body Message".HasValue() then begin
                        GlobalConnection."WSC Body Message".CreateInStream(InStr);
                        BodyInStream := InStr;
                        RequestContent.WriteFrom(InStr);
                    end;
                end;
            else
                HandleCustomBodyTypes(GlobalConnection, RequestContent);
        end;

        EvaluateBodyFileType();

        //Prepare Call
        CollectHeaders(ContentHeaders);
        OnAfterSetContentHeaders(ContentHeaders, GlobalConnection);
        RequestMessage.Method := Format(GlobalConnection."WSC HTTP Method");
        NewEndPoint := ParseEndPoint(GlobalConnection."WSC EndPoint", GlobalRecRef);
        NewEndPoint := AddParameters(NewEndPoint);
        RequestMessage.SetRequestUri(NewEndPoint);

        OnBeforeSetRequestContent(RequestContent, GlobalConnection);
        case GlobalConnection."WSC HTTP Method" of
            GlobalConnection."WSC HTTP Method"::Get,
            GlobalConnection."WSC HTTP Method"::Delete:
                if HasBodyValues() then
                    RequestMessage.Content(RequestContent);
            GlobalConnection."WSC HTTP Method"::Post,
            GlobalConnection."WSC HTTP Method"::Put,
            GlobalConnection."WSC HTTP Method"::Patch:
                RequestMessage.Content(RequestContent);
        end;

        //Execute Call & Response Management
        StartingDateTime := CurrentDateTime();
        ClearLastError();
        OnBeforeSendRequest(Client, GlobalConnection);
        if Client.Send(RequestMessage, ResponseMessage) then
            EvaluateResponse(ResponseMessage)
        else
            LastMessageText := Text000Err;

        EndingDateTime := CurrentDateTime();
        ExecutionTime := EndingDateTime - StartingDateTime;

        //milliseconds = Duration / 1
        //seconds = Duration / 1000
        //minutes = Duration / 60000
        //hours = Duration / 3600000
        //days = Duration / 86400000
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
        ResponseMessage.Content.ReadAs(ResponseInStream); //Response Complete as File
        ResponseMessage.Content.ReadAs(ResponseText); //Response Complete as Text Variable
        EvaluateResponseFileType(ResponseText);
        if ResponseMessage.IsSuccessStatusCode() then
            CallExecution := true
        else
            LastMessageText := ResponseMessage.ReasonPhrase();
        HttpStatusCode := ResponseMessage.HttpStatusCode();
    end;

    local procedure EvaluateBodyFileType()
    var
        InStr: InStream;
        BodyAsText: Text;
        IsHandled: Boolean;
        JsonObjectReader: JsonObject;
        LocOptions: XmlReadOptions;
        LocXmlDocument: XmlDocument;
    begin
        GlobalConnection.CalcFields("WSC Body Message");
        if not GlobalConnection."WSC Body Message".HasValue() then
            exit;

        GlobalConnection."WSC Body Message".CreateInStream(InStr);
        InStr.ReadText(BodyAsText);

        OnBeforeEvaluateBodyFileType(BodyAsText, BodyFileType, IsHandled);
        if IsHandled then
            exit;

        BodyFileType := BodyFileType::" ";
        if BodyAsText = '' then
            exit;

        LocOptions.PreserveWhitespace := true;
        if XmlDocument.ReadFrom(BodyAsText, LocOptions, LocXmlDocument) then begin
            BodyFileType := BodyFileType::Xml;
            exit;
        end;

        if JsonObjectReader.ReadFrom(BodyAsText) then begin
            BodyFileType := BodyFileType::Json;
            exit;
        end;

        BodyFileType := BodyFileType::Txt;
    end;

    local procedure EvaluateResponseFileType(ResponseText: Text)
    var
        IsHandled: Boolean;
        JsonObjectReader: JsonObject;
        LocOptions: XmlReadOptions;
        LocXmlDocument: XmlDocument;
    begin
        OnBeforeEvaluateResponseFileType(ResponseText, ResponseFileType, IsHandled);
        if IsHandled then
            exit;

        ResponseFileType := ResponseFileType::" ";
        if (ResponseText = '') and (GlobalConnection."WSC Allow Blank Response") then
            exit;

        LocOptions.PreserveWhitespace := true;
        if XmlDocument.ReadFrom(ResponseText, LocOptions, LocXmlDocument) then begin
            ResponseFileType := ResponseFileType::Xml;
            exit;
        end;

        if JsonObjectReader.ReadFrom(ResponseText) then begin
            ResponseFileType := ResponseFileType::Json;
            exit;
        end;

        ResponseFileType := ResponseFileType::Txt;
    end;

    #endregion CallFunctions
    #region GeneralFunctions

    local procedure AddParameters(EndPointUrl: Text) NewString: Text
    var
        Parameters: Record "WSC Parameters";
        Text000Lbl: label '%1=%2';
    begin
        NewString := EndPointUrl;

        Parameters.Reset();
        Parameters.SetRange("WSC Code", GlobalConnection."WSC Code");
        Parameters.SetRange("WSC Enabled", true);
        Parameters.SetFilter("WSC Key", '<> %1', '');
        Parameters.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Parameters.IsEmpty() then
            exit;

        NewString += '?';
        Parameters.ReadIsolation := IsolationLevel::ReadUncommitted;
        Parameters.FindSet();
        repeat
            NewString += StrSubstNo(Text000Lbl, Parameters."WSC Key", Parameters."WSC Value") + '&';
            //Replace %1, %2 ecc. with your custom filters
            if Parameters.IsVariableValues() then
                OnParseVariableParameter(NewString, Parameters);
        until Parameters.Next() = 0;
        NewString := NewString.TrimEnd('&');
    end;

    local procedure ParseEndPoint(EndPointUrl: Text; RecRef: RecordRef): Text
    var
        EndPointVariables: Record "WSC EndPoint Variables";
        AzureADTenant: Codeunit "Azure AD Tenant";
        Company: Record Company;
        NewString: Text;
    begin
        EndPointVariables.Reset();
        EndPointVariables.ReadIsolation := IsolationLevel::ReadUncommitted;
        if EndPointVariables.IsEmpty() then
            exit(EndPointUrl);

        NewString := EndPointUrl;
        EndPointVariables.FindSet();
        repeat
            case EndPointVariables."WSC Variable Name" of
                '[@CompanyName]':
                    if NewString.Contains('[@CompanyName]') then
                        NewString := EndPointUrl.Replace('[@CompanyName]', CompanyName());
                '[@CompanyID]':
                    if NewString.Contains('[@CompanyID]') then begin
                        Company.Get(CompanyName());
                        NewString := EndPointUrl.Replace('[@CompanyID]', DelChr(Company.Id, '=', '{}'));
                    end;
                '[@UserID]':
                    if NewString.Contains('[@UserID]') then
                        NewString := EndPointUrl.Replace('[@UserID]', UserId());
                '[@CurrTenantId]':
                    if NewString.Contains('[@CurrTenantId]') then
                        NewString := EndPointUrl.Replace('[@CurrTenantId]', AzureADTenant.GetAadTenantId());
            end;
            OnParseEndpoint(EndPointUrl, NewString, EndPointVariables, GlobalConnection, GlobalRecRef);
        until EndPointVariables.Next() = 0;
        exit(NewString);
    end;

    local procedure AcquireGlobalWSConnection(WSCCode: Code[20])
    begin
        GlobalConnection.Get(WSCCode);
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
    /// <param name="ParBodyFileTypes">VAR Enum "WSC File Types".</param>
    /// <param name="ParResponseFileTypes">VAR Enum "WSC Response File Types".</param>
    /// <param name="ParExecutionTime">VAR Duration.</param>
    procedure RetrieveGlobalVariables(var ParBodyInStream: InStream; var ParResponseInStream: InStream; var ParCallExecution: Boolean; var ParHttpStatusCode: Integer; var ParLastMessageText: Text; var ParNewEndPoint: Text; var ParBodyFileTypes: Enum "WSC File Types"; var ParResponseFileTypes: Enum "WSC File Types"; var ParExecutionTime: Duration)
    begin
        ParBodyInStream := BodyInStream;
        ParResponseInStream := ResponseInStream;
        ParCallExecution := CallExecution;
        ParHttpStatusCode := HttpStatusCode;
        ParLastMessageText := LastMessageText;
        ParNewEndPoint := NewEndPoint;
        ParBodyFileTypes := BodyFileType;
        ParResponseFileTypes := ResponseFileType;
        ParExecutionTime := ExecutionTime;
    end;

    local procedure ClearGlobalVariables()
    begin
        Clear(GlobalConnection);
        Clear(ResponseInStream);
        Clear(BodyInStream);
        Clear(CallExecution);
        Clear(HttpStatusCode);
        Clear(LastMessageText);
        Clear(NewEndPoint);
        Clear(BodyFileType);
        Clear(ResponseFileType);
        Clear(ExecutionTime);
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
        if not SecurityManagements.HasToken(GlobalConnection."WSC Password", GlobalConnection.GetTokenDataScope()) then
            Error(Text000Err);

        TempBlob.CreateOutStream(LocOutStream, TextEncoding::UTF8);
        LocOutStream.WriteText(StrSubstNo(Text001Txt, GlobalConnection."WSC Username", SecurityManagements.GetToken(GlobalConnection."WSC Password", GlobalConnection.GetTokenDataScope())));
        TempBlob.CreateInStream(LocInStream, TextEncoding::UTF8);
        exit(StrSubstNo(Text002Txt, LocBase64Convert.ToBase64(LocInStream)))
    end;

    [NonDebuggable]
    local procedure CreateBearerAuthHeader(): Text
    var
        BearerConnection: Record "WSC Connections";
        SecurityManagements: Codeunit "WSC Security Managements";
        Bearer: Text;
        InStr: InStream;
        Text001Txt: Label 'Bearer must have a value in this type of call';
        Text002Txt: Label 'Bearer %1';
    begin
        BearerConnection.Get(GlobalConnection."WSC Bearer Connection Code");
        if not SecurityManagements.HasToken(BearerConnection."WSC Access Token", BearerConnection.GetTokenDataScope()) then
            Error(Text001Txt);
        exit(StrSubstNo(Text002Txt, SecurityManagements.GetToken(BearerConnection."WSC Access Token", BearerConnection.GetTokenDataScope())));
    end;

    local procedure CollectHeaders(var ParContentHeaders: HttpHeaders)
    var
        Headers: Record "WSC Headers";
    begin
        Headers.Reset();
        Headers.SetRange("WSC Code", GlobalConnection."WSC Code");
        Headers.SetRange("WSC Enabled", true);
        Headers.SetFilter("WSC Key", '<> %1', '');
        Headers.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Headers.IsEmpty() then
            exit;

        Headers.ReadIsolation := IsolationLevel::ReadUncommitted;
        Headers.FindSet();
        repeat
            if ParContentHeaders.Contains(Headers."WSC Key") then
                ParContentHeaders.Remove(Headers."WSC Key");
            ParContentHeaders.Add(Headers."WSC Key", Headers.GetValue());
        until Headers.Next() = 0;
    end;

    [NonDebuggable]
    local procedure CollectBodies(var ParRequestContent: HttpContent)
    var
        Bodies: Record "WSC Bodies";
        Text000Lbl: Label '%1=%2';
        BodyToWrite: Text;
    begin
        Bodies.Reset();
        Bodies.SetRange("WSC Code", GlobalConnection."WSC Code");
        Bodies.SetRange("WSC Enabled", true);
        Bodies.SetFilter("WSC Key", '<> %1', '');
        Bodies.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Bodies.IsEmpty() then
            exit;

        Bodies.ReadIsolation := IsolationLevel::ReadUncommitted;
        Bodies.FindSet();
        repeat
            BodyToWrite += StrSubstNo(Text000Lbl, Bodies."WSC Key", Bodies.GetValue()) + '&';
        until Bodies.Next() = 0;
        BodyToWrite := CopyStr(BodyToWrite, 1, StrLen(BodyToWrite) - 1);
        ParRequestContent.WriteFrom(BodyToWrite);
    end;

    local procedure HasBodyValues(): Boolean;
    var
        Bodies: Record "WSC Bodies";
    begin
        Bodies.Reset();
        Bodies.SetRange("WSC Code", GlobalConnection."WSC Code");
        Bodies.SetRange("WSC Enabled", true);
        Bodies.SetFilter("WSC Key", '<> %1', '');
        Bodies.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not Bodies.IsEmpty() then
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
        FileMissingErr: Label 'No file was selected';
    begin
        IsHandled := false;
        FromRecRef.GetTable(GlobalConnection);
        OnBeforeImportWithFilter(TempBlob, FileName, IsHandled, FromRecRef);
        if IsHandled then
            exit;

        FileName := FileManagement.BLOBImportWithFilter(
            TempBlob, ImportTxt, FileName, StrSubstNo(FileDialogTxt, FilterTxt), FilterTxt);
        if FileName = '' then
            Error(FileMissingErr);
    end;

    procedure GetRecordReference(RecRef: RecordRef)
    begin
        GlobalRecRef := RecRef;
    end;

    #endregion GeneralFunctions
    #region IntegrationEvents

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalls(var IsHandled: Boolean; Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitializeRequestHeaders(var RequestHeaders: HttpHeaders; Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetFixBodyMessage(var Connections: Record "WSC Connections")
    begin
        //Modify is not needed
    end;

    [IntegrationEvent(false, false)]
    local procedure HandleCustomBodyMethods(var Connections: Record "WSC Connections")
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure HandleCustomBodyTypes(var Connections: Record "WSC Connections"; var RequestContent: HttpContent)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetContentHeaders(var ContentHeaders: HttpHeaders; Connections: Record "WSC Connections")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetRequestContent(var RequestContent: HttpContent; Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendRequest(var Client: HttpClient; Connections: Record "WSC Connections")
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
    local procedure OnParseEndpoint(OldEndPointString: Text; var NewEndPointString: Text; EndPointVariables: Record "WSC EndPoint Variables"; Connections: Record "WSC Connections"; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnParseVariableParameter(var EndpointString: Text; Parameters: Record "WSC Parameters")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEvaluateBodyFileType(BodyAsText: Text; var BodyFileType: Enum "WSC File Types"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEvaluateResponseFileType(ResponseText: Text; var ResponseFileType: Enum "WSC File Types"; var IsHandled: Boolean)
    begin
    end;

    #endregion IntegrationEvents
    var
        GlobalRecRef: RecordRef;
        GlobalConnection: Record "WSC Connections";
        NewEndPoint: Text;
        LastMessageText: Text;
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CallExecution: Boolean;
        HttpStatusCode: Integer;
        BodyFileType: Enum "WSC File Types";
        ResponseFileType: Enum "WSC File Types";
        ExecutionTime: Duration;
}