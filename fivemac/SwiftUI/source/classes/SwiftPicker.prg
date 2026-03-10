#include "FiveMac.ch"

static aSwiftPickers := {}

//----------------------------------------------------------------------------//

CLASS TSwiftPicker FROM TControl

    DATA   bChange
    DATA   bSetGet
    DATA   aItems
    DATA   cVarName
    DATA   nIndex
    DATA   cID

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, bSetGet, cVarName )
    METHOD Redefine( nId, oWnd, aItems, bChange, bSetGet, cVarName )
   
    METHOD SetItems( aItems ) INLINE SwiftPickerSetItems( aItems, ::cID )
    METHOD Set( cValue )      INLINE PKR_SET_SELECTION( ::cID, cValue )
    METHOD SetGlass( lGlass ) INLINE PKR_SET_GLASS( ::cID, If( lGlass, "1", "0" ) )
    METHOD SetShowLabel( lShow ) INLINE PKR_SET_SHOW_LABEL( ::cID, If( lShow, "1", "0" ) )
    METHOD SetText( cText )      INLINE PKR_SET_TITLE( ::cID, cText )
    METHOD SetColor( nAccent, nText )
    METHOD GetValue()            INLINE PKR_GET_SELECTION( ::cID )
    METHOD SetAutoResize( nStyle ) INLINE ::_nAutoResize( nStyle )
   
    METHOD OnChange( cValue )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, bSetGet, cVarName , cTextLabel, nAutoResize ) CLASS TSwiftPicker

    DEFAULT nWidth := 100, nHeight := 24
    DEFAULT oWnd := GetWndDefault()
    DEFAULT aItems := {}
    DEFAULT cTextLabel := "Categoría"

    ::nTop    = nTop
    ::nLeft   = nLeft
    ::nWidth  = nWidth
    ::nHeight = nHeight
    ::oWnd    = oWnd
    ::aItems  = aItems
    ::bChange = bChange
    ::bSetGet = bSetGet
    ::cVarName = cVarName


    AAdd( aSwiftPickers, Self )
    ::nIndex = Len( aSwiftPickers )
    ::cID = AllTrim( SWIFT_UUID() )

    ::hWnd = SwiftPickerCreate( nTop, nLeft, nWidth, nHeight, aItems, oWnd:hWnd, ::nIndex, cTextLabel, ::cID )
    
    oWnd:AddControl( Self )

    if nAutoResize != nil
    ::SetAutoResize( nAutoResize )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD Redefine( nId, oWnd, aItems, bChange, cVarName ) CLASS TSwiftPicker

    DEFAULT oWnd := GetWndDefault()
   
    ::nId     = nId
    ::oWnd    = oWnd
    ::aItems  = aItems
    ::bChange = bChange
    ::cVarName = cVarName

    AAdd( aSwiftPickers, Self )
    ::nIndex = Len( aSwiftPickers )
   
    oWnd:DefControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD OnChange( cValue ) CLASS TSwiftPicker

    if ::bSetGet != nil
    Eval( ::bSetGet, cValue )
    endif

    if ::bChange != nil
    Eval( ::bChange, cValue, Self )
    endif
   
return nil

METHOD SetColor( nAccent, nText ) CLASS TSwiftPicker
    PKR_SET_COLORS( ::cID, clrToHex( nAccent ), clrToHex( nText ) )
return nil

//----------------------------------------------------------------------------//

function SwiftPickerOnChange( nIndex, cValue )
    aSwiftPickers[ nIndex ]:OnChange( cValue )

return nil

//----------------------------------------------------------------------------//
