#ifndef _SWIFTCONTROLS_CH
#define _SWIFTCONTROLS_CH

//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWIFTBUTTON [ <oBtn> PROMPT ] <cCaption> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ACTION <uAction> ] ;
    => ;
    [ <oBtn> := ] TSwiftButton():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cCaption>, <oWnd>, [<{uAction}>] )

//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWIFTLABEL [ <oSay> PROMPT ] <cText> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    => ;
    [ <oSay> := ] TSwiftLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd> )

#xcommand @ <nRow>, <nCol> SWIFTSLIDER [ <oSld> VAR ] <nVal> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ON CHANGE <uChange> ] ;
    => ;
    [ <oSld> := ] TSwiftSlider():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <nVal>, <oWnd>, [<{uChange}>] )

#xcommand @ <nRow>, <nCol> SWIFTIMAGE [ <oImg> NAME ] <cName> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ACTION <uAction> ] ;
    [ <lRes: RESIZABLE> <lResizable> ] ;
    => ;
    [ <oImg> := ] TSwiftImage():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cName>, <oWnd>, [<{uAction}>], <.lResizable.> )

#xcommand @ <nRow>, <nCol> SWIFTTABVIEW [ <oTab> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ITEMS <aItems> ] ;
    => ;
    [ <oTab> := ] TSwiftTabView():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <aItems> )

#xcommand @ <nRow>, <nCol> SWIFTVSTACK [ <oStub> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    => ;
    [ <oStub> := ] TSwiftVStack():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd> )

//----------------------------------------------------------------------------//

#endif
