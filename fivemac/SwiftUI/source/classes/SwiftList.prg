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

CLASS TSwiftList FROM TSwiftVStack

    DATA cSelectedId

    ASSIGN Value( n )      INLINE ::SelectIndex( n )
    ACCESS Value()         INLINE ::cSelectedId
    
    METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize, cId )
    METHOD OnAction( cItemId )
    METHOD SelectIndex( nIndex )
    METHOD SetBackgroundColor( nClr, nAlpha )
    METHOD SetVibrancy( lOnOff )
    METHOD AddItem( nType, cContent, cSecondaryContent, cParentId )
    METHOD AddBatch( cJson, cParentId )
    METHOD AddListRow()
    METHOD GetLastItemId() 
    METHOD End()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nAutoResize, cId ) CLASS TSwiftList

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault(), nAutoResize := 0

    ::TSwiftControl:New( nRow, nCol, nWidth, nHeight, cId )
    ::oWnd := oWnd
    ::aBatch := {}
    ::aIds   := {}
    
    ::Register( SD_SWIFT_LIST_CREATE( nRow, nCol, nWidth, nHeight, oWnd:hWnd, ::cId ) )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

    if __ObjHasData( oWnd, "lVibrancy" ) .and. oWnd:lVibrancy
        ::SetVibrancy( .T. )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD OnAction( cItemId ) CLASS TSwiftList
    local oItem := SwiftGetItem( cItemId )
    
    ::cSelectedId := cItemId

    if oItem != nil .and. __ObjHasMsg( oItem, "BACTION" ) .and. oItem:bAction != nil
        Eval( oItem:bAction, cItemId, oItem )
        return nil 
    endif

    if ::bAction != nil
        Eval( ::bAction, cItemId, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD SelectIndex( nIndex ) CLASS TSwiftList
    SD_LST_SET_SELECTION( ::cId, hb_ntos( nIndex ) )
return nil

//----------------------------------------------------------------------------//

METHOD SetBackgroundColor( nClr, nAlpha ) CLASS TSwiftList
return ::SetAccentColor( nClr, nAlpha )

//----------------------------------------------------------------------------//

METHOD SetVibrancy( lOnOff ) CLASS TSwiftList
    DEFAULT lOnOff := .T.
    if lOnOff
        ::SetBackgroundColor( 0, 0.0 ) 
    endif 
return nil

//----------------------------------------------------------------------------//

METHOD AddItem( nType, cContent, cSecondaryContent, cParentId ) CLASS TSwiftList
return SD_LST_ADD_ITEM( ::cId, nType, cContent, If( cSecondaryContent != nil, cSecondaryContent, "" ), If( cParentId != nil, cParentId, "" ) )

//----------------------------------------------------------------------------//

METHOD AddBatch( cJson, cParentId ) CLASS TSwiftList
return SD_LST_ADD_BATCH( ::cId, cJson, If( cParentId != nil, cParentId, "" ) )

//----------------------------------------------------------------------------//

METHOD AddListRow() CLASS TSwiftList
    local cId := SD_LST_ADD_ROW( ::cId )
return TSwiftRow():New( Self, cId )

//----------------------------------------------------------------------------//

METHOD GetLastItemId() CLASS TSwiftList
return SD_LST_GET_LAST_ITEM_ID( ::cId )

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftList
    if !Empty( ::hWnd )
        SD_LST_DESTROY( ::cId, ::hWnd )
        ::hWnd := nil
    endif
return ::TSwiftControl:End()

//----------------------------------------------------------------------------//
// TSwiftRow
//----------------------------------------------------------------------------//

CLASS TSwiftRow FROM TSwiftControl
    DATA oList
    DATA oLastIcon

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
    METHOD End()
ENDCLASS

METHOD New( oList, cId ) CLASS TSwiftRow
    ::oList := oList
    ::cId   := cId
    SwiftRegisterItem( ::cId, Self )
return Self

METHOD AddIcon( cIcon ) CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_SYSTEMIMAGE, cIcon, "", ::cId )
    ::oLastIcon := TSwiftListItem():New( cId, ::oList )
