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
        Upgrade_RetentionPolicies();
    end;

    local procedure HandleReinstall()
    begin
        SetEndpointVariables(true);
        Upgrade_RetentionPolicies();
    end;

    #region InstallProcedure
    local procedure SetEndpointVariables(IsReinstall: Boolean)
    var
        EndPointVariables: Record "WSC EndPoint Variables";
        Text000Lbl: Label 'Set Current Company ID';
        Text001Lbl: Label 'Set Current Company Name';
        Text002Lbl: Label 'Set Current User ID';
        Text003Lbl: Label 'Used to add text to Endpoint';
    begin
        if IsReinstall then begin
            EndPointVariables.SetRange("WSC Custom Var", false);
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

        EndPointVariables.Init();
        EndPointVariables."WSC Variable Name" := '[@Url_1]';
        EndPointVariables."WSC Description" := Text003Lbl;
        EndPointVariables.Insert();

        EndPointVariables.Init();
        EndPointVariables."WSC Variable Name" := '[@Url_2]';
        EndPointVariables."WSC Description" := Text003Lbl;
        EndPointVariables.Insert();
    end;

    local procedure Upgrade_RetentionPolicies()
    var
        LogCalls: Record "WSC Log Calls";
        RetenPolAllowedTables: Codeunit "Reten. Pol. Allowed Tables";
        TableFilters: JsonArray;
        Filtering: enum "Reten. Pol. Filtering";
        Deleting: enum "Reten. Pol. Deleting";
        MandatoryMinimumRetentionDays: Integer;
    begin
        MandatoryMinimumRetentionDays := 7;
        Filtering := Filtering::Default;
        Deleting := Deleting::Default;
        RetenPolAllowedTables.AddAllowedTable(Database::"WSC Log Calls", LogCalls.FieldNo(SystemCreatedAt), MandatoryMinimumRetentionDays, Filtering, Deleting, TableFilters);
    end;
    #endregion InstallProcedure
}