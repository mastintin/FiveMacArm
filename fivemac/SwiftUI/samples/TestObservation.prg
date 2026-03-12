#include "FiveMac.ch"
#include "SwiftControls.ch"
function Main()

    local oWnd, oObs
    local osay1

    DEFINE WINDOW oWnd TITLE "SwiftUI Bidirectional Observation" ;
        SIZE 400, 550

    oObs := SwiftObservation():New()
    
    // Create the reactive view
    oObs:CreateView( 20, 20, 360, 300, oWnd )
    
    // Handle actions coming from Swift!
    oObs:bAction = { | cAction | HandleSwiftAction( cAction, oObs, oWnd ) }

    @ 345, 20 BUTTON "Set Msg from Harbour" SIZE 200, 30 OF oWnd ;
        ACTION oObs:SetMsg( "Last Update: " + Time() )

    @ 385, 20 BUTTON "Reset Count (0)" SIZE 200, 30 OF oWnd ;
        ACTION oObs:SetCount( 0 )

    @ 425, 20 BUTTON "Check All Status" SIZE 200, 30 OF oWnd ;
        ACTION MsgInfo( "Count: " + Str( oObs:GetCount() ) + CRLF + ;
        "Level: " + Str( oObs:GetLevel() ) + CRLF + ;
        "Enabled: " + iif( oObs:GetEnabled(), "Yes", "No" ), "Harbour Report" )

    @ 480, 20 SWIFTSAY oSay1 PROMPT "Bidirectional Loop Active!" SIZE 300, 40 OF oWnd


    ACTIVATE WINDOW oWnd CENTERED

return nil

// ---------------------------------------------------------

static function HandleSwiftAction( cAction, oObs, oWnd )

    local cInfo := ""
    
    do case
        case cAction == "count_changed"
            cInfo := "Count is now: " + AllTrim( Str( oObs:GetCount() ) )
            
        case cAction == "level_changed"
            cInfo := "Level is now: " + AllTrim( Str( oObs:GetLevel() ) ) + "%"
            
        case cAction == "toggle_changed"
            cInfo := "System " + iif( oObs:GetEnabled(), "ENABLED", "DISABLED" )
    endcase
    
    if ! Empty( cInfo )
        oWnd:SetTitle( "Swift Event: " + cInfo )
    endif

return nil
