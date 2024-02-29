page 81012 "WSC Import Configuration"
{
    Caption = 'Import Configuration';
    PageType = List;
    SourceTable = "WSC Connections";
    SourceTableView = sorting("WSC Group Code", "WSC Indentation", "WSC Code");
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                IndentationColumn = Rec."WSC Indentation";
                IndentationControls = "WSC Description";
                ShowAsTree = true;
                field(WSCode; WSCode)
                {
                    ApplicationArea = All;
                    StyleExpr = LineColor;
                    Caption = 'Code';
                    trigger OnValidate()
                    begin
                        Rec."WSC Code" := WSCode;
                        if not IsCorrectConnession() then
                            Rec."WSC Imported" := false
                        else
                            Rec."WSC Imported" := true;
                    end;
                }
                field("WSC Description"; Rec."WSC Description")
                {
                    ApplicationArea = All;
                    StyleExpr = LineColor;
                    Editable = false;
                }
                /*
                field("WSC Imported"; Rec."WSC Imported")
                {
                    ApplicationArea = All;
                    StyleExpr = LineColor;
                    Caption = 'To Import';
                    trigger OnValidate()
                    begin
                        if not IsCorrectConnession() then
                            Rec."WSC Imported" := false;
                    end;
                }
                */
                field(CurrStatus; CurrStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = false;
                    StyleExpr = LineColor;
                }
                field(CurrMessage; CurrMessage)
                {
                    ApplicationArea = All;
                    Caption = 'Message';
                    Editable = false;
                    StyleExpr = LineColor;
                    trigger OnDrillDown()
                    begin
                        Message(CurrMessage);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IsCorrectConnession();
    end;

    local procedure IsCorrectConnession(): Boolean
    var
        Connections: Record "WSC Connections";
        Text000Err: Label 'Connection with code %1 already exist. Change the code to continue';
        Text001Err: Label 'Is not possible to use char ":"';
        Text000Lbl: Label 'Connection is importable';
    begin
        WSCode := Rec."WSC Code";
        CurrStatus := CurrStatus::Correct;
        CurrMessage := Text000Lbl;
        LineColor := 'Favorable';

        if StrPos(Rec."WSC Code", ':') > 0 then begin
            CurrStatus := CurrStatus::Error;
            CurrMessage := StrSubstNo(Text001Err);
            LineColor := 'Unfavorable';
            exit(false);
        end;

        if Connections.Get(Rec."WSC Code") then begin
            CurrStatus := CurrStatus::Error;
            CurrMessage := StrSubstNo(Text000Err, Rec."WSC Code");
            LineColor := 'Unfavorable';
            exit(false);
        end;

        exit(true);
    end;

    procedure SetConfiguration(var TempConnections: Record "WSC Connections" temporary)
    var
        Text000Lbl: Label 'Nothing to Import';
    begin
        TempConnections.Reset();
        if TempConnections.IsEmpty() then
            Error(Text000Lbl);
        TempConnections.FindSet();
        repeat
            Rec.Init();
            Rec.TransferFields(TempConnections);
            if IsCorrectConnession() then
                Rec."WSC Imported" := true;
            Rec.Insert();
        until TempConnections.Next() = 0;
    end;

    procedure GetConfiguration(var TempConnections: Record "WSC Connections" temporary)
    var
        Text000Lbl: Label 'Nothing to Import';
    begin
        Rec.Reset();
        Rec.SetRange("WSC Imported", true);
        if Rec.IsEmpty() then
            Error(Text000Lbl);

        Rec.FindSet();
        TempConnections.Reset();
        TempConnections.DeleteAll();
        repeat
            TempConnections.Init();
            TempConnections.TransferFields(Rec);
            TempConnections.Insert();
        until Rec.Next() = 0;
    end;

    var
        LineColor,
        CurrMessage : Text;
        WSCode: Code[20];
        CurrStatus: Option Error,Warning,Correct;
}