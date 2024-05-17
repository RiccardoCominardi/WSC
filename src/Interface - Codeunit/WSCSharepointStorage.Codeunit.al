codeunit 81010 "WSC Sharepoint Storage" implements "WSC Log Files Handler"
{

    //THIS CODE IS NOT TESTED AND PROBABLY IS WRONG

    procedure GetFile(LogCalls: Record "WSC Log Calls"; FieldNo: Integer) TempBlob: Codeunit "Temp Blob"
    var
        FileStorageSetup: Record "WSC File Storage Setup";
        Authorization: Interface "SharePoint Authorization";
        SharePointAuth: Codeunit "SharePoint Auth.";
        SharePointClient: Codeunit "SharePoint Client";
        InStr: InStream;
    begin
        FileStorageSetup.Get(LogCalls."WSC File Storage Code");
        FileStorageSetup.TestField("WSC Type", FileStorageSetup."WSC Type"::Sharepoint);

        Authorization := SharePointAuth.CreateAuthorizationCode(FileStorageSetup.GetField('entraTenantId'), FileStorageSetup.GetField('clientId'), FileStorageSetup.GetField('clientSecret'), FileStorageSetup.GetField('scope'));
        SharePointClient.Initialize(FileStorageSetup.GetField('baseUrl'), Authorization);
        TempBlob.CreateInStream(InStr);
        SharePointClient.DownloadFileContentByServerRelativeUrl(FileStorageSetup.GetField('baseUrl') + CreateFileName(LogCalls, FieldNo), InStr);
    end;

    procedure SaveFile(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer; FileToSave: InStream)
    var
        FileStorageSetup: Record "WSC File Storage Setup";
        TempSharePointFile: Record "SharePoint File" temporary;
        Authorization: Interface "SharePoint Authorization";
        SharePointAuth: Codeunit "SharePoint Auth.";
        SharePointClient: Codeunit "SharePoint Client";
        InStr: InStream;
    begin
        FileStorageSetup.Get(LogCalls."WSC File Storage Code");
        FileStorageSetup.TestField("WSC Type", FileStorageSetup."WSC Type"::Sharepoint);

        Authorization := SharePointAuth.CreateAuthorizationCode(FileStorageSetup.GetField('entraTenantId'), FileStorageSetup.GetField('clientId'), FileStorageSetup.GetField('clientSecret'), FileStorageSetup.GetField('scope'));
        SharePointClient.Initialize(FileStorageSetup.GetField('baseUrl'), Authorization);
        SharePointClient.AddFileToFolder(FileStorageSetup.GetField('baseUrl') + CreateFileName(LogCalls, FieldNo), CreateFileName(LogCalls, FieldNo), FileToSave, TempSharePointFile);
    end;

    procedure FileExist(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer): Boolean
    var
        FileStorageSetup: Record "WSC File Storage Setup";
        Authorization: Interface "SharePoint Authorization";
        SharePointAuth: Codeunit "SharePoint Auth.";
        SharePointClient: Codeunit "SharePoint Client";
        TempBlob: Codeunit "Temp Blob";
    begin
        FileStorageSetup.Get(LogCalls."WSC File Storage Code");
        FileStorageSetup.TestField("WSC Type", FileStorageSetup."WSC Type"::Sharepoint);

        Authorization := SharePointAuth.CreateAuthorizationCode(FileStorageSetup.GetField('entraTenantId'), FileStorageSetup.GetField('clientId'), FileStorageSetup.GetField('clientSecret'), FileStorageSetup.GetField('scope'));
        SharePointClient.Initialize(FileStorageSetup.GetField('baseUrl'), Authorization);
        SharePointClient.DownloadFileContentByServerRelativeUrl(FileStorageSetup.GetField('baseUrl') + CreateFileName(LogCalls, FieldNo), TempBlob);
        exit(TempBlob.HasValue());
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