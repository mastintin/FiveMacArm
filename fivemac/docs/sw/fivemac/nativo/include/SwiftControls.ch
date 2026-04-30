#ifndef _SWIFTCONTROLS_CH
#define _SWIFTCONTROLS_CH

//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWIFTBUTTON [ <oBtn> PROMPT ] <cCaption> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ACTION <uAction> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    [ <glass: GLASS> ] ;
    [ <prominent: PROMINENT> ] ;
    => ;
    [ <oBtn> := ] TSwiftButton():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cCaption>, <oWnd>, [<{uAction}>], <nAutoResize>, NIL, <.glass.>, <.prominent.> )

//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWIFTLABEL [ <oSay> PROMPT ] <cText> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oSay> := ] TSwiftLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTSAY [ <oSay> PROMPT ] <cText> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oSay> := ] TSwiftLabel():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <oWnd>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTGET [ <oGet> PROMPT ] <cText> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ PLACEHOLDER <cPlaceholder> ] ;
    [ ON CHANGE <uChange> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oGet> := ] TSwiftTextField():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cText>, <cPlaceholder>, <oWnd>, [<uChange>], <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTSLIDER [ <oSld> VAR ] <nVal> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ SHOWVALUE <lShow> ] ;
    [ GLASS <lGlass> ] ;
    [ ON CHANGE <uChange> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oSld> := ] TSwiftSlider():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <nVal>, <lShow>, <lGlass>, <oWnd>, [<{uChange}>], <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTTOGGLE [ <oTgl> VAR ] <lVar> ;
    [ PROMPT <cCaption> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ SWITCH <lSwitch> ] ;
    [ ON CHANGE <uChange> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oTgl> := ] TSwiftToggle():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cCaption>, <lVar>, <lSwitch>, <oWnd>, [<{uChange}>], <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTIMAGE [ <oImg> NAME ] <cName> ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ACTION <uAction> ] ;
    [ <lRes: RESIZABLE> <lResizable> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oImg> := ] TSwiftImage():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <cName>, <oWnd>, [<{uAction}>], <.lResizable.>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTTABVIEW [ <oTab> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ITEMS <aItems> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oTab> := ] TSwiftTabView():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <aItems>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTVSTACK [ <oStub> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oStub> := ] TSwiftVStack():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTZSTACK [ <oZStk> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oZStk> := ] TSwiftZStack():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTLIST [ <oList> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oList> := ] TSwiftList():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTGRID [ <oGrid> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ COLUMNS <aColumns> ] ;
    [ OF <oWnd> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oGrid> := ] TSwiftGrid():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <aColumns>, <oWnd>, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTCHART [ <oChart> ] ;
    [ DATA <hData> ] ;
    [ TYPE <cType> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    => ;
    [ <oChart> := ] TSwiftChart():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <hData>, <cType> )


//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWIFTPICKER [ <oPick> VAR ] <cVar> ;
    [ ITEMS <aItems> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ON CHANGE <uChange> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oPick> := ] TSwiftPicker():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>,;
    <aItems>, [\{| cVal, o |(<uChange>)\}], bSETGET(<cVar>),, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTDATEPICKER [ <oDtp> ] ;
    [ <dVar: VAR, dDATE> <dDate> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ ON CHANGE <uChange> ] ;
    [ TITLE <cTitle> ] ;
    => ;
    [ <oDtp> := ] TSwiftDatePicker():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, [<dDate>], [\{| dVal, o |(<uChange>)\}], <cTitle> )

//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> SWIFTWEBVIEW [ <oWeb> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ URL <cUrl> ] ;
    [ AUTORESIZE <nAutoResize> ] ;
    => ;
    [ <oWeb> := ] TSwiftWebview():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <cUrl>,, <nAutoResize> )

#xcommand @ <nRow>, <nCol> SWIFTAICHAT [ <oChat> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ OF <oWnd> ] ;
    [ APIKEY <cKey> ] ;
    [ MODEL <cModel> ] ;
    => ;
    [ <oChat> := ] TSwiftAIChat():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd>, <cKey>, <cModel> )

#xcommand SWIFTAICHAT <cKey> [ MODEL <cModel> ] ;
    => ;
    SD_SW_AICHAT_OPEN( <cKey>, [ <cModel> ] )

#endif
