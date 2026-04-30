#include "swfive.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd

   DEFINE WINDOW oWnd TITLE "SQLite en La Isla 🏝️🗄️" SIZE 600, 400
   
   @ 50, 50 BUTTON "Probar SQLite Ahora" SIZE 200, 50 OF oWnd ;
      ACTION TestSqlite()

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

function TestSqlite()

   local oDb, cResult := ""
   local cDb := "/tmp/isla_test.db"
   local aStruct := { { "NAME", "C", 50, 0 }, { "AGE", "N", 3, 0 } }
   
   // 1. Conectar / Crear DB
   SQLITE CONNECT cDb CREATE INTO oDb
   
   if ValType( oDb ) != "O" .or. Empty( oDb:hDB )
      MsgStop( "Fallo al conectar con SQLite en: " + cDb )
      return nil
   endif
   
   // 2. Crear Tabla
   SQLITE CREATE TABLE "users" FROM aStruct IN oDb
   
   // 3. Insertar datos mediante Hash (Moderno)
   SQLITE INSERT INTO "users" HASH { "NAME" => "Manuel", "AGE" => 40 } IN oDb
   SQLITE INSERT INTO "users" HASH { "NAME" => "Harriet (The Ghost)", "AGE" => 100 } IN oDb
   
   // 4. Usar la tabla y consultar
   SQLITE USE "users" IN oDb
   
   MsgInfo( "Registros en 'users': " + hb_ValToStr( oDb:RecCount() ), "Resultados" )
   
   oDb:GoTop()
   while ! oDb:Eof()
      cResult += "Fila: " + oDb:FieldGet( 1 ) + " - Edad: " + oDb:FieldGet( 2 ) + hb_OsNewLine()
      MsgInfo( "Nombre: " + oDb:FieldGet( 1 ) + " - Edad: " + oDb:FieldGet( 2 ), "Fila " + hb_ValToStr( oDb:RecNo() ) )
      oDb:Skip()
   end
   
   hb_memoWrit( "/tmp/isla_resultado.txt", cResult )

   // 5. Cerrar
   SQLITE CLOSE oDb
   
   MsgInfo( "Test de SQLite completado con éxito 🏝️✅" )

return nil
