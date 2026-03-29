#include <fivemac.h>

HB_FUNC(ARRAYCREATEEMPTY) {
  // Creamos el array con un contador de referencia de 1.
  // Este objeto PERMANECERÁ en memoria hasta que llamemos a [release].
  NSMutableArray *myarray = [[NSMutableArray alloc] init];

  if (myarray != nil) {
    hb_retnll((HB_LONGLONG)myarray);
  } else {
    hb_retnll(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYADDSTRING) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);

  // Verificamos que el array exista antes de intentar usarlo
  if (myarray != nil) {
    NSString *string = hb_NSSTRING_par(2);

    // Cocoa no permite añadir 'nil' a un NSMutableArray (daría crash)
    if (string != nil) {
      [myarray addObject:string];
    } else {
      // Opcional: añadir un string vacío si el parámetro de Harbour es NIL
      [myarray addObject:@""];
    }
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYADDOBJ) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  NSObject *object = (NSObject *)hb_parnll(2);

  // Validación crítica: Cocoa daría un crash si myarray o object son nulos
  if (myarray != nil && object != nil) {
    [myarray addObject:object];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(STRINGARRAYTONSARRAY) {
  // Creamos el array persistente (sin autorelease) para que viva en Harbour
  NSMutableArray *myarray = [[NSMutableArray alloc] init];

  if (myarray != nil) {
    // Obtenemos el número de elementos del array de Harbour
    int n = hb_parinfa(1, 0);
    int i;

    for (i = 1; i <= n; i++) { // En Harbour los arrays empiezan en 1
      const char *cText = hb_parvc(1, i);

      if (cText != NULL) {
        // Creamos el NSString.
        // Usamos 'stringWithUTF8String' porque devuelve un objeto
        // autorelease (seguro en No-ARC dentro de este bucle).
        NSString *string = [NSString stringWithUTF8String:cText];

        if (string != nil) {
          [myarray addObject:string];
        }
      }
    }

    // Devolvemos el puntero persistente a Harbour
    hb_retnll((HB_LONGLONG)myarray);
  } else {
    hb_retnll(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYDELALL) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);

  if (myarray != nil) {
    [myarray removeAllObjects];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYADEL) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  // Recibimos el índice de Harbour (1-based)
  int nHbIndex = hb_parni(2);

  if (myarray != nil && nHbIndex > 0) {
    // Convertimos a índice C (0-based)
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);

    // Verificamos que el índice no esté fuera de rango para evitar CRASH
    if (nIndex < [myarray count]) {
      [myarray removeObjectAtIndex:nIndex];
      hb_retl(YES);
    } else {
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYCREATELEN) {
  // Si no pasan parámetro, capacity será 0
  NSUInteger capacity = (NSUInteger)hb_parni(1);

  // Creamos el objeto persistente (Retain Count = 1)
  NSMutableArray *myarray = [[NSMutableArray alloc] initWithCapacity:capacity];

  if (myarray != nil) {
    hb_retnll((HB_LONGLONG)myarray);
  } else {
    hb_retnll(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYADDSTRINGINDEX) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);
  // Harbour usa base 1, Objective-C usa base 0
  int nHbIndex = hb_parni(3);

  if (myarray != nil && string != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);
    NSUInteger nCount = [myarray count];

    // En insertObject:atIndex:, el índice máximo permitido es [myarray count]
    // (que equivale a añadir al final).
    if (nIndex <= nCount) {
      [myarray insertObject:string atIndex:nIndex];
      hb_retl(YES);
    } else {
      // Si el índice es demasiado grande, lo añadimos al final por seguridad
      [myarray addObject:string];
      hb_retl(YES);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYADDOBJINDEX) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  NSObject *object = (NSObject *)hb_parnll(2);
  // Harbour usa base 1, Objective-C usa base 0
  int nHbIndex = hb_parni(3);

  if (myarray != nil && object != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);
    NSUInteger nCount = [myarray count];

    // En insertObject:atIndex:, el índice máximo permitido es [myarray count]
    if (nIndex <= nCount) {
      [myarray insertObject:object atIndex:nIndex];
      hb_retl(YES);
    } else {
      // Si el índice es demasiado grande, lo añadimos al final
      [myarray addObject:object];
      hb_retl(YES);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYLEN) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);

  if (myarray != nil) {
    // Devolvemos la longitud como un entero de Harbour
    hb_retni((int)[myarray count]);
  } else {
    hb_retni(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYGETOBJINDEX) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  int nHbIndex = hb_parni(2); // Índice base 1 desde Harbour

  if (myarray != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1); // Convertimos a base 0

    // Validación crítica de rango para evitar Crash
    if (nIndex < [myarray count]) {
      NSObject *object = [myarray objectAtIndex:nIndex];

      if (object != nil) {
        hb_retnll((HB_LONGLONG)object);
        return;
      }
    }
  }

  hb_retnll(0); // Devolvemos puntero nulo si falla
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYGETSTRINGINDEX) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  int nHbIndex = hb_parni(2);

  if (myarray != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);

    if (nIndex < [myarray count]) {
      id object = [myarray objectAtIndex:nIndex];

      if (object != nil) {
        // Si es un String, lo devolvemos directamente
        if ([object isKindOfClass:[NSString class]]) {
          hb_retc([object UTF8String]);
          return;
        } else {
          // Si es un número o booleano, 'description' lo hace string por
          // nosotros
          hb_retc([[object description] UTF8String]);
          return;
        }
      }
    }
  }

  hb_retc("");
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYSETOBJINDEX) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  int nHbIndex = hb_parni(2); // Índice base 1 desde Harbour
  NSObject *object = (NSObject *)hb_parnll(3);

  if (myarray != nil && object != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1); // Convertimos a base 0

    // Validación de rango: El índice debe existir previamente para poder
    // reemplazar
    if (nIndex < [myarray count]) {
      [myarray replaceObjectAtIndex:nIndex withObject:object];
      hb_retl(YES);
    } else {
      // Si el índice no existe, no podemos reemplazar. Devolvemos error.
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYRELEASE) {
  // Recuperamos el puntero que tiene Harbour
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);

  if (myarray != nil) {
    // Enviamos el mensaje de release para decrementar el contador
    // y que Cocoa destruya el objeto si llega a cero.
    [myarray release];

    // Opcional: devolvemos .T. para confirmar que se liberó
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYADDITEM) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  id value;

  if (HB_ISLOG(2))
    value = [NSNumber numberWithBool:hb_parl(2)];
  else if (HB_ISNUM(2))
    value = [NSNumber numberWithDouble:hb_parnd(2)];
  else
    value = hb_NSSTRING_par(2);

  [myarray addObject:value];
}

