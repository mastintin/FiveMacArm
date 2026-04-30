import SwiftUI
import Observation
import CoreImage.CIFilterBuiltins

// MARK: - Image State
@Observable
public class ImageState: SwApplyable, RGBAColorableState {
    public let id: String
    public var systemName: String = ""
    public var filePath: String = ""
    public var urlStr: String = ""
    public var resizable: Bool = true
    public var contentMode: Int = 0 // 0: fit, 1: fill
    public var foregroundColor: Color = .primary
    public var cornerRadius: CGFloat = 0
    public var shadowRadius: CGFloat = 0
    public var shadowColor: Color = .black.opacity(0.3)
    public var borderWidth: CGFloat = 0
    public var borderColor: Color = .clear
    public var qrText: String = ""
    public var qrScale: Double = 1.0
    public var scaling: Int = 0 // 0: ProportionalDown, 1: AxesIndependently, 2: None, 3: UpOrDown
    public var frameStyle: Int = 0 // 0: None, 1: Photo, 2: GrayBezel, 3: Groove, 4: Button
    
    public init(id: String, systemName: String = "", filePath: String = "", url: String = "") {
        self.id = id
        self.systemName = systemName
        self.filePath = filePath
        self.urlStr = url
    }
    
    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {}
    
    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.foregroundColor = Color(r: r, g: g, b: b, a: a)
        }
    }
    
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        switch prop {
        case "systemname":
            if let s = value as? String { 
                DispatchQueue.main.async {
                    self.systemName = s
                    self.filePath = ""
                    self.urlStr = ""
                }
            }
        case "file":
            if let s = value as? String {
                DispatchQueue.main.async {
                    self.filePath = s
                    self.systemName = ""
                    self.urlStr = ""
                }
            }
        case "url":
            if let s = value as? String {
                DispatchQueue.main.async {
                    self.urlStr = s
                    self.systemName = ""
                    self.filePath = ""
                }
            }
        case "mode":
            if let i = value as? Int { self.contentMode = i }
        case "resizable":
            if let b = value as? Bool { self.resizable = b }
        case "color":
            if let s = value as? String {
                DispatchQueue.main.async {
                    if s.hasPrefix(".") { self.foregroundColor = mapBaseColor(s) }
                    else { self.foregroundColor = Color(hex: s) }
                }
            }
        case "corner", "cornerradius":
            if let n = (value as? NSNumber)?.doubleValue { self.cornerRadius = CGFloat(n) }
        case "shadow", "shadowradius":
            if let n = (value as? NSNumber)?.doubleValue { self.shadowRadius = CGFloat(n) }
        case "shadowcolor":
            if let s = value as? String { self.shadowColor = Color(hex: s) }
        case "borderwidth":
            if let n = (value as? NSNumber)?.doubleValue { self.borderWidth = CGFloat(n) }
        case "bordercolor":
            if let s = value as? String {
                DispatchQueue.main.async { self.borderColor = Color(hex: s) }
            }
        case "scaling":
            if let i = value as? Int { self.scaling = i }
        case "frame":
            if let i = value as? Int { self.frameStyle = i }
        case "qr":
            if let s = value as? String { 
                self.qrText = s
                self.systemName = ""
                self.filePath = ""
                self.urlStr = ""
            }
        case "qrscale":
            if let n = (value as? NSNumber)?.doubleValue { self.qrScale = n }
        default:
            break
        }
    }
}

// MARK: - Image View (Premium with Universal Drop)
public struct SwiftImageView: View {
    @Bindable var state: ImageState
    @State private var isTargeted: Bool = false
    
    public var body: some View {
        imageContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(frameBackground)
            .overlay(frameOverlay)
            .if(state.cornerRadius > 0) { $0.cornerRadius(state.cornerRadius) }
            .if(state.shadowRadius > 0) { $0.shadow(color: state.shadowColor, radius: state.shadowRadius) }
            .onTapGesture {
                SwiftBridge.onAction(state.id)
            }
            // Aplicamos el manejador universal
            .swDropHandler(id: state.id, isTargeted: $isTargeted)
            .overlay(
                 RoundedRectangle(cornerRadius: state.cornerRadius)
                    .stroke(Color.blue.opacity(0.6), lineWidth: isTargeted ? 4 : 0)
            )
            .animation(.spring(), value: isTargeted)
    }
    
