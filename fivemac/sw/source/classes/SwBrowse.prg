#include "swfive.ch"

#define SW_TYPE_BROWSE 27

CLASS TSwBrowse FROM TSwiftControl

    DATA aCols INIT {}

    METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId )
    METHOD AddColumn( cTitle, nWidth, cField )
    METHOD SetArray( aData )
    
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId ) CLASS TSwBrowse

    DEFAULT nWidth := 400, nHeight := 300
    
    if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif

    ::cId     := cId
    ::hState["id"]          := ::cId
    ::hState["top"]         := nTop
    ::hState["left"]        := nLeft
    ::hState["width"]       := nWidth
    ::hState["height"]      := nHeight
    ::hState["type"]        := SW_TYPE_BROWSE
    
    if hb_IsObject( oParent )
       ::oWnd               := if( __ObjHasData( oParent, "oWnd" ), oParent:oWnd, oParent )
       ::hState["parentid"] := if( __ObjHasData( oParent, "cId"  ), oParent:cId , "NONE" )
    else 
       ::oWnd := oParent
    endif 
    
    ::oParent := oParent
    
    SwiftRegisterItem( ::cId, Self )
    ::Create()

return Self

//----------------------------------------------------------------------------//

METHOD AddColumn( cTitle, nWidth, cField ) CLASS TSwBrowse

    local hCol := { "title" => cTitle, "width" => nWidth, "field" => cField }

    if Empty( cField )
       hCol[ "field" ] := Lower( cTitle )
    endif

    AAdd( ::aCols, hCol )
    
    ::Apply( { "columns" => ::aCols } )

return nil

//----------------------------------------------------------------------------//

METHOD SetArray( aData ) CLASS TSwBrowse

    local aRows := {}
    local n, i, hRow
    
    for n := 1 to Len( aData )
        hRow := { "id" => AllTrim( Str( n ) ) }
        for i := 1 to Len( ::aCols )
            if i <= Len( aData[ n ] )
               hRow[ ::aCols[ i ][ "field" ] ] := cValToChar( aData[ n ][ i ] )
            endif
        next
        AAdd( aRows, hRow )
    next
    
    ::Apply( { "rows" => aRows } )

return nil
