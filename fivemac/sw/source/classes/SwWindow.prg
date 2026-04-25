#include "SwFive.ch"
 
   CLASS TSwWindow FROM TSwiftControl
   
       DATA lVisible  INIT .f.
       
       DATA bOnEnd
       DATA bOnInit
       
       METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CONSTRUCTOR
       METHOD Activate( lModal )
       METHOD End()
       METHOD Close() INLINE ::End()
       METHOD Update( hProps )
       
       METHOD Disable() INLINE SD:Apply( ::cId, { "interactive" => .f. } )
       METHOD Enable()  INLINE SD:Apply( ::cId, { "interactive" => .t. } )
   
   ENDCLASS
   
   //----------------------------------------------------------------------------//
   
   METHOD New( cTitle, nWidth, nHeight, cId, oParent ) CLASS TSwWindow
   
       DEFAULT nWidth := 500, nHeight := 400
       
       // Llamamos a la base para inicializar hState e ID de forma estándar
       ::Super:New( 0, 0, nWidth, nHeight, cId )
   
       ::oParent         := oParent
       ::hState["title"] := cTitle
       ::hState["type"]  := 100
    
       // CREACIÓN POR MENSAJERÍA ASÍNCRONA (Fire-and-Forget)
       // Ahora Harbour no espera, confía en el orden del Pipeline
       SDS:Create( ::hState )
     
    return self
   
   //----------------------------------------------------------------------------//
  
   METHOD Activate( lModal ) CLASS TSwWindow
   
      hb_default( @lModal, .f. )
      ::lVisible := .t.
      ::hState["modal"] := lModal
   
      if lModal
         SDS:Apply( ::cId, { "modal" => .t. } ) 
      endif
   
      // Si es la primera ventana, arrancamos el motor
      if !TSwApplication():isRunning()
         Sw_AppRun()
      endif
   
   RETURN nil
   
   //----------------------------------------------------------------------------//
   
   METHOD End() CLASS TSwWindow
      if ::bOnEnd != nil
         Eval( ::bOnEnd, Self )
      endif
      ::lVisible := .f.
      SD:Apply( ::cId, { "close" => .t. } )
   return nil
   
   //----------------------------------------------------------------------------//
   
   METHOD Update( hProps ) CLASS TSwWindow
       local cEvent := hb_HGetDef( hProps, "event", "" )

       if hb_HHasKey( hProps, "close" )
          ::End()
       elseif cEvent == "init"
          if !Empty( ::bOnInit )
             Eval( ::bOnInit, Self )
          endif
       endif
    return nil
   
   //----------------------------------------------------------------------------//
