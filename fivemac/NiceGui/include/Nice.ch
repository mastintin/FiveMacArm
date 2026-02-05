// Nice.ch - Preprocessor commands for NiceGUI Framework

#include "hbclass.ch"
#include "common.ch"
#include "FiveMac.ch"

#xcommand DEFINE NICE PAGE <oPage> [ OF <oParent> ] ;
    => ;
    <oPage> := TNicePage():New( <oParent> )

#xcommand ACTIVATE NICE PAGE <oPage> ;
    => ;
    <oPage>:Activate()

#xcommand DEFINE NICE HEADER [ <oHeader> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oPage> ] ;
    => ;
    [ <oHeader> := ] TNiceHeader():New( <oPage>, [<cClass>], [<cStyle>] )

#xcommand END NICE HEADER =>

#xcommand DEFINE NICE FOOTER [ <oFooter> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oPage> ] ;
    => ;
    [ <oFooter> := ] TNiceFooter():New( <oPage>, [<cClass>], [<cStyle>] )

#xcommand END NICE FOOTER =>

#xcommand DEFINE NICE CARD [ <oCard> ] ;
    [ RADIUS <nRadius> ] ;
    [ BORDER COLOR <cBorCol> ] ;
    [ BORDER WIDTH <nWidth> ] ;
    [ SIDE <cSide> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ GAP <cGap> ] ;
    [ ALIGN <cAlign> ] ;
    [ JUSTIFY <cJustify> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oCard> := ] TNiceCard():New( <oParent>, [<cClass>], [<cStyle>], [<.lBold.>], [<cSize>], [<cColor>], [<cGap>], [<cAlign>], [<cJustify>], [<cBgColor>] ) ;;
    [ <oCard>:SetRadius( <nRadius> ) ] ;;
    [ <oCard>:SetBorderColor( <cBorCol> ) ] ;;
    [ <oCard>:SetBorderWidth( <nWidth> ) ] ;;
    [ <oCard>:SetBorderSide( <cSide> ) ]

#xcommand END NICE CARD =>

#xcommand DEFINE NICE DRAWER [ <oDrawer> ] ;
    [ SIDE <cSide> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oPage> ] ;
    => ;
    [ <oDrawer> := ] TNiceDrawer():New( <oPage>, [<cSide>], [<cClass>], [<cStyle>] )

#xcommand END NICE DRAWER =>

#xcommand NICE DRAWER ITEM [ <oItem> ] ;
    PROMPT <cPrompt> ;
    [ ICON <cIcon> ] ;
    [ ACTION <uAction> ] ;
    [ JS <cJs> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oDrawer> ] ;
    => ;
    [ <oItem> := ] TNiceDrawerItem():New( <oDrawer>, <cPrompt>, [<cIcon>], [<{uAction}>], [<cClass>], [<cStyle>], [<cJs>] )

#xcommand DEFINE NICE HSTACK [ <oStack> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ GAP <cGap> ] ;
    [ ALIGN <cAlign> ] ;
    [ JUSTIFY <cJustify> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oStack> := ] TNiceHStack():New( <oParent>, [<cClass>], [<cStyle>], [<.lBold.>], [<cSize>], [<cColor>], [<cGap>], [<cAlign>], [<cJustify>], [<cBgColor>] )

#xcommand END NICE HSTACK =>

#xcommand DEFINE NICE VSTACK [ <oStack> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ GAP <cGap> ] ;
    [ ALIGN <cAlign> ] ;
    [ JUSTIFY <cJustify> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oStack> := ] TNiceVStack():New( <oParent>, [<cClass>], [<cStyle>], [<.lBold.>], [<cSize>], [<cColor>], [<cGap>], [<cAlign>], [<cJustify>], [<cBgColor>] )

#xcommand END NICE VSTACK =>

#xcommand DEFINE NICE GRID [ <oGrid> ] ;
    [ COLS <nCols> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ GAP <cGap> ] ;
    [ ALIGN <cAlign> ] ;
    [ JUSTIFY <cJustify> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oGrid> := ] TNiceGrid():New( <oParent>, [<nCols>], [<cClass>], [<cStyle>], [<.lBold.>], [<cSize>], [<cColor>], [<cGap>], [<cAlign>], [<cJustify>], [<cBgColor>] )

#xcommand END NICE GRID =>

#xcommand DEFINE NICE TABS <oTabs> [ <lVertical: VERTICAL> ] [ OF <oParent> ] ;
    => ;
    <oTabs> := TNiceTabs():New( <oParent>, <.lVertical.> )

