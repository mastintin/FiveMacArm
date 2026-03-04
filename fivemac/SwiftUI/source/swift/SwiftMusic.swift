import Foundation

@objc(SwiftMusicLoader)
public class SwiftMusicLoader: NSObject {
    
    // MARK: - Helpers
    
    private static func runAppleScript(_ cmd: String) -> String {
        let scriptSource = "tell application \"Music\"\n" + cmd + "\nend tell"
        var error: NSDictionary?
        if let script = NSAppleScript(source: scriptSource) {
            let output = script.executeAndReturnError(&error)
            if let err = error {
                print("[SwiftMusic] AppleScript Error: \(err)")
            }
            return output.stringValue ?? ""
        }
        return ""
    }
    
    // MARK: - Auth
    
    @objc
    public static func requestAuth() {
        print("[SwiftMusic] Requesting Auth via AppleScript...")
        _ = runAppleScript("get player state")
    }
    
    // MARK: - Playback
    
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
    
    // MARK: - State/Metadata
    
    @objc
    public static func getState() -> Int {
        let res = runAppleScript("get player state").lowercased()
        if res == "playing" { return 1 }
        if res == "paused" { return 2 }
        return 0 // stopped
    }
    
    @objc
    public static func getCurrentTrack() -> String {
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
        return runAppleScript(script)
    }
    
    @objc
    public static func getArtworkPath() -> String {
        let path = "/tmp/fivemac_cover.jpg"
        let script = """
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
            return ""
        end try
        """
        return runAppleScript(script)
    }
    
    @objc
    public static func getDuration() -> Double {
        let res = runAppleScript("get duration of current track")
        return Double(res) ?? 0.0
    }
    
    @objc
    public static func getPosition() -> Double {
        let res = runAppleScript("get player position")
        return Double(res) ?? 0.0
    }
    
    @objc
    public static func setPosition(seconds: Double) {
        _ = runAppleScript("set player position to \(seconds)")
    }
    
    @objc
    public static func getVolume() -> Int {
        let res = runAppleScript("get sound volume")
        return Int(res) ?? 50
    }
    
    @objc
    public static func setVolume(vol: Int) {
        _ = runAppleScript("set sound volume to \(vol)")
    }
}
