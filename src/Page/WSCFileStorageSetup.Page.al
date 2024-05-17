page 81024 "WSC File Storage Setup"
{
    Caption = 'File Storage Setup (WSC)';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "WSC File Storage Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("WSC Code"; Rec."WSC Code")
                {
                    ApplicationArea = All;
                    NotBlank = true;
                    trigger OnValidate()
                    begin
                        CurrPage.Details.Page.SetConfigCode(Rec."WSC Code");
                    end;
                }
                field("WSC Type"; Rec."WSC Type")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                        CurrPage.Details.Page.CalcDetails();
                    end;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                }
            }
            part(Details; "WSC File Storage Setup SubPage")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(TEST)
            {
                ApplicationArea = All;
                Caption = 'Test';
                Image = "1099Form";
                trigger OnAction()
                var
                    Filename: Text;
                    InStr: InStream;
                begin
                    Rec.CalcFields("WSC Configuration");
                    Rec."WSC Configuration".CreateInStream(InStr);
                    FileName := 'Test.json';
                    DownloadFromStream(InStr, '', '', '*.json', FileName);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Details.Page.SetConfigCode(Rec."WSC Code");
    end;
}