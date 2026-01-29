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
    
    METHOD New( oParent, cTitle )
    METHOD AddCol( cName, cLabel, cField, cWidth, lEditable )
    METHOD SetData( aRows )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
    
    METHOD OnChange( cVal ) // Called by NiceCore when updateVal is received
    METHOD GetColIndex( cField )
    
    METHOD _ColsToJson()
    METHOD _RowsToJson()
ENDCLASS

METHOD New( oParent, cTitle ) CLASS TNiceTable
    ::Super:New( oParent )
    ::cTitle := cTitle
    DEFAULT ::cTitle := "Table"
return Self

METHOD AddCol( cName, cLabel, cField, cWidth, lEditable ) CLASS TNiceTable
    DEFAULT cField := cName
    DEFAULT cWidth := ""
    DEFAULT lEditable := .F.
    AAdd( ::aCols, { cName, cLabel, cField, cWidth, lEditable } )
return nil

METHOD SetData( aRows ) CLASS TNiceTable
    ::aRows := aRows
return nil

METHOD GetHtml() CLASS TNiceTable
    local cHtml := '<q-table title="' + ::cTitle + '" '
    
    // Columns (Static for now)
    cHtml += ':columns="' + ::_ColsToJson() + '" '
    
    // Rows (Reactive)
    cHtml += ':rows="' + ::GetModelName() + '" '
    
    cHtml += 'row-key="id" ' 
    cHtml += '>'
    
    // Body Slot for Inline Editing
    cHtml += '<template v-slot:body="props">'
    cHtml += '<q-tr :props="props">'
    
    cHtml += '<q-td v-for="col in props.cols" :key="col.name" :props="props">'
    cHtml += '{{ props.row[col.field] }}'
    
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
    local cJson := "["
    local n, cStyle
   
    for n := 1 to Len( ::aCols )
    if n > 1 
    cJson += ","
    endif
       
    cStyle := ""
    if !Empty( ::aCols[n][4] )
    cStyle := "width: " + ::aCols[n][4] + ";"
    endif
       
    cJson += "{ name: '" + ::aCols[n][1] + "', " + ;
        "label: '" + ::aCols[n][2] + "', " + ;
        "field: '" + ::aCols[n][3] + "', " + ;
        "align: 'left', sortable: true"
       
    if !Empty( cStyle )
    cJson += ", style: '" + cStyle + "', headerStyle: '" + cStyle + "'"
    endif
    
    // Editable flag
    if Len( ::aCols[n] ) >= 5 .and. ::aCols[n][5]
    cJson += ", editable: true"
    endif
                  
    cJson += " }"
    next
   
    cJson += "]"
return cJson

METHOD _RowsToJson() CLASS TNiceTable
    local cJson := "["
    local n, k
    local hRow, uVal, cField
   
    for n := 1 to Len( ::aRows )
    if n > 1 
    cJson += ","
    endif
       
    cJson += "{"
    hRow := ::aRows[ n ]
       
    for k := 1 to Len( ::aCols )
    if k > 1
    cJson += ","
    endif
        
    cField := ::aCols[ k ][ 3 ]
        
    // Get value based on Row Type (Hash or Array)
    if ValType( hRow ) == "H"
    if hb_HHasKey( hRow, cField )
    uVal := hRow[ cField ]
    else
    uVal := "" 
    endif
    elseif ValType( hRow ) == "A"
    if k <= Len( hRow )
    uVal := hRow[ k ]
    else
    uVal := ""
    endif
    else
    uVal := ""
    endif
        
    // Serialize
    cJson += cField + ": '" + If( ValType( uVal ) $ "CM", uVal, hb_ValToStr( uVal ) ) + "'"
    next
       
    // Implicit ID
    cJson += ", id: " + AllTrim( Str( n ) )
       
    cJson += "}"
    next
   
    cJson += "]"
return cJson
