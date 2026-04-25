Function Main()
   Local nThread
   
   ? "--- Harbour MT Detector ---"
   ? "Harbour Version:", hb_Version()
   ? "Compiler:", hb_Compiler()
   ? "Multi-threaded VM (hb_mtVM()):", hb_mtVM()
   ? "---------------------------"
   
   if ! hb_mtVM()
      ? " [ALERTA] La VM de Harbour NO es multihilo."
      ? " No se pueden usar funciones hb_thread*."
      return nil
   endif
   
   ? " Intentando lanzar un hilo hijo..."
   
   nThread := hb_threadStart( @HiloHijo(), "Mensaje desde el hijo" )
   
   if empty( nThread )
      ? " [ERROR] hb_threadStart falló."
   else
      ? " [EXITO] Hilo hijo lanzado con ID:", nThread
      ? " Esperando a que el hijo termine..."
      hb_threadJoin( nThread )
      ? " Hilo hijo ha finalizado."
   endif
   
return nil

Procedure HiloHijo( cMsg )
   ? " -> HiloHijo dice:", cMsg
   hb_idleSleep( 1 )
   ? " -> HiloHijo terminando..."
return
