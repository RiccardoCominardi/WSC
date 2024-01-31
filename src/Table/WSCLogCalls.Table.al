/// <summary>
/// Table WSC Log Calls (ID 81004).
/// </summary>
table 81004 "WSC Log Calls"
{
    Caption = 'Web Services - Log Calls';
    DataClassification = CustomerContent;
    DrillDownPageId = "WSC Log Calls";
    LookupPageId = "WSC Log Calls";

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
            TableRelation = "WSC Connections"."WSC Code";
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
            TableRelation = "WSC Connections"."WSC Code" where("WSC Bearer Connection" = const(true));
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
            TableRelation = "WSC Connections"."WSC Code";
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
        field(14; "WSC Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Group Code';
            TableRelation = "WSC Group Codes"."WSC Code";
        }
        field(15; "WSC Zip Response"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Zip Response';
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
        field(205; "WSC Body File Type"; Enum "WSC File Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Body File Type';
        }
        field(206; "WSC Response File Type"; Enum "WSC File Types")
        {
            DataClassification = CustomerContent;
            Caption = 'Response File Type';
        }
        field(207; "WSC Execution Time (ms)"; Duration)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Time (ms)';
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
        Text000Lbl: Label 'BodyMessage';
        Text001Lbl: Label 'ResponseMessage';
        Text002Lbl: Label 'ResponseMessage.zip';
    begin
        case FieldNo of
            Rec.FieldNo("WSC Body Message"):
                begin
                    FileName := Text000Lbl + RetrieveBodyFileExtension(false);
                    Rec.CalcFields("WSC Body Message");
                    if Rec."WSC Body Message".HasValue() then begin
                        Rec."WSC Body Message".CreateInStream(InStr);
                        DownloadFromStream(InStr, '', '', RetrieveBodyFileExtension(true), FileName);
                    end;
                end;
            Rec.FieldNo("WSC Response Message"):
                begin
                    Rec.CalcFields("WSC Response Message");
                    if Rec."WSC Response Message".HasValue() then begin
                        Rec."WSC Response Message".CreateInStream(InStr);
                        if Rec."WSC Zip Response" then begin
                            FileName := Text002Lbl;
                            DownloadFromStream(InStr, '', '', '*.zip', FileName)
                        end else begin
                            FileName := Text001Lbl + RetrieveResponseFileExtension(false);
                            DownloadFromStream(InStr, '', '', RetrieveResponseFileExtension(true), FileName);
                        end;
                    end;
                end;
        end;

    end;

    local procedure RetrieveBodyFileExtension(AsFilter: Boolean) RetText: Text
    begin
        if AsFilter then
            RetText := '*';

        case Rec."WSC Body File Type" of
            "WSC File Types"::" ",
            "WSC File Types"::Json:
                RetText += '.json';
            "WSC File Types"::Xml:
                RetText += '.xml';
            "WSC File Types"::Txt:
                RetText += '.txt';
        end;

        exit(RetText);
    end;

    local procedure RetrieveResponseFileExtension(AsFilter: Boolean) RetText: Text
    begin
        if AsFilter then
            RetText := '*';

        case Rec."WSC Response File Type" of
            "WSC File Types"::" ",
            "WSC File Types"::Json:
                RetText += '.json';
            "WSC File Types"::Xml:
                RetText += '.xml';
            "WSC File Types"::Txt:
                RetText += '.txt';
        end;

        exit(RetText);
    end;

    /// <summary>
    /// ViewLog.
    /// </summary>
    /// <param name="WSCCode">Code[20].</param>
    procedure ViewLog(WSCCode: Code[20])
    var
        Connections: Record "WSC Connections";
        LogCalls: Record "WSC Log Calls";
    begin
        Connections.Get(WSCCode);

        LogCalls.Reset();
        LogCalls.SetCurrentKey("WSC Execution Date-Time");
        LogCalls.FilterGroup(2);
        if Connections."WSC Bearer Connection Code" <> '' then
            LogCalls.SetFilter("WSC Code", '%1|%2', Connections."WSC Code", Connections."WSC Bearer Connection Code")
        else
            LogCalls.SetRange("WSC Code", Connections."WSC Code");
        LogCalls.FilterGroup(0);
        Page.RunModal(0, LogCalls);
    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        LogParameters: Record "WSC Log Parameters";
        LogHeaders: Record "WSC Log Headers";
        LogBodies: Record "WSC Log Bodies";
    begin
        LogParameters.Reset();
        LogParameters.SetRange("WSC Code", Rec."WSC Code");
        LogParameters.DeleteAll();

        LogHeaders.Reset();
        LogHeaders.SetRange("WSC Code", Rec."WSC Code");
        LogHeaders.DeleteAll();

        LogBodies.Reset();
        LogBodies.SetRange("WSC Code", Rec."WSC Code");
        LogBodies.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

}