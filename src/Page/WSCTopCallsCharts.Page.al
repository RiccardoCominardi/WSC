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
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    UpdateChart();
                end;

                trigger Refresh()
                begin
                    UpdateChart();
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
                    UpdateChart();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Initialize();
    end;

    var
        ChartsManagements: Codeunit "WSC Charts Managements";

    /// <summary>
    /// UpdateChart.
    /// </summary>
    procedure UpdateChart()
    begin
        ChartsManagements.GenerateData(Rec);
        Rec.Update(CurrPage.BusinessChart);
    end;
}