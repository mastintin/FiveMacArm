#include "FiveMac.ch"

function Main()

    local oWnd, oGet1, oGet2, oSay1, oSay2
    local oBatch
    local cText1 := "Batch Field 1"
    local cText2 := "Batch Field 2"

    NSLog( "--- App Starting ---" )

    DEFINE WINDOW oWnd TITLE "SwiftUI Standalone Batch Test" ;
        SIZE 400, 400

    @ 20, 20 SAY "These controls are created in a SINGLE BATCH:" SIZE 300, 20 OF oWnd

    oBatch := TSwiftBatch():New( oWnd )

    oGet1 := TSwiftTextField():New( 60, 20, 360, 24, cText1, "Batch 1...", oWnd, ;
        {|cValue| oSay1:SetText( "Value 1: " + cValue ) }, "ID1", oBatch )

    oGet2 := TSwiftTextField():New( 150, 20, 360, 24, cText2, "Batch 2...", oWnd, ;
        {|cValue| oSay2:SetText( "Value 2: " + cValue ) }, "ID2", oBatch )

    @ 90, 20 SAY oSay1 PROMPT "Value 1: " + cText1 SIZE 360, 20 OF oWnd
    @ 180, 20 SAY oSay2 PROMPT "Value 2: " + cText2 SIZE 360, 20 OF oWnd

    @ 230, 20 BUTTON "Set Text 1" SIZE 100, 30 OF oWnd ACTION ( oGet1:SetText( "Batch Update!" ) )
    @ 230, 130 BUTTON "Get Text 2" SIZE 100, 30 OF oWnd ACTION ( MsgInfo( "Get 2: '" + oGet2:GetText() + "'" ) )
   
    @ 300, 150 BUTTON "Close" SIZE 100, 30 OF oWnd ACTION ( oWnd:End() )

    oBatch:Create()

    ACTIVATE WINDOW oWnd CENTERED

return nil
