#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local oWnd, oBtn, oBtn2, oLabel,olabel2,oBtn3
    local lGlass := .t.

    DEFINE WINDOW oWnd TITLE "Standalone SwiftUI Test" SIZE 400, 400


    // Absolute positioning using @ row, col commands
    
    @ 50, 50 SWIFTLABEL oLabel PROMPT "I am a Standalone Label" ;
        SIZE 300, 40 OF oWnd


    @ 100, 50 SWIFTSAY oLabel2 PROMPT "I am a Second Label (SWIFTSAY)" ;
        SIZE 300, 40 OF oWnd

    @ 200, 50 SWIFTBUTTON oBtn PROMPT "Click Standalone Button" ;
        SIZE 200, 50 OF oWnd ;
        ACTION oLabel2:SetText( "Text Changed!2 " + Time() )

    // Check if we can change properties after creation
    @ 300, 50 SWIFTBUTTON oBtn2 PROMPT "Change Label Text" ;
        SIZE 200, 50 OF oWnd ;
        ACTION oLabel:SetText( "Text Changed! " + Time() )

    @ 350, 50 SWIFTBUTTON oBtn3 PROMPT "Change Button" ;
        SIZE 200, 50 OF oWnd ;
        ACTION ( lGlass := !lGlass , oBtn:SetGlass( lGlass ) )
        
    @ 420, 50 SWIFTGET oLabel PROMPT "I am a TextField" PLACEHOLDER "Type something..." ;
        SIZE 200, 40 OF oWnd

    ACTIVATE WINDOW oWnd
return nil
