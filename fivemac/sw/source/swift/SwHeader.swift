import SwiftUI
import Observation

// MARK: - Header State
@Observable
public class SwiftHeaderState: SwApplyable {
    public let id: String
    public var title: String = ""
    public var subtitle: String = ""
    public var image: String = ""
    public var colors: [String] = []
    public var status: String = ""
    public var statusIcon: String = ""
    public var isVisible: Bool = true
    
    public init(id: String) {
        self.id = id
    }
    
    @MainActor
    public func apply(property: String, value: Any) {
        let prop = property.lowercased()
        if prop == "title" {
            if let sVal = value as? String { self.title = sVal }
        } else if prop == "subtitle" {
            if let sVal = value as? String { self.subtitle = sVal }
        } else if prop == "image" {
            if let sVal = value as? String { self.image = sVal }
        } else if prop == "colors" {
            if let sVal = value as? String {
                self.colors = sVal.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if let aVal = value as? [String] {
                self.colors = aVal
            }
        } else if prop == "status" {
            if let sVal = value as? String { self.status = sVal }
        } else if prop == "statusicon" {
            if let sVal = value as? String { self.statusIcon = sVal }
        } else if prop == "visible" {
            if let bVal = value as? Bool { self.isVisible = bVal }
        }
    }
}

// MARK: - Header View
public struct SwiftHeaderView: View {
    @Bindable var state: SwiftHeaderState
    
    var gradient: LinearGradient {
        var swColors: [Color] = []
        for c in state.colors {
            if c.hasPrefix(".") { swColors.append(mapBaseColor(c)) }
            else if c.hasPrefix("#") { swColors.append(Color(hex: c)) }
            else { swColors.append(.blue) }
        }
        if swColors.isEmpty { swColors = [.blue, .purple, .black] }
        return LinearGradient(colors: swColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    public var body: some View {
        if state.isVisible {
            ZStack(alignment: .bottomLeading) {
                // Background Gradient
                gradient
                    .mask(
                        Rectangle()
                            .padding(.bottom, -20) // Soft overlap if needed
                    )
                
                // Content
                HStack(spacing: 20) {
                    // Profile Image / Icon
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                            .frame(width: 74, height: 74)
                            .shadow(color: .blue.opacity(0.3), radius: 10)
                        
                        if state.image.contains("/") || state.image.contains("\\") {
                             // Probable path (not implemented here for simplicity, using SF Symbol as fallback)
                             Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: state.image.isEmpty ? "person.crop.circle.fill" : state.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(.white)
                                .shadow(radius: 5)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.title)
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        if !state.subtitle.isEmpty {
                            Text(state.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        if !state.status.isEmpty {
                            HStack(spacing: 6) {
                                if !state.statusIcon.isEmpty {
                                    Image(systemName: state.statusIcon)
                                        .font(.caption2)
                                }
                                Text(state.status)
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.3))
                            .clipShape(Capsule())
                            .foregroundStyle(.green)
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Factory Logic
extension SwiftHeaderView {
    @MainActor
    public static func create(id: String, from jsonData: Data) throws -> StackItem {
        let decoder = JSONDecoder()
        let initial = try decoder.decode(HeaderInit.self, from: jsonData)
        
        let state = SwiftHeaderState(id: id)
        state.title = initial.title ?? ""
        state.subtitle = initial.subtitle ?? ""
        state.image = initial.image ?? ""
        if let c = initial.colors {
             state.colors = c.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        }
        state.status = initial.status ?? ""
        state.statusIcon = initial.statusicon ?? ""
        
        ViewRegistry.register(state, for: id)
        
        let item = StackItem(type: .header, id: id) 
        setupGeometry(item: item, from: initial)
        return item
    }
}

// MARK: - Data Structures
public struct HeaderInit: Codable, GeometryProtocol {
    public let title: String?
    public let subtitle: String?
    public let image: String?
    public let colors: String?
    public let status: String?
    public let statusicon: String?
    
    public let width, height, top, left: Double?
    public let resizemask: Int?
    public let parentwidth, parentheight: Double?
}
