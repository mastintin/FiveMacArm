#include "swfive.ch"

//----------------------------------------------------------------------------//

CLASS TSwApplication

    DATA cId
    DATA lRunning INIT .F.
    
    METHOD New()
    METHOD Activate()
    METHOD isRunning() INLINE Sw_GetQueryProxy():isRunning()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TSwApplication

    ::cId := "MAINAPP"
    
    // Register the application in the global registry
    SwiftRegisterItem( ::cId, Self )

return Self

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TSwApplication

    if ::lRunning
       return nil
    endif

    ::lRunning := .T.
    
    // El motor de la Isla toma el control (Bloqueante)
    // El motor ahora se inicia vía HSW_START_SWIFT()

    // Cuando el bucle termina, actualizamos el estado real
    ::lRunning := ::isRunning()

return nil

//----------------------------------------------------------------------------//
