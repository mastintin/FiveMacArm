#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TPanel FROM TControl

    DATA aControls INIT {}

    DATA lFlipped INIT .F.

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, lFlipped )
    METHOD AddControl( oCtrl ) 
    
    METHOD SetColor( nClrText, nClrBack )

    METHOD cGenPrg()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd ) CLASS TPanel

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault()
     
    ::lFlipped = oWnd:lFlipped   

    ::hWnd = PanelCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, ::lFlipped )
    ::oWnd = oWnd
    
    ::aControls = {}

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD AddControl( oCtrl ) CLASS TPanel

    AAdd( ::aControls, oCtrl )
    ::oWnd:AddControl( oCtrl )

return nil

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

METHOD SetColor( nClrText, nClrBack ) CLASS TPanel

    if ! Empty( nClrBack )
        PanelSetColor( ::hWnd, nRgbRed( nClrBack ), nRgbGreen( nClrBack ),;
            nRgbBlue( nClrBack ), 100 )
    endif

return nil

//----------------------------------------------------------------------------//

METHOD cGenPrg() CLASS TPanel

    local cCode := CRLF + CRLF + "   @ " + ;
        AllTrim( Str( ::nTop ) ) + ", " + ;
        AllTrim( Str( ::nLeft ) ) + " PANEL " + ::cVarName + ;
        " OF " + ::oWnd:cVarName + ;
        " ;" + CRLF + "      SIZE " + ;
        AllTrim( Str( ::nWidth ) ) + ", " + ;
        AllTrim( Str( ::nHeight ) )

return cCode

//----------------------------------------------------------------------------//


CLASS TSidebar FROM TPanel

    METHOD New( nWidth, oWnd )
    
ENDCLASS

METHOD New( nWidth, oWnd ) CLASS TSidebar

    DEFAULT nWidth := 200, oWnd := GetWndDefault()

    // Default to full height of parent window
    // nTop=0, nLeft=0
    ::Super:New( 0, 0, nWidth, oWnd:nHeight, oWnd )
    
    // Autoresize: Height (16) + MinY (8)? OR just Fixed Left/Top + Resizable Height
    // Cocoa: Height Sizable (16) | MaxY Margin (32) ?? 
    // We want it stuck to left (MinX fixed) and top (MinY fixed or MaxY fixed depending on flipped).
    // In Flipped coordinates (0,0 is top-left):
    // We want Fixed Top, Fixed Left, Resizable Height.
    // Fixed Right Margin? No, width is fixed.
    // So autoresize mask = NSViewHeightSizable (16)
    ::nAutoResize = 16 

    // Default Color: Finder Sidebar Gray-ish
    // Example: ARGB( 255, 236, 236, 236 ) or similar system color emulation
    
    ::SetColor( CLR_BLACK, ARGB( 255, 240, 240, 240 ) ) 

    if oWnd:lGlass
        ::SetLiquidGlass( .T. )
        ::SetColor( CLR_BLACK, ARGB( 0, 0, 0, 0 ) ) // Transparent background for Glass             
    endif

return Self

