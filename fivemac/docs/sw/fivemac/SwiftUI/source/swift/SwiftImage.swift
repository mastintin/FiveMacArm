import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class SwiftImageState: RGBAColorableState {
    var systemName: String
    var name: String
    var filePath: String
    var resizable: Bool
    var contentMode: Int // 0: fit, 1: fill
    var foregroundColor: Color = .primary
    var image: NSImage?
    
    init(systemName: String = "", name: String = "", filePath: String = "", resizable: Bool = true, contentMode: Int = 0, foregroundColor: Color = .primary, image: NSImage? = nil) {
        self.systemName = systemName
        self.name = name
        self.filePath = filePath
        self.resizable = resizable
        self.contentMode = contentMode
        self.foregroundColor = foregroundColor
        self.image = image
    }

    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        // Not used for Images usually, but could be background?
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.foregroundColor = Color(r: r, g: g, b: b, a: a)
        }
    }
}

struct SwiftImageView: View {
    var state: SwiftImageState
    var callback: (() -> Void)?
    
    var body: some View {
        ZStack {
            if let img = state.image {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
            } else if !state.systemName.isEmpty {
                Image(systemName: state.systemName)
                    .resizable()
                    .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
            } else if !state.filePath.isEmpty {
                if let img = NSImage(contentsOfFile: state.filePath) {
                     Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
                } else {
                     Image(nsImage: NSImage(byReferencingFile: state.filePath) ?? NSImage())
                        .resizable()
                        .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
                }
            } else if !state.name.isEmpty {
                Image(state.name)
                     .resizable()
                     .aspectRatio(contentMode: state.contentMode == 1 ? .fill : .fit)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .foregroundColor(state.foregroundColor)
        .onTapGesture {
            self.callback?()
        }
    }
}

@objc(SwiftImageLoader)
public class SwiftImageLoader: NSObject {
    public static func makeImage(systemName: String, name: String, filePath: String, id: String, callback: (() -> Void)?) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = SwiftImageState(systemName: systemName, name: name, filePath: filePath)
         
         // Register in central registry
         ViewRegistry.register(state, for: finalId)
         
         let view = SwiftImageView(state: state, callback: callback)
         ViewRegistry.register(view, for: finalId)
 
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    public static func destroyImage(id: String, viewPtr: Int64) {
        // Clean from registries
        ViewRegistry.clean(id: id)
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func img_set_system_name(id: String, name: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState {
            state.systemName = name
            state.name = ""
            state.filePath = ""
            state.image = nil
        }
    }
}

@HarbourDirect
public func img_set_name(id: String, name: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState {
            state.name = name
            state.systemName = ""
            state.filePath = ""
            state.image = nil
        }
    }
}

@HarbourDirect
public func img_set_file(id: String, path: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState {
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

@HarbourDirect
public func img_set_color(id: String, hexColor: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState {
            state.foregroundColor = Color(hex: hexColor)
        }
    }
}

@HarbourDirect
public func img_set_resizable(id: String, resizable: Bool) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState {
            state.resizable = resizable
        }
    }
}

@HarbourDirect
public func img_set_aspect_ratio(id: String, mode: Int) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState {
            state.contentMode = mode
        }
    }
}

@HarbourDirect
public func img_destroy(id: String, viewPtr: Int64) {
    SwiftImageLoader.destroyImage(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_image_create(
    top: Double,
    left: Double,
    width: Double,
    height: Double,
    name: String,
    parentPtr: Int64,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let callback: () -> Void = {
            let sendToHarbour = {
                SwiftBridge.onAction(finalId)
            }
            
            if Thread.isMainThread {
                sendToHarbour()
            } else {
                DispatchQueue.main.async { sendToHarbour() }
            }
        }

        let imgView = SwiftImageLoader.makeImage(
            systemName: name, 
            name: "", 
            filePath: "", 
            id: finalId, // Pasamos el ID ya generado
            callback: callback
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: imgView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(imgView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        }
        
        return viewAddress
    }

    if Thread.isMainThread {
        return executeCreation()
    } else {
        return DispatchQueue.main.sync {
            return executeCreation()
        }
    }
}

@HarbourDirect
public func img_set_nsimage(id: String, imagePtr: Int64) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? SwiftImageState, imagePtr != 0 {
            if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(imagePtr)) {
                let image = Unmanaged<NSImage>.fromOpaque(rawPtr).takeUnretainedValue()
                state.image = image
                state.systemName = ""
                state.name = ""
                state.filePath = ""
            }
        }
    }
}