return ::oLastIcon

METHOD AddText( cText ) CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_TEXT, cText, "", ::cId )
return TSwiftListItem():New( cId, ::oList )

METHOD AddSpacer() CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_SPACER, "", "", ::cId )
return TSwiftListItem():New( cId, ::oList )

METHOD AddButton( cContent, bAction ) CLASS TSwiftRow
    local cId := SD_LST_ADD_ITEM( ::oList:cId, TYPE_BUTTON, cContent, "", ::cId )
    local oItem := TSwiftListItem():New( cId, ::oList )
    if bAction != nil ; oItem:bAction := bAction ; endif
return oItem

METHOD SetSize( nW, nH ) CLASS TSwiftRow
    DEFAULT nW := 0, nH := 0
    SD_LST_SET_ITEM_LAYOUT( ::oList:cId, ::cId, hb_ntos( nW ), hb_ntos( nH ), "-1" )
return Self

METHOD SetIconSize( nW, nH ) CLASS TSwiftRow
    if ::oLastIcon != nil ; ::oLastIcon:SetSize( nW, nH ) ; endif
return nil

METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftRow
    DEFAULT nAlphaFore := 255, nAlphaBack := 255
    if nClrFore != nil ; SD_LST_SET_ITEM_COLOR( ::oList:cId, ::cId, nClrFore, nAlphaFore ) ; endif
    if nClrBack != nil ; SD_LST_SET_ITEM_BGCOLOR( ::oList:cId, ::cId, nClrBack, nAlphaBack ) ; endif
return Self

METHOD SetFont( nSize, lBold ) CLASS TSwiftRow
    DEFAULT nSize := 0, lBold := .F.
    SD_LST_SET_ITEM_FONT( ::oList:cId, ::cId, hb_ntos( nSize ), lBold )
return Self

METHOD SetSpacing( nSpacing ) CLASS TSwiftRow
    DEFAULT nSpacing := 8
    SD_LST_SET_ITEM_LAYOUT( ::oList:cId, ::cId, "0", "0", hb_ntos( nSpacing ) )
return Self

METHOD End() CLASS TSwiftRow
    ::oLastIcon := nil
    ::oList := nil
return ::Super:End()

//----------------------------------------------------------------------------//
// TSwiftListItem
//----------------------------------------------------------------------------//

CLASS TSwiftListItem FROM TSwiftControl
    DATA oList

    METHOD New( cId, oList )
    METHOD SetSize( nW, nH )
    METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD SetFont( nSize, lBold )
    METHOD End()
ENDCLASS

METHOD New( cId, oList ) CLASS TSwiftListItem
    ::cId := cId
    ::oList := oList
    SwiftRegisterItem( ::cId, Self )
return Self

METHOD SetSize( nW, nH ) CLASS TSwiftListItem
    DEFAULT nW := 0, nH := 0
    SD_LST_SET_ITEM_LAYOUT( ::oList:cId, ::cId, hb_ntos( nW ), hb_ntos( nH ), "-1" )
return Self

METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftListItem
    DEFAULT nAlphaFore := 255, nAlphaBack := 255
    if nClrFore != nil ; SD_LST_SET_ITEM_COLOR( ::oList:cId, ::cId, nClrFore, nAlphaFore ) ; endif
    if nClrBack != nil ; SD_LST_SET_ITEM_BGCOLOR( ::oList:cId, ::cId, nClrBack, nAlphaBack ) ; endif
return Self

METHOD SetFont( nSize, lBold ) CLASS TSwiftListItem
    DEFAULT nSize := 0, lBold := .F.
    SD_LST_SET_ITEM_FONT( ::oList:cId, ::cId, hb_ntos( nSize ), lBold )
return Self

METHOD End() CLASS TSwiftListItem
    ::bAction := nil
    ::oList := nil
return ::Super:End()
