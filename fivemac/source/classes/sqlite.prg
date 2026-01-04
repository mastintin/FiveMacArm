#include "FiveMac.ch"

// Class TSQLite
// Wraps native macOS sqlite3 library

CLASS TSQLite

   DATA hDB  // Handle to sqlite3 *
   DATA cFile
   DATA nError INIT 0
   DATA cError INIT ""

   METHOD New( cFile ) CONSTRUCTOR
   METHOD End() INLINE SQLite_Close( ::hDB ), ::hDB := nil
   
   METHOD Execute( cSql ) 
   METHOD Query( cSql )
   METHOD Insert( cTable, aData ) // Helper for simple inserts
   METHOD RowId() INLINE SQLite_LastInsertRowId( ::hDB )
   
   METHOD ErrorMsg() INLINE ::cError := SQLite_ErrMsg( ::hDB )

ENDCLASS

METHOD New( cFile ) CLASS TSQLite

   ::cFile = cFile
   ::hDB   = SQLite_Open( cFile )

   if Empty( ::hDB )
      MsgAlert( "Cannot open database: " + cFile )
   endif

return Self

METHOD Execute( cSql ) CLASS TSQLite
   
   local nResult := SQLite_Exec( ::hDB, cSql )
   
   if nResult != 0
      ::nError = nResult
      ::ErrorMsg()
      // MsgAlert( "SQLite Error (" + AllTrim(Str(nResult)) + "): " + ::cError )
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
   endif
   
return aRows

METHOD Insert( cTable, aData ) CLASS TSQLite
   // aData: Hash or Array? Let's assume Hash { field => value } or simply build query manually
   // Keeping it simple for now, user builds INSERT string
return nil
