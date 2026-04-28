#include "swfive.ch"
 
 #define SW_TYPE_GRID 16
 
 CLASS TSwGrid FROM TSwiftControl
    
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, aColumns )
    METHOD AddRow()
    METHOD Clear()
    METHOD Update( hNewState )
     
 ENDCLASS
   
 //----------------------------------------------------------------------------//
   
 METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, aColumns ) CLASS TSwGrid
    
    local cJsonColumns := "["
    local n
    
    DEFAULT nWidth := 400, nHeight := 300, nAutoResize := 0, aColumns := {}
       
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    ::oWnd := oWnd
       
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
       
    ::hState["type"] := SW_TYPE_GRID
 
    ::Create()
 
    // Generar JSON para las columnas
    for n := 1 to Len( aColumns )
        if n > 1 ; cJsonColumns += "," ; endif
        cJsonColumns += "{"
        do case
           case Lower( aColumns[n][1] ) == "fixed"
                cJsonColumns += '"type":"fixed","size":' + hb_ntos( aColumns[n][2] )
           case Lower( aColumns[n][1] ) == "adaptive"
                cJsonColumns += '"type":"adaptive","min":' + hb_ntos( aColumns[n][2] )
                if Len( aColumns[n] ) >= 3 ; cJsonColumns += ',"max":' + hb_ntos( aColumns[n][3] ) ; endif
           otherwise // flexible
                cJsonColumns += '"type":"flexible"'
                if Len( aColumns[n] ) >= 2 ; cJsonColumns += ',"min":' + hb_ntos( aColumns[n][2] ) ; endif
                if Len( aColumns[n] ) >= 3 ; cJsonColumns += ',"max":' + hb_ntos( aColumns[n][3] ) ; endif
        endcase
        cJsonColumns += "}"
    next
    cJsonColumns += "]"
 
    ::Apply( { "columns" => cJsonColumns } )
    
 return Self
     
 //----------------------------------------------------------------------------//
     
 METHOD AddRow() CLASS TSwGrid
    // En un Grid, cada "Row" es en realidad una celda (ZStack contenedor)
    // Pero usamos TSwListRow por compatibilidad de lógica de construcción
    return TSwListRow():New( 0, 0, 0, 0, Self )
      
 //----------------------------------------------------------------------------//
   
 METHOD Clear() CLASS TSwGrid
    ::Apply( { "clear" => .T. } )
 return nil
   
 //----------------------------------------------------------------------------//
   
 METHOD Update( hNewState ) CLASS TSwGrid
    ::Super:Update( hNewState )
 return nil