//----------------------------------------------------------------------//

HB_FUNC(ARRAYSETSTRINGINDEX) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  int nHbIndex = hb_parni(2); // Índice base 1 desde Harbour
  NSString *string = hb_NSSTRING_par(3);

  if (myarray != nil && string != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1); // Convertimos a base 0

    // Validación de rango: El índice debe existir previamente para poder
    // reemplazar
    if (nIndex < [myarray count]) {
      [myarray replaceObjectAtIndex:nIndex withObject:string];
      hb_retl(YES);
    } else {
      // Si el índice no existe, no podemos reemplazar. Devolvemos error.
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

// Alias para Harbour TARRAY_SET con detección automática de tipos
HB_FUNC(TARRAY_SET) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  int nHbIndex = hb_parni(2);
  id value;

  if (myarray != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);

    if (nIndex < [myarray count]) {
      if (HB_ISLOG(3))
        value = [NSNumber numberWithBool:hb_parl(3)];
      else if (HB_ISNUM(3))
        value = [NSNumber numberWithDouble:hb_parnd(3)];
      else if (HB_ISCHAR(3))
        value = hb_NSSTRING_par(3);
      else
        value = (id)hb_parnll(3);

      if (value != nil) {
        [myarray replaceObjectAtIndex:nIndex withObject:value];
        hb_retl(YES);
      }
    }
  }
  hb_retl(NO);
}

HB_FUNC(TARRAY_DEL) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  int nHbIndex = hb_parni(2);

  if (myarray != nil && nHbIndex > 0) {
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);
    if (nIndex < [myarray count]) {
      [myarray removeObjectAtIndex:nIndex];
      hb_retl(YES);
    }
  }
  hb_retl(NO);
}

