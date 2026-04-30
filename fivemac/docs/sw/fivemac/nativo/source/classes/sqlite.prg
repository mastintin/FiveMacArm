#include "FiveMac.ch"

// Class TSQLite
// Wrapper for native macOS libsqlite3

CLASS TSQLite

   DATA hDB
   DATA cFile
   DATA nError INIT 0
   DATA cError INIT ""

   DATA aResult     INIT {}
   DATA nCurrentRow INIT 0
   DATA lEof        INIT .T.
   DATA cTable      INIT ""
   DATA cOrder      INIT ""
   DATA aFields     INIT {}

   METHOD New( cFile, nFlags ) CONSTRUCTOR
   METHOD End() INLINE if( !Empty( ::hDB ), SQLite_Close( ::hDB ), )
   
   METHOD Query( cSql )
   METHOD Execute( cSql )
   METHOD TableUse( cTable )
   METHOD SelectDB( cDb ) INLINE ::Query( "ATTACH DATABASE '" + cDb + "' AS " + cDb )
   METHOD CreateDatabase( cFile ) INLINE ::SqliteCreateDb( cFile )
   METHOD OrdSetFocus( cOrder )
    
   METHOD SqliteUse( cFile )
   METHOD SqliteCreateDb( cFile )
   METHOD CreateTable( cTable, aFields )
    
   METHOD DelTable() 
   METHOD DelAllRec( cTable )   
   METHOD Delrecord()
   METHOD Insert( cTable, hData )
   METHOD Current()
   METHOD RowId() INLINE SQLite_LastInsertRowId( ::hDB )
   METHOD ValToSql( uVal )
    
   METHOD ErrorMsg() INLINE ::cError := SQLite_ErrMsg( ::hDB )

   // Navigation
   METHOD GoTop() 
   METHOD GoBottom()
   METHOD Skip( n )
   METHOD EOF()     INLINE ::lEof
   METHOD BOF()     INLINE ::nCurrentRow == 0
   METHOD RecCount() INLINE Len( ::aResult )
   METHOD RecNo()    INLINE ::nCurrentRow
   METHOD DbStruct()
   METHOD ImportFromDBF( cDbf, bProgress )
   METHOD ExportToDBF( cDbf, bProgress )
   METHOD SqlTypeToHb( cType )

   METHOD DbAppend() 
   METHOD FieldPos( cName )
   METHOD FieldName( n )
   METHOD FieldPutName( cName, uVal )
   METHOD FieldPut( n, uVal )
   METHOD FieldGetName( cName )
   METHOD DelRecord()
   METHOD FieldGet( n ) 

ENDCLASS

METHOD New( cFile, nFlags ) CLASS TSQLite

   ::cFile = cFile
   ::hDB   = SQLite_Open( cFile, nFlags )

   if Empty( ::hDB )
      MsgAlert( "Cannot open database: " + cFile )
   endif

return Self

METHOD SqliteUse( cFile ) CLASS TSQLite
   if ! File( cFile )
      MsgAlert( "Database not found: " + cFile )
      return nil
   endif
return ::New( cFile, 2 ) // SQLITE_OPEN_READWRITE

METHOD SqliteCreateDb( cFile ) CLASS TSQLite
return ::New( cFile, 6 ) // SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE

METHOD Execute( cSql ) CLASS TSQLite
   
   local nResult := SQLite_Exec( ::hDB, cSql )
   
   if nResult != 0
      ::nError = nResult
      ::ErrorMsg()
   else
      ::nError = 0
      ::cError = ""
   endif
   
return nResult

METHOD Query( cSql ) CLASS TSQLite
   
   local aRows
   
   aRows = SQLite_Query( ::hDB, cSql )
   
   if aRows == nil
      ::ErrorMsg()
      ::aResult := {}
      ::lEof    := .T.
      ::nCurrentRow := 0
   else
      ::aResult := aRows
      ::GoTop()
   endif
   
return aRows

METHOD TableUse( cTable ) CLASS TSQLite
   local aInfo
   ::cTable := cTable
   ::cOrder := ""
   
   // Get field names for FieldPut mapping
   aInfo := SQLite_Query( ::hDB, "PRAGMA table_info(" + cTable + ")" )
   ::aFields := {}
   if ! Empty( aInfo )
      AEval( aInfo, { | a | AAdd( ::aFields, a[ 2 ] ) } ) 
   endif

return ::Query( "SELECT rowid, * FROM " + cTable )

METHOD DelTable( cTable ) CLASS TSQLite
return ::Execute( "DROP TABLE " + cTable )

