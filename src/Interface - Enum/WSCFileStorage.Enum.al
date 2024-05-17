enum 81010 "WSC File Storage" implements "WSC Log Files Handler"
{
    Extensible = true;

    value(0; Application)
    {
        Implementation = "WSC Log Files Handler" = "WSC Application Storage";
    }
    value(1; Sharepoint)
    {
        Implementation = "WSC Log Files Handler" = "WSC Sharepoint Storage";
    }
    value(2; "Azure Blob")
    {
        Implementation = "WSC Log Files Handler" = "WSC Azure Blob Storage";
    }
}