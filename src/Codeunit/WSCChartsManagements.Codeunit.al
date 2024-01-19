/// <summary>
/// Codeunit WSC Charts Managements (ID 81006).
/// </summary>
codeunit 81006 "WSC Charts Managements"
{
    trigger OnRun()
    begin

    end;

    var
        WebServicesChartsSetup: Record "WSC Charts Setup";

    /// <summary>
    /// GenerateData.
    /// </summary>
    /// <param name="BusinessChartBuffer">VAR Record "Business Chart Buffer".</param>
    procedure GenerateData(var BusinessChartBuffer: Record "Business Chart Buffer")
    var
        Top5WebServiceCalls: Query "WSC Top 5 Web Service Calls";
        Connections: Record "WSC Connections";
        LogCalls: Record "WSC Log Calls";
        Index: Integer;
    begin
        WebServicesChartsSetup.Reset();
        WebServicesChartsSetup.SetRange("WSC User ID", UserId());
        if not WebServicesChartsSetup.FindFirst() then
            Page.RunModal(Page::"WSC Charts Setup");

        BusinessChartBuffer.Initialize();
        BusinessChartBuffer.AddMeasure('Calls', 1, BusinessChartBuffer."Data Type"::Integer, WebServicesChartsSetup."WSC Top Calls Chart Types".AsInteger());
        BusinessChartBuffer.SetXAxis('Code', BusinessChartBuffer."Data Type"::String);

        Top5WebServiceCalls.Open();
        while Top5WebServiceCalls.Read() do begin
            BusinessChartBuffer.AddColumn(Top5WebServiceCalls.WSCCode);
            BusinessChartBuffer.SetValueByIndex(0, Index, Top5WebServiceCalls.TotalCalls);
            Index += 1;
        end;

    end;

    /// <summary>
    /// DrillDown.
    /// </summary>
    /// <param name="WSCode">Text.</param>
    procedure DrillDown(WSCode: Text)
    var
        LogCalls: Record "WSC Log Calls";
    begin
        LogCalls.Reset();
        LogCalls.FilterGroup(2);
        LogCalls.SetRange("WSC Code", WSCode);
        LogCalls.FilterGroup(0);
        Page.Run(0, LogCalls);
    end;
}