#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oChart
    local aData := {;
        { "label" => "Mon", "value" => 10, "group" => "Sales" },;
        { "label" => "Tue", "value" => 20, "group" => "Sales" },;
        { "label" => "Wed", "value" => 15, "group" => "Sales" },;
        { "label" => "Thu", "value" => 30, "group" => "Sales" },;
        { "label" => "Fri", "value" => 25, "group" => "Sales" };
        }

    DEFINE WINDOW oWnd TITLE "Native Swift Charts (macOS 13+)" SIZE 600, 400 NOFLIPPED 

    @ 30, 20 SWIFTCHART oChart DATA aData TYPE "bar" SIZE 560, 300 OF oWnd

    @ 350, 20 BUTTON "Bar" ACTION oChart:SetType( "bar" ) SIZE 100, 30 OF oWnd
    @ 350, 130 BUTTON "Line" ACTION oChart:SetType( "line" ) SIZE 100, 30 OF oWnd
    @ 350, 240 BUTTON "Point" ACTION oChart:SetType( "point" ) SIZE 100, 30 OF oWnd
    @ 350, 350 BUTTON "Update Data" ACTION UpdateData( oChart ) SIZE 120, 30 OF oWnd

    ACTIVATE WINDOW oWnd

return nil

function UpdateData( oChart )
    local aNewData := {;
        { "label" => "Mon", "value" => hb_RandomInt( 5, 50 ), "group" => "Sales" },;
        { "label" => "Tue", "value" => hb_RandomInt( 5, 50 ), "group" => "Sales" },;
        { "label" => "Wed", "value" => hb_RandomInt( 5, 50 ), "group" => "Sales" },;
        { "label" => "Thu", "value" => hb_RandomInt( 5, 50 ), "group" => "Sales" },;
        { "label" => "Fri", "value" => hb_RandomInt( 5, 50 ), "group" => "Sales" };
        }
    oChart:SetData( aNewData )
return nil