METHOD DelAllRec( cTable ) CLASS TSQLite
   DEFAULT cTable := ::cTable
return ::Execute( "DELETE FROM " + cTable )

METHOD OrdSetFocus( cOrder ) CLASS TSQLite
   ::cOrder := cOrder
   if ! Empty( ::cTable )
      if ! Empty( cOrder )
         return ::Query( "SELECT rowid, * FROM " + chr(34) + ::cTable + chr(34) + " ORDER BY " + cOrder )
      else
         return ::Query( "SELECT rowid, * FROM " + chr(34) + ::cTable + chr(34) )
      endif
   endif
return ::cOrder

METHOD DbStruct() CLASS TSQLite
   local aStruct := {}
   local aInfo, n, cType, nAt, nComma, cHbType
   if ! Empty( ::cTable )
      aInfo := SQLite_Query( ::hDB, "PRAGMA table_info(" + chr(34) + ::cTable + chr(34) + ")" )
      if ! Empty( aInfo )
         for n := 1 to Len( aInfo )
            cType := Upper( aInfo[ n ][ 3 ] )
            cHbType := ::SqlTypeToHb( cType )
            if ( nAt := At( "(", cType ) ) > 0
               nComma := At( ",", cType )
               if nComma > 0
                  AAdd( aStruct, { aInfo[ n ][ 2 ], ;
                     cHbType, ;
                     Val( SubStr( cType, nAt + 1, nComma - nAt - 1 ) ), ;
                     Val( SubStr( cType, nComma + 1, At( ")", cType ) - nComma - 1 ) ) } )
               else
                  AAdd( aStruct, { aInfo[ n ][ 2 ], ;
                     cHbType, ;
                     Val( SubStr( cType, nAt + 1, At( ")", cType ) - nAt - 1 ) ), ;
                     0 } )
               endif
            else
               if cHbType == "N" .and. ! ( "INT" $ cType )
                  AAdd( aStruct, { aInfo[ n ][ 2 ], cHbType, 16, 6 } ) 
               else
                  AAdd( aStruct, { aInfo[ n ][ 2 ], cHbType, 12, 0 } ) 
               endif
            endif
         next
      endif
   endif
return aStruct

METHOD SqlTypeToHb( cType ) CLASS TSQLite
   cType := Upper( cType )
   if "INT" $ cType ; return "N" ; endif
   if "CHAR" $ cType .or. "TEXT" $ cType ; return "C" ; endif
   if "BLOB" $ cType ; return "M" ; endif
   if "REAL" $ cType .or. "FLOA" $ cType .or. "DOUB" $ cType .or. "NUME" $ cType .or. "DECI" $ cType ; return "N" ; endif
   if "DATE" $ cType ; return "D" ; endif
   if "BOOL" $ cType ; return "L" ; endif
return "C"

METHOD DbAppend() CLASS TSQLite
   if ! Empty( ::cTable )
      ::Execute( "INSERT INTO " + chr(34) + ::cTable + chr(34) + " DEFAULT VALUES" )
      if ! Empty( ::cOrder )
         ::OrdSetFocus( ::cOrder )
      else
         ::TableUse( ::cTable )
      endif
      ::GoBottom()
   endif
return nil

METHOD FieldPos( cName ) CLASS TSQLite
   local nPos := AScan( ::aFields, { | c | Lower( c ) == Lower( cName ) } )
   if nPos == 0
      return nil
   endif
return nPos

METHOD FieldName( n ) CLASS TSQLite
return ::aFields[ n ]

METHOD FieldPutName( cName, uVal ) CLASS TSQLite
   local nPos
   nPos := ::FieldPos( cName )
   if nPos == nil
      return nil
   endif
return ::FieldPut( nPos, uVal )

METHOD FieldPut( n, uVal ) CLASS TSQLite
   local cSql, cVal, nRowId
   
   if Empty( ::cTable ) .or. ::nCurrentRow == 0 .or. ::nCurrentRow > Len( ::aResult )
      return nil
   endif

   if n < 1 .or. n > Len( ::aFields )
      return nil
   endif

   nRowId := Val( ::aResult[ ::nCurrentRow ][ 1 ] )
   cVal   := ::ValToSql( uVal )

   cSql := "UPDATE " + chr(34) + ::cTable + chr(34) + " SET " + chr(34) + ::aFields[ n ] + chr(34) + " = " + cVal + ;
      " WHERE rowid = " + AllTrim( Str( nRowId ) )
   
   if ::Execute( cSql ) == 0
      ::aResult[ ::nCurrentRow ][ n + 1 ] := cValToChar( uVal )
      return .T.
   endif

