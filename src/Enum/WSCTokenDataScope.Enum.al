/// <summary>
/// Enum WSC Token DataScope (ID 81005).
/// </summary>
enum 81005 "WSC Token DataScope"
{
    Extensible = true;

    value(0; Module)
    {
        Caption = 'Module';
    }
    value(1; User)
    {
        Caption = 'User';
    }
    value(2; Company)
    {
        Caption = 'Company';
    }
    value(3; UserAndCompany)
    {
        Caption = 'UserAndCompany';
    }
}