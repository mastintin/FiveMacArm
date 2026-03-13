#include "FiveMac.ch"

#define TYPE_TEXT            0
#define TYPE_SYSTEMIMAGE     1
#define TYPE_HSTACK          2
#define TYPE_IMAGEFILE       3
#define TYPE_VSTACK          4
#define TYPE_HSTACKCONTAINER 5
#define TYPE_SPACER          6
#define TYPE_LAZYVGRID       7
#define TYPE_LIST            8
#define TYPE_BUTTON          9
#define TYPE_DIVIDER         10

static aSwiftLists := {}

// TSwiftList inherits from TSwiftVStack to get AddItem/AddBatch
CLASS TSwiftList FROM TSwiftVStack
    DATA cId
    DATA nListIndex 

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    
    // We inherit AddVStack/AddHStack from TSwiftVStack
    // But we might need to override the bridge calls if they expect SWIFTLIST...
    // Actually SWIFTVSTACKCREATE and SWIFTLISTCREATE are different,
    // but the subsequent AddItem/AddBatch bridges can be shared if they use the same Loader.

    METHOD SelectIndex( nIndex )

    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )

    METHOD SetVibrancy( lOnOff )

    METHOD AddItem( nType, cContent, cSecondaryContent, cParentId )

    METHOD AddBatch( cJson, cParentId )

    METHOD AddListRow()

    METHOD GetLastItemId() 

    METHOD End()

ENDCLASS


METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize ) CLASS TSwiftList

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault(), nAutoResize := 0

    ::oWnd = oWnd
    
    ::cId := hb_UUID()
    ::aBatch := {}

    ::hWnd = SD_SWIFT_LIST_CREATE( nRow, nCol, nWidth, nHeight, oWnd:hWnd, ::cId )
    
    AAdd( aSwiftLists, Self )
    ::nListIndex := Len( aSwiftLists )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

    if __ObjHasData( oWnd, "lVibrancy" ) .and. oWnd:lVibrancy
        ::SetVibrancy( .T. )
    endif

return Self

//----------------------------------------------------------------//

function SWIFTLISTONACTION( cId, cItemId )
    local nPos := AScan( aSwiftLists, { |o| o != nil .and. o:cId == cId } )
    local oItem := SwiftGetItem( cItemId )

    if oItem != nil .and. __ObjHasMsg( oItem, "BACTION" ) .and. oItem:bAction != nil
        Eval( oItem:bAction, cItemId, oItem )
        return nil // If item has its own action, we might skip the list action or not, 
        // but usually, if it's a button click inside the row, we don't want the row click too.
    endif

    if nPos > 0
        if aSwiftLists[ nPos ]:bAction != nil
            Eval( aSwiftLists[ nPos ]:bAction, cItemId )
        endif
    endif
return nil

METHOD SelectIndex( nIndex ) CLASS TSwiftList
    SD_LST_SET_SELECTION( ::cId, hb_ntos( nIndex ) )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftList
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
        nClr   := nRed
    else
        nClr := nRGB( nRed, nGreen, nBlue )
    endif

    SD_LST_SET_BGCOLOR_HEX( ::cId, clrToHex( nClr, nAlpha ) )
return nil

METHOD SetVibrancy( lOnOff ) CLASS TSwiftList
    DEFAULT lOnOff := .T.
    if lOnOff
        ::SetBackgroundColor( 0, 0, 0, 0.0 ) // Clear background for vibrancy
    endif 
return nil

METHOD AddItem( nType, cContent, cSecondaryContent, cParentId ) CLASS TSwiftList
return SD_LST_ADD_ITEM( ::cId, nType, cContent, cSecondaryContent, cParentId )


METHOD AddBatch( cJson, cParentId ) CLASS TSwiftList
return SD_LST_ADD_BATCH( ::cId, cJson, cParentId )

METHOD AddListRow() CLASS TSwiftList
    local cId
    cId := SD_LST_ADD_ROW( ::cId )
return TSwiftRow():New( Self, cId )

METHOD GetLastItemId() CLASS TSwiftList
return SD_LST_GET_LAST_ITEM_ID( ::cId )

METHOD End() CLASS TSwiftList
    if !Empty( ::hWnd )
        SD_LST_DESTROY( ::cId, ::hWnd )
        ::hWnd := 0
        ::cId := ""
        if ::nListIndex > 0 .and. ::nListIndex <= Len( aSwiftLists )
            aSwiftLists[ ::nListIndex ] := nil
        endif
    endif
return ::Super:End()

//--------------------------------------------------------------------

// ---------------------------------------------------------
// Clase ligera para gestionar una fila (HStack) de la lista
// ---------------------------------------------------------
CREATE CLASS TSwiftRow
    VAR oList    // Referencia al objeto TSwiftList (la lista completa)
    VAR cId      // El UUID de esta fila concreta (el hstackContainer)
    VAR oLastIcon 

    METHOD New( oList, cId )
    METHOD AddIcon( cIcon )
    METHOD AddText( cText )
    METHOD AddSpacer()
    METHOD AddButton( cContent, bAction )
    METHOD SetSize( nW, nH )
    METHOD SetIconSize( nW, nH )
    METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD SetFont( nSize, lBold )
    METHOD SetSpacing( nSpacing )
    METHOD AddSpacing( nSpacing ) INLINE ::SetSpacing( nSpacing )
ENDCLASS

METHOD New( oList, cId ) CLASS TSwiftRow
    ::oList := oList
    ::cId   := cId
return Self

METHOD AddIcon( cIcon ) CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_SYSTEMIMAGE, cIcon, "", ::cId )
    ::oLastIcon := TSwiftStackItem():New( cId, ::oList )
return ::oLastIcon

METHOD SetIconSize( nW, nH ) CLASS TSwiftRow
    if ::oLastIcon != nil 
        ::oLastIcon:SetSize( nW, nH )
    endif 
return nil

METHOD AddText( cText ) CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_TEXT, cText, "", ::cId )
return TSwiftStackItem():New( cId, ::oList )

METHOD AddSpacer() CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_SPACER, "", "", ::cId )
return TSwiftStackItem():New( cId, ::oList )

METHOD AddButton( cContent, bAction ) CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_BUTTON, cContent, "", ::cId )
    local oItem := TSwiftStackItem():New( cId, ::oList )
    if bAction != nil ; oItem:bAction := bAction ; endif
return oItem

METHOD SetSize( nW, nH ) CLASS TSwiftRow
    DEFAULT nW := 0, nH := 0
    SD_LST_SET_ITEM_LAYOUT( ::oList:cId, ::cId, hb_ntos( nW ), hb_ntos( nH ), "-1" )
return nil

METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftRow
    DEFAULT nAlphaFore := 1.0, nAlphaBack := 1.0
    if nClrFore != nil
        SD_LST_SET_ITEM_COLOR_HEX( ::oList:cId, ::cId, clrToHex( nClrFore, nAlphaFore ) )
    endif
    if nClrBack != nil
        SD_LST_SET_ITEM_BGCOLOR_HEX( ::oList:cId, ::cId, clrToHex( nClrBack, nAlphaBack ) )
    endif
return nil

METHOD SetFont( nSize, lBold ) CLASS TSwiftRow
    DEFAULT nSize := 0, lBold := .F.
    SD_LST_SET_ITEM_FONT( ::oList:cId, ::cId, hb_ntos( nSize ), lBold )
return nil

METHOD SetSpacing( nSpacing ) CLASS TSwiftRow
    DEFAULT nSpacing := 8
    SD_LST_SET_ITEM_LAYOUT( ::oList:cId, ::cId, "0", "0", hb_ntos( nSpacing ) )
return nil
