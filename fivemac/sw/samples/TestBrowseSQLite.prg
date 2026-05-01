#include "swfive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

//----------------------------------------------------------------------------//

function AppMain()
   local oWnd, oBrw
   local oDb
   local cDbPath := Path() + "jubilacion.db"
   
   DEFINE WINDOW oWnd TITLE "Jubilacion - Cotizaciones" SIZE 720, 500
   
   @ 20, 20 SWBROWSE oBrw SIZE 680, 400 OF oWnd
   
   // Columnas definidas a mano
   oBrw:AddColumn( "Año",      70,  "year"      )
   oBrw:AddColumn( "Mes",      50,  "month"     )
   oBrw:AddColumn( "Base (€)", 130, "amount"    )
   oBrw:AddColumn( "Laguna",   80,  "es_laguna" )
   oBrw:AddColumn( "Usuario",  70,  "user_id"   )
   
   oBrw:cBackColor := "#F8FAFC"
   
   // Conectar y cargar
   if File( cDbPath )
      oDb := TSwSqlite():New( cDbPath, 2 )
      if ! Empty( oDb ) .and. ! Empty( oDb:hDB )
         // Es importante que oDb:cTable tenga el nombre de la tabla para que SetDB 
         // pueda obtener los nombres de columna si no los conoce
         oDb:cTable := "cotizaciones" 
         
         oBrw:SetDB( oDb, "SELECT year, month, amount, es_laguna, user_id " + ;
                          "FROM cotizaciones WHERE user_id = 1 " + ;
                          "ORDER BY year DESC, month DESC" )
      endif
   else
      MsgInfo( "No se encuentra la base de datos en: " + cDbPath )
   endif
   
   oBrw:bLDblClick := { | o, nId | ShowDetalle( o, nId ) }
   
   ACTIVATE WINDOW oWnd CENTERED

   if ! Empty( oDb ) ; oDb:End() ; endif

return nil

//----------------------------------------------------------------------------//

function ShowDetalle( oBrw, nId )
   local nRow  := Val( nId )
   local hRow
   if nRow > 0 .and. nRow <= Len( oBrw:aRows )
      hRow  := oBrw:aRows[ nRow ]
      MsgInfo( "Año: "  + hRow[ "year" ]  + CRLF + ;
               "Mes: "  + hRow[ "month" ] + CRLF + ;
               "Base: " + hRow[ "amount" ] + " €", "Detalle" )
   endif
return nil
