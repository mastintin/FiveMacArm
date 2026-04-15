#include "FiveMac.ch"

//----------------------------------------------------------------------------//
// Funciones de Información y Alerta (Síncronas por defecto para Harbour)
//----------------------------------------------------------------------------//

FUNCTION SwMsgInfo( cMsg, cTitle )
return SDS:SwMsgInfo( cMsg, cTitle )

FUNCTION SwMsgStop( cMsg, cTitle )
return SDS:SwMsgStop( cMsg, cTitle )

FUNCTION SwMsgAlert( cMsg, cTitle )
return SDS:SwMsgAlert( cMsg, cTitle )

//----------------------------------------------------------------------------//
// Funciones de Decisión
//----------------------------------------------------------------------------//

FUNCTION SwMsgYesNo( cMsg, cTitle )
return SDS:SwMsgGet( cMsg, cTitle ) // Devuelve .T. o .F.

//----------------------------------------------------------------------------//
// Funciones Asíncronas (No bloqueantes para Harbour)
//----------------------------------------------------------------------------//

FUNCTION SwNotify( cMsg, cTitle )
return SD:SwMsgWait( cMsg, cTitle ) // Lanza el aviso y sigue

//----------------------------------------------------------------------------//
// Utilidades de Archivos (Wrappers para mayor comodidad)
//----------------------------------------------------------------------------//

FUNCTION SwFileWrite( cFile, cContent )
return SD:SwFileWrite( cFile, cContent )

//----------------------------------------------------------------------------//
// Diálogos de Selección (Síncronos)
//----------------------------------------------------------------------------//

FUNCTION SwGetFile( cTitle, cTypes )
return SDS:SwGetFile( cTitle, cTypes )

FUNCTION SwGetDir( cTitle )
return SDS:SwGetDir( cTitle )

FUNCTION SwSaveFile( cTitle, cDefaultName )
return SDS:SwSaveFile( cTitle, cDefaultName )

//----------------------------------------------------------------------------//
