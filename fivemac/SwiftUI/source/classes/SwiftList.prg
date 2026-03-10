#include "FiveMac.ch"


// TSwiftList inherits from TSwiftVStack to get AddItem/AddBatch
CLASS TSwiftList FROM TSwiftVStack
    DATA cId

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    
    // We inherit AddVStack/AddHStack from TSwiftVStack
    // But we might need to override the bridge calls if they expect SWIFTLIST...
    // Actually SWIFTVSTACKCREATE and SWIFTLISTCREATE are different,
    // but the subsequent AddItem/AddBatch bridges can be shared if they use the same Loader.

    METHOD SelectIndex( nIndex )

    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )

    METHOD SetVibrancy( lOnOff )

ENDCLASS


METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize ) CLASS TSwiftList

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault(), nAutoResize := 0

    ::oWnd = oWnd
    
    ::nIndex = SwiftRegisterControl( Self )
    ::aBatch := {}
    ::cId = ""  // Root ID for List items

    ::hWnd = SWIFTLISTCREATE( oWnd:hWnd, ::nIndex, nRow, nCol, nWidth, nHeight )
    
    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

    if __ObjHasData( oWnd, "lVibrancy" ) .and. oWnd:lVibrancy
    ::SetVibrancy( .T. )
    endif

return Self

//----------------------------------------------------------------//

function SwiftListOnClick( nListIndex, nItemIndex )
    local oList
    oList = SwiftGetControl( nListIndex )
    if oList != nil .and. oList:bAction != nil
    Eval( oList:bAction, nItemIndex )
    endif
return nil

METHOD SelectIndex( nIndex ) CLASS TSwiftList
    SWIFTLISTSELECTINDEX( ::nIndex, nIndex )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftList
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    VSTK_SET_BGCOLOR_HEX( hb_ntos( ::nIndex ), clrToHex( nClr, nAlpha ) )
return nil

METHOD SetVibrancy( lOnOff ) CLASS TSwiftList
    DEFAULT lOnOff := .T.
    if lOnOff
    ::SetBackgroundColor( 0, 0, 0, 0.0 ) // Clear background for vibrancy
    endif 
return nil


