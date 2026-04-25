#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd, oBtn, oSql
   local cDb := "hsw_test.db"
   
   oWnd := TSwWindow():New( "FiveMac HSW - SQLite Test", 600, 400 )
   
   oBtn := TSwButton():New( 50, 50, 200, 40, "Crear y Consultar DB", oWnd, ;
      { || DoSqlTest( cDb ) } )

   ACTIVATE WINDOW oWnd
   
return nil

function DoSqlTest( cDb )
   local oSql, aData, cResult := ""
   
   oSql := TSwSqlite():New( cDb )
   
   if oSql:Connect()
      oSql:Execute( "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT)" )
      oSql:Execute( "INSERT INTO test (name) VALUES ('FiveMac HSW " + Time() + "')" )
      
      aData := oSql:Query( "SELECT * FROM test ORDER BY id DESC LIMIT 5" )
      
      if !Empty( aData )
         AEval( aData, { |a| cResult += AllTrim(Str(a[1])) + ": " + a[2] + hb_OsNewLine() } )
         MsgInfo( "Datos recuperados desde SQLite:" + hb_OsNewLine() + hb_OsNewLine() + cResult )
      endif
      
      oSql:Close()
   else
      MsgAlert( "Error conectando a SQLite" )
   endif
   
return nil
