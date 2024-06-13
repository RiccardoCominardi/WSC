/// <summary>
/// Codeunit WSC Import Export Config. (ID 81003).
/// </summary>
codeunit 81003 "WSC Import Export Config."
{
    trigger OnRun()
    begin

    end;

    var
        TempConnections: Record "WSC Connections" temporary;
        TempParameters: Record "WSC Parameters" temporary;
        TempHeaders: Record "WSC Headers" temporary;
        TempBodies: Record "WSC Bodies" temporary;
        TableType: Option Default,Parameter,Header,Body;
        GroupCode: Code[20];
        CurrWSCode: Code[20];


    #region Import
    local procedure ImportWSCFromPostmanJson()
    var
        myInt: Integer;
    begin
        //Importazione configurazione WSC da Json di Postman
    end;

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

        if GuiAllowed() then
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
        Commit();
        if GuiAllowed() then begin
            ImportConfiguration.SetConfiguration(TempConnections);
            ImportConfiguration.Editable(true);
            ImportConfiguration.LookupMode(true);
            if ImportConfiguration.RunModal() = Action::LookupOK then
                ImportConfiguration.GetConfiguration(TempConnections)
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
        foreach JsonKey in JObject.Keys() do
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
        SetNewRecordToInsert();
    end;

    local procedure ApplyJsonValueToField(JsonKeyValue: JsonValue; JsonFieldName: Text[50])
    var
        SecurityManagements: Codeunit "WSC Security Managements";
    begin
        case TableType of
            TableType::Default:
                case JsonFieldName of
                    'groupCode':
                        GroupCode := JsonKeyValue.AsText();
                    'code':
                        begin
                            SetNewRecordToInsert();
                            TempConnections."WSC Code" := JsonKeyValue.AsText();
                            TempConnections."WSC Previous Code" := JsonKeyValue.AsText();
                            TempConnections."WSC Group Code" := GroupCode;
                        end;
                    'description':
                        TempConnections."WSC Description" := JsonKeyValue.AsText();
                    'httpMethod':
                        Evaluate(TempConnections."WSC HTTP Method", JsonKeyValue.AsText()); //Valutare se nuove versioni hanno la funzione AsEnum
                    'endpoint':
                        TempConnections."WSC EndPoint" := JsonKeyValue.AsText();
                    'allowBlankResponse':
                        TempConnections."WSC Allow Blank Response" := JsonKeyValue.AsBoolean();
                    'authType':
                        Evaluate(TempConnections."WSC Auth. Type", JsonKeyValue.AsText());
                    'bodyType':
                        Evaluate(TempConnections."WSC Body Type", JsonKeyValue.AsText());
                    'bodyMethod':
                        Evaluate(TempConnections."WSC Body Method", JsonKeyValue.AsText());
                    'tokenDataScope':
                        Evaluate(TempConnections."WSC Token DataScope", JsonKeyValue.AsText());
                    'username':
                        TempConnections."WSC Username" := JsonKeyValue.AsText();
                    'password':
                        SecurityManagements.SetToken(TempConnections."WSC Password", JsonKeyValue.AsText(), TempConnections.GetTokenDataScope());
                    'bearerToken':
                        TempConnections."WSC Bearer Connection" := JsonKeyValue.AsBoolean();
                    'bearerConnCode':
                        TempConnections."WSC Bearer Connection Code" := JsonKeyValue.AsText();
                    'zipResponse':
                        TempConnections."WSC Zip Response" := JsonKeyValue.AsBoolean();
                    'type':
                        Evaluate(TempConnections."WSC Type", JsonKeyValue.AsText());
                    'indentation':
                        TempConnections."WSC Indentation" := JsonKeyValue.AsInteger();
                end;
            TableType::Parameter:
                case JsonFieldName of
                    'key':
                        begin
                            SetNewRecordToInsert();
                            TempParameters."WSC Key" := JsonKeyValue.AsText();
                        end;
                    'value':
                        TempParameters."WSC Value" := JsonKeyValue.AsText();
                    'description':
                        TempParameters."WSC Description" := JsonKeyValue.AsText();
                    'isEnabled':
                        TempParameters."WSC Enabled" := JsonKeyValue.AsBoolean();
                end;
            TableType::Header:
                case JsonFieldName of
                    'key':
                        begin
                            SetNewRecordToInsert();
                            TempHeaders."WSC Key" := JsonKeyValue.AsText();
                        end;
                    'isSecret':
                        TempHeaders."WSC Is Secret" := JsonKeyValue.AsBoolean();
                    'value':
                        TempHeaders.SetValue(JsonKeyValue.AsText());
                    'description':
                        TempHeaders."WSC Description" := JsonKeyValue.AsText();
                    'isEnabled':
                        TempHeaders."WSC Enabled" := JsonKeyValue.AsBoolean();
                end;
            TableType::Body:
                case JsonFieldName of
                    'key':
                        begin
                            SetNewRecordToInsert();
                            TempBodies."WSC Key" := JsonKeyValue.AsText();
                        end;
                    'isSecret':
                        TempBodies."WSC Is Secret" := JsonKeyValue.AsBoolean();
                    'value':
                        TempBodies.SetValue(JsonKeyValue.AsText());
                    'description':
                        TempBodies."WSC Description" := JsonKeyValue.AsText();
                    'isEnabled':
                        TempBodies."WSC Enabled" := JsonKeyValue.AsBoolean();
                end;
        end;
    end;

    local procedure SetTableType(JsonArrayName: Text[50])
    begin
        case JsonArrayName of
            'codes', 'generalInfo':
                TableType := TableType::Default;
            'parameter':
                TableType := TableType::Parameter;
            'header':
                TableType := TableType::Header;
            'body':
                TableType := TableType::Body;
        end;
    end;

    local procedure SetNewRecordToInsert()
    begin
        case TableType of
            TableType::Default:
                begin
                    if TempConnections."WSC Code" <> '' then begin
                        CurrWSCode := TempConnections."WSC Code";
                        if TempConnections.Insert() then;
                    end;
                    TempConnections.Init();
                    TempConnections."WSC Code" := '';
                end;
            TableType::Parameter:
                begin
                    if TempParameters."WSC Key" <> '' then
                        if TempParameters.Insert() then;
                    TempParameters.Init();
                    TempParameters."WSC Code" := CurrWSCode;
                    TempParameters."WSC Key" := '';
                end;
            TableType::Header:
                begin
                    if TempHeaders."WSC Key" <> '' then
                        if TempHeaders.Insert() then;
                    TempHeaders.Init();
                    TempHeaders."WSC Code" := CurrWSCode;
                    TempHeaders."WSC Key" := '';
                end;
            TableType::Body:
                begin
                    if TempBodies."WSC Key" <> '' then
                        if TempBodies.Insert() then;
                    TempBodies.Init();
                    TempBodies."WSC Code" := CurrWSCode;
                    TempBodies."WSC Key" := '';
                end;
        end;
    end;

    local procedure TransferRecordFromTemp()
    var
        Connections: Record "WSC Connections";
        Parameters: Record "WSC Parameters";
        Headers: Record "WSC Headers";
        Bodies: Record "WSC Bodies";
        Text000Lbl: Label 'Nothing to Import';
        NewGroupCode: Code[20];
    begin
        TempConnections.Reset();
        TempConnections.SetCurrentKey("WSC Type");
        TempConnections.ReadIsolation := IsolationLevel::ReadUncommitted;
        if TempConnections.IsEmpty() then
            Error(Text000Lbl);

        TempConnections.FindSet();
        NewGroupCode := TempConnections."WSC Code";
        repeat
            if TempConnections."WSC Previous Code" <> TempConnections."WSC Code" then begin
                if TempConnections."WSC Type" = TempConnections."WSC Type"::Group then
                    NewGroupCode := TempConnections."WSC Code";
                UpdateRelatedTableKey();
            end;

            Connections.Init();
            Connections.TransferFields(TempConnections);
            Connections."WSC Group Code" := NewGroupCode;
            Connections."WSC Imported" := true;
            Connections.Insert();

            TempParameters.Reset();
            TempParameters.SetRange("WSC Code", TempConnections."WSC Code");
            TempParameters.ReadIsolation := IsolationLevel::ReadUncommitted;
            if not TempParameters.IsEmpty() then begin
                TempParameters.FindSet();
                repeat
                    Parameters.Init();
                    Parameters.TransferFields(TempParameters);
                    Parameters.Insert();
                until TempParameters.Next() = 0;
            end;

            TempHeaders.Reset();
            TempHeaders.SetRange("WSC Code", TempConnections."WSC Code");
            TempHeaders.ReadIsolation := IsolationLevel::ReadUncommitted;
            if not TempHeaders.IsEmpty() then begin
                TempHeaders.FindSet();
                repeat
                    Headers.Init();
                    Headers.TransferFields(TempHeaders);
                    Headers.Insert();
                until TempHeaders.Next() = 0;
            end;

            TempBodies.Reset();
            TempBodies.SetRange("WSC Code", TempConnections."WSC Code");
            TempBodies.ReadIsolation := IsolationLevel::ReadUncommitted;
            if not TempBodies.IsEmpty() then begin
                TempBodies.FindSet();
                repeat
                    Bodies.Init();
                    Bodies.TransferFields(TempBodies);
                    Bodies.Insert();
                until TempBodies.Next() = 0;
            end;
        until TempConnections.Next() = 0;

        InitializeTempVar();
    end;

    local procedure InitializeTempVar()
    begin
        TempConnections.Reset();
        TempConnections.DeleteAll();
        TempHeaders.Reset();
        TempHeaders.DeleteAll();
        TempBodies.Reset();
        TempBodies.DeleteAll();
    end;

    local procedure UpdateRelatedTableKey()
    var
        ParameterDatas,
        HeaderDatas,
        BodyDatas : List of [Text];
        Datas: Text;
    begin
        //Store Datas Into List
        TempParameters.Reset();
        TempParameters.SetRange("WSC Code", TempConnections."WSC Previous Code");
        TempParameters.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not TempParameters.IsEmpty() then begin
            TempParameters.FindSet();
            repeat
                ParameterDatas.Add(TempParameters."WSC Key");
            until TempParameters.Next() = 0;
        end;

        TempHeaders.Reset();
        TempHeaders.SetRange("WSC Code", TempConnections."WSC Previous Code");
        TempHeaders.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not TempHeaders.IsEmpty() then begin
            TempHeaders.FindSet();
            repeat
                HeaderDatas.Add(TempHeaders."WSC Key");
            until TempHeaders.Next() = 0;
        end;

        TempBodies.Reset();
        TempBodies.SetRange("WSC Code", TempConnections."WSC Previous Code");
        TempBodies.ReadIsolation := IsolationLevel::ReadUncommitted;
        if not TempBodies.IsEmpty() then begin
            TempBodies.FindSet();
            repeat
                BodyDatas.Add(TempBodies."WSC Key");
            until TempBodies.Next() = 0;
        end;

        //Update Parameter
        foreach Datas in ParameterDatas do begin
            if TempParameters.Get(TempConnections."WSC Previous Code", Datas) then
                TempParameters.Rename(TempConnections."WSC Code", Datas);
        end;

        //Update Headers
        foreach Datas in HeaderDatas do begin
            if TempHeaders.Get(TempConnections."WSC Previous Code", Datas) then
                TempHeaders.Rename(TempConnections."WSC Code", Datas);
        end;

        //Update Bodies
        foreach Datas in BodyDatas do begin
            if TempBodies.Get(TempConnections."WSC Previous Code", Datas) then
                TempBodies.Rename(TempConnections."WSC Code", Datas);
        end;
    end;

    #endregion Import

    #region Export

    procedure ExportWSCJson(WSCode: Code[20])
    var
        Connections: Record "WSC Connections";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        Text000Lbl: Label '%1_%2.json';
        IsHandled,
        ExportGroup : Boolean;
        FileJson: JsonObject;
        LocalFileName,
        Result : Text;
    begin
        OnBeforeExportWSCJson(IsHandled, WSCode);
        if IsHandled then
            exit;

        Connections.Get(WSCode);
        if Connections."WSC Type" = Connections."WSC Type"::Group then begin
            LocalFileName := StrSubstNo(Text000Lbl, 'GROUP', Connections."WSC Group Code");
            FileJson := ExportWSCGroupJson(Connections)
        end else begin
            LocalFileName := StrSubstNo(Text000Lbl, 'SINGLE', Connections."WSC Code");
            FileJson := ExportWSCSingleJson(Connections);
        end;

        TempBlob.CreateInStream(InStr);
        TempBlob.CreateOutStream(OutStr);

        FileJson.WriteTo(OutStr);
        OutStr.WriteText(Result);
        InStr.ReadText(Result);

        DownloadFromStream(InStr, '', '', '', LocalFileName);
    end;

    local procedure ExportWSCSingleJson(Connections: Record "WSC Connections") envelope: JsonObject
    var
        Connections2: Record "WSC Connections";
    begin
        Connections2.Reset();
        Connections2.SetCurrentKey("WSC Bearer Connection");
        Connections2.Ascending(false);
        if Connections."WSC Bearer Connection Code" <> '' then
            Connections2.SetFilter("WSC Code", '%1|%2', Connections."WSC Code", Connections."WSC Bearer Connection Code")
        else
            Connections2.SetRange("WSC Code", Connections."WSC Code");

        Connections2.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Connections2.IsEmpty() then
            Error('');

        Clear(envelope);
        Connections2.FindSet();
        envelope.Add('groupCode', Connections2."WSC Group Code");
        AddArray(envelope, 'codes', Connections2);
    end;

    local procedure ExportWSCGroupJson(Connections: Record "WSC Connections") envelope: JsonObject
    var
        Connections2: Record "WSC Connections";
    begin
        Connections2.Reset();
        Connections2.SetCurrentKey("WSC Type");
        Connections2.SetRange("WSC Group Code", Connections."WSC Group Code");
        Connections2.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Connections2.IsEmpty() then
            Error('');

        Clear(envelope);
        Connections2.FindSet();
        envelope.Add('groupCode', Connections2."WSC Group Code");
        AddArray(envelope, 'codes', Connections2);
    end;

    local procedure AddArray(var JObjectFatherName: JsonObject; ArrayName: Text; var Connections: Record "WSC Connections")
    var
        i: Integer;
        JObjectName: JsonObject;
        JArrayName: JsonArray;
        IsHandled: Boolean;
    begin
        OnBeforeAddArray(IsHandled, JObjectFatherName, ArrayName, Connections);
        if IsHandled then
            exit;

        case ArrayName of
            'codes':
                codesContent(JObjectFatherName, ArrayName, Connections);
            'generalInfo':
                generalInfoContent(JObjectFatherName, ArrayName, Connections);
            'parameter':
                parameterContent(JObjectFatherName, ArrayName, Connections);
            'header':
                headerContent(JObjectFatherName, ArrayName, Connections);
            'body':
                bodyContent(JObjectFatherName, ArrayName, Connections);
        end;
    end;

    local procedure codesContent(var JObjectFatherName: JsonObject; ArrayName: Text; var Connections: Record "WSC Connections")
    var
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        repeat
            Clear(JObjectName);
            JObjectName.Add('code', Connections."WSC Code");
            AddArray(JObjectName, 'generalInfo', Connections);
            AddArray(JObjectName, 'parameter', Connections);
            AddArray(JObjectName, 'header', Connections);
            AddArray(JObjectName, 'body', Connections);
            OnBeforeAddArrayCodesContent(JObjectName, Connections);
            JArrayName.Add(JObjectName);
        until Connections.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure generalInfoContent(var JObjectFatherName: JsonObject; ArrayName: Text; Connections: Record "WSC Connections")
    var
        SecurityManagements: Codeunit "WSC Security Managements";
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        Clear(JObjectName);

        JObjectName.Add('description', Connections."WSC Description");
        JObjectName.Add('httpMethod', Format(Connections."WSC HTTP Method"));
        JObjectName.Add('endpoint', Connections."WSC EndPoint");
        JObjectName.Add('allowBlankResponse', Connections."WSC Allow Blank Response");
        JObjectName.Add('authType', Format(Connections."WSC Auth. Type"));
        JObjectName.Add('bodyType', Format(Connections."WSC Body Type"));
        JObjectName.Add('bodyMethod', Format(Connections."WSC Body Method"));
        JObjectName.Add('tokenDataScope', format(Connections."WSC Token DataScope"));
        JObjectName.Add('username', Connections."WSC Username");
        JObjectName.Add('password', SecurityManagements.GetToken(Connections."WSC Password", Connections.GetTokenDataScope()));
        JObjectName.Add('bearerToken', Connections."WSC Bearer Connection");
        JObjectName.Add('bearerConnCode', Connections."WSC Bearer Connection Code");
        JObjectName.Add('zipResponse', Connections."WSC Zip Response");
        JObjectName.Add('type', Format(Connections."WSC Type"));
        JObjectName.Add('indentation', Format(Connections."WSC Indentation"));
        OnBeforeAddArrayGeneralInfoContent(JObjectName, Connections);

        JArrayName.Add(JObjectName);
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure parameterContent(var JObjectFatherName: JsonObject; ArrayName: Text; Connections: Record "WSC Connections")
    var
        Parameters: Record "WSC Parameters";
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        Parameters.Reset();
        Parameters.SetRange("WSC Code", Connections."WSC Code");
        Parameters.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Parameters.IsEmpty() then
            exit;

        Parameters.FindSet();
        repeat
            Clear(JObjectName);
            JObjectName.Add('key', Parameters."WSC Key");
            JObjectName.Add('value', Parameters."WSC Value");
            JObjectName.Add('description', Parameters."WSC Description");
            JObjectName.Add('isEnabled', Parameters."WSC Enabled");
            OnBeforeAddArrayParameterContent(JObjectName, Parameters);

            JArrayName.Add(JObjectName);
        until Parameters.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure headerContent(var JObjectFatherName: JsonObject; ArrayName: Text; Connections: Record "WSC Connections")
    var
        Headers: Record "WSC Headers";
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        Headers.Reset();
        Headers.SetRange("WSC Code", Connections."WSC Code");
        Headers.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Headers.IsEmpty() then
            exit;

        Headers.FindSet();
        repeat
            Clear(JObjectName);
            JObjectName.Add('key', Headers."WSC Key");
            JObjectName.Add('isSecret', Headers."WSC Is Secret");
            JObjectName.Add('value', Headers.GetValue());
            JObjectName.Add('description', Headers."WSC Description");
            JObjectName.Add('isEnabled', Headers."WSC Enabled");
            OnBeforeAddArrayHeaderContent(JObjectName, Headers);

            JArrayName.Add(JObjectName);
        until Headers.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;

    local procedure bodyContent(var JObjectFatherName: JsonObject; ArrayName: Text; Connections: Record "WSC Connections")
    var
        Bodies: Record "WSC Bodies";
        JObjectName: JsonObject;
        JArrayName: JsonArray;
    begin
        Bodies.Reset();
        Bodies.SetRange("WSC Code", Connections."WSC Code");
        Bodies.ReadIsolation := IsolationLevel::ReadUncommitted;
        if Bodies.IsEmpty() then
            exit;

        Bodies.FindSet();
        repeat
            Clear(JObjectName);
            JObjectName.Add('key', Bodies."WSC Key");
            JObjectName.Add('isSecret', Bodies."WSC Is Secret");
            JObjectName.Add('value', Bodies.GetValue());
            JObjectName.Add('description', Bodies."WSC Description");
            JObjectName.Add('isEnabled', Bodies."WSC Enabled");
            OnBeforeAddArrayBodyContent(JObjectName, Bodies);

            JArrayName.Add(JObjectName);
        until Bodies.Next() = 0;
        JObjectFatherName.Add(ArrayName, JArrayName);
    end;
    #endregion Export

    #region IntegrationEvents
    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportWSCJson(var IsHandled: Boolean; WSCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddArray(var IsHandled: Boolean; var JObjectFatherName: JsonObject; ArrayName: Text; var Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddArrayCodesContent(var JObjectName: JsonObject; var Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddArrayGeneralInfoContent(var JObjectName: JsonObject; var Connections: Record "WSC Connections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddArrayParameterContent(var JObjectName: JsonObject; var Parameters: Record "WSC Parameters")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddArrayHeaderContent(var JObjectName: JsonObject; var Headers: Record "WSC Headers")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAddArrayBodyContent(var JObjectName: JsonObject; var Bodies: Record "WSC Bodies")
    begin
    end;

    #endregion IntegrationEvents
}