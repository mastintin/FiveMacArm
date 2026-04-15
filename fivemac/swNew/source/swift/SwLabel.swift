import SwiftUI
import HarbourMacro

// MARK: - Independent Label Bridge for 'sw'
@HarbourDirect
public func sw_lbl_create(top: Double, left: Double, w: Double, h: Double, prompt: String, id: String) {
    // DEBUG LBL
    sw_msginfo(msg: "Creando Label: \(id) - Prompt: \(prompt)", title: "Swift DEBUG")

    let finalId = id.isEmpty ? UUID().uuidString : id
    
    let item = SwStackItem(type: .label, content: prompt, id: finalId)
    item.x = top
    item.y = left
    item.width = w
    item.height = h
    
    SwRegistry.register(item, for: finalId)
}
