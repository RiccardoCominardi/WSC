/// <summary>
/// Page WSC Log Calls (ID 81005).
/// </summary>
page 81005 "WSC Log Calls"
{
    Caption = 'Log Calls (WSC)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Log Calls";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {

                field("WSC Entry No."; Rec."WSC Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
                field("WSC HTTP Method"; Rec."WSC HTTP Method")
                {
                    ApplicationArea = All;
                }
                field("WSC EndPoint"; Rec."WSC EndPoint")
                {
                    ApplicationArea = All;
                }
                field("WSC Auth. Type"; Rec."WSC Auth. Type")
                {
                    ApplicationArea = All;
                }
                field("WSC Bearer Connection"; Rec."WSC Bearer Connection")
                {
                    ApplicationArea = All;
                }
                field("WSC Bearer Connection Code"; Rec."WSC Bearer Connection Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Link To Entry No."; Rec."WSC Link To Entry No.")
                {
                    ApplicationArea = All;
                }
                field("WSC Allow Blank Response"; Rec."WSC Allow Blank Response")
                {
                    ApplicationArea = All;
                }
                field("WSC Body Type"; Rec."WSC Body Type")
                {
                    ApplicationArea = All;
                }
                field(BodyExist; BodyExist)
                {
                    Caption = 'Body Message Present';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Rec.ExportAttachment(Rec.FieldNo("WSC Body Message"));
                        CurrPage.SaveRecord();
                    end;
                }
                field(ResponseExist; ResponseExist)
                {
                    Caption = 'Response Message Present';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    begin
                        Rec.ExportAttachment(Rec.FieldNo("WSC Response Message"));
                        CurrPage.SaveRecord();
                    end;
                }
                field("WSC Zip Response"; Rec."WSC Zip Response")
                {
                    ApplicationArea = All;
                }
                field("WSC Message Text"; Rec."WSC Message Text")
                {
                    ApplicationArea = All;
                }
                field("WSC Execution Date-Time"; Rec."WSC Execution Date-Time")
                {
                    ApplicationArea = All;
                }
                field("WSC Execution Time (ms)"; Rec."WSC Execution Time (ms)")
                {
                    ApplicationArea = All;
                }
                field("WSC Result Status Code"; Rec."WSC Result Status Code")
                {
                    ApplicationArea = All;
                }
                field("WSC Execution UserID"; Rec."WSC Execution UserID")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Parameters)
            {
                ApplicationArea = All;
                Image = SetupList;
                Caption = 'Parameters';
                ToolTip = 'Set Parameter information for the Web Service call';
                trigger OnAction()
                var
                    LogParameters: Record "WSC Log Parameters";
                begin
                    LogParameters.ViewLog(Rec."WSC Code", Rec."WSC Entry No.");
                end;
            }
            action(Headers)
            {
                Caption = 'Headers';
                ApplicationArea = All;
                Image = SetupList;

                trigger OnAction()
                var
                    LogHeaders: Record "WSC Log Headers";
                begin
                    LogHeaders.ViewLog(Rec."WSC Code", Rec."WSC Entry No.");
                end;
            }
            action(Bodies)
            {
                Caption = 'Bodies';
                ApplicationArea = All;
                Image = SetupList;

                trigger OnAction()
                var
                    LogBodies: Record "WSC Log Bodies";
                begin
                    LogBodies.ViewLog(Rec."WSC Code", Rec."WSC Entry No.");
                end;
            }
        }

        area(Promoted)
        {
            actionref(Parameters_Promoted; Parameters) { }
            actionref(Headers_Promoted; Headers) { }
            actionref(Bodies_Promoted; Bodies) { }

        }
    }

    trigger OnAfterGetRecord()
    begin
        SetFileExist();
    end;

    local procedure SetFileExist()
    var
        LogFilesHandler: Interface "WSC Log Files Handler";
    begin
        LogFilesHandler := Rec."WSC File Storage";
        BodyExist := LogFilesHandler.FileExist(Rec, Rec.FieldNo("WSC Body Message"));
        ResponseExist := LogFilesHandler.FileExist(Rec, Rec.FieldNo("WSC Response Message"));
    end;

    var
        BodyExist,
        ResponseExist : Boolean;
}