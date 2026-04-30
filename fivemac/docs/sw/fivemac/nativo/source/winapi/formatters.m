#include "formatters.h"
#include <fivemac.h>

static PHB_SYMB symFMH = NULL;

@implementation FMFormatter

- (NSString *)stringForObjectValue:(id)obj {
  return [obj description];
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  *obj = string;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partial
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)errorString {
  BOOL lResult = YES;

  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMO"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNLL((HB_LONGLONG)[control window]);
  hb_vmPushLong(WM_GETPARTEVALUE);
  hb_vmPushNLL((HB_LONGLONG)control);
  hb_vmPushString([partial cStringUsingEncoding:NSUTF8StringEncoding],
                  [partial length]);

  hb_vmDo(4);

  if (HB_ISCHAR(-1)) {
    *newString = hb_NSSTRING_par(-1);
    lResult = NO;
  } else {
    if (HB_ISLOG(-1)) {
      lResult = hb_parl(-1);
      if (!lResult)
        NSBeep();
    }
  }

  return lResult;
}

@end

@implementation FMUpperFormatter

- (NSString *)stringForObjectValue:(id)obj {
  return [obj description];
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  *obj = string;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partial
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)errorString {
  *newString = [partial uppercaseString];
  return NO;
}

@end

@implementation FMAlphaFormatter

- (NSString *)stringForObjectValue:(id)obj {
  return [obj description];
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  *obj = string;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partial
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)errorString {
  int i;

  for (i = 0; i < [partial length]; i++)
    if (![[NSCharacterSet letterCharacterSet]
            characterIsMember:[partial characterAtIndex:i]])
      return NO;

  return YES;
}

@end

@implementation FMPictureFormatter

- (NSString *)stringForObjectValue:(id)obj {
  return [obj description];
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  *obj = string;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partial
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)errorString {
  int i = 0, j = 0;
  NSMutableString *formatted = [NSMutableString string];

  for (j = 0; j < [picture length] && i < [partial length]; j++) {
    unichar maskChar = [picture characterAtIndex:j];
    unichar inputChar = [partial characterAtIndex:i];

    if (maskChar == '9') {
      if (isdigit(inputChar)) {
        [formatted appendFormat:@"%C", inputChar];
        i++;
      } else {
        // Look ahead for matching literal
        BOOL foundJump = NO;
        int k;
        for (k = j + 1; k < [picture length]; k++) {
          if ([picture characterAtIndex:k] == inputChar) {
            foundJump = YES;
            break;
          }
          if (inputChar == ',' && [picture characterAtIndex:k] == '.') {
            foundJump = YES;
            break;
          }
        }

        if (foundJump) {
          j = k - 1;
          continue;
        }

        return NO;
      }
    } else {
      [formatted appendFormat:@"%C", maskChar];
      if (inputChar == maskChar)
        i++;
    }
  }

  if ([formatted isEqualToString:partial])
    return YES;

  *newString = formatted;
  return NO;
}

@end

@implementation FMEuroNumberFormatter

