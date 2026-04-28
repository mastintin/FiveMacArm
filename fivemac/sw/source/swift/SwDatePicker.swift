import SwiftUI

struct SwiftDatePickerView: View {
    @Bindable var state: DatePickerState
    
    var body: some View {
        GeometryReader { geo in
            // Renderizamos solo el Picker sin marcos externos
            renderDatePicker(size: geo.size)
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .opacity(state.isVisible ? 1 : 0)
        .disabled(!state.isEnabled)
        .onChange(of: state.date) { oldValue, newValue in
            sendChange(newValue)
        }
    }
    
    @ViewBuilder
    private func renderDatePicker(size: CGSize) -> some View {
        let picker = DatePicker("", selection: $state.date, displayedComponents: getComponents())
            .labelsHidden()
            .tint(Color.indigo) // Mantenemos el acento indigo para los controles internos
            .controlSize(.large)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .monospacedDigit()
        
        if state.style == 1 {
            // Escala Auto-Ajustada sin marco
            let scale = min(size.width / 200, size.height / 200) * 0.9
            
            picker.datePickerStyle(.graphical)
                  .scaleEffect(scale, anchor: .center)
        } else if state.style == 3 {
            picker.datePickerStyle(.field)
        } else {
            picker.datePickerStyle(.compact)
        }
    }
    
    private func getComponents() -> DatePickerComponents {
        var components: DatePickerComponents = []
        if state.showDate { components.insert(.date) }
        if state.showTime { components.insert(.hourAndMinute) }
        return components.isEmpty ? [.date] : components
    }
    
    private func sendChange(_ date: Date) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        let dateStr = formatter.string(from: date)
        
        let controlId = state.id
        let json = "{\"\(controlId)\":{\"event\":\"change\",\"date\":\"\(dateStr)\"}}"
        Harbour.call("SW_UPDATE_HB", json)
    }
}

extension SwiftDatePickerView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(DatePickerInit.self, from: jsonData)
        
        let state = DatePickerState(id: id)
        state.style = initial.style ?? 0
        state.showTime = initial.showtime ?? false
        state.showDate = initial.showdate ?? true
        
        if let dateStr = initial.date {
            if let d = SwUtils.parseHarbourDate(dateStr) {
                state.date = d
            }
        }
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .datepicker, id: id)
        item.itemWidth = initial.width ?? 140
        item.itemHeight = initial.height ?? 30
        item.x = initial.left ?? 0
        item.y = initial.top ?? 0
        
        return item
    }
}