return .F.

METHOD FieldGetName( cName ) CLASS TSQLite
   local n := ::FieldPos( cName )
   if n != nil .and. n > 0
      return ::FieldGet( n )
   endif
return nil

METHOD DelRecord() CLASS TSQLite
   local nRowId, cSql
   
   if Empty( ::cTable ) .or. ::nCurrentRow == 0 .or. ::nCurrentRow > Len( ::aResult )
      return .F.
   endif

   nRowId := Val( ::aResult[ ::nCurrentRow ][ 1 ] )
   cSql   := "DELETE FROM " + chr(34) + ::cTable + chr(34) + " WHERE rowid = " + AllTrim( Str( nRowId ) )
   
   if ::Execute( cSql ) == 0
      ADel( ::aResult, ::nCurrentRow )
      ASize( ::aResult, Len( ::aResult ) - 1 )
      
      if ::nCurrentRow > Len( ::aResult )
         ::nCurrentRow := Len( ::aResult )
         if ::nCurrentRow == 0
            ::lEof := .T.
         endif
      endif
      return .T.
   endif

return .F.

METHOD GoTop() CLASS TSQLite
   if Len( ::aResult ) > 0
      ::nCurrentRow := 1
      ::lEof := .F.
   else
      ::nCurrentRow := 0
      ::lEof := .T.
   endif
return nil

METHOD GoBottom() CLASS TSQLite
   if Len( ::aResult ) > 0
      ::nCurrentRow := Len( ::aResult )
      ::lEof := .F.
   else
      ::nCurrentRow := 0
      ::lEof := .T.
   endif
return nil

METHOD Skip( n ) CLASS TSQLite
   DEFAULT n := 1
    
   if Len( ::aResult ) == 0
      ::lEof := .T.
      return nil
   endif

   ::nCurrentRow += n

   if ::nCurrentRow > Len( ::aResult )
      ::nCurrentRow := Len( ::aResult ) + 1
      ::lEof := .T.
   elseif ::nCurrentRow < 1
      ::nCurrentRow := 0
      ::lEof := .F. 
   else
      ::lEof := .F.
   endif
return nil

METHOD CreateTable( cTable, aStruct ) CLASS TSQLite
   local cSql := "CREATE TABLE IF NOT EXISTS " + chr(34) + cTable + chr(34) + " ( "
   local n, aField, cType
    
   for n := 1 to Len( aStruct )
      aField := aStruct[n]
      cType := Upper( aField[2] )
      
      cSql += chr(34) + aField[1] + chr(34) + " "
      
      do case
         case cType == "C" ; cSql += "TEXT"
         case cType == "N" ; cSql += "NUMERIC(" + AllTrim(Str(aField[3])) + "," + AllTrim(Str(aField[4])) + ")"
         case cType == "D" ; cSql += "TEXT" // SQLite prefers ISO dates as text
         case cType == "L" ; cSql += "INTEGER"
         case cType == "M" ; cSql += "BLOB"
            otherwise         ; cSql += "TEXT"
      endcase

      if n < Len( aStruct )
         cSql += ", "
      endif
   next
    
   cSql += " )"
    
return ::Execute( cSql )

METHOD FieldGet( n ) CLASS TSQLite
   local nOff := If( ! Empty( ::cTable ), 1, 0 ) 
   if ::nCurrentRow > 0 .and. ::nCurrentRow <= Len( ::aResult )
      if ( n + nOff ) > 0 .and. ( n + nOff ) <= Len( ::aResult[ ::nCurrentRow ] )
         return ::aResult[ ::nCurrentRow ][ n + nOff ]
      endif
   endif
return nil

METHOD Insert( cTable, hData ) CLASS TSQLite
   local cSql, cCols := "", cVals := ""
   local aKeys, n
   
   if ValType( cTable ) == "H"
      hData := cTable
      cTable := ::cTable
   endif

   if ValType( hData ) != "H" .or. Empty( cTable )
      return -1
   endif

   aKeys := hb_HKeys( hData )
   
   for n := 1 to Len( aKeys )
      cCols += chr(34) + aKeys[ n ] + chr(34)
      cVals += ::ValToSql( hData[ aKeys[ n ] ] )
      if n < Len( aKeys )
         cCols += ", "
         cVals += ", "
      endif
   next

   cSql := "INSERT INTO " + chr(34) + cTable + chr(34) + " (" + cCols + ") VALUES (" + cVals + ")"
   
