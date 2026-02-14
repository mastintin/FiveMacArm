#include "FiveMac.ch"
#include "mysql.ch"

static oDb, oBrw, aRows

//----------------------------------------------------------------------------//

function Main()

    local oWnd, oBar
    local cHost := "134.0.10.187"
    local cUser := "mastintin"
    local cPass := "Mas_0210199999"
    local cDb   := "testfivemac"
    local nPort := 3306

    oDb = TMySQL():New( cHost, cUser, cPass, cDb, nPort )

    if oDb == nil
        return nil
    endif

    // Ensure table exists
    oDb:Execute( "CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), age INT)" )

    LoadData()

    DEFINE WINDOW oWnd TITLE "MySQL Users CRUD (" + cHost + ")" ;
        FROM 200, 200 TO 600, 800 FLIPPED

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

    oBrw:bLine     = { | nRow | If( nRow <= Len( aRows ), ;
        { cValToChar( aRows[ nRow ][ 1 ] ), ;
        cValToChar( aRows[ nRow ][ 2 ] ), ;
        cValToChar( aRows[ nRow ][ 3 ] ) }, ;
        { "", "", "" } ) }
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
    
    if oBrw != nil
        oBrw:Refresh()
    endif

return nil

//----------------------------------------------------------------------------//

function AddUser()

    local oDlg, cName := Space( 50 ), nAge := 0
    local lSave := .F.

    DEFINE DIALOG oDlg TITLE "Add User" SIZE 400, 200 FLIPPED

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

    nId   = aRows[ oBrw:nRowPos ][ 1 ] 
    cName = PadR( aRows[ oBrw:nRowPos ][ 2 ], 50 )
    nAge  = aRows[ oBrw:nRowPos ][ 3 ] 
    
    DEFINE DIALOG oDlg TITLE "Edit User (ID: " + cValToChar( nId ) + ")" SIZE 400, 200 FLIPPED

    @ 20, 20 SAY "Name:" OF oDlg
    @ 20, 80 GET cName OF oDlg SIZE 280, 24

    @ 50, 20 SAY "Age:" OF oDlg
    @ 50, 80 GET nAge OF oDlg SIZE 100, 24 PICTURE "999"

    @ 80, 80 BUTTON "Save" OF oDlg ACTION ( lSave := .T., oDlg:End() )
    @ 80, 200 BUTTON "Cancel" OF oDlg ACTION oDlg:End()

    ACTIVATE DIALOG oDlg CENTERED

    if lSave
        cName = AllTrim( cName )
        oDb:Execute( "UPDATE users SET name = '" + cName + "', age = " + cValToChar( nAge ) + " WHERE id = " + cValToChar( nId ) )
        LoadData()
    endif

return nil

//----------------------------------------------------------------------------//

function DeleteUser()

    local nId

    if Empty( aRows )
        return nil
    endif

    nId = aRows[ oBrw:nRowPos ][ 1 ]

    if MsgYesNo( "Are you sure you want to delete user ID " + cValToChar( nId ) + "?" )
        oDb:Execute( "DELETE FROM users WHERE id = " + cValToChar( nId ) )
        LoadData()
    endif

return nil
