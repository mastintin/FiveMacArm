#import <Foundation/Foundation.h>
#import <hbapi.h>
#import <hbapiitm.h>
#import <hbthread.h>
#import <hbvm.h>

// Definimos los prototipos de las funciones Swift
extern void hsw_swift_start(void);
extern void HSW_SEND_COMMAND(const char *json);

static char * gcFuncName = NULL;

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

// Inicializa el motor Swift y mueve Harbour a un hilo secundario
HB_FUNC( HSW_START_SWIFT )
{
   if( hb_param( 1, HB_IT_STRING ) != NULL )
   {
      HB_THREAD_ID th_id;
      
      if( gcFuncName ) free( gcFuncName );
      gcFuncName = strdup( hb_parc( 1 ) );
      
      hb_threadCreate( &th_id, hsw_harbour_thread, NULL );
      hsw_swift_start(); // Bloqueante, toma el control del Hilo 0
   }
   else 
   {
       printf( "HSW Error: HSW_START_SWIFT requiere el nombre de la función de inicio.\n" );
   }
}

// --- PUENTE: HSW_SEND_COMMAND( cJson ) ---
// Llamado desde Harbour para enviar mensajes a la UI
HB_FUNC( HSW_SEND_COMMAND )
{
   if( hb_param( 1, HB_IT_STRING ) != NULL )
   {
      HSW_SEND_COMMAND( hb_parc( 1 ) );
   }
}
