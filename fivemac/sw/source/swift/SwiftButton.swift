import SwiftUI
import Observation

// MARK: - Button State
@Observable
public class ButtonState: SwApplyable {
    public var id: String
    public var caption: String
    public var backgroundColor: Color
    public var foregroundColor: Color
    public var cornerRadius: CGFloat
    public var isVisible: Bool = true
    
    public init(id: String, caption: String, backgroundColor: Color = .blue, foregroundColor: Color = .white, cornerRadius: CGFloat = 8) {
        self.id = id
        self.caption = caption
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }

    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "caption", "text", "settext":
            self.caption = String(describing: value)
        case "bgcolor", "background":
            if let color = value as? Color { self.backgroundColor = color }
        case "fgcolor", "foreground":
            if let color = value as? Color { self.foregroundColor = color }
        case "corner", "cornerradius":
            if let n = value as? CGFloat { self.cornerRadius = n }
        case "visible":
            if let b = value as? Bool { self.isVisible = b }
        default:
            break
        }
    }
}

// MARK: - Button Style
struct IslandButtonStyle: ButtonStyle {
    let bgColor: Color
    let fgColor: Color
    let radius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(bgColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button View
public struct SwiftButtonView: View {
    var state: ButtonState
    
    public var body: some View {
        Button(action: {
            let json = "{\"\(state.id)\":{\"event\":\"click\"}}"
            Harbour.call("SW_PIPELINE_SYNC", json)
        }) {
            Text(state.caption)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(state.foregroundColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(IslandButtonStyle(
            bgColor: state.backgroundColor,
            fgColor: state.foregroundColor, 
            radius: state.cornerRadius
        ))
    }
}
