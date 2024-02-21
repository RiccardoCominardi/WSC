/// <summary>
/// Report WSC Copy Request Details (ID 81001).
/// </summary>
report 81001 "WSC Copy Request Details"
{
    Caption = 'Copy Request Details';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = where(Number = const(1));
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

        CopyParametersFunction();
        CopyHeadersFunction();
        CopyBodiesFunction();
    end;

    /// <summary>
    /// SetCurrentWSCode.
    /// </summary>
    /// <param name="WSCode">Code[20].</param>
    procedure SetCurrentWSCode(WSCode: Code[20])
    begin
        CurrWSCode := WSCode;
    end;

    /// <summary>
    /// SetParameters.
    /// </summary>
    /// <param name="Parameters">Boolean.</param>
    /// <param name="Headers">Boolean.</param>
    /// <param name="Bodies">Boolean.</param>
    procedure SetParameters(Parameters: Boolean; Headers: Boolean; Bodies: Boolean)
    begin
        CopyParameters := Parameters;
        CopyHeaders := Headers;
        CopyBodies := Bodies;
    end;

    local procedure CopyParametersFunction()
    var
        FromParameters: Record "WSC Parameters";
        Parameters: Record "WSC Parameters";
        Text000Qst: Label '%1 already exist in destination record. Do you want to delete and recreate all?';
    begin
        if not CopyHeaders then
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

    local procedure CopyHeadersFunction()
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

    local procedure CopyBodiesFunction()
    var
        FromBodies: Record "WSC Bodies";
        Bodies: Record "WSC Bodies";
        Text000Qst: Label '%1 already exist in destination record. Do you want to delete and recreate all?';
    begin
        if not CopyHeaders then
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
        CopyParameters: Boolean;
        CopyHeaders: Boolean;
        CopyBodies: Boolean;
        CopyOnlyEnabled: Boolean;
        CopyFromWSCode: Code[20];
        CurrWSCode: Code[20];
}