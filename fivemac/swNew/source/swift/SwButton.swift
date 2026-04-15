import SwiftUI
import HarbourMacro

// MARK: - Independent Button Loader for 'sw'
@HarbourDirect
public func sw_btn_create(top: Double, left: Double, w: Double, h: Double, prompt: String, id: String) {
    let finalId = id.isEmpty ? UUID().uuidString : id
    
    // Creamos un Item de nuestro stack independiente
    let item = SwStackItem(type: .button, content: prompt, id: finalId)
    item.x = top
    item.y = left
    item.width = w
    item.height = h
    
    // Lo registramos en nuestro registro privado de 'sw'
    SwRegistry.register(item, for: finalId)
}
