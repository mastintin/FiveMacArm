import SwiftUI

@Observable
public class ColorPickerState: SwApplyable {
    public let id: String
    public var value: String // Hex string
    public var prompt: String
    public var isVisible: Bool = true
    public var isEnabled: Bool = true

    public init(id: String, value: String, prompt: String) {
        self.id = id
        self.value = value
        self.prompt = prompt
    }

    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "value":
            if let s = value as? String { self.value = s }
        case "prompt":
            if let s = value as? String { self.prompt = s }
        case "visible":
            self.isVisible = SwUtils.toBool(value)
        case "enabled":
            self.isEnabled = SwUtils.toBool(value)
        default:
            break
        }
    }
}

public struct ColorPickerInit: Codable, GeometryProtocol {
    public let value, prompt: String?
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}

public struct SwiftColorPickerView: View {
    @Bindable var state: ColorPickerState
    
    // Local color state to bind with the native picker
    @State private var selectedColor: Color = .blue

    public var body: some View {
        if state.isVisible {
            ColorPicker(state.prompt, selection: $selectedColor)
                .disabled(!state.isEnabled)
                .opacity(state.isEnabled ? 1.0 : 0.5)
                .onAppear {
                    // Initialize local color from hex
                    if !state.value.isEmpty {
                        selectedColor = Color(hex: state.value)
                    }
                }
                .onChange(of: selectedColor) { _, newValue in
                    let hex = newValue.toHex()
                    if hex != state.value {
                        state.value = hex
                        SwDispatcher.shared.recordChange(id: state.id, property: "value", value: hex)
                        SwDispatcher.shared.enqueueEvent(id: state.id, type: "action", data: ["value": hex])
                    }
                }
                .onChange(of: state.value) { _, newValue in
                    // Sync back if changed from Harbour
                    let newColor = Color(hex: newValue)
                    selectedColor = newColor
                }
        }
    }
}

extension SwiftColorPickerView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(ColorPickerInit.self, from: jsonData)
        
        let state = ColorPickerState(id: id, 
                                   value: initial.value ?? "#0000FF", 
                                   prompt: initial.prompt ?? "Select Color")
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .colorpicker, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}

// Extension to get hex from Color
extension Color {
    func toHex() -> String {
        // Fallback for system colors or special colors
        let nsColor = NSColor(self)
        guard let rgbColor = nsColor.usingColorSpace(.sRGB) else {
            return "#000000"
        }
        
        let r = Float(rgbColor.redComponent)
        let g = Float(rgbColor.greenComponent)
        let b = Float(rgbColor.blueComponent)
        let a = Float(rgbColor.alphaComponent)
        
        if a < 1.0 {
            return String(format: "#%02X%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255),
                          Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255))
        }
    }
}
