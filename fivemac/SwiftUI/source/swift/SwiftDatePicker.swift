import SwiftUI
import AppKit
import Observation
import HarbourMacro

@Observable
public class DatePickerState {
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
    
    public static var states: [String: DatePickerState] = [:]

    public static func makeDatePicker(date: Date, title: String, id: String, index: Int, callback: ((Date) -> Void)?) -> NSView {
         let state = DatePickerState(date: date, title: title)
         states[id] = state
         
         let view = SwiftDatePickerView(state: state, callback: callback)
         ViewRegistry.register(view, for: index)
         
         let hostingView = NSHostingView(rootView: view)
         hostingView.sizingOptions = []
         hostingView.translatesAutoresizingMaskIntoConstraints = false
         return hostingView
    }

    public static func destroyDatePicker(id: String, index: Int, viewPtr: Int64) {
        states.removeValue(forKey: id)
        ViewRegistry.clean(index: index)
        
        if viewPtr != 0 {
            if let rawPtr = UnsafeMutableRawPointer(bitPattern: Int(viewPtr)) {
                let _ = Unmanaged<NSView>.fromOpaque(rawPtr).takeRetainedValue()
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
        if let state = SwiftDatePickerLoader.states[id] {
            state.date = SwiftDatePickerLoader.harbourStrToDate(dateStr)
        }
    }
}

@HarbourDirect
public func dtp_get_date(id: String) -> String {
    if let state = SwiftDatePickerLoader.states[id] {
        return SwiftDatePickerLoader.dateToHarbourStr(state.date)
    }
    return ""
}

@HarbourDirect
public func dtp_set_colors(id: String, accentHex: String, textHex: String) {
    DispatchQueue.main.async {
        if let state = SwiftDatePickerLoader.states[id] {
            state.accentColor = Color(hex: accentHex)
            state.textColor = Color(hex: textHex)
        }
    }
}

@HarbourDirect
public func dtp_set_enabled(id: String, enabled: Bool) {
    DispatchQueue.main.async {
        if let state = SwiftDatePickerLoader.states[id] {
            state.isEnabled = enabled
        }
    }
}

@HarbourDirect
public func dtp_destroy(id: String, index: Int, viewPtr: Int64) {
    SwiftDatePickerLoader.destroyDatePicker(id: id, index: index, viewPtr: viewPtr)
}

@HarbourDirect
public func swift_datepicker_create(
    top: Double,
    left: Double,
    width: Double,
    height: Double,
    dateStr: String,
    parentPtr: Int64,
    index: Int,
    title: String,
    id: String
) -> Int64 {
    
    func executeCreation() -> Int64 {
        var viewAddress: Int64 = 0
        
        let initialDate = SwiftDatePickerLoader.harbourStrToDate(dateStr)

        let callback: (Date) -> Void = { newDate in
            let dateStr = SwiftDatePickerLoader.dateToHarbourStr(newDate)
            let sendToHarbour = {
                if let pDynSym = hb_dynsymFindName("SWIFTDATEPICKERONCHANGE") {
                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym))
                    hb_vmPushNil()
                    hb_vmPushNumber(Double(index), 0)
                    hb_vmPushString(dateStr)
                    hb_vmDo(2)
                }
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
            id: id,
            index: index,
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