#xcommand DEFINE NICE TAB [ <oTab> ] TITLE <cTitle> [ ICON <cIcon> ] [ OF <oTabs> ] ;
    => ;
    [ <oTab> := ] TNiceTab():New( <oTabs>, <cTitle>, [<cIcon>] )

#xcommand DEFINE NICE EXPANSION [ <oExp> ] [ PROMPT <cLabel> ] [ ICON <cIcon> ] [ OF <oParent> ] ;
    => ;
    [ <oExp> := ] TNiceExpansionItem():New( <oParent>, <cLabel>, [<cIcon>] )

#xcommand NICE BUTTON [ <oBtn> ] PROMPT <cPrompt> ;
    [ OF <oParent> ] ;
    [ ACTION <uAction> ] ;
    [ JS <cJs> ] ;
    [ ICON <cIcon> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oBtn> := ] TNiceButton():New( <oParent>, <cPrompt>, [<{uAction}>], [<cIcon>], [<cClass>], [<cStyle>], [<cJs>], [<.lBold.>], [<cSize>], [<cColor>], [<cBgColor>] )

#xcommand NICE GET [ <oInput> ] PROMPT <cLabel> ;
    [ VALUE <cValue> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oInput> := ] TNiceInput():New( <oParent>, <cLabel>, [<cValue>], [<cClass>], [<cStyle>], [<.lBold.>], [<cSize>], [<cColor>], [<cBgColor>] )

#xcommand DEFINE NICE DIALOG <oDlg> OF <oPage> ;
    => ;
    <oDlg> := TNiceDialog():New( <oPage> )

#xcommand NICE SHOW DIALOG <oDlg> => <oDlg>:Show()
#xcommand NICE HIDE DIALOG <oDlg> => <oDlg>:Hide()

#xcommand DEFINE NICE TABLE <oTbl> TITLE <cTitle> OF <oParent> ;
    => ;
    <oTbl> := TNiceTable():New( <oParent>, <cTitle> )

#xcommand NICE ADD COL TO <oTbl> NAME <cName> LABEL <cLabel> FIELD <cField> ;
    [ WIDTH <cWidth> ] ;
    [ <lEdit: EDITABLE> ] ;
    => ;
    <oTbl>:AddCol( <cName>, <cLabel>, <cField>, [<cWidth>], <.lEdit.> )

#xcommand NICE SET DATA OF <oTbl> TO <aData> ;
    => ;
    <oTbl>:SetData( <aData> )

#xcommand NICE SAY [ <oSay> ] PROMPT <cText> ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oSay> := ] TNiceLabel():New( <oParent>, <cText>, [<cClass>], [<cStyle>], [<.lBold.>], [<cSize>], [<cColor>], [<cBgColor>] )

