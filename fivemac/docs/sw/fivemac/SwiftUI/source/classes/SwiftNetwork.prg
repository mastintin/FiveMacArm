#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftNetwork

   CLASSDATA nTimeout INIT 30

   CLASSDATA hDownloads INIT {=>}

   METHOD New() CONSTRUCTOR

   // Estado de red (Swift Native)
   METHOD IsConnected() INLINE SD_SW_IsConnected()
   METHOD GetIP()      INLINE SD_SW_GetIP()

   // Cabeceras personalizadas
   METHOD SetHeader( cKey, cValue ) INLINE SD_SW_Http_Set_Header( cKey, cValue )
   METHOD ClearHeaders()            INLINE SD_SW_Http_Clear_Headers()

   // Peticiones HTTP (Swift Native)
   METHOD Get( cUrl, nTimeout )    INLINE SD_SW_Http_Get( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD GetJson( cUrl )          INLINE SD_SW_Http_Get_Json( cUrl )
   METHOD Post( cUrl, cJson, nTimeout ) INLINE SD_SW_Http_Post( cUrl, cJson, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Put( cUrl, cJson, nTimeout )  INLINE SD_SW_Http_Put( cUrl, cJson, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Delete( cUrl, nTimeout )      INLINE SD_SW_Http_Delete( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )

   // Descarga y Subida de archivos
   METHOD CanResume( cUrl )                      INLINE SD_SW_Http_Can_Resume( cUrl )
   METHOD WaitDownload( cUrl, cFile, nTimeout )  INLINE SD_SW_Http_Wait_Download( cUrl, cFile, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Download( cUrl, cFile, bOnEnd )  
   METHOD Upload( cUrl, cFile, nTimeout )        INLINE SD_SW_Http_Upload( cUrl, cFile, hb_defaultValue( nTimeout, ::nTimeout ) )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TSwiftNetwork
return Self

//----------------------------------------------------------------------------//

METHOD Download( cUrl, cFile, bOnEnd ) CLASS TSwiftNetwork
   LOCAL cResumeFile := cFile + ".resume"
   LOCAL cId 
   LOCAL cPathToResume := ""
   
   // 1. Verificamos si existe archivo de reanudación y si el servidor lo permite
   IF File( cResumeFile ) .and. ::CanResume( cUrl )
      
      IF MsgNoYes( "Se ha detectado una descarga previa interrumpida para este archivo." + hb_OsNewLine() + hb_OsNewLine() + ;
                   "¿Desea continuar con la descarga desde donde se quedó?", "Reanudar descarga" )
                   
          cPathToResume := cResumeFile
          
      ELSE
          // El usuario no quiere reanudar. Preguntamos si quiere empezar de cero.
          IF MsgNoYes( "¿Desea eliminar los datos previos y comenzar la descarga desde el principio?", "Nueva descarga" )
             FErase( cResumeFile )
             // cPathToResume se queda vacío, por lo que Swift empezará de cero
          ELSE
             // El usuario no quiere reanudar ni empezar de cero (Cancelar todo)
             RETURN NIL 
          ENDIF
      ENDIF
   ENDIF

   // 2. Iniciamos el proceso normal de descarga asíncrona
   cId := hb_MD5( cUrl + cFile + TString( hb_MilliSeconds() ) )
   
   if ! Empty( bOnEnd )
      ::hDownloads[ cId ] = bOnEnd
   endif
   
   SD_SW_Http_Download_Async( cUrl, cFile, cId, cPathToResume )
   
return NIL

//----------------------------------------------------------------------------//
// Función receptora del evento Swift (Callback)
//----------------------------------------------------------------------------//

FUNCTION SW_NET_ON_DOWNLOAD_END( cId, lSuccess )
   LOCAL bOnEnd 
   
   if hb_HHasKey( TSwiftNetwork():hDownloads, cId )
      bOnEnd = TSwiftNetwork():hDownloads[ cId ]
      hb_HDel( TSwiftNetwork():hDownloads, cId )
      Eval( bOnEnd, lSuccess )
   endif
   
return NIL
