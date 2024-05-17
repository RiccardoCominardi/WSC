interface "WSC Log Files Handler"
{
    procedure GetFile(LogCalls: Record "WSC Log Calls"; FieldNo: Integer) TempBlob: Codeunit "Temp Blob";

    procedure SaveFile(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer; FileToSave: InStream)

    procedure FileExist(var LogCalls: Record "WSC Log Calls"; FieldNo: Integer): Boolean
}