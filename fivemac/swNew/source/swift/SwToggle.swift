import SwiftUI
import HarbourMacro

// MARK: - Independent Toggle State
@Observable
public class SwToggleState {
    public var id: String
    public var isOn: Bool = false
    public var prompt: String = ""
    
    public init(id: String, isOn: Bool, prompt: String) {
        self.id = id
        self.isOn = isOn
        self.prompt = prompt
    }
}

// MARK: - Independent Toggle Bridge for 'sw'
@HarbourDirect
public func sw_tog_create(top: Double, left: Double, w: Double, h: Double, prompt: String, id: String, isOn: Bool) {
    let finalId = id.isEmpty ? UUID().uuidString : id
    
    // El 'content' será el prompt
    let item = SwStackItem(type: .toggle, content: prompt, id: finalId)
    item.x = top
    item.y = left
    item.width = w
    item.height = h
    
    // Creamos el estado específico para el Toggle
    let state = SwToggleState(id: finalId, isOn: isOn, prompt: prompt)
    SwRegistry.register(state, for: finalId)
    
    // También registramos el item en el stack
    SwRegistry.register(item, for: finalId)
}
