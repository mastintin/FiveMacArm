#include <fivemac.h>

HB_FUNC(CREATEURL) {
  NSString *string = hb_NSSTRING_par(1);

  if (string) {
    // 1. Creamos el objeto con 'alloc'. Esto pone el contador de referencias
    // en 1. NO usamos autorelease aquí porque queremos que "viva" fuera de esta
    // función.
    NSURL *name = [[NSURL alloc] initWithString:string];

    if (name) {
      hb_retnll((HB_LONGLONG)name);
      return;
    }
  }

  hb_retnll(0);
}

//-------------------------------------------------------------------------------//

HB_FUNC(CREATEURLFILE) {
  NSString *string = hb_NSSTRING_par(1);

  if (string) {
    // Usamos alloc/init sin autorelease para que NO se destruya al salir de la
    // función
    NSURL *name = [[NSURL alloc] initFileURLWithPath:string];

    if (name) {
      hb_retnll((HB_LONGLONG)name);
      return;
    }
  }

  hb_retnll(0);
}

//-------------------------------------------------------------------------------//

HB_FUNC(URLPATHEXTENSION) {
  NSURL *name = (NSURL *)hb_parnll(1);

  if (name) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // pathExtension devuelve un NSString que vive en el pool actual
    NSString *source = [name pathExtension];

    if (source) {
      hb_retc([source UTF8String]);
    } else {
      hb_retc("");
    }

    [pool drain]; // Limpia la extensión de la memoria de inmediato
  } else {
    hb_retc("");
  }
}

//-------------------------------------------------------------------------------//

HB_FUNC(RELEASEURL) {
  NSURL *name = (NSURL *)hb_parnll(1);
  if (name) {
    [name release]; // Esto baja el contador a 0 y libera la RAM
  }
}

//-------------------------------------------------------------------------------//

HB_FUNC(URLLOAD) {
  // 1. Iniciamos el pool para capturar los objetos temporales
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // hb_NSSTRING_par suele devolver un objeto autoreleased
  NSString *string = hb_NSSTRING_par(1);

  if (string) {
    // URLWithString también devuelve un objeto autoreleased
    NSURL *url = [NSURL URLWithString:string];

    if (url) {
      [[NSWorkspace sharedWorkspace] openURL:url];
    }
  }

  // 2. Al drenar el pool, liberamos 'string' y 'url' de la memoria
  // inmediatamente
  [pool drain];
}

//-------------------------------------------------------------------------------//

HB_FUNC(URLPATH) {
  NSURL *name = (NSURL *)hb_parnll(1);

  if (name) {
    // El pool debe envolver la creación de los NSString temporales
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *source = [[name path] stringByRemovingPercentEncoding];

    if (source) {
      hb_retc([source UTF8String]);
    } else {
      hb_retc("");
    }

    // Aquí se destruye 'source' y el string devuelto por 'path'
    [pool drain];
  } else {
    hb_retc("");
  }
}
