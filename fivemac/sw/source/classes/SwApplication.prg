#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwApplication

    DATA cId
    
    METHOD New()
    METHOD Activate()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TSwApplication

    ::cId := "MAINAPP"
    
    // Register the application in the global registry
    SwiftRegisterItem( ::cId, Self )

return Self

//----------------------------------------------------------------------------//

METHOD Activate() CLASS TSwApplication

    // Delegate idempotency to Swift (NSApp.isRunning)
    SW_APPRUN()

return nil

//----------------------------------------------------------------------------//
