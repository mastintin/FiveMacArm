#import <Foundation/Foundation.h>
#import <hbapi.h>
#import <hbapiitm.h>
#import <hbthread.h>
#import <hbvm.h>

// Prototipo de la función de arranque en Swift
extern void hsw_swift_start(void);

static char * gcFuncName = NULL;

/// Hilo secundario donde correrá la máquina virtual de Harbour
static HB_THREAD_STARTFUNC( hsw_harbour_thread )
{
   HB_SYMBOL_UNUSED( Cargo );
   
   hb_vmThreadInit( NULL );
   
   if( gcFuncName )
   {
      hb_vmPushSymbol( hb_dynsymSymbol( hb_dynsymFindName( gcFuncName ) ) );
      hb_vmPushNil();
      hb_vmDo( 0 );
   }
   
   hb_vmThreadQuit();
   return NULL;
}

/// HB_FUNC( HSW_START_SWIFT )
/// Punto de entrada inicial: 
/// 1. Crea un hilo para Harbour
/// 2. Arranca NSApplication en el hilo principal (bloqueante)
HB_FUNC( HSW_START_SWIFT )
{
   if( hb_param( 1, HB_IT_STRING ) != NULL )
   {
      HB_THREAD_ID th_id;
      
      if( gcFuncName ) free( gcFuncName );
      gcFuncName = strdup( hb_parc( 1 ) );
      
      hb_threadCreate( &th_id, hsw_harbour_thread, NULL );
      hsw_swift_start(); // Toma el control del Hilo 0 (UI)
   }
   else 
   {
       printf( "HSW Error: HSW_START_SWIFT requiere el nombre de la función de inicio.\n" );
   }
}
