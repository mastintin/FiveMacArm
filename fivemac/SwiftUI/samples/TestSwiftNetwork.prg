#include "FiveMac.ch"
#include "SwiftControls.ch"

//----------------------------------------------------------------------------//

function Main()

    local oWnd, oNet := TSwiftNetwork():New()
    local oSayConn, oSayIP
    local cUrl := "https://api.ipify.org?format=json"

    DEFINE WINDOW oWnd TITLE "SwiftUI Native Network Test" ;
        SIZE 450, 500

    @ 20, 20 SWIFTSAY "SwiftUI Network Implementation" SIZE 400, 30 OF oWnd

    @ 60, 20 SWIFTSAY oSayConn PROMPT "Status: checking..." SIZE 400, 20 OF oWnd
    @ 90, 20 SWIFTSAY oSayIP   PROMPT "Local IP: 0.0.0.0"     SIZE 400, 20 OF oWnd

    @ 130, 20 SWIFTBUTTON "Check Connection" SIZE 150, 30 OF oWnd ;
        ACTION ( oSayConn:SetText( "Status: " + if( oNet:IsConnected(), "CONNECTED", "OFFLINE" ) ) )

    @ 130, 180 SWIFTBUTTON "Get Local IP" SIZE 150, 30 OF oWnd ;
        ACTION ( oSayIP:SetText( "Local IP: " + oNet:GetIP() ) )

    @ 180, 20 SWIFTSAY "Test JSON API (ipify.org):" SIZE 400, 20 OF oWnd

    @ 210, 20 SWIFTBUTTON "Fetch Public IP (JSON)" SIZE 200, 40 OF oWnd ;
        ACTION ( TestJson( oNet, cUrl ) )

    @ 300, 150 SWIFTBUTTON "Close" SIZE 100, 30 OF oWnd ACTION ( oWnd:End() )

    ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

static function TestJson( oNet, cUrl )
    local uData := oNet:GetJson( cUrl )
    
    if valtype( uData ) == "H"
       MsgInfo( "Your Public IP is: " + uData[ "ip" ], "Success from Swift" )
    else
       MsgAlert( hb_ValToStr( uData ), "Network Error Detail" )
    endif
return nil

//----------------------------------------------------------------------------//
