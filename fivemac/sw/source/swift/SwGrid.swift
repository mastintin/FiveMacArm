import SwiftUI
import Observation

@Observable
public class GridState: SwApplyable, StackStateProtocol {
    public let id: String
    public var items: [StackItem] = []
    public var columns: [GridItem] = [GridItem(.flexible())]
    public var spacing: Double = 10
    public var backgroundColor: Color = .clear
    public var isInteractive: Bool = true
    public var lastItem: StackItem? = nil

    public init(id: String) {
        self.id = id
    }

    @MainActor
    public func apply(property: String, value: Any) {
        switch property.lowercased() {
        case "columns":
            if let json = value as? String {
                self.columns = parseColumns(json)
            }
        case "spacing":
            if let nVal = value as? Double { self.spacing = nVal }
        case "backgroundcolor":
            if let sVal = value as? String { self.backgroundColor = Color(hex: sVal) }
        case "clear":
            self.items.removeAll()
            self.lastItem = nil
        default:
            break
        }
    }

    private func parseColumns(_ json: String) -> [GridItem] {
        guard let data = json.data(using: .utf8),
              let rawColumns = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return [GridItem(.flexible())]
        }

        return rawColumns.compactMap { dict in
            let type = (dict["type"] as? String) ?? "flexible"
            let size = (dict["size"] as? Double) ?? 100
            let min = (dict["min"] as? Double) ?? 50
            let max = (dict["max"] as? Double) ?? 500

            switch type {
            case "fixed":
                return GridItem(.fixed(CGFloat(size)))
            case "adaptive":
                return GridItem(.adaptive(minimum: CGFloat(min), maximum: CGFloat(max)))
            default: // flexible
                return GridItem(.flexible(minimum: CGFloat(min), maximum: CGFloat(max)))
            }
        }
    }
}

public struct SwiftGridView: View {
    @Bindable var state: GridState

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: state.columns, spacing: CGFloat(state.spacing)) {
                ForEach(state.items) { item in
                    SwRecursiveItemView(item: item)
                }
            }
            .padding(CGFloat(state.spacing))
        }
        .background(state.backgroundColor)
    }

    @MainActor
    public static func create(id: String, initial: GenericInit) -> StackItem {
        let state = GridState(id: id)
        ViewRegistry.register(state, for: id)
        let item = StackItem(type: .grid, id: id)
        setupGeometry(item: item, from: initial)
        return item
    }
}
