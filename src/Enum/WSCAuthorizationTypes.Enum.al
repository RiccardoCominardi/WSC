/// <summary>
/// Enum WSC Authorization Types (ID 81002).
/// </summary>
enum 81002 "WSC Authorization Types"
{
    Extensible = true;

    value(0; none)
    {
        Caption = 'None';
    }
    value(1; basic)
    {
        Caption = 'Basic';
    }
    value(2; "bearer token")
    {
        Caption = 'Bearer Token';
    }

}
