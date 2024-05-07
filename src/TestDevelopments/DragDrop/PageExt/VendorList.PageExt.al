pageextension 81002 "WSC Vendor List" extends "Vendor List"
{
    layout
    {
        addfirst(factboxes)
        {
            part(WSCDragAndDropFactbox; "WSC Drag & Drop Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = const(23), "No." = field("No.");
            }
        }
    }
}