#import "SwiftPython-Swift.h"
#import <Foundation/Foundation.h>
#include <hbapi.h>
#include <stdlib.h>

HB_FUNC(SET_PYTHON_HOME) {
  // Suponiendo que pasas la ruta calculada desde Harbour
  const char *path = hb_parc(1);
  setenv("PYTHONHOME", path, 1);
}

HB_FUNC(SWIFTPYTHON_EVAL) {
  const char *code = hb_parc(1);
  NSString *strCode = [NSString stringWithUTF8String:code];
  [TSwiftPython Eval:strCode];
}

HB_FUNC(SWIFTPYTHON_EVALUATE) {
  const char *code = hb_parc(1);
  NSString *strCode = [NSString stringWithUTF8String:code];
  NSString *result = [TSwiftPython Evaluate:strCode];
  hb_retc([result UTF8String]);
}
