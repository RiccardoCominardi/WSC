/// <summary>
/// Page WCS Web Services Tree Visual (ID 81009).
/// </summary>
page 81009 "WCS Web Services Tree Visual"
{
    Caption = 'Web Services - Tree Visual';
    Editable = false;
    PageType = List;
    SourceTable = "WCS Web Services Tree Visual";
    SourceTableView = sorting("WSC Group Code", "WSC Entry No.") order(ascending);

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                ShowAsTree = true;
                IndentationColumn = NameIndent;
                IndentationControls = "WSC Description";
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Emphasize;
                }
                field("WSC Indentation"; Rec."WSC Indentation")
                {
                    ApplicationArea = All;
                    Visible = false;
                }

                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = Emphasize;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        FormatLines;
    end;

    trigger OnOpenPage()
    begin
    end;

    /// <summary>
    /// BuildPage.
    /// </summary>
    procedure BuildPage()
    var
        WSCWSServicesMgt: Codeunit "WSC Web Services Management";
    begin
        WSCWSServicesMgt.LoadWCSTreeVisualTable(Rec);
    end;


    var
        Text000: Label 'Shortcut Dimension %1';
        [InDataSet]
        Emphasize: Boolean;
        [InDataSet]
        NameIndent: Integer;

    local procedure FormatLines()
    begin
        Emphasize := Rec."WSC Indentation" = 0;
        NameIndent := Rec."WSC Indentation";
    end;
}

