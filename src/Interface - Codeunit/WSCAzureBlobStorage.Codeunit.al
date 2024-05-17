codeunit 81011 "WSC Azure Blob Storage" implements "WSC Log Files Handler"
{

    //THIS CODE IS NOT TESTED AND PROBABLY IS WRONG
    procedure GetFile(LogCalls: Record "WSC Log Calls"; FieldNo: Integer) TempBlob: Codeunit "Temp Blob"
    var
        FileStorageSetup: Record "WSC File Storage Setup";
        ABSBlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
        InStr: InStream;
    begin
        FileStorageSetup.Get(LogCalls."WSC File Storage Code");
        FileStorageSetup.TestField("WSC Type", FileStorageSetup."WSC Type"::"Azure Blob");

        Authorization := StorageServiceAuthorization.CreateSharedKey(FileStorageSetup.GetField('sharedAccessKey'));
        ABSBlobClient.Initialize(FileStorageSetup.GetField('accountName'), FileStorageSetup.GetField('containerName'), Authorization);
        TempBlob.CreateInStream(InStr);
        ABSBlobClient.GetBlobAsStream(CreateFileName(LogCalls, FieldNo), InStr);
    end;

    procedure SaveFile(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer; FileToSave: InStream)
    var
        FileStorageSetup: Record "WSC File Storage Setup";
        ABSBlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
    begin
        FileStorageSetup.Get(LogCalls."WSC File Storage Code");
        FileStorageSetup.TestField("WSC Type", FileStorageSetup."WSC Type"::"Azure Blob");

        Authorization := StorageServiceAuthorization.CreateSharedKey(FileStorageSetup.GetField('sharedAccessKey'));
        ABSBlobClient.Initialize(FileStorageSetup.GetField('accountName'), FileStorageSetup.GetField('containerName'), Authorization);
        ABSBlobClient.AppendBlockStream(CreateFileName(LogCalls, FieldNo), FileToSave)
    end;

    procedure FileExist(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer): Boolean
    var
        FileStorageSetup: Record "WSC File Storage Setup";
        ABSBlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
    begin
        FileStorageSetup.Get(LogCalls."WSC File Storage Code");
        FileStorageSetup.TestField("WSC Type", FileStorageSetup."WSC Type"::"Azure Blob");

        Authorization := StorageServiceAuthorization.CreateSharedKey(FileStorageSetup.GetField('sharedAccessKey'));
        ABSBlobClient.Initialize(FileStorageSetup.GetField('accountName'), FileStorageSetup.GetField('containerName'), Authorization);
        exit(ABSBlobClient.BlobExists(CreateFileName(LogCalls, FieldNo)))
    end;

    local procedure CreateFileName(LogCalls: Record "WSC Log Calls"; FieldNo: Integer) FileName: Text
    begin
        FileName := LogCalls."WSC Code" + '_Field' + Format(FieldNo) + '_EntryNo' + Format(LogCalls."WSC Entry No.");
        if LogCalls."WSC Zip Response" then
            FileName += '.zip'
        else
            FileName += LogCalls.RetrieveResponseFileExtension(false);
    end;
}