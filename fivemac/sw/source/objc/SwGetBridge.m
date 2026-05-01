#import <AppKit/AppKit.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbvm.h>

// --- Funciones de Ayuda (Bridge) ---

NSString * hb_NSSTRING_par( int iParam ) {
  if( !HB_ISCHAR( iParam ) ) return @"";
  const char * szText = hb_parc( iParam );
  if( szText == NULL ) return @"";
  NSString * nsText = [ NSString stringWithUTF8String: szText ];
  if( nsText == nil ) {
    nsText = [ NSString stringWithCString: szText encoding: NSISOLatin1StringEncoding ];
  }
  return ( nsText != nil ) ? nsText : @"";
}

const char * ValToChar( PHB_ITEM item ) {
  static char szBuffer[ 1024 ];
  szBuffer[ 0 ] = '\0';
  if( item ) {
    PHB_ITEM pRes = hb_itemDoC( "CVALTOCHAR", 1, item );
    if( pRes ) {
      const char * szText = hb_itemGetCPtr( pRes );
      if( szText ) {
        strncpy( szBuffer, szText, 1023 );
        szBuffer[ 1023 ] = '\0';
      }
      hb_itemRelease( pRes );
    }
  }
  return szBuffer;
}

// --- Interfaces de Formateadores ---

@interface FMPictureFormatter : NSFormatter {
   @public NSString * picture;
}
@end

@interface FMEuroNumberFormatter : NSNumberFormatter {
   @public int maxIntegerDigits;
}
@end

@interface FMUpperFormatter : NSFormatter
@end

@interface FMAlphaFormatter : NSFormatter
@end

@interface FMEuroDateFormatter : NSDateFormatter
@end

// MARK: - SwGet Native Bridge
// Estas funciones permiten a Swift configurar los PICTURES nativos 
// sin tener que conocer las clases de Objective-C en tiempo de compilación.

void SwGet_SetPicture(NSTextField *control, const char *cPicture) {
    if (!control || !cPicture) return;
    
    NSString *picture = [NSString stringWithUTF8String:cPicture];
    FMPictureFormatter *formatter = [[[FMPictureFormatter alloc] init] autorelease];
    formatter->picture = [picture retain];
    [[control cell] setFormatter:formatter];
}

void SwGet_SetEuroNumber(NSTextField *control, const char *cPicture) {
    if (!control || !cPicture) return;
    
    NSString *picture = [NSString stringWithUTF8String:cPicture];
    FMEuroNumberFormatter *formatter = [[[FMEuroNumberFormatter alloc] init] autorelease];
    
    NSRange dotRange = [picture rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
        int decimals = (int)([picture length] - dotRange.location - 1);
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:decimals];
        
        NSString *intPart = [picture substringToIndex:dotRange.location];
        int nineCount = 0;
        for (int i = 0; i < [intPart length]; i++)
            if ([intPart characterAtIndex:i] == '9') nineCount++;
        
        formatter->maxIntegerDigits = nineCount;
    } else {
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:0];
        int nineCount = 0;
        for (int i = 0; i < [picture length]; i++)
            if ([picture characterAtIndex:i] == '9') nineCount++;
        
        formatter->maxIntegerDigits = nineCount;
    }
    
    if ([picture rangeOfString:@","].location != NSNotFound)
        [formatter setUsesGroupingSeparator:YES];
    else
        [formatter setUsesGroupingSeparator:NO];
        
    [[control cell] setFormatter:formatter];
}

void SwGet_SetUpper(NSTextField *control) {
    if (!control) return;
    FMUpperFormatter *formatter = [[[FMUpperFormatter alloc] init] autorelease];
    [[control cell] setFormatter:formatter];
}

void SwGet_SetAlpha(NSTextField *control) {
    if (!control) return;
    FMAlphaFormatter *formatter = [[[FMAlphaFormatter alloc] init] autorelease];
    [[control cell] setFormatter:formatter];
}

void SwGet_SetEuroDate(NSTextField *control) {
    if (!control) return;
    FMEuroDateFormatter *formatter = [[[FMEuroDateFormatter alloc] init] autorelease];
    [[control cell] setFormatter:formatter];
}

// --- Implementaciones de Formateadores ---

