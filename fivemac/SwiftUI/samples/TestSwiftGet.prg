#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oGet1, oGet2, oSay1, oSay2
    local cText1 := "Auto-Batch 1"
    local cText2 := "Auto-Batch 2"

    DEFINE WINDOW oWnd TITLE "SwiftUI SWIFTGET Test" ;
        SIZE 400, 400

    @ 20, 20 SWIFTSAY "Using the NEW @ ... SWIFTGET command:" SIZE 360, 20 OF oWnd

    // No need to create oBatch anymore!
    @ 60, 20 SWIFTGET oGet1 PROMPT cText1 PLACEHOLDER "Type..." ;
        ON CHANGE { |cVal| oSay1:SetText( "Value 1: " + cVal ) } ;
        OF oWnd

    @ 150, 20 SWIFTGET oGet2 PROMPT cText2 PLACEHOLDER "Type more..." ;
        ON CHANGE { |cVal| oSay2:SetText( "Value 2: " + cVal ) } ;
        OF oWnd

    @ 90, 20 SWIFTSAY oSay1 PROMPT "Value 1: " + cText1 SIZE 360, 20 OF oWnd
    @ 180, 20 SWIFTSAY oSay2 PROMPT "Value 2: " + cText2 SIZE 360, 20 OF oWnd

    @ 230, 20 SWIFTBUTTON "Set Text 1" SIZE 100, 30 OF oWnd ACTION ( oGet1:SetText( "It works!" ) )
    @ 230, 130 SWIFTBUTTON "Get Text 2" SIZE 100, 30 OF oWnd ACTION ( MsgInfo( "Get 2: '" + oGet2:GetText() + "'" ) )
    
    @ 300, 150 SWIFTBUTTON "Close" SIZE 100, 30 OF oWnd ACTION ( oWnd:End() )

    // No need to call oBatch:Create() anymore!
    ACTIVATE WINDOW oWnd CENTERED

return nil
