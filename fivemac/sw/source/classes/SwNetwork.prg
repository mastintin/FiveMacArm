#include "swfive.ch"

//----------------------------------------------------------------------------//

CLASS TSwNetwork FROM TSwiftControl
   
   DATA hRequests  INIT {=>}

   METHOD New( lSync ) 
   
   METHOD SetSync()   INLINE ( ::lSync := .T., self )
   METHOD SetAsync()  INLINE ( ::lSync := .F., self )

   ACCESS lSync          INLINE ::hState["lsync"]
   ASSIGN lSync( l )     INLINE ::hState["lsync"] := l

   // Motor Genérico (Fontanería Unificada)
   METHOD Query( cCmd, hParams, bAction, lSync )
   METHOD Send( lSync )  INLINE if( hb_defaultValue( lSync, ::lSync ), SDS, SD )

   // Estado de red (Capa de abstracción)
   METHOD IsConnected( bAction, lSync )     INLINE ::Query( "isconnected", {=>}, bAction, lSync )
   METHOD GetIP( bAction, lSync )           INLINE ::Query( "getip", {=>}, bAction, lSync )
   METHOD CanResume( cUrl, bAction, lSync ) INLINE ::Query( "httpcanresume", { "url" => cUrl }, bAction, lSync )

   // Cabeceras
   METHOD SetHeader( cKey, cValue ) INLINE ::Send():HttpHeader( ::cId, cKey, cValue )
   METHOD ClearHeaders()            INLINE ::Send():HttpClear( ::cId )

   // Peticiones HTTP 
   METHOD Get( cUrl, bAction, lSync )       INLINE ::Query( "httpget", { "url" => cUrl }, bAction, lSync )
   METHOD Post( cUrl, cJson, bAction, lSync )    INLINE ::Query( "httppost", { "url" => cUrl, "json" => cJson }, bAction, lSync )
   METHOD Put( cUrl, cJson, bAction, lSync )     INLINE ::Query( "httpput", { "url" => cUrl, "json" => cJson }, bAction, lSync ) 
   METHOD Delete( cUrl, bAction, lSync )         INLINE ::Query( "httpdelete", { "url" => cUrl }, bAction, lSync )   

   // Descarga y Subida
   METHOD WaitDownload( cUrl, cFile, bAction, lSync ) INLINE ::Query( "httpdownload", { "url" => cUrl, "path" => cFile }, bAction, lSync )
   METHOD Download( cUrl, cFile, bAction )  INLINE ::WaitDownload( cUrl, cFile, bAction, .F. )
   METHOD Upload( cUrl, cFile, bAction, lSync )       INLINE ::Query( "httpupload", { "url" => cUrl, "path" => cFile }, bAction, lSync )

   // Reactor Genérico 
   METHOD Update( hProps )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( lSync ) CLASS TSwNetwork
   ::Super:New()
   ::hState["lsync"] := hb_defaultValue( lSync, .F. )
return self

//----------------------------------------------------------------------------//

METHOD Query( cCmd, hParams, bAction, lSync ) CLASS TSwNetwork
   local cReqId  := Lower( cCmd )
   local lIsSync := hb_defaultValue( lSync, ::lSync )
   
   if lIsSync
      return SDS:Apply( ::cId, hb_HMerge( { "cmd" => cCmd }, hParams ) )
   endif

   // En modo asíncrono, generamos UUID para peticiones de datos (concurrencia)
   if cReqId $ "httpget,httppost,httpput,httpdelete,httpdownload,httpupload"
      cReqId := hb_UUID()
   endif

   if bAction != nil ; ::hRequests[ cReqId ] := bAction ; endif
   
   ::Send():Apply( cReqId, hb_HMerge( { "cmd" => cCmd, "targetId" => ::cId }, hParams ) )
   
return cReqId

//----------------------------------------------------------------------------//

METHOD Update( hProps ) CLASS TSwNetwork
   local aKeys, n, cReqId, uResult, bAction
   
   if ValType( hProps ) == "H"
      aKeys := hb_HKeys( hProps )
      for n := 1 to Len( aKeys )
          cReqId := aKeys[ n ]
          uResult := hProps[ cReqId ]
          
          if hb_HHasKey( ::hRequests, cReqId )
             bAction := ::hRequests[ cReqId ]
             hb_HDel( ::hRequests, cReqId ) 
             Eval( bAction, uResult, self )
          endif
      next
   endif

return nil
