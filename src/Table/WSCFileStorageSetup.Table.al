table 81014 "WSC File Storage Setup"
{
    Caption = 'File Storage Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; "WSC Type"; Enum "WSC File Storage")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                Text000Qst: Label 'Changing field %1, all the configuration will be lost.\Continue?';
            begin
                if xRec."WSC Type" <> xRec."WSC Type"::Application then begin
                    if not Confirm(StrSubstNo(Text000Qst, Rec.FieldCaption("WSC Type")), false) then
                        Error('');
                    Clear(Rec."WSC Configuration");
                end;
            end;
        }
        field(3; "WSC Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; "WSC Configuration"; Blob)
        {
            Caption = 'Configuration';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "WSC Code")
        {
            Clustered = true;
        }
    }

    procedure LoadDetails(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        TempNameValueBuffer.Reset();
        TempNameValueBuffer.DeleteAll();

        case Rec."WSC Type" of
            Rec."WSC Type"::"Azure Blob":
                InsertAzureBlobDetails(TempNameValueBuffer);
        end;
    end;

    local procedure InsertAzureBlobDetails(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        NextID: Integer;
    begin
        NextID += 1;
        TempNameValueBuffer.Init();
        TempNameValueBuffer.ID := NextID;
        TempNameValueBuffer.Name := 'sharedAccessKey';
        if IsFieldSet('sharedAccessKey') then
            TempNameValueBuffer.Value := 'Filled';
        TempNameValueBuffer.Insert();

        NextID += 1;
        TempNameValueBuffer.Init();
        TempNameValueBuffer.ID := NextID;
        TempNameValueBuffer.Name := 'accountName';
        if IsFieldSet('accountName') then
            TempNameValueBuffer.Value := 'Filled';
        TempNameValueBuffer.Insert();

        NextID += 1;
        TempNameValueBuffer.Init();
        TempNameValueBuffer.ID := NextID;
        TempNameValueBuffer.Name := 'containerName';
        if IsFieldSet('containerName') then
            TempNameValueBuffer.Value := 'Filled';
        TempNameValueBuffer.Insert();

        CreateAzureBlobJson();
    end;

    local procedure CreateAzureBlobJson()
    var
        JObject: JsonObject;
        AzureBlobObj: JsonObject;
        OutStr: OutStream;
    begin
        Rec.CalcFields("WSC Configuration");
        if Rec."WSC Configuration".HasValue() then
            exit;

        Rec."WSC Configuration".CreateOutStream(OutStr);

        AzureBlobObj.Add('type', 'AzureBlob');
        AzureBlobObj.Add('sharedAccessKey', '');
        AzureBlobObj.Add('accountName', '');
        AzureBlobObj.Add('containerName', '');

        JObject.Add('configuration', AzureBlobObj);
        JObject.WriteTo(OutStr);
        Rec.Modify();
    end;

    [NonDebuggable]
    procedure IsFieldSet(FieldName: Text): Boolean
    var
        InStr: InStream;
        JObject: JsonObject;
        JObjectConfig: JsonObject;
        JToken: JsonToken;
    begin
        Rec.CalcFields("WSC Configuration");
        if not Rec."WSC Configuration".HasValue() then
            exit(false);

        Rec."WSC Configuration".CreateInStream(InStr);

        JObject.ReadFrom(InStr);
        if not JObject.Get('configuration', JToken) then
            exit(false);

        JObjectConfig := JToken.AsObject();
        if not JObjectConfig.Get(FieldName, JToken) then
            exit(false);
        exit(JToken.AsValue().AsText() <> '');
    end;

    [NonDebuggable]
    procedure SetField(FieldName: Text; FieldValue: Text): Boolean
    var
        JObject: JsonObject;
        JObjectConfig: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        OutStr: OutStream;
    begin
        Rec.CalcFields("WSC Configuration");
        if not Rec."WSC Configuration".HasValue() then
            exit(false);

        Rec."WSC Configuration".CreateInStream(InStr);
        JObject.ReadFrom(InStr);
        Rec."WSC Configuration".CreateOutStream(OutStr);

        JObject.Get('configuration', JToken);
        JObjectConfig := JToken.AsObject();
        JObjectConfig.Replace(FieldName, FieldValue);
        JObject.WriteTo(OutStr);
        Rec.Modify();
    end;

    [NonDebuggable]
    procedure GetField(FieldName: Text) FieldValue: Text
    var
        JObject: JsonObject;
        JObjectConfig: JsonObject;
        JToken: JsonToken;
        InStr: InStream;
        OutStr: OutStream;
    begin
        FieldValue := '';
        Rec.CalcFields("WSC Configuration");
        if not Rec."WSC Configuration".HasValue() then
            exit(FieldValue);

        Rec."WSC Configuration".CreateInStream(InStr);
        JObject.ReadFrom(InStr);
        Rec."WSC Configuration".CreateOutStream(OutStr);

        JObject.Get('configuration', JToken);
        JObjectConfig := JToken.AsObject();
        if JObjectConfig.Get(FieldName, JToken) then
            FieldValue := JToken.AsValue().AsText();
    end;
}