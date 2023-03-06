/// <summary>
/// Enum WSC Body Types (ID 81003).
/// </summary>
enum 81003 "WSC Body Types"
{
    Extensible = true;

    value(0; none)
    {
        Caption = 'None';
    }
    value(1; "form data")
    {
        Caption = 'Form Data';
    }
    value(2; "x-www-form-urlencoded")
    {
        Caption = 'x-www-form-urlencoded';
    }
    value(3; raw)
    {
        Caption = 'Raw';
    }
    value(4; binary)
    {
        Caption = 'Binary';
    }
    value(5; GraphQL)
    {
        Caption = 'GraphQL';
    }
}