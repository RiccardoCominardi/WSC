controladdin "WSC File Drag and Drop"
{
    Scripts = 'https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.3.1.min.js',
        'src/TestDevelopments/DragDrop/Script/Script.js';
    StartupScript = 'src/TestDevelopments/DragDrop/Script/Startup.js';

    RequestedHeight = 1;
    MinimumHeight = 1;
    HorizontalStretch = true;

    event ControlAddinReady();
    event OnFileUpload(FileName: Text; FileAsText: Text; IsLastFile: Boolean)
    procedure InitializeFileDragAndDrop()
}