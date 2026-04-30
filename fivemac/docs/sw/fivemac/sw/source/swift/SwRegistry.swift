import Foundation



public class SwCapabilities {
    public static let shared = SwCapabilities()
    
    // Almacén de comandos para el Proxy [SWTEXT: text]
    private var proxyCommands: [String: String] = [:]
    
    // Almacén de campos para el retorno [button: [text: cCaption]]
    private var harbourFields: [String: [String: Any]] = [:]
    
    private let queue = DispatchQueue(label: "com.fivemac.capabilities", attributes: .concurrent)
    
    private init() {}

    public func register(control: String, commands: [String: String], fields: [String: String]) {
        queue.async(flags: .barrier) {
            // 1. Añadimos comandos al mapa global (Acumulativo)
            for (hbCmd, swCmd) in commands {
                self.proxyCommands[hbCmd.uppercased()] = swCmd
            }
            
            // 2. Registramos el diccionario de retorno específico para este tipo de control
            self.harbourFields[control.lowercased()] = fields
        }
    }

    public func getProxyMap() -> [String: String] {
        queue.sync { return proxyCommands }
    }
    
    public func getHarbourField(for control: String, cmd: String) -> String {
        queue.sync {
            let controlKey = control.lowercased()
            let cmdKey = cmd.lowercased()
            
            if let controlMap = harbourFields[controlKey] as? [String: String] {
                return controlMap[cmdKey] ?? cmd
            }
            return cmd
        }
    }
}
