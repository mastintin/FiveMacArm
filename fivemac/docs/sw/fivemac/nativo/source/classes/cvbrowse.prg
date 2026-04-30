#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TCVBrowse FROM TControl

    DATA bChange
    DATA bLDblClick

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd )
   
    METHOD AddFile( cFile )
    METHOD AddDir( cDir )
    METHOD OpenPanel()
   
    METHOD SetZoom( nPercent )
    METHOD GetZoom()

    METHOD HandleEvent( nMsg, nWParam, nLParam )

    METHOD Click() INLINE nil

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd ) CLASS TCVBrowse

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault()

    ::hWnd = IKImgBrCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
   
    oWnd:AddControl( Self )
   
return Self

//----------------------------------------------------------------------------//

METHOD AddFile( cFile ) CLASS TCVBrowse
   
    IKImgBrOpenFile( ::hWnd, cFile )
   
return nil

//----------------------------------------------------------------------------//

METHOD AddDir( cDir ) CLASS TCVBrowse

    IKImgBrOpenDir( ::hWnd, cDir )

return nil

//----------------------------------------------------------------------------//

METHOD OpenPanel() CLASS TCVBrowse

    IKImgBrOpenPanel( ::hWnd )

return nil

//----------------------------------------------------------------------------//

METHOD SetZoom( nPercent ) CLASS TCVBrowse

    IKImgBrSetZoom( ::hWnd, nPercent )

return nil

//----------------------------------------------------------------------------//

METHOD GetZoom() CLASS TCVBrowse

return IKImgBrGetZoom( ::hWnd )

//----------------------------------------------------------------------------//

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TCVBrowse

    if nMsg == 18 // WM_BRWCHANGED
    if ::bChange != nil
    Eval( ::bChange, Self, nLParam )
    endif
    return 0
    endif
   
    if nMsg == 50 // WM_CVDBLCLICK
    if ::bLDblClick != nil
    Eval( ::bLDblClick, Self, nLParam )
    endif
    return 0
    endif

return Super:HandleEvent( nMsg, nWParam, nLParam )
