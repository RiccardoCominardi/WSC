/// <summary>
/// Codeunit WSC Managements (ID 81001).
/// </summary>
codeunit 81001 "WSC Managements"
{
    trigger OnRun()
    begin
    end;

    #region ExecutionFunctions

    /// <summary>
    /// ExecuteConnections.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    /// <param name="LogCalls">Record "WSC Log Calls".</param>
    /// <returns>Return variable Result of type Boolean.</returns>
    procedure ExecuteConnections(WSCCode: Code[20]; var LogCalls: Record "WSC Log Calls"): Boolean
    var
        ResponseString: Text;
        WSCodeLog: Code[20];
        WSEntryLog: Integer;
    begin
        ResponseString := ExecuteDirectConnections(WSCCode);
        ParseResponse(ResponseString, WSCodeLog, WSEntryLog);

        LogCalls.Get(WSCodeLog, WSEntryLog);
        if IsSuccessStatusCode(WSCodeLog, WSEntryLog) then
            exit(true)
        else
            exit(false);
    end;

    local procedure ExecuteDirectConnections(WSCCode: Code[20]) ResponseString: Text;
    var
        Connections: Record "WSC Connections";
        BearerConnection: Record "WSC Connections";
        TokenEntryNo: Integer;
        LogEntryNo: Integer;
        Text000Lbl: Label 'Execution Terminated. Check the log to see the result';
        IsHandled: Boolean;
    begin
        Connections.Get(WSCCode);
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

        if GuiAllowed() then
            if not HideMessage then
                Message(Text000Lbl);
    end;

    local procedure ExecuteTokenCall(WSCTokenCode: Code[20]; var BearerConnection: Record "WSC Connections"; var TokenEntryNo: Integer) TokenTaken: Boolean;
    var
        WSCWSServicesLogCalls: Record "WSC Log Calls";
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
            WSCWSServicesLogCalls.Reset();
            WSCWSServicesLogCalls.SetRange("WSC Code", BearerConnection."WSC Code");
            WSCWSServicesLogCalls.FindLast();
            TokenEntryNo := WSCWSServicesLogCalls."WSC Entry No.";
            TokenTaken := true;
        end;
        exit(TokenTaken);
    end;

    /// <summary>
    /// ParseResponse.
    /// </summary>
    /// <param name="StringToParse">Text.</param>
    /// <param name="WSCCodeLog">VAR Code[20].</param>
    /// <param name="WSCEntryNoLog">VAR Integer.</param>
    procedure ParseResponse(StringToParse: Text; var WSCCodeLog: Code[20]; var WSCEntryNoLog: Integer)
    begin
        WSCCodeLog := CopyStr(StringToParse, 1, StrPos(StringToParse, ':') - 1);
        Evaluate(WSCEntryNoLog, CopyStr(StringToParse, StrPos(StringToParse, ':') + 1, MaxStrLen(WSCCodeLog)));
    end;

    #endregion ExecutionFunctions
    #region GeneralFunctions
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

    /// <summary>
    /// SetCustomBody.
    /// </summary>
    /// <param name="InStr">VAR InStream.</param>
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
        DataCompression.AddEntry(InStr, 'ResponseMessage.json');
        DataCompression.SaveZipArchive(OutStr);
    end;

    /// <summary>
    /// SetHideMessage.
    /// </summary>
    /// <param name="ParHideMessage">Boolean.</param>
    procedure SetHideMessage(ParHideMessage: Boolean)
    begin
        HideMessage := ParHideMessage;
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
    end;

    /// <summary>
    /// ShowWSCAsTree.
    /// </summary>
    procedure ShowWSCAsTree()
    var
        WebServicesTreeVisual: Page "WSC Tree Visualization";
    begin
        Clear(WebServicesTreeVisual);
        WebServicesTreeVisual.BuildPage();
        WebServicesTreeVisual.RunModal();
    end;

    /// <summary>
    /// LoadWSCTreeVisualTable.
    /// </summary>
    /// <param name="WebServicesTreeVisual">VAR Record "WSC Tree Visualization".</param>
    procedure LoadWSCTreeVisualTable(var WebServicesTreeVisual: Record "WSC Tree Visualization")
    var
        WSCWebServicesGroupCodes: Record "WSC Group Codes";
        Connections: Record "WSC Connections";
    begin
        WSCWebServicesGroupCodes.Reset();
        if not WSCWebServicesGroupCodes.IsEmpty then begin
            WSCWebServicesGroupCodes.FindSet();
            repeat
                Connections.Reset();
                Connections.SetRange("WSC Group Code", WSCWebServicesGroupCodes."WSC Code");
                if not Connections.IsEmpty() then begin
                    InsertGroupRecord(WSCWebServicesGroupCodes, WebServicesTreeVisual); //First Record only for group
                    Connections.SetRange("WSC Bearer Connection", true);
                    if not Connections.IsEmpty() then begin
                        Connections.FindSet();
                        repeat
                            CollectRecordWithTokenFromGroup(Connections, WebServicesTreeVisual); //Collect Token + Call Link to Token With Group
                        until Connections.Next() = 0;
                    end;
                    CollectRecordWithoutTokenFromGroup(WSCWebServicesGroupCodes."WSC Code", WebServicesTreeVisual); //Collect Call without linked Token With Group
                end;
            until WSCWebServicesGroupCodes.Next() = 0;
        end;

        Connections.Reset();
        Connections.SetRange("WSC Group Code", '');
        Connections.SetRange("WSC Bearer Connection", true);
        if not Connections.IsEmpty() then begin
            Connections.FindSet();
            repeat
                CollectRecordWithTokenNoGroup(Connections, WebServicesTreeVisual); //Collect Token + Call Lik to Token No Group
            until Connections.Next() = 0;
        end;
        CollectRecordWithoutTokenNoGroup('', WebServicesTreeVisual); //Collect Call without linked Token No Group 
        WebServicesTreeVisual.Reset();
    end;

    local procedure InsertGroupRecord(WSCWebServicesGroupCodes: Record "WSC Group Codes"; var WebServicesTreeVisual: Record "WSC Tree Visualization")
    begin
        WebServicesTreeVisual.Init();
        WebServicesTreeVisual.Validate("WSC Group Code", WSCWebServicesGroupCodes."WSC Code");
        WebServicesTreeVisual.Validate("WSC Entry No.", 1);
        WebServicesTreeVisual.Validate("WSC Indentation", 0);
        WebServicesTreeVisual.Validate("WSC Code", WSCWebServicesGroupCodes."WSC Code");
        WebServicesTreeVisual.Validate("WSC Description", WSCWebServicesGroupCodes."WSC Description");
        WebServicesTreeVisual.Insert();
    end;

    local procedure CollectRecordWithTokenFromGroup(BearerConnection: Record "WSC Connections"; var WebServicesTreeVisual: Record "WSC Tree Visualization")
    var
        Connections: Record "WSC Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", BearerConnection."WSC Group Code");
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        WebServicesTreeVisual.Init();
        WebServicesTreeVisual.Validate("WSC Group Code", BearerConnection."WSC Group Code");
        WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
        WebServicesTreeVisual.Validate("WSC Indentation", 1);
        WebServicesTreeVisual.Validate("WSC Code", BearerConnection."WSC Code");
        WebServicesTreeVisual.Validate("WSC Description", BearerConnection."WSC Description");
        WebServicesTreeVisual.Insert();

        Connections.Reset();
        Connections.SetRange("WSC Group Code", BearerConnection."WSC Group Code");
        Connections.SetRange("WSC Bearer Connection", false);
        Connections.SetRange("WSC Bearer Connection Code", BearerConnection."WSC Code");
        if not Connections.IsEmpty() then begin
            Connections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", Connections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 2);
                WebServicesTreeVisual.Validate("WSC Code", Connections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", Connections."WSC Description");
                WebServicesTreeVisual.Insert();
            until Connections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithTokenNoGroup(BearerConnection: Record "WSC Connections"; var WebServicesTreeVisual: Record "WSC Tree Visualization")
    var
        Connections: Record "WSC Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", BearerConnection."WSC Group Code");
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        WebServicesTreeVisual.Init();
        WebServicesTreeVisual.Validate("WSC Group Code", BearerConnection."WSC Group Code");
        WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
        WebServicesTreeVisual.Validate("WSC Indentation", 0);
        WebServicesTreeVisual.Validate("WSC Code", BearerConnection."WSC Code");
        WebServicesTreeVisual.Validate("WSC Description", BearerConnection."WSC Description");
        WebServicesTreeVisual.Insert();

        Connections.Reset();
        Connections.SetRange("WSC Group Code", BearerConnection."WSC Group Code");
        Connections.SetRange("WSC Bearer Connection", false);
        Connections.SetRange("WSC Bearer Connection Code", BearerConnection."WSC Code");
        if not Connections.IsEmpty() then begin
            Connections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", Connections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 1);
                WebServicesTreeVisual.Validate("WSC Code", Connections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", Connections."WSC Description");
                WebServicesTreeVisual.Insert();
            until Connections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithoutTokenFromGroup(WSCGroupCode: Code[20]; var WebServicesTreeVisual: Record "WSC Tree Visualization")
    var
        Connections: Record "WSC Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", WSCGroupCode);
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No."
        else
            NextEntryNo := 0;

        Connections.Reset();
        Connections.SetRange("WSC Group Code", WSCGroupCode);
        Connections.SetRange("WSC Bearer Connection", false);
        Connections.SetRange("WSC Bearer Connection Code", '');
        if not Connections.IsEmpty() then begin
            Connections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", Connections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 1);
                WebServicesTreeVisual.Validate("WSC Code", Connections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", Connections."WSC Description");
                WebServicesTreeVisual.Insert();
            until Connections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithoutTokenNoGroup(WSCGroupCode: Code[20]; var WebServicesTreeVisual: Record "WSC Tree Visualization")
    var
        Connections: Record "WSC Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", WSCGroupCode);
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No."
        else
            NextEntryNo := 0;

        Connections.Reset();
        Connections.SetRange("WSC Group Code", WSCGroupCode);
        Connections.SetRange("WSC Bearer Connection", false);
        Connections.SetRange("WSC Bearer Connection Code", '');
        if not Connections.IsEmpty() then begin
            Connections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", Connections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 0);
                WebServicesTreeVisual.Validate("WSC Code", Connections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", Connections."WSC Description");
                WebServicesTreeVisual.Insert();
            until Connections.Next() = 0;
        end;
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
                        //SecurityManagements.SetTokenForceNoEncryption(BearerConnection."WSC Access Token", JToken.AsValue().AsText(), BearerConnection.GetTokenDataScope());
                        SecurityManagements.SetToken(BearerConnection."WSC Access Token", JToken.AsValue().AsText(), BearerConnection.GetTokenDataScope());
                        //OuStr.WriteText(JToken.AsValue().AsText());
                    end;
                'refresh_token':
                    begin
                        //SecurityManagements.SetTokenForceNoEncryption(BearerConnection."WSC Refresh Token", JToken.AsValue().AsText(), BearerConnection.GetTokenDataScope());
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
        WebServicesCaller.RetrieveGlobalVariables(BodyInStream, ResponseInStream, CallExecution, HttpStatusCode, LastMessageText, NewEndPoint);

        LogCalls.Reset();
        LogCalls.SetRange("WSC Code", WSCCode);
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
        LogCalls."WSC Body Message".CreateOutStream(OutStr);
        WriteBlobFields(OutStr, BodyInStream);
        Clear(OutStr);

        //Response
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
            LogHeaders.Init();
            LogHeaders."WSC Log Entry No." := LogEntryNo;
            LogHeaders."WSC Entry No." := NextEntryNo;
            LogHeaders."WSC Code" := Headers."WSC Code";
            LogHeaders."WSC Key" := Headers."WSC Key";
            LogHeaders."WSC Value" := Headers."WSC Value";
            LogHeaders."WSC Description" := Headers."WSC Description";
            OnBeforeInsertLogHeaders(LogHeaders, Headers);
            LogHeaders.Insert();
        until Headers.Next() = 0;
    end;

    local procedure WriteBodyLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        Connections: Record "WSC Connections";
        Bodies: Record "WSC Bodies";
        LogBodies: Record "WSC Log Bodies";
        NextEntryNo: Integer;
    begin
        Connections.Get(WSCCode);
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

    #endregion IntegrationEvents
    var
        WebServicesCaller: Codeunit "WSC Caller";
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CustomBodyInStream: InStream;
        ResponseText: Text;
        CallExecution: Boolean;
        HideMessage: Boolean;
        CustomBodyIsSet: Boolean;
        HttpStatusCode: Integer;
        LastMessageText: Text;
        NewEndPoint: Text;
}