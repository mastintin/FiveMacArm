#include "FiveMac.ch"

CLASS SwiftObservation FROM TControl

    DATA cId
    DATA bAction
    
    METHOD New()
    METHOD CreateView( nRow, nCol, nWidth, nHeight, oWnd )
    METHOD End()
    
    METHOD SetCount( nVal )  INLINE SW_OBS_SETCOUNT( AllTrim( Str( Int( nVal ) ) ) )
    METHOD SetMsg( cMsg )    INLINE SW_OBS_SETMSG( cMsg )
    
    METHOD GetCount()        INLINE SW_OBS_GETCOUNT()
    METHOD GetLevel()        INLINE SW_OBS_GETLEVEL()
    METHOD GetEnabled()      INLINE SW_OBS_GETENABLED()

ENDCLASS

METHOD New() CLASS SwiftObservation
    ::cId := hb_UUID()
return Self

METHOD CreateView( nRow, nCol, nWidth, nHeight, oWnd ) CLASS SwiftObservation

    DEFAULT nRow := 0, nCol := 0, nWidth := 200, nHeight := 200
    DEFAULT oWnd := GetWndDefault()

    ::oWnd = oWnd
    ::hWnd = SD_SWIFT_OBSERVATION_CREATE( nRow, nCol, nWidth, nHeight, oWnd:hWnd, ::cId )
    
    oWnd:AddControl( Self )

return Self

METHOD End() CLASS SwiftObservation
    if !Empty( ::hWnd )
        SD_OBS_DESTROY( ::cId, ::hWnd )
        ::hWnd := 0
        ::cId  := ""
    endif
return ::Super:End()

function SWIFTOBSERONACTION( cId, cAction )
    // This is shared model, so careful with multiple instances.
    // For now we just print or handle global.
return nil
