/// <summary>
/// Table WSC Web Services EndPoint Var. (ID 81009).
/// </summary>
table 81009 "WSC Web Services EndPoint Var."
{
    DataClassification = CustomerContent;
    Caption = 'Web Services - EndPoint Variables';

    fields
    {
        field(1; "WSC Variable Name"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Variable Name';
            trigger OnValidate()
            begin
                CheckVarComposition(Rec."WSC Variable Name");
            end;
        }
        field(2; "WSC Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "WSC Custom Var"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Custom Variables';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "WSC Variable Name")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        Text000Err: Label 'Is not possible to delete standard variables';
    begin
        if not Rec."WSC Custom Var" then
            Error(Text000Err);
    end;

    trigger OnRename()
    begin

    end;

    local procedure CheckVarComposition(VarName: Text)
    var
        Text000Err: Label 'Variable Name must be prefixed by chars "[@"';
        Text001Err: Label 'Variable Name must be suffixed by char "]"';
    begin
        if CopyStr(VarName, 1, 2) <> '[@' then
            Error(Text000Err);
        if CopyStr(VarName, StrLen(VarName), 1) <> ']' then
            Error(Text001Err);
    end;

}