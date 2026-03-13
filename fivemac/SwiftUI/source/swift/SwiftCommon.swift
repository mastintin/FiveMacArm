import SwiftUI
import Foundation

// Prototipo para Strings

//@_silgen_name("hb_parc") func hb_parc(_ i: Int32) -> UnsafePointer<Int8>?
//@_silgen_name("hb_parl") func hb_parl(_ i: Int32) -> Int32
//@_silgen_name("hb_parni") func hb_parni(_ i: Int32) -> Int32
//@_silgen_name("hb_parnd") func hb_parnd(_ i: Int32) -> Double

//@_silgen_name("hb_param")
//func hb_param(_ iParam: Int32, _ iMask: Int32) -> UnsafeMutableRawPointer?

//@_silgen_name("hb_itemType")
//func hb_itemType(_ pItem: UnsafeMutableRawPointer?) -> Int32

// Constante de Harbour para saber si es número (HB_IT_NUMERIC)
let HB_IT_NUMERIC: Int32 = 2 

@_cdecl("sw_GetRootId_par")
public func sw_GetRootId_par(_ iParam: Int32) -> UnsafePointer<Int8>? {
    // 1. Verificamos si es un número (HB_ISNUM)
    let pItem = hb_param(iParam, 0xFFFF) // HB_IT_ANY
    if (hb_itemType(pItem) & HB_IT_NUMERIC) != 0 {
        // Es un número: lo convertimos a String y sacamos el puntero
        let val = hb_parni(iParam)
        return ("\(val)" as NSString).utf8String
    } else {
        // No es número: lo tratamos como String (o devolvemos vacío)
        return hb_parc(iParam) ?? ("" as NSString).utf8String
    }
}



// Función de ayuda en Swift para booleanos
@_cdecl("sw_parl")
public func sw_parl(_ iParam: Int32) -> Bool {
    // En Harbour 0 es .F. y cualquier otra cosa suele ser .T.
    return hb_parl(iParam) != 0
}

@_cdecl("sw_parc")
public func sw_parc(_ iParam: Int32) -> UnsafePointer<Int8>? {
    return hb_parc(iParam) ?? ("" as NSString).utf8String
}


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

extension Color {
    static func parseHexRGBA(_ hex: String) -> (r: Double, g: Double, b: Double, a: Double)? {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 4: (r, g, b, a) = ((int >> 12) * 17, (int >> 8 & 0xF) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: return nil
        }
        return (Double(r)/255, Double(g)/255, Double(b)/255, Double(a)/255)
    }

    // 1. Para Hex Strings (Útil para temas o bases de datos)
    init(hex: String) {
        if let comps = Color.parseHexRGBA(hex) {
            self.init(.sRGB, red: comps.r, green: comps.g, blue: comps.b, opacity: comps.a)
        } else {
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
        }
    }

    // 2. Para Integers de 32 bits (Formato RRGGBBAA)
    init(rgba: Int) {
        let r = Double((rgba >> 24) & 0xFF) / 255.0
        let g = Double((rgba >> 16) & 0xFF) / 255.0
        let b = Double((rgba >> 8) & 0xFF) / 255.0
        let a = Double(rgba & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    } 

    // 3. Para el estándar de Harbour (Formato 0xBBGGRR o nRGB)
    init(hbColor: Int) {
        let r = Double(hbColor & 0xFF) / 255.0
        let g = Double((hbColor >> 8) & 0xFF) / 255.0
        let b = Double((hbColor >> 16) & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

import AppKit

func applySwiftViewLayout(swiftView: NSView, parent: NSObject, top: Double, left: Double, w: Double, h: Double) {
    let targetView: NSView? = (parent as? NSWindow)?.contentView ?? (parent as? NSView)
    // 1. Validar que el parent sea una NSView válida
    guard let contentView = targetView else {
        print("Error: Parent provides no content view")
        return
    }

    // 2. Gestión de coordenadas (Harbour Top-Left vs Cocoa)
    let winHeight = contentView.frame.size.height
    let cocoaY = contentView.isFlipped ? CGFloat(top) : (winHeight - CGFloat(top) - CGFloat(h))

    // 3. Aplicamos el Frame
    swiftView.frame = NSRect(x: CGFloat(left), y: cocoaY, width: CGFloat(w), height: CGFloat(h))
    contentView.addSubview(swiftView)

    // 4. Configuración de Auto-Resize (Clave para que no desaparezca)
    swiftView.translatesAutoresizingMaskIntoConstraints = true
    swiftView.autoresizingMask = [.maxXMargin, .minYMargin]
}

import SwiftUI
import AppKit

@objc(ViewRegistry)
public class ViewRegistry: NSObject {
    
    // Usamos String para que el cId (UUID) de Harbour sea la clave única
    private static var views: [String: AnyView] = [:]
    private static var objects: [String: Any] = [:]

    // --- MÉTODOS PARA HARBOUR (Compatibles con Objective-C) ---

    @objc(registerObject:forId:)
    public static func registerObject(_ object: Any, for id: String) {
        objects[id] = object
    }

    @objc(getObject:)
    public static func getObject(for id: String) -> Any? {
        return objects[id]
    }

    @objc(clean:)
    public static func clean(id: String) {
        views.removeValue(forKey: id)
        objects.removeValue(forKey: id)
    }

    @objc(registerNSView:forId:)
    public static func registerNSView(_ view: NSView, for id: String) {
        // Asegúrate de tener definido GenericNSViewWrapper en tu proyecto
        let wrapper = GenericNSViewWrapper(view: view)
        views[id] = AnyView(wrapper)
    }

    @objc(registerNSView:forIndex:)
    public static func registerNSView(_ view: NSView, for index: Int) {
        registerNSView(view, for: String(index))
    }

    // --- MÉTODOS PARA SWIFT (Sin @objc por el AnyView) ---

    public static func register<T: View>(_ view: T, for id: String) {
        views[id] = AnyView(view)
    }

    public static func getView(for id: String) -> AnyView? {
        return views[id]
    }
}
