import Foundation
import SwiftUI
import AppKit

// MARK: - Notification Manager
@MainActor
class SwNotificationCenter {
    static let shared = SwNotificationCenter()
    
    // Almacén por ID para control manual desde Harbour
    private var activeNotifications: [String: NotificationState] = [:]

    func show(id: String, text: String, title: String, type: Int = 1, seconds: Double = 0) {
        // Si ya existe una con ese ID, la cerramos antes de abrir la nueva
        if let existingState = activeNotifications[id] {
            self.dismiss(state: existingState)
        }
        
        let state = NotificationState(id: id, text: text, title: title, type: type)
        let view = AnyView(SleekNotificationView(state: state) {
            Task { @MainActor in
                self.dismiss(state: state)
            }
        })
        
        let panel = NotificationPanel(view: view, title: title)
        state.panel = panel
        
        activeNotifications[id] = state
        panel.makeKeyAndOrderFront(nil)
        panel.invalidateShadow()
        
        if seconds > 0 {
            let nanoseconds = UInt64(seconds * 1_000_000_000)
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: nanoseconds)
                self.dismiss(id: id)
            }
        }
    }

    func dismiss(id: String) {
        if let state = activeNotifications[id] {
            self.dismiss(state: state)
        }
    }

    private func dismiss(state: NotificationState) {
        guard let panel = state.panel else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            panel.animator().alphaValue = 0
        }) {
            panel.close()
            Task { @MainActor in
                self.activeNotifications.removeValue(forKey: state.id)
            }
        }
    }
}

// MARK: - Data Models
@MainActor
class NotificationState: ObservableObject {
    let id: String
    let text: String
    let title: String
    let type: Int
    weak var panel: NSPanel?
    
    init(id: String, text: String, title: String, type: Int) {
        self.id = id
        self.text = text
        self.title = title
        self.type = type
    }
    
    var iconName: String {
        switch type {
        case 2: return "xmark.octagon.fill"
        case 3: return "exclamationmark.triangle.fill"
        default: return "info.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch type {
        case 2: return .red
        case 3: return .orange
        default: return .blue
        }
    }
}

// MARK: - UI View (Glassmorphism)
struct SleekNotificationView: View {
    @ObservedObject var state: NotificationState
    var onClose: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: state.iconName)
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(state.iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(state.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(state.text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(width: 400)
        .background(
            ZStack {
                SwNotificationVibrancyView(material: .hudWindow, blendingMode: .behindWindow)
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(10)
    }
}

// MARK: - Panel Host
class NotificationPanel: NSPanel {
    init(view: AnyView, title: String) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 420, height: 160),
                   styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        
        self.isOpaque = false
        self.backgroundColor = .clear 
        self.hasShadow = true
        self.isFloatingPanel = true
        self.level = .floating
        
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        self.isMovableByWindowBackground = true
        self.center()
        
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.layer?.backgroundColor = .clear
        self.contentView = hostingController.view
    }
}

// MARK: - Vibrancy Helper
struct SwNotificationVibrancyView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = 22
        view.layer?.masksToBounds = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
