import SwiftUI
import AppKit

@available(OSX 10.15, *)
class SwiftImageState: ObservableObject {
    @Published var systemName: String
    @Published var name: String
    @Published var filePath: String
    @Published var resizable: Bool
    @Published var contentMode: Int // 0: fit, 1: fill
    @Published var foregroundColor: Color?
    @Published var image: NSImage?
    
    init(systemName: String = "", name: String = "", filePath: String = "", resizable: Bool = true, contentMode: Int = 0, foregroundColor: Color? = nil, image: NSImage? = nil) {
        self.systemName = systemName
        self.name = name
        self.filePath = filePath
        self.resizable = resizable
        self.contentMode = contentMode
        self.foregroundColor = foregroundColor
        self.image = image
    }
}

@available(OSX 10.15, *)
struct SwiftImageView: View {
    @ObservedObject var state: SwiftImageState
    var callback: (() -> Void)?
    
    var body: some View {
        Group {
            if let img = state.image {
                Image(nsImage: img)
                    .if(state.resizable) { $0.resizable() }
            } else if !state.systemName.isEmpty {
                if #available(OSX 11.0, *) {
                    Image(systemName: state.systemName)
                        .if(state.resizable) { $0.resizable() }
                } else {
                    Text(state.systemName) 
                }
            } else if !state.filePath.isEmpty {
                Image(nsImage: NSImage(byReferencingFile: state.filePath) ?? NSImage())
                     .if(state.resizable) { $0.resizable() }
            } else if !state.name.isEmpty {
                Image(state.name)
                     .if(state.resizable) { $0.resizable() }
            } else {
                Text("No Image")
            }
        }
        .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
        .foregroundColor(state.foregroundColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            self.callback?()
        }
    }
}

@available(OSX 10.15, *)
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

@objc(SwiftImageLoader)
public class SwiftImageLoader: NSObject {
    
    static var lastCreatedState: Any? = nil

    @objc(makeImageWithSystemName:index:callback:)
    public static func makeImage(systemName: String, index: Int, callback: ((String) -> Void)?) -> NSView {
         if #available(OSX 10.15, *) {
             let state = SwiftImageState(systemName: systemName)
             lastCreatedState = state
             
             let action: () -> Void = {
                 _ = callback?("Click")
             }
             
             let view = SwiftImageView(state: state, callback: action)
             
             // Register
             ViewRegistry.register(view, for: index)

             let hostingView = NSHostingView(rootView: view)
             hostingView.translatesAutoresizingMaskIntoConstraints = false
             return hostingView
         } else {
             return NSView()
         }
    }
    
    // Setters
    
    @objc(setImageSystemName:)
    public static func setImageSystemName(_ name: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.systemName = name
                    state.name = ""
                    state.filePath = ""
                    state.image = nil
                }
            }
        }
    }

    @objc(setImageName:)
    public static func setImageName(_ name: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.name = name
                    state.systemName = ""
                    state.filePath = ""
                    state.image = nil
                }
            }
        }
    }

    @objc(setImageFile:)
    public static func setImageFile(_ path: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.filePath = path
                    state.systemName = ""
                    state.name = ""
                    state.image = nil
                }
            }
        }
    }
    
    @objc(setImageColor:)
    public static func setImageColor(_ colorHex: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.foregroundColor = Color(hexImg: colorHex)
                }
            }
        }
    }
    
    @objc(setImageResizable:)
    public static func setImageResizable(_ resizable: NSNumber) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.resizable = resizable.boolValue
                }
            }
        }
    }

    @objc(setImageAspectRatio:)
    public static func setImageAspectRatio(_ mode: NSNumber) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.contentMode = mode.intValue
                }
            }
        }
    }

    @objc(setImageObj:)
    public static func setImageObj(_ image: NSImage) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftImageState {
                    state.image = image
                    state.systemName = ""
                    state.name = ""
                    state.filePath = ""
                }
            }
        }
    }
}

@available(OSX 10.15, *)
extension Color {
    init(hexImg: String) { 
        let hex = hexImg.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: 
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: 
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: 
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
