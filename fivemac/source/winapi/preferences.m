#include <fivemac.h>

HB_FUNC(CREATEPREFERENCES) {
  NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];

  hb_retnll((HB_LONGLONG)preferences);
}

HB_FUNC(SETSTRINGPREFERENCE) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  NSString *cValor = hb_NSSTRING_par(3);

  [preferences setObject:cValor forKey:key];
}

HB_FUNC(GETSTRINGPREFERENCE) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSString *key = hb_NSSTRING_par(2);
  NSString *cValue = [preferences objectForKey:key];

  hb_retc([cValue cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(SETDEFAULTPREFERENCE) {
  NSUserDefaults *preferences = (NSUserDefaults *)hb_parnll(1);
  NSDictionary *preferencesByDefault = [NSDictionary
      dictionaryWithObjectsAndKeys:@"Nombreprog", @"sciedit", @"pathfivemac",
                                   @"~/fivemac", @"pathharbour", @"~/harbour",
                                   nil];

  if ([preferences stringForKey:@"Nombreprog"] == nil)
    [preferences registerDefaults:preferencesByDefault];
}

HB_FUNC(GETPLISTVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);

  // Iniciamos diccionario
  NSMutableDictionary *dict =
      [[NSMutableDictionary alloc] initWithContentsOfFile:file];

  // Asignamos un valor a un string, por ejemplo
  NSString *cValue = [dict objectForKey:key];

  hb_retc([cValue cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(SETPLISTVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  NSString *cValue = hb_NSSTRING_par(3);
  NSFileManager *filemgr = [NSFileManager defaultManager];
  NSMutableDictionary *dict;

  if ([filemgr fileExistsAtPath:file])
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
  else
    dict = [[NSMutableDictionary alloc] init];

  [dict setValue:cValue forKey:key];
  [dict writeToFile:file atomically:hb_parl(4)];
}

HB_FUNC(SETPLISTARRAYVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  NSFileManager *filemgr = [NSFileManager defaultManager];
  NSMutableDictionary *dict;
  NSMutableArray *myarray = (NSMutableArray *)hb_parnll(3);

  if ([filemgr fileExistsAtPath:file])
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
  else
    dict = [[NSMutableDictionary alloc] init];

  [dict setValue:myarray forKey:key];

  [dict writeToFile:file atomically:hb_parl(4)];
}

HB_FUNC(GETPLISTARRAYVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  NSMutableDictionary *dict =
      [[NSMutableDictionary alloc] initWithContentsOfFile:file];

  hb_retnll(
      (HB_LONGLONG)[NSMutableArray arrayWithArray:[dict objectForKey:key]]);
}

HB_FUNC(ISKEYPLIST) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  NSMutableDictionary *dict =
      [[NSMutableDictionary alloc] initWithContentsOfFile:file];

  hb_retl((HB_LONG)[dict objectForKey:key]);
}

HB_FUNC(SETPLISTBOOLEAN) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *key = hb_NSSTRING_par(2);
  BOOL value = hb_parl(3);
  NSFileManager *filemgr = [NSFileManager defaultManager];
  NSMutableDictionary *dict;

  if ([filemgr fileExistsAtPath:file])
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
  else
    dict = [[NSMutableDictionary alloc] init];

  [dict setValue:[NSNumber numberWithBool:value] forKey:key];
  [dict writeToFile:file atomically:hb_parl(4)];
}

HB_FUNC(SETPLISTPATHVALUE) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);
  id value;

  if (HB_ISLOG(3))
    value = [NSNumber numberWithBool:hb_parl(3)];
  else if (HB_ISNUM(3))
    value = [NSNumber numberWithDouble:hb_parnd(3)];
  else
    value = hb_NSSTRING_par(3);

  NSFileManager *filemgr = [NSFileManager defaultManager];
  NSMutableDictionary *dict;

  if ([filemgr fileExistsAtPath:file])
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
  else
    dict = [[NSMutableDictionary alloc] init];

  NSArray *components = [path componentsSeparatedByString:@"/"];
  NSMutableDictionary *currentDict = dict;

  for (NSUInteger i = 0; i < [components count] - 1; i++) {
    NSString *key = [components objectAtIndex:i];
    id nextObj = [currentDict objectForKey:key];
    NSMutableDictionary *nextDict;

    if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
      nextDict = [[NSMutableDictionary alloc] init];
    } else {
      nextDict = [nextObj mutableCopy];
    }

    [currentDict setObject:nextDict forKey:key];
    currentDict = nextDict;
  }

  NSString *finalKey = [components lastObject];
  [currentDict setObject:value forKey:finalKey];

  [dict writeToFile:file atomically:hb_parl(4)];
}

HB_FUNC(SETPLISTPATHARRAY) {
  NSString *file = hb_NSSTRING_par(1);
  NSString *path = hb_NSSTRING_par(2);
  NSMutableArray *value = (NSMutableArray *)hb_parnll(3); // Expecting Handle

  NSFileManager *filemgr = [NSFileManager defaultManager];
  NSMutableDictionary *dict;

  if ([filemgr fileExistsAtPath:file])
    dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
  else
    dict = [[NSMutableDictionary alloc] init];

  NSArray *components = [path componentsSeparatedByString:@"/"];
  NSMutableDictionary *currentDict = dict;

  for (NSUInteger i = 0; i < [components count] - 1; i++) {
    NSString *key = [components objectAtIndex:i];
    id nextObj = [currentDict objectForKey:key];
    NSMutableDictionary *nextDict;

    if (nextObj == nil || ![nextObj isKindOfClass:[NSDictionary class]]) {
      nextDict = [[NSMutableDictionary alloc] init];
    } else {
      nextDict = [nextObj mutableCopy];
    }

    [currentDict setObject:nextDict forKey:key];
    currentDict = nextDict;
  }

  NSString *finalKey = [components lastObject];
  [currentDict setObject:value forKey:finalKey];

  [dict writeToFile:file atomically:hb_parl(4)];
}
