#include <fivemac.h>

@interface FMFormatter : NSFormatter {
@public
  NSTextField *control;
}
- (NSString *)stringForObjectValue:(id)anObject;
- (BOOL)getObjectValue:(id *)anObject
             forString:(NSString *)string
      errorDescription:(NSString **)error;
- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error;
@end

@interface FMUpperFormatter : NSFormatter
- (NSString *)stringForObjectValue:(id)anObject;
- (BOOL)getObjectValue:(id *)anObject
             forString:(NSString *)string
      errorDescription:(NSString **)error;
- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error;
@end

@interface FMAlphaFormatter : NSFormatter
- (NSString *)stringForObjectValue:(id)anObject;
- (BOOL)getObjectValue:(id *)anObject
             forString:(NSString *)string
      errorDescription:(NSString **)error;
- (BOOL)isPartialStringValid:(NSString *)partialString
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)error;
@end

@interface FMDateFormatter : NSDateFormatter
@end

@interface FMPictureFormatter : NSFormatter {
@public
  NSString *picture;
}
- (BOOL)isPartialStringValid:(NSString *)partial
            newEditingString:(NSString **)newString
            errorDescription:(NSString **)errorString;
@end

@interface FMEuroNumberFormatter : NSNumberFormatter {
@public
  int maxIntegerDigits;
}
@end

@interface FMEuroDateFormatter : NSDateFormatter
@end