- (id)init {
  self = [super init];
  if (self) {
    NSLocale *euroLocale =
        [[[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"] autorelease];
    [self setLocale:euroLocale];
    [self setNumberStyle:NSNumberFormatterDecimalStyle];
    maxIntegerDigits = 0;
  }
  return self;
}

- (NSString *)stringForObjectValue:(id)obj {
  return [obj description];
}

- (BOOL)getObjectValue:(id *)obj
             forString:(NSString *)string
      errorDescription:(NSString **)error {
  *obj = string;
  return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partial
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error {
  if ([partial length] == 0)
    return YES;

  NSMutableString *s = [[partial mutableCopy] autorelease];
  BOOL changed = NO;

  if ([self usesGroupingSeparator]) {
    if ([s hasSuffix:@"."]) {
      [s replaceCharactersInRange:NSMakeRange([s length] - 1, 1)
                       withString:@","];
      changed = YES;
    }
    if ([s rangeOfString:@".."].location != NSNotFound) {
      [s replaceOccurrencesOfString:@".."
                         withString:@","
                            options:0
                              range:NSMakeRange(0, [s length])];
      changed = YES;
    }
    if ([s rangeOfString:@"."].location != NSNotFound) {
      [s replaceOccurrencesOfString:@"."
                         withString:@""
                            options:0
                              range:NSMakeRange(0, [s length])];
    }
  } else {
    if ([s rangeOfString:@"."].location != NSNotFound) {
      [s replaceOccurrencesOfString:@"."
                         withString:@","
                            options:0
                              range:NSMakeRange(0, [s length])];
      changed = YES;
    }
  }

  NSUInteger commaCount = [[s componentsSeparatedByString:@","] count] - 1;
  if (commaCount > 1)
    return NO;

  NSArray *parts = [s componentsSeparatedByString:@","];

  if (maxIntegerDigits > 0) {
    NSString *integerPart = [parts objectAtIndex:0];
    NSCharacterSet *notDigits =
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *digits =
        [[integerPart componentsSeparatedByCharactersInSet:notDigits]
            componentsJoinedByString:@""];

    if ([digits length] > maxIntegerDigits) {
      if ([parts count] == 1) {
        NSString *validInt = [digits substringToIndex:maxIntegerDigits];
        NSString *excess = [digits substringFromIndex:maxIntegerDigits];

        if ([self maximumFractionDigits] == 0)
          return NO;

        [s setString:[NSString stringWithFormat:@"%@,%@", validInt, excess]];
        changed = YES;
      } else {
        return NO;
      }
    }
  }

  if (changed)
    parts = [s componentsSeparatedByString:@","];

  if ([parts count] > 1) {
    NSString *fractionPart = [parts objectAtIndex:1];
    if ([fractionPart length] > [self maximumFractionDigits]) {
      return NO;
    }
  }

  if ([self usesGroupingSeparator]) {
    NSString *integerPart = [parts objectAtIndex:0];
    NSCharacterSet *notDigits =
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *digits =
        [[integerPart componentsSeparatedByCharactersInSet:notDigits]
            componentsJoinedByString:@""];
    NSString *fractionPart =
        ([parts count] > 1) ? [parts objectAtIndex:1] : nil;

    NSMutableString *fInt = [NSMutableString string];
    int count = 0;
    for (int i = [digits length] - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0)
        [fInt insertString:@"." atIndex:0];

      [fInt insertString:[digits substringWithRange:NSMakeRange(i, 1)]
                 atIndex:0];
      count++;
    }
    integerPart = fInt;

    NSString *newS =
        fractionPart
            ? [NSString stringWithFormat:@"%@,%@", integerPart, fractionPart]
            : integerPart;

    if (![newS isEqualToString:s]) {
      [s setString:newS];
      changed = YES;
    }
  }

  if (changed) {
    *newString = [NSString stringWithString:s];
    return NO;
  }

  return YES;
}

@end

@implementation FMEuroDateFormatter

- (id)init {
  self = [super init];
  if (self) {
    [self setDateFormat:@"dd/MM/yyyy"];
  }
  return self;
}

@end

@implementation FMDateFormatter
@end

HB_FUNC(FORMATTERCREATE) {
  NSFormatter *formatter = [[[NSFormatter alloc] init] autorelease];
  hb_retnll((HB_LONGLONG)formatter);
}

HB_FUNC(FORMATTERDATECREATE) {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  hb_retnll((HB_LONGLONG)formatter);
}

HB_FUNC(FORMATTERNUMBERCREATE) {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  hb_retnll((HB_LONGLONG)formatter);
}

HB_FUNC(FORMATTERSETDATESHORT) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setDateStyle:NSDateFormatterShortStyle];
}

HB_FUNC(FORMATTERSETDATEMEDIUM) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setDateStyle:NSDateFormatterMediumStyle];
}

HB_FUNC(FORMATTERSETTIMESHORT) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setTimeStyle:NSDateFormatterShortStyle];
}

HB_FUNC(FORMATTERSETTIMEMEDIUM) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setTimeStyle:NSDateFormatterMediumStyle];
}

HB_FUNC(FORMATTERNUMERICSETLOCALE) {
  NSNumberFormatter *formatter = (NSNumberFormatter *)hb_parnll(1);
  NSLocale *locale = (NSLocale *)hb_parnll(2);
  [formatter setLocale:locale];
}

HB_FUNC(FORMATTERSETNUMERIC) {
  NSNumberFormatter *formatter = (NSNumberFormatter *)hb_parnll(1);
  [formatter setNumberStyle:NSNumberFormatterNoStyle];
}

