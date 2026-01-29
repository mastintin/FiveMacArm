// Sample showing how to embed a SwiftUI view in FiveMac
#include "FiveMac.ch"
#include "SwiftControls.ch"

static oSay
static nClicks := 0
static oLabel
static oSlider
static oStyledBtn
static oImage

function Main()

    local oWnd, oTab, oTabBtn, oTabLbl
    Local lResize := .f.

    DEFINE WINDOW oWnd TITLE "SwiftUI in FiveMac" ;
        FROM 200, 250 TO 600, 950 FLIPPED
   
    // --- Left Column: Native Controls ---

    @ 20, 20 BUTTON "Standard Button" OF oWnd ;
        ACTION ( MsgInfo("I am native"), oLabel:SetText( "Changed from Native Button!" ) )

    @ 20, 180 SAY oSay PROMPT "Clicks: 0" OF oWnd SIZE 150, 20

    @ 60, 20 BUTTON "Set Swift Label" OF oWnd ;
        ACTION oLabel:SetText( "Hello from Harbour!" )

    @ 100, 20 BUTTON "Font Big" OF oWnd ;
        ACTION oLabel:SetFont( 48.0 )

    @ 100, 150 BUTTON "Font Small" OF oWnd ;
        ACTION oLabel:SetFont( 12.0 )

    @ 180, 20 BUTTON "Style Title" OF oWnd ;
        ACTION oLabel:SetFont( "largeTitle" )

    @ 140, 20 BUTTON "Color Red" OF oWnd ;
        ACTION oLabel:SetColor( 255 )

    @ 140, 150 BUTTON "Color Blue" OF oWnd ;
        ACTION oLabel:SetColor( 16711680 )

    // --- Right Column: Swift Controls ---

    // 1. Swift Label (Top Right)
    @ 20, 450 SWIFTLABEL oLabel PROMPT "Initial Swift Label" SIZE 300, 40 OF oWnd

    // 2. Swift Slider (Below Label)
    @ 70, 450 SWIFTSLIDER oSlider VAR 50 SIZE 300, 40 OF oWnd ;
        ON CHANGE {|nVal| oLabel:SetText( "Slider: " + Str(nVal) ) }

    // 3. Swift Button 1 (Below Slider)
    @ 120, 450 SWIFTBUTTON "Standard Syntax" SIZE 150, 40 OF oWnd ;
        ACTION MyHarbourFunc( "Hello from Standard Syntax!" )

    // 4. Swift Button 2 (Below Button 1)
    @ 170, 450 SWIFTBUTTON "CodeBlock Syntax" SIZE 150, 40 OF oWnd ;
        ACTION {|| MyHarbourFunc( "Hello from CodeBlock!" ) }

    // 5. Styled Button (Below Button 2)
    @ 220, 450 SWIFTBUTTON oStyledBtn PROMPT "Styled Button" SIZE 150, 50 OF oWnd ;
        ACTION MsgInfo("I am stylish!")

    oStyledBtn:SetColor( 16777215, 255 ) // White text, Red background (255 = Red)
    oStyledBtn:SetRadius( 25 )
    oStyledBtn:SetPadding( 5 )

    // 6. Swift Image
    @ 280, 450 SWIFTIMAGE oImage NAME "star.fill" SIZE 100, 100 OF oWnd ;
        ACTION MsgInfo("You clicked the star!")
        oImage:SetColor( 255 ) // Red
        oImage:setResizable(.t.)


    // 7. Toggle Resize
    @ 350, 450 BUTTON "Toggle Resize" SIZE 120, 40 OF oWnd ACTION (   lresize := !lresize , oImage:SetResizable( lresize ), MsgInfo("Image Fixed (No Resize)") )

    // 8. TabView
    @ 400, 20 SWIFTBUTTON oTabBtn PROMPT "Tab Button" SIZE 100, 30 OF oWnd ACTION MsgInfo("Tab Btn")
    @ 400, 150 SWIFTLABEL oTabLbl PROMPT "Tab Label" SIZE 100, 30 OF oWnd
    @ 450, 20 SWIFTTABVIEW oTab SIZE 350, 200 OF oWnd ;
        ITEMS { { oTabBtn, "Button Tab", "square.and.pencil" }, ;
        { oTabLbl, "Label Tab", "text.bubble" }, ;
        { oImage,  "Star Tab", "star" } }

    // --- Bottom: Large Hosting View ---
    
    // Pass "UpdateSwiftState" as the callback function name (7th parameter)
    ACTIVATE WINDOW oWnd ;
        VALID MsgYesNo( "Want to end ?" )
    //    ON INIT CreateSwiftView( oWnd:hWnd, "SwiftFive.SwiftLoader", 230, 20, 580, 250, "UpdateSwiftState" ) ;
    //    VALID MsgYesNo( "Want to end ?" )

return nil

// This function is called from SwiftUI via SwiftGlue.m
function UpdateSwiftState( cMsg )
   
    nClicks++
    oSay:SetText( "Clicks: " + AllTrim( Str( nClicks ) ) )
   
return nil

// This function is called by the TSwiftButton
function MyHarbourFunc( cMsg )
    msginfo(1)
    MsgInfo( cMsg )
    if oLabel != nil
    oLabel:SetText( cMsg )
    endif
return nil
