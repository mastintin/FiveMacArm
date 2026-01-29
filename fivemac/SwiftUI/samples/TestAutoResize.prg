#include "FiveMac.ch"
#include "SwiftControls.ch"


function Main()

    local oWnd
    local oBtnTL, oBtnTR, oBtnBL, oBtnBR, oBtnC

    DEFINE WINDOW oWnd TITLE "Test Swift AutoResize (Anchors)" ;
        SIZE 600, 400

    // Top-Left 
    // Stick Top (Flexible Bottom = AnclaTop = 8)
    // Stick Left (Flexible Right = AnclaLeft = 4)
    @ 20, 20 SWIFTBUTTON oBtnTL PROMPT "Top-Left" SIZE 100, 30 OF oWnd ACTION MsgInfo("TL") ;
        AUTORESIZE nOr( AnclaTop, AnclaLeft )

    // Top-Right 
    // Stick Top (Flexible Bottom = AnclaTop = 8)
    // Stick Right (Flexible Left = AnclaRight = 1)
    @ 20, 480 SWIFTBUTTON oBtnTR PROMPT "Top-Right" SIZE 100, 30 OF oWnd ACTION MsgInfo("TR") ;
        AUTORESIZE nOr( AnclaTop, AnclaRight )

    // Bottom-Left 
    // Stick Bottom (Flexible Top = AnclaBottom = 32)
    // Stick Left (Flexible Right = AnclaLeft = 4)
    @ 350, 20 SWIFTBUTTON oBtnBL PROMPT "Bottom-Left" SIZE 100, 30 OF oWnd ACTION MsgInfo("BL") ;
        AUTORESIZE nOr( AnclaBottom, AnclaLeft )

    // Bottom-Right 
    // Stick Bottom (Flexible Top = AnclaBottom = 32)
    // Stick Right (Flexible Left = AnclaRight = 1)
    @ 350, 480 SWIFTBUTTON oBtnBR PROMPT "Bottom-Right" SIZE 100, 30 OF oWnd ACTION MsgInfo("BR") ;
        AUTORESIZE nOr( AnclaBottom, AnclaRight )

    // Center / Resizable Width 
    // Stick Top (AnclaTop = 8)
    // Width Sizable (AnchoMovil = 2)
    @ 100, 20 SWIFTBUTTON oBtnC PROMPT "Resizable Width (Top Anchored)" SIZE 560, 30 OF oWnd ACTION MsgInfo("C") ;
        AUTORESIZE nOr( AnclaTop, AnchoMovil )

    ACTIVATE WINDOW oWnd

return nil
