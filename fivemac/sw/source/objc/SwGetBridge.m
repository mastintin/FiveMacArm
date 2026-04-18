#import <AppKit/AppKit.h>
#import "formatters.h"

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
