#include "FiveMac.ch"

CLASS SwiftObservation FROM TControl

    DATA nIndex
    DATA bAction
    
    METHOD New()
    METHOD CreateView( nRow, nCol, nWidth, nHeight, oWnd )
    
    METHOD SetCount( nVal )  INLINE SW_OBS_SETCOUNT( AllTrim( Str( Int( nVal ) ) ) )
    METHOD SetMsg( cMsg )    INLINE SW_OBS_SETMSG( cMsg )
    
    METHOD GetCount()        INLINE SW_OBS_GETCOUNT()
    METHOD GetLevel()        INLINE SW_OBS_GETLEVEL()
    METHOD GetEnabled()      INLINE SW_OBS_GETENABLED()

ENDCLASS

METHOD New() CLASS SwiftObservation
return Self

METHOD CreateView( nRow, nCol, nWidth, nHeight, oWnd ) CLASS SwiftObservation

    DEFAULT nRow := 0, nCol := 0, nWidth := 200, nHeight := 200
    DEFAULT oWnd := GetWndDefault()

    ::oWnd = oWnd
    ::nIndex = SwiftRegisterControl( Self )
    ::hWnd = SWIFTOBSERVATIONCREATE( oWnd:hWnd, ::nIndex, nRow, nCol, nWidth, nHeight )
    
    oWnd:AddControl( Self )

return Self
