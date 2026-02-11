#include "FiveMac.ch"
#include "sqlite.ch"

function Main()

    local oDb
    local aData
    local hData := { => }
   
    SQLITE CONNECT Path() + "/test.db" CREATE INTO oDb
    
    if Empty( oDb:hDB )
    return nil
    endif

    // Use the new CreateTable command
    SQLITE CREATE TABLE "test" FIELDS { ;
        { "id",   "INTEGER", "PRIMARY KEY" },;
        { "name", "TEXT",    "" },;
        { "age",  "INTEGER", "" } ;
        } IN oDb
    
    // Clean it up for fresh test
    oDb:DelAllRec( "test" )
    
    // Activate table to load metadata (required for name-based accessors)
    SQLITE USE "test" IN oDb
    
    // Insert some test data
    hData[ "name" ] := "HashUser"
    hData[ "age" ] := 33

    SQLITE INSERT INTO "test" HASH hData IN oDb

    SQLITE APPEND IN oDb
    SQLITE REPLACE "name" WITH "Manuel" IN oDb
    SQLITE REPLACE "age" WITH 50 IN oDb
   
    SQLITE APPEND IN oDb
    SQLITE REPLACE "name" WITH "Antonino" IN oDb
    SQLITE REPLACE "age" WITH 45 IN oDb
   
    SQLITE APPEND IN oDb
    SQLITE REPLACE "name" WITH "FiveMac" IN oDb
    SQLITE REPLACE "age" WITH 10 IN oDb

    MsgInfo( "Data inserted. Testing TableUse and OrdSetFocus..." )

    // Test TableUse
    SQLITE USE "test" IN oDb
    MsgInfo( "TableUse('test') -> RecCount: " + Str( oDb:RecCount() ) )

    // Test OrdSetFocus (by Name)
    SQLITE USE "test" IN oDb ORDER "name"
    oDb:GoTop()
    MsgInfo( "Ordered by Name -> First: " + cValToChar( oDb:FieldGet( 2 ) ) )

    // Test OrdSetFocus (by Age)
    SQLITE USE "test" IN oDb ORDER "age"
    oDb:GoTop()
    MsgInfo( "Ordered by Age -> First: " + cValToChar( oDb:FieldGet( 2 ) ) )

    // Test Hash-based Insert
    MsgInfo( "Testing Hash-based Insert..." )
    SQLITE INSERT INTO "test" HASH { "name" => "HashUser2", "age" => 44 } IN oDb
    
    // Refresh to see the new record
    SQLITE USE "test" IN oDb
    oDb:GoBottom()
    MsgInfo( "After Hash Insert -> RecNo: " + Str( oDb:RecNo() ) + ;
        " Name: " + cValToChar( oDb:FieldGetName( "name" ) ) + ;
        " Age: " + cValToChar( oDb:FieldGetName( "age" ) ) )

    // Test DelRecord
    MsgInfo( "Testing DelRecord..." )
    SQLITE DELETE IN oDb
    MsgInfo( "After DelRecord -> RecCount: " + Str( oDb:RecCount() ) )

    // Perform manual query (still possible)
    aData := oDb:Query( "SELECT * FROM test WHERE age > 20" )
   
    if aData == nil
    MsgAlert( "Query failed" )
    return nil
    endif

    MsgInfo( "RecCount: " + Str( oDb:RecCount() ) )

    // Navigate like a DBF
    oDb:GoTop()
    MsgInfo( "GoTop -> RecNo: " + Str( oDb:RecNo() ) + " Name: " + cValToChar( oDb:FieldGet( 2 ) ) )

    oDb:Skip()
    MsgInfo( "Skip -> RecNo: " + Str( oDb:RecNo() ) + " Name: " + cValToChar( oDb:FieldGet( 2 ) ) )

    oDb:Skip()
    MsgInfo( "Skip -> RecNo: " + Str( oDb:RecNo() ) + " Name: " + cValToChar( oDb:FieldGet( 2 ) ) )

    oDb:Skip()
    if oDb:EOF()
    MsgInfo( "Reached EOF" )
    endif

    oDb:GoTop()
    while ! oDb:EOF()
    MsgInfo( "Loop -> RecNo: " + Str( oDb:RecNo() ) + ": " + cValToChar( oDb:FieldGet( 2 ) ) )
    oDb:Skip()
    enddo

    SQLITE CLOSE oDb

return nil
