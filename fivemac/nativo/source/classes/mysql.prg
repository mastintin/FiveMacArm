#include "FiveMac.ch"
#include "hbhash.ch"

// Class TMySQL
// Wrapper for Harbour hbmysql library (TMySQLServer)

CLASS TMySQL

    DATA oServer
    DATA oQuery
    DATA cFile
    DATA nError INIT 0
    DATA cError INIT ""

    DATA aResult     INIT {}
    DATA nCurrentRow INIT 0
    DATA lEof        INIT .T.
    DATA cTable      INIT ""
    DATA cOrder      INIT ""
    DATA aFields     INIT {}

    METHOD New( cHost, cUser, cPass, cDb, nPort ) CONSTRUCTOR
    METHOD End() INLINE if( !Empty( ::oServer ), ::oServer:Destroy(), )
   
    METHOD Query( cSql )
    METHOD Execute( cSql )
    METHOD TableUse( cTable )
    METHOD SelectDB( cDb, lCreate )
    METHOD CreateDatabase( cDb )
    METHOD OrdSetFocus( cOrder )
    METHOD DbAppend()
    METHOD FieldPut( n, uVal )
    METHOD FieldPutName( cName, uVal )   
    METHOD FieldGetName( cName )  
    METHOD FieldName( n ) 
    METHOD FieldPos( cName )  
  
    METHOD DelRecord()
    METHOD Insert( cTable, hData )
    METHOD Current()
    METHOD ValToSql( uVal )
    METHOD CreateTable( cTable, aStruct )
   
    // Navigation
    METHOD GoTop() 
    METHOD GoBottom()
    METHOD Skip( n )
    METHOD EOF()     INLINE ::lEof
    METHOD BOF()     INLINE ::nCurrentRow == 0
    METHOD RecCount() INLINE Len( ::aResult )
    METHOD RecNo()    INLINE ::nCurrentRow
    METHOD DbStruct()
    METHOD ImportFromSQLite( oDbSQLite, cTable, bProgress )
    METHOD ImportFromDBF( cDbf, bProgress )
    METHOD ExportToDBF( cDbf, bProgress )

    METHOD FieldGet( n ) 

ENDCLASS

METHOD New( cHost, cUser, cPass, cDb, nPort ) CLASS TMySQL

    DEFAULT cHost := "localhost", nPort := 3306
   
    ::oServer := TMySQLServer():New( cHost, cUser, cPass, nPort )

    if ::oServer:NetErr()
        MsgAlert( "Cannot connect to MySQL server: " + ::oServer:Error() )
        return nil
    endif

    if ! Empty( cDb )
        if ! ::oServer:SelectDB( cDb )
            MsgAlert( "Cannot select database: " + cDb )
            return nil
        endif
    endif

return Self

METHOD SelectDB( cDb, lCreate ) CLASS TMySQL
    DEFAULT lCreate := .F.
    if lCreate 
        if ! ::CreateDatabase( cDb )
            MsgAlert( "Failed to create database: " + cDb )
        endif
    endif

    if ! ::oServer:SelectDB( cDb )
        MsgAlert( "Cannot select database: " + cDb + CRLF + ::oServer:Error() )
        return .F.
    endif
return .T.

METHOD CreateDatabase( cDb ) CLASS TMySQL
    local oQuery := ::oServer:Query( "CREATE DATABASE IF NOT EXISTS " + cDb )
    if oQuery:NetErr()
        MsgAlert( "MySQL Error: " + oQuery:Error() )
        return .F.
    endif
return .T.

