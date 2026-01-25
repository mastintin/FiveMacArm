// Sample showing how to load images from file in SwiftUI
#include "FiveMac.ch"
#include "SwiftControls.ch"

static oImage1, oImage2

function Main()

    local oWnd
    local oBtn1, oBtn2, oBtn3, oBtnExit
    local nMode := 0

    DEFINE WINDOW oWnd TITLE "SwiftUI Image Loader (Multiple Images)" ;
        FROM 200, 200 TO 700, 1000 

    // Image 1 (Left)
    @ 20, 20 SWIFTIMAGE oImage1 NAME "star.fill" SIZE 250, 250 OF oWnd ;
        ACTION MsgInfo("Image 1 Clicked")
    
    // Image 2 (Right)
    @ 20, 300 SWIFTIMAGE oImage2 NAME "heart.fill" SIZE 250, 250 OF oWnd ;
        ACTION MsgInfo("Image 2 Clicked")

    // Button to Change Image 1
    @ 300, 20 BUTTON oBtn1 PROMPT "Set Img 1 (Sun)" SIZE 150, 30 OF oWnd ;
        ACTION oImage1:SetSystemName( "sun.max.fill" )

    // Button to Change Image 2
    @ 300, 300 BUTTON oBtn2 PROMPT "Set Img 2 (Moon)" SIZE 150, 30 OF oWnd ;
        ACTION oImage2:SetSystemName( "moon.stars.fill" )

    // Button to Color Image 1 Red
    @ 340, 20 BUTTON "Img 1 Red" SIZE 150, 30 OF oWnd ;
        ACTION oImage1:SetColor( CLR_HRED )

    // Button to Color Image 2 Blue
    @ 340, 300 BUTTON "Img 2 Blue" SIZE 150, 30 OF oWnd ;
        ACTION oImage2:SetColor( CLR_HBLUE )

    // Load Image from File (Image 1)
    @ 380, 20 BUTTON "Load File Img 1" SIZE 150, 30 OF oWnd ;
        ACTION LoadImageFromFile( oImage1 )

    // Exit Button
    @ 430, 280 BUTTON oBtnExit PROMPT "Exit" SIZE 150, 30 OF oWnd ;
        ACTION oWnd:End()

    ACTIVATE WINDOW oWnd

return nil

function LoadImageFromFile( oImg )
    local cFile := cGetFile( "Image File | *.jpg;*.png", "Select Image" )
   
    if ! Empty( cFile )
    oImg:SetFile( cFile )
    endif
   
return nil
