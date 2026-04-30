#include <fivemac.h>

HB_FUNC(CREATEPREFERENCES) {
  // standardUserDefaults es un singleton manejado por el sistema.
  // En No-ARC, NO necesita [release] ni [retain] al obtenerlo así.
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

  if (preferences != nil) {
    hb_retnll((HB_LONGLONG)(uintptr_t)preferences);
  } else {
    hb_retnll(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PREFERENCES_SYNC) {
  // Recuperamos el puntero que guardaste en Harbour
  NSUserDefaults *preferences = (NSUserDefaults *)(uintptr_t)hb_parnll(1);

  if (preferences != nil) {
    // synchronize devuelve un BOOL (YES si tuvo éxito)
    hb_retl((BOOL)[preferences synchronize]);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTWRITETOFILE) {
  NSDictionary *dict = (NSDictionary *)hb_parnll(1);
  NSString *file = hb_NSSTRING_par(2);
  BOOL atomic = hb_parl(3);

  if (dict != nil && file != nil) {
    hb_retl([dict writeToFile:file atomically:atomic]);
  } else {
    hb_retl(NO);
  }
}

// --- PREFERENCES (GET / SET Strings) ---

HB_FUNC(SETSTRINGPREFERENCE) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  NSString *value = hb_NSSTRING_par(3);

  if (preferences != nil && key != nil) {
    [preferences setObject:value forKey:key];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(GETSTRINGPREFERENCE) {

  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);

  if (preferences != nil && key != nil) {
    NSString *value = [preferences stringForKey:key];
    if (value != nil) {
      hb_retc([value UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

// --- NUMBERS (Integer) ---

HB_FUNC(PREFERENCES_SETINT) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  int value = hb_parni(3);

  if (preferences != nil && key != nil) {
    [preferences setInteger:value forKey:key];
  }
}

HB_FUNC(PREFERENCES_GETINT) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);

  if (preferences != nil && key != nil) {
    hb_retni((int)[preferences integerForKey:key]);
  } else {
    hb_retni(0);
  }
}

// --- BOOLEANS ---

HB_FUNC(PREFERENCES_SETBOOL) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  BOOL value = hb_parl(3);

  if (preferences != nil && key != nil) {
    [preferences setBool:value forKey:key];
  }
}

HB_FUNC(PREFERENCES_GETBOOL) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);

  if (preferences != nil && key != nil) {
    hb_retl([preferences boolForKey:key]);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PREFERENCES_REMOVE) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);

  if (preferences != nil && key != nil) {
    [preferences removeObjectForKey:key];
    // Opcional: podrías devolver .T. si la ejecución llega aquí
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(PREFERENCES_REMOVEALL) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  [preferences removePersistentDomainForName:bundleIdentifier];
}

//----------------------------------------------------------------------//

HB_FUNC(SETDEFAULTPREFERENCE) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSDictionary *preferencesByDefault = [NSDictionary
      dictionaryWithObjectsAndKeys:@"Nombreprog", @"sciedit", @"pathfivemac",
                                   @"~/fivemac", @"pathharbour", @"~/harbour",
                                   nil];

  if ([preferences stringForKey:@"Nombreprog"] == nil)
    [preferences registerDefaults:preferencesByDefault];
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);

  if (file != nil && key != nil) {
    // Usamos el método de conveniencia 'dictionaryWithContentsOfFile'.
    // Este método devuelve un objeto con 'autorelease',
    // por lo que NO hay leak y NO hay que hacer [release].
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      NSString *cValue = [dict objectForKey:key];

      if (cValue != nil) {
        // Usamos tu función probada para devolver el string
        hb_retstr_NS(cValue);
      } else {
        hb_retc("");
      }
    } else {
      hb_retc(""); // El archivo no existe o no es un Plist válido
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------//

HB_FUNC(SETPLISTVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  NSString *value = hb_NSSTRING_par(3);

  // Si hb_pcount() es menor a 4, usamos YES por defecto
  BOOL bAtomic = (hb_pcount() >= 4) ? hb_parl(4) : YES;

  if (file != nil && key != nil && value != nil) {
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithContentsOfFile:file];

    if (dict == nil) {
      dict = [NSMutableDictionary dictionary];
    }

    [dict setObject:value forKey:key];

    // Usamos nuestra variable bAtomic
    BOOL success = [dict writeToFile:file atomically:bAtomic];

    hb_retl(success);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(SETPLISTARRAYVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  // Recuperamos el puntero del array (debe ser un NSMutableArray previo)
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(3);
  BOOL bAtomic = (hb_pcount() >= 4) ? hb_parl(4) : YES;

  if (file != nil && key != nil && myarray != nil) {
    // En No-ARC, usamos métodos de conveniencia para evitar el [release]
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithContentsOfFile:file];

    if (dict == nil) {
      dict = [NSMutableDictionary dictionary];
    }

    // IMPORTANTE: Usamos 'setObject' en lugar de 'setValue' para mayor
    // seguridad con arrays
    [dict setObject:myarray forKey:key];

    BOOL success = [dict writeToFile:file atomically:bAtomic];
    hb_retl(success);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTARRAYVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);

  if (file != nil && key != nil) {
    // Usamos método de conveniencia para evitar leak del diccionario en No-ARC
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      NSArray *originalArray = [dict objectForKey:key];

      if (originalArray != nil &&
          [originalArray isKindOfClass:[NSArray class]]) {
        // Creamos una copia mutable para que Harbour pueda manipularla.
        // IMPORTANTE: En No-ARC, si vas a guardar este puntero en una variable
        // de Harbour para usarlo LUEGO, necesitamos asegurar que no
        // desaparezca.
        NSMutableArray *myArray =
            [[NSMutableArray alloc] initWithArray:originalArray];

        // Lo devolvemos como LONGLONG.
        // NOTA: Al usar 'alloc', este objeto DEBE ser liberado luego con una
        // función tipo 'ARRAY_RELEASE' o similar para no dejar leak.
        hb_retnll((HB_LONGLONG)myArray);
        return;
      }
    }
  }

  hb_retnll(0); // Si algo falla, devolvemos 0 (puntero nulo)
}

//----------------------------------------------------------------------//

HB_FUNC(ISKEYPLIST) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);

  if (file != nil && key != nil) {
    // Usamos método de conveniencia (autorelease) para evitar el leak del
    // diccionario
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      // Comprobamos si la llave existe (si devuelve algo distinto de nil)
      id value = [dict objectForKey:key];
      hb_retl(value != nil);
      return;
    }
  }

  // Si el archivo no existe o la llave no se encuentra
  hb_retl(NO);
}

