#include "swfive.ch"

function Main()
   local oDb, aUsers
   local cDbPath := Path() + "jubilacion.db"
   
   if ! File( cDbPath )
      ? "Error: No se encuentra la DB"
      return nil
   endif

   oDb := TSwSqlite():New( cDbPath, 2 )
   aUsers := oDb:Query( "SELECT id, nombre, apellidos FROM usuarios" )
   
   if valtype( aUsers ) == "A"
      ? "Registros encontrados: " + hb_ValToStr( Len( aUsers ) )
      if Len( aUsers ) > 0
         ? "Primer usuario: " + aUsers[ 1 ][ 2 ] + " " + aUsers[ 1 ][ 3 ]
      endif
   else
      ? "Error: La consulta no devolvió un array"
   endif
   
   oDb:End()
return nil
