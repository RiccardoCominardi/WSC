/// <summary>
/// ControlAddIn WSC Gantt.
/// </summary>
controladdin "WSC Gantt"
{
    Scripts = 'src/TestDevelopments/Gantt/Script/GanttDhtmlx.js', 'src/TestDevelopments/Gantt/Script/GanttFunctions.js';
    StartupScript = 'src/TestDevelopments/Gantt/Script/GanttStartup.js';
    StyleSheets = 'src/TestDevelopments/Gantt/Css/Gantt.css';
    VerticalStretch = true;
    HorizontalStretch = true;

    /// <summary>
    /// ControlReady.
    /// </summary>
    event ControlReady();

    procedure Load(Data: JsonObject);
}