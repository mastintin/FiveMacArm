#include "FiveMac.ch"

// ---------------------------------------------------------
// Legacy Wrappers for SwiftSystem functions
// These map old CSW... and SW_MSG... names to new SD_SW_... direct bridges
// ---------------------------------------------------------

FUNCTION CSWGETFILE( cTitle, cTypes, cPrompt )
RETURN SD_SW_GET_FILE( cTitle, cTypes, cPrompt )

FUNCTION CSWGETDIR( cTitle, cPrompt )
RETURN SD_SW_GET_DIR( cTitle, cPrompt )

FUNCTION CSWGETIMAGEFILE( cTitle, cPrompt )
RETURN SD_SW_GET_IMAGE( cTitle, cPrompt )

FUNCTION SW_MSGINFO( cMsg, cTitle )
   DEFAULT cTitle := "Attention"
RETURN SD_SW_ALERT( cMsg, cTitle, 0 )

FUNCTION SW_MSGYESNO( cMsg, cTitle )
   DEFAULT cTitle := "Select"
RETURN SD_SW_MSG_YES_NO( cMsg, cTitle )

FUNCTION CSWGETCOLOR()
RETURN SD_SW_GET_COLOR()

FUNCTION CSWPATH()
RETURN SD_SW_GET_PATH()

FUNCTION CSWAPPPATH()
RETURN SD_SW_GET_APP_PATH()

FUNCTION CSWRESPATH()
RETURN SD_SW_GET_RES_PATH()

// ---------------------------------------------------------
// Legacy Wrappers for Observation functions
// ---------------------------------------------------------

FUNCTION SW_OBS_SETCOUNT( nVal )
RETURN SD_OBS_SET_COUNT( nVal )

FUNCTION SW_OBS_SETMSG( cMsg )
RETURN SD_OBS_SET_MSG( cMsg )

FUNCTION SW_OBS_GETCOUNT()
RETURN SD_OBS_GET_COUNT()

FUNCTION SW_OBS_GETLEVEL()
RETURN SD_OBS_GET_LEVEL()

FUNCTION SW_OBS_GETENABLED()
RETURN SD_OBS_GET_ENABLED()