#xcommand NICE ICON [ <oIco> ] NAME <cName> ;
    [ SIZE <cSize> ] ;
    [ COLOR <cColor> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    [ <lBold: BOLD> ] ;
    [ SIZEATTR <cSizeAttr> ] ;
    [ COLORATTR <cColorAttr> ] ;
    [ BGCOLOR <cBgColor> ] ;
    => ;
    [ <oIco> := ] TNiceIcon():New( <oParent>, <cName>, [<cSize>], [<cColor>], [<cClass>], [<cStyle>], [<.lBold.>], [<cSizeAttr>], [<cColorAttr>], [<cBgColor>] )

#xcommand NICE DROPDOWN [ <oSelect> ] ;
    PROMPT <cLabel> ;
    [ VALUE <cValue> ] ;
    [ ITEMS <aOptions> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oSelect> := ] TNiceSelect():New( <oParent>, , <cLabel>, <cValue>, <aOptions>, [<cClass>], [<cStyle>] )

#xcommand NICE TOGGLE [ <oCheck> ] ;
    PROMPT <cLabel> ;
    [ VALUE <lValue> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oCheck> := ] TNiceCheckbox():New( <oParent>, , <cLabel>, <lValue>, [<cClass>], [<cStyle>] )

#xcommand NICE DATEPICKER [ <oDate> ] ;
    PROMPT <cLabel> ;
    [ VALUE <dValue> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oDate> := ] TNiceDate():New( <oParent>, , <cLabel>, <dValue>, [<cClass>], [<cStyle>] )

#xcommand NICE BADGE [ <oBadge> ] PROMPT <cLabel> ;
    [ COLOR <cColor> ] ;
    [ TEXT COLOR <cTextColor> ] ;
    [ <lFloating: FLOATING> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oBadge> := ] TNiceBadge():New( <oParent>, , <cLabel>, <cColor>, <cTextColor>, <.lFloating.>, [<cClass>], [<cStyle>] )

#xcommand NICE CHIP [ <oChip> ] PROMPT <cLabel> ;
    [ ICON <cIcon> ] ;
    [ COLOR <cColor> ] ;
    [ TEXT COLOR <cTextColor> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oChip> := ] TNiceChip():New( <oParent>, , <cLabel>, <cIcon>, <cColor>, <cTextColor>, [<cClass>], [<cStyle>] )

#xcommand NICE PROGRESS [ <oProg> ] ;
    [ VALUE <nValue> ] ;
    [ COLOR <cColor> ] ;
    [ SIZE <nSize> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oProg> := ] TNiceProgress():New( <oParent>, , <nValue>, <cColor>, <nSize>, [<cClass>], [<cStyle>] )

#xcommand DEFINE NICE CHART [ <oChart> ] ;
    [ WIDTH <nWidth> ] ;
    [ HEIGHT <nHeight> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oChart> := ] TNiceChart():New( <oParent>, , [<nWidth>], [<nHeight>], [<cClass>], [<cStyle>] )

#xcommand NICE CHART <oChart> SET TITLE <cTitle> ;
    => ;
    <oChart>:SetTitle( <cTitle> )

#xcommand NICE CHART <oChart> SET XAXIS DATA <aData> ;
    => ;
    <oChart>:SetXAxis( <aData> )

#xcommand NICE CHART <oChart> ADD SERIES DATA <aData> ;
    [ TYPE <cType> ] ;
    [ <lSmooth: SMOOTH> ] ;
    [ <lArea: AREA> ] ;
    => ;
    <oChart>:AddSeries( <aData>, [<cType>], [<.lSmooth.>], [<.lArea.>] )

#xcommand END NICE CHART =>

#xcommand NICE CHART [ <oChart> ] ;
    OPTIONS <cOptions> ;
    [ WIDTH <nWidth> ] ;
    [ HEIGHT <nHeight> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oChart> := ] TNiceChart():New( <oParent>, <cOptions>, [<nWidth>], [<nHeight>], [<cClass>], [<cStyle>] )

#xcommand NICE SLIDER [ <oSlider> ] ;
    [ VALUE <nValue> ] ;
    [ MIN <nMin> ] ;
    [ MAX <nMax> ] ;
    [ STEP <nStep> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oSlider> := ] TNiceSlider():New( <oParent>, , <nValue>, <nMin>, <nMax>, <nStep>, [<cClass>], [<cStyle>] )

#xcommand DEFINE NICE STEPPER [ <oStepper> ] ;
    [ VALUE <nValue> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oStepper> := ] TNiceStepper():New( <oParent>, <nValue>, [<cClass>], [<cStyle>] )

#xcommand DEFINE NICE STEP [ <oStep> ] ;
    STEP <nStep> ;
    TITLE <cTitle> ;
    [ ICON <cIcon> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oStepper> ] ;
    => ;
    [ <oStep> := ] TNiceStep():New( <oStepper>, <nStep>, <cTitle>, [<cIcon>], [<cClass>], [<cStyle>] )

#xcommand END NICE STEP =>
#xcommand END NICE STEPPER =>

#xcommand NICE STEPPER <oStepper> NEXT     => <oStepper>:Next()
#xcommand NICE STEPPER <oStepper> PREVIOUS => <oStepper>:Previous()

//----------------------------------------------------------------------------//
// Nice Printer Commands
//----------------------------------------------------------------------------//

#xcommand DEFINE NICE PRINTER [ <oPrn> ] ;
    [ FORMAT <cFormat> ] ;
    [ <lLandscape: LANDSCAPE> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oPrn> := ] TNicePrinter():New( <oParent>, [<cFormat>], [<.lLandscape.>] )

#xcommand NICE PRINT PAGE [ <oPage> ] OF <oPrn> ;
    => ;
    [ <oPage> := ] TNicePrintPage():New( <oPrn> )

#xcommand END NICE PRINT PAGE =>
#xcommand END NICE PRINTER =>

#xcommand NICE PRINT BUTTON [ <oBtn> ] ;
    [ PROMPT <cLabel> ] ;
    [ CLASS <cClass> ] ;
    [ STYLE <cStyle> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oBtn> := ] TNicePrintButton():New( <oParent>, [<cLabel>], [<cClass>], [<cStyle>] )
