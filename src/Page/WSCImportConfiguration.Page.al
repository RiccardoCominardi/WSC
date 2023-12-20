/// <summary>
/// Page WSC Import Configuration (ID 81012).
/// </summary>
page 81012 "WSC Import Configuration"
{
    Caption = 'Import Configuration';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "WSC Web Services Connections";
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
        WebServicesConnections: Record "WSC Web Services Connections";
        Text000Err: Label 'Web Service Connection with code %1 already exist. Change the code to continue';
        Text000Lbl: Label 'Web Service Connection is importable';
    begin
        WSCode := Rec."WSC Code";
        CurrStatus := CurrStatus::Correct;
        CurrMessage := Text000Lbl;
        LineColor := 'Favorable';

        if WebServicesConnections.Get(Rec."WSC Code") then begin
            CurrStatus := CurrStatus::Error;
            CurrMessage := StrSubstNo(Text000Err, Rec."WSC Code");
            LineColor := 'Unfavorable';
            exit(false);
        end;

        exit(true);
    end;

    /// <summary>
    /// SetConfiguration.
    /// </summary>
    /// <param name="TempWebServicesConnections">Temporary VAR Record "WSC Web Services Connections".</param>
    procedure SetConfiguration(var TempWebServicesConnections: Record "WSC Web Services Connections" temporary)
    var
        Text000Lbl: Label 'Nothing to Import';
    begin
        TempWebServicesConnections.Reset();
        if TempWebServicesConnections.IsEmpty() then
            Error(Text000Lbl);
        TempWebServicesConnections.FindSet();
        repeat
            Rec.Init();
            Rec.TransferFields(TempWebServicesConnections);
            if IsCorrectConnession() then
                Rec."WSC Imported" := true;
            Rec.Insert();
        until TempWebServicesConnections.Next() = 0;
    end;

    /// <summary>
    /// GetConfiguration.
    /// </summary>
    /// <param name="TempWebServicesConnections">Temporary VAR Record "WSC Web Services Connections".</param>
    procedure GetConfiguration(var TempWebServicesConnections: Record "WSC Web Services Connections" temporary)
    var
        Text000Lbl: Label 'Nothing to Import';
    begin
        Rec.Reset();
        Rec.SetRange("WSC Imported", true);
        if Rec.IsEmpty() then
            Error(Text000Lbl);

        Rec.FindSet();
        TempWebServicesConnections.Reset();
        TempWebServicesConnections.DeleteAll();
        repeat
            TempWebServicesConnections.Init();
            TempWebServicesConnections.TransferFields(Rec);
            TempWebServicesConnections.Insert();
        until Rec.Next() = 0;
    end;

    var
        LineColor,
        CurrMessage : Text;
        WSCode: Code[20];
        CurrStatus: Option Error,Warning,Correct;
}