@implementation FMUpperFormatter
- (NSString *)stringForObjectValue:(id)obj { return [obj description]; }
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { *obj = string; return YES; }
- (BOOL)isPartialStringValid:(NSString *)partial newEditingString:(NSString **)newString errorDescription:(NSString **)errorString {
    *newString = [partial uppercaseString];
    return NO;
}
@end

@implementation FMAlphaFormatter
- (NSString *)stringForObjectValue:(id)obj { return [obj description]; }
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { *obj = string; return YES; }
- (BOOL)isPartialStringValid:(NSString *)partial newEditingString:(NSString **)newString errorDescription:(NSString **)errorString {
    for (int i = 0; i < [partial length]; i++)
        if (![[NSCharacterSet letterCharacterSet] characterIsMember:[partial characterAtIndex:i]]) return NO;
    return YES;
}
@end

@implementation FMPictureFormatter
- (NSString *)stringForObjectValue:(id)obj { return [obj description]; }
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { *obj = string; return YES; }
- (BOOL)isPartialStringValid:(NSString *)partial newEditingString:(NSString **)newString errorDescription:(NSString **)errorString {
    int i = 0, j = 0;
    NSMutableString *formatted = [NSMutableString string];
    for (j = 0; j < [picture length] && i < [partial length]; j++) {
        unichar maskChar = [picture characterAtIndex:j];
        unichar inputChar = [partial characterAtIndex:i];
        if (maskChar == '9') {
            if (isdigit(inputChar)) { [formatted appendFormat:@"%C", inputChar]; i++; }
            else return NO;
        } else {
            [formatted appendFormat:@"%C", maskChar];
            if (inputChar == maskChar) i++;
        }
    }
    if ([formatted isEqualToString:partial]) return YES;
    *newString = formatted;
    return NO;
}
@end

@implementation FMEuroNumberFormatter
- (id)init {
    self = [super init];
    if (self) {
        [self setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"es_ES"] autorelease]];
        [self setNumberStyle:NSNumberFormatterDecimalStyle];
        maxIntegerDigits = 0;
    }
    return self;
}
- (NSString *)stringForObjectValue:(id)obj { return [obj description]; }
- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString **)error { *obj = string; return YES; }
@end

@implementation FMEuroDateFormatter
- (id)init {
    self = [super init];
    if (self) { [self setDateFormat:@"dd/MM/yyyy"]; }
    return self;
}
@end

//----------------------------------------------------------------------------//
// SWLOG - Log desde Harbour via NSLog
//----------------------------------------------------------------------------//

HB_FUNC(SWLOG) {
    NSString *msg = hb_NSSTRING_par(1);
    NSLog(@"[HRB] %@", msg);
}

//----------------------------------------------------------------------------//
// PATH FUNCTIONS (ported from nativo/source/winapi/system.m)
//----------------------------------------------------------------------------//

// Path() -> Parent directory of the .app bundle (same as nativo HB_FUNC(PATH))
HB_FUNC(PATH) {
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle != nil) {
        NSString *buPath = [bundle bundlePath];
        NSString *parentPath = [buPath stringByDeletingLastPathComponent];
        if (parentPath != nil) {
            // Añadimos "/" final para que Path() + "file.db" funcione correctamente
            NSString *withSlash = [parentPath stringByAppendingString:@"/"];
            hb_retc([withSlash UTF8String]);
        } else {
            hb_retc("");
        }
    } else {
        hb_retc("");
    }
}

// UserPath() -> Home directory (~)
HB_FUNC(USERPATH) {
    NSString *userPath = [@"~" stringByExpandingTildeInPath];
    hb_retc(userPath != nil ? [userPath UTF8String] : "");
}

// HomePath() -> alias for UserPath
HB_FUNC(HOMEPATH) {
    NSString *userPath = [@"~" stringByExpandingTildeInPath];
    hb_retc(userPath != nil ? [userPath UTF8String] : "");
}

// ImgPath() -> Resources directory inside the .app bundle
HB_FUNC(IMGPATH) {
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    if (resPath != nil) {
        NSString *fullPath = [resPath stringByAppendingString:@"/"];
        hb_retc([fullPath UTF8String]);
    } else {
        hb_retc("");
    }
}
