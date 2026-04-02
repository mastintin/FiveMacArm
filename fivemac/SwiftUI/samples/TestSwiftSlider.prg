#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local oWnd, oSlider, oSlider2, oLabel
    local obtn1, obtn2
    local nVal := 50

    DEFINE WINDOW oWnd TITLE "Testing SwiftSlider" SIZE 400, 300 GLASS NOFLIPPED 

    @ 20, 20 SWIFTLABEL oLabel PROMPT "Value: 70" SIZE 200, 30 OF oWnd

    @ 60, 20 SWIFTSLIDER oSlider VAR nVal SIZE 300, 40 OF oWnd ;
        ON CHANGE { |n| oLabel:SetText( "Value 1: " + AllTrim( Str( n ) ) ) }

    @ 110, 20 SWIFTSLIDER oSlider2 VAR nVal SIZE 300, 40 OF oWnd ;
        SHOWVALUE .F. ;
        GLASS .T. ;
        ON CHANGE { |n| oLabel:SetText( "Value 2 (Hidden): " + AllTrim( Str( n ) ) ) }

    @ 180, 20 SWIFTBUTTON obtn1 PROMPT "S1 -> 10" SIZE 100, 30 OF oWnd ;
        ACTION { || oSlider:SetValue( 10 ) }

    @ 180, 140 SWIFTBUTTON obtn2 PROMPT "S2 -> 90" SIZE 100, 30 OF oWnd ;
        ACTION { || oSlider2:SetValue( 90 ) }

    ACTIVATE WINDOW oWnd
return nil
