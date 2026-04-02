#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftCharts := {}

//----------------------------------------------------------------------------//

CLASS TSwiftChart FROM TControl

    DATA hData       INIT {=>}
    DATA cChartType  INIT "bar"
    DATA cID

    ACCESS Value       INLINE ::hData
    ASSIGN Value( h )  INLINE ::SetData( h )
    
    ACCESS Data        INLINE ::hData
    ASSIGN Data( h )   INLINE ::SetData( h )
    
    ACCESS Type        INLINE ::cChartType
    ASSIGN Type( c )   INLINE ::SetType( c )

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, hData, cType )
    METHOD SetData( hData )
    METHOD SetType( cType )
    METHOD SetTitles( cTitle, cSubtitle )
    METHOD SaveToImage( cPath )
    METHOD End()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, hData, cType ) CLASS TSwiftChart

    oWnd := if( oWnd == nil, GetWndDefault(), oWnd )
    ::oWnd    = oWnd
    ::hData   = hData
    ::cChartType = cType
    ::cID := ""
   
    AAdd( aSwiftCharts, Self )

    ::hWnd = SD_SWIFT_CHART_CREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, ::cID, hb_jsonEncode( ::hData ), ::cChartType )
    ::cID := SW_GET_ID( ::hWnd )
    
    // REGISTRO GLOBAL
    SwiftRegisterItem( ::cID, Self )
  
    oWnd:AddControl( Self )

return Self

METHOD SetData( hData ) CLASS TSwiftChart
    local cJson 
    ::hData := hData
    cJson := if( ValType( hData ) == "C", hData, hb_jsonEncode( hData ) )
    SD_CHART_SET_DATA( ::cID, cJson )
return nil

METHOD SetType( cType ) CLASS TSwiftChart
    ::cChartType := cType
    SD_CHART_SET_TYPE( ::cID, cType )
return nil

METHOD SetTitles( cTitle, cSubtitle ) CLASS TSwiftChart
    DEFAULT cTitle := "", cSubtitle := ""
    SD_CHART_SET_TITLES( ::cID, cTitle, cSubtitle )
return nil

METHOD SaveToImage( cPath ) CLASS TSwiftChart
    DEFAULT cPath := GetEnv( "TMPDIR" ) + "/chart_" + ::cID + ".png"
    SD_CHART_MAKE_SNAPSHOT( ::cID, cPath )
return cPath 

METHOD End() CLASS TSwiftChart
    local nPos 
    if !Empty( ::hWnd )
        SD_CHART_DESTROY( ::cID, ::hWnd )
        
        // UNREGISTER GLOBAL
        SwiftUnregisterItem( ::cID )
        
        nPos := AScan( aSwiftCharts, { |o| o != nil .and. o:cID == ::cID } )
        if nPos > 0
            aSwiftCharts[ nPos ] := nil
        endif
        ::cID := ""
    endif
return ::Super:End()
