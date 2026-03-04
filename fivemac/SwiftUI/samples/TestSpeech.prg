
#include "FiveMac.ch"
#include "SwiftControls.ch"

function Main()
    local oWnd, oVStack
    local oSpeech := TSwiftSpeech():New()
    local oTranscription, oPitch, oJitter, oShimmer
    local oBtnStart, oBtnStop
    
    DEFINE WINDOW oWnd TITLE "FiveMac Speech Analysis (SwiftUI)" ;
        SIZE 500, 600 GLASS FLIPPED
    
    // Using SwiftUI VStack for a modern layout
    oVStack := TSwiftVStack():New( 0, 0, 500, 600, oWnd )
    oVStack:SetSpacing( 20 )
    
    oSpeech:SetLocale( "es-ES" )
    
    oVStack:AddSystemImage( "mic.circle.fill" ):SetSize( 100, 100 )
    
    oVStack:AddText( "Speech Transcription" ):SetFont( 24, .t. )
    
    oTranscription := oVStack:AddText( "Waiting for speech..." )
    oTranscription:SetColor( 0x555555 )
    
    oVStack:AddDivider()
    
    oVStack:AddText( "Vocal Metrics" ):SetFont( 18, .t. )
    
    oPitch   := oVStack:AddText( "Pitch: 0.0" )
    oJitter  := oVStack:AddText( "Jitter: 0.0" )
    oShimmer := oVStack:AddText( "Shimmer: 0.0" )
    
    oVStack:AddSpacer()
    
    oBtnStart := oVStack:AddButton( "Start Recording" )
    oBtnStart:SetColor( 0xFFFFFF, 0x00AA00 ) // White on Green
    oBtnStart:SetRadius( 10 )
    
    oBtnStop := oVStack:AddButton( "Stop Recording" )
    oBtnStop:SetColor( 0xFFFFFF, 0xAA0000 ) // White on Red
    oBtnStop:SetRadius( 10 )
    
   
    oVStack:bAction := { | cId, oItem | 
    
    if oItem == oBtnStart
        msginfo("strat")
        oSpeech:Start()
    elseif oItem == oBtnStop
        msginfo("stop")
        oSpeech:Stop()
    endif
    return nil
    }
    
    oSpeech:SetOnTranscription( { | cTxt, lFinal |
    oTranscription:SetText( cTxt )
    if lFinal
        // Optional: log or handle final text
    endif
    return nil
    } )
    
    oSpeech:SetOnMetrics( { | nPitch, nJitter, nShimmer |
    oPitch:SetText( "Pitch (Log): " + hb_ntos( nPitch ) )
    oJitter:SetText( "Jitter (%): " + hb_ntos( nJitter ) )
    oShimmer:SetText( "Shimmer (dB): " + hb_ntos( nShimmer ) )
    return nil
    } )

    oSpeech:SetOnError( { | cError |
    MsgAlert( "Speech Error: " + cError )
    return nil
    } )
    
    ACTIVATE WINDOW oWnd CENTERED
    
    oSpeech:Stop()
    
return nil
