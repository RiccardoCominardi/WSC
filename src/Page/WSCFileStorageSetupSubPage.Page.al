page 81025 "WSC File Storage Setup SubPage"
{
    Caption = 'Details';
    PageType = ListPart;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Details)
            {
                Caption = 'Details';
                field("WSC Name"; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("WSC Value"; Rec."Value")
                {
                    ApplicationArea = All;
                    StyleExpr = FieldExpr;
                    trigger OnValidate()
                    var
                        FileStorageSetup: Record "WSC File Storage Setup";
                        Text000Qst: Label 'Do you want to update the configuration value?';
                    begin
                        FileStorageSetup.Get(ConfigCode);
                        if FileStorageSetup.IsFieldSet(Rec.Name) then
                            if not Confirm(Text000Qst, false) then
                                Error('');
                        FileStorageSetup.SetField(Rec.Name, Rec.Value);
                        Rec.Value := 'Filled';
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        FileStorageSetup: Record "WSC File Storage Setup";
    begin
        if ConfigCode = '' then
            exit;
        if not FileStorageSetup.Get(ConfigCode) then
            exit;
        FileStorageSetup.LoadDetails(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        FileStorageSetup: Record "WSC File Storage Setup";
    begin
        if not FileStorageSetup.Get(ConfigCode) then
            exit;

        FieldExpr := 'Standard';
        if FileStorageSetup.IsFieldSet(Rec.Name) then
            FieldExpr := 'StrongAccent';
    end;

    procedure CalcDetails()
    var
        FileStorageSetup: Record "WSC File Storage Setup";
    begin
        if ConfigCode = '' then
            exit;
        FileStorageSetup.Get(ConfigCode);
        FileStorageSetup.LoadDetails(Rec);
    end;

    procedure SetConfigCode(SetupCode: Code[20])
    begin
        ConfigCode := SetupCode;
    end;

    procedure GetConfigCode(var SetupCode: Code[20])
    begin
        SetupCode := ConfigCode;
    end;

    var
        ConfigCode: Code[20];
        FieldExpr: Text;
}