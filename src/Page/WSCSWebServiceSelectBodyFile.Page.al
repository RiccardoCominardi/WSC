/// <summary>
/// Page WSC Web Service Sel. Body File (ID 81006).
/// </summary>
page 81006 "WSC Web Service Sel. Body File"
{
    Caption = 'Web Services - Select Body File';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = Integer;
    SourceTableTemporary = true;
    InsertAllowed = false;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            group(GroupName)
            {
                ShowCaption = false;
                field(GlobalBase64String; GlobalBase64String)
                {
                    Caption = 'File In Base64 String';
                    ApplicationArea = All;
                }
            }
        }
    }
    /// <summary>
    /// GetBodyFile.
    /// </summary>
    /// <param name="Base64String">VAR Text.</param>
    procedure GetBodyString(var Base64String: Text)
    var
    begin
        Base64String := GlobalBase64String;
    end;


    var
        GlobalBase64String: Text;
}