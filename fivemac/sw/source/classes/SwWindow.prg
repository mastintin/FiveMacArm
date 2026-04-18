#include "FiveMac.ch"
 
  CLASS TSwWindow FROM TSwiftControl
  
      METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CONSTRUCTOR
      METHOD Activate()
      METHOD Close() INLINE ::End()
  
  ENDCLASS
  
  //----------------------------------------------------------------------------//
  
  METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CLASS TSwWindow
  
      DEFAULT nWidth := 500, nHeight := 400
      
      // Llamamos a la base para inicializar hState e ID de forma estándar
      ::Super:New( 0, 0, nWidth, nHeight, cId )
  
      ::oParent         := oParent
      ::hState["title"] := cTitle
      ::hState["type"]  := "window"
      ::hState["typeid"] := 100 
   
      // CREACIÓN POR MENSAJERÍA ASÍNCRONA (Fire-and-Forget)
      // Ahora Harbour no espera, confía en el orden del Pipeline
      SD:Create( ::hState )
    
   return self
  
  //----------------------------------------------------------------------------//
 
  METHOD Activate() CLASS TSwWindow
     // Si es la primera ventana, arrancamos el motor
     if !Sw_AppIsRunning()
        SD:Sync():Apply( ::cId, { "center" => .t. } )
        Sw_AppRun()
     else
        SD:Apply( ::cId, { "center" => .t. } )
     endif
  return nil
  
  //----------------------------------------------------------------------------//
