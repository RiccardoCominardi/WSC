page 81023 "WSC File Storage Setup List"
{
    Caption = 'File Storage Setup (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WSC File Storage Setup";
    CardPageID = "WSC File Storage Setup";
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Type"; Rec."WSC Type")
                {
                    ApplicationArea = All;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}