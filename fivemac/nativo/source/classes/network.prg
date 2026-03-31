#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TNetwork

   CLASSDATA nTimeout INIT 30

   METHOD New() CONSTRUCTOR

   // Estado de red
   METHOD IsConnected() INLINE NET_ISCONNECTED()
   METHOD GetIP()       INLINE NET_GETIP()
   METHOD GetPublicIP() INLINE NET_GETPUBLICIP( ::nTimeout )
   METHOD GetMac()      INLINE NET_GETMACADDRESS()

   // Cabeceras personalizadas
   METHOD SetHeader( cKey, cValue ) INLINE NET_HTTPSETHEADER( cKey, cValue )
   METHOD ClearHeaders()            INLINE NET_HTTPCLEARHEADERS()

   // Peticiones HTTP
   METHOD Get( cUrl, nTimeout )    INLINE NET_HTTPGET( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD GetJson( cUrl, nTimeout ) INLINE NET_HTTPGETJSON( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Post( cUrl, cJson, nTimeout ) INLINE NET_HTTPPOST( cUrl, cJson, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Put( cUrl, cJson, nTimeout )  INLINE NET_HTTPPUT( cUrl, cJson, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Delete( cUrl, nTimeout )      INLINE NET_HTTPDELETE( cUrl, hb_defaultValue( nTimeout, ::nTimeout ) )

   // Descarga y Subida de archivos
   METHOD Download( cUrl, cFile, nTimeout ) INLINE NET_HTTPDOWNLOAD( cUrl, cFile, hb_defaultValue( nTimeout, ::nTimeout ) )
   METHOD Upload( cUrl, cFile, nTimeout )   INLINE NET_HTTPUPLOAD( cUrl, cFile, hb_defaultValue( nTimeout, ::nTimeout ) )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TNetwork
return Self

//----------------------------------------------------------------------------//
