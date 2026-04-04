import SwiftUI
import AppKit
import HarbourMacro

// MARK: - Registry for Dynamic Views (Fundamental)

public class ViewRegistry {
    private static var states: [String: Any] = [:]
    private static var objects: [String: Any] = [:]

    public static func register(_ item: Any, for id: String) {
        if item is RGBAColorableState || item is StackStateProtocol {
            states[id] = item
        } else {
            objects[id] = item
        }
    }

    public static func get(_ id: String) -> Any? {
        // Return whatever is available, prioritizing states for property updates
        return states[id] ?? objects[id]
    }

    // Specialized helpers for type safety
    public static func getState(for id: String) -> Any? {
        return states[id]
    }

    public static func getObject(for id: String) -> Any? {
        return objects[id]
    }

    public static func clean(id: String) {
        states.removeValue(forKey: id)
        objects.removeValue(forKey: id)
    }
}

// MARK: - Protocol for Atomic Color Management

public protocol RGBAColorableState: AnyObject {
    func setAccentColorRGBA(color: Int, alpha: Int)
    func setTextColorRGBA(color: Int, alpha: Int)
}

// MARK: - SwiftUI View Extensions (modify & if)

extension View {
    @ViewBuilder
    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color Extensions (Hex & nRGB)

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8)*17, (int>>4&0xF)*17, (int&0xF)*17)
        case 6: (a, r, g, b) = (255, int>>16, int>>8&0xFF, int&0xFF)
        case 8: (a, r, g, b) = (int>>24, int>>16&0xFF, int>>8&0xFF, int&0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    public static func parseHexRGBA(_ hexString: String) -> (r: Double, g: Double, b: Double, a: Double)? {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8)*17, (int>>4&0xF)*17, (int&0xF)*17)
        case 6: (a, r, g, b) = (255, int>>16, int>>8&0xFF, int&0xFF)
        case 8: (a, r, g, b) = (int>>24, int>>16&0xFF, int>>8&0xFF, int&0xFF)
        default: return nil
        }
        return (Double(r)/255, Double(g)/255, Double(b)/255, Double(a)/255)
    }

    public init(hbColor: Int, alpha: Int = 255) {
        let r = Double(hbColor & 0xFF) / 255.0
        let g = Double((hbColor >> 8) & 0xFF) / 255.0
        let b = Double((hbColor >> 16) & 0xFF) / 255.0
        
        // Intelligence: Detect alpha from 4th byte (Byte 3) if present
        var a = Double(alpha) / 255.0
        let nativeAlpha = (hbColor >> 24) & 0xFF
        
        // Use nativeAlpha ONLY if it's present AND an explicit override wasn't passed (default 255)
        if nativeAlpha > 0 && alpha == 255 {
            a = Double(nativeAlpha) / 255.0
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}


// MARK: - Stack Models & Utilities

public struct GridItemSpec: Codable {
    public let type: String // "fixed", "flexible", "adaptive"
    public let size: Double?
    public let min: Double?
    public let max: Double?
    public let spacing: Double?
    public let caption: String?
}

public struct ColorRGBA: Codable {
    public let r: Double
    public let g: Double
    public let b: Double
    public let a: Double
}

@Observable
public class StackItem: Identifiable {
    public var id: String
    public let type: ItemType
    public var content: String
    public let secondaryContent: String?
    public var children: [StackItem] = []

    // Grid Props
    public var gridColumns: [GridItemSpec]? = nil

    // Background & Foreground Color
    public var bgColor: (r: Double, g: Double, b: Double, a: Double)? = nil
    public var fgColor: (r: Double, g: Double, b: Double, a: Double)? = nil
    public var itemHeight: Double? = nil
    public var itemWidth: Double? = nil
    public var spacing: Double? = nil
    public var fontSize: Double? = nil
    public var isBold: Bool = false
    public var cornerRadius: Double? = nil
    
    // Absolute Coordinates (for ZStack/Window)
    public var x: Double? = nil
    public var y: Double? = nil

    public init(type: ItemType, content: String, secondaryContent: String? = nil, id: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.content = content
        self.secondaryContent = secondaryContent
    }

    public enum ItemType: Int, Codable {
        case text = 0
        case systemImage = 1
        case hstack = 2
        case imageFile = 3
        case vstack = 4
        case hstackContainer = 5
        case spacer = 6
        case lazyVGrid = 7
        case list = 8
        case button = 9
        case divider = 10
        case toggle = 11
        case slider = 12
        case picker = 13
        case datepicker = 14
        case textfield = 15
        case zstack = 16
    }
}

public protocol StackStateProtocol: AnyObject {
    var items: [StackItem] { get set }
    var onAction: ((String) -> Void)? { get set }
    var lastItem: StackItem? { get set }
}

public func mapSpecsToGridItems(_ specs: [GridItemSpec]) -> [GridItem] {
    return specs.map { spec in
        let spacing = spec.spacing.map { CGFloat($0) }
        switch spec.type {
        case "fixed":
            return GridItem(.fixed(CGFloat(spec.size ?? 100)), spacing: spacing)
        case "flexible":
            return GridItem(.flexible(minimum: CGFloat(spec.min ?? 10), maximum: CGFloat(spec.max ?? .infinity)), spacing: spacing)
        case "adaptive":
            return GridItem(.adaptive(minimum: CGFloat(spec.min ?? 50), maximum: CGFloat(spec.max ?? .infinity)), spacing: spacing)
        default:
            return GridItem(.flexible())
        }
    }
}

public func findItem(in items: [StackItem], id: String) -> StackItem? {
    for item in items {
        if item.id == id {
            return item
        }
        if let found = findItem(in: item.children, id: id) {
            return found
        }
    }
    return nil
}

// MARK: - Core Bridge Functions (Equivalent to Legacy .m)

@_cdecl("sw_GetRootId_par")
public func sw_GetRootId_par(_ iParam: Int32) -> UnsafePointer<Int8>? {
    let pItem = hb_param(iParam, 0xFFFF)
    if (hb_itemType(pItem) & HB_IT_NUMERIC) != 0 {
        return ("\(hb_parni(iParam))" as NSString).utf8String
    }
    return hb_parc(iParam) ?? ("" as NSString).utf8String
}

@_cdecl("sw_parl")
public func sw_parl(_ iParam: Int32) -> Bool {
    return hb_parl(iParam) != 0
}

@_cdecl("HB_FUN_SWIFTAUTORESIZE")
public func swift_autoresize(_ p: UnsafeMutableRawPointer?) {
    let viewPtr = hb_parnll(1)
    if viewPtr != 0, let nsView = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)) {
        Unmanaged<NSView>.fromOpaque(nsView).takeUnretainedValue().autoresizingMask = NSView.AutoresizingMask(rawValue: UInt(hb_parnl(2)))
    }
}