//----------------------------------------------------------------------//

HB_FUNC(SETPLISTBOOLEAN) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  BOOL value = hb_parl(3);
  BOOL bAtomic = (hb_pcount() >= 4) ? hb_parl(4) : YES;

  if (file != nil && key != nil) {
    // Usamos el método de conveniencia para que Cocoa gestione la memoria solo
    // (No-ARC)
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithContentsOfFile:file];

    if (dict == nil) {
      dict = [NSMutableDictionary dictionary];
    }

    // Los Plist no guardan BOOLs puros, guardan objetos NSNumber
    // numberWithBool devuelve un objeto con autorelease, perfecto para No-ARC
    [dict setObject:[NSNumber numberWithBool:value] forKey:key];

    BOOL success = [dict writeToFile:file atomically:bAtomic];
    hb_retl(success);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTBOOLEAN) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);

  if (file != nil && key != nil) {
    // Usamos método de conveniencia (autorelease) para evitar leak
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      id value = [dict objectForKey:key];

      // Verificamos si el valor es un NSNumber y si su valor booleano es YES
      if (value != nil && [value isKindOfClass:[NSNumber class]]) {
        BOOL bResult = [value boolValue];
        hb_retl(bResult);
        return;
      }
    }
  }

  // Si falla o no existe, devolvemos NO (o false)
  hb_retl(NO);
}

//----------------------------------------------------------------------//

