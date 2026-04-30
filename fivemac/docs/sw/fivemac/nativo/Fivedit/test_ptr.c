/*
 * Harbour 3.2.0dev (r2512222342)
 * LLVM/Clang C 17.0 (clang-1700.6.3.2) ARM64
 * Generated C source from "test_ptr.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( MAIN );
HB_FUNC_EXTERN( HB_XGRAB );
HB_FUNC_EXTERN( QOUT );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_TEST_PTR )
{ "MAIN", {HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL}, {HB_FUNCNAME( MAIN )}, NULL },
{ "HB_XGRAB", {HB_FS_PUBLIC}, {HB_FUNCNAME( HB_XGRAB )}, NULL },
{ "QOUT", {HB_FS_PUBLIC}, {HB_FUNCNAME( QOUT )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_TEST_PTR, "test_ptr.prg", 0x0, 0x0003 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_TEST_PTR
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_TEST_PTR )
   #include "hbiniseg.h"
#endif

HB_FUNC( MAIN )
{
	static const HB_BYTE pcode[] =
	{
		13,3,0,36,2,0,176,1,0,92,10,12,1,80,
		1,36,3,0,100,80,2,36,4,0,121,80,3,36,
		5,0,176,2,0,106,19,67,111,109,112,97,114,105,
		110,103,32,80,32,97,110,100,32,85,58,0,20,1,
		36,6,0,176,2,0,95,1,95,2,8,20,1,36,
		7,0,176,2,0,106,6,68,111,110,101,46,0,20,
		1,36,8,0,100,110,7
	};

	hb_vmExecute( pcode, symbols );
}

