import Foundation
import Combine

@available(macOS 12.0, *)
@objc(SwiftMusicLoader)
public class SwiftMusicLoader: NSObject {
    
    // MARK: - Helpers
    
    private static func runScript(_ source: String) -> String {
        var error: NSDictionary?
        let script = NSAppleScript(source: "tell application \"Music\" to " + source)
        let output = script?.executeAndReturnError(&error)
        
        if let err = error {
            print("[SwiftMusic] Error: \(err)")
            return ""
        }
        
        return output?.stringValue ?? ""
    }
    
    // MARK: - Auth
    
    @objc
    public static func requestAuth() {
        print("[SwiftMusic] Requesting TCC via AppleScript...")
        // Simple command to trigger "FiveMac wants to control Music" prompt
        _ = runScript("get player state")
    }
    
    // MARK: - Playback
    
    @objc
    public static func play() {
        print("[SwiftMusic] Play")
        // Try to play; if empty, it might do nothing, but usually Music plays *something*
        _ = runScript("play")
    }
    
    @objc
    public static func pause() {
        print("[SwiftMusic] Pause")
        _ = runScript("pause")
    }
    
    @objc
    public static func next() {
        print("[SwiftMusic] Next")
        _ = runScript("next track")
    }
    
    @objc
    public static func previous() {
        print("[SwiftMusic] Previous")
        _ = runScript("previous track")
    }
    
    @objc
    public static func stop() {
        _ = runScript("stop")
    }
    
    // MARK: - State/Metadata
    
    @objc
    public static func getState() -> Int {
        let state = runScript("get player state").lowercased()
        if state == "playing" { return 1 }
        if state == "paused" { return 2 }
        return 0 // stopped
    }
    
    @objc
    public static func getCurrentTrack() -> String {
        // Safe JSON construction via multiple calls to avoid string escaping hell in AS
        // Or specific AS to build JSON
        let script = """
        try
            set t to current track
            set tName to name of t
            set tArtist to artist of t
            set tAlbum to album of t
            return "{\\"title\\": \\"" & tName & "\\", \\"artist\\": \\"" & tArtist & "\\", \\"album\\": \\"" & tAlbum & "\\"}"
        on error
            return "{}"
        end try
        """
        return runScript(script)
    }
    
    // MARK: - Advanced Features
    
    @objc
    public static func getArtworkPath() -> String {
        let path = "/tmp/fivemac_cover.jpg"
        // Based on native implementation which uses 'raw data'
        let script = """
        tell application "Music"
            try
                if exists (artwork 1 of current track) then
                    set d to raw data of artwork 1 of current track
                    set f to open for access (POSIX file "\(path)") with write permission
                    set eof f to 0
                    write d to f
                    close access f
                    return "\(path)"
                else
                    return ""
                end if
            on error err
                try
                    close access (POSIX file "\(path)")
                end try
                return "ERROR: " & err
            end try
        end tell
        """
        let res = runScript(script)
        // print("[SwiftMusic] getArtworkPath result: \(res)")
        if res.starts(with: "ERROR") { return "" }
        return res
    }
    
    @objc
    public static func getDuration() -> Double {
        let res = runScript("get duration of current track") // Returns seconds (real)
        return Double(res) ?? 0.0
    }
    
    @objc
    public static func getPosition() -> Double {
        let res = runScript("get player position") // Returns seconds (real)
        return Double(res) ?? 0.0
    }
    
    @objc
    public static func setPosition(seconds: Double) {
        _ = runScript("set player position to \(seconds)")
    }
    
    @objc
    public static func getVolume() -> Int {
        let res = runScript("get sound volume") // 0-100
        return Int(res) ?? 50
    }
    
    @objc
    public static func setVolume(vol: Int) {
        _ = runScript("set sound volume to \(vol)")
    }
}
