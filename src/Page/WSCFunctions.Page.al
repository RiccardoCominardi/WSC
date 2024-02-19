/// <summary>
/// Page WSC Functions (ID 81019).
/// </summary>
page 81019 "WSC Functions"
{
    Caption = 'Functions (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Functions";
    SourceTableView = sorting("WSC Sequence");
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("WSC Enabled"; Rec."WSC Enabled")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Connection Code"; Rec."WSC Connection Code")
                {
                    ApplicationArea = All;
                    Visible = not FromConnVisibility;
                    Editable = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Sequence"; Rec."WSC Sequence")
                {
                    ApplicationArea = All;
                    Visible = not FromConnVisibility;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
                field("WSC GuiAllowed"; Rec."WSC GuiAllowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this function will be executed only if the call it was done manually';
                    StyleExpr = not Rec."WSC Enabled";
                    Style = Unfavorable;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(LoadStandardFunctions)
            {
                ApplicationArea = All;
                Caption = 'Load Standard Functions';
                Visible = FromConnVisibility;
                Image = WorkCenterLoad;

                trigger OnAction()
                var
                    FunctionsManagements: Codeunit "WSC Functions Managements";
                begin
                    FunctionsManagements.LoadStandardFunctions(Rec."WSC Connection Code");
                end;
            }
            action(MoveUp)
            {
                ApplicationArea = All;
                Caption = 'Move Up';
                Visible = FromConnVisibility;
                Image = MoveUp;

                trigger OnAction()
                begin
                    Rec.ChangeSequence(-1);
                end;
            }
            action(MoveDown)
            {
                ApplicationArea = All;
                Caption = 'Move Down';
                Visible = FromConnVisibility;
                Image = MoveDown;
                trigger OnAction()
                begin
                    Rec.ChangeSequence(1);
                end;
            }
        }
        area(Promoted)
        {
            actionref(LoadStandardFunctions_Promoted; LoadStandardFunctions) { }
            actionref(MoveUp_Promoted; MoveUp) { }
            actionref(ModeDown_Promoted; MoveDown) { }
        }
    }

    /// <summary>
    /// IsFromConnVisibility.
    /// </summary>
    /// <param name="FromConnVis">Boolean.</param>
    procedure IsFromConnVisibility(FromConnVis: Boolean)
    begin
        FromConnVisibility := FromConnVis;
    end;

    var
        FromConnVisibility: Boolean;
}