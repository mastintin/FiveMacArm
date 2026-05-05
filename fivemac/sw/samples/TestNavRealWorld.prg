#include "swfive.ch"

//----------------------------------------------------------------------------//

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

//----------------------------------------------------------------------------//

function AppMain()
   local oNav, oDb
   local cDbPath := Path() + "jubilacion.db"
   local aTables, n, cTable
   local oList, aUsers, oRow, nU
   local cId, cNombre, cApellido, cDias
   local oPanel, oVStack, oCard1, oCard2, oH1, oV1, oGauge, oHData, oVLabels, oHBtns
   local oBtnSave, oBtnCancel
   
   local hData := {=>}
   local hGets := {=>}
   
   // 1. CONEXIÓN A LA BASE DE DATOS
   if ! File( cDbPath )
      MsgStop( "No se encuentra la base de datos: " + cDbPath )
      return nil
   endif

   oDb := TSwSqlite():New( cDbPath, 2 )
   
   // 2. CREACIÓN DE LA VENTANA DE NAVEGACIÓN
   DEFINE NAVWINDOW oNav TITLE "Fivemac ERP - Estructura + Gauge"
   
   // 3. CARGA DINÁMICA DEL SIDEBAR (OPCIONES PRINCIPALES)
   aTables := oDb:Query( "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'" )
   
   if ! Empty( aTables )
      for n := 1 to Len( aTables )
          cTable := aTables[ n ][ 1 ]
          oNav:AddItem( Lower( cTable ), cTable, "table", "" )
      next
   endif

   // 4. MÓDULO DE USUARIOS (Segunda columna)
   @ 0, 0 LIST oList ID "usuarios" OF oNav SIZE 350, 800
   
   aUsers := oDb:Query( "SELECT id, nombre, apellidos, dias_cotizados FROM usuarios" )
   
   if ! Empty( aUsers )
      for nU := 1 to Len( aUsers )
         cId      := AllTrim( hb_ValToStr( aUsers[ nU ][ 1 ] ) )
         cNombre  := AllTrim( hb_ValToStr( aUsers[ nU ][ 2 ] ) )
         cApellido := AllTrim( hb_ValToStr( aUsers[ nU ][ 3 ] ) )
         cDias    := AllTrim( hb_ValToStr( aUsers[ nU ][ 4 ] ) )

         hData[ cId ] := { "nombre" => cNombre, "apellidos" => cApellido, "dias" => cDias }
         hGets[ cId ] := { "nombre" => nil, "apellidos" => nil, "dias" => nil }

         // Definimos la fila en la lista
         DEFINE ROW oRow OF oList ID cId
            oRow:nHeight := 45
            @ 12, 15 SAY cNombre + " " + cApellido OF oRow SIZE 300, 20

         // 5. Contenedor de Detalle + Tarjetas
         @ 0, 0 PANEL oPanel ID "detail_" + cId OF oNav
            @ 40, 0 VSTACK oVStack OF oPanel SIZE 440, 800
               oVStack:nSpacing := 20
               @ 0, 0 SAY "EXPEDIENTE DIGITAL" OF oVStack SIZE 400, 25
               
               // Tarjeta 1
               @ 0, 0 CARD oCard1 TITLE "Datos Personales" SYMBOL "person.text.rectangle" OF oVStack SIZE 440, 200
                  @ 0, 0 HSTACK oH1 OF oCard1
                  oH1:nSpacing := 20
                  oH1:nPadding := 2
                     @ 0, 0 IMAGE SYMBOL "person.crop.circle.fill" OF oH1 SIZE 60, 60
                     @ 0, 0 VSTACK oV1 OF oH1
                     oV1:nSpacing := 5
                     oV1:nPadding := 0
                        @ 0, 0 GET hGets[cId]["nombre"] VAR hData[cId]["nombre"] OF oV1 SIZE 260, 35 ;
                           ACTION GenAction( hData[cId], "nombre" )
                        @ 0, 0 GET hGets[cId]["apellidos"] VAR hData[cId]["apellidos"] OF oV1 SIZE 260, 35 ;
                           ACTION GenAction( hData[cId], "apellidos" )

                // Tarjeta 2 activa (Cálculo de Jubilación)
                @ 0, 0 CARD oCard2 TITLE "Cálculo de Jubilación" SYMBOL "timer" OF oVStack SIZE 440, 360
                   oCard2:nSpacing := 30
                   
                   // Bloque Superior: Gauge y Datos
                   @ 0, 0 HSTACK oHData OF oCard2
                      oHData:nSpacing := 15
                      
                      @ 0, 0 GAUGE oGauge VALUE Val(cDias) RANGE 0, 25000 OF oHData SIZE 120, 120 ;
                         STYLE 3 PROMPT "Cotizado" UNIT "días" SHOWVALUE COLOR ".cyan.glass"

                      @ 0, 0 VSTACK oVLabels OF oHData
                         oVLabels:nSpacing := 4
                         @ 0, 0 SAY "Días Registrados:" OF oVLabels SIZE 200, 20
                         @ 0, 0 GET hGets[cId]["dias"] VAR hData[cId]["dias"] OF oVLabels SIZE 200, 35 ;
                            ACTION GenAction( hData[cId], "dias" )
                         
                         @ 0, 0 SAY "Meta: 14,053 días (38.5 años)" OF oVLabels SIZE 220, 20
                         @ 0, 0 SAY "Estado: " + If( Val(cDias) > 11000, "Próxima", "En curso" ) OF oVLabels SIZE 200, 20

                   // Bloque Inferior: Acciones
                   @ 0, 0 HSTACK oHBtns OF oCard2
                      oHBtns:nSpacing := 20
                      
                      @ 0, 0 BUTTON oBtnSave PROMPT "GRABAR" OF oHBtns SIZE 170, 45 ;
                         STYLE ".blue.glass" ICON "square.and.arrow.down" COLOR ".white"
                      oBtnSave:bAction := GenSaveAction( oDb, cId, hData )

                      @ 0, 0 BUTTON oBtnCancel PROMPT "CANCELAR" OF oHBtns SIZE 170, 45 ;
                         STYLE ".red.glass" ICON "arrow.uturn.backward" COLOR ".white"
                      oBtnCancel:bAction := GenCancelAction( oDb, cId, hData, oNav, hGets )
      next
   endif

   oList:bAction := { | cId | oNav:SetContent( "detail_" + cId ) }

   // 6. ACTIVACIÓN
   ACTIVATE WINDOW oNav CENTERED
   