HB_FUNC(FORMATTERSETCURRENCY) {
  NSNumberFormatter *formatter = (NSNumberFormatter *)hb_parnll(1);
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALECREATEFROMID) // ojo tiene retain que se debe liberar
{
  NSString *string = hb_NSSTRING_par(1);

  if (string != nil) {
    // En No-ARC, este método devuelve un objeto autoreleased
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:string];

    if (locale != nil) {
      // INCREMENTAMOS el contador para que viva en la memoria de Harbour
      [locale retain];
      hb_retnll((HB_LONGLONG)locale);
    } else {
      hb_retnll(0);
    }
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(LOCALECURRENT) // ojo tiene retain que se debe liberar
{
  // Obtenemos el locale (objeto autorelease)
  NSLocale *locale = [NSLocale currentLocale];

  if (locale != nil) {
    // IMPORTANTE en No ARC: Incrementamos el contador de referencias
    // para que no desaparezca al salir de esta función.
    [locale retain];

    hb_retnll((HB_LONGLONG)locale);
  } else {
    hb_retnll(0);
  }
}

HB_FUNC(LOCALE_RELEASE) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  if (locale != nil) {
    [locale release]; // Liberamos la memoria manualmente
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALEGETNAME) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  NSArray *languages = [NSLocale preferredLanguages];

  // Verificamos que el objeto locale y el array de idiomas existan
  if (locale != nil && languages != nil && [languages count] > 0) {

    // objectAtIndex devuelve un objeto autorelease (no requiere release)
    NSString *language = [languages objectAtIndex:0];

    // displayNameForKey también devuelve un objeto autorelease
    NSString *displayNameString = [locale displayNameForKey:NSLocaleIdentifier
                                                      value:language];

    if (displayNameString != nil) {
      hb_retc([displayNameString UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALE_GETLANGUAGE) {
  // Cast directo del puntero de Harbour
  NSLocale *locale = (NSLocale *)hb_parnll(1);

  if (locale != nil) {
    // En No ARC, estas propiedades devuelven objetos autorelease
    NSString *code = [locale languageCode];
    NSString *language = [locale localizedStringForLanguageCode:code];

    if (language != nil) {
      hb_retc([language UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALE_SETLANGUAGE) {
  // Obtenemos el string desde Harbour (asumiendo que hb_NSSTRING_par maneja el
  // autorelease)
  NSString *lang = hb_NSSTRING_par(1);

  if (lang != nil) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Creamos el array literal. En No-ARC, esto es un objeto autorelease.
    NSArray *langArray = [NSArray arrayWithObject:lang];

    [defaults setObject:langArray forKey:@"AppleLanguages"];
    [defaults synchronize];
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALEGETPREFID) {
  // preferredLanguages devuelve un NSArray "autoreleased"
  NSArray *languages = [NSLocale preferredLanguages];

  if (languages != nil && [languages count] > 0) {
    // objectAtIndex devuelve el objeto sin traspasar la propiedad (no requiere
    // release)
    NSString *language = [languages objectAtIndex:0];
    hb_retc([language UTF8String]);
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALE_SETCOUNTRY) {
  // Obtenemos el código de país desde Harbour (ej: "MX", "ES", "US")
  NSString *countryCode = hb_NSSTRING_par(1);

  if (countryCode != nil) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // En No-ARC, 'setObject' no requiere retain manual del objeto pasado
    // porque NSUserDefaults se encarga de su propia gestión interna.
    [defaults setObject:countryCode forKey:@"AppleLocale"];

    // Sincronizamos para asegurar que el cambio persista
    [defaults synchronize];
  }
}

HB_FUNC(LOCALE_GETCOUNTRY) {
  // Recuperamos el objeto locale desde el puntero de Harbour
  NSLocale *locale = (NSLocale *)hb_parnll(1);

  if (locale != nil) {
    // En No-ARC, countryCode es un objeto autorelease
    // Nota: En versiones antiguas de iOS/macOS se usa:
    // [locale objectForKey:NSLocaleCountryCode]
    NSString *country = [locale countryCode];

    if (country != nil) {
      hb_retc([country UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALEGETMESURESYSTEM) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  if (locale != nil) {
    // 'string' es un objeto autorelease; no requiere [release]
    NSString *string = [locale objectForKey:NSLocaleMeasurementSystem];

    if (string != nil) {
      hb_retc([string UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALE_MESUREISMETRIC) {
  // Realizamos un cast simple sin bridge de ARC
  NSLocale *locale = (NSLocale *)hb_parnll(1);

  if (locale != nil) {
    // En Objective-C tradicional, objectForKey devuelve un objeto autorelease
    // No necesitamos hacer release manual de 'isMetricNumber'
    NSNumber *isMetricNumber = [locale objectForKey:NSLocaleUsesMetricSystem];
    BOOL isMetric = [isMetricNumber boolValue];

    hb_retl(isMetric);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LOCALE_GETCURRENCYSYMBOL) {
  // Recuperamos el objeto locale desde el puntero (long long)
  NSLocale *locale = (NSLocale *)hb_parnll(1);

  if (locale != nil) {
    // En No-ARC, el objeto devuelto es 'autorelease'
    NSString *symbol = [locale objectForKey:NSLocaleCurrencySymbol];

    if (symbol != nil) {
      hb_retc([symbol UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}
