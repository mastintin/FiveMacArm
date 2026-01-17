import SwiftUI
import AppKit

@available(OSX 10.15, *)
@available(OSX 10.15, *)
struct VStackItem: Hashable, Identifiable {
    let id = UUID()
    let type: ItemType
    let content: String 
    let secondaryContent: String? // For HStack: systemName
    
    enum ItemType: Int {
        case text = 0
        case systemImage = 1
        case hstack = 2
    }
}

@available(OSX 10.15, *)
class SwiftVStackState: ObservableObject {
    @Published var items: [VStackItem] = []
    @Published var scrollable: Bool = false
    
    // Default color: Gray (0.5) opacity 0.5
    @Published var red: Double = 0.5
    @Published var green: Double = 0.5
    @Published var blue: Double = 0.5
    @Published var alpha: Double = 0.5
    
    @Published var useInvertedColor: Bool = false
    
    // Foreground Color (Text Color)
    @Published var fgRed: Double = 0.0
    @Published var fgGreen: Double = 0.0
    @Published var fgBlue: Double = 0.0
    @Published var fgAlpha: Double = 1.0
    
    @Published var spacing: Double = 12.0
    @Published var alignment: Int = 0 // 0: Center, 1: Leading, 2: Trailing
    
    var onClick: ((Int) -> Void)?
}

@available(OSX 10.15, *)
struct SwiftVStackView: View {
    @ObservedObject var state: SwiftVStackState
    
    var body: some View {
        Group {
            if state.scrollable {
                ScrollView {
                    content
                }
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Group {
                if state.useInvertedColor {
                    Color.primary.colorInvert().opacity(state.alpha)
                } else {
                    Color(red: state.red, green: state.green, blue: state.blue, opacity: state.alpha)
                }
            }
        )
        .cornerRadius(10)
        .foregroundColor(
            Color(red: state.fgRed, green: state.fgGreen, blue: state.fgBlue, opacity: state.fgAlpha)
        )
    }
    
    var content: some View {
        let align: HorizontalAlignment
        switch state.alignment {
        case 1: align = .leading
        case 2: align = .trailing
        default: align = .center
        }
        
        return VStack(alignment: align, spacing: CGFloat(state.spacing)) {
            ForEach(Array(state.items.enumerated()), id: \.element) { index, item in
                Group {
                    if item.type == .text {
                        Text(item.content)
                            .padding(8)
                            // removed maxWidth: .infinity to allow alignment to work
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    } else if item.type == .systemImage {
                        if #available(OSX 11.0, *) {
                            Image(systemName: item.content)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .padding(5)
                        } else {
                            // Fallback for older macOS
                            Text("Img: " + item.content)
                            // Fallback for older macOS
                            Text("Img: " + item.content)
                        }
                    } else if item.type == .hstack {
                        HStack {
                            if #available(OSX 11.0, *) {
                                Image(systemName: item.secondaryContent ?? "")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("I")
                            }
                            Text(item.content)
                                .font(.body)
                            Spacer()
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .contentShape(Rectangle()) // Make the whole area tappable
                .onTapGesture {
                    state.onClick?(index + 1) // 1-based index for Harbour
                }
            }
        }
        .padding()
        // Forces the VStack to fill the available width, responding to alignment
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: align, vertical: .center))
    }
}

@objc(SwiftVStackLoader)
public class SwiftVStackLoader: NSObject {
    
    static var lastCreatedState: Any? = nil

    @objc(makeVStackWithIndex:callback:)
    public static func makeVStack(index: Int, callback: @escaping (Int) -> Void) -> NSView {
         if #available(OSX 10.15, *) {
             let state = SwiftVStackState()
             state.onClick = callback
             lastCreatedState = state
             
             let view = SwiftVStackView(state: state)
             
             // Register
             ViewRegistry.register(view, for: index)

             let hostingView = NSHostingView(rootView: view)
             return hostingView
         } else {
             return NSView()
         }
    }
    
    @objc(addItem:)
    public static func addItem(_ text: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    state.items.append(VStackItem(type: .text, content: text, secondaryContent: nil))
                }
            }
        }
    }
    
    @objc(addSystemImage:)
    public static func addSystemImage(_ systemName: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    state.items.append(VStackItem(type: .systemImage, content: systemName, secondaryContent: nil))
                }
            }
        }
    }
    
    @objc(addHStackItem:systemName:)
    public static func addHStackItem(_ text: String, systemName: String) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    state.items.append(VStackItem(type: .hstack, content: text, secondaryContent: systemName))
                }
            }
        }
    }
    
    @objc(setScrollable:)
    public static func setScrollable(_ scrollable: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    state.scrollable = scrollable
                }
            }
        }
    }
    
    @objc(setBackgroundColorRed:green:blue:alpha:)
    public static func setBackgroundColor(red: Double, green: Double, blue: Double, alpha: Double) {
         if #available(OSX 10.15, *) {
             DispatchQueue.main.async {
                 if let state = lastCreatedState as? SwiftVStackState {
                     state.red = red
                     state.green = green
                     state.blue = blue
                     state.alpha = alpha
                 }
             }
         }
    }
    
    @objc(setSpacing:)
    public static func setSpacing(_ spacing: Double) {
        print("DEBUG: setSpacing called with \(spacing)")
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    print("DEBUG: Updating state.spacing")
                    state.spacing = spacing
                } else {
                    print("DEBUG: lastCreatedState is NIL or wrong type")
                }
            }
        }
    }

    @objc(setAlignment:)
    public static func setAlignment(_ alignment: Int) {
         print("DEBUG: setAlignment called with \(alignment)")
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    print("DEBUG: Updating state.alignment")
                    state.alignment = alignment
                } else {
                    print("DEBUG: lastCreatedState is NIL")
                }
            }
        }
    }
    
    @objc(setInvertedColor:)
    public static func setInvertedColor(_ useInverted: Bool) {
        if #available(OSX 10.15, *) {
            DispatchQueue.main.async {
                if let state = lastCreatedState as? SwiftVStackState {
                    state.useInvertedColor = useInverted
                }
            }
        }
    }
}