HB_FUNC(TARRAY_DELALL) {
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(1);
  if (myarray != nil) {
    [myarray removeAllObjects];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTCREATEEMPTY) {
  // Usamos alloc/init para que el objeto TENGA un retain count de 1.
  // Esto garantiza que el objeto NO desaparezca hasta que nosotros lo
  // liberemos.
  NSMutableDictionary *mydict = [[NSMutableDictionary alloc] init];

  if (mydict != nil) {
    hb_retnll((HB_LONGLONG)mydict);
  } else {
    hb_retnll(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTCREATELEN) {
  NSUInteger capacity = (NSUInteger)hb_parni(1);

  // Usamos alloc/init para que el objeto tenga un Retain Count de 1.
  // Esto garantiza que el diccionario PERMANEZCA en memoria hasta que
  // decidamos liberarlo desde Harbour con ARRAYRELEASE o NSRELEASE.
  NSMutableDictionary *mydict =
      [[NSMutableDictionary alloc] initWithCapacity:capacity];

  if (mydict != nil) {
    hb_retnll((HB_LONGLONG)mydict);
  } else {
    hb_retnll(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTADDITEM) {
  NSMutableDictionary *mydict = (NSMutableDictionary *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  id value;

  if (HB_ISLOG(3))
    value = [NSNumber numberWithBool:hb_parl(3)];
  else if (HB_ISNUM(3))
    value = [NSNumber numberWithDouble:hb_parnd(3)];
  else
    value = hb_NSSTRING_par(3);

  [mydict setObject:value forKey:key];
}

//----------------------------------------------------------------------//

HB_FUNC(DICTSETVALUE) {
  NSMutableDictionary *dict = (NSMutableDictionary *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  id value = nil;

  // Detección automática de tipos de Harbour para el valor (parámetro 3)
  if (HB_ISLOG(3)) {
    value = [NSNumber numberWithBool:hb_parl(3)];
  } else if (HB_ISNUM(3)) {
    value = [NSNumber numberWithDouble:hb_parnd(3)];
  } else if (HB_ISCHAR(3)) {
    value = hb_NSSTRING_par(3);
  } else if (HB_ISNUM(3) || HB_ISPOINTER(3)) {
    // Si pasas un puntero (como otro Array o Diccionario)
    value = (id)hb_parnll(3);
  }

  // Validación crítica para No-ARC: Cocoa hace Crash si insertas nil
  if (dict != nil && key != nil && value != nil) {
    [dict setObject:value forKey:key];
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTGETVALUE) {
  NSDictionary *dict = (NSDictionary *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);

  if (dict != nil && key != nil) {
    id value = [dict objectForKey:key];

    if (value != nil) {
      // 1. Strings
      if ([value isKindOfClass:[NSString class]]) {
        hb_retc([value UTF8String]);
        return;
      }
      // 2. Números y Lógicos (Detección por tipo de C)
      else if ([value isKindOfClass:[NSNumber class]]) {
        const char *type = [value objCType];
        // 'c' = char/BOOL, 'i' = int, 'B' = bool (64bit)
        if (strcmp(type, "c") == 0 || strcmp(type, "i") == 0 ||
            strcmp(type, "B") == 0) {
          hb_retni((int)[value integerValue]);
        } else {
          hb_retnd([value doubleValue]);
        }
        return;
      }
      // 3. Objetos complejos (Arrays/Dicts) -> Devolvemos Puntero
      else {
        hb_retnll((HB_LONGLONG)value);
        return;
      }
    }
  }
  hb_retnll(0);
}

//----------------------------------------------------------------------//

HB_FUNC(DICTKEYS) {
  NSDictionary *dict = (NSDictionary *)hb_parnll(1);

  if (dict != nil) {
    // allKeys devuelve un NSArray con todas las llaves (en autorelease)
    NSArray *keys = [dict allKeys];
    PHB_ITEM pArray = hb_itemNew(NULL);
    NSUInteger nCount = [keys count];

    // Creamos un array de Harbour del tamaño necesario
    hb_arrayNew(pArray, (HB_SIZE)nCount);

    for (NSUInteger i = 0; i < nCount; i++) {
      id key = [keys objectAtIndex:i];

      // Convertimos la llave a String de Harbour (normalmente son NSString)
      if ([key isKindOfClass:[NSString class]]) {
        PHB_ITEM pItem = hb_itemPutC(NULL, [key UTF8String]);
        hb_arraySet(pArray, (HB_SIZE)(i + 1), pItem);
        hb_itemRelease(pItem);
      }
    }

    // Devolvemos el array nativo a Harbour y liberamos el contenedor temporal
    hb_itemReturn(pArray);
    hb_itemRelease(pArray);
  } else {
    // Si el diccionario es nulo, devolvemos un array vacío {}
    hb_reta(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTRELEASE) {
  // Recuperamos el puntero que tiene Harbour
  NSDictionary *mydict = (NSDictionary *)hb_parnll(1);

  if (mydict != nil) {
    // Enviamos el mensaje de release para decrementar el contador
    // y que Cocoa destruya el objeto si llega a cero.
    [mydict release];

    // Opcional: devolvemos .T. para confirmar que se liberó
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTCOUNT) {
  NSDictionary *dict = (NSDictionary *)hb_parnll(1);

  if (dict != nil) {
    hb_retni((int)[dict count]);
  } else {
    hb_retni(0);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTREMOVEKEY) {
  NSMutableDictionary *dict = (NSMutableDictionary *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);

  if (dict != nil && key != nil) {
    [dict removeObjectForKey:key];
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------//

HB_FUNC(DICTIONARYWITHCONTENTSOFFILE) {
  NSString *file = hb_NSSTRING_par(1);

  if (file != nil) {
    // Usamos alloc/initWithContentsOfFile para que el objeto sea PERSISTENTE.
    // En No-ARC, esto le da un Retain Count de 1.
    // El objeto NO morirá hasta que llames a DICTRELEASE desde Harbour.
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:file];

    if (dict != nil) {
      hb_retnll((HB_LONGLONG)dict);
      return;
    }
  }

  hb_retnll(0); // Si el archivo no existe o no es un Plist válido
}

//----------------------------------------------------------------------//

HB_FUNC(DICTGETKEY) {
  NSDictionary *dict = (NSDictionary *)hb_parnll(1);
  int nHbIndex = hb_parni(2); // Índice base 1 desde Harbour

  if (dict != nil && nHbIndex > 0) {
    // Obtenemos todas las llaves (en autorelease, seguro en No-ARC)
    NSArray *keys = [dict allKeys];
    NSUInteger nIndex = (NSUInteger)(nHbIndex - 1);

    if (nIndex < [keys count]) {
      NSString *key = [keys objectAtIndex:nIndex];
      // Devolvemos la cadena a Harbour usando tu función probada
      hb_retstr_NS(key);
      return;
    }
  }

  hb_retc(""); // Si falla o no existe el índice
}

//----------------------------------------------------------------------//

//----------------------------------------------------------------------------//

HB_FUNC(ISDICT) {
  id obj = (id)hb_parnll(1);
  hb_retl([obj isKindOfClass:[NSDictionary class]]);
}

//----------------------------------------------------------------------------//

HB_FUNC(ISARRAY) {
  id obj = (id)hb_parnll(1);
  hb_retl([obj isKindOfClass:[NSArray class]]);
}

//----------------------------------------------------------------------------//

static id HB_ITEM_TO_NSOBJECT(PHB_ITEM pItem) {
  id value = nil;
  HB_TYPE type = hb_itemType(pItem);

  if (type & HB_IT_HASH) {
    // Llamamos a tu función de Hash (devuelve NSDictionary)
    value = (id)hb_itemDoC("HASH_TO_DICT", 1, pItem);
    [value autorelease]; // El contenedor padre será el dueño
  } else if (type & HB_IT_ARRAY) {
    // Llamamos a tu función de Array (devuelve NSArray)
    value = (id)hb_itemDoC("ARRAY_TO_NSARRAY", 1, pItem);
    [value autorelease];
  } else if (type & HB_IT_LOGICAL) {
    value = [NSNumber numberWithBool:hb_itemGetL(pItem)];
  } else if (type & HB_IT_NUMERIC) {
    value = [NSNumber numberWithDouble:hb_itemGetND(pItem)];
  } else if (type & HB_IT_STRING) {
    value = [NSString stringWithUTF8String:hb_itemGetC(pItem)];
  }

  return value;
}

// Convierte un Hash de Harbour {=>} en un NSDictionary de Cocoa
HB_FUNC(HASH_TO_DICT) {
  PHB_ITEM pHash = hb_param(1, HB_IT_HASH);

  if (pHash) {
    // Creamos con 'alloc' para que sea persistente (Retain Count = 1)
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    HB_SIZE nLen = hb_hashLen(pHash);
    HB_SIZE i;

    for (i = 1; i <= nLen; i++) {
      PHB_ITEM pKey = hb_hashGetKeyAt(pHash, i);
      PHB_ITEM pVal = hb_hashGetValueAt(pHash, i);

      if (pKey && pVal) {
        NSString *key = [NSString stringWithUTF8String:hb_itemGetC(pKey)];
        id value = HB_ITEM_TO_NSOBJECT(pVal); // <--- Uso del Helper

        if (key && value) {
          [dict setObject:value forKey:key];
        }
      }
    }
    // Devolvemos el puntero persistente a Harbour
    hb_retnll((HB_LONGLONG)dict);
  } else {
    hb_retnll(0);
  }
}

// Convierte un Array de Harbour {} en un NSArray de Cocoa
HB_FUNC(ARRAY_TO_NSARRAY) {
  PHB_ITEM pArray = hb_param(1, HB_IT_ARRAY);

  if (pArray) {
    HB_SIZE nLen = hb_arrayLen(pArray);
    // Creamos con 'alloc' para que sea persistente (Retain Count = 1)
    NSMutableArray *nsArray = [[NSMutableArray alloc] initWithCapacity:nLen];
    HB_SIZE i;

    for (i = 1; i <= nLen; i++) {
      PHB_ITEM pVal = hb_arrayGetItemPtr(pArray, i);
      id value = HB_ITEM_TO_NSOBJECT(pVal); // <--- Uso del Helper

      if (value) {
        [nsArray addObject:value];
      }
    }
    // Devolvemos el puntero persistente a Harbour
    hb_retnll((HB_LONGLONG)nsArray);
  } else {
    hb_retnll(0);
  }
}
