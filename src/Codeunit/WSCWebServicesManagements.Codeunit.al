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
    /// ExecuteDirectWSCConnections.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    /// <returns>Return variable ResponseString of type Text.</returns>
    procedure ExecuteDirectWSCConnections(WSCCode: Code[20]) ResponseString: Text;
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCConnBearer: Record "WSC Web Services Connections";
        TokenEntryNo: Integer;
        LogEntryNo: Integer;
        Text000Lbl: Label 'Execution Terminated. Check the log to see the result';
        IsHandled: Boolean;
    begin
        WSCWSServicesConnections.Get(WSCCode);
        CheckWSCCodeSetup(WSCWSServicesConnections);
        WriteCustomBodyOnWSCRec(WSCWSServicesConnections);

        OnBeforeExecuteDirectWSCConnections(IsHandled, WSCWSServicesConnections);
        if IsHandled then
            exit;

        case WSCWSServicesConnections."WSC Auth. Type" of
            WSCWSServicesConnections."WSC Auth. Type"::none,
            WSCWSServicesConnections."WSC Auth. Type"::basic:
                begin
                    Clear(WSCWebServicesCaller);
                    ClearLastError();
                    if WSCWSServicesConnections."WSC Bearer Connection" then begin
                        ExecuteTokenCall(WSCWSServicesConnections."WSC Code", WSCConnBearer, TokenEntryNo);
                        LogEntryNo := TokenEntryNo;
                    end else begin
                        if WSCWebServicesCaller.Run(WSCWSServicesConnections) then;
                        LogEntryNo := WriteConnectionLog(WSCCode, '', 0);
                    end;
                    ResponseString := WSCWSServicesConnections."WSC Code" + ':' + Format(LogEntryNo);
                end;
            WSCWSServicesConnections."WSC Auth. Type"::"bearer token":
                if ExecuteTokenCall(WSCWSServicesConnections."WSC Bearer Connection Code", WSCConnBearer, TokenEntryNo) then begin
                    Commit();
                    Clear(WSCWebServicesCaller);
                    ClearLastError();
                    if WSCWebServicesCaller.Run(WSCWSServicesConnections) then;
                    LogEntryNo := WriteConnectionLog(WSCCode, WSCConnBearer."WSC Code", TokenEntryNo);
                    ResponseString := WSCWSServicesConnections."WSC Code" + ':' + Format(LogEntryNo);
                end else
                    ResponseString := WSCWSServicesConnections."WSC Bearer Connection Code" + ':' + Format(TokenEntryNo);
        end;
        OnAfterExecuteDirectWSCConnections(WSCWSServicesConnections);

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
        CheckWSCCodeSetup(WSCConnBearer);
        if IsTokenCallToDo(WSCConnBearer) then begin
            Clear(WSCWebServicesCaller);
            ClearLastError();
            if WSCWebServicesCaller.Run(WSCConnBearer) then;
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
    local procedure CheckWSCCodeSetup(WSCWSServicesConnections: Record "WSC Web Services Connections")
    begin
        WSCWSServicesConnections.TestField("WSC EndPoint");
        case WSCWSServicesConnections."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                begin
                    WSCWSServicesConnections.TestField("WSC Username");
                    WSCWSServicesConnections.TestField("WSC Password");
                end;

            WSCWSServicesConnections."WSC Auth. Type"::"bearer token":
                WSCWSServicesConnections.TestField("WSC Bearer Connection Code");

            WSCWSServicesConnections."WSC Auth. Type"::none:
                if WSCWSServicesConnections."WSC Bearer Connection" then begin
                    WSCWSServicesConnections.TestField("WSC Bearer Connection Code", '');
                    CheckWSBodiesForToken(WSCWSServicesConnections);
                end;
        end;

        case WSCWSServicesConnections."WSC Body Type" of
            "WSC Body Types"::raw,
            "WSC Body Types"::binary:
                WSCWSServicesConnections.TestField("WSC Body Method");
        end;

        OnAfterCheckWSCCodeSetup(WSCWSServicesConnections);
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

    local procedure WriteCustomBodyOnWSCRec(var WSCWSServicesConnections: Record "WSC Web Services Connections")
    var
        OutStr: OutStream;
    begin
        ClearWSCBodyMessage(WSCWSServicesConnections);
        if not CustomBodyIsSet then
            exit;
        WSCWSServicesConnections."WSC Body Message".CreateOutStream(OutStr);
        CopyStream(OutStr, CustomBodyInStream);
        WSCWSServicesConnections.Modify();
        Commit();
    end;

    local procedure ClearWSCBodyMessage(var WSCWSServicesConnections: Record "WSC Web Services Connections")
    begin
        WSCWSServicesConnections.LockTable();
        Clear(WSCWSServicesConnections."WSC Body Message");
        WSCWSServicesConnections.Modify();
        Commit();
    end;

    local procedure IsSuccessStatusCode(WSCCode: Code[20]; EntryNo: Integer): Boolean
    var
        WSCWebServicesLogCalls: Record "WSC Web Services Log Calls";
    begin
        WSCWebServicesLogCalls.Get(WSCCode, EntryNo);
        case WSCWebServicesLogCalls."WSC Result Status Code" of
            200,
            201,
            202:
                exit(true);
        end;
    end;

    local procedure WriteBlobFields(var OutStr: OutStream; var InStr: InStream)
    var
        CurrText: Text;
    begin
        while not InStr.EOS() do begin
            InStr.ReadText(CurrText);
            ResponseText += CurrText;
            OutStr.Write(CurrText);
        end;
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
        WCSWSServicesTreeVisual: Page "WCS Web Services Tree Visual";
    begin
        Clear(WCSWSServicesTreeVisual);
        WCSWSServicesTreeVisual.BuildPage();
        WCSWSServicesTreeVisual.RunModal();
    end;

    /// <summary>
    /// LoadWCSTreeVisualTable.
    /// </summary>
    /// <param name="WCSWSServicesTreeVisual">VAR Record "WCS Web Services Tree Visual".</param>
    procedure LoadWCSTreeVisualTable(var WCSWSServicesTreeVisual: Record "WCS Web Services Tree Visual")
    var
        WSCWebServicesGroupCodes: Record "WSC Web Services Group Codes";
        WSCWSServicesConnections: Record "WSC Web Services Connections";
    begin
        WSCWebServicesGroupCodes.Reset();
        if not WSCWebServicesGroupCodes.IsEmpty then begin
            WSCWebServicesGroupCodes.FindSet();
            repeat
                WSCWSServicesConnections.Reset();
                WSCWSServicesConnections.SetRange("WSC Group Code", WSCWebServicesGroupCodes."WSC Code");
                if not WSCWSServicesConnections.IsEmpty() then begin
                    InsertGroupRecord(WSCWebServicesGroupCodes, WCSWSServicesTreeVisual); //First Record only for group
                    WSCWSServicesConnections.SetRange("WSC Bearer Connection", true);
                    if not WSCWSServicesConnections.IsEmpty() then begin
                        WSCWSServicesConnections.FindSet();
                        repeat
                            CollectRecordWithTokenFromGroup(WSCWSServicesConnections, WCSWSServicesTreeVisual); //Collect Token + Call Lik to Token With Group
                        until WSCWSServicesConnections.Next() = 0;
                    end;
                    CollectRecordWithoutTokenFromGroup(WSCWebServicesGroupCodes."WSC Code", WCSWSServicesTreeVisual); //Collect Call without linked Token With Group
                end;
            until WSCWebServicesGroupCodes.Next() = 0;
        end;

        WSCWSServicesConnections.Reset();
        WSCWSServicesConnections.SetRange("WSC Group Code", '');
        WSCWSServicesConnections.SetRange("WSC Bearer Connection", true);
        if not WSCWSServicesConnections.IsEmpty() then begin
            WSCWSServicesConnections.FindSet();
            repeat
                CollectRecordWithTokenNoGroup(WSCWSServicesConnections, WCSWSServicesTreeVisual); //Collect Token + Call Lik to Token No Group
            until WSCWSServicesConnections.Next() = 0;
        end;
        CollectRecordWithoutTokenNoGroup('', WCSWSServicesTreeVisual); //Collect Call without linked Token No Group 
        WCSWSServicesTreeVisual.Reset();
    end;

    local procedure InsertGroupRecord(WSCWebServicesGroupCodes: Record "WSC Web Services Group Codes"; var WCSWSServicesTreeVisual: Record "WCS Web Services Tree Visual")
    begin
        WCSWSServicesTreeVisual.Init();
        WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCWebServicesGroupCodes."WSC Code");
        WCSWSServicesTreeVisual.Validate("WSC Entry No.", 1);
        WCSWSServicesTreeVisual.Validate("WSC Indentation", 0);
        WCSWSServicesTreeVisual.Validate("WSC Code", WSCWebServicesGroupCodes."WSC Code");
        WCSWSServicesTreeVisual.Validate("WSC Description", WSCWebServicesGroupCodes."WSC Description");
        WCSWSServicesTreeVisual.Insert();
    end;

    local procedure CollectRecordWithTokenFromGroup(WSCConnBearer: Record "WSC Web Services Connections"; var WCSWSServicesTreeVisual: Record "WCS Web Services Tree Visual")
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WCSWSServicesTreeVisual.Reset();
        WCSWSServicesTreeVisual.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        if WCSWSServicesTreeVisual.FindLast() then
            NextEntryNo := WCSWSServicesTreeVisual."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        WCSWSServicesTreeVisual.Init();
        WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCConnBearer."WSC Group Code");
        WCSWSServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
        WCSWSServicesTreeVisual.Validate("WSC Indentation", 1);
        WCSWSServicesTreeVisual.Validate("WSC Code", WSCConnBearer."WSC Code");
        WCSWSServicesTreeVisual.Validate("WSC Description", WSCConnBearer."WSC Description");
        WCSWSServicesTreeVisual.Insert();

        WSCWSServicesConnections.Reset();
        WSCWSServicesConnections.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        WSCWSServicesConnections.SetRange("WSC Bearer Connection", false);
        WSCWSServicesConnections.SetRange("WSC Bearer Connection Code", WSCConnBearer."WSC Code");
        if not WSCWSServicesConnections.IsEmpty() then begin
            WSCWSServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WCSWSServicesTreeVisual.Init();
                WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCWSServicesConnections."WSC Group Code");
                WCSWSServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WCSWSServicesTreeVisual.Validate("WSC Indentation", 2);
                WCSWSServicesTreeVisual.Validate("WSC Code", WSCWSServicesConnections."WSC Code");
                WCSWSServicesTreeVisual.Validate("WSC Description", WSCWSServicesConnections."WSC Description");
                WCSWSServicesTreeVisual.Insert();
            until WSCWSServicesConnections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithTokenNoGroup(WSCConnBearer: Record "WSC Web Services Connections"; var WCSWSServicesTreeVisual: Record "WCS Web Services Tree Visual")
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WCSWSServicesTreeVisual.Reset();
        WCSWSServicesTreeVisual.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        if WCSWSServicesTreeVisual.FindLast() then
            NextEntryNo := WCSWSServicesTreeVisual."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        WCSWSServicesTreeVisual.Init();
        WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCConnBearer."WSC Group Code");
        WCSWSServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
        WCSWSServicesTreeVisual.Validate("WSC Indentation", 0);
        WCSWSServicesTreeVisual.Validate("WSC Code", WSCConnBearer."WSC Code");
        WCSWSServicesTreeVisual.Validate("WSC Description", WSCConnBearer."WSC Description");
        WCSWSServicesTreeVisual.Insert();

        WSCWSServicesConnections.Reset();
        WSCWSServicesConnections.SetRange("WSC Group Code", WSCConnBearer."WSC Group Code");
        WSCWSServicesConnections.SetRange("WSC Bearer Connection", false);
        WSCWSServicesConnections.SetRange("WSC Bearer Connection Code", WSCConnBearer."WSC Code");
        if not WSCWSServicesConnections.IsEmpty() then begin
            WSCWSServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WCSWSServicesTreeVisual.Init();
                WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCWSServicesConnections."WSC Group Code");
                WCSWSServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WCSWSServicesTreeVisual.Validate("WSC Indentation", 1);
                WCSWSServicesTreeVisual.Validate("WSC Code", WSCWSServicesConnections."WSC Code");
                WCSWSServicesTreeVisual.Validate("WSC Description", WSCWSServicesConnections."WSC Description");
                WCSWSServicesTreeVisual.Insert();
            until WSCWSServicesConnections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithoutTokenFromGroup(WSCGroupCode: Code[20]; var WCSWSServicesTreeVisual: Record "WCS Web Services Tree Visual")
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WCSWSServicesTreeVisual.Reset();
        WCSWSServicesTreeVisual.SetRange("WSC Group Code", WSCGroupCode);
        if WCSWSServicesTreeVisual.FindLast() then
            NextEntryNo := WCSWSServicesTreeVisual."WSC Entry No."
        else
            NextEntryNo := 0;

        WSCWSServicesConnections.Reset();
        WSCWSServicesConnections.SetRange("WSC Group Code", WSCGroupCode);
        WSCWSServicesConnections.SetRange("WSC Bearer Connection", false);
        WSCWSServicesConnections.SetRange("WSC Bearer Connection Code", '');
        if not WSCWSServicesConnections.IsEmpty() then begin
            WSCWSServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WCSWSServicesTreeVisual.Init();
                WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCWSServicesConnections."WSC Group Code");
                WCSWSServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WCSWSServicesTreeVisual.Validate("WSC Indentation", 1);
                WCSWSServicesTreeVisual.Validate("WSC Code", WSCWSServicesConnections."WSC Code");
                WCSWSServicesTreeVisual.Validate("WSC Description", WSCWSServicesConnections."WSC Description");
                WCSWSServicesTreeVisual.Insert();
            until WSCWSServicesConnections.Next() = 0;
        end;
    end;

    local procedure CollectRecordWithoutTokenNoGroup(WSCGroupCode: Code[20]; var WCSWSServicesTreeVisual: Record "WCS Web Services Tree Visual")
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        NextEntryNo: Integer;
    begin
        WCSWSServicesTreeVisual.Reset();
        WCSWSServicesTreeVisual.SetRange("WSC Group Code", WSCGroupCode);
        if WCSWSServicesTreeVisual.FindLast() then
            NextEntryNo := WCSWSServicesTreeVisual."WSC Entry No."
        else
            NextEntryNo := 0;

        WSCWSServicesConnections.Reset();
        WSCWSServicesConnections.SetRange("WSC Group Code", WSCGroupCode);
        WSCWSServicesConnections.SetRange("WSC Bearer Connection", false);
        WSCWSServicesConnections.SetRange("WSC Bearer Connection Code", '');
        if not WSCWSServicesConnections.IsEmpty() then begin
            WSCWSServicesConnections.FindSet();
            repeat
                NextEntryNo += 1;
                WCSWSServicesTreeVisual.Init();
                WCSWSServicesTreeVisual.Validate("WSC Group Code", WSCWSServicesConnections."WSC Group Code");
                WCSWSServicesTreeVisual.Validate("WSC Entry No.", NextEntryNo);
                WCSWSServicesTreeVisual.Validate("WSC Indentation", 0);
                WCSWSServicesTreeVisual.Validate("WSC Code", WSCWSServicesConnections."WSC Code");
                WCSWSServicesTreeVisual.Validate("WSC Description", WSCWSServicesConnections."WSC Description");
                WCSWSServicesTreeVisual.Insert();
            until WSCWSServicesConnections.Next() = 0;
        end;
    end;

    /// <summary>
    /// ReplaceString.
    /// </summary>
    /// <param name="String">Text[250].</param>
    /// <param name="FindWhat">Text[250].</param>
    /// <param name="ReplaceWith">Text[250].</param>
    /// <returns>Return variable NewString of type Text[250].</returns>
    procedure ReplaceString(String: Text[250]; FindWhat: Text[250]; ReplaceWith: Text[250]) NewString: Text[250]
    var
        FindPos: Integer;
    begin
        FindPos := StrPos(String, FindWhat);
        while FindPos > 0 do begin
            NewString += DelStr(String, FindPos) + ReplaceWith;
            String := CopyStr(String, FindPos + StrLen(FindWhat));
            FindPos := StrPos(String, FindWhat);
        end;
        NewString += String;
    end;
    #endregion GeneralFunctions
    #region TokenFunctions
    local procedure CheckWSBodiesForToken(WSCConnBearer: Record "WSC Web Services Connections")
    var
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
        v: Record "Sales Header" temporary;
        Text000Err: Label 'Key %1 must be filled for token request';
        IsHandled: Boolean;
    begin
        OnBeforeCheckWSCBodiesForToken(IsHandled, WSCConnBearer);
        if IsHandled then
            exit;

        WSCWSServicesBodies.Get(WSCConnBearer."WSC Code", 'grant_type');
        case WSCWSServicesBodies."WSC Value" of
            'client_credentials':
                begin
                    WSCWSServicesBodies.Reset();
                    WSCWSServicesBodies.SetRange("WSC Code", WSCConnBearer."WSC Code");
                    WSCWSServicesBodies.SetRange("WSC Key", 'client_id');
                    WSCWSServicesBodies.SetFilter("WSC Value", '<> %1', '');
                    if WSCWSServicesBodies.IsEmpty() then
                        Error(Text000Err, 'client_id');
                    WSCWSServicesBodies.SetRange("WSC Key", 'client_secret');
                    if WSCWSServicesBodies.IsEmpty() then
                        Error(Text000Err, 'client_secret');
                    WSCWSServicesBodies.SetRange("WSC Key", 'scope');
                    if WSCWSServicesBodies.IsEmpty() then
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
                        WSCConnBearer."WSC Access Token".CreateOutStream(OuStr, TextEncoding::UTF8);
                        OuStr.WriteText(JToken.AsValue().AsText());
                    end;
                'refresh_token':
                    ;
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
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCWebServicesLogCalls: Record "WSC Web Services Log Calls";
        NextEntryNo: Integer;
        OutStr: OutStream;
    begin
        WSCWSServicesConnections.Get(WSCCode);
        ClearGlobalVariables();
        WSCWebServicesCaller.RetrieveGlobalVariables(BodyInStream, ResponseInStream, CallExecution, HttpStatusCode, LastMessageText, NewEndPoint);

        WSCWebServicesLogCalls.Reset();
        WSCWebServicesLogCalls.SetRange("WSC Code", WSCCode);
        if WSCWebServicesLogCalls.FindLast() then
            NextEntryNo := WSCWebServicesLogCalls."WSC Entry No." + 1
        else
            NextEntryNo := 1;

        CurrEntryNo := NextEntryNo;

        WSCWebServicesLogCalls.Init();
        WSCWebServicesLogCalls."WSC Entry No." := CurrEntryNo;
        WSCWebServicesLogCalls."WSC Code" := WSCWSServicesConnections."WSC Code";
        WSCWebServicesLogCalls."WSC Description" := WSCWSServicesConnections."WSC Description";
        WSCWebServicesLogCalls."WSC HTTP Method" := WSCWSServicesConnections."WSC HTTP Method";
        WSCWebServicesLogCalls."WSC EndPoint" := NewEndPoint;
        WSCWebServicesLogCalls."WSC Auth. Type" := WSCWSServicesConnections."WSC Auth. Type";
        WSCWebServicesLogCalls."WSC Bearer Connection" := WSCWSServicesConnections."WSC Bearer Connection";
        WSCWebServicesLogCalls."WSC Bearer Connection Code" := WSCWSServicesConnections."WSC Bearer Connection Code";
        WSCWebServicesLogCalls."WSC Body Type" := WSCWSServicesConnections."WSC Body Type";
        WSCWebServicesLogCalls."WSC Allow Blank Response" := WSCWSServicesConnections."WSC Allow Blank Response";
        WSCWebServicesLogCalls."WSC Group Code" := WSCWSServicesConnections."WSC Group Code";
        Clear(OutStr);
        WSCWebServicesLogCalls."WSC Body Message".CreateOutStream(OutStr);
        WriteBlobFields(OutStr, BodyInStream);
        Clear(OutStr);
        WSCWebServicesLogCalls."WSC Response Message".CreateOutStream(OutStr);
        WriteBlobFields(OutStr, ResponseInStream);
        WSCWebServicesLogCalls."WSC Message Text" := CopyStr(LastMessageText, 1, MaxStrLen(WSCWebServicesLogCalls."WSC Message Text"));
        WSCWebServicesLogCalls."WSC Link to WSC Code" := TokenWSCCode;
        WSCWebServicesLogCalls."WSC Link To Entry No." := TokenEntryNo;
        WSCWebServicesLogCalls."WSC Result Status Code" := HttpStatusCode;
        WSCWebServicesLogCalls."WSC Execution Date-Time" := CurrentDateTime();
        WSCWebServicesLogCalls."WSC Execution UserID" := UserId();
        OnBeforeInsertWSCWebServicesLogCalls(WSCWebServicesLogCalls, WSCWSServicesConnections);
        WSCWebServicesLogCalls.Insert();

        WriteHeaderLog(WSCCode, CurrEntryNo);
        WriteBodyLog(WSCCode, CurrEntryNo);
    end;

    local procedure WriteHeaderLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        WSCWSServicesHeaders: Record "WSC Web Services Headers";
        WSCWSServicesLogHeaders: Record "WSC Web Services Log Headers";
        NextEntryNo: Integer;
    begin
        WSCWSServicesHeaders.Reset();
        WSCWSServicesHeaders.SetRange("WSC Code", WSCCode);
        if WSCWSServicesHeaders.IsEmpty() then
            exit;

        WSCWSServicesLogHeaders.Reset();
        WSCWSServicesLogHeaders.SetRange("WSC Code", WSCCode);
        WSCWSServicesLogHeaders.SetRange("WSC Log Entry No.", LogEntryNo);
        if WSCWSServicesLogHeaders.FindLast() then
            NextEntryNo := WSCWSServicesLogHeaders."WSC Entry No."
        else
            NextEntryNo := 0;

        WSCWSServicesHeaders.FindSet();
        repeat
            NextEntryNo += 1;
            WSCWSServicesLogHeaders.Init();
            WSCWSServicesLogHeaders."WSC Log Entry No." := LogEntryNo;
            WSCWSServicesLogHeaders."WSC Entry No." := NextEntryNo;
            WSCWSServicesLogHeaders."WSC Code" := WSCWSServicesHeaders."WSC Code";
            WSCWSServicesLogHeaders."WSC Key" := WSCWSServicesHeaders."WSC Key";
            WSCWSServicesLogHeaders."WSC Value" := WSCWSServicesHeaders."WSC Value";
            WSCWSServicesLogHeaders."WSC Description" := WSCWSServicesHeaders."WSC Description";
            OnBeforeInsertWSCWSServicesLogHeaders(WSCWSServicesLogHeaders, WSCWSServicesHeaders);
            WSCWSServicesLogHeaders.Insert();
        until WSCWSServicesHeaders.Next() = 0;
    end;

    local procedure WriteBodyLog(WSCCode: Code[20]; LogEntryNo: Integer)
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
        WSCWSServicesLogBodies: Record "WSC Web Services Log Bodies";
        NextEntryNo: Integer;
    begin
        WSCWSServicesConnections.Get(WSCCode);
        WSCWSServicesBodies.Reset();
        WSCWSServicesBodies.SetRange("WSC Code", WSCCode);
        if WSCWSServicesBodies.IsEmpty() then
            exit;

        WSCWSServicesLogBodies.Reset();
        WSCWSServicesLogBodies.SetRange("WSC Code", WSCCode);
        WSCWSServicesLogBodies.SetRange("WSC Log Entry No.", LogEntryNo);
        if WSCWSServicesLogBodies.FindLast() then
            NextEntryNo := WSCWSServicesLogBodies."WSC Entry No."
        else
            NextEntryNo := 0;

        WSCWSServicesBodies.FindSet();
        repeat
            NextEntryNo += 1;
            WSCWSServicesLogBodies.Init();
            WSCWSServicesLogBodies."WSC Log Entry No." := LogEntryNo;
            WSCWSServicesLogBodies."WSC Entry No." := NextEntryNo;
            WSCWSServicesLogBodies."WSC Code" := WSCWSServicesBodies."WSC Code";
            WSCWSServicesLogBodies."WSC Key" := WSCWSServicesBodies."WSC Key";
            WSCWSServicesLogBodies."WSC Value" := WSCWSServicesBodies."WSC Value";
            WSCWSServicesLogBodies."WSC Description" := WSCWSServicesBodies."WSC Description";
            OnBeforeInsertWSCWSServicesLogBodies(WSCWSServicesLogBodies, WSCWSServicesBodies);
            WSCWSServicesLogBodies.Insert();
        until WSCWSServicesBodies.Next() = 0;
    end;
    #endregion LogFunctions
    #region IntegrationEvents
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecuteDirectWSCConnections(IsHanlded: Boolean; WSCWebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExecuteDirectWSCConnections(WSCWebServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckWSCBodiesForToken(IsHanlded: Boolean; WSCConnBearer: Record "WSC Web Services Connections")
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
    local procedure OnBeforeReadJsonTokenResponse(IsHanlded: Boolean; JAccessToken: JsonObject; var WSCConnBearer: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReadJsonTokenResponse(JAccessToken: JsonObject; var WSCConnBearer: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWSCWebServicesLogCalls(var WSCWebServicesLogCalls: Record "WSC Web Services Log Calls"; WSCWSServicesConnections: Record "WSC Web Services Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWSCWSServicesLogHeaders(var WSCWSServicesLogHeaders: Record "WSC Web Services Log Headers"; WSCWSServicesHeaders: Record "WSC Web Services Headers")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWSCWSServicesLogBodies(var WSCWSServicesLogBodies: Record "WSC Web Services Log Bodies"; WSCWSServicesBodies: Record "WSC Web Services Bodies")
    begin
    end;

    #endregion IntegrationEvents
    var
        WSCWebServicesCaller: Codeunit "WSC Web Services Caller";
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