@_cdecl("HB_FUN_SWIFT_UUID")
public func swift_uuid(_ p: UnsafeMutableRawPointer?) {
    hb_retc(UUID().uuidString)
}

@_cdecl("HB_FUN_SW_GET_ID")
public func sw_get_id_hb(_ p: UnsafeMutableRawPointer?) {
    let viewPtr = hb_parnll(1)
    if viewPtr != 0, let nsView = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)) {
        let view = Unmanaged<NSView>.fromOpaque(nsView).takeUnretainedValue()
        hb_retc(view.identifier?.rawValue ?? "")
    } else {
        hb_retc("")
    }
}

@_cdecl("HB_FUN_SW_SET_ID")
public func sw_set_id_hb(_ p: UnsafeMutableRawPointer?) {
    let viewPtr = hb_parnll(1)
    if viewPtr != 0, let nsView = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)), let newId = hb_parc(2) {
        let view = Unmanaged<NSView>.fromOpaque(nsView).takeUnretainedValue()
        view.identifier = NSUserInterfaceItemIdentifier(String(cString: newId))
    }
}

// MARK: - Core View Engine

func applySwiftViewLayout(swiftView: NSView, parent: NSObject, top: Double, left: Double, w: Double, h: Double) {
    let targetView: NSView? = (parent as? NSWindow)?.contentView ?? (parent as? NSView)
    guard let contentView = targetView else { return }
    let winHeight = contentView.frame.size.height
    let cocoaY = contentView.isFlipped ? CGFloat(top) : (winHeight - CGFloat(top) - CGFloat(h))
    swiftView.frame = NSRect(x: CGFloat(left), y: cocoaY, width: CGFloat(w), height: CGFloat(h))
    contentView.addSubview(swiftView)
    swiftView.translatesAutoresizingMaskIntoConstraints = true
    swiftView.autoresizingMask = [.maxXMargin, .minYMargin]
    
    if let id = swiftView.identifier?.rawValue, !id.isEmpty {
       ViewRegistry.register(swiftView, for: id)
    }
}

