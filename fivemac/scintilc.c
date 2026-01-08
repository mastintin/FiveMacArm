// C functions for Scintilla

#include <windows.h>
#include <Windowsx.h>
#include <commctrl.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbregex.h>
#include "scintila.h"
#include <fwh.h>

typedef struct SCNotification SCNOTIFICATION, * LPSCNOTIFICATION;

FILE * hb_fsOpen( const char * path, const char * mode );
int hb_fsRead( char * pBuffer, int nSizeT, int nSize, FILE * pFile );
int hb_fsClose( FILE * pFile );

//----------------------------------------------------------------------------//

static void AsigKeys( HWND hWnd, int nKey )
{
  SendMessage( hWnd, SCI_ASSIGNCMDKEY,( nKey + (SCMOD_CTRL << 16)), SCI_NULL );
}

//----------------------------------------------------------------------------//

HB_FUNC( ASIGNKEYS )
{
   int x ;
   for ( x = 65; ( x < 91 ) ; x++ )
   {
     if ( x != 84 )
     {
     AsigKeys(  ( HWND ) fw_parH( 1 ), x ) ;
     AsigKeys(  ( HWND ) fw_parH( 1 ), x + 32 ) ;
     }
   }
}

//----------------------------------------------------------------------------//

HB_FUNC( GETIDHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   struct NotifyHeader * pMsg1 = ( struct NotifyHeader * ) pSCN;
   #ifndef _WIN64
      hb_retnl( pMsg1->idFrom );
   #else
      hb_retnll( pMsg1->idFrom );
   #endif
}

//-------------------------------------------------------------------------//

HB_FUNC( SCNOTIFICATIONCH )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   //struct NotifyHeader * pMsg1 = ( struct NotifyHeader * ) pSCN;
   hb_retni( pSCN->ch );
}

//-------------------------------------------------------------------------//

HB_FUNC( SCNOTIFICATIONCODE )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   struct NotifyHeader * pMsg1 = ( struct NotifyHeader * ) pSCN;
   hb_retni( pMsg1->code );
}

//-------------------------------------------------------------------------//

/*
HB_FUNC( SCNOTIFICATIONTEXT )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   #ifndef _WIN64
      hb_retc( pSCN->text );
   #else
      hb_retc( ( LPCSTR ) pSCN->text );
   #endif
}
*/
//-------------------------------------------------------------------------//

HB_FUNC( GETPOSHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->position );
}

//----------------------------------------------------------------------------//
/*
static HWND GetWndHdr( LPARAM lParam )
{
   //struct SCNotification * pMsg = ( struct SCNotification * )lParam;
   LPSCNOTIFICATION  pMsg = ( LPSCNOTIFICATION ) lParam;
   struct NotifyHeader * pMsg1 = ( struct NotifyHeader * ) pMsg;

   return ( ( HWND ) pMsg1->hwndFrom );
}
*/
//----------------------------------------------------------------------------//

HB_FUNC( GETWNDHDR )
{
   #ifndef _WIN64
   LPSCNOTIFICATION  pMsg = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   struct NotifyHeader * pMsg1 = ( struct NotifyHeader * ) pMsg;
   //HWND hRet = ( HWND ) GetWndHdr( hb_parnl( 1 ) );
   //hb_retnl( ( LONG ) pMsg1->hwndFrom ); //( LONG ) hRet );
   fw_retnll( pMsg1->hwndFrom );
   #else
   LPSCNOTIFICATION  pMsg = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   struct NotifyHeader * pMsg1 = ( struct NotifyHeader * ) pMsg;
   //HWND hRet = ( HWND ) GetWndHdr( hb_parnll( 1 ) );
   hb_retnll( ( LONGLONG ) pMsg1->hwndFrom ); //hRet );
   #endif
}

//----------------------------------------------------------------------------//

HB_FUNC( GETPOSIHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->position );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETCHARHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->ch );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETMODIFIER )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->modifiers );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETMODTYPE )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->modificationType );
}

//----------------------------------------------------------------------------//
//const char *text;

HB_FUNC( GETTEXTHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retc( ( LPCSTR ) pSCN->text );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLENHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->length );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLINADDHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->linesAdded );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETMESSAGEHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->message );
}

//----------------------------------------------------------------------------//
//uptr_t wParam;
HB_FUNC( GETWPARAM )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retnl( ( long ) pSCN->wParam );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLPARAM )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retnl( ( long ) pSCN->lParam );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLINEHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->line );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLEVNOWHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->foldLevelNow );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLEVPREVHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->foldLevelPrev );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETMARGHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->margin );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLISTHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->listType );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETXHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->x );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETYHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->y );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETTOKENHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->token );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETANNOTALINESADDHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->annotationLinesAdded );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETUPDATEDHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->updated );
}

