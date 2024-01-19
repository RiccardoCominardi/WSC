/// <summary>
/// Table WSC Charts Setup (ID 81012).
/// </summary>
table 81012 "WSC Charts Setup"
{
    Caption = 'Charts Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "WSC User ID"; Text[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(2; "WSC Top Calls Chart Types"; Enum "Business Chart Type")
        {
            Caption = 'Top Calls - Chart Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "WSC User ID")
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
    begin

    end;

    trigger OnRename()
    begin

    end;

}