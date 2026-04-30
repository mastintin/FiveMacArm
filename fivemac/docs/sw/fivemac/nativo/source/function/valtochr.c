#include <hbapi.h>
#include <hbapicls.h>
#include <hbapiitm.h>
#include <hbvm.h>
#include <stdio.h>
#include <string.h>

// Necesario para NSString
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

//----------------------------------------------------------------------------//

const char *ValToChar(PHB_ITEM item) {
  static char szBuffer[1024];
  szBuffer[0] = '\0';

  if (item) {
    // Invocamos a CVALTOCHAR de Harbour para que haga la conversion pesada
    PHB_ITEM pRes = hb_itemDoC("CVALTOCHAR", 1, item);

    if (pRes) {
      // Extraemos el puntero de cadena C
      const char *szText = hb_itemGetCPtr(pRes);
      if (szText) {
        // COPIAMOS el texto a nuestro buffer estatico antes de liberar el item
        strncpy(szBuffer, szText, 1023);
        szBuffer[1023] = '\0';
      }
      // LIBERAMOS el item temporal para evitar el leak de 16-32 bytes
      hb_itemRelease(pRes);
    }
  }

  return szBuffer;
}

//----------------------------------------------------------------------------//

#ifdef __OBJC__
// Prototipo necesario para evitar declaraciones implicitas
NSString *HB_To_NSString(PHB_ITEM pItem);

// Funcion puente definitiva: accede al parametro, convierte el tipo y libera items temporales
NSString *hb_NSSTRING_VAL_par(int iParam) {
  return HB_To_NSString(hb_param(iParam, HB_IT_ANY));
}

// Funcion puente ultra-segura (autorelease)
NSString *HB_To_NSString(PHB_ITEM pItem) {
  if (!pItem)
    return @"";
  return [NSString stringWithUTF8String:ValToChar(pItem)];
}
#endif

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
