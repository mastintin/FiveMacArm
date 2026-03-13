import Foundation
import Observation
import SwiftUI

public struct GridItemSpec: Codable {
    public let type: String // "fixed", "flexible", "adaptive"
    public let size: Double?
    public let min: Double?
    public let max: Double?
    public let spacing: Double?
}

public struct ColorRGBA: Codable {
    public let r: Double
    public let g: Double
    public let b: Double
    public let a: Double
}

@Observable
public class StackItem: Identifiable {
    public var id: String
    public let type: ItemType
    public var content: String
    public let secondaryContent: String?
    public var children: [StackItem] = []

    // Grid Props
    public var gridColumns: [GridItemSpec]? = nil

    // Background & Foreground Color
    public var bgColor: (r: Double, g: Double, b: Double, a: Double)? = nil
    public var fgColor: (r: Double, g: Double, b: Double, a: Double)? = nil
    public var itemHeight: Double? = nil
    public var itemWidth: Double? = nil
    public var spacing: Double? = nil
    public var fontSize: Double? = nil
    public var isBold: Bool = false
    public var cornerRadius: Double? = nil

    public init(type: ItemType, content: String, secondaryContent: String? = nil, id: String? = nil) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.content = content
        self.secondaryContent = secondaryContent
    }

    public enum ItemType: Int, Codable {
        case text = 0
        case systemImage = 1
        case hstack = 2
        case imageFile = 3
        case vstack = 4
        case hstackContainer = 5
        case spacer = 6
        case lazyVGrid = 7
        case list = 8
        case button = 9
        case divider = 10
    }
}

public protocol StackStateProtocol: AnyObject {
    var items: [StackItem] { get set }
    var onAction: ((String) -> Void)? { get set }
    var lastItem: StackItem? { get set }
}

public class SwiftStackRegistry {
    public static var sharedStates: [String: StackStateProtocol] = [:]
    
    public static func register(_ state: StackStateProtocol, for id: String) {
        sharedStates[id] = state
    }
    
    public static func getState(for id: String) -> StackStateProtocol? {
        return sharedStates[id]
    }
}

public func mapSpecsToGridItems(_ specs: [GridItemSpec]) -> [GridItem] {
    return specs.map { spec in
        let spacing = spec.spacing.map { CGFloat($0) }
        switch spec.type {
        case "fixed":
            return GridItem(.fixed(CGFloat(spec.size ?? 100)), spacing: spacing)
        case "flexible":
            return GridItem(.flexible(minimum: CGFloat(spec.min ?? 10), maximum: CGFloat(spec.max ?? .infinity)), spacing: spacing)
        case "adaptive":
            return GridItem(.adaptive(minimum: CGFloat(spec.min ?? 50), maximum: CGFloat(spec.max ?? .infinity)), spacing: spacing)
        default:
            return GridItem(.flexible())
        }
    }
}

public func findItem(in items: [StackItem], id: String) -> StackItem? {
    for item in items {
        if item.id == id {
            return item
        }
        if let found = findItem(in: item.children, id: id) {
            return found
        }
    }
    return nil
}


public struct RecursiveItemView: View {
    public var item: StackItem
    public var onAction: ((String) -> Void)?
    public var index: Int
    public var remoteIndex: Int? = nil 
    public var selectedIndex: Int? = nil 
    public var isInsideList: Bool = false 

    public init(item: StackItem, onAction: ((String) -> Void)? = nil, index: Int, remoteIndex: Int? = nil, selectedIndex: Int? = nil, isInsideList: Bool = false) {
        self.item = item
        self.onAction = onAction
        self.index = index
        self.remoteIndex = remoteIndex
        self.selectedIndex = selectedIndex
        self.isInsideList = isInsideList
    }

    private func getBackground() -> some View {
        Group {
            if let bg = item.bgColor {
                Color(red: bg.r, green: bg.g, blue: bg.b, opacity: bg.a)
                    .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            } else {
                Color.clear
            }
        }
    }

    private func getForegroundColor() -> Color? {
        if let fg = item.fgColor {
            return Color(red: fg.r, green: fg.g, blue: fg.b, opacity: fg.a)
        }
        return nil
    }

