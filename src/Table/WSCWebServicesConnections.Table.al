/// <summary>
/// Table WSC Web Services Connections (ID 81001).
/// </summary>
table 81001 "WSC Web Services Connections"
{
    Caption = 'Web Services Connections';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Conn. List";
    LookupPageId = "WSC Web Services Conn. List";

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
                            Rec."WSC Password" := '';
                        end;
                    "WSC Authorization Types"::basic:
                        Rec."WSC Convert Auth. Base64" := true;
                end;
            end;
        }
        field(6; "WSC Username"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Username';
        }
        field(7; "WSC Password"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Password';
        }
        field(8; "WSC Access Token"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Acces Token';
        }
        field(9; "WSC Refresh Token"; Blob)
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
            TableRelation = "WSC Web Services Connections"."WSC Code" where("WSC Bearer Connection" = const(true));
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
        field(16; "WSC Convert Auth. Base64"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Convert Auth. Base64';
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
            TableRelation = "WSC Web Services Group Codes"."WSC Code";
            trigger OnValidate()
            var
                WSCWSServicesConnections: Record "WSC Web Services Connections";
                Text000Err: Label 'Is not possible to change Group Code if there is a linked Token. Clear first the linked Token value';
            begin
                if Rec."WSC Bearer Connection" then begin
                    WSCWSServicesConnections.Reset();
                    WSCWSServicesConnections.SetRange("WSC Bearer Connection Code", Rec."WSC Code");
                    WSCWSServicesConnections.ModifyAll("WSC Group Code", Rec."WSC Group Code");
                end else
                    if Rec."WSC Bearer Connection Code" <> '' then
                        if WSCWSServicesConnections.Get(Rec."WSC Bearer Connection Code") then
                            if WSCWSServicesConnections."WSC Group Code" <> Rec."WSC Group Code" then
                                Error(Text000Err);

            end;
        }
    }

    keys
    {
        key(Key1; "WSC Code")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        WSCWSServicesHeaders: Record "WSC Web Services Headers";
        WSCWSServicesBodies: Record "WSC Web Services Bodies";
        WSCWSServicesLogCalls: Record "WSC Web Services Log Calls";
    begin
        WSCWSServicesHeaders.Reset();
        WSCWSServicesHeaders.SetRange("WSC Code", Rec."WSC Code");
        WSCWSServicesHeaders.DeleteAll();

        WSCWSServicesBodies.Reset();
        WSCWSServicesBodies.SetRange("WSC Code", Rec."WSC Code");
        WSCWSServicesBodies.DeleteAll();

        WSCWSServicesLogCalls.Reset();
        WSCWSServicesLogCalls.SetRange("WSC Code", Rec."WSC Code");
        WSCWSServicesLogCalls.DeleteAll(true);
    end;

    trigger OnRename()
    begin

    end;

}