/// <summary>
/// Codeunit WSC Upgrade (ID 81004).
/// </summary>
codeunit 81004 "WSC Upgrade"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo);
        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then
            HandleFreshInstall()
        else
            HandleReinstall();
    end;

    trigger OnValidateUpgradePerDatabase()
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
        EndPointVariables: Record "WSC EndPoint Variables";
        Text000Lbl: Label 'Set Current Company ID';
        Text001Lbl: Label 'Set Current Company Name';
        Text002Lbl: Label 'Set Current User ID';
    begin
        if IsReinstall then begin
            EndPointVariables.SetFilter("WSC Variable Name", '[@CompanyID]|[@CompanyName]|[@UserID]');
            if not EndPointVariables.IsEmpty() then
                EndPointVariables.DeleteAll();
        end;

        EndPointVariables.Reset();

        EndPointVariables.Init();
        EndPointVariables."WSC Variable Name" := '[@CompanyID]';
        EndPointVariables."WSC Description" := Text000Lbl;
        EndPointVariables.Insert();

        EndPointVariables.Init();
        EndPointVariables."WSC Variable Name" := '[@CompanyName]';
        EndPointVariables."WSC Description" := Text001Lbl;
        EndPointVariables.Insert();

        EndPointVariables.Init();
        EndPointVariables."WSC Variable Name" := '[@UserID]';
        EndPointVariables."WSC Description" := Text002Lbl;
        EndPointVariables.Insert();
    end;
    #endregion InstallProcedure
}