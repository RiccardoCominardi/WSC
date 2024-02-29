report 81001 "WSC Copy Request Details"
{
    Caption = 'Copy Request Details';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {

                group(GroupName)
                {
                    ShowCaption = false;
                    field(CopyFromWSCode; CopyFromWSCode)
                    {
                        ApplicationArea = All;
                        Caption = 'From WS Code';
                        TableRelation = "WSC Connections"."WSC Code";
                    }
                }
                group(Options)
                {
                    Caption = 'Copy';
                    field(CopyFunctions; CopyFunctions)
                    {
                        Caption = 'Functions';
                        ApplicationArea = All;
                    }
                    field(CopyCredentials; CopyCredentials)
                    {
                        Caption = 'Credentials';
                        ApplicationArea = All;
                    }
                    field(CopyParameter; CopyParameters)
                    {
                        Caption = 'Parameters';
                        ApplicationArea = All;
                    }
                    field(CopyHeader; CopyHeaders)
                    {
                        Caption = 'Headers';
                        ApplicationArea = All;
                    }
                    field(CopyBody; CopyBodies)
                    {
                        Caption = 'Bodies';
                        ApplicationArea = All;
                    }
                    field(CopyOnlyEnabled; CopyOnlyEnabled)
                    {
                        ApplicationArea = All;
                        Caption = 'Copy Only Enabled';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        Connections: Record "WSC Connections";
        FromConnections: Record "WSC Connections";
        Text000Err: Label 'You must specify where to get and set the details';
        Text001Err: Label 'Is not possible to copy details from the same connections';
    begin
        if (CurrWSCode = '') or (CopyFromWSCode = '') then
            Error(Text000Err);
        if CopyFromWSCode = CurrWSCode then
            Error(Text001Err);

        FromConnections.Get(CopyFromWSCode);
        Connections.Get(CurrWSCode);

        DoCopyCredentials();
        DoCopyFunctions();
        DoCopyParameters();
        DoCopyHeaders();
        DoCopyBodies();
    end;

    procedure SetCurrentWSCode(WSCode: Code[20])
    begin
        CurrWSCode := WSCode;
    end;

    procedure SetFromWSCode(WSCode: Code[20])
    begin
        CopyFromWSCode := WSCode;
    end;

    procedure SetParameters(Functions: Boolean; Credentials: Boolean; Parameters: Boolean; Headers: Boolean; Bodies: Boolean)
    begin
        CopyFunctions := Functions;
        CopyCredentials := Credentials;
        CopyParameters := Parameters;
        CopyHeaders := Headers;
        CopyBodies := Bodies;
    end;

    local procedure DoCopyCredentials()
    var
        FromConnections: Record "WSC Connections";
        Connections: Record "WSC Connections";
        SecurityManagements: Codeunit "WSC Security Managements";
    begin
        if not CopyCredentials then
            exit;

        Connections.Get(CurrWSCode);
        FromConnections.Get(CopyFromWSCode);

        Connections."WSC Auth. Type" := FromConnections."WSC Auth. Type";
        Connections."WSC Username" := FromConnections."WSC Username";
        Connections."WSC Password" := FromConnections."WSC Password";
        Connections."WSC Bearer Connection Code" := FromConnections."WSC Bearer Connection Code";
        Connections.Modify();
    end;

    local procedure DoCopyFunctions()
    var
        FromFunctions: Record "WSC Functions";
        Functions: Record "WSC Functions";
        Text000Qst: Label '%1 already exist in destination record. Do you want to delete and recreate all?';
    begin
        if not CopyFunctions then
            exit;

        Functions.Reset();
        Functions.SetRange("WSC Connection Code", CurrWSCode);
        if not Functions.IsEmpty() then
            if not Confirm(StrSubstNo(Text000Qst, Functions.TableCaption()), false) then
                exit;

        Functions.DeleteAll();

        FromFunctions.Reset();
        FromFunctions.SetRange("WSC Connection Code", CopyFromWSCode);
        if CopyOnlyEnabled then
            FromFunctions.SetRange("WSC Enabled", true);
        if FromFunctions.IsEmpty() then
            exit;

        FromFunctions.FindSet();
        repeat
            Functions.Init();
            Functions.TransferFields(FromFunctions);
            Functions."WSC Connection Code" := CurrWSCode;
            Functions.Insert();
        until FromFunctions.Next() = 0;
    end;

    local procedure DoCopyParameters()
    var
        FromParameters: Record "WSC Parameters";
        Parameters: Record "WSC Parameters";
        Text000Qst: Label '%1 already exist in destination record. Do you want to delete and recreate all?';
    begin
        if not CopyParameters then
            exit;

        Parameters.Reset();
        Parameters.SetRange("WSC Code", CurrWSCode);
        if not Parameters.IsEmpty() then
            if not Confirm(StrSubstNo(Text000Qst, Parameters.TableCaption()), false) then
                exit;

        Parameters.DeleteAll();

        FromParameters.Reset();
        FromParameters.SetRange("WSC Code", CopyFromWSCode);
        if CopyOnlyEnabled then
            FromParameters.SetRange("WSC Enabled", true);
        if FromParameters.IsEmpty() then
            exit;

        FromParameters.FindSet();
        repeat
            Parameters.Init();
            Parameters.TransferFields(FromParameters);
            Parameters."WSC Code" := CurrWSCode;
            Parameters.Insert();
        until FromParameters.Next() = 0;
    end;

    local procedure DoCopyHeaders()
    var
        FromHeaders: Record "WSC Headers";
        Headers: Record "WSC Headers";
        Text000Qst: Label '%1 already exist in destination record. Do you want to delete and recreate all?';
    begin
        if not CopyHeaders then
            exit;

        Headers.Reset();
        Headers.SetRange("WSC Code", CurrWSCode);
        if not Headers.IsEmpty() then
            if not Confirm(StrSubstNo(Text000Qst, Headers.TableCaption()), false) then
                exit;

        Headers.DeleteAll();

        FromHeaders.Reset();
        FromHeaders.SetRange("WSC Code", CopyFromWSCode);
        if CopyOnlyEnabled then
            FromHeaders.SetRange("WSC Enabled", true);
        if FromHeaders.IsEmpty() then
            exit;

        FromHeaders.FindSet();
        repeat
            Headers.Init();
            Headers.TransferFields(FromHeaders);
            Headers."WSC Code" := CurrWSCode;
            Headers.Insert();
        until FromHeaders.Next() = 0;
    end;

    local procedure DoCopyBodies()
    var
        FromBodies: Record "WSC Bodies";
        Bodies: Record "WSC Bodies";
        Text000Qst: Label '%1 already exist in destination record. Do you want to delete and recreate all?';
    begin
        if not CopyBodies then
            exit;

        Bodies.Reset();
        Bodies.SetRange("WSC Code", CurrWSCode);
        if not Bodies.IsEmpty() then
            if not Confirm(StrSubstNo(Text000Qst, Bodies.TableCaption()), false) then
                exit;

        Bodies.DeleteAll();

        FromBodies.Reset();
        FromBodies.SetRange("WSC Code", CopyFromWSCode);
        if CopyOnlyEnabled then
            FromBodies.SetRange("WSC Enabled", true);
        if FromBodies.IsEmpty() then
            exit;

        FromBodies.FindSet();
        repeat
            Bodies.Init();
            Bodies.TransferFields(FromBodies);
            Bodies."WSC Code" := CurrWSCode;
            Bodies.Insert();
        until FromBodies.Next() = 0;
    end;

    var
        CopyCredentials,
        CopyFunctions,
        CopyParameters,
        CopyHeaders,
        CopyBodies,
        CopyOnlyEnabled : Boolean;
        CopyFromWSCode,
        CurrWSCode : Code[20];
}