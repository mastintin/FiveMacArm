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

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd ) CLASS TSwiftList

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault()

    ::oWnd = oWnd
    
    ::nId = Len( aLists ) + 1
    AAdd( aLists, Self )
    ::hItems := {=>}
    ::aBatch := {}
    
    ::cId = ""  // Root ID for List items

    ::hWnd = SWIFTLISTCREATE( oWnd:hWnd, ::nId, nRow, nCol, nWidth, nHeight )
    
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
