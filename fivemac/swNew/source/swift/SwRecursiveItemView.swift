import SwiftUI

/// Renderizador recursivo INDEPENDIENTE para la arquitectura de prueba 'sw'.
public struct SwRecursiveItemView: View {
    @Bindable var item: SwStackItem
    let index: Int
    
    public var body: some View {
        Group {
            switch item.type {
            case .button:
                Button(action: {
                    SwBridge.onAction(item.id)
                }) {
                    Text(item.content)
                        .padding(5)
                }
                .buttonStyle(.borderedProminent)
                .frame(width: CGFloat(item.width), height: CGFloat(item.height))

            case .label:
                Text(item.content)
                    .frame(width: CGFloat(item.width), height: CGFloat(item.height), alignment: .leading)

            case .toggle:
                if let state = SwRegistry.get(item.id) as? SwToggleState {
                    @Bindable var bState = state
                    Toggle(state.prompt, isOn: $bState.isOn)
                        .onChange(of: bState.isOn) {
                            SwBridge.onChange(state.id, state.isOn)
                        }
                        .frame(width: CGFloat(item.width), height: CGFloat(item.height))
                }

            case .text:
                Text(item.content)
            
            case .aichat:
                if let state = SwRegistry.get(item.id) as? SwiftAIChatState {
                    SwiftAIChatView(state: state)
                        .frame(width: CGFloat(item.width), height: CGFloat(item.height))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                }
            }
        }
    }
}