METHOD Query( cSql ) CLASS TMySQL
    local oQuery, n, i, aRow, aRows := {}, nRecCount, nFieldCount
    local aData, cMsg
   
    oQuery := ::oServer:Query( cSql )
   
    if oQuery:NetErr()
        MsgAlert( "MySQL Error: " + oQuery:Error() + CRLF + "SQL: " + cSql )
        ::cError := oQuery:Error()
        ::aResult := {}
        ::lEof := .T.
        ::nCurrentRow := 0
        return nil
    endif

    nRecCount   := oQuery:LastRec()
    nFieldCount := oQuery:FCount()

    // Backdoor probes if standard methods fail
    if ! ( ValType( nRecCount ) == "N" .and. nRecCount > 0 ) .and. ! Empty( oQuery:nResultHandle )
        nRecCount := MYSQL_NUM_ROWS( oQuery:nResultHandle )
    endif
    if ! ( ValType( nFieldCount ) == "N" .and. nFieldCount > 0 ) .and. ! Empty( oQuery:nResultHandle )
        nFieldCount := MYSQL_NUM_FIELDS( oQuery:nResultHandle )
    endif

    if ValType( nRecCount ) != "N"
        nRecCount := Val( cValToChar( nRecCount ) )
    endif
    if ValType( nFieldCount ) != "N"
        nFieldCount := Val( cValToChar( nFieldCount ) )
    endif

    // Cache results for xBase navigation
    if nRecCount > 0 .and. nFieldCount > 0
        for n := 1 to nRecCount
            aRow := oQuery:GetRow( n )
            if aRow != nil
                AAdd( aRows, Array( nFieldCount ) )
                for i := 1 to nFieldCount
                    if ValType( aRow ) == "O"
                        aRows[ Len( aRows ) ][ i ] := aRow:FieldGet( i )
                    elseif ValType( aRow ) == "A"
                        aRows[ Len( aRows ) ][ i ] := aRow[ i ]
                    endif
                next
            endif
        next
    endif

    ::aResult := aRows
    ::GoTop()
    ::oQuery := oQuery // Keep reference for metadata if needed

return aRows

METHOD DbStruct() CLASS TMySQL
    local aStruct := {}
    local n
    local cType, nLen, nDec
    if ::oQuery != nil
        for n := 1 to ::oQuery:FCount()
            cType := ::oQuery:FieldType( n )
            nLen  := ::oQuery:FieldLen( n )
            nDec  := ::oQuery:FieldDec( n )
            
            if cType == "N" .and. nDec < 6
                nDec := 6
            endif

            AAdd( aStruct, { ::oQuery:FieldName( n ), cType, nLen, nDec } )
        next
    endif
return aStruct

METHOD CreateTable( cTable, aStruct ) CLASS TMySQL
    local cSql := "CREATE TABLE IF NOT EXISTS `" + cTable + "` ( "
    local n, aField, cType
    
    for n := 1 to Len( aStruct )
        aField := aStruct[n]
        cType := Upper( aField[2] )
      
        cSql += "`" + aField[1] + "` "
      
        do case
            case cType == "C" ; cSql += "VARCHAR(" + AllTrim(Str(aField[3])) + ")"
            case cType == "N" ; cSql += "DOUBLE(" + AllTrim(Str(aField[3])) + "," + AllTrim(Str(aField[4])) + ")"
            case cType == "D" ; cSql += "DATE"
            case cType == "L" ; cSql += "TINYINT(1)"
            case cType == "M" ; cSql += "LONGTEXT"
                otherwise         ; cSql += "VARCHAR(255)"
        endcase

        if n < Len( aStruct )
            cSql += ", "
        endif
    next
    
    cSql += " )"
    
return ::Execute( cSql )

METHOD Execute( cSql ) CLASS TMySQL
    local oQuery := ::oServer:Query( cSql )
    if oQuery == nil .or. oQuery:NetErr()
        ::cError := if( oQuery == nil, "Unknown error", oQuery:Error() )
        MsgAlert( "MySQL Error: " + ::cError + CRLF + "SQL: " + cSql )
        return -1
    endif
return 0

