#include "FiveMac.ch"
#include "hbhash.ch"

// Class TSQLite
// Wraps native macOS sqlite3 library

CLASS TSQLite

   DATA hDB  // Handle to sqlite3 *
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
   METHOD End() INLINE SQLite_Close( ::hDB ), ::hDB := nil
   
   METHOD SqliteUse( cFile )
   METHOD SqliteCreateDb( cFile )

   METHOD Execute( cSql ) 
   METHOD Query( cSql )
   METHOD TableUse( cTable )
   METHOD OrdSetFocus( cOrder )
   METHOD DbAppend()
   METHOD FieldPut( n, uVal )
   METHOD FieldPutName( cName, uVal )   
   METHOD FieldGetName( cName )  
   METHOD FieldName() 
   METHOD FieldPos( cName )  
  
   METHOD DelRecord()
   METHOD CreateTable( cTable, aFields )
   METHOD DelTable() 
   METHOD DelAllRec( cTable )   
   METHOD Insert( cTable, hData )
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
   aInfo := ::Query( "PRAGMA table_info(" + cTable + ")" )
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
   return ::Query( "SELECT rowid, * FROM " + ::cTable + " ORDER BY " + cOrder )
   else
   return ::Query( "SELECT rowid, * FROM " + ::cTable )
   endif
   endif
return ::cOrder

METHOD DbAppend() CLASS TSQLite
   if ! Empty( ::cTable )
   ::Execute( "INSERT INTO " + ::cTable + " DEFAULT VALUES" )
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

   cSql := "UPDATE " + ::cTable + " SET " + ::aFields[ n ] + " = " + cVal + ;
      " WHERE rowid = " + AllTrim( Str( nRowId ) )
   
   if ::Execute( cSql ) == 0
   // Update buffer (remember rowid is at index 1)
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
   cSql   := "DELETE FROM " + ::cTable + " WHERE rowid = " + AllTrim( Str( nRowId ) )
   
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
   ::lEof := .F. // Matches DBF behavior where BOF() is a state not EOF
   else
   ::lEof := .F.
   endif
return nil

METHOD CreateTable( cTable, aFields ) CLASS TSQLite
   local cSql := "CREATE TABLE IF NOT EXISTS " + cTable + " ( "
   local n, aField
    
   for n := 1 to Len( aFields )
   aField := aFields[n]
   // aField[1] = Name, aField[2] = Type, aField[3] = Constraints (optional)
   cSql += aField[1] + " " + aField[2]
   if Len( aField ) >= 3 .and. !Empty( aField[3] )
   cSql += " " + aField[3]
   endif
   if n < Len( aFields )
   cSql += ", "
   endif
   next
    
   cSql += " )"
    
return ::Execute( cSql )

METHOD FieldGet( n ) CLASS TSQLite
   local nOff := If( ! Empty( ::cTable ), 1, 0 ) // Skip rowid if using TableUse
   if ::nCurrentRow > 0 .and. ::nCurrentRow <= Len( ::aResult )
   if ( n + nOff ) > 0 .and. ( n + nOff ) <= Len( ::aResult[ ::nCurrentRow ] )
   return ::aResult[ ::nCurrentRow ][ n + nOff ]
   endif
   endif
return nil

METHOD Insert( cTable, hData ) CLASS TSQLite
   local cSql, cCols := "", cVals := ""
   local aKeys, n
   
   if ValType( hData ) != "H"
   return -1
   endif

   aKeys := hb_HKeys( hData )
   
   for n := 1 to Len( aKeys )
   cCols += aKeys[ n ]
   cVals += ::ValToSql( hData[ aKeys[ n ] ] )
   if n < Len( aKeys )
   cCols += ", "
   cVals += ", "
   endif
   next

   cSql := "INSERT INTO " + cTable + " (" + cCols + ") VALUES (" + cVals + ")"
   
return ::Execute( cSql )

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