@_cdecl("HB_FUN_CREATESWIFTVIEW")
public func create_swift_view_hb(_ p: UnsafeMutableRawPointer?) {
    guard let cStr = hb_parc(2), let windowAddr = UnsafeMutableRawPointer(bitPattern: Int(hb_parnll(1))) else { return }
    let window = Unmanaged<NSObject>.fromOpaque(windowAddr).takeUnretainedValue()
    let className = String(cString: cStr)
    let swiftClass: AnyClass? = NSClassFromString(className) ?? NSClassFromString("SwiftFive.\(className)")
    guard let finalClass = swiftClass as? NSObject.Type else { return }
    let selector = NSSelectorFromString("makeViewWithCallback:")
    if finalClass.responds(to: selector) {
        let callbackName = hb_pcount() >= 7 ? String(cString: hb_parc(7)!) : nil
        let callback: @convention(block) (String) -> Void = { msg in
            DispatchQueue.main.async {
                if let cbName = callbackName, let pDynSym = hb_dynsymFindName(cbName) {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym)); hb_vmPushNil(); hb_vmPushString(msg); hb_vmDo(1)
                }
            }
        }
        let makeView = finalClass.method(for: selector)
        typealias MakeViewFunc = @convention(c) (AnyClass, Selector, @convention(block) (String) -> Void) -> UnsafeMutableRawPointer
        let function = unsafeBitCast(makeView, to: MakeViewFunc.self)
        let swiftView = Unmanaged<NSView>.fromOpaque(function(finalClass, selector, callback)).takeUnretainedValue()
        applySwiftViewLayout(swiftView: swiftView, parent: window, top: hb_parnd(3), left: hb_parnd(4), w: hb_parnd(5), h: hb_parnd(6))
    }
}

@_cdecl("HB_FUN_SWIFTSTANDALONEBATCHCREATE")
public func swift_standalone_batch_create(_ p: UnsafeMutableRawPointer?) {
    guard let cStr = hb_parc(2), let windowAddr = UnsafeMutableRawPointer(bitPattern: Int(hb_parnll(1))),
          let data = String(cString: cStr).data(using: .utf8),
          let batch = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
    let window = Unmanaged<NSObject>.fromOpaque(windowAddr).takeUnretainedValue()
    let pArray = hb_itemNew(nil); hb_arrayNew(pArray, Int32(batch.count))
    for (index, item) in batch.enumerated() {
        var fieldView: NSView? = nil
        let itemId = item["id"] as? String ?? ""
        if (item["type"] as? String) == "textfield" {
            let loaderClass = NSClassFromString("SwiftFive.SwiftTextFieldLoader") as? NSObject.Type
            let selector = NSSelectorFromString("makeTextFieldWithText:placeholder:id:callback:")
            let callback: @convention(block) (String) -> Void = { newText in
                DispatchQueue.main.async {
                    if let pDynSym = hb_dynsymFindName("SWIFTTEXTFIELDONCHANGE") {
                        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym)); hb_vmPushNil(); hb_vmPushString(itemId); hb_vmPushString(newText); hb_vmDo(2)
                    }
                }
            }
            if let loader = loaderClass, loader.responds(to: selector) {
                let imp = loader.method(for: selector)
                typealias MakeTF = @convention(c) (AnyClass, Selector, String, String, String, @convention(block) (String) -> Void) -> UnsafeMutableRawPointer
                let function = unsafeBitCast(imp, to: MakeTF.self)
                let viewPtr = function(loader, selector, item["text"] as? String ?? "", item["placeholder"] as? String ?? "", itemId, callback)
                fieldView = Unmanaged<NSView>.fromOpaque(viewPtr).takeUnretainedValue()
            }
            if let fv = fieldView {
                applySwiftViewLayout(swiftView: fv, parent: window, top: item["top"] as? Double ?? 0, left: item["left"] as? Double ?? 0, w: item["width"] as? Double ?? 200, h: item["height"] as? Double ?? 24)
            }
        }
        let pHandle = hb_itemPutPtr(nil, fieldView.map { Unmanaged.passRetained($0).toOpaque() })
        hb_arraySet(pArray, HB_SIZE(index + 1), pHandle); hb_itemRelease(pHandle)
    }
    hb_itemReturnRelease(pArray)
}

// MARK: - Universal Atomic Bridges for TSwiftControl (RGBA)

@HarbourDirect
public func sw_set_colors_rgba(id: String, color: Int, alpha: Int) {
    if let state = ViewRegistry.getState(for: id) as? RGBAColorableState {
        state.setAccentColorRGBA(color: color, alpha: alpha)
    }
}

