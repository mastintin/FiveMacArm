// Sample showing MusicKit Integration via SwiftUI Bridge
#include "FiveMac.ch"

function Main()

    local oWnd, oBtnPlay, oBtnPause, oBtnNext, oBtnPrev, oBtnAuth
    local oSayState, oSayMeta
    local oMusic := TSwiftMusic():New()

    DEFINE WINDOW oWnd TITLE "MusicKit Integration" ;
        FROM 200, 250 TO 600, 750 FLIPPED

    @ 20, 20 BUTTON "Request Auth" OF oWnd ;
        ACTION oMusic:Auth()

    @ 60, 20 BUTTON "Play" OF oWnd ;
        ACTION oMusic:Play()

    @ 60, 150 BUTTON "Pause" OF oWnd ;
        ACTION oMusic:Pause()

    @ 100, 20 BUTTON "Previous" OF oWnd ;
        ACTION oMusic:Previous()

    @ 100, 150 BUTTON "Next" OF oWnd ;
        ACTION oMusic:Next()

    @ 140, 20 BUTTON "Get Metadata" OF oWnd ;
        ACTION MsgInfo( oMusic:GetMetadata() )

    @ 140, 150 BUTTON "Get State" OF oWnd ;
        ACTION MsgInfo( Str( oMusic:GetState() ) )

    ACTIVATE WINDOW oWnd ;
        VALID MsgYesNo( "Want to end ?" )

return nil