METHOD TableUse( cTable ) CLASS TMySQL
    local oQuery
    local n, i, aRow
    ::cTable := cTable
    ::cOrder := ""
   
    // Get field names
    oQuery := ::oServer:Query( "SELECT * FROM `" + cTable + "` LIMIT 1" )
    ::aFields := {}
    if ! oQuery:NetErr() 
    n := oQuery:FCount()
    if ValType( n ) != "N" ; n := Val( cValToChar( n ) ) ; endif
        
        if n == 0
            aRow := oQuery:GetRow()
            if ValType( aRow ) == "A"
                n := Len( aRow )
            endif
        endif

        if n > 0
            for i := 1 to n
                AAdd( ::aFields, oQuery:FieldName( i ) )
            next
        endif
    endif

return ::Query( "SELECT * FROM `" + cTable + "`" )

METHOD OrdSetFocus( cOrder ) CLASS TMySQL
    ::cOrder := cOrder
    if ! Empty( ::cTable )
        if ! Empty( cOrder )
            return ::Query( "SELECT * FROM `" + ::cTable + "` ORDER BY " + cOrder )
        else
            return ::Query( "SELECT * FROM `" + ::cTable + "`" )
        endif
    endif
return ::cOrder

METHOD DbAppend() CLASS TMySQL
    // MySQL usually needs explicitly defined columns for insert if they don't have defaults
    // Here we assume simple case or that we'll use FieldPut afterwards.
    // Note: TMySQLServer:Query() for INSERT doesn't return a recordset.
    if ! Empty( ::cTable )
        ::oServer:Query( "INSERT INTO " + ::cTable + " () VALUES ()" )
        ::Query( "SELECT * FROM " + ::cTable ) // Refresh
        ::GoBottom()
    endif
return nil

METHOD FieldPos( cName ) CLASS TMySQL
    local nPos := AScan( ::aFields, { | c | Lower( c ) == Lower( cName ) } )
return if( nPos == 0, nil, nPos )

METHOD FieldName( n ) CLASS TMySQL
return ::aFields[ n ]

METHOD FieldPutName( cName, uVal ) CLASS TMySQL
    local nPos := ::FieldPos( cName )
return if( nPos == nil, nil, ::FieldPut( nPos, uVal ) )

METHOD FieldPut( n, uVal ) CLASS TMySQL
    local cSql, cVal, nId, cPrimaryKey := "id" // Assumption for simplified wrapper
   
    if Empty( ::cTable ) .or. ::nCurrentRow == 0 .or. ::nCurrentRow > Len( ::aResult )
        return nil
    endif

    if n < 1 .or. n > Len( ::aFields )
        return nil
    endif

    // We need a primary key to update. For this simple wrapper we assume first column is ID
    // or we look for it in metadata.
    nId := ::aResult[ ::nCurrentRow ][ 1 ]
    cVal := ::ValToSql( uVal )

    cSql := "UPDATE " + ::cTable + " SET " + ::aFields[ n ] + " = " + cVal + ;
        " WHERE " + ::aFields[ 1 ] + " = " + cValToChar( nId )
   
    if ! ::oServer:Query( cSql ):NetErr()
        ::aResult[ ::nCurrentRow ][ n ] := uVal
        return .T.
    endif

return .F.

METHOD FieldGetName( cName ) CLASS TMySQL
    local n := ::FieldPos( cName )
return if( n != nil, ::FieldGet( n ), nil )

METHOD DelRecord() CLASS TMySQL
    local nId, cSql
   
    if Empty( ::cTable ) .or. ::nCurrentRow == 0 .or. ::nCurrentRow > Len( ::aResult )
        return .F.
    endif

    nId := ::aResult[ ::nCurrentRow ][ 1 ]
    cSql := "DELETE FROM " + ::cTable + " WHERE " + ::aFields[ 1 ] + " = " + cValToChar( nId )
   
    if ! ::oServer:Query( cSql ):NetErr()
        ADel( ::aResult, ::nCurrentRow )
        ASize( ::aResult, Len( ::aResult ) - 1 )
        if ::nCurrentRow > Len( ::aResult )
            ::nCurrentRow := Len( ::aResult )
            ::lEof := ( ::nCurrentRow == 0 )
        endif
        return .T.
    endif

