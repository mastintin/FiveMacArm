#include "SwFive.ch"

// ---------------------------------------------------------
// Punto de entrada (Thread 0)
// ---------------------------------------------------------
function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

// ---------------------------------------------------------
// Lógica de la aplicación (Thread 1)
// ---------------------------------------------------------
function AppMain()
   local oWnd
   
   DEFINE WINDOW oWnd TITLE "FiveMac HSW - Mensajes Síncronos" SIZE 400, 600
   
   @ 50, 50 BUTTON "MsgInfo" ACTION MsgInfo( "Este es un mensaje síncrono", "Aviso" ) SIZE 100, 30 OF oWnd
   @ 90, 50 BUTTON "MsgStop" ACTION MsgStop( "Esto es un error crítico", "Atención" ) SIZE 100, 30 OF oWnd
   @ 130, 50 BUTTON "MsgYesNo" ACTION TestYesNo() SIZE 100, 30 OF oWnd
   @ 170, 50 BUTTON "MsgNoYes" ACTION TestNoYes() SIZE 100, 30 OF oWnd
   @ 210, 50 BUTTON "MsgGetMulti" ACTION TestGetMulti() SIZE 100, 30 OF oWnd
   @ 250, 50 BUTTON "MsgRun" ACTION TestRun() SIZE 100, 30 OF oWnd
   @ 290, 50 BUTTON "MsgWaitNS" ACTION TestWaitNS() SIZE 100, 30 OF oWnd
   @ 330, 50 BUTTON "Test Progress" ACTION TestProgress() SIZE 100, 30 OF oWnd
   @ 370, 50 BUTTON "MsgToast" ACTION MsgToast( "Hola desde el mundo nativo", "Notificación" ) SIZE 100, 30 OF oWnd
   
   @ 50, 200 BUTTON "GetFile" ACTION MsgInfo( GetFile( "Selecciona un archivo", "txt,prg,c" ) ) SIZE 100, 30 OF oWnd
   @ 90, 200 BUTTON "GetDir" ACTION MsgInfo( GetDir( "Selecciona una carpeta" ) ) SIZE 100, 30 OF oWnd
   @ 130, 200 BUTTON "SaveFile" ACTION MsgInfo( SaveFile( "test.txt", "Guardar resultado" ) ) SIZE 100, 30 OF oWnd
   @ 170, 200 BUTTON "MsgChoice" ACTION MsgInfo( Str( MsgChoice( "Elija color", "Selección", {"Rojo", "Verde", "Azul"} ) ) ) SIZE 100, 30 OF oWnd
   @ 210, 200 BUTTON "MsgGet" ACTION MsgInfo( MsgGet( "Nombre:", "Usuario", "Manuel" ) ) SIZE 100, 30 OF oWnd
   @ 250, 200 BUTTON "MsgList" ACTION TestMsgList() SIZE 100, 30 OF oWnd
   @ 290, 200 BUTTON "MsgToast" ACTION MsgToast( "Esto es una notificación rápida", "Éxito" ) SIZE 100, 30 OF oWnd
   @ 330, 200 BUTTON "MsgWait (5s)" ACTION MsgWait( "Esperando un poco...", "MsgWait", 5 ) SIZE 100, 30 OF oWnd
   
   ACTIVATE WINDOW oWnd CENTER
   
return nil

function TestMsgList()
   local aItems := { "Manzana", "Pera", "Plátano", "Fresa", "Kiwi", "Naranja", "Limón", "Uva", "Sandía", "Melón", "Cereza", "Ciruela", "Higo", "Mango", "Piña" }
   local nIdx := MsgList( aItems, "Seleccione una Fruta (Lista con Buscador)" )
   if nIdx > 0
      MsgInfo( "Has seleccionado: " + aItems[ nIdx ] )
   else
      MsgInfo( "Has cancelado la selección" )
   endif
return nil

function TestGetMulti()
   local cText := MsgGetMultiline( "Instrucciones Especiales", "Escribe aquí tus notas...", 400, 200 )
   if ! Empty( cText )
      MsgInfo( "Has escrito:" + hb_osnewline() + cText )
   else
      MsgInfo( "No has escrito nada o has cancelado" )
   endif
return nil

function TestYesNo()
   local a := MsgYesNo( "¿Deseas continuar con la prueba?", "Confirmación" )
   if a
      MsgInfo( "Has dicho que SÍ" )
   else
      MsgInfo( "Has dicho que NO" )
   endif
return nil

function TestRun()
   MsgRun( "Procesando tarea de 6 segundos...", "Progreso Dinámico", { || DoDynamicTask() } )
   MsgInfo( "Tarea finalizada con éxito" )
return nil

function DoDynamicTask()
   local i
   for i := 1 to 10
      MsgStatusUpdate( i * 10 )
      hb_idleSleep( 0.5 )
   next
return nil

function DoTestRunTask()
   local i
   for i := 1 to 100
      MsgStatusUpdate( i )
      hb_idleSleep( 0.07 )
   next
return nil

function TestProgress()
   MsgInfo( "Iniciando prueba de progreso (7 segundos)..." )
   MsgStatus( "Cargando componentes...", "Proceso Largo" )
   DoTestRunTask()
   MsgStatusClose()
   MsgInfo( "Prueba de 7 segundos finalizada." )
return nil

function TestNoYes()
   local a := MsgNoYes( "¿Deseas borrar los datos? (Cuidado, foco en NO)", "Peligro" )
   if a
      MsgInfo( "Has dicho que SÍ" )
   else
      MsgInfo( "Has dicho que NO (¡Salvado!)" )
   endif
return nil

function TestWaitNS()
   MsgWaitNS( "Este es un cartel asíncrono manual", "Esperando..." )
   hb_idleSleep( 3 )
   MsgWaitNSStop()
   MsgInfo( "El cartel asíncrono se ha cerrado manualmente" )
return nil
