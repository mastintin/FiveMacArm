#include "FiveMac.ch"
#include "mysql.ch"

function Main()

    // Remote
    // local cHost := "134.0.10.187"
    // local cUser := "mastintin"
    // local cPass := "Mas_0210199999"
    // local cDb   := "testfivemac"
    
    // Local
    local cHost := "127.0.0.1"
    local cUser := "testuser"
    local cPass := "test"
    local cDb   := "testfivemac"
    
    
    local nPort := 3306
    local oDb

    // 1. Connect (without DB first)
    MYSQL CONNECT "" HOST cHost USER cUser PASSWORD cPass PORT nPort INTO oDb
   
    if oDb == nil
        return nil
    endif

    // 2. Create and Select DB
    oDb:SelectDB( cDb, .T. )

    MsgInfo( "Connected to MySQL!" )

    // 2. Query
    MYSQL QUERY "CREATE TABLE IF NOT EXISTS test_fivemac ( id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50), city VARCHAR(50) )" IN oDb
   
    // 3. Clear and Insert
    MYSQL QUERY "DELETE FROM test_fivemac" IN oDb
   
    MYSQL INSERT "test_fivemac" IN oDb HASH { "name" => "Antonio", "city" => "Marbella" }
    MYSQL INSERT "test_fivemac" IN oDb HASH { "name" => "Manuel",  "city" => "Sevilla" }
    MYSQL INSERT "test_fivemac" IN oDb HASH { "name" => "Gemini",  "city" => "Cloud" }

    // 4. Navigation
    MYSQL USE "test_fivemac" IN oDb ORDER "id"
   
    MsgInfo( "Records in table: " + cValToChar( oDb:RecCount() ), "Record Count" )

    oDb:GoTop()
    while ! oDb:EOF()
        MsgInfo( "ID: " + cValToChar( oDb:FieldGet( 1 ) ) + CRLF + ;
            "Name: " + oDb:FieldGet( 2 ) + CRLF + ;
            "City: " + oDb:FieldGet( 3 ), "Browsing Records" )
        oDb:Skip()
    enddo

    // 5. Update
    oDb:GoTop()
    MYSQL REPLACE "city" WITH "Malaga" IN oDb
    MsgInfo( "Updated " + oDb:FieldGet( 2 ) + "'s city to Malaga", "Update" )

    // 6. Delete
    oDb:Skip() // Go to Manuel (Record 2 in ID order)
    
    if MsgYesNo( "Do you want to delete record: " + oDb:FieldGet( 2 ) + "?", "Confirm Delete" )
        MYSQL DELETE IN oDb
        MsgInfo( "Record deleted", "Delete" )
    endif

    MsgInfo( "Remaining records: " + cValToChar( oDb:RecCount() ), "End of test" )

    // 7. Cleanup
    MYSQL CLOSE oDb

return nil