HB_FUNC(SETPLISTPATHVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);
  id value = nil;

  // Determinamos el tipo de valor (Automático)
  if (HB_ISLOG(3)) {
    value = [NSNumber numberWithBool:hb_parl(3)];
  } else if (HB_ISNUM(3)) {
    value = [NSNumber numberWithDouble:hb_parnd(3)];
  } else {
    value = hb_NSSTRING_par(3);
  }

  if (file != nil && path != nil && value != nil) {
    // Cargamos el diccionario usando métodos de conveniencia (autorelease)
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithContentsOfFile:file];
    if (dict == nil) {
      dict = [NSMutableDictionary dictionary];
    }

    NSArray *components = [path componentsSeparatedByString:@"/"];
    NSMutableDictionary *currentDict = dict;

    // Recorremos la ruta para crear la estructura anidada
    for (NSUInteger i = 0; i < [components count] - 1; i++) {
      NSString *key = [components objectAtIndex:i];
      id nextObj = [currentDict objectForKey:key];
      NSMutableDictionary *nextDict;

      if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
        // Usamos 'dictionary' en lugar de 'alloc/init' para evitar leak
        nextDict = [NSMutableDictionary dictionary];
      } else {
        // 'mutableCopy' CREA un objeto nuevo con retain count +1.
        // En No-ARC DEBEMOS enviarle 'autorelease' para que no fugue memoria.
        nextDict = [[nextObj mutableCopy] autorelease];
      }

      [currentDict setObject:nextDict forKey:key];
      currentDict = nextDict;
    }

    NSString *finalKey = [components lastObject];
    [currentDict setObject:value forKey:finalKey];

    BOOL bAtomic = (hb_pcount() >= 4) ? hb_parl(4) : YES;
    hb_retl([dict writeToFile:file atomically:bAtomic]);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTPATHVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);

  if (file != nil && path != nil) {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      NSArray *components = [path componentsSeparatedByString:@"/"];
      NSDictionary *currentDict = dict;

      // Recorremos la ruta para llegar al valor
      for (NSUInteger i = 0; i < [components count] - 1; i++) {
        NSString *key = [components objectAtIndex:i];
        id nextObj = [currentDict objectForKey:key];

        if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
          hb_retnll(0); // No es un diccionario, ruta inválida
          return;
        }
        currentDict = nextObj;
      }

      NSString *finalKey = [components lastObject];
      id value = [currentDict objectForKey:finalKey];

      if (value != nil) {
        // Determinamos el tipo y devolvemos el valor
        if ([value isKindOfClass:[NSNumber class]]) {
          // Verificamos si es booleano o numérico
          CFNumberType numType = CFNumberGetType((CFNumberRef)value);
          if (numType == kCFNumberCharType || numType == kCFNumberSInt8Type ||
              numType == kCFNumberSInt16Type ||
              numType == kCFNumberSInt32Type ||
              numType == kCFNumberSInt64Type) {
            // Es un número entero/booleano
            if ([value boolValue]) {
              hb_retl(YES);
            } else {
              hb_retl(NO);
            }
          } else {
            // Es un número decimal (Double)
            hb_retnd([value doubleValue]);
          }
        } else if ([value isKindOfClass:[NSString class]]) {
          hb_retc([value UTF8String]);
        }
        return;
      }
    }
  }

  // Si falla o no existe, devolvemos 0 o false según el contexto
  // Como no sabemos qué esperaba el usuario, devolvemos 0 (puntero nulo)
  hb_retnll(0);
}

//----------------------------------------------------------------------//

