/// <summary>
/// Page WSC Too Calls Charts (ID 81017).
/// </summary>
page 81017 "WSC Top Calls Charts"
{
    Caption = 'Top Calls';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(Content)
        {
            usercontrol(BusinessChart; BusinessChart)
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    UpdateAddin();
                end;

                trigger Refresh()
                begin
                    UpdateAddin();
                end;

                trigger DataPointClicked(point: JsonObject)
                var
                    JsonTokenXValueString: JsonToken;
                    XValueString: Text;
                begin
                    if point.Get('XValueString', JsonTokenXValueString) then begin
                        XValueString := Format(JsonTokenXValueString);
                        XValueString := DelChr(XValueString, '=', '"');
                        ChartsManagements.DrillDown(XValueString);
                    end;
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Chart Setup")
            {
                Caption = 'Chart Setup';
                ApplicationArea = All;
                Image = Setup;
                trigger OnAction()
                begin
                    Page.RunModal(Page::"WSC Charts Setup");
                    UpdateAddin();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Initialize();
    end;

    /// <summary>
    /// UpdateChart.
    /// </summary>
    procedure UpdateAddin()
    begin
        ChartsManagements.GenerateData(Rec);
        Rec.UpdateChart(CurrPage.BusinessChart);
    end;

    var
        ChartsManagements: Codeunit "WSC Charts Managements";
}