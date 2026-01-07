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
