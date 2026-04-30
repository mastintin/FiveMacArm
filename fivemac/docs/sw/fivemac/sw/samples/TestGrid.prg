#include "swfive.ch"
 
 function Main()
    HSW_START_SWIFT( "AppMain" )
 return nil

 function AppMain()
 
    local oWnd, oGrid, oRow
    local aColors := { "#FF5733", "#33FF57", "#3357FF", "#F333FF", "#33FFF3", "#F3FF33", "#FF3380", "#8033FF" }
    local n
 
    DEFINE WINDOW oWnd TITLE "SwiftUI Grid Test" SIZE 600, 500
 
    @ 460, 20 SAY "Responsive Adaptive Grid (Min 120px):" OF oWnd SIZE 300, 20
 
    // Grid con columnas adaptativas (mínimo 120px)
    @ 50, 20 GRID oGrid OF oWnd SIZE 560, 400 COLUMNS { { "adaptive", 120 } } ANCHOR 15
 
    for n := 1 to 24
       oRow := oGrid:AddRow()
       
       // Una celda de color con un número
       @ 0, 0 SAY AllTrim(Str(n)) OF oRow SIZE 120, 100
       oRow:SetColor( aColors[ (n % 8) + 1 ] )
    next
 
    ACTIVATE WINDOW oWnd CENTERED
 
 return nil
