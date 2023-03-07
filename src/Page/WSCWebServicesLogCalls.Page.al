/// <summary>
/// Page WSC Web Services Log Calls (ID 81005).
/// </summary>
page 81005 "WSC Web Services Log Calls"
{
    Caption = 'Web Services Log Calls';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "WSC Web Services Log Calls";
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
                field("WSC Body Message"; Rec."WSC Body Message".HasValue())
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
                field("WSC Response Message"; Rec."WSC Response Message".HasValue())
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
                field("WSC Message Text"; Rec."WSC Message Text")
                {
                    ApplicationArea = All;
                }
                field("WSC Execution Date-Time"; Rec."WSC Execution Date-Time")
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
            action(Headers)
            {
                Caption = 'Headers';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = SetupList;

                trigger OnAction()
                var
                    WSCWSServicesLogHeaders: Record "WSC Web Services Log Headers";
                begin
                    WSCWSServicesLogHeaders.ViewLog(Rec."WSC Code", Rec."WSC Entry No.");
                end;
            }
            action(Bodies)
            {
                Caption = 'Bodies';
                ApplicationArea = All;
                PromotedCategory = Process;
                Promoted = true;
                Image = SetupList;

                trigger OnAction()
                var
                    WSCWSServicesLogBodies: Record "WSC Web Services Log Bodies";
                begin
                    WSCWSServicesLogBodies.ViewLog(Rec."WSC Code", Rec."WSC Entry No.");
                end;
            }
        }
    }
}