return nil

//----------------------------------------------------------------------------//

function GenAction( hUser, cKey )
return { |v| hUser[ cKey ] := v }

//----------------------------------------------------------------------------//

function GenSaveAction( oDb, cId, hData )
return { || oDb:Execute( "UPDATE usuarios SET nombre = '" + hData[cId]["nombre"] + ;
                                               "', apellidos = '" + hData[cId]["apellidos"] + ;
                                               "', dias_cotizados = " + AllTrim(hb_ValToStr(hData[cId]["dias"])) + ;
                                               " WHERE id = " + cId ), ;
            MsgInfo( "Datos de " + hData[cId]["nombre"] + " guardados con éxito." ) }

//----------------------------------------------------------------------------//

function GenCancelAction( oDb, cId, hData, oNav, hGets )
return { || MsgInfo("Dummy de cancelar"), ReloadUser( oDb, cId, hData, oNav, hGets ) }

//----------------------------------------------------------------------------//

function ReloadUser( oDb, cId, hData, oNav, hGets )
   local aRec := oDb:Query( "SELECT nombre, apellidos, dias_cotizados FROM usuarios WHERE id = " + cId )
   if !Empty( aRec )
      hData[ cId ][ "nombre" ]    := AllTrim( hb_ValToStr( aRec[ 1 ][ 1 ] ) )
      hData[ cId ][ "apellidos" ] := AllTrim( hb_ValToStr( aRec[ 1 ][ 2 ] ) )
      hData[ cId ][ "dias" ]      := AllTrim( hb_ValToStr( aRec[ 1 ][ 3 ] ) )
      
      if hb_HHasKey( hGets, cId )
         hGets[ cId ][ "nombre" ]:SetText( hData[ cId ][ "nombre" ] )
         hGets[ cId ][ "apellidos" ]:SetText( hData[ cId ][ "apellidos" ] )
         hGets[ cId ][ "dias" ]:SetText( hData[ cId ][ "dias" ] )
      endif

      // Forzar refresco de la vista actual
      oNav:SetContent( "" )
      oNav:SetContent( "detail_" + cId )
      MsgInfo( "Registro recargado desde la base de datos:" + hb_OsNewLine() + ;
               "Nombre: " + hData[ cId ][ "nombre" ] + hb_OsNewLine() + ;
               "Apellidos: " + hData[ cId ][ "apellidos" ] + hb_OsNewLine() + ;
               "Días: " + hData[ cId ][ "dias" ] )
   endif
return nil