//----------------------------------------------------------------------------//

HB_FUNC( GETLISTCOMPLETIONHDR )
{
   #ifndef _WIN64
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnl( 1 );
   #else
      LPSCNOTIFICATION pSCN = ( LPSCNOTIFICATION ) hb_parnll( 1 );
   #endif
   hb_retni( pSCN->listCompletionMethod );
}

//----------------------------------------------------------------------------//
//
//----------------------------------------------------------------------------//

HB_FUNC( GETXPARAM )
{
   #ifndef _WIN64
      hb_retni( GET_X_LPARAM( hb_parnl( 1 ) ) );
   #else
      hb_retni( GET_X_LPARAM( hb_parnll( 1 ) ) );
   #endif
}

//----------------------------------------------------------------------------//

HB_FUNC( GETYPARAM )
{
   #ifndef _WIN64
      hb_retni( GET_Y_LPARAM( hb_parnl( 1 ) ) );
   #else
      hb_retni( GET_Y_LPARAM( hb_parnll( 1 ) ) );
   #endif
}

//----------------------------------------------------------------------------//

HB_FUNC( PONFOLD )
{
   #ifndef _WIN64
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
   HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   SendMessage( hWnd, 4004, ( WPARAM ) hb_parc( 2 ), ( LPARAM ) hb_parc( 3 ) );
     //SendMessage( hWnd, SCI_SETPROPERTY, (WPARAM)"fold", (LPARAM)"1");
}
//----------------------------------------------------------------------------//

HB_FUNC( PONFOLDCOMPACT )
{
   #ifndef _WIN64
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
   HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   SendMessage( hWnd, 4004, ( WPARAM ) hb_parc( 2 ), ( LPARAM ) hb_parc( 3 ) );
     //SendMessage( hWnd, SCI_SETPROPERTY, (WPARAM)"fold.compact", (LPARAM)"0");
}
//----------------------------------------------------------------------------//

BOOL SearchForward( HWND hWnd, LPSTR szText, int nSearchFlags ) //@parm text to search
{
   long lPos = ( long ) SendMessage( hWnd, SCI_GETCURRENTPOS, 0, 0 );
   TEXTTOFIND tf;

   tf.lpstrText  = szText;
   tf.chrg.cpMin = lPos + 1;
   tf.chrg.cpMax = ( long ) SendMessage( hWnd, SCI_GETLENGTH, 0, 0 );

   lPos = ( long ) SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) nSearchFlags, ( LPARAM ) &tf );

   if( lPos > 0 )
   {
      SetFocus( hWnd );
      SendMessage( hWnd, SCI_GOTOPOS, lPos, 0 );
      SendMessage( hWnd, SCI_SETSEL, tf.chrgText.cpMin, (LPARAM) tf.chrgText.cpMax );
      return TRUE;
   }

   return FALSE;
}

//----------------------------------------------------------------------------//
// @mfunc Search backward for a given string and select it if found. You may use regular expressions on the text.
// @rvalue BOOL | TRUE if text is ffound else FALSE
//----------------------------------------------------------------------------//

BOOL SearchBackward( HWND hWnd, LPSTR szText, int nSearchFlags ) //@parm text to search
{
   int lPos;
   int lMinSel;
   TEXTTOFIND tf;

   if ( szText == NULL)
      return FALSE;

   lPos = ( int ) SendMessage( hWnd, SCI_GETCURRENTPOS, 0, 0 );
   lMinSel = ( int ) SendMessage( hWnd, SCI_GETSELECTIONSTART, 0, 0 );
   tf.lpstrText = szText;

   if( lMinSel >= 0 )
      tf.chrg.cpMin = lMinSel-1;
   else
      tf.chrg.cpMin = lPos-1;

   tf.chrg.cpMax = 0;
   lPos = ( int ) SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) nSearchFlags, ( LPARAM ) &tf );

   if( lPos >= 0 )
   {
      SetFocus(hWnd);
      SendMessage( hWnd, SCI_GOTOPOS, lPos, 0 );
      SendMessage( hWnd, SCI_SETSEL, tf.chrgText.cpMin, tf.chrgText.cpMax );
      SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) nSearchFlags, ( LPARAM ) &tf );
      return TRUE;
   }
   return FALSE;
}

//----------------------------------------------------------------------------//

