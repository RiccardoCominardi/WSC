/// <summary>
/// Codeunit WSC Web Services Management (ID 81001).
/// </summary>
codeunit 81001 "WSC Web Services Management"
{
    trigger OnRun()
    begin
    end;

    /// <summary>
    /// ExecuteDirectWSCConnections.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    procedure ExecuteDirectWSCConnections(WSCCode: Code[20])
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCConnBearer: Record "WSC Web Services Connections";
        TokenEntryNo: Integer;
    begin
        WSCWSServicesConnections.Get(WSCCode);
        CheckWSCCodeSetup(WSCWSServicesConnections);

        case WSCWSServicesConnections."WSC Auth. Type" of
            WSCWSServicesConnections."WSC Auth. Type"::"bearer token":
                begin
                    WSCConnBearer.Get(WSCWSServicesConnections."WSC Bearer Connection Code");
                    //è da usare il token? Refresh o uso lo stesso?
                    Clear(WSCWebServicesCaller);
                    ClearLastError();
                    if WSCWebServicesCaller.Run(WSCConnBearer) then; //First Web Service call to get the Token
                    TokenEntryNo := WriteConnectionLog(WSCCode, 0);
                    //Log da inserire in qualsiaso modo vada a finire + Bearer da salvarsi
                end;
        end;

        Clear(WSCWebServicesCaller);
        ClearLastError();
        if WSCWebServicesCaller.Run(WSCWSServicesConnections) then; //Call to Web service
        WriteConnectionLog(WSCCode, TokenEntryNo);
    end;

    local procedure CheckWSCCodeSetup(WSCWSServicesConnections: Record "WSC Web Services Connections")
    var
        WSCConnBearer: Record "WSC Web Services Connections";
    begin
        WSCWSServicesConnections.TestField("WSC EndPoint");
        case WSCWSServicesConnections."WSC Auth. Type" of
            "WSC Authorization Types"::basic:
                begin
                    WSCWSServicesConnections.TestField("WSC Username");
                    WSCWSServicesConnections.TestField("WSC Password");
                end;
            WSCWSServicesConnections."WSC Auth. Type"::"bearer token":
                begin
                    WSCWSServicesConnections.TestField("WSC Bearer Connection Code");
                    WSCConnBearer.Get(WSCWSServicesConnections."WSC Bearer Connection Code");
                    WSCConnBearer.TestField("WSC Bearer Connection");
                    CheckWSCHeaderForToken(WSCConnBearer);
                end;
        end;
    end;

    local procedure CheckWSCHeaderForToken(WSCConnBearer: Record "WSC Web Services Connections")
    var
        WSCWebServicesHeaders: Record "WSC Web Services Headers";
        Text000Err: Label 'Key %1 must be filled for token request';
    begin
        WSCWebServicesHeaders.Get(WSCConnBearer."WSC Code", 'grant_type');
        case WSCWebServicesHeaders."WSC Value" of
            'client_credentials':
                begin
                    WSCWebServicesHeaders.Reset();
                    WSCWebServicesHeaders.SetRange("WSC Code", WSCConnBearer."WSC Code");
                    WSCWebServicesHeaders.SetRange("WSC Key", 'client_id');
                    WSCWebServicesHeaders.SetFilter("WSC Value", '<> %1', '');
                    if WSCWebServicesHeaders.IsEmpty() then
                        Error(Text000Err, 'client_id');
                    WSCWebServicesHeaders.SetRange("WSC Key", 'client_secret');
                    if WSCWebServicesHeaders.IsEmpty() then
                        Error(Text000Err, 'client_secret');
                end;
            'authorization_code':
                ;
            'password':
                ;
        end;
    end;

    local procedure WriteConnectionLog(WSCCode: Code[20]; TokenEntryNo: Integer) CurrEntryNo: Integer;
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCWebServicesLogCalls: Record "WSC Web Services Log Calls";
        NextEntryNo: Integer;
        BodyInStream: InStream;
        ResponseInStream: InStream;
        CallExecution: Boolean;
        HttpStatusCode: Integer;
        LastMessageText: Text;
        OutStr: OutStream;
    begin
        WSCWSServicesConnections.Get(WSCCode);
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

    local procedure WriteBlobFields(var OutStr: OutStream; var InStr: InStream)
    var
        CurrText: Text;
    begin
        while not InStr.EOS() do begin
            InStr.ReadText(CurrText);
            OutStr.Write(CurrText);
        end;
    end;

    var
        WSCWebServicesCaller: Codeunit "WSC Web Services Caller";
}