    public var body: some View {
        HStack(spacing: 0) {  
            if item.type == .text {
                Text(item.content)
                    .font(item.fontSize.map { .system(size: CGFloat($0)) } ?? .body)
                    .fontWeight(item.isBold ? .bold : .regular)
                    .foregroundColor(getForegroundColor())
                    .background(getBackground())
                    .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            }
            else if item.type == .systemImage {
                Image(systemName: item.content)
                    .resizable()
                    .scaledToFit()
                    .frame(width: item.itemWidth.map { CGFloat($0) }, height: item.itemHeight.map { CGFloat($0) } ?? 24)
                    .foregroundColor(getForegroundColor())
                    .background(getBackground())
                    .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            } else if item.type == .imageFile {
                if let nsImage = NSImage(contentsOfFile: item.content) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: item.itemWidth.map { CGFloat($0) }, height: item.itemHeight.map { CGFloat($0) } ?? 24)
                        .background(getBackground())
                        .cornerRadius(CGFloat(item.cornerRadius ?? 0))
                } else {
                    Text("Img error")
                }
            } else if item.type == .hstack {
                HStack(alignment: .center) {
                    Image(systemName: item.secondaryContent ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(item.content)
                        .font(item.fontSize.map { .system(size: CGFloat($0)) } ?? .body)
                        .fontWeight(item.isBold ? .bold : .regular)
                    Spacer()
                }
                .background(getBackground())
                .cornerRadius(CGFloat(item.cornerRadius ?? 0))
            } else if item.type == .vstack {
                VStack(alignment: .leading) {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                        let child = item.children[childIndex]
                        RecursiveItemView(item: child, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex, isInsideList: isInsideList)
                    }
                }
                .background(getBackground())
            } else if item.type == .hstackContainer {
                HStack(alignment: .center, spacing: item.spacing.map { CGFloat($0) } ?? 8) {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                        let child = item.children[childIndex]
                        RecursiveItemView(item: child, onAction: onAction, index: 0, remoteIndex: remoteIndex, selectedIndex: selectedIndex, isInsideList: isInsideList)
                    }
                }
                .frame(width: item.itemWidth.map { CGFloat($0) }, height: item.itemHeight.map { CGFloat($0) })
                .background(getBackground())
            } else if item.type == .spacer {
                Spacer()
            } else if item.type == .divider {
                Rectangle().fill(Color.secondary.opacity(0.3)).frame(height: 1)
            } else if item.type == .lazyVGrid {
                let columns = mapSpecsToGridItems(item.gridColumns ?? [])
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                         let child = item.children[childIndex]
                         RecursiveItemView(item: child, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex, isInsideList: isInsideList)
                    }
                }
                .background(getBackground())
            } else if item.type == .list {
                List {
                    ForEach(0..<item.children.count, id: \.self) { childIndex in
                        let child = item.children[childIndex]
                        RecursiveItemView(item: child, onAction: onAction, index: childIndex, remoteIndex: remoteIndex ?? (index+1), selectedIndex: selectedIndex, isInsideList: true)
                    }
                }
            } else if item.type == .button {
                Button(action: {
                    onAction?(item.id)
                }) {
                    Text(item.content)
                        .font(item.fontSize.map { .system(size: CGFloat($0)) } ?? .body)
                        .fontWeight(item.isBold ? .bold : .semibold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .foregroundColor(item.fgColor.map { Color(red: $0.r, green: $0.g, blue: $0.b, opacity: $0.a) } ?? (item.bgColor != nil ? .white : .primary))
                        .background(
                            Group {
                                 if let bg = item.bgColor {
                                     Color(red: bg.r, green: bg.g, blue: bg.b, opacity: bg.a)
                                 } else {
                                     Color.accentColor
                                 }
                            }
                        )
                        .cornerRadius(CGFloat(item.cornerRadius ?? 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        // .border(Color.red, width: 1) //
        .foregroundColor(item.fgColor.map { Color(red: $0.r, green: $0.g, blue: $0.b, opacity: $0.a) } ?? (item.type == .button ? .white : .primary))
        .contentShape(Rectangle())
        .if(!isInsideList) { view in
            view.simultaneousGesture(TapGesture().onEnded {
                let type = item.type
                if type == .text || type == .systemImage || type == .imageFile || type == .spacer || type == .hstack || type == .hstackContainer {
                    onAction?(item.id)
                }
            })
        }
    }
}