HB_FUNC(SETPLISTPATHARRAY) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);
  // Recuperamos el puntero del NSMutableArray
  NSMutableArray *value = (NSMutableArray *)hb_parnll(3);
  BOOL bAtomic = (hb_pcount() >= 4) ? hb_parl(4) : YES;

  if (file != nil && path != nil && value != nil) {
    // Cargamos el diccionario usando métodos de conveniencia (No-ARC safe)
    NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithContentsOfFile:file];
    if (dict == nil) {
      dict = [NSMutableDictionary dictionary];
    }

    NSArray *components = [path componentsSeparatedByString:@"/"];
    NSMutableDictionary *currentDict = dict;

    // Recorremos la ruta anidada
    for (NSUInteger i = 0; i < [components count] - 1; i++) {
      NSString *key = [components objectAtIndex:i];
      id nextObj = [currentDict objectForKey:key];
      NSMutableDictionary *nextDict;

      if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
        // Cambiamos alloc/init por dictionary (autorelease)
        nextDict = [NSMutableDictionary dictionary];
      } else {
        // mutableCopy REQUIERE autorelease en No-ARC para no fugar memoria
        nextDict = [[nextObj mutableCopy] autorelease];
      }

      [currentDict setObject:nextDict forKey:key];
      currentDict = nextDict;
    }

    // Insertamos el Array en la posición final de la ruta
    NSString *finalKey = [components lastObject];
    [currentDict setObject:value forKey:finalKey];

    // Guardamos y devolvemos éxito/error a Harbour
    hb_retl([dict writeToFile:file atomically:bAtomic]);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTPATHARRAY) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);

  if (file != nil && path != nil) {
    // Cargamos el diccionario principal (autorelease)
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      NSArray *components = [path componentsSeparatedByString:@"/"];
      id currentObj = dict;

      // Navegamos por la ruta (excepto el último elemento)
      for (NSUInteger i = 0; i < [components count] - 1; i++) {
        NSString *key = [components objectAtIndex:i];
        currentObj = [currentObj objectForKey:key];

        // Si en algún punto la ruta no es un diccionario, abortamos
        if (![currentObj isKindOfClass:[NSDictionary class]]) {
          currentObj = nil;
          break;
        }
      }

      if (currentObj != nil) {
        NSString *finalKey = [components lastObject];
        NSArray *finalArray = [currentObj objectForKey:finalKey];

        if (finalArray != nil && [finalArray isKindOfClass:[NSArray class]]) {
          // IMPORTANTE para No-ARC:
          // Creamos una copia persistente con 'alloc' para que el puntero
          // siga vivo cuando Harbour lo necesite usar más tarde.
          NSMutableArray *myArray =
              [[NSMutableArray alloc] initWithArray:finalArray];

          hb_retnll((HB_LONGLONG)myArray);
          return;
        }
      }
    }
  }

  hb_retnll(0); // Si la ruta no existe o no es un Array
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTPATHARRAYCOUNT) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);

  if (file != nil && path != nil) {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      NSArray *components = [path componentsSeparatedByString:@"/"];
      NSDictionary *currentDict = dict;

      // Recorremos la ruta para llegar al array
      for (NSUInteger i = 0; i < [components count] - 1; i++) {
        NSString *key = [components objectAtIndex:i];
        id nextObj = [currentDict objectForKey:key];

        if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
          hb_retnll(0); // No es un diccionario, ruta inválida
          return;
        }
        currentDict = nextObj;
      }

      NSString *finalKey = [components lastObject];
      id value = [currentDict objectForKey:finalKey];

      if (value != nil && [value isKindOfClass:[NSArray class]]) {
        // Devolvemos el tamaño del array
        hb_retnl([value count]);
        return;
      }
    }
  }

  // Si falla o no existe, devolvemos 0
  hb_retnll(0);
}

//----------------------------------------------------------------------//

HB_FUNC(GETPLISTPATHARRAYITEM) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);
  int index = hb_parni(3);

  if (file != nil && path != nil) {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];

    if (dict != nil) {
      NSArray *components = [path componentsSeparatedByString:@"/"];
      NSDictionary *currentDict = dict;

      // Recorremos la ruta para llegar al array
      for (NSUInteger i = 0; i < [components count] - 1; i++) {
        NSString *key = [components objectAtIndex:i];
        id nextObj = [currentDict objectForKey:key];

        if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
          hb_retnll(0); // No es un diccionario, ruta inválida
          return;
        }
        currentDict = nextObj;
      }

      NSString *finalKey = [components lastObject];
      id value = [currentDict objectForKey:finalKey];

      if (value != nil && [value isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)value;
        if (index >= 0 && index < [array count]) {
          id item = [array objectAtIndex:index];

          // Determinamos el tipo y devolvemos el valor
          if ([item isKindOfClass:[NSNumber class]]) {
            CFNumberType numType = CFNumberGetType((CFNumberRef)item);
            if (numType == kCFNumberCharType || numType == kCFNumberSInt8Type ||
                numType == kCFNumberSInt16Type ||
                numType == kCFNumberSInt32Type ||
                numType == kCFNumberSInt64Type) {
              // Es un número entero/booleano
              if ([item boolValue]) {
                hb_retl(YES);
              } else {
                hb_retl(NO);
              }
            } else {
              // Es un número decimal (Double)
              hb_retnd([item doubleValue]);
            }
          } else if ([item isKindOfClass:[NSString class]]) {
            hb_retc([item UTF8String]);
          }
          return;
        }
      }
    }
  }

  // Si falla o no existe, devolvemos 0 o false
  hb_retnll(0);
}
