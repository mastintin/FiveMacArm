/*
 * Harbour 3.2.0dev (r2512222342)
 * LLVM/Clang C 17.0 (clang-1700.6.3.2) ARM64
 * Generated C source from "test.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( HELLOWORLD );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_TEST )
{ "HELLOWORLD", {HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL}, {HB_FUNCNAME( HELLOWORLD )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_TEST, "test.prg", 0x0, 0x0003 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_TEST
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_TEST )
   #include "hbiniseg.h"
#endif

HB_FUNC( HELLOWORLD )
{
	static const HB_BYTE pcode[] =
	{
		36,1,0,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

