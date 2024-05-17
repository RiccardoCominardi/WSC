codeunit 81009 "WSC Application Storage" implements "WSC Log Files Handler"
{
    procedure GetFile(LogCalls: Record "WSC Log Calls"; FieldNo: Integer) TempBlob: Codeunit "Temp Blob"
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LogCalls);
        TempBlob.FromRecordRef(RecRef, FieldNo);
    end;

    procedure SaveFile(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer; FileToSave: InStream)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LogCalls);
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, FileToSave);
        TempBlob.ToRecordRef(RecRef, FieldNo);
        RecRef.SetTable(LogCalls);
    end;

    procedure FileExist(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(LogCalls);
        TempBlob.FromRecordRef(RecRef, FieldNo);
        exit(TempBlob.HasValue());
    end;
}