#include "Fivemac.ch"
#include "swfive.ch"

function Main()

   local lRet
   
   MsgInfo( "Vamos a probar el nuevo MsgYesNo de SwiftFive" )
   
   // Ahora MsgYesNo() llama internamente a Swift!
   lRet := MsgYesNo( "¿Deseas continuar con la prueba?", "SwiftFive Native" )
   
   if lRet
      MsgInfo( "Has dicho que SI" )
   else
      MsgInfo( "Has dicho que NO" )
   endif

return nil
