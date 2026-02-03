#include "FiveMac.ch"
#include "Nice.ch"

function Main()

    local oWnd, oPage
    local oChart
    local hOption := {=>}
    local hTitle := {=>}
    local hTooltip := {=>}
    local hXAxis := {=>}
    local hYAxis := {=>}
    local hSeries := {=>}
    local aData := { 5, 20, 36, 10, 10, 20 }

    DEFINE WINDOW oWnd TITLE "FiveMac NiceChart Demo" SIZE 800, 600

    oPage = TNicePage():New( oWnd )
   
    // Chart Configuration (JSON structure)
    hTitle["text"] := "ECharts Entry Example"
    hOption["title"] := hTitle
   
    hTooltip["trigger"] := "axis"
    hOption["tooltip"] := hTooltip
   
    hXAxis["data"] := { "Shirt", "Cardigan", "Chiffon", "Pants", "Heels", "Socks" }
    hOption["xAxis"] := hXAxis
   
    hYAxis["type"] := "value"
    hOption["yAxis"] := hYAxis
   
    hSeries["name"] := "sales"
    hSeries["type"] := "bar"
    hSeries["data"] := aData
   
    hOption["series"] := { hSeries }

    oChart := TNiceChart():New( oPage, hOption )
   
    oPage:Activate()

    ACTIVATE WINDOW oWnd

return nil
