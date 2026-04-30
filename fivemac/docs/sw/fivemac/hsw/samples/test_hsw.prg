Function Main()
   ? "--------------------------------------------------"
   ? " [HSW] Iniciando en Hilo 0 (Como el FiveMac de siempre)"
   ? "--------------------------------------------------"
   
   // 1. Lanzamos la lógica en el Hilo 1 (Multihilo real)
   hb_threadStart( @LogicThread() )
   
   // 2. Cedemos el Hilo 0 a Swift. 
   // ¡OJO! Esta función NO VUELVE hasta que se cierre la App.
   ? " [HSW] Hilo 0: Entregando el control a Swift/AppKit..."
   HSW_START_SWIFT()
   
return nil

Procedure LogicThread()
   ? " [HSW] Harbour: ¡Hola desde el Hilo Secundario!"
   ? " [HSW] Mientras Swift controla el Hilo 0, yo proceso aquí."
   
   // Esperamos a que Swift esté listo
   hb_idleSleep( 1 )
   
   // Enviamos un comando a la UI (Swift en Hilo 0)
   HSW_SEND_COMMAND( '{"cmd": "create_window"}' )
   
   for i := 1 to 20
      ? " [HSW] Harbour: Trabajando en Hilo 1... paso", i
      SYSTEM_SLEEP( 500000 )
   next
return

#pragma BEGINDUMP
#include <hbapi.h>
#include <unistd.h>

// Definimos los prototipos de las funciones Swift
extern void HSW_SEND_COMMAND( const char * json );
extern void hsw_swift_start( void );

HB_FUNC( HSW_START_SWIFT )
{
   hsw_swift_start();
}

HB_FUNC( HSW_SEND_COMMAND )
{
   // Capturamos el puntero en el hilo de Harbour y se lo entregamos a Swift
   HSW_SEND_COMMAND( hb_parc( 1 ) );
}

HB_FUNC( SYSTEM_SLEEP )
{
   usleep( hb_parnl( 1 ) );
}
#pragma ENDDUMP
