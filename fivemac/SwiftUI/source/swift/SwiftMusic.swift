import Foundation
import HarbourMacro

@HarbourBridge
@objc(SwiftMusicLoader)
public class SwiftMusicLoader: NSObject {
    
    // MARK: - Helpers
    
    private static func runAppleScript(_ cmd: String) -> String {
        let scriptSource = """
        if application "Music" is running then
            tell application "Music"
                try
                    \(cmd)
                on error
                    return ""
                end try
            end tell
        else
            return ""
        end if
        """
        var error: NSDictionary?
        if let script = NSAppleScript(source: scriptSource) {
            let output = script.executeAndReturnError(&error)
            if let err = error {
                print("[SwiftMusic] AppleScript Error: \(err)")
                return ""
            }
            return output.stringValue ?? ""
        }
        return ""
    }
    
    // MARK: - Auth
    
    @objc(requestAuth)
    public static func requestAuth() {
        print("[SwiftMusic] Requesting Auth via AppleScript...")
        let scriptSource = "tell application \"Music\" to get player state"
        if let script = NSAppleScript(source: scriptSource) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
    }
    
    // MARK: - Playback
    
    @objc(play)
    public static func play() {
        _ = runAppleScript("play")
    }
    
    @objc(pause)
    public static func pause() {
        _ = runAppleScript("pause")
    }
    
    @objc(next)
    public static func next() {
        _ = runAppleScript("next track")
    }
    
    @objc(previous)
    public static func previous() {
        _ = runAppleScript("previous track")
    }
    
    @objc(stop)
    public static func stop() {
        _ = runAppleScript("stop")
    }
    
    // MARK: - State/Metadata
    
    @objc(getState)
    public static func getState() -> Int {
        let res = runAppleScript("get player state").lowercased()
        if res == "playing" { return 1 }
        if res == "paused" { return 2 }
        return 0 // stopped
    }
    
    @objc(getCurrentTrack)
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
        let res = runAppleScript(script)
        return res.isEmpty ? "{}" : res
    }
    
    @objc(getArtworkPath)
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
    
    @objc(getDuration)
    public static func getDuration() -> Double {
        let res = runAppleScript("get duration of current track")
        return Double(res) ?? 0.0
    }
    
    @objc(getPosition)
    public static func getPosition() -> Double {
        let res = runAppleScript("get player position")
        return Double(res) ?? 0.0
    }
    
    @objc(setPositionWithSeconds:)
    public static func setPosition(seconds: Double) {
        _ = runAppleScript("set player position to \(seconds)")
    }
    
    @objc(getVolume)
    public static func getVolume() -> Int {
        let res = runAppleScript("get sound volume")
        return Int(res) ?? 50
    }
    
    @objc(setVolumeWithVol:)
    public static func setVolume(vol: Int) {
        _ = runAppleScript("set sound volume to \(vol)")
    }
    
    // MARK: - Playlists
    
    @objc(getPlaylists)
    public static func getPlaylists() -> String {
        // We use a custom delimiter to avoid issues with commas in playlist names
        let script = """
        set theNames to name of every playlist
        set AppleScript's text item delimiters to "|"
        return theNames as string
        """
        let res = runAppleScript(script)
        if res.isEmpty { return "[]" }
        
        let names = res.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if let data = try? JSONSerialization.data(withJSONObject: names, options: []),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "[]"
    }
    
    @objc(playPlaylistWithName:)
    public static func playPlaylist(name: String) {
        _ = runAppleScript("play playlist \"\(name)\"")
    }

    @objc(playFirstAvailablePlaylist)
    public static func playFirstAvailablePlaylist() {
        let script = """
        repeat with p in playlists
            if (count of tracks of p) > 0 then
                play p
                return name of p
            end if
        end repeat
        return ""
        """
        _ = runAppleScript(script)
    }
}
