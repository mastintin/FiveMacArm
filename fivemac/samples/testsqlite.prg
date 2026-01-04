#include "FiveMac.ch"

static oDb, oBrw, aRows

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oBar
   local cDBName := Path() + "/test.db"

   oDb = TSQLite():New( cDBName )

   if oDb:hDB == nil
      MsgAlert( "Cannot open database: " + cDBName )
      return nil
   endif

   // Ensure table exists
   oDb:Execute( "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)" )

   LoadData()

   DEFINE WINDOW oWnd TITLE "SQLite Users CRUD (" + cDBName + ")" ;
      FROM 200, 200 TO 600, 800

   DEFINE TOOLBAR oBar OF oWnd

   DEFINE BUTTON OF oBar PROMPT "Add" IMAGE ImgNamed( "NSTouchBarAddTemplate" ) ;
      ACTION AddUser()

   DEFINE BUTTON OF oBar PROMPT "Edit" IMAGE ImgNamed( "NSTouchBarComposeTemplate" ) ;
      ACTION EditUser()

   DEFINE BUTTON OF oBar PROMPT "Delete" IMAGE ImgNamed( "NSTouchBarDeleteTemplate" ) ;
      ACTION DeleteUser()

   DEFINE BUTTON OF oBar PROMPT "Exit" IMAGE ImgNamed( "NSStopProgressTemplate" ) ;
      ACTION oWnd:End()

   @ 30, 10 BROWSE oBrw OF oWnd ;
      SIZE oWnd:nWidth - 20, oWnd:nHeight - 40 ;
      HEADERS "ID", "Name", "Age" ;
      FIELDS "", "", ""

   oBrw:SetColWidth( 1, 50 )
   oBrw:SetColWidth( 2, 300 )
   oBrw:SetColWidth( 3, 100 )

   oBrw:bLine     = { | nRow | If( nRow <= Len( aRows ), aRows[ nRow ], { "", "", "" } ) }
   oBrw:bLogicLen = { || Len( aRows ) }
   oBrw:cAlias    = "_ARRAY"
   oBrw:Refresh()
   
   ACTIVATE WINDOW oWnd ;
      VALID ( oDb:End(), .T. )

return nil

//----------------------------------------------------------------------------//

function LoadData()

   aRows = oDb:Query( "SELECT * FROM users ORDER BY id" )
   
   if ValType( aRows ) != "A"
      aRows = {}
   endif
   
   MsgInfo( "Loaded " + AllTrim( Str( Len( aRows ) ) ) + " rows" )

   if oBrw != nil
      oBrw:Refresh()
   endif

return nil

//----------------------------------------------------------------------------//

function AddUser()

   local oDlg, cName := Space( 50 ), nAge := 0
   local lSave := .F.

   DEFINE DIALOG oDlg TITLE "Add User" SIZE 400, 200

   @ 20, 20 SAY "Name:" OF oDlg
   @ 20, 80 GET cName OF oDlg SIZE 280, 24

   @ 50, 20 SAY "Age:" OF oDlg
   @ 50, 80 GET nAge OF oDlg SIZE 100, 24 PICTURE "999"

   @ 80, 80 BUTTON "Save" OF oDlg ACTION ( lSave := .T., oDlg:End() )
   @ 80, 200 BUTTON "Cancel" OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

   if lSave
      cName = AllTrim( cName )
      oDb:Execute( "INSERT INTO users (name, age) VALUES ('" + cName + "', " + AllTrim( Str( nAge ) ) + ")" )
      LoadData()
   endif

return nil

//----------------------------------------------------------------------------//

function EditUser()

   local oDlg, cName, nAge, nId
   local lSave := .F.

   if Empty( aRows )
      return nil
   endif

   nId   = Val( aRows[ oBrw:nRowPos ][ 1 ] ) // Integer ID
   cName = PadR( aRows[ oBrw:nRowPos ][ 2 ], 50 )
   nAge  = Val( aRows[ oBrw:nRowPos ][ 3 ] ) // It might be a string in array from sqlite C wrapper? 
                                             // C wrapper: hb_itemPutC implies strings. 
                                             // Let's verify. If Query returns strings for everything, we use Val().
                                             // My C code used hb_itemPutC for everything from argv. So yes, strings.
   
   DEFINE DIALOG oDlg TITLE "Edit User (ID: " + AllTrim(Str(nId)) + ")" SIZE 400, 200

   @ 20, 20 SAY "Name:" OF oDlg
   @ 20, 80 GET cName OF oDlg SIZE 280, 24

   @ 50, 20 SAY "Age:" OF oDlg
   @ 50, 80 GET nAge OF oDlg SIZE 100, 24 PICTURE "999"

   @ 80, 80 BUTTON "Save" OF oDlg ACTION ( lSave := .T., oDlg:End() )
   @ 80, 200 BUTTON "Cancel" OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

   if lSave
      if ValType( nAge ) == "C"; nAge = Val( nAge ); endif
      if ValType( nId ) == "C"; nId = Val( nId ); endif
      cName = AllTrim( cName )
      oDb:Execute( "UPDATE users SET name = '" + cName + "', age = " + AllTrim( Str( nAge ) ) + " WHERE id = " + AllTrim( Str( nId ) ) )
      LoadData()
   endif

return nil

//----------------------------------------------------------------------------//

function DeleteUser()

   local nId

   if Empty( aRows )
      return nil
   endif

   nId = Val( aRows[ oBrw:nRowPos ][ 1 ] )

   if MsgYesNo( "Are you sure you want to delete user ID " + AllTrim( Str( nId ) ) + "?" )
      oDb:Execute( "DELETE FROM users WHERE id = " + AllTrim( Str( nId ) ) )
      LoadData()
   endif

return nil
