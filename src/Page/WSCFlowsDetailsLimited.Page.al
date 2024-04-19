page 81021 "WSC Flows Details Limited"
{
    PageType = ListPart;
    SourceTable = "WSC Flows Details";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Connection Code"; Rec."WSC Connection Code")
                {
                    ApplicationArea = All;
                    TableRelation = "WSC Connections"."WSC Code" where("WSC Type" = const("WSC Types"::Token));
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}