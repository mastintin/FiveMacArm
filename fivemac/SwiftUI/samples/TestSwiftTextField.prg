#include "FiveMac.ch"

function Main()

    local oWnd, oGet1, oGet2, oSay1, oSay2
    local cText1 := "Hello SwiftUI"
    local cText2 := "Standard Text 2"

    NSLog( "--- App Starting ---" )

    DEFINE WINDOW oWnd TITLE "SwiftUI Native TextField Test" ;
        SIZE 400, 350

    @ 20, 20 SAY "Standalone TextField (Absolute Position):" SIZE 300, 20 OF oWnd

    oGet1 := TSwiftTextField():New( 50, 20, 360, 24, cText1, "Type something...", oWnd, ;
        {|cValue| oSay1:SetText( "Value 1: " + cValue ) } )

    @ 80, 20 SAY oSay1 PROMPT "Value 1: " + cText1 SIZE 360, 20 OF oWnd

    oGet2 := TSwiftTextField():New( 110, 20, 360, 24, cText2, "Password or more text...", oWnd, ;
        {|cValue| oSay2:SetText( "Value 2: " + cValue ) } )

    @ 140, 20 SAY oSay2 PROMPT "Value 2: " + cText2 SIZE 360, 20 OF oWnd
   
    @ 180, 20 BUTTON "Set Text 1" SIZE 100, 30 OF oWnd ACTION ( oGet1:SetText( "Hi #1!" ) )
    @ 180, 130 BUTTON "Get Text 1" SIZE 100, 30 OF oWnd ACTION ( MsgInfo( "Get 1: '" + oGet1:GetText() + "'" ) )

    @ 220, 20 BUTTON "Set Text 2" SIZE 100, 30 OF oWnd ACTION ( oGet2:SetText( "Hi #2!" ) )
    @ 220, 130 BUTTON "Get Text 2" SIZE 100, 30 OF oWnd ACTION ( MsgInfo( "Get 2: '" + oGet2:GetText() + "'" ) )
   
    @ 270, 150 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION ( oWnd:End() )

    ACTIVATE WINDOW oWnd CENTERED

return nil
