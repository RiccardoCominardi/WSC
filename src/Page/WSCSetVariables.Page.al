page 81026 "WSC Set Variables"
{
    //Handled 5 parameters
    Caption = 'Set Variables';
    PageType = Card;
    DataCaptionExpression = GetPageCaption();
    SourceTable = Integer;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            grid(Grid1)
            {
                field(FinalEndpointString; FinalEndpointString)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                }
            }
            grid(Grid2)
            {
                group(EndpointVariables)
                {
                    Caption = 'Endpoint Variables';
                    field(Text1; ArrayOfText[1])
                    {
                        ApplicationArea = All;
                        Visible = VisibleText1;
                        CaptionClass = '1,5,,' + TextCaption[1];
                        trigger OnValidate()
                        begin
                            ParseEndpoint();
                        end;
                    }
                    field(Text2; ArrayOfText[2])
                    {
                        ApplicationArea = All;
                        Visible = VisibleText2;
                        CaptionClass = '1,5,,' + TextCaption[2];
                        trigger OnValidate()
                        begin
                            ParseEndpoint();
                        end;
                    }
                    field(Text3; ArrayOfText[3])
                    {
                        ApplicationArea = All;
                        Visible = VisibleText3;
                        CaptionClass = '1,5,,' + TextCaption[3];
                        trigger OnValidate()
                        begin
                            ParseEndpoint();
                        end;
                    }
                    field(Text4; ArrayOfText[4])
                    {
                        ApplicationArea = All;
                        Visible = VisibleText4;
                        CaptionClass = '1,5,,' + TextCaption[4];
                        trigger OnValidate()
                        begin
                            ParseEndpoint();
                        end;
                    }
                    field(Text5; ArrayOfText[5])
                    {
                        ApplicationArea = All;
                        Visible = VisibleText5;
                        CaptionClass = '1,5,,' + TextCaption[5];
                        trigger OnValidate()
                        begin
                            ParseEndpoint();
                        end;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ParseEndpoint();
    end;

    /*
        local procedure ParseEndpointCustom()
        var
            i: Integer;
            LocalEndpointString: Text;
        begin
            LocalEndpointString := RealEndpointString;
            for i := 1 to 5 do
                if TextCaption[i] <> '' then
                    if RealEndpointString.Contains(TextCaption[i]) then
                        if ArrayOfText[i] <> '' then
                            LocalEndpointString := LocalEndpointString.Replace(TextCaption[i], ArrayOfText[i])
                        else
                            LocalEndpointString := LocalEndpointString.Replace(TextCaption[i], TextCaption[i]);

            FinalEndpointString := LocalEndpointString;
        end;
        */

    local procedure ParseEndpoint()
    var
        Connections: Record "WSC Connections";
        EndPointVariables: Record "WSC EndPoint Variables";
        Company: Record Company;
        AzureADTenant: Codeunit "Azure AD Tenant";
        i: Integer;
        LocalEndpointString: Text;
    begin
        Connections.Get(WSCCode);
        FinalEndpointString := Connections."WSC EndPoint";
        RealEndpointString := FinalEndpointString;

        EndPointVariables.Reset();
        EndPointVariables.SetRange("WSC Custom Var", false);
        EndPointVariables.ReadIsolation := IsolationLevel::ReadUncommitted;
        if EndPointVariables.IsEmpty() then
            exit;
        EndPointVariables.ReadIsolation := IsolationLevel::ReadUncommitted;
        EndPointVariables.FindSet();
        repeat
            case EndPointVariables."WSC Variable Name" of
                '[@CompanyName]':
                    if FinalEndpointString.Contains('[@CompanyName]') then
                        FinalEndpointString := FinalEndpointString.Replace('[@CompanyName]', CompanyName());
                '[@CompanyID]':
                    if FinalEndpointString.Contains('[@CompanyID]') then begin
                        Company.Get(CompanyName());
                        FinalEndpointString := FinalEndpointString.Replace('[@CompanyID]', DelChr(Company.Id, '=', '{}'));
                    end;
                '[@UserID]':
                    if FinalEndpointString.Contains('[@UserID]') then
                        FinalEndpointString := FinalEndpointString.Replace('[@UserID]', UserId());
                '[@CurrTenantId]':
                    if FinalEndpointString.Contains('[@CurrTenantId]') then
                        FinalEndpointString := FinalEndpointString.Replace('[@CurrTenantId]', AzureADTenant.GetAadTenantId());
            end;
        until EndPointVariables.Next() = 0;

        LocalEndpointString := FinalEndpointString;

        for i := 1 to 5 do
            if TextCaption[i] <> '' then
                if RealEndpointString.Contains(TextCaption[i]) then
                    if ArrayOfText[i] <> '' then
                        LocalEndpointString := LocalEndpointString.Replace(TextCaption[i], ArrayOfText[i])
                    else
                        LocalEndpointString := LocalEndpointString.Replace(TextCaption[i], TextCaption[i]);

        FinalEndpointString := LocalEndpointString;
    end;

    procedure InitiParameters()
    begin
        VisibleText1 := false;
        VisibleText2 := false;
        VisibleText3 := false;
        VisibleText4 := false;
        VisibleText5 := false;
        TextCounter := 0;

        Clear(TextCaption);
    end;

    procedure SetWSCCode(WSCode: Code[20])
    begin
        WSCCode := WSCode;
    end;

    procedure GetArrayOf(var ArrayOfVariant: array[5] of Variant)
    var
        i: Integer;
    begin
        for i := 1 to 5 do
            ArrayOfVariant[i] := ArrayOfText[i];
    end;

    procedure GetVariablesAsDictionary(var Variables: Dictionary of [Text, Text])
    var
        i: Integer;
    begin
        Clear(Variables);
        for i := 1 to 5 do
            if ArrayOfText[i] <> '' then
                Variables.Add(TextCaption[i], ArrayOfText[i]);
    end;

    local procedure GetPageCaption(): Text[250]
    begin
        exit(WSCCode);
    end;

    procedure SetCaption(CaptionValue: Text)
    begin
        TextCounter += 1;
        TextCaption[TextCounter] := CaptionValue;
        case TextCounter of
            1:
                VisibleText1 := true;
            2:
                VisibleText2 := true;
            3:
                VisibleText3 := true;
            4:
                VisibleText4 := true;
            5:
                VisibleText5 := true;
        end;
    end;

    var
        ArrayOfText: array[5] of Text;
        TextCaption: array[5] of Text;
        WSCCode: Code[20];
        FinalEndpointString: Text;
        RealEndpointString: Text;
        VisibleText1: Boolean;
        VisibleText2: Boolean;
        VisibleText3: Boolean;
        VisibleText4: Boolean;
        VisibleText5: Boolean;
        TextCounter: Integer;
}