#import <Cocoa/Cocoa.h>
#include <hbapi.h>
#include <hbvm.h>
#include <pthread.h>

// Prototipo de la función que arrancará Swift (definida en Swift)
extern void hsw_swift_start(void);

// Estructura para pasar argumentos al hilo de Harbour
typedef struct {
    int argc;
    char **argv;
} hb_thread_args;

// --- HILO PRINCIPAL: El mundo de Swift/UI ---
int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSLog(@"[HSW] Sistema: Arranque nativo Harbour...");
        
        // 1. Inicialización de la VM
        hb_vmInit( 1 );
        
        // 2. Ejecutar Function Main() de Harbour en el Hilo 0 (como siempre)
        hb_cmdargInit( argc, argv );
        hb_vmDo( 0 );
        
        hb_vmQuit();
    }
    return 0;
}