HB_FUNC( SC_ADDTEXT )
{
   #ifndef _WIN64
   hb_retnl( SendMessage( ( HWND ) hb_parnl( 1 ), SCI_ADDTEXT, hb_parclen( 2 ), ( LPARAM ) hb_parc( 2 ) ) );
   #else
   hb_retnll( SendMessage( ( HWND ) hb_parnll( 1 ), SCI_ADDTEXT, hb_parclen( 2 ), ( LPARAM ) hb_parc( 2 ) ) );
   #endif

}

//----------------------------------------------------------------------------//

#define BUFSIZE 131072

HB_FUNC( SCI_OPENFILE )
{

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   char * fileName = ( char * ) hb_parc( 2 );
   char * data;
   FILE * fp;
   int lenFile;

   data = ( char * ) hb_xgrab( BUFSIZE );

   // SendMessage( hWnd, SCI_CLEARALL, 0, 0 );
   SendMessage( hWnd, EM_EMPTYUNDOBUFFER, 0, 0 );
   SendMessage( hWnd, SCI_SETSAVEPOINT, 0, 0 );
   SendMessage( hWnd, SCI_CANCEL, 0, 0 );
   SendMessage( hWnd, SCI_SETUNDOCOLLECTION, 0, 0 );

   fp = ( FILE * ) hb_fsOpen( fileName, "rb" );

   if( fp )
   {
      lenFile = hb_fsRead( data, 1, BUFSIZE, fp );

      while( lenFile > 0 )
      {
         SendMessage( hWnd, SCI_ADDTEXT, lenFile, ( LPARAM ) data );
         lenFile = hb_fsRead( data, 1, BUFSIZE, fp );
      }

      hb_fsClose( fp );
   }
   else
   {
      MessageBox( 0, "Can't open the file", "Attention", MB_OK );
   }

   SendMessage( hWnd, SCI_SETUNDOCOLLECTION, 1, 0 );
   SetFocus( hWnd );
   SendMessage( hWnd, EM_EMPTYUNDOBUFFER, 0, 0 );
   SendMessage( hWnd, SCI_SETSAVEPOINT, 0, 0 );
   SendMessage( hWnd, SCI_GOTOPOS, 0, 0 );

   hb_xfree( data );

   hb_ret();
}

//----------------------------------------------------------------------------//

HB_FUNC( SCIGETTEXT )
{

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   int wLen = ( int ) SendMessage( hWnd, SCI_GETLENGTH, 0, 0 );
   char * buffer = ( char * ) hb_xgrab( wLen + 1 );

   SendMessage( hWnd, SCI_GETTEXT, wLen + 1, ( LPARAM ) buffer );

   hb_retclen( ( char * ) buffer, wLen );
   hb_xfree( buffer );
}

//----------------------------------------------------------------------------//

HB_FUNC( SCIGETTEXTAT )
{

   #ifndef _WIN64
      HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
      HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif

   int lPos = hb_parni( 2 );
   char * buffer = hb_xgrab( 2 );    //( char * )

   memset( buffer, 0x00, 2 );

   buffer[0] = ( char ) SendMessage( hWnd, SCI_GETCHARAT, ( WPARAM ) lPos, ( LPARAM ) 0 );

   hb_retc( ( char * ) buffer );
   hb_xfree( buffer );
}

//----------------------------------------------------------------------------//

HB_FUNC( SCIGETLINE )
{
   #ifndef _WIN64
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
   HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   int nLine = hb_parni( 2 )-1;
   int wLen;
   BYTE * pbyBuffer;
   wLen = ( int ) SendMessage( hWnd, SCI_LINELENGTH, nLine, 0 );
   if( wLen )
   {
      pbyBuffer = ( BYTE * ) hb_xgrab( wLen+1 );
      SendMessage( hWnd, SCI_GETLINE, nLine, (LPARAM) pbyBuffer );
      hb_retclen( ( char * ) pbyBuffer, wLen );
      hb_xfree( pbyBuffer );
   }
   else
      hb_retc("");
}

//----------------------------------------------------------------------------//

HB_FUNC( SC_ISREADONLY )
{
   #ifndef _WIN64
   hb_retl( SendMessage( (HWND) hb_parnl( 1 ), SCI_GETREADONLY, 0, 0 ) );
   #else
   hb_retl( ( int ) SendMessage( (HWND) hb_parnll( 1 ), SCI_GETREADONLY, 0, 0 ) );
   #endif

}

//----------------------------------------------------------------------------//

HB_FUNC( SEARCHFORWARD )
{
   #ifndef _WIN64
   hb_retl( SearchForward( ( HWND ) hb_parnl( 1 ), ( char * ) hb_parc( 2 ), hb_parni( 3 ) ) );
   #else
   hb_retl( SearchForward( ( HWND ) hb_parnll( 1 ), ( char * ) hb_parc( 2 ), hb_parni( 3 ) ) );
   #endif

}

