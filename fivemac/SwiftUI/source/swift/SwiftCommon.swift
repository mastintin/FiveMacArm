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
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit) -> 444
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 4: // RGBA (16-bit) -> 4444
            (r, g, b, a) = ((int >> 12) * 17, (int >> 8 & 0xF) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RRGGBBAA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
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

import AppKit

func applySwiftViewLayout(swiftView: NSView, parent: NSObject, top: Double, left: Double, w: Double, h: Double) {
    let targetView: NSView? = (parent as? NSWindow)?.contentView ?? (parent as? NSView)
    
    guard let contentView = targetView else {
        print("Error: Parent provides no content view")
        return
    }

    let winHeight = contentView.frame.size.height
    let cocoaY = contentView.isFlipped ? CGFloat(top) : (winHeight - CGFloat(top) - CGFloat(h))

    swiftView.frame = NSRect(x: CGFloat(left), y: cocoaY, width: CGFloat(w), height: CGFloat(h))
    contentView.addSubview(swiftView)

    swiftView.translatesAutoresizingMaskIntoConstraints = true
    swiftView.autoresizingMask = [.maxXMargin, .minYMargin]
}