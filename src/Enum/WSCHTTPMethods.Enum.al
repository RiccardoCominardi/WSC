/// <summary>
/// Enum WSC HTTP Methods (ID 81001).
/// </summary>
enum 81001 "WSC HTTP Methods"
{
    Extensible = true;

    value(0; Get)
    {
        Caption = 'GET';
    }
    value(1; Post)
    {
        Caption = 'POST';
    }
    value(3; Put)
    {
        Caption = 'PUT';
    }
    value(4; Patch)
    {
        Caption = 'PATCH';
    }
    value(5; Delete)
    {
        Caption = 'DELETE';
    }
}