//----------------------------------------------------------------------------//

HB_FUNC( SEARCHBACKWARD )
{
   #ifndef _WIN64
    hb_retl( SearchBackward( ( HWND ) hb_parnl( 1 ), ( char * ) hb_parc( 2 ), hb_parni( 3 ) ) );
   #else
    hb_retl( SearchBackward( ( HWND ) hb_parnll( 1 ), ( char * ) hb_parc( 2 ), hb_parni( 3 ) ) );
   #endif

}

//----------------------------------------------------------------------------//

HB_FUNC( SCIGETSELTEXT )
{
   #ifndef _WIN64
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   int wSize = hb_parnl( 2 );
   #else
   HWND hWnd = ( HWND ) hb_parnll( 1 );
   int wSize = ( int ) hb_parnll( 2 );
   #endif

   char * cBuff = ( char * ) hb_xgrab( wSize + 1 );

   SendMessage( hWnd, SCI_GETSELTEXT, ( WPARAM ) 0, ( LPARAM ) cBuff );

   hb_retclen( cBuff, wSize );
   hb_xfree( cBuff );
}

//----------------------------------------------------------------------------//

static HB_BOOL isValidChar( char * cChar ){

  //const char cWordCharacters[] = "(Ã|ƒ|Œ|Ž|‹|Š|‰|ˆ|‡|†|…|€|»|¿|Ó|ß|õ|Ô|Ò|Õ|µ|a|c|e|Þ|Ú|Ù|Û|ý|Ý|´|¯|=|½|¼|¾|÷|¶|§|°|?|¨|·|³|¹|²|±|þ|à|á|ä|â|ã|å|æ|è|é|ë|ê|ì|í|ï|î|ò|ó|ö|ô|õ|ø|?|ù|ú|ü|û|ñ|ç|a|b|c|d|e|f|g|h|i|j|k|l|m|n|ñ|o|p|q|r|s|t|u|v|w|x|y|z|1|2|3|4|5|6|7|8|9|0)";
  const char cWordCharacters[] = "(a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|1|2|3|4|5|6|7|8|9|0|ñ)";
  PHB_ITEM pRegExItm = hb_itemNew( NULL );
  HB_BOOL fResult = HB_FALSE;
  PHB_REGEX pReg;
  hb_itemPutCL( pRegExItm, cWordCharacters, strlen( cWordCharacters ) );
  pReg = hb_regexGet( pRegExItm, HBREG_ICASE );

  if( pReg != NULL ){
    fResult = hb_regexMatch( pReg, cChar, strlen( cChar ), HB_FALSE );
    hb_regexFree( pReg );
  }
  
  hb_itemRelease( pRegExItm );
  return fResult;
}

//----------------------------------------------------------------------------//

HB_FUNC( FINDAUTOCOMPLETE )
{
   int lPos;
   int lMinSel;
   char * szText = ( char * ) hb_parc( 2 );
   #ifndef _WIN64
   HWND hWnd = ( HWND ) hb_parnl( 1 );
   #else
   HWND hWnd = ( HWND ) hb_parnll( 1 );
   #endif
   TEXTTOFIND tf;

   if ( szText ){     //!szText == NULL
      //if( hb_parni( 3 ) )
      //   lPos = SendMessage( hWnd, SCI_GETCURRENTPOS, 0, 0 ) + hb_parni( 3 );
      //else
         lPos = ( int ) SendMessage( hWnd, SCI_GETCURRENTPOS, 0, 0 );

      lMinSel = ( int ) SendMessage( hWnd, SCI_GETSELECTIONSTART, 0, 0 );
      tf.lpstrText = szText;

      if( lMinSel >= 0 )
         tf.chrg.cpMin = lMinSel - 1;
      else
         tf.chrg.cpMin = lPos - 1;

      tf.chrg.cpMax = 0;
      lPos = ( int ) SendMessage( hWnd, SCI_FINDTEXT, ( WPARAM ) SCFIND_WORDSTART, ( LPARAM ) &tf );
      if( lPos >= 0 )
      {
         TEXTTOFIND tfFound;
         char * cBuff = ( char * ) hb_xgrab( 512 );
         int iCurrent = 0;
         //char cChar;
         char cSingle[2];

         memset( cSingle, 0x00, 2 );

         cSingle[0] = ( char ) SendMessage( hWnd, SCI_GETCHARAT, ( WPARAM ) lPos, ( LPARAM ) 0 );
         //strncpy( cSingle, &cChar, 1 );

         while( isValidChar( cSingle ) == HB_TRUE ){
            iCurrent ++;
            cSingle[0] = ( char ) SendMessage( hWnd, SCI_GETCHARAT, ( WPARAM ) lPos + iCurrent, ( LPARAM ) 0 );
            //strncpy( cSingle, &cChar, 1 );
         }

         tfFound.chrg.cpMin = lPos;
         tfFound.chrg.cpMax = lPos + iCurrent;
         tfFound.lpstrText  = cBuff;
         SendMessage( hWnd, SCI_GETTEXTRANGE, ( WPARAM ) 0, ( LPARAM ) &tfFound );
         hb_retclen( cBuff, iCurrent );
         hb_xfree( cBuff );
      }else
         hb_ret();
   }else
      hb_ret();

}

