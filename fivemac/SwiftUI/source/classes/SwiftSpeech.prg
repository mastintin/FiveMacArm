
#include "FiveMac.ch"

CLASS TSwiftSpeech
    DATA bOnTranscription
    DATA bOnMetrics
    DATA bOnError

    METHOD New() CONSTRUCTOR
    METHOD Start()
    METHOD Stop()
    METHOD End() 

    METHOD SetOnTranscription( bCB ) INLINE SWIFTSPEECHSETTRANSCRIPTIONCB( bCB ), ::bOnTranscription := bCB
    METHOD SetOnMetrics( bCB )       INLINE SWIFTSPEECHSETMETRICSCB( bCB ), ::bOnMetrics := bCB
    METHOD SetOnError( bCB )         INLINE SWIFTSPEECHSETERRORCB( bCB ), ::bOnError := bCB
    METHOD SetLocale( cId )          INLINE SWIFTSPEECHSETLOCALE( cId )
    
    METHOD RecordToFile( cPath )     INLINE SWIFTSPEECHRECORDFILE( cPath )
    METHOD StopRecording()           INLINE SWIFTSPEECHSTOPRECORDING()
    METHOD TranscribeFile( cPath )   INLINE SWIFTSPEECHTRANSCRIBEFILE( cPath )

ENDCLASS

METHOD New() CLASS TSwiftSpeech
return Self

METHOD Start() CLASS TSwiftSpeech
    SWIFTSPEECHSTART()
return nil

METHOD Stop() CLASS TSwiftSpeech
    SWIFTSPEECHSTOP()
return nil

METHOD End() CLASS TSwiftSpeech
return nil
