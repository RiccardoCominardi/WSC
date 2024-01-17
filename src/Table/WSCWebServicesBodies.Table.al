/// <summary>
/// Table WSC Web Services Bodies (ID 81003).
/// </summary>
table 81003 "WSC Web Services Bodies"
{
    Caption = 'Web Services - Bodies';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Bodies";
    LookupPageId = "WSC Web Services Bodies";

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "WSC Web Services Connections"."WSC Code";
        }
        field(2; "WSC Key"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Key';
        }
        field(3; "WSC Value"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Value';
        }
        field(4; "WSC Secret Value"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Secret Value';
        }

        field(5; "WSC Token DataScope"; Enum "WSC Token DataScope")
        {
            DataClassification = CustomerContent;
            Caption = 'Token DataScope';
        }
        field(6; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(7; "WSC Is Secret"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Secret';
        }
    }

    keys
    {
        key(Key1; "WSC Code", "WSC Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// ViewLog.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    procedure ViewLog(WSCCode: Code[20])
    var
        WebServicesConnections: Record "WSC Web Services Connections";
        WebServicesBodies: Record "WSC Web Services Bodies";
    begin
        WebServicesConnections.Get(WSCCode);
        if not (WebServicesConnections."WSC Body Type" in [WebServicesConnections."WSC Body Type"::"form data", WebServicesConnections."WSC Body Type"::"x-www-form-urlencoded"]) then
            exit;

        WebServicesBodies.Reset();
        WebServicesBodies.FilterGroup(2);
        WebServicesBodies.SetRange("WSC Code", WebServicesConnections."WSC Code");
        WebServicesBodies.FilterGroup(0);
        Page.RunModal(0, WebServicesBodies);
    end;

    /// <summary>
    /// HasValue.
    /// </summary>
    /// <returns>Return value of type Boolean.</returns>
    procedure HasValue(): Boolean
    var
        SecurityManagements: Codeunit "WSC Security Managements";
    begin
        if Rec."WSC Value" <> '' then
            exit(true);

        if SecurityManagements.HasToken(Rec."WSC Secret Value", Rec.GetTokenDataScope()) then
            exit(true);

        exit(false);
    end;

    /// <summary>
    /// GetValue.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    [NonDebuggable]
    procedure GetValue() ValueAsText: Text;
    var
        SecurityManagements: Codeunit "WSC Security Managements";
    begin
        ValueAsText := '';
        if Rec."WSC Is Secret" then begin
            if SecurityManagements.HasToken(Rec."WSC Secret Value", Rec.GetTokenDataScope()) then
                ValueAsText := SecurityManagements.GetToken(Rec."WSC Secret Value", Rec.GetTokenDataScope());
        end else
            ValueAsText := Rec."WSC Value";
    end;

    /// <summary>
    /// SetValue.
    /// </summary>
    /// <param name="ValueAsText">Text.</param>
    [NonDebuggable]
    procedure SetValue(ValueAsText: Text)
    var
        SecurityManagements: Codeunit "WSC Security Managements";
    begin
        if Rec."WSC Is Secret" then begin
            Rec."WSC Value" := '';
            SecurityManagements.SetToken(Rec."WSC Secret Value", ValueAsText, Rec.GetTokenDataScope());
        end else begin
            if SecurityManagements.DeleteToken(Rec."WSC Secret Value", Rec.GetTokenDataScope()) then
                Clear(Rec."WSC Secret Value");
            Rec."WSC Value" := ValueAsText;
        end;
    end;

    /// <summary>
    /// ConvertValue.
    /// </summary>
    [NonDebuggable]
    procedure ConvertValue()
    var
        SecurityManagements: Codeunit "WSC Security Managements";
        Text000Qst: Label 'There is already a value. Do you want to convert it?';
    begin
        if xRec."WSC Is Secret" <> Rec."WSC Is Secret" then
            if Rec.HasValue() then
                if not Confirm(Text000Qst) then begin
                    if SecurityManagements.DeleteToken(Rec."WSC Secret Value", Rec.GetTokenDataScope()) then
                        Clear(Rec."WSC Secret Value");
                    Rec."WSC Value" := '';
                end else begin
                    if Rec."WSC Is Secret" then begin
                        SecurityManagements.SetToken(Rec."WSC Secret Value", Rec."WSC Value", Rec.GetTokenDataScope());
                        Rec."WSC Value" := '';
                    end else begin
                        Rec."WSC Value" := SecurityManagements.GetToken(Rec."WSC Secret Value", Rec.GetTokenDataScope());
                        if SecurityManagements.DeleteToken(Rec."WSC Secret Value", Rec.GetTokenDataScope()) then
                            Clear(Rec."WSC Secret Value");
                    end;
                end;
    end;

    /// <summary>
    /// GetTokenDataScope.
    /// </summary>
    /// <returns>Return value of type DataScope.</returns>
    procedure GetTokenDataScope(): DataScope
    begin
        case Rec."WSC Token DataScope" of
            "WSC Token DataScope"::Company:
                exit(DataScope::Company);
            "WSC Token DataScope"::UserAndCompany:
                exit(DataScope::CompanyAndUser);
            "WSC Token DataScope"::User:
                exit(DataScope::User);
            "WSC Token DataScope"::Module:
                exit(DataScope::Module);
        end;
    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        SecurityManagements: Codeunit "WSC Security Managements";
    begin
        if Rec."WSC Is Secret" then
            SecurityManagements.DeleteToken(Rec."WSC Secret Value", Rec.GetTokenDataScope());
    end;

    trigger OnRename()
    begin

    end;

}