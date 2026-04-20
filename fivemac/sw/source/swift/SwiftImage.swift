import SwiftUI
import Observation

// MARK: - Image View
public struct SwiftImageView: View {
    @Bindable var state: ImageState
    
    public var body: some View {
        Group {
            if !state.systemName.isEmpty {
                Image(systemName: state.systemName)
                    .resizable()
            } else if !state.filePath.isEmpty {
                if let nsImage = NSImage(contentsOfFile: state.filePath) {
                    Image(nsImage: nsImage)
                        .resizable()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                }
            } else if !state.urlStr.isEmpty, let url = URL(string: state.urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
            }
        }
        .aspectRatio(contentMode: state.contentMode == 0 ? .fit : .fill)
        .foregroundColor(state.foregroundColor)
    }
}
