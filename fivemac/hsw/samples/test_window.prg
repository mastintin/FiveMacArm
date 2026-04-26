// --- Incluimos la definición de la clase y los comandos ---
// En el futuro esto irá en un hsw.ch
#include "../source/classes/HswWindow.prg"

Function Main()
   Local oWnd
   
   ? "--------------------------------------------------"
   ? " [HSW] Test de Reactividad SwiftUI"
   ? "--------------------------------------------------"
   
   // 1. Iniciamos Swift (ahora él toma el mando del Hilo 0)
   // Pasamos el nombre de la función que Harbour ejecutará en el Hilo 1
   HSW_START_SWIFT( "AppMain" )
   
return nil

Function AppMain()
   Local oWnd
   
   ? " [HSW] Harbour: Iniciando lógica en Hilo 1..."
   
   DEFINE WINDOW oWnd TITLE "Ventana Reactiva HSW" SIZE 400, 300
   ACTIVATE WINDOW oWnd
   
   ? " [HSW] Harbour: Esperando 3 segundos..."
   hb_idleSleep( 3 )
   
   ? " [HSW] Harbour: Cambiando título..."
   oWnd:cTitle := "¡Título Cambiado! 🎉"
   
   ? " [HSW] Harbour: Esperando 2 segundos..."
   hb_idleSleep( 2 )
   
   ? " [HSW] Harbour: Cambiando ancho..."
   oWnd:nWidth := 600
   
return nil

#pragma BEGINDUMP
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbthread.h>
#include <hbvm.h>

extern void hsw_swift_start( void );
extern void HSW_SEND_COMMAND( const char * json );

static HB_THREAD_STARTFUNC( hsw_harbour_thread )
{
   char * szFuncName = ( char * ) Cargo;
   hb_vmThreadInit( NULL );
   
   if( szFuncName )
   {
      hb_vmPushSymbol( hb_dynsymGetSymbol( szFuncName ) );
      hb_vmPushNil();
      hb_vmDo( 0 );
      hb_xfree( szFuncName );
   }
   
   hb_vmThreadQuit();
   return NULL;
}

HB_FUNC( HSW_START_SWIFT )
{
   HB_THREAD_ID th_id;
   char * szFuncName = NULL;
   
   if( hb_pcount() > 0 )
      szFuncName = hb_strdup( hb_parc( 1 ) );
      
   hb_threadCreate( &th_id, hsw_harbour_thread, ( void * ) szFuncName );
   hsw_swift_start();
}

HB_FUNC( HSW_SEND_COMMAND )
{
   HSW_SEND_COMMAND( hb_parc( 1 ) );
}
#pragma ENDDUMP
