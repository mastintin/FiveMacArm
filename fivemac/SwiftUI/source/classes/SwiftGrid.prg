#include "FiveMac.ch"

static aGrids := {}

CLASS TSwiftGrid FROM TSwiftList

    METHOD New( nRow, nCol, nWidth, nHeight, aColumns, oWnd )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, aColumns, oWnd, nAutoResize ) CLASS TSwiftGrid

    local cJson := "["
    local n

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault()
    DEFAULT aColumns := {}, nAutoResize := 0

    ::oWnd = oWnd
    ::cId = hb_UUID()
    
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

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif
    
    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------//

function SwiftGridOnClick( cGridId, nItemIndex )
    local nPos := AScan( aGrids, { |o| o != nil .and. o:cId == cGridId } )
    local oGrid

    if nPos > 0
        oGrid = aGrids[ nPos ]
        if oGrid:bAction != nil
            Eval( oGrid:bAction, nItemIndex )
        endif
    endif

return nil

function SwiftGridOnAction( cGridId, cId )
    local nPos := AScan( aGrids, { |o| o != nil .and. o:cId == cGridId } )
    local oGrid
    local uVal

    if nPos > 0
        oGrid = aGrids[ nPos ]
           
        // Try to resolve ID via Hash
        if __ObjHasMsg( oGrid, "GETITEM" )
            uVal := oGrid:GetItem( cId )
        endif
           
        if valtype( uVal ) == "N" // Found Index!
            if oGrid:bAction != nil
                Eval( oGrid:bAction, uVal )
            endif
        elseif valtype( uVal ) == "O" // Found Object!
            if __ObjHasMsg( uVal, "BACTION" ) .and. uVal:bAction != nil
                Eval( uVal:bAction, uVal )
            endif
        endif
    endif

return nil
