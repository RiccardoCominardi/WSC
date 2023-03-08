/// <summary>
/// Table WSC Web Services Log Calls (ID 81004).
/// </summary>
table 81004 "WSC Web Services Log Calls"
{
    Caption = 'Web Services Log Calls';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Web Services Log Calls";
    LookupPageId = "WSC Web Services Log Calls";

    fields
    {
        field(1; "WSC Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            TableRelation = "WSC Web Services Connections"."WSC Code";
        }
        field(3; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(4; "WSC HTTP Method"; Enum "WSC HTTP Methods")
        {
            DataClassification = CustomerContent;
            Caption = 'HTTP Method';
        }
        field(5; "WSC EndPoint"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'EndPoint';
        }
        field(6; "WSC Auth. Type"; Enum "WSC Authorization Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Auth. Type';
        }
        field(7; "WSC Bearer Connection"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Bearer Connection';
        }
        field(8; "WSC Bearer Connection Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Bearer Connection Code';
            TableRelation = "WSC Web Services Connections"."WSC Code" where("WSC Bearer Connection" = const(true));
        }
        field(9; "WSC Body Type"; Enum "WSC Body Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Body Type';
        }
        field(10; "WSC Body Message"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Body Message';
        }
        field(11; "WSC Link to WSC Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Link to WSC Code';
            TableRelation = "WSC Web Services Connections"."WSC Code";
        }
        field(12; "WSC Link To Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Link To Entry No';
        }
        field(13; "WSC Allow Blank Response"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Blank Response';
        }
        field(200; "WSC Response Message"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Response Message';
        }
        field(201; "WSC Message Text"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Message Text';
        }
        field(202; "WSC Result Status Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Result Status Code';
        }
        field(203; "WSC Execution Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Date-Time';
        }
        field(204; "WSC Execution UserID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Execution UserID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "WSC Code", "WSC Entry No.")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// ExportAttachment.
    /// </summary>
    /// <param name="FieldNo">Integer.</param>
    procedure ExportAttachment(FieldNo: Integer);
    var
        InStr: InStream;
        FileName: Text;
        Text000Lbl: Label 'BodyMessage.json';
        Text001Lbl: Label 'ResponseMessage.json';
    begin
        case FieldNo of
            Rec.FieldNo("WSC Body Message"):
                begin
                    FileName := Text000Lbl;
                    Rec.CalcFields("WSC Body Message");
                    if Rec."WSC Body Message".HasValue() then begin
                        Rec."WSC Body Message".CreateInStream(InStr);
                        DownloadFromStream(InStr, '', '', '*.json', FileName);
                    end;
                end;
            Rec.FieldNo("WSC Response Message"):
                begin
                    FileName := Text001Lbl;
                    Rec.CalcFields("WSC Response Message");
                    if Rec."WSC Response Message".HasValue() then begin
                        Rec."WSC Response Message".CreateInStream(InStr);
                        DownloadFromStream(InStr, '', '', '*.json', FileName);
                    end;
                end;
        end;

    end;

    /// <summary>
    /// ViewLog.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    procedure ViewLog(WSCCode: Code[20])
    var
        WSCWSServicesConnections: Record "WSC Web Services Connections";
        WSCWSServicesLogCalls: Record "WSC Web Services Log Calls";
    begin
        WSCWSServicesConnections.Get(WSCCode);

        WSCWSServicesLogCalls.Reset();
        WSCWSServicesLogCalls.SetCurrentKey("WSC Execution Date-Time");
        WSCWSServicesLogCalls.FilterGroup(2);
        if WSCWSServicesConnections."WSC Bearer Connection Code" <> '' then
            WSCWSServicesLogCalls.SetFilter("WSC Code", '%1|%2', WSCWSServicesConnections."WSC Code", WSCWSServicesConnections."WSC Bearer Connection Code")
        else
            WSCWSServicesLogCalls.SetRange("WSC Code", WSCWSServicesConnections."WSC Code");
        WSCWSServicesLogCalls.FilterGroup(0);
        Page.RunModal(0, WSCWSServicesLogCalls);
    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        WSCWSServicesLogHeaders: Record "WSC Web Services Log Headers";
        WSCWSServicesLogBodies: Record "WSC Web Services Log Bodies";
    begin
        WSCWSServicesLogHeaders.Reset();
        WSCWSServicesLogHeaders.SetRange("WSC Code", Rec."WSC Code");
        WSCWSServicesLogHeaders.DeleteAll();

        WSCWSServicesLogBodies.Reset();
        WSCWSServicesLogBodies.SetRange("WSC Code", Rec."WSC Code");
        WSCWSServicesLogBodies.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

}