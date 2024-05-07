table 81001 "WSC Connections"
{
    Caption = 'Web Services - Connections';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Connections List";
    LookupPageId = "WSC Connections List";

    fields
    {
        field(1; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            NotBlank = true;
            trigger OnValidate()
            var
                Text000Err: Label 'Is not possible to use char ":"';
            begin
                if StrPos(Rec."WSC Code", ':') > 0 then
                    Error(Text000Err);
            end;
        }
        field(2; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "WSC HTTP Method"; Enum "WSC HTTP Methods")
        {
            DataClassification = CustomerContent;
            Caption = 'HTTP Method';
        }
        field(4; "WSC EndPoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint';
        }
        field(5; "WSC Auth. Type"; Enum "WSC Authorization Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Auth. Type';
            trigger OnValidate()
            begin
                case Rec."WSC Auth. Type" of
                    "WSC Authorization Types"::none, "WSC Authorization Types"::"bearer token":
                        begin
                            Rec."WSC Username" := '';
                            Clear(Rec."WSC Password");
                        end;
                end;
            end;
        }
        field(6; "WSC Username"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Username';
        }
        field(7; "WSC Password"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Password';
        }
        field(8; "WSC Access Token"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Acces Token';
        }
        field(9; "WSC Refresh Token"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Refresh Token';
        }
        field(10; "WSC Expires In"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Expires In';
        }
        field(11; "WSC Authorization Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Authorization Time';
        }
        field(12; "WSC Bearer Connection"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Bearer Connection';
            trigger OnValidate()
            begin
                if "WSC Bearer Connection" then
                    TestField("WSC Bearer Connection Code", '');
            end;
        }
        field(13; "WSC Bearer Connection Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bearer Connection Code';
            TableRelation = "WSC Connections"."WSC Code" where("WSC Bearer Connection" = const(true));
            trigger OnValidate()
            begin
                if "WSC Bearer Connection" then
                    TestField("WSC Bearer Connection Code", '');
            end;
        }
        field(14; "WSC Body Type"; Enum "WSC Body Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Body Type';
        }
        field(15; "WSC Body Message"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Body Message';
        }
        field(17; "WSC Allow Blank Response"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Blank Response';
        }
        field(18; "WSC Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Group Code';
            TableRelation = "WSC Connections"."WSC Code" where("WSC Type" = const("WSC Types"::Group));
            trigger OnValidate()
            begin
                CheckOnChangeGrouCode();
                SetIndentation();
            end;
        }
        field(19; "WSC Body Method"; Enum "WSC Body Methods")
        {
            DataClassification = CustomerContent;
            Caption = 'Body Method';
        }
        field(20; "WSC Imported"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Imported';
        }
        field(21; "WSC Previous Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Previous Code';
        }
        field(22; "WSC Zip Response"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Zip Response';
        }
        field(23; "WSC Token DataScope"; Enum "WSC Token DataScope")
        {
            DataClassification = CustomerContent;
            Caption = 'Token DataScope';
        }
        field(24; "WSC Store Headers Datas"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Store Header Datas';
            trigger OnValidate()
            begin
                if not xRec."WSC Store Headers Datas" and Rec."WSC Store Headers Datas" then
                    if not Confirm(Text000Qst, false) then
                        Error('');
            end;
        }
        field(25; "WSC Store Body Datas"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Store Body Datas';
            trigger OnValidate()
            begin
                if not xRec."WSC Store Body Datas" and Rec."WSC Store Body Datas" then
                    if not Confirm(Text000Qst, false) then
                        Error('');
            end;
        }
        field(26; "WSC Store Parameters Datas"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Store Parameters Datas';
            trigger OnValidate()
            begin
                if not xRec."WSC Store Parameters Datas" and Rec."WSC Store Parameters Datas" then
                    if not Confirm(Text000Qst, false) then
                        Error('');
            end;
        }
        field(27; "WSC Type"; Enum "WSC Types")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."WSC Type" = Rec."WSC Type"::Token then
                    Rec."WSC Bearer Connection" := true
                else
                    Rec."WSC Bearer Connection" := false;

                SetIndentation();
            end;
        }
        field(28; "WSC Indentation"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Indentation';
        }
    }

    keys
    {
        key(Key1; "WSC Code")
        {
            Clustered = true;
        }
        key(Key2; "WSC Group Code", "WSC Indentation", "WSC Type", "WSC Code")
        {
        }
    }

    var
        Text000Qst: Label 'Are you sure you want to archive the data? This may affect performance and safety. Continue?';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        Connections: Record "WSC Connections";
        Parameters: Record "WSC Parameters";
        Headers: Record "WSC Headers";
        Bodies: Record "WSC Bodies";
        LogCalls: Record "WSC Log Calls";
        Functions: Record "WSC Functions";
        SecurityManagements: Codeunit "WSC Security Managements";
        Text000Qst: Label 'Deleting a Group will be delete each connections inside the group. Continue?';
    begin
        if Rec."WSC Type" = Rec."WSC Type"::Group then begin
            if not Confirm(Text000Qst, false) then
                Error('');

            Connections.Reset();
            Connections.SetRange("WSC Group Code", Rec."WSC Code");
            Connections.SetFilter("WSC Code", '<> %1', Rec."WSC Code");
            Connections.DeleteAll(true);
        end;

        if Rec."WSC Bearer Connection" then begin
            Connections.Reset();
            Connections.SetRange("WSC Bearer Connection Code", Rec."WSC Code");
            Connections.ModifyAll("WSC Bearer Connection Code", '');
        end;

        Functions.Reset();
        Functions.SetRange("WSC Connection Code", Rec."WSC Code");
        Functions.DeleteAll();

        Parameters.Reset();
        Parameters.SetRange("WSC Code", Rec."WSC Code");
        Parameters.DeleteAll();

        Headers.Reset();
        Headers.SetRange("WSC Code", Rec."WSC Code");
        Headers.DeleteAll();

        Bodies.Reset();
        Bodies.SetRange("WSC Code", Rec."WSC Code");
        Bodies.DeleteAll();

        LogCalls.Reset();
        LogCalls.SetRange("WSC Code", Rec."WSC Code");
        LogCalls.DeleteAll(true);

        SecurityManagements.DeleteToken(Rec."WSC Access Token", GetTokenDataScope());
        SecurityManagements.DeleteToken(Rec."WSC Refresh Token", GetTokenDataScope());
        SecurityManagements.DeleteToken(Rec."WSC Password", GetTokenDataScope());
    end;

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

    procedure CopyAndPasteDataOnSubGroup()
    var
        CopyRequestDetails: Report "WSC Copy Request Details";
        Text000Qst: Label 'Do you want to copy the information (Credentials, Functions, Parameters, Header, Body) from the group %1?';
    begin
        if Rec."WSC Group Code" = '' then
            exit;

        if not (Rec."WSC Type" in [Rec."WSC Type"::Call, Rec."WSC Type"::Token]) then
            exit;

        if not Confirm(StrSubstNo(Text000Qst, Rec."WSC Group Code")) then
            exit;

        CopyRequestDetails.SetCurrentWSCode(Rec."WSC Code");
        CopyRequestDetails.SetFromWSCode(Rec."WSC Group Code");
        CopyRequestDetails.SetParameters(true, true, true, true, true);
        CopyRequestDetails.UseRequestPage(false);
        CopyRequestDetails.RunModal();
    end;

    local procedure SetIndentation()
    begin
        case Rec."WSC Type" of
            Rec."WSC Type"::Group:
                begin
                    Rec."WSC Group Code" := Rec."WSC Code";
                    Rec."WSC Indentation" := 1;
                end;
            Rec."WSC Type"::Token,
            Rec."WSC Type"::Call:
                Rec."WSC Indentation" := 2;
        end;

        if Rec."WSC Type" <> Rec."WSC Type"::Group then
            if Rec."WSC Group Code" = '' then
                Rec."WSC Indentation" := 1;
    end;

    local procedure CheckOnChangeGrouCode()
    var
        Connections: Record "WSC Connections";
        Text000Err: Label 'Is not possible to change the Group if there is a call that use this Token';
        Text001Err: Label 'Is not possible to change Group Code if there is a linked Token. Clear first the linked Token value';
    begin
        case Rec."WSC Type" of
            "WSC Type"::Token:
                begin
                    Connections.Reset();
                    Connections.SetRange("WSC Bearer Connection Code", Rec."WSC Code");
                    Connections.ReadIsolation := IsolationLevel::ReadUncommitted;
                    if not Connections.IsEmpty() then
                        Error(Text000Err);
                end;
            "WSC Type"::Call:
                begin
                    if Rec."WSC Bearer Connection Code" <> '' then
                        if Connections.Get(Rec."WSC Bearer Connection Code") then
                            if Connections."WSC Group Code" <> Rec."WSC Group Code" then
                                Error(Text001Err);
                end;
        end;
    end;

    trigger OnRename()
    begin

    end;
}