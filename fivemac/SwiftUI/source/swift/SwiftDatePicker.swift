import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class DatePickerState: RGBAColorableState {
    var date: Date
    var isVisible: Bool = true
    var isEnabled: Bool = true
    var accentColor: Color = .blue
    var textColor: Color = .primary
    var title: String = ""
    
    init(date: Date = Date(), title: String = "") {
        self.date = date
        self.title = title
    }

    public func setAccentColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.accentColor = Color(r: r, g: g, b: b, a: a)
        }
    }

    public func setTextColorRGBA(r: Int, g: Int, b: Int, a: Int) {
        DispatchQueue.main.async {
            self.textColor = Color(r: r, g: g, b: b, a: a)
        }
    }
}

struct SwiftDatePickerView: View {
    var state: DatePickerState
    var callback: ((Date) -> Void)?
    
    var body: some View {
        DatePicker(
            state.title,
            selection: Binding(
                get: { state.date },
                set: { 
                    state.date = $0
                    callback?($0)
                }
            ),
            displayedComponents: [.date]
        )
        .datePickerStyle(.stepperField)
        .foregroundColor(state.textColor)
        .tint(state.accentColor)
        .environment(\.locale, Locale(identifier: "es_ES"))
        .modify { view in
             if !state.isVisible { view.hidden() } else { view }
        }
        .disabled(!state.isEnabled)
    }
}

@objc(SwiftDatePickerLoader)
public class SwiftDatePickerLoader: NSObject {
    
    public static func makeDatePicker(date: Date, title: String, id: String, callback: ((Date) -> Void)?) -> NSView {
         let finalId = id.isEmpty ? UUID().uuidString : id
         let state = DatePickerState(date: date, title: title)
         
         // Register in central registry
         ViewRegistry.register(state, for: finalId)
         
         let view = SwiftDatePickerView(state: state, callback: callback)
         ViewRegistry.register(view, for: finalId)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         hostingView.identifier = NSUserInterfaceItemIdentifier(finalId)
         return hostingView
    }

    public static func destroyDatePicker(id: String, viewPtr: Int64) {
        ViewRegistry.clean(id: id)
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeRawPointer(bitPattern: Int(viewPtr)) {
                _ = Unmanaged<AnyObject>.fromOpaque(rawPtr).takeRetainedValue()
            }
        }
    }
    
    // Helper to format Date to YYYYMMDD
    public static func dateToHarbourStr(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    // Helper to parse YYYYMMDD to Date
    public static func harbourStrToDate(_ str: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: str) ?? Date()
    }
}

// --- HARBOUR DIRECT BRIDGES ---

@HarbourDirect
public func dtp_set_date(id: String, dateStr: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? DatePickerState {
            state.date = SwiftDatePickerLoader.harbourStrToDate(dateStr)
        }
    }
}

@HarbourDirect
public func dtp_get_date(id: String) -> String {
    if let state = ViewRegistry.getState(for: id) as? DatePickerState {
        return SwiftDatePickerLoader.dateToHarbourStr(state.date)
    }
    return ""
}

@HarbourDirect
public func dtp_set_colors(id: String, accentHex: String, textHex: String) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? DatePickerState {
            state.accentColor = Color(hex: accentHex)
            state.textColor = Color(hex: textHex)
        }
    }
}

@HarbourDirect
public func dtp_set_enabled(id: String, enabled: Bool) {
    DispatchQueue.main.async {
        if let state = ViewRegistry.getState(for: id) as? DatePickerState {
            state.isEnabled = enabled
        }
    }
}

@HarbourDirect
public func dtp_destroy(id: String, viewPtr: Int64) {
    SwiftDatePickerLoader.destroyDatePicker(id: id, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_datepicker_create(
    top: Double,
    left: Double,
    width: Double,
    height: Double,
    dateStr: String,
    parentPtr: Int64,
    title: String,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        let finalId = id.isEmpty ? UUID().uuidString : id
        
        let initialDate = SwiftDatePickerLoader.harbourStrToDate(dateStr)

        let callback: (Date) -> Void = { newDate in
            let dateStr = SwiftDatePickerLoader.dateToHarbourStr(newDate)
            let sendToHarbour = {
                SwiftBridge.onChange(finalId, dateStr)
            }
            
            // Always async to avoid crashes if Harbour opens modal dialogs (like MsgInfo)
            // during the interaction tracking loop.
            DispatchQueue.main.async {
                sendToHarbour()
            }
        }

        let dtpView = SwiftDatePickerLoader.makeDatePicker(
            date: initialDate,
            title: title,
            id: finalId, // Pasamos el ID ya generado
            callback: callback
        )

        if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(parentPtr)) {
            let parentObj = Unmanaged<NSObject>.fromOpaque(rawPtr).takeUnretainedValue()
            
            applySwiftViewLayout(
                swiftView: dtpView, 
                parent: parentObj, 
                top: top, 
                left: left, 
                w: width, 
                h: height
            )
            
            let viewPtr = Unmanaged.passRetained(dtpView).toOpaque()
            viewAddress = Int64(Int(bitPattern: viewPtr))
        }
        
        return viewAddress
    }

    if Thread.isMainThread {
        return executeCreation()
    } else {
        return DispatchQueue.main.sync {
            return executeCreation()
        }
    }
}
