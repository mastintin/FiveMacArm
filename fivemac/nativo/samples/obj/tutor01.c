/*
 * Harbour 3.2.0dev (r2512222342)
 * LLVM/Clang C 17.0 (clang-1700.6.3.2) ARM64
 * Generated C source from "tutor01.prg"
 */

#include "hbvmpub.h"
#include "hbinit.h"


HB_FUNC( MAIN );
HB_FUNC_EXTERN( MSGINFO );
HB_FUNC_EXTERN( HB_GT_NUL_DEFAULT );
HB_FUNC_EXTERN( ERRORLINK );
HB_FUNC_EXTERN( MSGBEEP );


HB_INIT_SYMBOLS_BEGIN( hb_vm_SymbolInit_TUTOR01 )
{ "MAIN", {HB_FS_PUBLIC | HB_FS_FIRST | HB_FS_LOCAL}, {HB_FUNCNAME( MAIN )}, NULL },
{ "MSGINFO", {HB_FS_PUBLIC}, {HB_FUNCNAME( MSGINFO )}, NULL },
{ "HB_GT_NUL_DEFAULT", {HB_FS_PUBLIC}, {HB_FUNCNAME( HB_GT_NUL_DEFAULT )}, NULL },
{ "ERRORLINK", {HB_FS_PUBLIC}, {HB_FUNCNAME( ERRORLINK )}, NULL },
{ "MSGBEEP", {HB_FS_PUBLIC}, {HB_FUNCNAME( MSGBEEP )}, NULL }
HB_INIT_SYMBOLS_EX_END( hb_vm_SymbolInit_TUTOR01, "tutor01.prg", 0x0, 0x0003 )

#if defined( HB_PRAGMA_STARTUP )
   #pragma startup hb_vm_SymbolInit_TUTOR01
#elif defined( HB_DATASEG_STARTUP )
   #define HB_DATASEG_BODY    HB_DATASEG_FUNC( hb_vm_SymbolInit_TUTOR01 )
   #include "hbiniseg.h"
#endif

HB_FUNC( MAIN )
{
	static const HB_BYTE pcode[] =
	{
		36,7,0,176,1,0,106,13,72,101,108,108,111,32,
		119,111,114,108,100,33,0,20,1,36,9,0,100,110,
		7
	};

	hb_vmExecute( pcode, symbols );
}

