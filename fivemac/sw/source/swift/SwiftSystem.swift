import Foundation
import AppKit
import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import HarbourMacro

// MARK: - Swift Universal Dispatcher System
//----------------------------------------------------------------------------//

internal struct SystemCommands {
    static func register(in sd: SwDispatcher) {
        // Registro de los comandos en el despacho universal (Ahora con retorno)
        sd.register("alert")      { params in await SystemCommands.alert(params) }
        sd.register("msgyesno")   { params in await SystemCommands.msgYesNo(params) }
        sd.register("msgchoice")  { params in await SystemCommands.msgChoice(params) }
        sd.register("msglist")    { params in await SystemCommands.msgList(params) }
        
        // --- NOTIFICACIONES Y ESTADOS ASÍNCRONOS ---
        sd.register("doevents")     { _ in await SystemCommands.doEvents() ; return nil }
        sd.register("isrunning")    { _ in return ["result": await NSApp.isRunning] }
        sd.register("msgstatus")    { params in await SystemCommands.msgStatus(params) ; return nil }
        sd.register("msgstatusupd") { params in await SystemCommands.msgStatusUpdate(params) ; return nil }
        sd.register("msgstatuscls") { _ in await SystemCommands.msgStatusClose() ; return nil }
        sd.register("beep")         { params in await SystemCommands.beep(params) }
        sd.register("msgget")       { params in await SystemCommands.msgGet(params) }
        sd.register("msggetmulti")  { params in await SystemCommands.msgGetMultiline(params) }
        sd.register("msgwait")      { params in await SystemCommands.msgWait(params) }
        sd.register("msgtoast")     { params in await SystemCommands.msgToast(params) ; return nil }
    }

// --- VISTA PARA MSGWAIT/TOAST (HUD) ---
// Estado global moderno para el sistema de Status/Progress (Swift 6 + Observation)
@Observable class SwStatusState {
    var msg: String = ""
    var title: String = ""
    var progress: Double = 0.0
    var showProgress: Bool = false
    
