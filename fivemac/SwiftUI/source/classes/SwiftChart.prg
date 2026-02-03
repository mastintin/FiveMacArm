#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftCharts := {}

//----------------------------------------------------------------------------//

CLASS TSwiftChart FROM TControl

    DATA hData       INIT {=>}
    DATA cChartType  INIT "bar"
    DATA nIndex
    DATA cID

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, hData, cType )
    METHOD SetData( hData )
    METHOD SetType( cType )
    METHOD SaveToImage( cPath )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, hData, cType ) CLASS TSwiftChart

    ::oWnd    = oWnd
    ::nId     = ::GetCtrlIndex()
    ::hData   = hData
    ::cChartType = cType
   
    DEFAULT nWidth  := 400
    DEFAULT nHeight := 300
    DEFAULT hData   := {}
    DEFAULT cType   := "bar"
   
    AAdd( aSwiftCharts, Self )
    ::nIndex = Len( aSwiftCharts )
    ::cID = AllTrim( SWIFT_UUID() )

    // Serialize initial data
    // If it is already a string (JSON), do not re-encode
    if ValType( ::hData ) == "C"
    ::hWnd = SWIFTCHARTCREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, ::nIndex, ::cID, ::hData, ::cChartType )
    else
    ::hWnd = SWIFTCHARTCREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, ::nIndex, ::cID, hb_jsonEncode( ::hData ), ::cChartType )
    endif
   
    oWnd:AddControl( Self )

return Self

METHOD SetData( hData ) CLASS TSwiftChart
    local cJson 
    ::hData := hData
    cJson := hb_jsonEncode( ::hData )
    SWIFTCHARTSETDATA( cJson, ::cID )
return nil

METHOD SetType( cType ) CLASS TSwiftChart
    ::cChartType := cType
    SWIFTCHARTSETTYPE( cType, ::cID )
return nil

METHOD SaveToImage( cPath ) CLASS TSwiftChart
    DEFAULT cPath := GetEnv( "TMPDIR" ) + "/chart_" + ::cID + ".png"
    SWIFTCHARTMAKESNAPSHOT( ::cID, cPath )
return cPath 
