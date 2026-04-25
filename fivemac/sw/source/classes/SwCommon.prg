// Common Utilities for the Swift Island

// SW_LOG: Escribe trazabilidad en un archivo de log usando funciones core
function SW_LOG( cMsg )
   local nHandle, cLog
   cLog := "[" + Time() + "] " + hb_ValToStr( cMsg ) + hb_OsNewLine()
   
   if ! File( "sw_bridge.log" )
      nHandle := fCreate( "sw_bridge.log" )
   else
      nHandle := fOpen( "sw_bridge.log", 1 ) // FO_WRITE
   endif
   
   if nHandle >= 0
      fSeek( nHandle, 0, 2 ) // FO_END
      fWrite( nHandle, cLog )
      fClose( nHandle )
   endif
return nil

