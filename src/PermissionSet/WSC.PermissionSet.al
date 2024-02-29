/// <summary>
/// Unknown WSC (ID 81001).
/// </summary>
permissionset 81001 "WSC Permissions"
{
    Assignable = true;
    Caption = 'WSC Permissions';

    Permissions =
         codeunit "WSC Caller" = X,
         codeunit "WSC Charts Managements" = X,
         codeunit "WSC Examples" = X,
         codeunit "WSC Functions Managements" = X,
         codeunit "WSC Import Export Config." = X,
         codeunit "WSC Managements" = X,
         codeunit "WSC NotificationActionHandler" = X,
         codeunit "WSC Security Managements" = X,
         codeunit "WSC Upgrade" = X,
         report "WSC Copy Request Details" = X,
         page "WSC Bodies" = X,
         page "WSC Charts Setup" = X,
         page "WSC Connection Card" = X,
         page "WSC Connections List" = X,
         page "WSC EndPoint Variables Factbox" = X,
         page "WSC EndPoint Variables List" = X,
         page "WSC Functions" = X,
         page "WSC Headers" = X,
         page "WSC Import Configuration" = X,
         page "WSC Log Bodies" = X,
         page "WSC Log Calls" = X,
         page "WSC Log Headers" = X,
         page "WSC Log Parameters" = X,
         page "WSC Parameters" = X,
         page "WSC Parameters Factbox" = X,
         page "WSC Top Calls Charts" = X,
         table "WSC Bodies" = X,
         table "WSC Charts Setup" = X,
         table "WSC Connections" = X,
         table "WSC EndPoint Variables" = X,
         table "WSC Functions" = X,
         table "WSC Headers" = X,
         table "WSC Log Bodies" = X,
         table "WSC Log Calls" = X,
         table "WSC Log Headers" = X,
         table "WSC Log Parameters" = X,
         table "WSC Parameters" = X,
         tabledata "WSC Bodies" = RIMD,
         tabledata "WSC Charts Setup" = RIMD,
         tabledata "WSC Connections" = RIMD,
         tabledata "WSC EndPoint Variables" = RIMD,
         tabledata "WSC Functions" = RIMD,
         tabledata "WSC Headers" = RIMD,
         tabledata "WSC Log Bodies" = RIMD,
         tabledata "WSC Log Calls" = RIMD,
         tabledata "WSC Log Headers" = RIMD,
         tabledata "WSC Log Parameters" = RIMD,
         tabledata "WSC Parameters" = RIMD;
}