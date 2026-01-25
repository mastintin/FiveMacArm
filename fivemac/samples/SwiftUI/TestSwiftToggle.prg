#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local oWnd, oToggle, oLabel, oBtn
    local lVal := .F.

    DEFINE WINDOW oWnd TITLE "Testing SwiftToggle" SIZE 400, 300

    @ 20, 20 SWIFTLABEL oLabel PROMPT "Toggle is: OFF" SIZE 200, 30 OF oWnd

    @ 60, 20 SWIFTTOGGLE oToggle VAR lVal PROMPT "My Switch" SIZE 150, 40 OF oWnd ;
        SWITCH .T. ;
        ON CHANGE { |lOn| oLabel:SetText( "Toggle is: " + If( lOn, "ON", "OFF" ) ) }

    @ 110, 20 SWIFTBUTTON oBtn PROMPT "Toggle ON" SIZE 100, 30 OF oWnd ;
        ACTION { || oToggle:Set( .T. ) }

    ACTIVATE WINDOW oWnd
return nil
