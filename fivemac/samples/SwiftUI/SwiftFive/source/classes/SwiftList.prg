#include "FiveMac.ch"

static aLists := {}

// TSwiftList inherits from TSwiftVStack to get AddItem/AddBatch
CLASS TSwiftList FROM TSwiftVStack

    DATA cId
    DATA hItems INIT {=>}
    DATA nChildCount INIT 0

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    
    METHOD RegItem( cId, oItem ) INLINE ::hItems[ cId ] := oItem
    METHOD GetItem( cId ) INLINE If( ::hItems[ cId ] != nil, ::hItems[ cId ], nil )
    
    // We inherit AddVStack/AddHStack from TSwiftVStack
    // But we might need to override the bridge calls if they expect SWIFTLIST...
    // Actually SWIFTVSTACKCREATE and SWIFTLISTCREATE are different,
    // but the subsequent AddItem/AddBatch bridges can be shared if they use the same Loader.

    METHOD SelectIndex( nIndex )

    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )

ENDCLASS


METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize ) CLASS TSwiftList

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault(), nAutoResize := 0

    ::oWnd = oWnd
    
    ::nId = Len( aLists ) + 1
    ::nIndex = ::nId
    AAdd( aLists, Self )
    ::hItems := {=>}
    ::aBatch := {}
    
    ::cId = ""  // Root ID for List items

    ::hWnd = SWIFTLISTCREATE( oWnd:hWnd, ::nId, nRow, nCol, nWidth, nHeight )
    
    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------//

function SwiftListOnClick( nListIndex, nItemIndex )
    local oList

    if nListIndex > 0 .and. nListIndex <= Len( aLists )
    oList = aLists[ nListIndex ]
    if oList:bAction != nil
    Eval( oList:bAction, nItemIndex )
    endif
    endif

return nil

METHOD SelectIndex( nIndex ) CLASS TSwiftList
    SWIFTLISTSELECTINDEX( ::nId, nIndex )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftList
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    SWIFTLISTSETBGCOLOR( ::nId, nRed / 255.0, nGreen / 255.0, nBlue / 255.0, nAlpha )
return nil


