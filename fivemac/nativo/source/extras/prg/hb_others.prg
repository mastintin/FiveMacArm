/*
 * hb_others.prg  A library for creating Excel XLSX worksheet files.
 *
 * Used in conjunction with the libxlsxwriter library of
 * John McNamara, jmcnamara@cpan.org. See LICENSE.txt.
 */
/*
 * Adapted for Harbour by Riztan Gutierrez, riztan@gmail.com
 *
 */

#include "Fivemac.ch"

FUNCTION hb_lxw_dv( hDV, cKey, uValue )

   LOCAL aKey

   aKey := { "validate", "criteria", "ignore_blank", ;
      "show_input", "show_error", "error_type", ;
      "dropdown", "is_between", "value_number", ;
      "value_formula", "value_list", "value_datetime", ;
      "minimum_number", "minimum_formula", "minimum_datetime", ;
      "maximum_number", "maximum_formula", "maximum_datetime", ;
      "input_title", "input_message", "error_title", ;
      "error_message" }

   IF AScan( aKey, {| key| key == cKey } ) = 0
   RETURN .F.
   ENDIF

   hb_HSet( hDV, cKey, uValue )

RETURN .T.



FUNCTION XLSWrite( oSheet, nRow, nCol, uVal, oFmt )

   DO CASE
   CASE ValType( uVal ) == "N"
   worksheet_write_number( oSheet, nRow, nCol, uVal, oFmt )
   CASE ValType( uVal ) == "D" .OR. ValType( uVal ) == "T"
   worksheet_write_datetime( oSheet, nRow, nCol, uVal, oFmt )
   CASE ValType( uVal ) == "L"
   worksheet_write_boolean( oSheet, nRow, nCol, iif( uVal, 1, 0 ), oFmt )
   OTHERWISE
   worksheet_write_string( oSheet, nRow, nCol, cValToChar( uVal ), oFmt )
   ENDCASE

RETURN NIL

FUNCTION XLS_COL( uCol )

   IF ValType( uCol ) == "C"
   RETURN LXW_COLUMN( uCol )
   ENDIF

RETURN uCol

FUNCTION LXW_COLUMN( cCol )
   LOCAL nCol := 0
   LOCAL i, nLen
   
   IF ValType( cCol ) != "C"
   RETURN cCol
   ENDIF

   cCol := Upper( AllTrim( cCol ) )
   nLen := Len( cCol )
   
   FOR i := 1 TO nLen
   nCol := nCol * 26 + ( Asc( SubStr( cCol, i, 1 ) ) - Asc( "A" ) + 1 )
   NEXT

RETURN nCol - 1

//----------------------------------------------------------------------------//

FUNCTION FMdbftoxlsx( cXlsx, cAlias )

   local oWk, oSh, oHeader
   local nFields, i, nRow := 1
   local uVal, nOldRec := 0

   DEFAULT cAlias := Alias()
   
   if empty( cAlias )
   return .F.
   endif

   DEFAULT cXlsx := cAlias + ".xlsx"

   CREATE XLS oWk FILE cXlsx
   
   if empty( oWk )
   return .F.
   endif

   DEFINE XLS FORMAT oHeader BOOK oWk
   SET XLS FORMAT oHeader BOLD .T.
   
   ADD SHEET oSh NAME cAlias BOOK oWk

   nFields := ( cAlias )->( FCount() )

   // Headers
   for i := 1 to nFields
   @ 0, i - 1 XLS WRITE ( cAlias )->( FieldName( i ) ) FORMAT oHeader SHEET oSh
   next

   // Data
   nOldRec := ( cAlias )->( RecNo() )
   ( cAlias )->( dbGoTop() )

   while ! ( cAlias )->( eof() )
   for i := 1 to nFields
   uVal := ( cAlias )->( FieldGet( i ) )
   @ nRow, i - 1 XLS WRITE uVal SHEET oSh
   next
   nRow++
   ( cAlias )->( dbSkip() )
   end

   ( cAlias )->( dbGoto( nOldRec ) )

   CLOSE XLS oWk

return .T.

//----------------------------------------------------------------------------//

FUNCTION FMsqlitetoxlsx( cXlsx, oSql )

   local oWk, oSh, oHeader
   local aFields, aStruct, i, nRow := 1
   local hRow, uVal, cType
   
   if empty( oSql ) .or. ValType( oSql ) != "O"
   return .F.
   endif

   DEFAULT cXlsx := oSql:cTable + ".xlsx"

   CREATE XLS oWk FILE cXlsx
   
   if empty( oWk )
   return .F.
   endif

   DEFINE XLS FORMAT oHeader BOOK oWk
   SET XLS FORMAT oHeader BOLD .T.
   
   ADD SHEET oSh NAME Left( oSql:cTable, 31 ) BOOK oWk

   aFields := oSql:aFields
   aStruct := oSql:DbStruct()
   
   // Headers
   for i := 1 to Len( aFields )
   @ 0, i - 1 XLS WRITE aFields[ i ] FORMAT oHeader SHEET oSh
   next

   // Data
   oSql:GoTop()
   while ! oSql:EOF()
   hRow := oSql:Current()
   for i := 1 to Len( aFields )
   uVal := hRow[ aFields[ i ] ]
   // Intento de conversión basado en la estructura de SQLite
   if i <= Len( aStruct )
   cType := aStruct[ i ][ 2 ]
   do case
   case cType == "N" .and. ValType( uVal ) == "C"
   uVal := Val( uVal )
   case cType == "D" .and. ValType( uVal ) == "C"
   uVal := SToD( uVal )
   case cType == "L" .and. ValType( uVal ) == "C"
   uVal := ( uVal == "1" )
   endcase
   endif
   @ nRow, i - 1 XLS WRITE uVal SHEET oSh
   next
   nRow++
   oSql:Skip()
   end

   CLOSE XLS oWk

return .T.

//----------------------------------------------------------------------------//

FUNCTION FMsqlquerytoxlsx( cXlsx, oSql, cSql )

   local oWk, oSh, oHeader
   local aFields, i, nRow := 1
   local aResult, aRow, uVal

   if empty( oSql ) .or. ValType( oSql ) != "O"
   return .F.
   endif

   if empty( cSql )
   return .F.
   endif

   // Obtener cabeceras usando la nueva función C
   aFields := SQLITE_COLUMN_NAMES( oSql:hDB, cSql )
   
   if empty( aFields )
   return .F.
   endif

   // Ejecutar la consulta
   aResult := SQLite_Query( oSql:hDB, cSql )

   DEFAULT cXlsx := "query_result.xlsx"

   CREATE XLS oWk FILE cXlsx
   
   if empty( oWk )
   return .F.
   endif

   DEFINE XLS FORMAT oHeader BOOK oWk
   SET XLS FORMAT oHeader BOLD .T.
   
   ADD SHEET oSh NAME "Query Result" BOOK oWk

   // Headers
   for i := 1 to Len( aFields )
   @ 0, i - 1 XLS WRITE aFields[ i ] FORMAT oHeader SHEET oSh
   next

   // Data
   if ! empty( aResult )
   for nRow := 1 to Len( aResult )
   aRow := aResult[ nRow ]
   for i := 1 to Len( aFields )
   uVal := aRow[ i ]
   @ nRow, i - 1 XLS WRITE uVal SHEET oSh
   next
   next
   endif

   CLOSE XLS oWk

return .T.

//----------------------------------------------------------------------------//