    static let shared = SwStatusState()
}

struct SwHUDView: View {
    var state = SwStatusState.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .center, spacing: 22) {
            // Sección Icono/Progreso
            ZStack {
                if state.showProgress {
                    ZStack {
                        // Fondo del progreso
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 4)
                        
                        // Barra de progreso circular (activa)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(max(state.progress / 100.0, 0.0), 1.0)))
                            .stroke(colorScheme == .dark ? Color.orange : Color.red, 
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.2), value: state.progress)
                            .id("progress_circle")
                        
                        Text("\(Int(state.progress))%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(width: 44, height: 44)
                } else {
                    Image(systemName: "info.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 34))
                }
            }
            .frame(width: 44, height: 44)
            
            // Sección Textos
            VStack(alignment: .leading, spacing: 4) {
                if !state.title.isEmpty {
                    Text(state.title.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .kerning(1.2)
                        .foregroundColor(colorScheme == .dark ? .orange : .red)
                        .opacity(0.9)
                }
                
                Text(state.msg)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .frame(minWidth: 340, maxWidth: 500, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// --- IMPLEMENTACIONES SÍNCRONAS ---

    @MainActor static func alert(_ params: [String: Any]) async -> [String: Any]? {
        let msg   = (params["msg"] as? String) ?? (params["p1"] as? String) ?? ""
        let title = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Información"
        let type  = (params["type"] as? Int) ?? (params["p3"] as? Int) ?? 0
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        
        switch type {
        case 1: alert.alertStyle = .warning
        case 2: alert.alertStyle = .critical
        default: alert.alertStyle = .informational
        }
        
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        return ["result": true]
    }

    @MainActor static func msgYesNo(_ params: [String: Any]) async -> [String: Any]? {
        let msg      = (params["msg"] as? String) ?? (params["p1"] as? String) ?? ""
        let title    = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Seleccione"
        
        // Detección robusta de booleano (acepta Bool o Int 1)
        let p3Raw    = params["defaultNo"] ?? params["p3"]
        let defNo    = (p3Raw as? Bool) ?? ((p3Raw as? Int) == 1)
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .informational
        
        if defNo {
            alert.addButton(withTitle: "No")  // NSAlertFirstButtonReturn
            alert.addButton(withTitle: "Yes") // NSAlertSecondButtonReturn
            let res = alert.runModal() == .alertSecondButtonReturn
            return ["result": res]
        } else {
            alert.addButton(withTitle: "Yes") // NSAlertFirstButtonReturn
            alert.addButton(withTitle: "No")  // NSAlertSecondButtonReturn
            let res = alert.runModal() == .alertFirstButtonReturn
            return ["result": res]
        }
    }

    @MainActor static func msgChoice(_ params: [String: Any]) async -> [String: Any]? {
        let msg   = (params["msg"] as? String) ?? (params["p1"] as? String) ?? ""
        let title = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Seleccione"
        let items = (params["items"] as? [String]) ?? (params["p3"] as? [Any])?.compactMap { "\($0)" } ?? []
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .informational
        
        for item in items {
            alert.addButton(withTitle: item)
        }
        
        let response = alert.runModal()
        let index = response.rawValue - NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
        
        return ["result": index + 1]
    }

    @MainActor static func beep(_ params: [String: Any]) async -> [String: Any]? {
        NSSound.beep()
        return nil
    }

    // --- IMPLEMENTACIONES ASÍNCRONAS (SIN RETORNO PARA HARBOUR) ---

    @MainActor static func doEvents() async {
        let event = NSApp.nextEvent(matching: .any, until: .distantPast, inMode: .default, dequeue: true)
        if let e = event {
            NSApp.sendEvent(e)
        }
    }

    @MainActor static func msgStatus(_ params: [String: Any]) async {
        let msg   = (params["msg"] as? String) ?? (params["p1"] as? String) ?? "Cargando..."
        let title = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Espere"
        
        let state = SwStatusState.shared
        state.msg = msg
        state.title = title
        state.progress = 0
        state.showProgress = true
        
        if currentStatusPanel == nil {
            let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 120),
                                styleMask: [.borderless, .nonactivatingPanel],
                                backing: .buffered, defer: false)
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = true
            panel.level = .floating
            panel.center()
            
            let hostingView = NSHostingView(rootView: SwHUDView())
            hostingView.frame = panel.contentView!.bounds
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = NSColor.clear.cgColor
            panel.contentView?.addSubview(hostingView)
            
            currentStatusPanel = panel
        }
        currentStatusPanel?.orderFrontRegardless()
    }

    @MainActor static func msgStatusUpdate(_ params: [String: Any]) async {
        let val = (params["value"] as? Double) ?? (params["p1"] as? Double) ?? 0.0
        SwStatusState.shared.progress = val
        
        // FORZAMOS EL REFRESCO TOTAL REASIGNANDO LA VISTA
        if let panel = currentStatusPanel, 
           let hostingView = panel.contentView?.subviews.first as? NSHostingView<SwHUDView> {
            hostingView.rootView = SwHUDView()
        }
        
        // Forzamos al panel a redibujarse inmediatamente y vaciamos el pipeline gráfico
        CATransaction.begin()
        currentStatusPanel?.display()
        CATransaction.flush()
        CATransaction.commit()
        
        // Bombeo rápido de eventos para asegurar que la ventana procese el refresco
        if let event = NSApp.nextEvent(matching: .any, until: .distantPast, inMode: .default, dequeue: true) {
            NSApp.sendEvent(event)
        }
    }

    @MainActor static func msgStatusClose() async {
        currentStatusPanel?.close()
        currentStatusPanel = nil
    }
}

//----------------------------------------------------------------------------//
// MARK: - Componentes de UI Auxiliares (SwiftUI)
//----------------------------------------------------------------------------//

// Diálogo de Selección de Lista con Buscador

@Observable class SwListState {
    var title: String = ""
    var items: [String] = []
    var searchText: String = ""
    var selectedIndex: Int? = nil
    var isClosed: Bool = false
    var onSelect: ((Int) -> Void)? = nil
    
    var filteredItems: [(originalIndex: Int, text: String)] {
        if searchText.isEmpty {
            return items.enumerated().map { ($0, $1) }
        } else {
            let lowerSearch = searchText.lowercased()
            return items.enumerated()
                .filter { $0.element.lowercased().contains(lowerSearch) }
                .map { ($0, $1) }
        }
    }
}

struct SwListView: View {
    @Bindable var state: SwListState
    @FocusState private var isSearchFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Cabecera Premium
            HStack {
                Text(state.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .orange : .red)
                Spacer()
                Button(action: { state.isClosed = true }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.primary.opacity(0.05))
            
            // Buscador
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Buscar elemento...", text: $state.searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.05)))
            .padding()
            
            // Lista de elementos
            List {
                ForEach(state.filteredItems, id: \.originalIndex) { item in
                    Button(action: {
                        state.onSelect?(item.originalIndex + 1)
                    }) {
                        HStack {
                            Text(item.text)
                                .font(.system(size: 13))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 4)
                        .background(Color.primary.opacity(0.001))
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            
            // Footer
            HStack {
                Spacer()
                Text("\(state.filteredItems.count) elementos")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
        }
        .frame(width: 350, height: 450)
        .background(.ultraThinMaterial)
        .onAppear {
            isSearchFocused = true
        }
    }
}

extension SystemCommands {
    static var currentStatusPanel: NSPanel?

    @MainActor static func msgGet(_ params: [String: Any]) async -> [String: Any]? {
        let msg     = (params["msg"] as? String) ?? (params["p1"] as? String) ?? ""
        let title   = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Entrada"
        let defText = (params["default"] as? String) ?? (params["p3"] as? String) ?? ""
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Aceptar")
        alert.addButton(withTitle: "Cancelar")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.stringValue = defText
        input.isEditable = true
        input.isSelectable = true
        alert.accessoryView = input
        
        // Aseguramos que el foco vaya al input al abrirse
        alert.window.initialFirstResponder = input
        
        let response = alert.runModal()
        let result = (response == .alertFirstButtonReturn) ? input.stringValue : ""
        
        return ["result": result]
    }

    @MainActor static func msgGetMultiline(_ params: [String: Any]) async -> [String: Any]? {
        let title   = (params["title"] as? String) ?? (params["p1"] as? String) ?? "Entrada de texto"
        let defText = (params["default"] as? String) ?? (params["p2"] as? String) ?? ""
        let w       = (params["width"] as? CGFloat) ?? (params["p3"] as? CGFloat) ?? 400
        let h       = (params["height"] as? CGFloat) ?? (params["p4"] as? CGFloat) ?? 150
        
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = "Introduzca el texto:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Aceptar")
        alert.addButton(withTitle: "Cancelar")
        
        let sv = NSScrollView(frame: NSRect(x: 0, y: 0, width: w, height: h))
        sv.hasVerticalScroller = true
        sv.autohidesScrollers = true
        sv.borderType = .bezelBorder
        
        let tv = NSTextView(frame: sv.bounds)
        tv.minSize = NSSize(width: 0.0, height: h)
        tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.autoresizingMask = .width
        tv.textContainer?.containerSize = NSSize(width: w, height: CGFloat.greatestFiniteMagnitude)
        tv.textContainer?.widthTracksTextView = true
        tv.string = defText
        tv.font = NSFont.systemFont(ofSize: 14)
        
        sv.documentView = tv
        alert.accessoryView = sv
        alert.window.initialFirstResponder = tv
        
        let response = alert.runModal()
        let result = (response == .alertFirstButtonReturn) ? tv.string : ""
        
        return ["result": result]
    }

    @MainActor static func msgWait(_ params: [String: Any]) async -> [String: Any]? {
        let msg     = (params["msg"] as? String) ?? (params["p1"] as? String) ?? "Espere..."
        let title   = (params["title"] as? String) ?? (params["p2"] as? String) ?? ""
        let seconds = (params["seconds"] as? Double) ?? (params["p3"] as? Double) ?? 2.0
        
        let state = SwStatusState.shared
        state.msg = msg
        state.title = title
        state.showProgress = true
        state.progress = 0
        
        // Reutilizamos la lógica de msgStatus para el panel
        await msgStatus(params)
        
        let endTime = Date().addingTimeInterval(seconds)
        while Date() < endTime {
            state.progress = (1.0 - (endTime.timeIntervalSinceNow / seconds)) * 100.0
            if let event = NSApp.nextEvent(matching: .any, until: .distantPast, inMode: .default, dequeue: true) {
                NSApp.sendEvent(event)
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        
        await msgStatusClose()
        return nil
    }

    @MainActor static func msgList(_ params: [String: Any]) async -> [String: Any]? {
        let title = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Seleccione un elemento"
        let items = (params["items"] as? [String]) ?? (params["p1"] as? [Any])?.compactMap { "\($0)" } ?? []
        
        let state = SwListState()
        state.title = title
        state.items = items
        
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 350, height: 450),
                            styleMask: [.titled, .fullSizeContentView, .closable],
                            backing: .buffered, defer: false)
        
        state.onSelect = { index in
            state.selectedIndex = index
            NSApp.stopModal()
        }
        
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.hasShadow = true
        
        let hostingView = NSHostingView(rootView: SwListView(state: state))
        panel.contentView = hostingView
        panel.center()
        
        // Ejecución modal pura
        NSApp.runModal(for: panel)
        
        panel.close()
        return ["result": state.selectedIndex ?? 0]
    }

    @MainActor static func msgToast(_ params: [String: Any]) async {
        let msg     = (params["msg"] as? String) ?? (params["p1"] as? String) ?? ""
        let title   = (params["title"] as? String) ?? (params["p2"] as? String) ?? "Aviso"
        let seconds = (params["seconds"] as? Double) ?? (params["p4"] as? Double) ?? 3.0
        
        let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 350, height: 100),
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered, defer: false)
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .floating
        panel.isMovableByWindowBackground = false
        
        let state = SwStatusState.shared
        state.msg = msg
        state.title = title
        state.showProgress = false
        
        let hostingView = NSHostingView(rootView: SwHUDView())
        hostingView.frame = panel.contentView!.bounds
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        panel.contentView?.addSubview(hostingView)
        
        // Posición arriba a la derecha
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            panel.setFrameOrigin(NSPoint(x: screenRect.maxX - 370, y: screenRect.maxY - 120))
        }
        
        panel.orderFrontRegardless()
        
        // Auto-cierre asíncrono
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            panel.close()
        }
    }
}