    @ViewBuilder
    private var imageContent: some View {
        Group {
            if !state.qrText.isEmpty {
                Image(nsImage: generateQRCode(from: state.qrText, scale: state.qrScale))
                    .interpolation(.none)
                    .resizable()
            } else if !state.systemName.isEmpty {
                Image(systemName: state.systemName)
                    .renderingMode(.template)
                    .resizable()
            } else if !state.filePath.isEmpty {
                if let nsImage = loadSafeImage(from: state.filePath) {
                    Image(nsImage: nsImage)
                        .resizable()
                } else {
                    placeholderView
                }
            } else if !state.urlStr.isEmpty, let url = URL(string: state.urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): 
                        image.resizable()
                             .renderingMode(.template)
                    case .failure: placeholderView
                    case .empty: ProgressView().controlSize(.small)
                    @unknown default: placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .aspectRatio(contentMode: contentMode)
        .foregroundStyle(state.foregroundColor)
    }

    private var contentMode: ContentMode {
        switch state.scaling {
        case 1, 3: return .fill
        default: return .fit
        }
    }
    
    @ViewBuilder
    private var frameBackground: some View {
        switch state.frameStyle {
        case 1: Color.white.padding(-5)
        case 2: Color.gray.opacity(0.1)
        default: Color.black.opacity(0.001)
        }
    }
    
    @ViewBuilder
    private var frameOverlay: some View {
        Group {
            switch state.frameStyle {
            case 1: Rectangle().stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            case 2: Rectangle().stroke(Color.gray.opacity(0.5), lineWidth: 1)
            case 3: Rectangle().stroke(Color.gray.opacity(0.5), lineWidth: 2)
                        .padding(1).border(Color.white.opacity(0.5), width: 1)
            case 4: RoundedRectangle(cornerRadius: 4).stroke(Color.blue.opacity(0.3), lineWidth: 2)
            default:
                if !state.borderColor.isClear {
                    RoundedRectangle(cornerRadius: state.cornerRadius).stroke(state.borderColor, lineWidth: state.borderWidth)
                }
            }
        }
    }
    
    private var placeholderView: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .opacity(0.2)
    }

    private func loadSafeImage(from path: String) -> NSImage? {
        let cleanPath = path.replacingOccurrences(of: "file://", with: "")
        if FileManager.default.fileExists(atPath: cleanPath) {
            return NSImage(contentsOfFile: cleanPath)
        }
        return nil
    }
    
    private func generateQRCode(from string: String, scale: Double) -> NSImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale)))
            if let cgimg = context.createCGImage(transformedImage, from: transformedImage.extent) {
                return NSImage(cgImage: cgimg, size: NSSize(width: transformedImage.extent.width, height: transformedImage.extent.height))
            }
        }
        return NSImage(size: NSSize(width: 10, height: 10))
    }
}

// MARK: - Factory & Protocols (Igual)
extension SwiftImageView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ImageInit.self, from: jsonData)
        let state = ImageState(id: id, systemName: initial.systemname ?? "", filePath: initial.file ?? "", url: initial.url ?? "")
        state.contentMode = initial.mode ?? 0
        state.scaling = initial.scaling ?? 0
        state.frameStyle = initial.frame ?? 0
        state.qrText = initial.qr ?? ""
        state.qrScale = initial.qrscale ?? 10.0
        if let colorHex = initial.color { state.foregroundColor = Color(hex: colorHex) }
        state.cornerRadius = initial.corner ?? 0
        state.shadowRadius = initial.shadow ?? 0
        if let shColor = initial.shadowcolor { state.shadowColor = Color(hex: shColor) }
        state.borderWidth = initial.borderwidth ?? 0
        if let bColor = initial.bordercolor { state.borderColor = Color(hex: bColor) }
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .image, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

public struct ImageInit: Codable, GeometryProtocol {
    public let systemname, file, url, color, qr: String?
    public let mode, scaling, frame: Int?
    public let qrscale, corner, shadow, borderwidth: Double?
    public let shadowcolor, bordercolor: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
