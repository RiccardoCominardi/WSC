/// <summary>
/// Codeunit WSC Install (ID 81004).
/// </summary>
codeunit 81004 "WSC Install"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    var
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);
        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then
            HandleFreshInstall()
        else
            HandleReinstall();
    end;

    trigger OnInstallAppPerDatabase()
    begin

    end;

    local procedure HandleFreshInstall()
    begin
        SetEndpointVariables(false);
    end;

    local procedure HandleReinstall()
    begin
        SetEndpointVariables(true);
    end;

    #region InstallProcedure
    local procedure SetEndpointVariables(IsReinstall: Boolean)
    var
        WebServicesEndPointVar: Record "WSC Web Services EndPoint Var.";
        Text000Lbl: Label 'Set Current Company ID';
        Text001Lbl: Label 'Set Current Company Name';
        Text002Lbl: Label 'Set Current User ID';
    begin
        if IsReinstall then begin
            WebServicesEndPointVar.SetFilter("WSC Variable Name", '[@CompanyID]|[@CompanyName]|[@UserID]');
            if not WebServicesEndPointVar.IsEmpty() then
                WebServicesEndPointVar.DeleteAll();
        end;

        WebServicesEndPointVar.Reset();

        WebServicesEndPointVar.Init();
        WebServicesEndPointVar."WSC Variable Name" := '[@CompanyID]';
        WebServicesEndPointVar."WSC Description" := Text000Lbl;
        WebServicesEndPointVar.Insert();

        WebServicesEndPointVar.Init();
        WebServicesEndPointVar."WSC Variable Name" := '[@CompanyName]';
        WebServicesEndPointVar."WSC Description" := Text001Lbl;
        WebServicesEndPointVar.Insert();

        WebServicesEndPointVar.Init();
        WebServicesEndPointVar."WSC Variable Name" := '[@UserID]';
        WebServicesEndPointVar."WSC Description" := Text002Lbl;
        WebServicesEndPointVar.Insert();
    end;
    #endregion InstallProcedure
}