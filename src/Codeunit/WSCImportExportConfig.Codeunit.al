/// <summary>
/// Codeunit WSC Import Export Config. (ID 81003).
/// </summary>
codeunit 81003 "WSC Import Export Config."
{
    trigger OnRun()
    begin

    end;

    var
        TempWebServicesConnections: Record "WSC Web Services Connections" temporary;
        TempWebServicesHeaders: Record "WSC Web Services Headers" temporary;
        TempWebServicesBodies: Record "WSC Web Services Bodies" temporary;
        TableType: Option Default,Header,Body;
        GroupCode: Code[20];


    #region Import
    local procedure ImportWSCFromPostmanJson()
    var
        myInt: Integer;
    begin
        //Importazione configurazione WSC da Json di Postman
    end;

    /// <summary>
    /// ImportWSCFromJson.
    /// </summary>
    procedure ImportWSCFromJson()
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        FileName: Text;
        FileDialogTxt: Label 'WS Configuration (%1)|%1', Comment = '%1=file types, such as *.txt or *.docx';
        FilterTxt: Label '*.json;*.*', Locked = true;
        ImportTxt: Label 'Select a WS Json Configuration.';
        ImportResultLbl: label 'Import Completed';
    begin
        //Importazione configurazione WSC
        FileName := FileManagement.BLOBImportWithFilter(
                    TempBlob, ImportTxt, FileName, StrSubstNo(FileDialogTxt, FilterTxt), FilterTxt);

        if FileName = '' then
            exit;

        ReadWSCJson(TempBlob);

        Message(ImportResultLbl);
    end;

    local procedure ReadWSCJson(var TempBlob: Codeunit "Temp Blob")
    var
        ImportConfiguration: Page "WSC Import Configuration";
        JObject: JsonObject;
    begin
        InitializeTempVar();
        JObject.ReadFrom(TempBlob.CreateInStream());
        AnalyzeJson(JObject);
        if GuiAllowed() then begin
            ImportConfiguration.SetConfiguration(TempWebServicesConnections);
            ImportConfiguration.LookupMode(true);
            if ImportConfiguration.RunModal() = Action::LookupOK then
                ImportConfiguration.GetConfiguration(TempWebServicesConnections)
            else
                Error('');
        end;
        TransferRecordFromTemp();
    end;

    local procedure AnalyzeJson(JObject: JsonObject)
    var
        JArrayObject: JsonObject;
        JArray: JsonArray;
        JToken: JsonToken;
        JsonKeyValue: JsonValue;
        JsonKey: Text;
        i: Integer;
    begin
        foreach JsonKey in JObject.Keys() do begin
            if JObject.Get(JsonKey, JToken) then
                case true of
                    JToken.IsArray():
                        begin
                            JArray.ReadFrom(Format(JToken));
                            for i := 0 to JArray.Count() - 1 do begin
                                JArray.Get(i, JToken);
                                JArrayObject := JToken.AsObject();
                                SetTableType(JsonKey);
                                AnalyzeJson(JArrayObject);
                            end;
                        end;
                    JToken.IsValue():
                        begin
                            JsonKeyValue := JToken.AsValue();
                            ApplyJsonValueToField(JsonKeyValue, JsonKey);
                        end;
                end;
        end;
        SetNewRecordToInsert(TableType);
    end;

    local procedure ApplyJsonValueToField(JsonKeyValue: JsonValue; JsonFieldName: Text[50])
    begin
        case TableType of
            TableType::Default:
                case JsonFieldName of
                    'groupCode':
                        GroupCode := JsonKeyValue.AsText();
                    'code':
                        begin
                            SetNewRecordToInsert(TableType);
                            TempWebServicesConnections."WSC Code" := JsonKeyValue.AsText();
                            TempWebServicesConnections."WSC Previous Code" := JsonKeyValue.AsText();
                            TempWebServicesConnections."WSC Group Code" := GroupCode;
                        end;
                    'description':
                        TempWebServicesConnections."WSC Description" := JsonKeyValue.AsText();
                    'httpMethod':
                        Evaluate(TempWebServicesConnections."WSC HTTP Method", JsonKeyValue.AsText()); //Valutare se nuove versioni hanno la funzione AsEnum
                    'endpoint':
                        TempWebServicesConnections."WSC EndPoint" := JsonKeyValue.AsText();
                    'allowBlankResponse':
                        TempWebServicesConnections."WSC Allow Blank Response" := JsonKeyValue.AsBoolean();
                    'authType':
                        Evaluate(TempWebServicesConnections."WSC Auth. Type", JsonKeyValue.AsText());
                    'bodyType':
                        Evaluate(TempWebServicesConnections."WSC Body Type", JsonKeyValue.AsText());
                    'bodyMethod':
                        Evaluate(TempWebServicesConnections."WSC Body Method", JsonKeyValue.AsText());
                    'username':
                        TempWebServicesConnections."WSC Username" := JsonKeyValue.AsText();
                    'password':
                        TempWebServicesConnections."WSC Password" := JsonKeyValue.AsText();
                    'convertAuthBase64':
                        TempWebServicesConnections."WSC Convert Auth. Base64" := JsonKeyValue.AsBoolean();
                    'bearerToken':
                        TempWebServicesConnections."WSC Bearer Connection" := JsonKeyValue.AsBoolean();
                    'bearerConnCode':
                        TempWebServicesConnections."WSC Bearer Connection Code" := JsonKeyValue.AsText();
                    'zipResponse':
                        TempWebServicesConnections."WSC Zip Response" := JsonKeyValue.AsBoolean();
                end;
            TableType::Header:
                case JsonFieldName of
                    'key':
                        begin
                            SetNewRecordToInsert(TableType);
                            TempWebServicesHeaders."WSC Key" := JsonKeyValue.AsText();
                        end;
                    'value':
                        TempWebServicesHeaders."WSC Value" := JsonKeyValue.AsText();
                    'description':
                        TempWebServicesHeaders."WSC Description" := JsonKeyValue.AsText();
                end;
            TableType::Body:
                case JsonFieldName of
                    'key':
                        begin
                            SetNewRecordToInsert(TableType);
                            TempWebServicesBodies."WSC Key" := JsonKeyValue.AsText();
                        end;
                    'value':
                        TempWebServicesBodies."WSC Value" := JsonKeyValue.AsText();
                    'description':
                        TempWebServicesBodies."WSC Description" := JsonKeyValue.AsText();
                end;
        end;
    end;

    local procedure SetTableType(JsonArrayName: Text[50])
    begin
        case JsonArrayName of
            'codes', 'generalInfo':
                TableType := TableType::Default;
            'header':
                TableType := TableType::Header;
            'body':
                TableType := TableType::Body;
        end;
    end;

    local procedure SetNewRecordToInsert(TableType: Option Default,Header,Body)
    begin
        case TableType of
            TableType::Default:
                begin
                    if TempWebServicesConnections."WSC Code" <> '' then
                        if TempWebServicesConnections.Insert() then;
                    TempWebServicesConnections.Init();
                    TempWebServicesConnections."WSC Code" := '';
                end;
            TableType::Header:
                begin
                    if TempWebServicesHeaders."WSC Key" <> '' then
                        if TempWebServicesHeaders.Insert() then;
                    TempWebServicesHeaders.Init();
                    TempWebServicesHeaders."WSC Code" := TempWebServicesConnections."WSC Code";
                    TempWebServicesHeaders."WSC Key" := '';
                end;
            TableType::Body:
                begin
                    if TempWebServicesBodies."WSC Key" <> '' then
                        if TempWebServicesBodies.Insert() then;
                    TempWebServicesBodies.Init();
                    TempWebServicesBodies."WSC Code" := TempWebServicesConnections."WSC Code";
                    TempWebServicesBodies."WSC Key" := '';
                end;
        end;
    end;

    local procedure TransferRecordFromTemp()
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        WebServicesHeaders: Record "WSC Web Services Headers";
        WebServicesBodies: Record "WSC Web Services Bodies";
        Text000Lbl: Label 'Nothing to Import';
    begin
        TempWebServicesConnections.Reset();
        if TempWebServicesConnections.IsEmpty() then
            Error(Text000Lbl);

        TempWebServicesConnections.FindSet();
        repeat
            if TempWebServicesConnections."WSC Previous Code" <> TempWebServicesConnections."WSC Code" then
                UpdateRelatedTableKey();

            WebServicesConnections.Init();
            WebServicesConnections.TransferFields(TempWebServicesConnections);
            WebServicesConnections."WSC Imported" := true;
            WebServicesConnections.Insert();

            TempWebServicesHeaders.Reset();
            TempWebServicesHeaders.SetRange("WSC Code", TempWebServicesConnections."WSC Code");
            if not TempWebServicesHeaders.IsEmpty() then begin
                TempWebServicesHeaders.FindSet();
                repeat
                    WebServicesHeaders.Init();
                    WebServicesHeaders.TransferFields(TempWebServicesHeaders);
                    WebServicesHeaders.Insert();
                until TempWebServicesHeaders.Next() = 0;
            end;

            TempWebServicesBodies.Reset();
            TempWebServicesBodies.SetRange("WSC Code", TempWebServicesConnections."WSC Code");
            if not TempWebServicesBodies.IsEmpty() then begin
                TempWebServicesBodies.FindSet();
                repeat
                    WebServicesBodies.Init();
                    WebServicesBodies.TransferFields(TempWebServicesBodies);
                    WebServicesBodies.Insert();
                until TempWebServicesBodies.Next() = 0;
            end;
        until TempWebServicesConnections.Next() = 0;

        InitializeTempVar();
    end;

    local procedure InitializeTempVar()
    begin
        TempWebServicesConnections.Reset();
        TempWebServicesConnections.DeleteAll();
        TempWebServicesHeaders.Reset();
        TempWebServicesHeaders.DeleteAll();
        TempWebServicesBodies.Reset();
        TempWebServicesBodies.DeleteAll();
    end;

    local procedure UpdateRelatedTableKey()
    var
        TempLocalWebServicesHeaders: Record "WSC Web Services Headers" temporary;
        TempLocalWebServicesBodies: Record "WSC Web Services Bodies" temporary;
    begin
        TempLocalWebServicesHeaders.Copy(TempWebServicesHeaders, true);
        TempLocalWebServicesBodies.Copy(TempWebServicesBodies, true);

        TempLocalWebServicesHeaders.Reset();
        TempLocalWebServicesHeaders.SetRange("WSC Code", TempWebServicesConnections."WSC Previous Code");
        if not TempLocalWebServicesHeaders.IsEmpty() then begin
            TempLocalWebServicesHeaders.FindSet();
            repeat
                TempWebServicesHeaders.Get(TempLocalWebServicesHeaders."WSC Code", TempLocalWebServicesHeaders."WSC Key");
                TempWebServicesHeaders.Rename(TempWebServicesConnections."WSC Code", TempWebServicesHeaders."WSC Key");
            until TempLocalWebServicesHeaders.Next() = 0;
        end;

        TempLocalWebServicesBodies.Reset();
        TempLocalWebServicesBodies.SetRange("WSC Code", TempWebServicesConnections."WSC Previous Code");
        if not TempLocalWebServicesBodies.IsEmpty() then begin
            TempLocalWebServicesBodies.FindSet();
            repeat
                TempWebServicesBodies.Get(TempLocalWebServicesBodies."WSC Code", TempLocalWebServicesBodies."WSC Key");
                TempWebServicesBodies.Rename(TempWebServicesConnections."WSC Code", TempWebServicesBodies."WSC Key");
            until TempLocalWebServicesBodies.Next() = 0;
        end;
    end;

    #endregion Import

    #region Export
    /// <summary>
    /// ExportWSCJson.
    /// </summary>
    /// <param name="WSCode">Code[20].</param>
    procedure ExportWSCJson(WSCode: Code[20])
    var
        WSCWebServicesConnections: Record "WSC Web Services Connections";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Text000Qst: Label 'This connection is part of a group. Do you want to export the entire group ?';
        Text000Lbl: Label '%1_%2.json';
        ExportGroup: Boolean;
        FileJson: JsonObject;
        LocalFileName,
        Result : Text;
    begin
        WSCWebServicesConnections.Get(WSCode);
        if WSCWebServicesConnections."WSC Group Code" <> '' then
            if Confirm(Text000Qst) then
                ExportGroup := true;

        if ExportGroup then begin
            LocalFileName := StrSubstNo(Text000Lbl, 'GROUP', WSCWebServicesConnections."WSC Group Code");
            FileJson := ExportWSCGroupJson(WSCWebServicesConnections)
        end else begin
            LocalFileName := StrSubstNo(Text000Lbl, 'SINGLE', WSCWebServicesConnections."WSC Code");
            FileJson := ExportWSCSingleJson(WSCWebServicesConnections);
        end;

        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);

        FileJson.WriteTo(OutStr);
        OutStr.WriteText(Result);
        InStr.ReadText(Result);

        DownloadFromStream(InStr, '', '', '', LocalFileName);
    end;

    local procedure ExportWSCSingleJson(WSCWebServicesConnections: Record "WSC Web Services Connections") envelope: JsonObject
    var
        WSCWebServicesConnections2: Record "WSC Web Services Connections";
    begin
        WSCWebServicesConnections2.Reset();
        WSCWebServicesConnections2.SetCurrentKey("WSC Bearer Connection");
        WSCWebServicesConnections2.Ascending(false);
        if WSCWebServicesConnections."WSC Bearer Connection Code" <> '' then
            WSCWebServicesConnections2.SetFilter("WSC Code", '%1|%2', WSCWebServicesConnections."WSC Code", WSCWebServicesConnections."WSC Bearer Connection Code")
        else
            WSCWebServicesConnections2.SetRange("WSC Code", WSCWebServicesConnections."WSC Code");

        if WSCWebServicesConnections2.IsEmpty() then
            Error('');

        Clear(envelope);
        WSCWebServicesConnections2.FindSet();
        envelope.Add('groupCode', WSCWebServicesConnections2."WSC Group Code");
        AddArray(envelope, 'codes', WSCWebServicesConnections2);
    end;

    local procedure ExportWSCGroupJson(WSCWebServicesConnections: Record "WSC Web Services Connections") envelope: JsonObject
    var
        WSCWebServicesConnections2: Record "WSC Web Services Connections";
    begin
        WSCWebServicesConnections2.Reset();
        WSCWebServicesConnections2.SetCurrentKey("WSC Bearer Connection");
        WSCWebServicesConnections2.Ascending(false);
        WSCWebServicesConnections2.SetRange("WSC Group Code", WSCWebServicesConnections."WSC Group Code");
        if WSCWebServicesConnections2.IsEmpty() then
            Error('');

        Clear(envelope);
        WSCWebServicesConnections2.FindSet();
        envelope.Add('groupCode', WSCWebServicesConnections2."WSC Group Code");
        AddArray(envelope, 'codes', WSCWebServicesConnections2);
    end;

    local procedure AddArray(var JObjectFatherName: JsonObject; ArrayName: Text; var WSCWebServicesConnections: Record "WSC Web Services Connections")
    var
        i: Integer;
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        case ArrayName of
            'codes':
                codesContent(JObjectFatherName, ArrayName, WSCWebServicesConnections);
            'generalInfo':
                generalInfoContent(JObjectFatherName, ArrayName, WSCWebServicesConnections);
            'header':
                headerContent(JObjectFatherName, ArrayName, WSCWebServicesConnections);
            'body':
                bodyContent(JObjectFatherName, ArrayName, WSCWebServicesConnections);
        end;
    end;

    local procedure codesContent(var JObjectFatherName: JsonObject; ArrayName: Text; var WSCWebServicesConnections: Record "WSC Web Services Connections")
    var
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        repeat
            Clear(JObjectName);
            JObjectName.Add('code', WSCWebServicesConnections."WSC Code");
            AddArray(JObjectName, 'generalInfo', WSCWebServicesConnections);
            AddArray(JObjectName, 'header', WSCWebServicesConnections);
            AddArray(JObjectName, 'body', WSCWebServicesConnections);
            JArrayName.Add(JObjectName);
        until WSCWebServicesConnections.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure generalInfoContent(var JObjectFatherName: JsonObject; ArrayName: Text; WSCWebServicesConnections: Record "WSC Web Services Connections")
    var
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        Clear(JObjectName);

        //JObjectName.Add('code', WSCWebServicesConnections."WSC Code");
        JObjectName.Add('description', WSCWebServicesConnections."WSC Description");
        JObjectName.Add('httpMethod', Format(WSCWebServicesConnections."WSC HTTP Method"));
        JObjectName.Add('endpoint', WSCWebServicesConnections."WSC EndPoint");
        JObjectName.Add('allowBlankResponse', WSCWebServicesConnections."WSC Allow Blank Response");
        JObjectName.Add('authType', Format(WSCWebServicesConnections."WSC Auth. Type"));
        JObjectName.Add('bodyType', Format(WSCWebServicesConnections."WSC Body Type"));
        JObjectName.Add('bodyMethod', Format(WSCWebServicesConnections."WSC Body Method"));
        JObjectName.Add('username', WSCWebServicesConnections."WSC Username");
        JObjectName.Add('password', WSCWebServicesConnections."WSC Password");
        JObjectName.Add('convertAuthBase64', WSCWebServicesConnections."WSC Convert Auth. Base64");
        JObjectName.Add('bearerToken', WSCWebServicesConnections."WSC Bearer Connection");
        JObjectName.Add('bearerConnCode', WSCWebServicesConnections."WSC Bearer Connection Code");
        JObjectName.Add('zipResponse', WSCWebServicesConnections."WSC Zip Response");

        JArrayName.Add(JObjectName);
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure headerContent(var JObjectFatherName: JsonObject; ArrayName: Text; WSCWebServicesConnections: Record "WSC Web Services Connections")
    var
        WSCWebServicesHeaders: Record "WSC Web Services Headers";
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        WSCWebServicesHeaders.Reset();
        WSCWebServicesHeaders.SetRange("WSC Code", WSCWebServicesConnections."WSC Code");
        if WSCWebServicesHeaders.IsEmpty() then
            exit;

        WSCWebServicesHeaders.FindSet();
        repeat
            Clear(JObjectName);
            JObjectName.Add('key', WSCWebServicesHeaders."WSC Key");
            JObjectName.Add('value', WSCWebServicesHeaders."WSC Value");
            JObjectName.Add('description', WSCWebServicesHeaders."WSC Description");

            JArrayName.Add(JObjectName);
        until WSCWebServicesHeaders.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure bodyContent(var JObjectFatherName: JsonObject; ArrayName: Text; WSCWebServicesConnections: Record "WSC Web Services Connections")
    var
        WSCWebServicesBodies: Record "WSC Web Services Bodies";
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        WSCWebServicesBodies.Reset();
        WSCWebServicesBodies.SetRange("WSC Code", WSCWebServicesConnections."WSC Code");
        if WSCWebServicesBodies.IsEmpty() then
            exit;

        WSCWebServicesBodies.FindSet();
        repeat
            Clear(JObjectName);
            JObjectName.Add('key', WSCWebServicesBodies."WSC Key");
            JObjectName.Add('value', WSCWebServicesBodies."WSC Value");
            JObjectName.Add('description', WSCWebServicesBodies."WSC Description");

            JArrayName.Add(JObjectName);
        until WSCWebServicesBodies.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;
    #endregion Export
}