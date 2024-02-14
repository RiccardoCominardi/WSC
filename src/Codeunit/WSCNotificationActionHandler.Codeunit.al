/// <summary>
/// Codeunit WSC NotificationActionHandler (ID 81007).
/// </summary>
codeunit 81007 "WSC NotificationActionHandler"
{
    trigger OnRun()
    begin

    end;

    /// <summary>
    /// ViewLog.
    /// </summary>
    /// <param name="ViewLogNotification">Notification.</param>
    procedure ViewLog(ViewLogNotification: Notification);
    var
        LogCalls: Record "WSC Log Calls";
    begin
        LogCalls.Reset();
        LogCalls.SetRange("WSC Code", ViewLogNotification.GetData(LogCalls.FieldName("WSC Code")));
        LogCalls.Ascending(false);
        Page.RunModal(0, LogCalls);
    end;
}