return ::Execute( cSql )

METHOD Current() CLASS TSQLite
   local hRow := {=>}
   local n
   local nOff := If( ! Empty( ::cTable ), 1, 0 )
   if ::nCurrentRow > 0 .and. ::nCurrentRow <= Len( ::aResult )
      for n := 1 to Len( ::aFields )
         hRow[ ::aFields[ n ] ] := ::aResult[ ::nCurrentRow ][ n + nOff ]
      next
   endif
return hRow

METHOD ValToSql( uVal ) CLASS TSQLite
   local cVal
   do case
      case ValType( uVal ) == "C"
         cVal := "'" + StrTran( uVal, "'", "''" ) + "'"
      case ValType( uVal ) == "N"
         cVal := cValToChar( uVal )
      case ValType( uVal ) == "D"
         cVal := "'" + DToS( uVal ) + "'"
      case ValType( uVal ) == "L"
         cVal := If( uVal, "1", "0" )
         otherwise
         cVal := "NULL"
   endcase
return cVal

//----------------------------------------------------------------------------//

METHOD ImportFromDBF( cDbf, bProgress ) CLASS TSQLite

   local aStruct, nTotal, nDone := 0
   local cTable := FileNoPath( cDbf )
   local hData, n, nFld
   
   if ( n := At( ".", cTable ) ) > 0
      cTable := Left( cTable, n - 1 )
   endif

   if ! hb_FileExists( cDbf )
      return .f.
   endif

   dbUseArea( .T.,, cDbf, "DBF_SYNC", .T. )
   
   if NetErr()
      return .f.
   endif

   aStruct := DBF_SYNC->( dbStruct() )
   nTotal  := DBF_SYNC->( lastRec() )
   
   ::Execute( "DROP TABLE IF EXISTS " + chr(34) + cTable + chr(34) )
   ::CreateTable( cTable, aStruct )
   ::TableUse( cTable )
   
   DBF_SYNC->( dbGoTop() )
   nFld := Len( aStruct )

   while ! DBF_SYNC->( eof() )
      hData := {=>}
      for n := 1 to nFld
         hData[ aStruct[ n ][ 1 ] ] := DBF_SYNC->( FieldGet( n ) )
      next
      if ::Insert( hData ) == 0
         nDone++
         if bProgress != nil
            Eval( bProgress, nDone, nTotal )
            PUMPEVENTS()
         endif
      endif
      DBF_SYNC->( dbSkip() )
   end
   DBF_SYNC->( dbCloseArea() )

return nDone == nTotal

//----------------------------------------------------------------------------//

METHOD ExportToDBF( cDbf, bProgress ) CLASS TSQLite

   local aStruct := ::DbStruct()
   local nTotal := ::RecCount()
   local nDone := 0
   local n, nFld := Len( aStruct )
   local hRow, uVal, cType
   
   if nTotal == 0
      return .f.
   endif
   
   // Pre-sanitize structure to avoid "Data width error"
   for n := 1 to nFld
      if aStruct[ n ][ 2 ] == "N" .and. aStruct[ n ][ 3 ] < 20
         aStruct[ n ][ 3 ] := 20
      endif
   next

   if hb_FileExists( cDbf )
      FErase( cDbf )
   endif

   DbCreate( cDbf, aStruct )
   DbUseArea( .T.,, cDbf, "EXPORT_DBF", .T. )
      
   if NetErr()
      return .f.
   endif

   ::GoTop()
   while ! ::EOF()
      hRow := ::Current()
      EXPORT_DBF->( DbAppend() )
      for n := 1 to nFld
         uVal := hRow[ aStruct[ n ][ 1 ] ]
         cType := aStruct[ n ][ 2 ]
         do case
            case cType == "N" .and. ValType( uVal ) == "C"
               uVal := Val( uVal )
            case cType == "D" .and. ValType( uVal ) == "C"
               uVal := SToD( uVal )
            case cType == "L" .and. ValType( uVal ) == "C"
               uVal := ( uVal == "1" )
            case cType == "C" .and. ValType( uVal ) != "C"
               uVal := cValToChar( uVal )
         endcase
         EXPORT_DBF->( FieldPut( n, uVal ) )
      next
      nDone++
      if bProgress != nil
         Eval( bProgress, nDone, nTotal )
         PUMPEVENTS()
      endif
      ::Skip()
   end
   EXPORT_DBF->( DbCloseArea() )

return nDone == nTotal
