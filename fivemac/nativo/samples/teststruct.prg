#include "FiveMac.ch"
#include "sqlite.ch"
#include "mysql.ch"

function Main()

    local oDb, aStruct, n, cMsg, aNewStruct
    
    // Sample structure array [ Name, Type, Len, Dec ]
    aNewStruct := { { "CODE",  "C", 10, 0 }, ;
        { "NAME",  "C", 50, 0 }, ;
        { "VALUE", "N", 12, 2 }, ;
        { "DATE",  "D",  8, 0 }, ;
        { "INFO",  "M", 10, 0 } }

    // 1. Test SQLite
    MsgInfo( "Testing SQLite CreateTable() from Array" )
    oDb := TSQLite():New( "/tmp/test_create.db" )
    if ! Empty( oDb:hDB )
        SQLITE DROP TABLE test_array IN oDb
        SQLITE CREATE TABLE test_array FROM aNewStruct IN oDb
        
        oDb:TableUse( "test_array" )
        aStruct := oDb:DbStruct()
      
        cMsg := "SQLite Created Structure:" + CRLF
        for n := 1 to Len( aStruct )
            cMsg += aStruct[n][1] + " " + aStruct[n][2] + " " + ;
                cValToChar( aStruct[n][3] ) + " " + cValToChar( aStruct[n][4] ) + CRLF
        next
        MsgInfo( cMsg )
        oDb:End()
    endif

    // 2. Test MySQL
    MsgInfo( "Testing MySQL CreateTable() from Array" )
    oDb := TMySQL():New( "134.0.10.187", "mastintin", "Mas_0210199999", "testfivemac" )
    if oDb != nil
        oDb:Execute( "DROP TABLE IF EXISTS test_array" )
        MYSQL CREATE TABLE test_array FROM aNewStruct IN oDb
  
        oDb:TableUse( "test_array" )
        aStruct := oDb:DbStruct()
      
        cMsg := "MySQL Created Structure:" + CRLF
        for n := 1 to Len( aStruct )
            cMsg += aStruct[n][1] + " " + aStruct[n][2] + " " + ;
                cValToChar( aStruct[n][3] ) + " " + cValToChar( aStruct[n][4] ) + CRLF
        next
        MsgInfo( cMsg )
        oDb:End()
    endif

return nil
