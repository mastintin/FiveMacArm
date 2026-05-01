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
   
   // Conectar a la base de datos
   SQLITE CONNECT cDbPath INTO oDb
   
   if oDb == nil
      MsgInfo( "No se pudo abrir jubilacion.db" )
      return nil
   endif
   
   DEFINE WINDOW oWnd TITLE "Jubilacion - Cotizaciones" SIZE 720, 500
   
   @ 20, 20 SWBROWSE oBrw SIZE 680, 400 OF oWnd
   
   // Columnas definidas a mano para labels amigables
   oBrw:AddColumn( "Año",       70,  "year"       )
   oBrw:AddColumn( "Mes",       50,  "month"      )
   oBrw:AddColumn( "Base (€)", 130,  "amount"     )
   oBrw:AddColumn( "Laguna",    80,  "es_laguna"  )
   oBrw:AddColumn( "Usuario",   70,  "user_id"    )
   
   // Color fondo del browse
   oBrw:SetBrowseBackColor( "#F8FAFC" )
   
   // Resaltar lagunas en rojo, resto en verde suave
   oBrw:SetBackColor( 4, { |v| If( v == "1", "#FFCCCC", "#D1E7DD" ) } )
   oBrw:SetColImg( 4, { |v| If( v == "1", "exclamationmark.triangle.fill", "checkmark.circle.fill" ) } )
   
   // Icono en columna Año
   oBrw:SetColImg( 1, { || "calendar" } )
   
   // Icono en columna Base
   oBrw:SetColImg( 3, { || "eurosign.circle" } )
   
   // Cargar datos con query personalizada: solo usuario 1, orden descendente
   oBrw:SetDB( oDb, "SELECT year, month, amount, es_laguna, user_id " + ;
                    "FROM cotizaciones WHERE user_id = 1 " + ;
                    "ORDER BY year DESC, month DESC" )
   
   oBrw:bLDblClick := { | o, nId | ShowDetalle( o, nId, oDb ) }
   
   ACTIVATE WINDOW oWnd CENTERED

   SQLITE CLOSE oDb

return nil

//----------------------------------------------------------------------------//

static function ShowDetalle( oBrw, nId, oDb )
   local nRow  := Val( nId )
   local hRow  := oBrw:aRows[ nRow ]
   local cMsg  := "Año: "  + hRow[ "year" ]  + CRLF + ;
                  "Mes: "  + hRow[ "month" ] + CRLF + ;
                  "Base: " + hRow[ "amount" ] + " €" + CRLF + ;
                  "Laguna: " + If( hRow[ "es_laguna" ] == "1", "Sí", "No" )
   MsgInfo( cMsg, "Detalle Cotización" )
return nil
