// NiceTable.prg - Data Tables

//----------------------------------------------------------------------------//
// Nice Table
//----------------------------------------------------------------------------//

CLASS TNiceTable FROM TNiceControl
    DATA aCols INIT {}
    DATA aRows INIT {}
    DATA cTitle
   
    METHOD New( oParent, cTitle )
    METHOD AddCol( cName, cLabel, cField, cWidth )
    METHOD SetData( aRows )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
   
    METHOD _ColsToJson()
    METHOD _RowsToJson()
ENDCLASS

METHOD New( oParent, cTitle ) CLASS TNiceTable
    ::Super:New( oParent )
    ::cTitle := cTitle
    DEFAULT ::cTitle := "Table"
return Self

METHOD AddCol( cName, cLabel, cField, cWidth ) CLASS TNiceTable
    DEFAULT cField := cName
    DEFAULT cWidth := ""
    AAdd( ::aCols, { cName, cLabel, cField, cWidth } )
return nil

METHOD SetData( aRows ) CLASS TNiceTable
    ::aRows := aRows
    // If we supported dynamic updates:
    // ::oParent:oWeb:ScriptCallMethod( "window.updateModel('" + ::GetModelName() + "', " + ::_RowsToJson() + ")" )
return nil

METHOD GetHtml() CLASS TNiceTable
    local cHtml := '<q-table title="' + ::cTitle + '" '
   
    // Columns (Static for now)
    cHtml += ':columns="' + ::_ColsToJson() + '" '
   
    // Rows (Reactive)
    cHtml += ':rows="' + ::GetModelName() + '" '
   
    cHtml += 'row-key="id"' 
    cHtml += '></q-table>'
return cHtml

METHOD GetModelName() CLASS TNiceTable
return ::cId + "_rows"

METHOD GetModelValue() CLASS TNiceTable
return ::_RowsToJson()

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
                  
    cJson += " }"
    next
   
    cJson += "]"
return cJson

METHOD _RowsToJson() CLASS TNiceTable
    local cJson := "["
    local n, k, nLen
    local hRow
   
    for n := 1 to Len( ::aRows )
    if n > 1 
        cJson += ","
    endif
       
    cJson += "{"
    hRow := ::aRows[ n ]
    // Assume Array of Arrays matching columns order.
       
    nLen := Len( hRow ) 
    for k := 1 to nLen
    if k > 1
        cJson += ","
    endif
    if k <= Len( ::aCols )
        // FIX: Use If() instead of ? :
        cJson += ::aCols[ k ][ 3 ] + ": '" + If( ValType( hRow[k] ) $ "CM", hRow[k], hb_ValToStr( hRow[k] ) ) + "'"
    endif
    next
       
    // Implicit ID
    cJson += ", id: " + AllTrim( Str( n ) )
       
    cJson += "}"
    next
   
    cJson += "]"
return cJson
