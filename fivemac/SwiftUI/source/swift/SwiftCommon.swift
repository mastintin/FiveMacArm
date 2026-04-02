import SwiftUI
import AppKit

// MARK: - Registry for Dynamic Views (Fundamental)

public class ViewRegistry {
    private static var views: [String: Any] = [:]
    private static var objects: [String: NSObject] = [:]

    public static func register(_ view: Any, for id: String) {
        if let v = view as? any View {
            views[id] = AnyView(v)
        } else {
            views[id] = view
        }
    }

    public static func getView(for id: String) -> Any? {
        return views[id]
    }
    
    public static func registerObject(_ obj: NSObject, for id: String) {
        objects[id] = obj
    }
    
    public static func getObject(for id: String) -> NSObject? {
        return objects[id]
    }

    public static func clean(id: String) {
        views.removeValue(forKey: id)
        objects.removeValue(forKey: id)
    }
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

    public init(hbColor: Int) {
        self.init(red: Double(hbColor & 0xFF)/255, green: Double((hbColor >> 8)&0xFF)/255, blue: Double((hbColor >> 16)&0xFF)/255)
    }
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
