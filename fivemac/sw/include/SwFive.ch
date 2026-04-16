#ifndef _SWFIVE_CH
#define _SWFIVE_CH

#include "anclas.ch"

// Nombres modernos para la isla (Autoresize)
#define SW_ANCHOR_RIGHT      AnclaRight
#define SW_RESIZE_WIDTH      AnchoMovil
#define SW_ANCHOR_LEFT       AnclaLeft
#define SW_ANCHOR_TOP        AnclaTop
#define SW_RESIZE_HEIGHT     AltoMovil
#define SW_ANCHOR_BOTTOM     AnclaBottom

//----------------------------------------------------------------------------//
// VENTANA
//----------------------------------------------------------------------------//

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   FROM <nTop>, <nLeft> TO <nBottom>, <nRight> ;
   => ;
   <oWnd> := TSwWindow():New( <cTitle>, <nRight> - <nLeft>, <nBottom> - <nTop> )

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   SIZE <nWidth>, <nHeight> ;
   => ;
   <oWnd> := TSwWindow():New( <cTitle>, <nWidth>, <nHeight> )

#xcommand ACTIVATE WINDOW <oWnd> ;
   [ <center: CENTER, CENTERED> ] ;
   => ;
   <oWnd>:Activate( <.center.> )

//----------------------------------------------------------------------------//
// COMPONENTES DE LA ISLA (Sw)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> LABEL [ <oSay> PROMPT ] <cText> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd>,, <nAnchor> )

#xcommand @ <nRow>, <nCol> SAY [ <oSay> PROMPT ] <cText> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd>,, <nAnchor> )

#xcommand @ <nRow>, <nCol> BUTTON [ <oBtn> PROMPT ] <cPrompt> ;
   [ OF <oWnd> ] ;
   [ ACTION <uAction,...> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
   => ;
   [ <oBtn> := ] TSwButton():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
   <cPrompt>, <oWnd>, [\{| self |(<uAction>)\}], <nAnchor> )

#xcommand @ <nRow>, <nCol> TOGGLE [ <oToggle> PROMPT ] <cText> ;
             [ <lValue: VALUE, VAR > <lOn> ] ;
             [ <lSw: SWITCH > ] ;
             [ OF <oWnd> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
             [ ID <cId> ] ;
      => ;
      [ <oToggle> := ] TSwToggle():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <lOn>, <cText>, <oWnd>, <cId>, [ .not. Empty(<.lSw.>) ], <nAnchor> )

#xcommand @ <nRow>, <nCol> SLIDER [ <oSlider> ] ;
             [ VALUE <nValue> ] ;
             [ RANGE <nMin>, <nMax> ] ;
             [ OF <oWnd> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
             [ <id: ID, IDENT, CID> <cId> ] ;
             [ <change: ON CHANGE, ACTION> <uAction,...> ] ;
    => ;
   [ <oSlider> := ] TSwSlider():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <nValue>, <nMin>, <nMax>, <oWnd>, <cId>, [\{| nVal, self |(<uAction>)\}], <nAnchor> )

#xcommand @ <nRow>, <nCol> WEBVIEW [ <oWeb> ] ;
              [ URL <cUrl> ] ;
              [ OF <oWnd> ] ;
              [ SIZE <nWidth>, <nHeight> ] ;
              [ <res: AUTORESIZE, ANCHOR> <nAnchor> ] ;
              [ ID <cId> ] ;
    => ;
    [ <oWeb> := ] TSwWebView():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cUrl>, <oWnd>, <cId>, <nAnchor> )

#endif
