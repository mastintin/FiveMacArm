import SwiftUI
import Speech
import AVFoundation
import HarbourMacro

@HarbourBridge
@objc(SwiftSpeechManager)
public class SwiftSpeechManager: NSObject {
    
    @objc public static let shared = SwiftSpeechManager()
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var localeIdentifier: String?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioRecorder: AVAudioRecorder?
    private let audioEngine = AVAudioEngine()
    
    // Callbacks to Harbour/ObjC
    @objc public var onTranscription: ((String, Bool) -> Void)?
    @objc public var onVocalMetrics: ((Double, Double, Double) -> Void)?
    @objc public var onError: ((String) -> Void)?
    
    @objc(start)
    public func start() {
        if recognitionTask != nil {
            stop()
        }
        
        do {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                OperationQueue.main.addOperation {
                    switch authStatus {
                        case .authorized:
                            print("Speech Recognition Authorized")
                        default:
                            let msg = "Speech Recognition Denied: \(authStatus)"
                            print(msg)
                            self.onError?(msg)
                    }
                }
            }
            
            let targetLocale = resolveLocale()
            print("Speech: Initializing recognizer with locale: \(targetLocale.identifier)")
            speechRecognizer = SFSpeechRecognizer(locale: targetLocale)
            
            guard let recognizer = speechRecognizer, recognizer.isAvailable else {
                let msg = "Speech Recognizer not available for locale \(targetLocale.identifier)"
                self.onError?(msg)
                return
            }
            
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = false 
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    let text = result.bestTranscription.formattedString
                    isFinal = result.isFinal
                    self.onTranscription?(text, isFinal)
                    
                    if let metrics = result.speechRecognitionMetadata?.voiceAnalytics {
                        let pitch = self.average(metrics.pitch.acousticFeatureValuePerFrame)
                        let jitter = self.average(metrics.jitter.acousticFeatureValuePerFrame)
                        let shimmer = self.average(metrics.shimmer.acousticFeatureValuePerFrame)
                        self.onVocalMetrics?(pitch, jitter, shimmer)
                    }
                }
                
                if error != nil || isFinal {
                    self.stop()
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
        } catch {
            self.onError?("Speech Start Error: \(error.localizedDescription)")
        }
    }
    
    @objc(recordToFile:)
    public func recordToFile(_ path: String) {
        let url = URL(fileURLWithPath: path)
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            print("Recording started to: \(path)")
        } catch {
            self.onError?("Record to file error: \(error.localizedDescription)")
        }
    }

    @objc(stopRecording)
    public func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        print("Recording stopped.")
    }

    @objc(transcribeFile:)
    public func transcribeFile(_ path: String) {
        let url = URL(fileURLWithPath: path)
        let targetLocale = resolveLocale()
        
        print("Swift: Starting file transcription for: \(path) with locale \(targetLocale.identifier)")
        
        guard let recognizer = SFSpeechRecognizer(locale: targetLocale), recognizer.isAvailable else {
            self.onError?("Recognizer not available for file transcription (\(targetLocale.identifier))")
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = true
        
        self.recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                print("Swift: File Transcription progress: \(transcription)")
                self.onTranscription?(transcription, result.isFinal)
            }
            
            if let error = error {
                print("Swift: File transcription error: \(error.localizedDescription)")
                self.onError?("File transcription error: \(error.localizedDescription)")
            }
            
            if error != nil || (result?.isFinal ?? false) {
                print("Swift: File transcription finished.")
                self.recognitionTask = nil
            }
        }
    }

    @objc(stop)
    public func stop() {
        if audioEngine.isRunning {
             audioEngine.stop()
             audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }
    
    private func resolveLocale() -> Locale {
        if let customId = localeIdentifier {
            return Locale(identifier: customId)
        }
        return Locale.current
    }

    private func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0.0 }
        return values.reduce(0, +) / Double(values.count)
    }

    @objc(setLocale:)
    public func setLocale(_ identifier: String) {
        self.localeIdentifier = identifier
        self.speechRecognizer = nil 
    }
}
