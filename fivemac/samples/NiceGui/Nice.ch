// Nice.ch - Preprocessor commands for NiceGUI Framework

#xcommand DEFINE NICE PAGE <oPage> [ OF <oParent> ] ;
    => ;
    <oPage> := TNicePage():New( <oParent> )

#xcommand ACTIVATE NICE PAGE <oPage> ;
    => ;
    <oPage>:Activate()

#xcommand DEFINE NICE CARD <oCard> OF <oParent> ;
    => ;
    <oCard> := TNiceCard():New( <oParent> )

#xcommand DEFINE NICE HSTACK <oStack> OF <oParent> ;
    => ;
    <oStack> := TNiceHStack():New( <oParent> )

#xcommand DEFINE NICE VSTACK <oStack> OF <oParent> ;
    => ;
    <oStack> := TNiceVStack():New( <oParent> )

#xcommand NICE BUTTON [<oBtn>] PROMPT <cPrompt> ;
    [ OF <oParent> ] ;
    [ ACTION <uAction> ] ;
    [ ICON <cIcon> ] ;
    => ;
    [ <oBtn> := ] TNiceButton():New( <oParent>, <cPrompt>, [<{uAction}>], [<cIcon>] )

#xcommand NICE GET [<oInput>] PROMPT <cLabel> ;
    [ VALUE <cValue> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oInput> := ] TNiceInput():New( <oParent>, <cLabel>, [<cValue>] )

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
    => ;
    <oTbl>:AddCol( <cName>, <cLabel>, <cField>, [<cWidth>] )

#xcommand NICE SET DATA OF <oTbl> TO <aData> ;
    => ;
    <oTbl>:SetData( <aData> )

#xcommand NICE SAY [<oSay>] PROMPT <cText> ;
    [ CLASS <cClass> ] ;
    [ OF <oParent> ] ;
    => ;
    [ <oSay> := ] TNiceLabel():New( <oParent>, <cText>, [<cClass>] )
