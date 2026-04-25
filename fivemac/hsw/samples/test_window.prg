// --- Incluimos la definición de la clase y los comandos ---
// En el futuro esto irá en un hsw.ch
#include "../source/classes/HswWindow.prg"

Function Main()
   Local oWnd
   
   ? "--------------------------------------------------"
   ? " [HSW] Test de Comandos Clásicos"
   ? "--------------------------------------------------"
   
   // 1. Definimos la ventana con sintaxis tradicional
   DEFINE WINDOW oWnd TITLE "Ventana creada desde PRG" SIZE 500, 400
   
   // 2. La activamos (esto lanza el hilo y envía el JSON)
   ACTIVATE WINDOW oWnd
   
   // 3. Cedemos el Hilo 0 a Swift
   ? " [HSW] Entregando control a Swift..."
   HSW_START_SWIFT()
   
return nil

#pragma BEGINDUMP
#include <hbapi.h>

extern void hsw_swift_start( void );

HB_FUNC( HSW_START_SWIFT )
{
   hsw_swift_start();
}

// Necesitamos declarar el prototipo para el compilador de C
extern void HSW_SEND_COMMAND( const char * json );

HB_FUNC( HSW_SEND_COMMAND )
{
   HSW_SEND_COMMAND( hb_parc( 1 ) );
}
#pragma ENDDUMP
