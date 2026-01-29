#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()

    local oWnd, oZStack
    local oHStack, oVStack
    local nW := 400
    local nH := 500

    DEFINE WINDOW oWnd TITLE "Testing SwiftUI ZStack" SIZE nW, nH FLIPPED

    // 1. Create ZStack centered
    @ 20, 20 SWIFTZSTACK oZStack SIZE 360, 300 OF oWnd
    
    // Add default test content
    oZStack:SetBackgroundColor( 200, 200, 200, 1.0 ) 
    
    // 19. Start Profile Card Logic
    BuildProfileCard( oZStack, "person.crop.square.fill", .T. ) // .T. = use system image

    // ----------------------------------------

    @ 360, 260 BUTTON "Exit" SIZE 90, 30 OF oWnd ACTION oWnd:End()
    
    // Image Loader
    @ 340, 20 BUTTON "Cargar Img" SIZE 100, 30 OF oWnd ACTION ( ;
        cFile := cGetFile( "Image Files (*.jpg;*.png)|*.jpg;*.png", "Select Image" ), ;
        If( !Empty( cFile ), ( oZStack:Reset(), BuildProfileCard( oZStack, cFile, .F. ) ), nil ) )

    // Alignment Controls
    @ 320, 20 BUTTON "TopLeading" SIZE 100, 30 OF oWnd ACTION oZStack:SetAlignment(1)
    @ 320, 130 BUTTON "Center"    SIZE 100, 30 OF oWnd ACTION oZStack:SetAlignment(0)
    @ 320, 240 BUTTON "BotTrailing" SIZE 100, 30 OF oWnd ACTION oZStack:SetAlignment(8)
    @ 360, 130 BUTTON "Bottom"    SIZE 100, 30 OF oWnd ACTION oZStack:SetAlignment(7)

    ACTIVATE WINDOW oWnd 

return nil

function BuildProfileCard( oZStack, cImage, lSystem )

    local oHStack, oVStack

    // 1. ZStack Alignment Bottom (to place Overlay at bottom)
    oZStack:SetAlignment( 7 ) 
    
    // 2. Add Background Image (Fills Screen)
    if lSystem
    oZStack:AddImage( cImage ) 
    else
    oZStack:AddImageFile( cImage )
    endif

    // 3. Create Overlay: HStack { VStack { Text, Text } Spacer }
    
    // Create Root HStack
    oHStack := oZStack:AddHStack()
    oHStack:SetColor( 255, 255, 255, 0.8 ) // Semi-transparent White
    
    // Add VStack to HStack
    oVStack := oHStack:AddVStack()
    
    // Add Texts to VStack
    oVStack:AddText("Rachael Chiseck")
    oVStack:AddText("Chief Executive Officer")
    
    // Add Spacer to HStack (pushes VStack to left)
    oHStack:AddSpacer()

return nil
