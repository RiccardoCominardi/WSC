/// <summary>
/// Unknown WSC (ID 81001).
/// </summary>
permissionset 81001 "WSC Permissions"
{
    Assignable = true;
    Caption = 'WSC Permissions';

    Permissions =
         codeunit "WSC Caller" = X,
         codeunit "WSC Examples" = X,
         codeunit "WSC Managements" = X,
         codeunit "WSC Import Export Config." = X,
         codeunit "WSC Upgrade" = X,
         codeunit "WSC Security Managements" = X,
         page "WSC Tree Visualization" = X,
         page "WSC Connection Card" = X,
         page "WSC Bodies" = X,
         page "WSC Connections List" = X,
         page "WSC EndPoint Variables List" = X,
         page "WSC EndPoint Variables Factbox" = X,
         page "WSC Group Codes" = X,
         page "WSC Parameters" = X,
         page "WSC Headers" = X,
         page "WSC Log Bodies" = X,
         page "WSC Log Calls" = X,
         page "WSC Log Headers" = X,
         page "WSC Log Parameters" = X,
         table "WSC Tree Visualization" = X,
         table "WSC Bodies" = X,
         table "WSC Connections" = X,
         table "WSC EndPoint Variables" = X,
         table "WSC Group Codes" = X,
         table "WSC Parameters" = X,
         table "WSC Headers" = X,
         table "WSC Log Bodies" = X,
         table "WSC Log Calls" = X,
         table "WSC Log Headers" = X,
         table "WSC Log Parameters" = X,
         tabledata "WSC Tree Visualization" = RIMD,
         tabledata "WSC Bodies" = RIMD,
         tabledata "WSC Connections" = RIMD,
         tabledata "WSC EndPoint Variables" = RIMD,
         tabledata "WSC Group Codes" = RIMD,
         tabledata "WSC Parameters" = RIMD,
         tabledata "WSC Headers" = RIMD,
         tabledata "WSC Log Bodies" = RIMD,
         tabledata "WSC Log Calls" = RIMD,
         tabledata "WSC Log Headers" = RIMD,
         tabledata "WSC Log Parameters" = RIMD;
}