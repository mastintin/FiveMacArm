#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local cUUID

    cUUID := Swift_UUID()
   
    MsgInfo( "Generated UUID: " + cUUID )
   
    // Verify it's different
    MsgInfo( "Another UUID: " + Swift_UUID() )

return nil
