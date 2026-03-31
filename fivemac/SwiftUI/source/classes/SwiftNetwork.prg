#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftNetwork

   CLASSDATA nTimeout INIT 30

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
   METHOD Download( cUrl, cFile )  INLINE SD_SW_Http_Download( cUrl, cFile )
   METHOD Upload( cUrl, cFile )    INLINE SD_SW_Http_Upload( cUrl, cFile )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TSwiftNetwork
return Self

//----------------------------------------------------------------------------//
