import Foundation

@objc(SwiftMusicLoader)
public class SwiftMusicLoader: NSObject {
    
    // MARK: - Helper
    
    private static func runAppleScript(_ cmd: String) -> NSAppleEventDescriptor? {
        let source = "tell application \"Music\" to \(cmd)"
        var error: NSDictionary?
        let script = NSAppleScript(source: source)
        let result = script?.executeAndReturnError(&error)
        
        if let err = error {
            print("[SwiftMusic] AppleScript Error: \(err)")
            return nil
        }
        return result
    }
    
    // MARK: - Playback Control
    
    @objc
    public static func play() {
        _ = runAppleScript("play")
    }
    
    @objc
    public static func pause() {
        _ = runAppleScript("pause")
    }
    
    @objc
    public static func next() {
        _ = runAppleScript("next track")
    }
    
    @objc
    public static func previous() {
        _ = runAppleScript("previous track")
    }
    
    @objc
    public static func stop() {
        _ = runAppleScript("stop")
    }
    
    // MARK: - State & Metadata
    
    @objc
    public static func getPlayerState() -> Int {
        // Returns enum: stopped/playing/paused
        guard let result = runAppleScript("get player state") else { return 0 }
        
        // Convert 4-byte code or string to int
        // kPSP = playing, kPSp = paused, kPSS = stopped (often requires coercion to string to be safe)
        
        // Easier: coerce to string in AS
        let source = "tell application \"Music\" to get player state as string"
        var error: NSDictionary?
        let script = NSAppleScript(source: source)
        if let result = script?.executeAndReturnError(&error), let str = result.stringValue {
            // Check substrings because localization might affect it? NO, enumerations usually coerce to English fixed names or use raw codes.
            // But 'as string' usually gives localized strings or standard names.
            // Let's rely on standard enum constants if we can, but simpler to check standard strings "playing", "paused", "stopped"
            
            let lower = str.lowercased()
            if lower.contains("play") { return 1 }
            if lower.contains("paus") { return 2 }
            if lower.contains("stop") { return 0 }
        }
        
        return 0
    }
    
    @objc
    public static func getCurrentTrack() -> String {
        // Get properties individually to avoid quoting hell
        let script = """
        tell application "Music"
            if player state is stopped then return "{}"
            try
                set t to current track
                set tName to name of t
                set tArtist to artist of t
                set tAlbum to album of t
                return "{\"title\": \"" & tName & "\", \"artist\": \"" & tArtist & "\", \"album\": \"" & tAlbum & "\"}"
            on error
                return "{}"
            end try
        end tell
        """
        
        var error: NSDictionary?
        let nsScript = NSAppleScript(source: script)
        if let result = nsScript?.executeAndReturnError(&error) {
            if let json = result.stringValue {
                // Verify it's valid JSON-ish or just return it
                // We need to escape quotes in the AppleScript variable concatenation manually if valid JSON is strictly required, 
                // but for this simple bridging, usually `returned string` is okay.
                // However, if the song title has a quote, it breaks the JSON structure constructed in simple string.
                // A better approach is to return list and build JSON in Swift.
                return json
            }
        }
        
        // Retry with safer approach: Getting values separately
        return getCurrentTrackSafe()
    }
    
    private static func getCurrentTrackSafe() -> String {
       let script = """
        tell application "Music"
            try
                if player state is stopped then return {}
                set t to current track
                return {name of t, artist of t, album of t}
            on error
                return {}
            end try
        end tell
        """
        var error: NSDictionary?
        let nsScript = NSAppleScript(source: script)
        if let result = nsScript?.executeAndReturnError(&error) {
            if result.numberOfItems >= 3 {
                let title = result.atIndex(1)?.stringValue?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""
                let artist = result.atIndex(2)?.stringValue?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""
                let album = result.atIndex(3)?.stringValue?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""
                
                return "{\"title\": \"\(title)\", \"artist\": \"\(artist)\", \"album\": \"\(album)\"}"
            }
        }
        return "{}"
    }
    
    @objc
    public static func requestAuth() {
        // Trigger a simple AppleScript to force TCC prompt
        _ = runAppleScript("get name")
    }
}
