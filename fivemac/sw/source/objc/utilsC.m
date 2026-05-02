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

// --- Formateadores eliminados ---



//----------------------------------------------------------------------------//
// SWLOG - Log desde Harbour via NSLog
//----------------------------------------------------------------------------//

HB_FUNC(SWLOG) {
    NSString *msg = hb_NSSTRING_par(1);
    NSLog(@"[HRB] %@", msg);
}

//----------------------------------------------------------------------------//
// PATH FUNCTIONS
//----------------------------------------------------------------------------//

HB_FUNC(PATH) {
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle != nil) {
        NSString *buPath = [bundle bundlePath];
        NSString *parentPath = [buPath stringByDeletingLastPathComponent];
        if (parentPath != nil) {
            NSString *withSlash = [parentPath stringByAppendingString:@"/"];
            hb_retc([withSlash UTF8String]);
        } else {
            hb_retc("");
        }
    } else {
        hb_retc("");
    }
}

HB_FUNC(USERPATH) {
    NSString *userPath = [@"~" stringByExpandingTildeInPath];
    hb_retc(userPath != nil ? [userPath UTF8String] : "");
}

HB_FUNC(HOMEPATH) {
    NSString *userPath = [@"~" stringByExpandingTildeInPath];
    hb_retc(userPath != nil ? [userPath UTF8String] : "");
}

HB_FUNC(IMGPATH) {
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    if (resPath != nil) {
        NSString *fullPath = [resPath stringByAppendingString:@"/"];
        hb_retc([fullPath UTF8String]);
    } else {
        hb_retc("");
    }
}
