
#include "FiveMac.ch"

function Main()
    local oWnd, oSpeech := TSwiftSpeech():New()
    local oBtnRecord, oBtnStop, oBtnSelect, oBtnTranscribe
    local oEditor
    local cFile := hb_GetEnv( "HOME" ) + "/Desktop/test_speech.m4a"
    local lRecording := .f.

    DEFINE WINDOW oWnd TITLE "Speech File Recording & Transcription"  NOFLIPPED ;
        SIZE 600, 500 GLASS 
    
    @ 20, 20 SAY "Multi-line Transcription:" OF oWnd
    
    oEditor := TSwiftTextEditor():New( 50, 20, 560, 300, "Result transcription will appear here...", oWnd )

    @ 370, 20 BUTTON oBtnRecord PROMPT "Start Recording" SIZE 150, 30 OF oWnd ;
        ACTION ( oSpeech:RecordToFile( cFile ), ;
        oBtnRecord:Disable(), oBtnStop:Enable(), lRecording := .t., ;
        MsgInfo( "Recording to: " + cFile ) )

    @ 370, 180 BUTTON oBtnStop PROMPT "Stop Recording" SIZE 150, 30 OF oWnd ;
        ACTION ( oSpeech:StopRecording(), ;
        oBtnRecord:Enable(), oBtnStop:Disable(), lRecording := .f., ;
        MsgInfo( "Recording saved." ) )
    oBtnStop:Disable()

    @ 410, 20 BUTTON oBtnSelect PROMPT "Select Audio File" SIZE 150, 30 OF oWnd ;
        ACTION ( cFile := AppChooseFile(), ;
        if( !Empty( cFile ), MsgInfo( "Selected: " + cFile ), ) )

    @ 410, 180 BUTTON oBtnTranscribe PROMPT "Transcribe Selected File" SIZE 200, 30 OF oWnd ;
        ACTION ( if( !Empty( cFile ) .and. File( cFile ), ;
        ( oEditor:SetText( "Transcribing... " + cFile ), ;
        oSpeech:TranscribeFile( cFile ) ), ;
        MsgAlert( "File not found: " + cFile ) ) )

    oSpeech:SetLocale( "es-ES" )
    
    oSpeech:SetOnTranscription( { | cTxt, lFinal | ;
        oEditor:SetText( cTxt ), ;
        if( lFinal, MsgInfo( "Texto final recibido!" ), ) } )
    
    oSpeech:SetOnError( { | cErr | MsgAlert( "Error de voz: " + cErr ) } )

    ACTIVATE WINDOW oWnd CENTERED

return nil

function AppChooseFile()
    local cFile := cGetFile( "Audio Files (*.m4a, *.wav, *.mp3) | *.m4a;*.wav;*.mp3", "Select Audio File" )
return cFile
