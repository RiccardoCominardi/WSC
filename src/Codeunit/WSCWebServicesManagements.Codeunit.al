/// <summary>
/// Codeunit WSC Web Services Management (ID 81001).
/// </summary>
codeunit 81001 "WSC Web Services Management"
{
    trigger OnRun()
    begin
    end;

    #region ExecutionFunctions

    /// <summary>
    /// ExecuteWSCConnections.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    /// <param name="WebServicesLogCalls">Record "WSC Web Services Log Calls".</param>
    /// <returns>Return variable Result of type Boolean.</returns>
    procedure ExecuteWSCConnections(WSCCode: Code[20]; var WebServicesLogCalls: Record "WSC Web Services Log Calls"): Boolean
    var
        ResponseString: Text;
        WSCodeLog: Code[20];
        WSEntryLog: Integer;
    begin
        ResponseString := ExecuteDirectWSCConnections(WSCCode);
        ParseResponse(ResponseString, WSCodeLog, WSEntryLog);

        WebServicesLogCalls.Get(WSCodeLog, WSEntryLog);
        if IsSuccessStatusCode(WSCodeLog, WSEntryLog) then
            exit(true)
        else
            exit(false);
    end;

    local procedure ExecuteDirectWSCConnections(WSCCode: Code[20]) ResponseString: Text;
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        WSCConnBearer: Record "WSC Web Services Connections";
        TokenEntryNo: Integer;
        LogEntryNo: Integer;
        Text000Lbl: Label 'Execution Terminated. Check the log to see the result';
        IsHandled: Boolean;
    begin
        WebServicesConnections.Get(WSCCode);
        CheckWSCodeSetup(WebServicesConnections);
        WriteCustomBodyOnWSCRec(WebServicesConnections);

        OnBeforeExecuteDirectWSCConnections(IsHandled, WebServicesConnections);
        if IsHandled then
            exit;

        case WebServicesConnections."WSC Auth. Type" of
            WebServicesConnections."WSC Auth. Type"::none,
            WebServicesConnections."WSC Auth. Type"::basic:
                begin
                    Clear(WebServicesCaller);
                    ClearLastError();
                    if WebServicesConnections."WSC Bearer Connection" then begin
                        ExecuteTokenCall(WebServicesConnections."WSC Code", WSCConnBearer, TokenEntryNo);
                        LogEntryNo := TokenEntryNo;
                    end else begin
                        if WebServicesCaller.Run(WebServicesConnections) then;
                        LogEntryNo := WriteConnectionLog(WSCCode, '', 0);
                    end;
                    ResponseString := WebServicesConnections."WSC Code" + ':' + Format(LogEntryNo);
                end;
            WebServicesConnections."WSC Auth. Type"::"bearer token":
                if ExecuteTokenCall(WebServicesConnections."WSC Bearer Connection Code", WSCConnBearer, TokenEntryNo) then begin
                    Commit();
                    Clear(WebServicesCaller);
                    ClearLastError();
                    if WebServicesCaller.Run(WebServicesConnections) then;
                    LogEntryNo := WriteConnectionLog(WSCCode, WSCConnBearer."WSC Code", TokenEntryNo);
                    ResponseString := WebServicesConnections."WSC Code" + ':' + Format(LogEntryNo);
                end else
                    ResponseString := WebServicesConnections."WSC Bearer Connection Code" + ':' + Format(TokenEntryNo);
        end;
        OnAfterExecuteDirectWSCConnections(WebServicesConnections);

        if GuiAllowed() then
            if not HideMessage then
                Message(Text000Lbl);
    end;

    local procedure ExecuteTokenCall(WSCTokenCode: Code[20]; var WSCConnBearer: Record "WSC Web Services Connections"; var TokenEntryNo: Integer) TokenTaken: Boolean;
    var
        WSCWSServicesLogCalls: Record "WSC Web Services Log Calls";
    begin
        TokenTaken := false;
        WSCConnBearer.Get(WSCTokenCode);
        CheckWSCodeSetup(WSCConnBearer);
        if IsTokenCallToDo(WSCConnBearer) then begin
            Clear(WebServicesCaller);
            ClearLastError();
            if WebServicesCaller.Run(WSCConnBearer) then;
            TokenEntryNo := WriteConnectionLog(WSCConnBearer."WSC Code", '', 0);
            if IsSuccessStatusCode(WSCConnBearer."WSC Code", TokenEntryNo) then begin
                TokenTaken := true;
                UpdateWSCTokenInfo(WSCConnBearer);
            end;
        end else begin
            WSCWSServicesLogCalls.Reset();
            WSCWSServicesLogCalls.SetRange("WSC Code", WSCConnBearer."WSC Code");
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
    local procedure CheckWSCodeSetup(WebServicesConnections: Record "WSC Web Services Connections")
    begin
        WebServicesConnections.TestField("WSC EndPoint");
        case WebServicesConnections."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                begin
                    WebServicesConnections.TestField("WSC Username");
                    WebServicesConnections.TestField("WSC Password");
                end;

            WebServicesConnections."WSC Auth. Type"::"bearer token":
                WebServicesConnections.TestField("WSC Bearer Connection Code");

            WebServicesConnections."WSC Auth. Type"::none:
                if WebServicesConnections."WSC Bearer Connection" then begin
                    WebServicesConnections.TestField("WSC Bearer Connection Code", '');
                    CheckWSBodiesForToken(WebServicesConnections);
                end;
        end;

        case WebServicesConnections."WSC Body Type" of
            "WSC Body Types"::raw,
            "WSC Body Types"::binary:
                WebServicesConnections.TestField("WSC Body Method");
        end;

        OnAfterCheckWSCCodeSetup(WebServicesConnections);
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

    local procedure WriteCustomBodyOnWSCRec(var WebServicesConnections: Record "WSC Web Services Connections")
    var
        OutStr: OutStream;
    begin
        ClearWSCBodyMessage(WebServicesConnections);
        if not CustomBodyIsSet then
            exit;
        WebServicesConnections."WSC Body Message".CreateOutStream(OutStr);
        CopyStream(OutStr, CustomBodyInStream);
        WebServicesConnections.Modify();
        Commit();
    end;

    local procedure ClearWSCBodyMessage(var WebServicesConnections: Record "WSC Web Services Connections")
    begin
        WebServicesConnections.LockTable();
        Clear(WebServicesConnections."WSC Body Message");
        WebServicesConnections.Modify();
        Commit();
    end;

    local procedure IsSuccessStatusCode(WSCCode: Code[20]; EntryNo: Integer): Boolean
    var
        WebServicesLogCalls: Record "WSC Web Services Log Calls";
    begin
        WebServicesLogCalls.Get(WSCCode, EntryNo);
        case WebServicesLogCalls."WSC Result Status Code" of
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
        WebServicesTreeVisual: Page "WSC Web Services Tree Visual";
    begin
        Clear(WebServicesTreeVisual);
        WebServicesTreeVisual.BuildPage();
        WebServicesTreeVisual.RunModal();
    end;

    /// <summary>
    /// LoadWSCTreeVisualTable.
    /// </summary>
    /// <param name="WebServicesTreeVisual">VAR Record "WSC Web Services Tree Visual".</param>
    procedure LoadWSCTreeVisualTable(var WebServicesTreeVisual: Record "WSC Web Services Tree Visual")
    var
        WSCWebServicesGroupCodes: Record "WSC Web Services Group Codes";
        WebServicesConnections: Record "WSC Web Services Connections";
    begin
        WSCWebServicesGroupCodes.Reset();
        if not WSCWebServicesGroupCodes.IsEmpty then begin
            WSCWebServicesGroupCodes.FindSet();
            repeat
                WebServicesConnections.Reset();
                WebServicesConnections.SetRange("WSC Group Code", WSCWebServicesGroupCodes."WSC Code");
                if not WebServicesConnections.IsEmpty() then begin
                    InsertGroupRecord(WSCWebServicesGroupCodes, WebServicesTreeVisual); //First Record only for group
                    WebServicesConnections.SetRange("WSC Bearer Connection", true);
                    if not WebServicesConnections.IsEmpty() then begin
                        WebServicesConnections.FindSet();
                        repeat
                            CollectRecordWithTokenFromGroup(WebServicesConnections, WebServicesTreeVisual); //Collect Token + Call Link to Token With Group
                        until WebServicesConnections.Next() = 0;
                    end;
                    CollectRecordWithoutTokenFromGroup(WSCWebServicesGroupCodes."WSC Code", WebServicesTreeVisual); //Collect Call without linked Token With Group
                end;
            until WSCWebServicesGroupCodes.Next() = 0;
        end;

        WebServicesConnections.Reset();
        WebServicesConnections.SetRange("WSC Group Code", '');
        WebServicesConnections.SetRange("WSC Bearer Connection", true);
        if not WebServicesConnections.IsEmpty() then begin
            WebServicesConnections.FindSet();
            repeat
                CollectRecordWithTokenNoGroup(WebServicesConnections, WebServicesTreeVisual); //Collect Token + Call Lik to Token No Group
            until WebServicesConnections.Next() = 0;
        end;
        CollectRecordWithoutTokenNoGroup('', WebServicesTreeVisual); //Collect Call without linked Token No Group 
        WebServicesTreeVisual.Reset();
    end;

    local procedure InsertGroupRecord(WSCWebServicesGroupCodes: Record "WSC Web Services Group Codes"; var WebServicesTreeVisual: Record "WSC Web Services Tree Visual")
    begin
        WebServicesTreeVisual.Init();
        WebServicesTreeVisual.Validate("WSC Group Code", WSCWebServicesGroupCodes."WSC Code");
        WebServicesTreeVisual.Validate("WSC Entry No.", 1);
        WebServicesTreeVisual.Validate("WSC Indentation", 0);
        WebServicesTreeVisual.Validate("WSC Code", WSCWebServicesGroupCodes."WSC Code");
        WebServicesTreeVisual.Validate("WSC Description", WSCWebServicesGroupCodes."WSC Description");
        WebServicesTreeVisual.Insert();
    end;

    local procedure CollectRecordWithTokenFromGroup(WSCConnBearer: Record "WSC Web Services Connections"; var WebServicesTreeVisual: Record "WSC Web Services Tree Visual")
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        WebServicesTreeVisual.Init();
        WebServicesTreeVisual.Validate("WSC Group Code", WSCConnBearer."WSC Group Code");
        WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
        WebServicesTreeVisual.Validate("WSC Indentation", 1);
        WebServicesTreeVisual.Validate("WSC Code", WSCConnBearer."WSC Code");
        WebServicesTreeVisual.Validate("WSC Description", WSCConnBearer."WSC Description");
        WebServicesTreeVisual.Insert();

        WebServicesConnections.Reset();
        WebServicesConnections.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        WebServicesConnections.SetRange("WSC Bearer Connection", false);
        WebServicesConnections.SetRange("WSC Bearer Connection Code", WSCConnBearer."WSC Code");
        if not WebServicesConnections.IsEmpty() then begin
            WebServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", WebServicesConnections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 2);
                WebServicesTreeVisual.Validate("WSC Code", WebServicesConnections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", WebServicesConnections."WSC Description");
                WebServicesTreeVisual.Insert();
            until WebServicesConnections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithTokenNoGroup(WSCConnBearer: Record "WSC Web Services Connections"; var WebServicesTreeVisual: Record "WSC Web Services Tree Visual")
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        WebServicesTreeVisual.Init();
        WebServicesTreeVisual.Validate("WSC Group Code", WSCConnBearer."WSC Group Code");
        WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
        WebServicesTreeVisual.Validate("WSC Indentation", 0);
        WebServicesTreeVisual.Validate("WSC Code", WSCConnBearer."WSC Code");
        WebServicesTreeVisual.Validate("WSC Description", WSCConnBearer."WSC Description");
        WebServicesTreeVisual.Insert();

        WebServicesConnections.Reset();
        WebServicesConnections.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        WebServicesConnections.SetRange("WSC Bearer Connection", false);
        WebServicesConnections.SetRange("WSC Bearer Connection Code", WSCConnBearer."WSC Code");
        if not WebServicesConnections.IsEmpty() then begin
            WebServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", WebServicesConnections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 1);
                WebServicesTreeVisual.Validate("WSC Code", WebServicesConnections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", WebServicesConnections."WSC Description");
                WebServicesTreeVisual.Insert();
            until WebServicesConnections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithoutTokenFromGroup(WSCGroupCode: Code[20]; var WebServicesTreeVisual: Record "WSC Web Services Tree Visual")
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", WSCGroupCode);
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No."
        else
            NextEntryNo := 0;

        WebServicesConnections.Reset();
        WebServicesConnections.SetRange("WSC Group Code", WSCGroupCode);
        WebServicesConnections.SetRange("WSC Bearer Connection", false);
        WebServicesConnections.SetRange("WSC Bearer Connection Code", '');
        if not WebServicesConnections.IsEmpty() then begin
            WebServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", WebServicesConnections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 1);
                WebServicesTreeVisual.Validate("WSC Code", WebServicesConnections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", WebServicesConnections."WSC Description");
                WebServicesTreeVisual.Insert();
            until WebServicesConnections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithoutTokenNoGroup(WSCGroupCode: Code[20]; var WebServicesTreeVisual: Record "WSC Web Services Tree Visual")
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WebServicesTreeVisual.Reset();
        WebServicesTreeVisual.SetRange("WSC Group Code", WSCGroupCode);
        if WebServicesTreeVisual.FindLast() then
            NextEntryNo := WebServicesTreeVisual."WSC Entry No."
        else
            NextEntryNo := 0;

        WebServicesConnections.Reset();
        WebServicesConnections.SetRange("WSC Group Code", WSCGroupCode);
        WebServicesConnections.SetRange("WSC Bearer Connection", false);
        WebServicesConnections.SetRange("WSC Bearer Connection Code", '');
        if not WebServicesConnections.IsEmpty() then begin
            WebServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WebServicesTreeVisual.Init();
                WebServicesTreeVisual.Validate("WSC Group Code", WebServicesConnections."WSC Group Code");
                WebServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WebServicesTreeVisual.Validate("WSC Indentation", 0);
                WebServicesTreeVisual.Validate("WSC Code", WebServicesConnections."WSC Code");
                WebServicesTreeVisual.Validate("WSC Description", WebServicesConnections."WSC Description");
                WebServicesTreeVisual.Insert();
            until WebServicesConnections.Next() = 0;
        end;
    end;

    #endregion GeneralFunctions
    #region TokenFunctions
    local procedure CheckWSBodiesForToken(WSCConnBearer: Record "WSC Web Services Connections")
    var
        WebServicesBodies: Record "WSC Web Services Bodies";
        Text000Err: Label 'Key %1 must be filled for token request';
        IsHandled: Boolean;
    begin
        OnBeforeCheckWSCBodiesForToken(IsHandled, WSCConnBearer);
        if IsHandled then
            exit;

        WebServicesBodies.Get(WSCConnBearer."WSC Code", 'grant_type');
        case WebServicesBodies."WSC Value" of
            'client_credentials':
                begin
                    WebServicesBodies.Reset();
                    WebServicesBodies.SetRange("WSC Code", WSCConnBearer."WSC Code");
                    WebServicesBodies.SetRange("WSC Key", 'client_id');
                    WebServicesBodies.FindFirst();
                    if not WebServicesBodies.HasValue() then
                        Error(Text000Err, 'client_id');
                    WebServicesBodies.SetRange("WSC Key", 'client_secret');
                    WebServicesBodies.FindFirst();
                    if not WebServicesBodies.HasValue() then
                        Error(Text000Err, 'client_secret');
                    WebServicesBodies.SetRange("WSC Key", 'scope');
                    WebServicesBodies.FindFirst();
                    if not WebServicesBodies.HasValue() then
                        Error(Text000Err, 'scope');
                end;
            'authorization_code':
                ;
            'password':
                ;
        end;
        OnAfterCheckWSCBodiesForToken(WSCConnBearer);
    end;

    local procedure UpdateWSCTokenInfo(var WSCConnBearer: Record "WSC Web Services Connections")
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
        OnBeforeReadJsonTokenResponse(IsHandled, JAccessToken, WSCConnBearer);
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
                    WSCConnBearer."WSC Expires In" := JToken.AsValue().AsInteger();
                'ext_expires_in':
                    ;
                'access_token':
                    begin
                        //SecurityManagements.SetTokenForceNoEncryption(WSCConnBearer."WSC Access Token", JToken.AsValue().AsText(), WSCConnBearer.GetTokenDataScope());
                        SecurityManagements.SetToken(WSCConnBearer."WSC Access Token", JToken.AsValue().AsText(), WSCConnBearer.GetTokenDataScope());
                        //OuStr.WriteText(JToken.AsValue().AsText());
                    end;
                'refresh_token':
                    begin
                        //SecurityManagements.SetTokenForceNoEncryption(WSCConnBearer."WSC Refresh Token", JToken.AsValue().AsText(), WSCConnBearer.GetTokenDataScope());
                        SecurityManagements.SetToken(WSCConnBearer."WSC Refresh Token", JToken.AsValue().AsText(), WSCConnBearer.GetTokenDataScope());
                    end;
                else
                    Error(Text000Err, Property, JToken.AsValue().AsText());
            end;
        end;
        OnAfterReadJsonTokenResponse(JAccessToken, WSCConnBearer);
        WSCConnBearer."WSC Authorization Time" := CurrentDateTime();
        WSCConnBearer.Modify();
    end;

    local procedure IsTokenCallToDo(WSCConnBearer: Record "WSC Web Services Connections"): Boolean
    var
        ElapsedSecs: Integer;
    begin
        if WSCConnBearer."WSC Authorization Time" = 0DT then
            exit(true);

        ElapsedSecs := Round((CurrentDateTime() - WSCConnBearer."WSC Authorization Time") / 1000, 1, '>');
        if (ElapsedSecs < WSCConnBearer."WSC Expires In") and (ElapsedSecs < 3600) then
            exit(false);

        exit(true);
    end;

    #endregion TokenFunctions
    #region LogFunctions
    local procedure WriteConnectionLog(WSCCode: Code[20]; TokenWSCCode: Code[20]; TokenEntryNo: Integer) CurrEntryNo: Integer;
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        WebServicesLogCalls: Record "WSC Web Services Log Calls";
        NextEntryNo: Integer;
        OutStr: OutStream;
    begin
        WebServicesConnections.Get(WSCCode);
        ClearGlobalVariables();
        WebServicesCaller.RetrieveGlobalVariables(BodyInStream, ResponseInStream, CallExecution, HttpStatusCode, LastMessageText, NewEndPoint);

        WebServicesLogCalls.Reset();
        WebServicesLogCalls.SetRange("WSC Code", WSCCode);
        if WebServicesLogCalls.FindLast() then
            NextEntryNo := WebServicesLogCalls."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        CurrEntryNo := NextEntryNo;

        WebServicesLogCalls.Init();
        WebServicesLogCalls."WSC Entry No." := CurrEntryNo;
        WebServicesLogCalls."WSC Code" := WebServicesConnections."WSC Code";
        WebServicesLogCalls."WSC Description" := WebServicesConnections."WSC Description";
        WebServicesLogCalls."WSC HTTP Method" := WebServicesConnections."WSC HTTP Method";
        WebServicesLogCalls."WSC EndPoint" := NewEndPoint;
        WebServicesLogCalls."WSC Auth. Type" := WebServicesConnections."WSC Auth. Type";
        WebServicesLogCalls."WSC Bearer Connection" := WebServicesConnections."WSC Bearer Connection";
        WebServicesLogCalls."WSC Bearer Connection Code" := WebServicesConnections."WSC Bearer Connection Code";
        WebServicesLogCalls."WSC Body Type" := WebServicesConnections."WSC Body Type";
        WebServicesLogCalls."WSC Allow Blank Response" := WebServicesConnections."WSC Allow Blank Response";
        WebServicesLogCalls."WSC Group Code" := WebServicesConnections."WSC Group Code";

        //Body Request
        Clear(OutStr);
        WebServicesLogCalls."WSC Body Message".CreateOutStream(OutStr);
        WriteBlobFields(OutStr, BodyInStream);
        Clear(OutStr);

        //Response
        WebServicesLogCalls."WSC Zip Response" := WebServicesConnections."WSC Zip Response";
        WebServicesLogCalls."WSC Response Message".CreateOutStream(OutStr);
        if WebServicesLogCalls."WSC Zip Response" then
            WriteZippedBlobFields(OutStr, ResponseInStream)
        else
            WriteBlobFields(OutStr, ResponseInStream);

        //Assign Response to a Globar variable to use 
        ResponseInStream.ResetPosition();
        ResponseInStream.ReadText(ResponseText);

        WebServicesLogCalls."WSC Message Text" := CopyStr(LastMessageText, 1, MaxStrLen(WebServicesLogCalls."WSC Message Text"));
        WebServicesLogCalls."WSC Link to WSC Code" := TokenWSCCode;
        WebServicesLogCalls."WSC Link To Entry No." := TokenEntryNo;
        WebServicesLogCalls."WSC Result Status Code" := HttpStatusCode;
        WebServicesLogCalls."WSC Execution Date-Time" := CurrentDateTime();
        WebServicesLogCalls."WSC Execution UserID" := UserId();
        OnBeforeInsertWebServicesLogCalls(WebServicesLogCalls, WebServicesConnections);
        WebServicesLogCalls.Insert();

        if WebServicesConnections."WSC Store Parameters Datas" then
            WriteParametersLog(WSCCode, CurrEntryNo);
        if WebServicesConnections."WSC Store Headers Datas" then
            WriteHeaderLog(WSCCode, CurrEntryNo);
        if WebServicesConnections."WSC Store Body Datas" then
            WriteBodyLog(WSCCode, CurrEntryNo);
    end;

    local procedure WriteParametersLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        WebServicesParameters: Record "WSC Web Services Parameters";
        WebServicesLogParam: Record "WSC Web Services Log Param.";
        NextEntryNo: Integer;
    begin
        WebServicesParameters.Reset();
        WebServicesParameters.SetRange("WSC Code", WSCCode);
        if WebServicesParameters.IsEmpty() then
            exit;

        WebServicesLogParam.Reset();
        WebServicesLogParam.SetRange("WSC Code", WSCCode);
        WebServicesLogParam.SetRange("WSC Log Entry No.", LogEntryNo);
        if WebServicesLogParam.FindLast() then
            NextEntryNo := WebServicesLogParam."WSC Entry No."
        else
            NextEntryNo := 0;

        WebServicesParameters.FindSet();
        repeat
            NextEntryNo += 1;
            WebServicesLogParam.Init();
            WebServicesLogParam."WSC Log Entry No." := LogEntryNo;
            WebServicesLogParam."WSC Entry No." := NextEntryNo;
            WebServicesLogParam."WSC Code" := WebServicesParameters."WSC Code";
            WebServicesLogParam."WSC Key" := WebServicesParameters."WSC Key";
            WebServicesLogParam."WSC Value" := WebServicesParameters."WSC Value"; //serve prendere il dato dei parametri????
            WebServicesLogParam."WSC Description" := WebServicesParameters."WSC Description";
            OnBeforeInsertWebServicesLogParam(WebServicesLogParam, WebServicesParameters);
            WebServicesLogParam.Insert();
        until WebServicesParameters.Next() = 0;
    end;

    local procedure WriteHeaderLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        WebServicesHeaders: Record "WSC Web Services Headers";
        WebServicesLogHeaders: Record "WSC Web Services Log Headers";
        NextEntryNo: Integer;
    begin
        WebServicesHeaders.Reset();
        WebServicesHeaders.SetRange("WSC Code", WSCCode);
        if WebServicesHeaders.IsEmpty() then
            exit;

        WebServicesLogHeaders.Reset();
        WebServicesLogHeaders.SetRange("WSC Code", WSCCode);
        WebServicesLogHeaders.SetRange("WSC Log Entry No.", LogEntryNo);
        if WebServicesLogHeaders.FindLast() then
            NextEntryNo := WebServicesLogHeaders."WSC Entry No."
        else
            NextEntryNo := 0;

        WebServicesHeaders.FindSet();
        repeat
            NextEntryNo += 1;
            WebServicesLogHeaders.Init();
            WebServicesLogHeaders."WSC Log Entry No." := LogEntryNo;
            WebServicesLogHeaders."WSC Entry No." := NextEntryNo;
            WebServicesLogHeaders."WSC Code" := WebServicesHeaders."WSC Code";
            WebServicesLogHeaders."WSC Key" := WebServicesHeaders."WSC Key";
            WebServicesLogHeaders."WSC Value" := WebServicesHeaders."WSC Value";
            WebServicesLogHeaders."WSC Description" := WebServicesHeaders."WSC Description";
            OnBeforeInsertWebServicesLogHeaders(WebServicesLogHeaders, WebServicesHeaders);
            WebServicesLogHeaders.Insert();
        until WebServicesHeaders.Next() = 0;
    end;

    local procedure WriteBodyLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        WebServicesBodies: Record "WSC Web Services Bodies";
        WebServicesLogBodies: Record "WSC Web Services Log Bodies";
        NextEntryNo: Integer;
    begin
        WebServicesConnections.Get(WSCCode);
        WebServicesBodies.Reset();
        WebServicesBodies.SetRange("WSC Code", WSCCode);
        if WebServicesBodies.IsEmpty() then
            exit;

        WebServicesLogBodies.Reset();
        WebServicesLogBodies.SetRange("WSC Code", WSCCode);
        WebServicesLogBodies.SetRange("WSC Log Entry No.", LogEntryNo);
        if WebServicesLogBodies.FindLast() then
            NextEntryNo := WebServicesLogBodies."WSC Entry No."
        else
            NextEntryNo := 0;

        WebServicesBodies.FindSet();
        repeat
            NextEntryNo += 1;
            WebServicesLogBodies.Init();
            WebServicesLogBodies."WSC Log Entry No." := LogEntryNo;
            WebServicesLogBodies."WSC Entry No." := NextEntryNo;
            WebServicesLogBodies."WSC Code" := WebServicesBodies."WSC Code";
            WebServicesLogBodies."WSC Key" := WebServicesBodies."WSC Key";
            WebServicesLogBodies."WSC Value" := WebServicesBodies.GetValue();
            WebServicesLogBodies."WSC Description" := WebServicesBodies."WSC Description";
            OnBeforeInsertWebServicesLogBodies(WebServicesLogBodies, WebServicesBodies);
            WebServicesLogBodies.Insert();
        until WebServicesBodies.Next() = 0;
    end;
    #endregion LogFunctions
    #region IntegrationEvents
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecuteDirectWSCConnections(var IsHandled: Boolean; WSCWebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExecuteDirectWSCConnections(WSCWebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWSCBodiesForToken(var IsHandled: Boolean; WSCConnBearer: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWSCBodiesForToken(WSCConnBearer: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWSCCodeSetup(WSCWebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReadJsonTokenResponse(var IsHandled: Boolean; JAccessToken: JsonObject; var WSCConnBearer: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReadJsonTokenResponse(JAccessToken: JsonObject; var WSCConnBearer: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWebServicesLogCalls(var WebServicesLogCalls: Record "WSC Web Services Log Calls"; WebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWebServicesLogParam(var WebServicesLogParam: Record "WSC Web Services Log Param."; WebServicesParameters: Record "WSC Web Services Parameters")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWebServicesLogHeaders(var WebServicesLogHeaders: Record "WSC Web Services Log Headers"; WebServicesHeaders: Record "WSC Web Services Headers")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWebServicesLogBodies(var WebServicesLogBodies: Record "WSC Web Services Log Bodies"; WebServicesBodies: Record "WSC Web Services Bodies")
    begin
    end;

    #endregion IntegrationEvents
    var
        WebServicesCaller: Codeunit "WSC Web Services Caller";
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