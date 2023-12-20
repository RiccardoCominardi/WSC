/// <summary>
/// Unknown WSC (ID 81001).
/// </summary>
permissionset 81001 "WSC Permissions"
{
    Assignable = true;
    Caption = 'WSC Permissions';

    Permissions =
         codeunit "WSC Web Services Caller" = X,
         codeunit "WSC Web Services Examples" = X,
         codeunit "WSC Web Services Management" = X,
         codeunit "WSC Import Export Config." = X,
         page "WSC Web Services Tree Visual" = X,
         page "WSC Web Service Conn. Card" = X,
         page "WSC Web Services Bodies" = X,
         page "WSC Web Services Conn. List" = X,
         page "WSC Web Services EndPntVarList" = X,
         page "WSC Web Services EndPoint Var." = X,
         page "WSC Web Services Group Codes" = X,
         page "WSC Web Services Headers" = X,
         page "WSC Web Services Log Bodies" = X,
         page "WSC Web Services Log Calls" = X,
         page "WSC Web Services Log Headers" = X,
         table "WSC Web Services Tree Visual" = X,
         table "WSC Web Services Bodies" = X,
         table "WSC Web Services Connections" = X,
         table "WSC Web Services EndPoint Var." = X,
         table "WSC Web Services Group Codes" = X,
         table "WSC Web Services Headers" = X,
         table "WSC Web Services Log Bodies" = X,
         table "WSC Web Services Log Calls" = X,
         table "WSC Web Services Log Headers" = X,
         tabledata "WSC Web Services Tree Visual" = RIMD,
         tabledata "WSC Web Services Bodies" = RIMD,
         tabledata "WSC Web Services Connections" = RIMD,
         tabledata "WSC Web Services EndPoint Var." = RIMD,
         tabledata "WSC Web Services Group Codes" = RIMD,
         tabledata "WSC Web Services Headers" = RIMD,
         tabledata "WSC Web Services Log Bodies" = RIMD,
         tabledata "WSC Web Services Log Calls" = RIMD,
         tabledata "WSC Web Services Log Headers" = RIMD;
}