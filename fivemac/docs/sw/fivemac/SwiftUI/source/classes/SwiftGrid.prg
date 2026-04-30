#include "FiveMac.ch"

static aGrids := {}

CLASS TSwiftGrid FROM TSwiftList

    METHOD New( nRow, nCol, nWidth, nHeight, aColumns, oWnd )
    METHOD End()

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, aColumns, oWnd, nAutoResize ) CLASS TSwiftGrid

    local cJson := "["
    local n

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault()
    DEFAULT aColumns := {}, nAutoResize := 0

    ::oWnd = oWnd
    ::cId := ""
    
    AAdd( aGrids, Self )
    
    for n := 1 to Len( aColumns )
        if n > 1
             cJson += ","
        endif
        cJson += "{"
        do case
        case Lower( aColumns[n][1] ) == "fixed"
            cJson += '"type":"fixed","size":' + AllTrim( Str( aColumns[n][2] ) )
        case Lower( aColumns[n][1] ) == "flexible"
            cJson += '"type":"flexible"'
            if Len( aColumns[n] ) >= 2; cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) ); endif
            if Len( aColumns[n] ) >= 3; cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) ); endif
        case Lower( aColumns[n][1] ) == "adaptive"
            cJson += '"type":"adaptive"'
            if Len( aColumns[n] ) >= 2; cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) ); endif
            if Len( aColumns[n] ) >= 3; cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) ); endif
        endcase
        
        cJson += "}"
    next
    cJson += "]"

    ::hWnd = SD_SWIFT_GRID_CREATE( nRow, nCol, nWidth, nHeight, oWnd:hWnd, ::cId, cJson )
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif
    
    oWnd:AddControl( Self )

return Self

METHOD End() CLASS TSwiftGrid
    if !Empty( ::hWnd )
       // El registro global se limpia en TSwiftList:End() si lo llamamos,
       // pero aquí limpiamos la tabla local aGrids
       AScan( aGrids, { |o, i| If( o != nil .and. o:cId == ::cId, aGrids[ i ] := nil, ) } )
    endif
return ::Super:End()