return .F.

METHOD GoTop() CLASS TMySQL
    if Len( ::aResult ) > 0
        ::nCurrentRow := 1
        ::lEof := .F.
    else
        ::nCurrentRow := 0
        ::lEof := .T.
    endif
return nil

METHOD GoBottom() CLASS TMySQL
    if Len( ::aResult ) > 0
        ::nCurrentRow := Len( ::aResult )
        ::lEof := .F.
    else
        ::nCurrentRow := 0
        ::lEof := .T.
    endif
return nil

METHOD Skip( n ) CLASS TMySQL
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

METHOD FieldGet( n ) CLASS TMySQL
    if ::nCurrentRow > 0 .and. ::nCurrentRow <= Len( ::aResult )
        if n > 0 .and. n <= Len( ::aResult[ ::nCurrentRow ] )
            return ::aResult[ ::nCurrentRow ][ n ]
        endif
    endif
return nil

METHOD Insert( cTable, hData ) CLASS TMySQL
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
        cCols += "`" + aKeys[ n ] + "`"
        cVals += ::ValToSql( hData[ aKeys[ n ] ] )
        if n < Len( aKeys )
            cCols += ", "
            cVals += ", "
        endif
    next

    cSql := "INSERT INTO `" + cTable + "` (" + cCols + ") VALUES (" + cVals + ")"
   
return ::Execute( cSql )

METHOD Current() CLASS TMySQL
    local hRow := {=>}
    local n
    if ::nCurrentRow > 0 .and. ::nCurrentRow <= Len( ::aResult )
        for n := 1 to Len( ::aFields )
            hRow[ ::aFields[ n ] ] := ::aResult[ ::nCurrentRow ][ n ]
        next
    endif
return hRow

METHOD ValToSql( uVal ) CLASS TMySQL
    local cType := ValType( uVal )
    do case
        case cType == "C" .or. cType == "M" ; return "'" + StrTran( uVal, "'", "''" ) + "'"
        case cType == "N" ; return cValToChar( uVal )
        case cType == "D" ; return "'" + Str( Year( uVal ), 4 ) + "-" + StrZero( Month( uVal ), 2 ) + "-" + StrZero( Day( uVal ), 2 ) + "'"
        case cType == "L" ; return if( uVal, "1", "0" )
        case cType == "T" ; return "'" + hb_TtoS( uVal ) + "'"
    endcase
return "NULL"

//----------------------------------------------------------------------------//

METHOD ImportFromSQLite( oDbSQLite, cTable, bProgress ) CLASS TMySQL

    local aStruct, nTotal, nDone := 0
   
    oDbSQLite:TableUse( cTable )
    aStruct := oDbSQLite:DbStruct()
    nTotal  := oDbSQLite:RecCount()
   
    ::Execute( "DROP TABLE IF EXISTS `" + cTable + "`" )
    ::CreateTable( cTable, aStruct )
    ::TableUse( cTable )
   
    oDbSQLite:GoTop()
    while ! oDbSQLite:EOF()
        if ::Insert( oDbSQLite:Current() ) == 0
            nDone++
            if bProgress != nil
                Eval( bProgress, nDone, nTotal )
                PUMPEVENTS()
            endif
        endif
        oDbSQLite:Skip()
    end

return nDone == nTotal

//----------------------------------------------------------------------------//

METHOD ImportFromDBF( cDbf, bProgress ) CLASS TMySQL

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
   
    ::Execute( "DROP TABLE IF EXISTS `" + cTable + "`" )
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

METHOD ExportToDBF( cDbf, bProgress ) CLASS TMySQL

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
                    uVal := SToD( StrTran( uVal, "-", "" ) )
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
