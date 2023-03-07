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
    procedure ExecuteDirectWSCConnections(WSCCode: Code[20])
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCConnBearer: Record "WSC Web Services Connections";
        TokenEntryNo: Integer;
        Text000Lbl: Label 'Execution Terminated. Check the log to see the result';
    begin
        WSCWSServicesConnections.Get(WSCCode);
        CheckWSCCodeSetup(WSCWSServicesConnections);

        case WSCWSServicesConnections."WSC Auth. Type" of
            WSCWSServicesConnections."WSC Auth. Type"::none,
            WSCWSServicesConnections."WSC Auth. Type"::basic:
                begin
                    Clear(WSCWebServicesCaller);
                    ClearLastError();
                    if WSCWSServicesConnections."WSC Bearer Connection" then
                        ExecuteTokenCall(WSCWSServicesConnections."WSC Code", WSCConnBearer, TokenEntryNo)
                    else begin
                        if WSCWebServicesCaller.Run(WSCWSServicesConnections) then;
                        WriteConnectionLog(WSCCode, '', 0);
                    end;
                end;
            WSCWSServicesConnections."WSC Auth. Type"::"bearer token":
                if ExecuteTokenCall(WSCWSServicesConnections."WSC Bearer Connection Code", WSCConnBearer, TokenEntryNo) then begin
                    Commit();
                    Clear(WSCWebServicesCaller);
                    ClearLastError();
                    if WSCWebServicesCaller.Run(WSCWSServicesConnections) then;
                    WriteConnectionLog(WSCCode, WSCConnBearer."WSC Code", TokenEntryNo);
                end;
        end;

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
                    CheckWSCHeaderForToken(WSCWSServicesConnections);
                end;
        end;
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
    end;

    #endregion GeneralFunctions
    #region TokenFunctions
    local procedure CheckWSCHeaderForToken(WSCConnBearer: Record "WSC Web Services Connections")
    var
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
        Text000Err: Label 'Key %1 must be filled for token request';
    begin
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
    end;

    local procedure UpdateWSCTokenInfo(var WSCConnBearer: Record "WSC Web Services Connections")
    var
        JToken: JsonToken;
        JAccessToken: JsonObject;
        Property: Text;
        OuStr: OutStream;
        Text000Err: Label 'Invalid Access Token Property %1, Value:  %2';
    begin
        JAccessToken.ReadFrom(ResponseText);
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
        WSCWebServicesCaller.RetrieveGlobalVariables(BodyInStream, ResponseInStream, CallExecution, HttpStatusCode, LastMessageText);

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
        WSCWebServicesLogCalls."WSC EndPoint" := WSCWSServicesConnections."WSC EndPoint";
        WSCWebServicesLogCalls."WSC Auth. Type" := WSCWSServicesConnections."WSC Auth. Type";
        WSCWebServicesLogCalls."WSC Bearer Connection" := WSCWSServicesConnections."WSC Bearer Connection";
        WSCWebServicesLogCalls."WSC Bearer Connection Code" := WSCWSServicesConnections."WSC Bearer Connection Code";
        WSCWebServicesLogCalls."WSC Body Type" := WSCWSServicesConnections."WSC Body Type";
        WSCWebServicesLogCalls."WSC Allow Blank Response" := WSCWSServicesConnections."WSC Allow Blank Response";
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
            WSCWSServicesLogBodies.Insert();
        until WSCWSServicesBodies.Next() = 0;
    end;
    #endregion LogFunctions
    var
        WSCWebServicesCaller: Codeunit "WSC Web Services Caller";
        BodyInStream: InStream;
        ResponseInStream: InStream;
        ResponseText: Text;
        CallExecution: Boolean;
        HideMessage: Boolean;
        HttpStatusCode: Integer;
        LastMessageText: Text;
}