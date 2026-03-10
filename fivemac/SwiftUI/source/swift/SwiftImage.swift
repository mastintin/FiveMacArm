import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class SwiftImageState {
    var systemName: String
    var name: String
    var filePath: String
    var resizable: Bool
    var contentMode: Int // 0: fit, 1: fill
    var foregroundColor: Color?
    var image: NSImage?
    
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

struct SwiftImageView: View {
    var state: SwiftImageState
    var callback: (() -> Void)?
    
    var body: some View {
        Group {
            if let img = state.image {
                Image(nsImage: img)
                    .if(state.resizable) { $0.resizable() }
            } else if !state.systemName.isEmpty {
                Image(systemName: state.systemName)
                    .if(state.resizable) { $0.resizable() }
            } else if !state.filePath.isEmpty {
                if let img = NSImage(contentsOfFile: state.filePath) {
                     Image(nsImage: img)
                        .if(state.resizable) { $0.resizable() }
                } else {
                     Image(nsImage: NSImage(byReferencingFile: state.filePath) ?? NSImage())
                        .if(state.resizable) { $0.resizable() }
                }
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

@objc(SwiftImageLoader)
public class SwiftImageLoader: NSObject {
    
    public static var states: [String: SwiftImageState] = [:]

    @objc(makeImageWithSystemName:index:callback:)
    public static func makeImage(systemName: String, index: String, callback: ((String) -> Void)?) -> NSView {
         let state = SwiftImageState(systemName: systemName)
         states[index] = state
         
         let action: () -> Void = {
             _ = callback?("Click")
         }
         
         let view = SwiftImageView(state: state, callback: action)
         
         if let intIndex = Int(index) {
             ViewRegistry.register(view, for: intIndex)
         }

         let hostingView = NSHostingView(rootView: view)
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         return hostingView
    }
}

// --- HARBOUR BRIDGE MACROS ---

@HarbourBridge
public func img_set_system_name(id: String, name: String) {
    DispatchQueue.main.async {
        if let state = SwiftImageLoader.states[id] {
            state.systemName = name
            state.name = ""
            state.filePath = ""
            state.image = nil
        }
    }
}

@HarbourBridge
public func img_set_name(id: String, name: String) {
    DispatchQueue.main.async {
        if let state = SwiftImageLoader.states[id] {
            state.name = name
            state.systemName = ""
            state.filePath = ""
            state.image = nil
        }
    }
}

@HarbourBridge
public func img_set_file(id: String, path: String) {
    DispatchQueue.main.async {
        if let state = SwiftImageLoader.states[id] {
            if let img = NSImage(contentsOfFile: path) {
                state.image = img
            } else {
                state.filePath = path
                state.image = nil
            }
            state.systemName = ""
            state.name = ""
        }
    }
}

@HarbourBridge
public func img_set_color(id: String, hexColor: String) {
    DispatchQueue.main.async {
        if let state = SwiftImageLoader.states[id] {
            state.foregroundColor = Color(hex: hexColor)
        }
    }
}

@HarbourBridge
public func img_set_resizable(id: String, resizable: String) {
    let isResizable = (resizable == "1" || resizable.lowercased() == "true")
    DispatchQueue.main.async {
        if let state = SwiftImageLoader.states[id] {
            state.resizable = isResizable
        }
    }
}

@HarbourBridge
public func img_set_aspect_ratio(id: String, mode: String) {
    let nMode = Int(mode) ?? 0
    DispatchQueue.main.async {
        if let state = SwiftImageLoader.states[id] {
            state.contentMode = nMode
        }
    }
}

@objc(SwiftImageActions)
public class SwiftImageActions: NSObject {
    @objc public static func setImageObj(index: String, image: NSImage) {
        DispatchQueue.main.async {
            if let state = SwiftImageLoader.states[index] {
                state.image = image
                state.systemName = ""
                state.name = ""
                state.filePath = ""
            }
        }
    }
}

