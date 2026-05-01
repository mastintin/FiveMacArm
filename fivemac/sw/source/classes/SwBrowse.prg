#include "swfive.ch"

#define SW_TYPE_BROWSE 27

CLASS TSwBrowse FROM TSwiftControl

    DATA aCols INIT {}
    DATA aRows INIT {}
    DATA bLDblClick

    METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId )
    METHOD AddColumn( cTitle, nWidth, cField )
    METHOD SetArray( aData )
    METHOD SetCellValue( nRow, nCol, uVal )
    METHOD Update( hNewState )
    
    // Nuevos métodos para lógica dinámica
    METHOD SetBackColor( nCol, bColor )
    METHOD SetColImg( nCol, bImg )
    
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

METHOD SetBackColor( nCol, bColor ) CLASS TSwBrowse
   if nCol > 0 .and. nCol <= Len( ::aCols )
      ::aCols[ nCol ][ "bClrBack" ] := bColor
   endif
return nil

//----------------------------------------------------------------------------//

METHOD SetColImg( nCol, bImg ) CLASS TSwBrowse
   if nCol > 0 .and. nCol <= Len( ::aCols )
      ::aCols[ nCol ][ "bImg" ] := bImg
   endif
return nil

//----------------------------------------------------------------------------//

METHOD SetArray( aData ) CLASS TSwBrowse

    local aRows := {}
    local n, i, hRow, aKeys, cField, uVal
    
    if Len( aData ) > 0 .and. Empty( ::aCols )
       if hb_IsHash( aData[ 1 ] )
          aKeys := hb_HKeys( aData[ 1 ] )
          for i := 1 to Len( aKeys )
             ::AddColumn( aKeys[ i ], 100, aKeys[ i ] )
          next
       elseif hb_IsArray( aData[ 1 ] )
          for i := 1 to Len( aData[ 1 ] )
             ::AddColumn( "Col " + AllTrim( Str( i ) ), 100, "col" + AllTrim( Str( i ) ) )
          next
       endif
    endif

    for n := 1 to Len( aData )
        hRow := { "id" => AllTrim( Str( n ) ) }
        
        // 1. Poblado básico de datos
        if hb_IsHash( aData[ n ] )
           aKeys := hb_HKeys( aData[ n ] )
           for i := 1 to Len( aKeys )
              hRow[ aKeys[ i ] ] := cValToChar( aData[ n ][ aKeys[ i ] ] )
           next
        else 
           for i := 1 to Len( ::aCols )
               if i <= Len( aData[ n ] )
                  hRow[ ::aCols[ i ][ "field" ] ] := cValToChar( aData[ n ][ i ] )
               endif
           next
        endif
        
        // 2. Decoración dinámica (Colores e Imágenes)
        for i := 1 to Len( ::aCols )
           cField := ::aCols[ i ][ "field" ]
           uVal   := hRow[ cField ]
           
           if hb_HHasKey( ::aCols[ i ], "bClrBack" )
              hRow[ cField + "_color" ] := Eval( ::aCols[ i ][ "bClrBack" ], uVal, n, i, hRow )
           endif
           
           if hb_HHasKey( ::aCols[ i ], "bImg" )
              hRow[ cField + "_img" ] := Eval( ::aCols[ i ][ "bImg" ], uVal, n, i, hRow )
           endif
        next

        AAdd( aRows, hRow )
    next
    
    ::aRows := aRows
    ::Apply( { "rows" => aRows } )

return nil

//----------------------------------------------------------------------------//

METHOD SetCellValue( nRow, nCol, uVal ) CLASS TSwBrowse

    local hRow, cField, cVal
    
    if nRow > 0 .and. nRow <= Len( ::aRows ) .and. nCol > 0 .and. nCol <= Len( ::aCols )
       
       hRow   := ::aRows[ nRow ]
       cField := ::aCols[ nCol ][ "field" ]
       cVal   := cValToChar( uVal )
       
       hRow[ cField ] := cVal
       
       // Re-evaluar decoración para esta celda
       if hb_HHasKey( ::aCols[ nCol ], "bClrBack" )
          hRow[ cField + "_color" ] := Eval( ::aCols[ nCol ][ "bClrBack" ], cVal, nRow, nCol, hRow )
       endif
       
       if hb_HHasKey( ::aCols[ nCol ], "bImg" )
          hRow[ cField + "_img" ] := Eval( ::aCols[ nCol ][ "bImg" ], cVal, nRow, nCol, hRow )
       endif
       
       // Enviar solo la fila actualizada
       ::Apply( { "row_update" => hRow } )
       
    endif

return nil

//----------------------------------------------------------------------------//

METHOD Update( hNewState ) CLASS TSwBrowse

    if hb_HHasKey( hNewState, "event" ) .and. hNewState[ "event" ] == "dblclick"
       if hb_IsBlock( ::bLDblClick )
          Eval( ::bLDblClick, Self, hb_HGetDef( hNewState, "rowid", "" ) )
       endif
    endif

return ::Super:Update( hNewState )