@HarbourDirect
public func sw_set_text_colors_rgba(id: String, color: Int, alpha: Int) {
    if let state = ViewRegistry.getState(for: id) as? RGBAColorableState {
        state.setTextColorRGBA(color: color, alpha: alpha)
    }
}

@_cdecl("HB_FUN_SW_SET_POS")
public func sw_set_pos_hb(_ p: UnsafeMutableRawPointer?) {
    let pcount = hb_pcount()
    guard pcount >= 1 else { return }
    let id = hb_parc(1).map({ String(cString: $0) }) ?? ""
    
    let block = {
        if let view = ViewRegistry.getObject(for: id) as? NSView,
           let superview = view.superview {
            var rect = view.frame
            if pcount >= 2 && hb_param(2, HB_IT_DOUBLE) != nil {
               let top = hb_parnd(2)
               rect.origin.y = superview.isFlipped ? CGFloat(top) : (superview.frame.size.height - CGFloat(top) - rect.size.height)
            }
            if pcount >= 3 && hb_param(3, HB_IT_DOUBLE) != nil {
               rect.origin.x = CGFloat(hb_parnd(3))
            }
            view.frame = rect
        } else if ViewRegistry.get(id) is StackStateProtocol {
            // Support for stack items
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
}

@_cdecl("HB_FUN_SW_SET_SIZE")
public func sw_set_size_hb(_ p: UnsafeMutableRawPointer?) {
    let pcount = hb_pcount()
    guard pcount >= 1 else { return }
    let id = hb_parc(1).map({ String(cString: $0) }) ?? ""
    
    let block = {
        if let view = ViewRegistry.getObject(for: id) as? NSView {
            var rect = view.frame
            if pcount >= 2 && hb_param(2, HB_IT_DOUBLE) != nil {
               rect.size.width = CGFloat(hb_parnd(2))
            }
            if pcount >= 3 && hb_param(3, HB_IT_DOUBLE) != nil {
               rect.size.height = CGFloat(hb_parnd(3))
            }
            // If the parent is not flipped, the Y coordinate depends on the height
            if let superview = view.superview, !superview.isFlipped {
                rect.origin.y = rect.origin.y + view.frame.size.height - rect.size.height
            }
            view.frame = rect
        }
    }
    if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
}

@_cdecl("HB_FUN_SW_UPDATE_STATE")
public func sw_update_state_hb(_ p: UnsafeMutableRawPointer?) {
    _ = hb_parc(1).map({ String(cString: $0) }) ?? ""
    // Future update logic
    /* 
    if let _ = hb_parc(2), ...
    */
}

@HarbourDirect
public func sw_get_item_text(rootId: String, itemId: String) -> String {
    if let state = ViewRegistry.get(rootId) as? StackStateProtocol {
       if let item = findItem(in: state.items, id: itemId) {
           return item.content
       }
    }
    return ""
}

// MARK: - Recursive Item View (Stack Base)

public struct RecursiveItemView: View {
    public var item: StackItem
    public var onAction: ((String) -> Void)?
    public var index: Int
    public var remoteIndex: Int? = nil 
    public var selectedIndex: Int? = nil 
    public var isInsideList: Bool = false 

    public init(item: StackItem, onAction: ((String) -> Void)? = nil, index: Int, remoteIndex: Int? = nil, selectedIndex: Int? = nil, isInsideList: Bool = false) {
        self.item = item
        self.onAction = onAction
        self.index = index
        self.remoteIndex = remoteIndex
        self.selectedIndex = selectedIndex
        self.isInsideList = isInsideList
    }

    private func getBackground() -> some View {
        Group {
            if let bg = item.bgColor {
                Color(red: bg.r, green: bg.g, blue: bg.b, opacity: bg.a)
                    .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            } else {
                Color.clear
            }
        }
    }

    private func getForegroundColor() -> Color? {
        if let fg = item.fgColor {
            return Color(red: fg.r, green: fg.g, blue: fg.b, opacity: fg.a)
        }
        return nil
    }

    public var body: some View {
        HStack(spacing: 0) {  
            switch item.type {
            case .text:
                Text(item.content)
                    .font(item.fontSize.map { .system(size: CGFloat($0)) } ?? .body)
                    .fontWeight(item.isBold ? .bold : .regular)
                    .foregroundColor(getForegroundColor())
                    .background(getBackground())
                    .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            
            case .systemImage:
                Image(systemName: item.content)
                    .resizable()
                    .scaledToFit()
                    .frame(width: item.itemWidth.map { CGFloat($0) }, height: item.itemHeight.map { CGFloat($0) } ?? 24)
                    .foregroundColor(getForegroundColor())
                    .background(getBackground())
                    .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            
            case .imageFile:
                if let nsImage = NSImage(contentsOfFile: item.content) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: item.itemWidth.map { CGFloat($0) }, height: item.itemHeight.map { CGFloat($0) } ?? 24)
                        .background(getBackground())
                        .cornerRadius(CGFloat(item.cornerRadius ?? 0))
                } else {
                    Text("Img error")
                }
            
            case .hstack:
                HStack(alignment: .center) {
                    Image(systemName: item.secondaryContent ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(item.content)
                        .font(item.fontSize.map { .system(size: CGFloat($0)) } ?? .body)
                        .fontWeight(item.isBold ? .bold : .regular)
                    Spacer()
                }
                .background(getBackground())
                .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            
            case .vstack:
                VStack(alignment: .leading) {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                        let child = item.children[childIndex]
                        RecursiveItemView(item: child, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex, isInsideList: isInsideList)
                    }
                }
                .background(getBackground())
            
            case .hstackContainer:
                HStack(alignment: .center, spacing: item.spacing.map { CGFloat($0) } ?? 8) {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                        let child = item.children[childIndex]
                        RecursiveItemView(item: child, onAction: onAction, index: 0, remoteIndex: remoteIndex, selectedIndex: selectedIndex, isInsideList: isInsideList)
                    }
                }
                .frame(width: item.itemWidth.map { CGFloat($0) }, height: item.itemHeight.map { CGFloat($0) })
                .background(getBackground())
            
            case .spacer:
                Spacer()
            
            case .divider:
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            
            case .lazyVGrid:
                let specs = item.gridColumns ?? []
                let columns = mapSpecsToGridItems(specs)
                LazyVGrid(columns: columns, spacing: 20) {
                    Section {
                        ForEach(0..<item.children.count, id: \.self) { childIndex in
                             let child = item.children[childIndex]
                             RecursiveItemView(item: child, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex, isInsideList: isInsideList)
                        }
                    } header: {
                        if specs.contains(where: { $0.caption != nil }) {
                            ForEach(0..<specs.count, id: \.self) { i in
                                Text(specs[i].caption ?? "")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .background(getBackground())
            
            case .list:
                List {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                        let child = item.children[childIndex]
                        RecursiveItemView(item: child, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex, isInsideList: true)
                    }
                }
            
            case .button:
                Button(action: {
                    onAction?(item.id)
                }) {
                    Text(item.content)
                        .font(item.fontSize.map { .system(size: CGFloat($0)) } ?? .body)
                        .fontWeight(item.isBold ? .bold : .semibold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .foregroundColor(item.fgColor.map { Color(red: $0.r, green: $0.g, blue: $0.b, opacity: $0.a) } ?? (item.bgColor != nil ? .white : .primary))
                        .background(
                            Group {
                                 if let bg = item.bgColor {
                                     Color(red: bg.r, green: bg.g, blue: bg.b, opacity: bg.a)
                                 } else {
                                     Color.accentColor
                                 }
                            }
                        )
                        .cornerRadius(CGFloat(item.cornerRadius ?? 8))
                }
                .buttonStyle(PlainButtonStyle())
            
            case .toggle:
                if let toggleState = ViewRegistry.get(item.id) as? ToggleState {
                    SwiftToggleView(state: toggleState)
                }
            
            case .slider:
                if let sliderState = ViewRegistry.get(item.id) as? SliderState {
                    SwiftSliderView(state: sliderState)
                }
            
            case .picker:
                if let pickerState = ViewRegistry.get(item.id) as? PickerState {
                    SwiftPickerView(state: pickerState)
                }

            case .datepicker:
                if let dateState = ViewRegistry.get(item.id) as? DatePickerState {
                    SwiftDatePickerView(state: dateState)
                }
            
            case .textfield:
                if let tfState = ViewRegistry.get(item.id) as? TextFieldState {
                    SwiftTextFieldView(state: tfState)
                }
            default:
                EmptyView()
            }
        }
        .foregroundColor(item.fgColor.map { Color(red: $0.r, green: $0.g, blue: $0.b, opacity: $0.a) } ?? (item.type == .button ? .white : .primary))
        .contentShape(Rectangle())
        .if(!isInsideList) { view in
            view.simultaneousGesture(TapGesture().onEnded {
                let type = item.type
                if type == .text || type == .systemImage || type == .imageFile || type == .spacer || type == .hstack || type == .hstackContainer {
                    onAction?(item.id)
                }
            })
        }
    }
}
