/// <summary>
/// Codeunit WSC Functions Managements (ID 81008).
/// </summary>
codeunit 81008 "WSC Functions Managements"
{
    trigger OnRun()
    begin

    end;

    /// <summary>
    /// ExecuteLinkedFunctions.
    /// </summary>
    /// <param name="LogCalls">Record "WSC Log Calls".</param>
    procedure ExecuteLinkedFunctions(LogCalls: Record "WSC Log Calls")
    var
        Functions: Record "WSC Functions";
        IsHandled: Boolean;
    begin
        OnBeforeExecuteLinkedFunctions(LogCalls, IsHandled);
        if IsHandled then
            exit;

        Functions.Reset();
        Functions.SetCurrentKey("WSC Sequence");
        Functions.SetRange("WSC Connection Code", LogCalls."WSC Code");
        Functions.SetRange("WSC Enabled", true);
        if not GuiAllowed then
            Functions.SetRange("WSC GuiAllowed", false);
        if Functions.IsEmpty() then
            exit;

        Functions.FindSet();
        repeat
            case Functions."WSC Code" of
                'DOWNLOAD_BODY':
                    DownloadMessage(LogCalls, 0);
                'DOWNLOAD_RESPONSE':
                    DownloadMessage(LogCalls, 1);
                else
                    OnExecuteLinkedFunctions(Functions, LogCalls);
            end
        until Functions.Next() = 0;
    end;

    local procedure DownloadMessage(LogCalls: Record "WSC Log Calls"; MessageType: Option "Body","Response")
    begin
        case MessageType of
            MessageType::Body:
                LogCalls.ExportAttachment(LogCalls.FieldNo("WSC Body Message"));
            MessageType::Response:
                LogCalls.ExportAttachment(LogCalls.FieldNo("WSC Response Message"));
        end;
    end;

    /// <summary>
    /// LoadStandardFunctions.
    /// </summary>
    /// <param name="WSCode">Code[20].</param>
    procedure LoadStandardFunctions(WSCode: Code[20])
    var
        Text000Lbl: Label 'DOWNLOAD_BODY';
        Text000DescLbl: Label 'Download Web Service Call Body if present';
        Text001Lbl: Label 'DOWNLOAD_RESPONSE';
        Text001DescLbl: Label 'Download Web Service Call Response';
    begin
        CreateFunction(WSCode, Text000Lbl, Text000DescLbl, false);
        CreateFunction(WSCode, Text001Lbl, Text001DescLbl, false);
    end;

    /// <summary>
    /// CreateFunction.
    /// </summary>
    /// <param name="WSCode">Code[20].</param>
    /// <param name="FunctionCode">Code[20].</param>
    /// <param name="Description">Text[100].</param>
    /// <param name="Custom">Boolean.</param>
    procedure CreateFunction(WSCode: Code[20]; FunctionCode: Code[20]; Description: Text[100]; Custom: Boolean)
    var
        Connections: Record "WSC Connections";
        Functions: Record "WSC Functions";
    begin
        Connections.Get(WSCode);

        Functions.Init();
        Functions."WSC Connection Code" := WSCode;
        Functions."WSC Code" := FunctionCode;
        Functions."WSC Description" := Description;
        Functions."WSC Custom" := Custom;
        Functions.InitializeSequence();
        if Functions.Insert() then;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExecuteLinkedFunctions(LogCalls: Record "WSC Log Calls"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnExecuteLinkedFunctions(Functions: Record "WSC Functions"; LogCalls: Record "WSC Log Calls")
    begin
    end;
}