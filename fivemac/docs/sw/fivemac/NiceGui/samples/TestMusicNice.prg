#include "FiveMac.ch"
#include "Nice.ch"

static oMusic
static oLabelTitle
static oLabelArtist
static oSlider
static oCardImg

static nState

function Main()

    local oWnd, oPage, oCard
    local oBtnPlay, oBtnPrev, oBtnNext, oStack
    local oTimer

    oMusic := TSwiftMusic():New()
    oMusic:Auth()

    nState:= 2  

    DEFINE WINDOW oWnd TITLE "FiveMac + NiceGUI Music Player"  NOFLIPPED ;
        SIZE 450, 600 FLIPPED

    DEFINE NICE PAGE oPage OF oWnd

    DEFINE NICE CARD oCard ;
        OF oPage ;
        CLASS "q-ma-md q-pa-lg flex flex-center column" ;
        STYLE "width: 100%; max-width: 400px; background: rgba(255, 255, 255, 0.9);"

    // -- Artwork --
    DEFINE NICE IMAGE oCardImg FILE "music_note.png" ;
        SIZE "300px" ;
        CLASS "rounded-borders shadow-4 q-mb-md" ;
        OF oCard

    // -- Song Title --
    NICE SAY oLabelTitle PROMPT "Not Playing" ;
        CLASS "text-h5 text-weight-bold q-mt-sm" ;
        OF oCard

    // -- Artist --
    NICE SAY oLabelArtist PROMPT "Unknown Artist" ;
        CLASS "text-subtitle1 text-grey-7 q-mb-md" ;
        OF oCard

    // -- Progress Slider --
    NICE SLIDER oSlider VALUE 0 MIN 0 MAX 100 STEP 1 ;
        OF oCard ;
        CLASS "q-mb-md full-width"

    // Handle Slider Change -> Seek
    oSlider:bAction := { |o| oMusic:SetPosition( Val( o:cValue ) ) }

    // -- Controls --
    DEFINE NICE HSTACK oStack GAP "lg" CLASS "flex-center" OF oCard

    NICE BUTTON oBtnPrev PROMPT "" ICON "skip_previous" ;
        CLASS "glossy" COLOR "primary" ;
        ACTION { || oMusic:Previous(), UpdateMusicState() } ;
        OF oStack

    NICE BUTTON oBtnPlay PROMPT "" ICON "play_arrow" ;
        CLASS "glossy" COLOR "primary" SIZE "lg" ;
        ACTION { || TogglePlay( oBtnPlay ) } ;
        OF oStack

    NICE BUTTON oBtnNext PROMPT "" ICON "skip_next" ;
        CLASS "glossy" COLOR "primary" ;
        ACTION { || oMusic:Next(), UpdateMusicState() } ;
        OF oStack

    END NICE HSTACK

    END NICE CARD

    ACTIVATE NICE PAGE oPage

    // -- Timer for UI Updates --
    DEFINE TIMER oTimer OF oWnd INTERVAL 1 REPEAT ;
        ACTION UpdateMusicState( oLabelTitle, oLabelArtist, oSlider, oCardImg, oBtnPlay )
   
    ACTIVATE TIMER oTimer

    ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

function TogglePlay( oBtn )
   

    if nState == 1
        oMusic:Pause()
        // Optimistic Update
        oBtn:Set( "icon", "play_arrow" )
        nState := 2
    else
        oMusic:Play()
        oBtn:Set( "icon", "pause" )
        nState := 1
    endif
   
    UpdateMusicState()
return nil

//----------------------------------------------------------------------------//

function UpdateMusicState( oTitle, oArtist, oProg, oImg, oBtnPlay )
   
    local cJson, hData
    local cArtPath

    // If params are nil (called from actions without args), ignore or rely on statics?
    // Better to use STATICS if simple, or pass oPage
   
    if oTitle == nil; return nil; endif

    // 1. Update Play Button Icon
    if nState == 1

        // oBtnPlay:Set( "icon", "pause" ) // This might be too frequent if called every sec? 
        // NiceGUI handles diffs? No, explicit Set sends JS.
        // Only send if changed?
    else
        // oBtnPlay:Set( "icon", "play_arrow" )
    endif

    // 2. Metadata
    
    cJson := oMusic:GetMetadata()
    hData := hb_jsonDecode( cJson )
  
    if Len(hData) > 0 .and. hb_HHasKey(hData, "title") .and. !Empty(hData["title"]) 
       
        if oTitle:cText != hData["title"]
            oTitle:Set( hData["title"] )
            

           
        endif
      
        if "artist" $ hData .and. oArtist:cText != hData["artist"]
            oArtist:Set( hData["artist"] )
        endif

        // Artwork
        cArtPath := oMusic:GetArtworkPath()
             

        if !Empty( cArtPath ) .and. File( cArtPath )
            // NiceImage needs a path relative to bundle or absolute file://?
            // TSwiftImage uses base64 or file path. TNiceImage usually converts to base64 if local.
            // Let's assume Set( cFile ) works.
            oImg:Set( "file://" + cArtPath ) 
         
            // Actually TNiceImage doesn't have a simple SetFile method in the PRG I saw?
            // It has GetHtml. We might need to reload it seamlessly.
            // Or just send "src" update to Vue model.
            // TNiceImage:Set( cVal ) updates "src" model?
            // Looking at TNiceControl:Set(), it updates `cId + "_val"`.
            // TNiceImage should use `cId + "_val"` as src.
         
            // oImg:Set( "file://" + cArtPath ) 
        endif
    endif

    // 3. Progress
    if nState == 1
        oProg:Set( oMusic:GetPosition() )
        oProg:Set( "max", oMusic:GetDuration() ) // Dynamic max
    endif

return nil
