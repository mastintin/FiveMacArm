// Sample showing how to load images from file in SwiftUI
#include "FiveMac.ch"
#include "SwiftControls.ch"

static oImage

function Main()

    local oWnd
    local oBtnFile, oBtnExit
    local nMode := 0

    DEFINE WINDOW oWnd TITLE "SwiftUI Image Loader" ;
        FROM 200, 250 TO 600, 750 FLIPPED

    // Swift Image Control
    @ 20, 20 SWIFTIMAGE oImage NAME "photo" SIZE 460, 280 OF oWnd ;
        ACTION MsgInfo("Image Clicked")
    
    oImage:SetResizable( .T. )

    // Load Image Button
    @ 320, 20 BUTTON oBtnFile PROMPT "Load Image..." SIZE 150, 40 OF oWnd ;
        ACTION LoadImageFromFile()

    // Aspect Ratio Button
    @ 320, 180 BUTTON "Toggle Aspect" SIZE 140, 40 OF oWnd ;
        ACTION ( nMode := If( nMode == 0, 1, 0 ), oImage:SetAspectRatio( nMode ) )

    // Load Image via Pointer
    @ 400, 20 BUTTON "Via NSImage" SIZE 150, 40 OF oWnd ;
        ACTION LoadImageFromPointer( oImage )

    // Exit Button
    @ 320, 330 BUTTON oBtnExit PROMPT "Exit" SIZE 150, 40 OF oWnd ;
        ACTION oWnd:End()

    ACTIVATE WINDOW oWnd

return nil

function LoadImageFromFile()
    local cFile := cGetFile( "Image File | *.jpg;*.png", "Select Image" )
   
    if ! Empty( cFile )
    oImage:SetFile( cFile )
    endif
   
return nil

function LoadImageFromPointer( oImage )
    local cFile := cGetFile( "Image File | *.jpg;*.png", "Select Image (Handle)" )
    local pImage
    
    if ! Empty( cFile )
    // Use FiveMac's NSImgFromFile to get an NSImage pointer
    pImage := NSImgFromFile( cFile )
    if pImage != nil
    oImage:SetImage( pImage )
    endif
    endif

return nil
