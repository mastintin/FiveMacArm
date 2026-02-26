#include "Nice.ch"

// NiceTable.prg - Data Tables

//----------------------------------------------------------------------------//
// Nice Table
//----------------------------------------------------------------------------//

CLASS TNiceTable FROM TNiceControl
    DATA aCols INIT {}
    DATA aRows INIT {}
    DATA cTitle
    DATA cValue // Stores "row:ID:col:FIELD:val:VALUE"
    DATA bOnSave // Callback: {|oTbl, nRow, cField, uVal| ... }
    
    METHOD New( oParent, cTitle, cClass, cStyle )
    METHOD AddCol( cName, cLabel, cField, cWidth, lEditable )
    METHOD SetData( aRows )
    METHOD AddRow( aRow )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
    
    METHOD OnChange( cVal ) // Called by NiceCore when updateVal is received
    METHOD GetColIndex( cField )
    
    METHOD _ColsToJson()
    METHOD _RowsToJson()
ENDCLASS

METHOD New( oParent, cTitle, cClass, cStyle ) CLASS TNiceTable
    ::Super:New( oParent, cClass, cStyle )
    ::cTitle := cTitle
    DEFAULT ::cTitle := "Table"
return Self

METHOD AddCol( cName, cLabel, cField, cWidth, lEditable ) CLASS TNiceTable
    DEFAULT cLabel := cName
    DEFAULT cField := cName
    DEFAULT cWidth := ""
    DEFAULT lEditable := .F.
    AAdd( ::aCols, { cName, cLabel, cField, cWidth, lEditable } )
return nil

METHOD SetData( aRows ) CLASS TNiceTable
    ::aRows := aRows
return nil

METHOD AddRow( aRow ) CLASS TNiceTable
    AAdd( ::aRows, aRow )
return nil

METHOD GetHtml() CLASS TNiceTable
    local cHtml := '<q-table title="' + ::cTitle + '" '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    
    // Columns (Static for now)
    cHtml += ":columns='" + ::_ColsToJson() + "' "
    
    // Rows (Reactive)
    cHtml += ":rows='" + ::GetModelName() + "' "
    
    // Pagination: 0 for all rows by default
    cHtml += ":pagination='{rowsPerPage: 0}' "
    
    cHtml += 'row-key="id" ' 
    cHtml += '>'
    
    // Body Slot for Inline Editing
    cHtml += '<template v-slot:body="props">'
    cHtml += '<q-tr :props="props">'
    
    cHtml += '<q-td v-for="col in props.cols" :key="col.name" :props="props">'
    cHtml += '{{ props.row[col.name] }}'
    
    // Popup Edit
    cHtml += '<q-popup-edit v-if="col.editable" v-model="props.row[col.field]" v-slot="scope" '
    // Send update event: "row:ID:col:FIELD:val:VALUE"
    cHtml += '@save="updateVal( ' + "'" + ::cId + "', " + ;
        "'row:' + props.row.id + ':col:' + col.field + ':val:' + scope.value )" + '" >'
             
    cHtml += '<q-input v-model="scope.value" dense autofocus @keyup.enter="scope.set" />'
    cHtml += '</q-popup-edit>'
    
    cHtml += '</q-td>'
    cHtml += '</q-tr>'
    cHtml += '</template>'

    cHtml += '</q-table>'
return cHtml

METHOD GetModelName() CLASS TNiceTable
return ::cId + "_rows"

METHOD GetModelValue() CLASS TNiceTable
return ::_RowsToJson()

METHOD OnChange( cVal ) CLASS TNiceTable
    local aTokens := hb_ATokens( cVal, ":" )
    local nRowId, cField, uVal
    local nRow, nCol
    local cValStr
   
    // Format: row:ID:col:FIELD:val:VALUE
    if Len( aTokens ) >= 6 .and. aTokens[1] == "row" .and. aTokens[3] == "col" .and. aTokens[5] == "val"
    nRowId := Val( aTokens[2] )
    cField := aTokens[4]
      
    // Reassemble value if it contained colons
    cValStr := ""
    if Len( aTokens ) > 6
    // Join tokens starting from 6
    // ... implementation for rejoining if needed, similar to NiceCore fix
    // For now assume simple value
    cValStr := aTokens[6] 
    else
    cValStr := aTokens[6]
    endif
      
    // Update local array
    // ID uses implicit 1-based index from _RowsToJson
    if nRowId > 0 .and. nRowId <= Len( ::aRows )
    nCol := ::GetColIndex( cField )
    if nCol > 0
    // Update Array (Assume simple types for now)
    // Check original type to cast?
    if ValType( ::aRows[nRowId][nCol] ) == "N"
    ::aRows[nRowId][nCol] := Val( cValStr )
    else
    ::aRows[nRowId][nCol] := cValStr
    endif
             
    // Fire Callback
    if ::bOnSave != nil
    Eval( ::bOnSave, Self, nRowId, nCol, ::aRows[nRowId][nCol] )
    endif
    endif
    endif
    endif
return nil

METHOD GetColIndex( cField ) CLASS TNiceTable
    local n
    for n := 1 to Len( ::aCols )
    // aCols format: { Name, Label, Field, Width, Editable }
    if ::aCols[n][3] == cField
    return n
    endif
    next
return 0

//----------------------------------------------------------------------------//
// Helpers (Manual JSON)
//----------------------------------------------------------------------------//

METHOD _ColsToJson() CLASS TNiceTable
    local aCols := {}
    local n, hCol
   
    for n := 1 to Len( ::aCols )
    hCol := { ;
        "name"     => ::aCols[n][1], ;
        "label"    => ::aCols[n][2], ;
        "field"    => ::aCols[n][3], ;
        "align"    => "left", ;
        "sortable" => .T., ;
        "editable" => If( Len( ::aCols[n] ) >= 5, ::aCols[n][5], .F. ) ;
        }
    if !Empty( ::aCols[n][4] )
    hCol[ "style" ] := "width: " + ::aCols[n][4] + ";"
    hCol[ "headerStyle" ] := "width: " + ::aCols[n][4] + ";"
    endif
    AAdd( aCols, hCol )
    next
return hb_jsonEncode( aCols )

METHOD _RowsToJson() CLASS TNiceTable
    local aRows := {}
    local n, k, hRow, hNewRow, cField, uVal
    
    for n := 1 to Len( ::aRows )
    hRow := ::aRows[ n ]
    hNewRow := { "id" => n }
        
    for k := 1 to Len( ::aCols )
    cField := ::aCols[k][3]
    if ValType( hRow ) == "H"
    uVal := If( hb_HHasKey( hRow, cField ), hRow[cField], "" )
    else
    uVal := If( k <= Len( hRow ), hRow[k], "" )
    endif
    hNewRow[ cField ] := uVal
    next
    AAdd( aRows, hNewRow )
    next
return hb_jsonEncode( aRows )
