import AppKit
import Foundation

public class SwAppMenu {
    @MainActor
    public static func setup(from jsonData: Data) {
        print("🚀 [SwAppMenu] setup llamado")
        
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let menuItems = dict["items"] as? [[String: Any]] else {
            print("❌ [SwAppMenu] Error decodificando JSON de AppMenu")
            return
        }

        print("🔍 [SwAppMenu] Items encontrados: \(menuItems.count)")

        let mainMenu = NSMenu()
        
        // 1. Menú de Aplicación
        let appName = ProcessInfo.processInfo.processName
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        print("✅ [SwAppMenu] Menú de App '\(appName)' añadido")
        
        // 2. Menús de Harbour
        for itemData in menuItems {
            if let menu = buildNSMenu(from: itemData) {
                let menuItem = NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
                menuItem.submenu = menu
                mainMenu.addItem(menuItem)
                print("✅ [SwAppMenu] Menú Harbour '\(menu.title)' añadido a la barra")
            }
        }
        
        NSApp.mainMenu = mainMenu
        NSApp.activate(ignoringOtherApps: true)
        print("🏁 [SwAppMenu] NSApp.mainMenu establecido correctamente")
    }
}

private func buildNSMenu(from data: [String: Any]) -> NSMenu? {
    let title = data["caption"] as? String ?? "Menu"
    let menu = NSMenu(title: title)
    
    if let items = data["items"] as? [[String: Any]] {
        for itemData in items {
            let caption = itemData["caption"] as? String ?? ""
            if caption == "-" {
                menu.addItem(NSMenuItem.separator())
            } else if let subItems = itemData["items"] as? [[String: Any]], !subItems.isEmpty {
                // Es un submenú
                if let subMenu = buildNSMenu(from: itemData) {
                    let menuItem = NSMenuItem(title: subMenu.title, action: nil, keyEquivalent: "")
                    menuItem.submenu = subMenu
                    menu.addItem(menuItem)
                }
            } else {
                // Es un item de menú
                let id = itemData["id"] as? String ?? ""
                let key = itemData["shortcut"] as? String ?? ""
                
                let menuItem = NSMenuItem(title: caption, action: #selector(SwAppMenuActionHandler.handleAction(_:)), keyEquivalent: key)
                menuItem.target = SwAppMenuActionHandler.shared
                menuItem.representedObject = id
                menu.addItem(menuItem)
            }
        }
    }
    
    return menu
}

class SwAppMenuActionHandler: NSObject {
    static let shared = SwAppMenuActionHandler()
    
    @objc func handleAction(_ sender: NSMenuItem) {
        if let id = sender.representedObject as? String {
            print("SwAppMenu: Click en item \(id)")
            let json = "{\"\(id)\":{\"event\":\"click\"}}"
            Harbour.call("SW_UPDATE_HB", json)
        }
    }
}
