/// <summary>
/// Page WSC Charts Setup (ID 81016).
/// </summary>
page 81016 "WSC Charts Setup"
{
    Caption = 'Charts Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = StandardDialog;
    SourceTable = "WSC Charts Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("WSC Total Call Chart Types"; Rec."WSC Top Calls Chart Types")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get(UserId()) then begin
            Rec.Init();
            Rec."WSC User ID" := UserId();
            Rec.Insert();
        end;

        Rec.FilterGroup(2);
        Rec.SetRange("WSC User ID", UserId());
        Rec.FilterGroup(0);
    end;
}