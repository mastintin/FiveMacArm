#include "FiveMac.ch"

static oSpeechManager

CLASS TSwiftSpeech
    DATA bOnTranscription
    DATA bOnMetrics
    DATA bOnError

    METHOD New() CONSTRUCTOR
    METHOD Start()
    METHOD Stop()
    METHOD End() 

    METHOD SetOnTranscription( bCB ) INLINE ::bOnTranscription := bCB
    METHOD SetOnMetrics( bCB )       INLINE ::bOnMetrics := bCB
    METHOD SetOnError( bCB )         INLINE ::bOnError := bCB
    METHOD SetLocale( cId )          INLINE SD_SPEECH_SET_LOCALE( cId )
    
    METHOD RecordToFile( cPath )     INLINE SD_SPEECH_RECORD_FILE( cPath )
    METHOD StopRecording()           INLINE SD_SPEECH_STOP_RECORDING()
    METHOD TranscribeFile( cPath )   INLINE SD_SPEECH_TRANSCRIBE_FILE( cPath )

ENDCLASS

METHOD New() CLASS TSwiftSpeech
    oSpeechManager := Self
return Self

METHOD Start() CLASS TSwiftSpeech
    SD_SPEECH_START()
return nil

METHOD Stop() CLASS TSwiftSpeech
    SD_SPEECH_STOP()
return nil

METHOD End() CLASS TSwiftSpeech
    oSpeechManager := nil
return nil

// --- GLOBAL CALLBACK ROUTING ---

function SwiftSpeechOnTranscription( cText, lFinal )
    if oSpeechManager != nil .and. oSpeechManager:bOnTranscription != nil
        Eval( oSpeechManager:bOnTranscription, cText, lFinal )
    endif
return nil

function SwiftSpeechOnMetrics( nPitch, nJitter, nShimmer )
    if oSpeechManager != nil .and. oSpeechManager:bOnMetrics != nil
        Eval( oSpeechManager:bOnMetrics, nPitch, nJitter, nShimmer )
    endif
return nil

function SwiftSpeechOnError( cError )
    if oSpeechManager != nil .and. oSpeechManager:bOnError != nil
        Eval( oSpeechManager:bOnError, cError )
    endif
return nil
