codeunit 81001 "WSC Managements"
{
    trigger OnRun()
    begin
    end;

    #region ExecutionFunctions

    procedure ExecuteFlow(FlowCode: Code[20])
    var
        Flows: Record "WSC Flows";
    begin
        Flows.Get(FlowCode);
        Flows.TestField("WSC Enabled", true);

        ExecuteFlowRequest(Flows);
    end;

    local procedure ExecuteFlowRequest(var Flows: Record "WSC Flows")
    var
        FlowsDetails: Record "WSC Flows Details";
        LogCalls: Record "WSC Log Calls";
        IsSuccessCall: Boolean;
        Text000Err: Label 'Error: %1';
        Text000Lbl: Label 'Operation Completed';
    begin
        FlowsDetails.Reset();
        FlowsDetails.SetRange("WSC Flow Code", Flows."WSC Code");
        FlowsDetails.SetRange("WSC Type", FlowsDetails."WSC Type"::Call);
        if FlowsDetails.IsEmpty() then
            exit;

        FlowsDetails.ModifyAll("WSC Last Flow Status", FlowsDetails."WSC Last Flow Status"::" ");
        FlowsDetails.ModifyAll("WSC Last Message Status", '');
        FlowsDetails.FindSet();

        Flows."WSC Last Date-Time" := CurrentDateTime();
        IsSuccessCall := true;
        repeat
            ClearLastError();

            if FlowsDetails."WCS Sleeping Time Type" in [FlowsDetails."WCS Sleeping Time Type"::Before] then
                Sleep(FlowsDetails."WCS Sleeping Time");

            IsSuccessCall := ExecuteConnections(FlowsDetails."WSC Connection Code", false, LogCalls);
            if not IsSuccessCall then begin
                Flows."WSC Last Flow Status" := FlowsDetails."WSC Last Flow Status"::Error;
                FlowsDetails."WSC Last Flow Status" := FlowsDetails."WSC Last Flow Status"::Error;
                FlowsDetails."WSC Last Message Status" := StrSubstNo(Text000Err, GetLastErrorText());
            end else begin
                Flows."WSC Last Flow Status" := FlowsDetails."WSC Last Flow Status"::Success;
                FlowsDetails."WSC Last Flow Status" := FlowsDetails."WSC Last Flow Status"::Success;
                FlowsDetails."WSC Last Message Status" := Text000Lbl;
            end;
            FlowsDetails.Modify();
            Commit();

            if FlowsDetails."WCS Sleeping Time Type" in [FlowsDetails."WCS Sleeping Time Type"::After] then
                Sleep(FlowsDetails."WCS Sleeping Time");

        until (FlowsDetails.Next() = 0) or not IsSuccessCall;

        Flows.Modify();
        FlowsDetails.Modify();
    end;

    procedure ExecuteConnections(WSCCode: Code[20]; ShowNotification: Boolean; var LogCalls: Record "WSC Log Calls") SuccessCall: Boolean
    var
        FunctionsManagements: Codeunit "WSC Functions Managements";
        ResponseString: Text;
    begin
        ResponseString := ExecuteDirectConnections(WSCCode);
        ParseResponse(ResponseString, LogCalls);
        SuccessCall := IsSuccessStatusCode(LogCalls."WSC Code", LogCalls."WSC Entry No.");
        if SuccessCall then
            FunctionsManagements.ExecuteLinkedFunctions(LogCalls);
        if GuiAllowed() then
            if ShowNotification then
                ShowViewLogNotification(LogCalls);
    end;

    local procedure ExecuteDirectConnections(WSCCode: Code[20]) ResponseString: Text;
    var
        Connections: Record "WSC Connections";
        BearerConnection: Record "WSC Connections";
        TokenEntryNo: Integer;
        LogEntryNo: Integer;
        IsHandled: Boolean;
    begin
        Connections.Get(WSCCode);
        if not (Connections."WSC Type" in [Connections."WSC Type"::Call, Connections."WSC Type"::Token]) then
            Error('');

        CheckWSCodeSetup(Connections);
        WriteCustomBodyOnWSCRec(Connections);

        OnBeforeExecuteDirectConnections(IsHandled, Connections);
        if IsHandled then
            exit;

        case Connections."WSC Auth. Type" of
            Connections."WSC Auth. Type"::none,
            Connections."WSC Auth. Type"::basic:
                begin
                    Clear(WebServicesCaller);
                    ClearLastError();
                    if Connections."WSC Bearer Connection" then begin
                        ExecuteTokenCall(Connections."WSC Code", BearerConnection, TokenEntryNo);
                        LogEntryNo := TokenEntryNo;
                    end else begin
                        if WebServicesCaller.Run(Connections) then;
                        LogEntryNo := WriteConnectionLog(WSCCode, '', 0);
                    end;
                    ResponseString := Connections."WSC Code" + ':' + Format(LogEntryNo);
                end;
            Connections."WSC Auth. Type"::"bearer token":
                if ExecuteTokenCall(Connections."WSC Bearer Connection Code", BearerConnection, TokenEntryNo) then begin
                    Commit();
                    Clear(WebServicesCaller);
                    ClearLastError();
                    if WebServicesCaller.Run(Connections) then;
                    LogEntryNo := WriteConnectionLog(WSCCode, BearerConnection."WSC Code", TokenEntryNo);
                    ResponseString := Connections."WSC Code" + ':' + Format(LogEntryNo);
                end else
                    ResponseString := Connections."WSC Bearer Connection Code" + ':' + Format(TokenEntryNo);
        end;
        OnAfterExecuteDirectConnections(Connections);
    end;

    local procedure ExecuteTokenCall(WSCTokenCode: Code[20]; var BearerConnection: Record "WSC Connections"; var TokenEntryNo: Integer) TokenTaken: Boolean;
    var
        LogCalls: Record "WSC Log Calls";
    begin
        TokenTaken := false;
        BearerConnection.Get(WSCTokenCode);
        CheckWSCodeSetup(BearerConnection);
        if IsTokenCallToDo(BearerConnection) then begin
            Clear(WebServicesCaller);
            ClearLastError();
            if WebServicesCaller.Run(BearerConnection) then;
            TokenEntryNo := WriteConnectionLog(BearerConnection."WSC Code", '', 0);
            if IsSuccessStatusCode(BearerConnection."WSC Code", TokenEntryNo) then begin
                TokenTaken := true;
                UpdateWSCTokenInfo(BearerConnection);
            end;
        end else begin
            LogCalls.Reset();
            LogCalls.SetRange("WSC Code", BearerConnection."WSC Code");
            LogCalls.FindLast();
            TokenEntryNo := LogCalls."WSC Entry No.";
            TokenTaken := true;
        end;
        exit(TokenTaken);
    end;

    procedure ParseResponse(StringToParse: Text; var LogCalls: Record "WSC Log Calls")
    var
        SplittedString: List of [Text];
    begin
        SplittedString := StringToParse.Split(':');
        LogCalls.Get(SplittedString.Get(1), SplittedString.Get(2));
    end;

    #endregion ExecutionFunctions
    #region GeneralFunctions

    local procedure ShowViewLogNotification(LogCalls: Record "WSC Log Calls")
    var
        ViewLogNotification: Notification;
        Text000Lbl: Label 'Execution Terminated. Check the log to see the result';
        Text001Lbl: Label 'Open Log?';
    begin
        ViewLogNotification.Message(Text000Lbl);
        ViewLogNotification.Scope := NotificationScope::LocalScope;
        ViewLogNotification.SetData(LogCalls.FieldName("WSC Code"), LogCalls."WSC Code");
        ViewLogNotification.AddAction('View Log', Codeunit::"WSC NotificationActionHandler", 'ViewLog', 'Click the action to open log automatically');
        ViewLogNotification.Send();
    end;

    local procedure CheckWSCodeSetup(Connections: Record "WSC Connections")
    begin
        Connections.TestField("WSC EndPoint");
        case Connections."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                begin
                    Connections.TestField("WSC Username");
                    Connections.TestField("WSC Password");
                end;

            Connections."WSC Auth. Type"::"bearer token":
                Connections.TestField("WSC Bearer Connection Code");

            Connections."WSC Auth. Type"::none:
                if Connections."WSC Bearer Connection" then begin
                    Connections.TestField("WSC Bearer Connection Code", '');
                    CheckWSBodiesForToken(Connections);
                end;
        end;

        case Connections."WSC Body Type" of
            "WSC Body Types"::raw,
            "WSC Body Types"::binary:
                Connections.TestField("WSC Body Method");
        end;

        OnAfterCheckWSCCodeSetup(Connections);
    end;

    procedure SetCustomBody(var InStr: InStream)
    begin
        CustomBodyInStream := InStr;
        CustomBodyIsSet := true;
    end;

    local procedure WriteCustomBodyOnWSCRec(var Connections: Record "WSC Connections")
    var
        OutStr: OutStream;
    begin
        ClearWSCBodyMessage(Connections);
        if not CustomBodyIsSet then
            exit;
        Connections."WSC Body Message".CreateOutStream(OutStr);
        CopyStream(OutStr, CustomBodyInStream);
        Connections.Modify();
        Commit();
    end;

    local procedure ClearWSCBodyMessage(var Connections: Record "WSC Connections")
    begin
        Connections.LockTable();
        Clear(Connections."WSC Body Message");
        Connections.Modify();
        Commit();
    end;

    local procedure IsSuccessStatusCode(WSCCode: Code[20]; EntryNo: Integer): Boolean
    var
        LogCalls: Record "WSC Log Calls";
    begin
        LogCalls.Get(WSCCode, EntryNo);
        case LogCalls."WSC Result Status Code" of
            200,
            201,
            202:
                exit(true);
        end;
    end;

    local procedure WriteBlobFields(var OutStr: OutStream; var InStr: InStream)
    var
        ResponseString,
        CurrText : Text;
    begin
        while not InStr.EOS() do begin
            InStr.ReadText(CurrText);
            ResponseString += CurrText;
            OutStr.Write(CurrText);
        end;
    end;

    local procedure WriteZippedBlobFields(var OutStr: OutStream; var InStr: InStream)
    var
        DataCompression: Codeunit "Data Compression";
        CurrText: Text;
    begin
        if InStr.Length = 0 then
            exit;

        DataCompression.CreateZipArchive();
        DataCompression.AddEntry(InStr, 'ResponseMessage' + RetrieveResponseFileExtension());
        DataCompression.SaveZipArchive(OutStr);
    end;

    local procedure RetrieveResponseFileExtension(): Text
    var
        IsHandled: Boolean;
        RetText: Text;
    begin
        OnBeforeRetrieveResponseFileExtension(ResponseFileType, RetText, IsHandled);
        if IsHandled then
            exit;

        case ResponseFileType of
            ResponseFileType::" ",
            ResponseFileType::Json:
                RetText := '.json';
            ResponseFileType::Xml:
                RetText := '.xml';
            ResponseFileType::Txt:
                RetText := '.txt';
        end;

        exit(RetText);
    end;

    local procedure ClearGlobalVariables()
    begin
        Clear(BodyInStream);
        Clear(ResponseInStream);
        Clear(CallExecution);
        Clear(HttpStatusCode);
        Clear(LastMessageText);
        Clear(ResponseText);
        Clear(NewEndPoint);
        Clear(CustomBodyInStream);
        Clear(CustomBodyIsSet);
        Clear(BodyFileType);
        Clear(ResponseFileType);
    end;

    #endregion GeneralFunctions
    #region TokenFunctions
    local procedure CheckWSBodiesForToken(BearerConnection: Record "WSC Connections")
    var
        Bodies: Record "WSC Bodies";
        Text000Err: Label 'Key %1 must be filled for token request';
        IsHandled: Boolean;
    begin
        OnBeforeCheckWSCBodiesForToken(IsHandled, BearerConnection);
        if IsHandled then
            exit;

        Bodies.Get(BearerConnection."WSC Code", 'grant_type');
        case Bodies."WSC Value" of
            'client_credentials':
                begin
                    Bodies.Reset();
                    Bodies.SetRange("WSC Code", BearerConnection."WSC Code");
                    Bodies.SetRange("WSC Enabled", true);
                    Bodies.SetRange("WSC Key", 'client_id');
                    Bodies.FindFirst();
                    if not Bodies.HasValue() then
                        Error(Text000Err, 'client_id');
                    Bodies.SetRange("WSC Key", 'client_secret');
                    Bodies.FindFirst();
                    if not Bodies.HasValue() then
                        Error(Text000Err, 'client_secret');
                    Bodies.SetRange("WSC Key", 'scope');
                    Bodies.FindFirst();
                    if not Bodies.HasValue() then
                        Error(Text000Err, 'scope');
                end;
            'authorization_code':
                ;
            'password':
                ;
        end;
        OnAfterCheckWSCBodiesForToken(BearerConnection);
    end;

    local procedure UpdateWSCTokenInfo(var BearerConnection: Record "WSC Connections")
    var
        SecurityManagements: Codeunit "WSC Security Managements";
        JToken: JsonToken;
        JAccessToken: JsonObject;
        Property: Text;
        OuStr: OutStream;
        Text000Err: Label 'Invalid Access Token Property %1, Value:  %2';
        IsHandled: Boolean;
    begin
        JAccessToken.ReadFrom(ResponseText);
        OnBeforeReadJsonTokenResponse(IsHandled, JAccessToken, BearerConnection);
        if IsHandled then
            exit;

        foreach Property in JAccessToken.Keys() do begin
            JAccessToken.Get(Property, JToken);
            case Property of
                'token_type',
                'scope',
                'expires_on',
                'not_before',
                'resource',
                'id_token':
                    ;
                'expires_in':
                    BearerConnection."WSC Expires In" := JToken.AsValue().AsInteger();
                'ext_expires_in':
                    ;
                'access_token':
                    begin
                        SecurityManagements.SetToken(BearerConnection."WSC Access Token", JToken.AsValue().AsText(), BearerConnection.GetTokenDataScope());
                    end;
                'refresh_token':
                    begin
                        SecurityManagements.SetToken(BearerConnection."WSC Refresh Token", JToken.AsValue().AsText(), BearerConnection.GetTokenDataScope());
                    end;
                else
                    Error(Text000Err, Property, JToken.AsValue().AsText());
            end;
        end;
        OnAfterReadJsonTokenResponse(JAccessToken, BearerConnection);
        BearerConnection."WSC Authorization Time" := CurrentDateTime();
        BearerConnection.Modify();
    end;

    local procedure IsTokenCallToDo(BearerConnection: Record "WSC Connections"): Boolean
    var
        ElapsedSecs: Integer;
    begin
        if BearerConnection."WSC Authorization Time" = 0DT then
            exit(true);

        ElapsedSecs := Round((CurrentDateTime() - BearerConnection."WSC Authorization Time") / 1000, 1, '>');
        if (ElapsedSecs < BearerConnection."WSC Expires In") and (ElapsedSecs < 3600) then
            exit(false);

        exit(true);
    end;

    #endregion TokenFunctions
    #region LogFunctions
    local procedure WriteConnectionLog(WSCCode: Code[20]; TokenWSCCode: Code[20]; TokenEntryNo: Integer) CurrEntryNo: Integer;
    var
        Connections: Record "WSC Connections";
        LogCalls: Record "WSC Log Calls";
        NextEntryNo: Integer;
        OutStr: OutStream;
    begin
        Connections.Get(WSCCode);
        ClearGlobalVariables();
        WebServicesCaller.RetrieveGlobalVariables(BodyInStream, ResponseInStream, CallExecution, HttpStatusCode, LastMessageText, NewEndPoint, BodyFileType, ResponseFileType, ExecutionTime);

        LogCalls.Reset();
        LogCalls.SetRange("WSC Code", WSCCode);
        LogCalls.ReadIsolation := IsolationLevel::ReadUncommitted;
        if LogCalls.FindLast() then
            NextEntryNo := LogCalls."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        CurrEntryNo := NextEntryNo;

        LogCalls.Init();
        LogCalls."WSC Entry No." := CurrEntryNo;
        LogCalls."WSC Code" := Connections."WSC Code";
        LogCalls."WSC Description" := Connections."WSC Description";
        LogCalls."WSC HTTP Method" := Connections."WSC HTTP Method";
        LogCalls."WSC EndPoint" := NewEndPoint;
        LogCalls."WSC Auth. Type" := Connections."WSC Auth. Type";
        LogCalls."WSC Bearer Connection" := Connections."WSC Bearer Connection";
        LogCalls."WSC Bearer Connection Code" := Connections."WSC Bearer Connection Code";
        LogCalls."WSC Body Type" := Connections."WSC Body Type";
        LogCalls."WSC Allow Blank Response" := Connections."WSC Allow Blank Response";
        LogCalls."WSC Group Code" := Connections."WSC Group Code";

        //Body Request
        Clear(OutStr);
        LogCalls."WSC Body File Type" := BodyFileType;
        LogCalls."WSC Body Message".CreateOutStream(OutStr);
        WriteBlobFields(OutStr, BodyInStream);
        Clear(OutStr);

        //Response
        LogCalls."WSC Response File Type" := ResponseFileType;
        LogCalls."WSC Zip Response" := Connections."WSC Zip Response";
        LogCalls."WSC Response Message".CreateOutStream(OutStr);
        if LogCalls."WSC Zip Response" then
            WriteZippedBlobFields(OutStr, ResponseInStream)
        else
            WriteBlobFields(OutStr, ResponseInStream);

        //Assign Response to a Globar variable to use 
        ResponseInStream.ResetPosition();
        ResponseInStream.ReadText(ResponseText);

        LogCalls."WSC Message Text" := CopyStr(LastMessageText, 1, MaxStrLen(LogCalls."WSC Message Text"));
        LogCalls."WSC Link to WSC Code" := TokenWSCCode;
        LogCalls."WSC Link To Entry No." := TokenEntryNo;
        LogCalls."WSC Result Status Code" := HttpStatusCode;
        LogCalls."WSC Execution Date-Time" := CurrentDateTime();
        LogCalls."WSC Execution UserID" := UserId();
        LogCalls."WSC Execution Time (ms)" := ExecutionTime;
        OnBeforeInsertLogCalls(LogCalls, Connections);
        LogCalls.Insert();

        if Connections."WSC Store Parameters Datas" then
            WriteParametersLog(WSCCode, CurrEntryNo);
        if Connections."WSC Store Headers Datas" then
            WriteHeaderLog(WSCCode, CurrEntryNo);
        if Connections."WSC Store Body Datas" then
            WriteBodyLog(WSCCode, CurrEntryNo);
    end;

    local procedure WriteParametersLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        Parameters: Record "WSC Parameters";
        LogParameters: Record "WSC Log Parameters";
        NextEntryNo: Integer;
    begin
        Parameters.Reset();
        Parameters.SetRange("WSC Code", WSCCode);
        Parameters.SetRange("WSC Enabled", true);
        if Parameters.IsEmpty() then
            exit;

        LogParameters.Reset();
        LogParameters.SetRange("WSC Code", WSCCode);
        LogParameters.SetRange("WSC Log Entry No.", LogEntryNo);
        LogParameters.ReadIsolation := IsolationLevel::ReadUncommitted;
        if LogParameters.FindLast() then
            NextEntryNo := LogParameters."WSC Entry No."
        else
            NextEntryNo := 0;

        Parameters.FindSet();
        repeat
            NextEntryNo += 1;
            LogParameters.Init();
            LogParameters."WSC Log Entry No." := LogEntryNo;
            LogParameters."WSC Entry No." := NextEntryNo;
            LogParameters."WSC Code" := Parameters."WSC Code";
            LogParameters."WSC Key" := Parameters."WSC Key";
            LogParameters."WSC Value" := Parameters."WSC Value"; //serve prendere il dato dei parametri????
            LogParameters."WSC Description" := Parameters."WSC Description";
            OnBeforeInsertLogParameters(LogParameters, Parameters);
            LogParameters.Insert();
        until Parameters.Next() = 0;
    end;

    local procedure WriteHeaderLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        Headers: Record "WSC Headers";
        LogHeaders: Record "WSC Log Headers";
        NextEntryNo: Integer;
    begin
        Headers.Reset();
        Headers.SetRange("WSC Code", WSCCode);
        Headers.SetRange("WSC Enabled", true);
        if Headers.IsEmpty() then
            exit;

        LogHeaders.Reset();
        LogHeaders.SetRange("WSC Code", WSCCode);
        LogHeaders.SetRange("WSC Log Entry No.", LogEntryNo);
        if LogHeaders.FindLast() then
            NextEntryNo := LogHeaders."WSC Entry No."
        else
            NextEntryNo := 0;

        Headers.FindSet();
        repeat
            NextEntryNo += 1;
            LogHeaders.ReadIsolation := IsolationLevel::ReadUncommitted;
            LogHeaders.Init();
            LogHeaders."WSC Log Entry No." := LogEntryNo;
            LogHeaders."WSC Entry No." := NextEntryNo;
            LogHeaders."WSC Code" := Headers."WSC Code";
            LogHeaders."WSC Key" := Headers."WSC Key";
            LogHeaders."WSC Value" := Headers.GetValue();
            LogHeaders."WSC Description" := Headers."WSC Description";
            OnBeforeInsertLogHeaders(LogHeaders, Headers);
            LogHeaders.Insert();
        until Headers.Next() = 0;
    end;

    local procedure WriteBodyLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        Bodies: Record "WSC Bodies";
        LogBodies: Record "WSC Log Bodies";
        NextEntryNo: Integer;
    begin
        Bodies.Reset();
        Bodies.SetRange("WSC Enabled", true);
        Bodies.SetRange("WSC Code", WSCCode);
        if Bodies.IsEmpty() then
            exit;

        LogBodies.Reset();
        LogBodies.SetRange("WSC Code", WSCCode);
        LogBodies.SetRange("WSC Log Entry No.", LogEntryNo);
        if LogBodies.FindLast() then
            NextEntryNo := LogBodies."WSC Entry No."
        else
            NextEntryNo := 0;

        Bodies.FindSet();
        repeat
            NextEntryNo += 1;
            LogBodies.ReadIsolation := IsolationLevel::ReadUncommitted;
            LogBodies.Init();
            LogBodies."WSC Log Entry No." := LogEntryNo;
            LogBodies."WSC Entry No." := NextEntryNo;
            LogBodies."WSC Code" := Bodies."WSC Code";
            LogBodies."WSC Key" := Bodies."WSC Key";
            LogBodies."WSC Value" := Bodies.GetValue();
            LogBodies."WSC Description" := Bodies."WSC Description";
            OnBeforeInsertLogBodies(LogBodies, Bodies);
            LogBodies.Insert();
        until Bodies.Next() = 0;
    end;
    #endregion LogFunctions
    #region IntegrationEvents
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecuteDirectConnections(var IsHandled: Boolean; WSCConnections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExecuteDirectConnections(WSCConnections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWSCBodiesForToken(var IsHandled: Boolean; BearerConnection: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWSCBodiesForToken(BearerConnection: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWSCCodeSetup(WSCConnections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReadJsonTokenResponse(var IsHandled: Boolean; JAccessToken: JsonObject; var BearerConnection: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReadJsonTokenResponse(JAccessToken: JsonObject; var BearerConnection: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLogCalls(var LogCalls: Record "WSC Log Calls"; Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLogParameters(var LogParameters: Record "WSC Log Parameters"; Parameters: Record "WSC Parameters")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLogHeaders(var LogHeaders: Record "WSC Log Headers"; Headers: Record "WSC Headers")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertLogBodies(var LogBodies: Record "WSC Log Bodies"; Bodies: Record "WSC Bodies")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRetrieveResponseFileExtension(ResponseFileType: Enum "WSC File Types"; var RetText: Text; IsHandled: Boolean)
    begin
    end;
    #endregion IntegrationEvents

    #region SubscriberEvents
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Apply Retention Policy", 'OnApplyRetentionPolicyIndirectPermissionRequired', '', false, false)]
    local procedure OnApplyRetentionPolicyIndirectPermissionRequired(var RecRef: RecordRef; var Handled: Boolean);
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        LogCategory: Enum "Retention Policy Log Category";
        LogMessageLbl: Label 'No filters applyed for table %1 %2';
    begin
        if Handled then
            exit;

        if not (RecRef.Number in [Database::"WSC Log Calls"]) then
            exit;

        if (RecRef.GetFilters() = '') or (not RecRef.MarkedOnly()) then
            RetentionPolicyLog.LogError(LogCategory::"Retention Policy - Apply", StrSubstNo(LogMessageLbl, RecRef.Number, RecRef.Name));

        RecRef.Delete(true);
        Handled := true;
    end;
    #endregion SubscriberEvents
    var
        WebServicesCaller: Codeunit "WSC Caller";
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CustomBodyInStream: InStream;
        ResponseText: Text;
        CallExecution: Boolean;
        CustomBodyIsSet: Boolean;
        HttpStatusCode: Integer;
        LastMessageText: Text;
        NewEndPoint: Text;
        BodyFileType,
        ResponseFileType : Enum "WSC File Types";
        ExecutionTime: Duration;
}