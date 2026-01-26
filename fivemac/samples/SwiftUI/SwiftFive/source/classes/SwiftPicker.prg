#include "FiveMac.ch"

static aSwiftPickers := {}

//----------------------------------------------------------------------------//

CLASS TSwiftPicker FROM TControl

    DATA   bChange
    DATA   bSetGet
    DATA   aItems
    DATA   cVarName
    DATA   nIndex

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, bSetGet, cVarName )
    METHOD Redefine( nId, oWnd, aItems, bChange, bSetGet, cVarName )
   
    METHOD SetItems( aItems ) INLINE SwiftPickerSetItems( aItems, ::nIndex )
    METHOD Set( cValue )      INLINE SwiftPickerSetSelection( cValue, ::nIndex )
    METHOD SetGlass( lGlass ) INLINE SwiftPickerSetGlass( lGlass, ::nIndex )
    METHOD SetShowLabel( lShow ) INLINE SwiftPickerSetShowLabel( lShow, ::nIndex )
    METHOD SetText( cText )      INLINE SwiftPickerSetTitle( cText, ::nIndex )
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

    ::hWnd = SwiftPickerCreate( nTop, nLeft, nWidth, nHeight, aItems, oWnd:hWnd, ::nIndex, cTextLabel )
    
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

//----------------------------------------------------------------------------//

function SwiftPickerOnChange( nIndex, cValue )
    aSwiftPickers[ nIndex ]:OnChange( cValue )

return nil

//----------------------------------------------------------------------------//