//----------------------------------------------------------------------------//

//"/* XPM */",
HB_FUNC( MYFUNC_F )
{
 char * F_unction_xpm[] = {
"12 12 3 1",    // Añadir aqui antes lo de XPM
" 	c None",
".	c #808080",
"+	c #000000",
"            ",
"  .++++++.  ",
"  +      +  ",
"  + ++++ +  ",
"  + +    +  ",
"  + +    +  ",
"  + +++  +  ",
"  + +    +  ",
"  + +    +  ",
"  +      +  ",
"  .++++++.  ",
"            "};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//

/* XPM */
HB_FUNC( MYFUNC_FBLUE )
{
 char * F_unction_xpm[] = {
"12 12 3 1",
" 	c None",
".	c #6666FF",
"+	c #0000FF",
"            ",
"  .++++++.  ",
"  +      +  ",
"  + ++++ +  ",
"  + +    +  ",
"  + +    +  ",
"  + +++  +  ",
"  + +    +  ",
"  + +    +  ",
"  +      +  ",
"  .++++++.  ",
"            "};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//

/* XPM */
HB_FUNC( MYFUNC_DBLUE )
{
 char * F_unction_xpm[] = {
"12 12 3 1",
" 	c None",
".	c #6666FF",
"+	c #0000FF",
"            ",
".++++++++++.",
"+          +",
"+  ++++    +",
"+  +   +   +",
"+  +   +   +",
"+  +   +   +",
"+  +   +   +",
"+  +   +   +",
"+  ++++    +",
"+          +",
"+++++++++++."};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//

/* XPM */
HB_FUNC( MYFUNC_VBLUE )
{
 char * F_unction_xpm[] = {
"12 12 3 1",
" 	c None",
".	c #6666FF",
"+	c #0000FF",
"            ",
".++++++++++.",
"+          +",
"+ +     +  +",
"+ +     +  +",
"+ +     +  +",
"+  +   +   +",
"+  +   +   +",
"+   + +    +",
"+    +     +",
"+          +",
"+++++++++++."};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//

/* XPM */
HB_FUNC( MYFUNC_MBLUE )
{
 char * F_unction_xpm[] = {
"12 12 3 1",
" 	c None",
".	c #6666FF",
"+	c #0000FF",
"            ",
".----------.",
"+          !",
"+  ++   ++ !",
"+  ++   ++ !",
"+  + + + + !",
"+  +  +  + !",
"+  +     + !",
"+  +     + !",
"+  +     + !",
"+          !",
".----------."};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//

HB_FUNC( MYFUNC_F16 )
{
 char * F_unction_xpm[] = {
"16 16 3 1",
" 	c None",
"-	c #808080",
"+	c #8F0000",
"                ",
"                ",
"+--------------+",
"+--------------+",
"+              +",
"+   ++++++++   +",
"+   ++++++++   +",
"+   ++         +",
"+   ++         +",
"+   +++++      +",
"+   +++++      +",
"+   ++         +",
"+   ++         +",
"+   ++         +",
"+              +",
"+--------------+",
"+--------------+",
"                ",};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//

HB_FUNC( MYFUNC_MBLUE16 )
{
 char * F_unction_xpm[] = {
"16 16 3 1",
" 	c None",
"-	c #6666FF",
"+	c #0000FF",
"                ",
"                ",
"+--------------+",
"+--------------+",
"+              +",
"+  ++     ++   +",
"+  +++   +++   +",
"+  ++ + + ++   +",
"+  ++  +  ++   +",
"+  ++     ++   +",
"+  ++     ++   +",
"+  ++     ++   +",
"+              +",
"+--------------+",
"+--------------+",
"                ",};

   hb_retclen( (LPSTR) F_unction_xpm, sizeof( F_unction_xpm )  ) ;
}

//----------------------------------------------------------------------------//
