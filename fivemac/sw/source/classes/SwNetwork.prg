#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwNetwork
   
   CLASSDATA nTimeout INIT 30
   CLASSDATA hDownloads INIT {=>}
   
   DATA lSync  INIT .F.  // Estado persistente: .T. = Síncrono, .F. = Asíncrono

   METHOD New( lSync ) CONSTRUCTOR
   
   // Métodos de utilidad para cambiar el estado rápidamente
   METHOD SetSync()   INLINE ( ::lSync := .T., Self )
   METHOD SetAsync()  INLINE ( ::lSync := .F., Self )

   // Estado de red
   METHOD IsConnected( lSync ) 
   METHOD GetIP( lSync )      
   METHOD CanResume( cUrl, lSync )

   // Cabeceras personalizadas
   METHOD SetHeader( cKey, cValue ) 
   METHOD ClearHeaders()           

   // Peticiones HTTP 
   METHOD Get( cUrl, nTimeout, lSync )
   METHOD Post( cUrl, cJson, nTimeout, lSync )
   METHOD Put( cUrl, cJson, nTimeout, lSync ) 
   METHOD Delete( cUrl, nTimeout, lSync )   

   // Descarga y Subida de archivos
   METHOD WaitDownload( cUrl, cFile, nTimeout, lSync )  
   METHOD Download( cUrl, cFile, bOnEnd )  
   METHOD Upload( cUrl, cFile, nTimeout, lSync )       

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( lSync ) CLASS TSwNetwork
   ::lSync := hb_defaultValue( lSync, .F. )
return self

//----------------------------------------------------------------------------//
// Lógica de Despacho (Busca el Dispatcher según lSync)
//----------------------------------------------------------------------------//

static function GetDispatcher( lSync )
return if( lSync, SDS, SD )

//----------------------------------------------------------------------------//

METHOD IsConnected( lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):IsConnected()

METHOD GetIP( lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):GetIP()

METHOD CanResume( cUrl, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpCanResume( cUrl )

METHOD SetHeader( cKey, cValue ) CLASS TSwNetwork
   SD:HttpHeader( cKey, cValue ) // Las cabeceras siempre son síncronas/inmediatas en el motor
return nil

METHOD ClearHeaders() CLASS TSwNetwork
   SD:HttpClear()
return nil

METHOD Get( cUrl, nTimeout, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpGet( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )

METHOD Post( cUrl, cJson, nTimeout, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpPost( cUrl, cJson, hb_defaultValue( nTimeout, ::nTimeout ) )

METHOD Put( cUrl, cJson, nTimeout, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpPut( cUrl, cJson, hb_defaultValue( nTimeout, ::nTimeout ) )

METHOD Delete( cUrl, nTimeout, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpDelete( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )

METHOD WaitDownload( cUrl, cFile, nTimeout, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpDownload( cUrl, cFile, hb_defaultValue( nTimeout, ::nTimeout ) )

METHOD Upload( cUrl, cFile, nTimeout, lSync ) CLASS TSwNetwork
return GetDispatcher( hb_defaultValue( lSync, ::lSync ) ):HttpUpload( cUrl, cFile, hb_defaultValue( nTimeout, ::nTimeout ) )

METHOD Download( cUrl, cFile, bOnEnd ) CLASS TSwNetwork
   LOCAL cId := hb_UUID()
   
   IF bOnEnd != nil
      ::hDownloads[ cId ] := bOnEnd
   ENDIF
   
   SD:HttpDownload( cUrl, cFile, cId ) // Las descargas puramente asíncronas siempre usan SD
return cId
