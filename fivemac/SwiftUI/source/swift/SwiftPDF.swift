import Foundation
import SwiftUI
import AppKit

@available(OSX 10.15, *)
@objc(SwiftPDF)
public class SwiftPDF: NSObject {
    
    @objc(saveView:to:)
    public static func saveView(id: Int, path: String) {
        
        DispatchQueue.main.async {
            // 1. Try generic NSView retrieval (Previous logical path)
            let nsObject = ViewRegistry.getObject(for: id) as? NSView
            
            // 2. Try SwiftUI View retrieval (For ImageRenderer)
            let swiftUIView = ViewRegistry.getView(for: id)
            
            if #available(macOS 13.0, *), let renderView = swiftUIView {
                // Important: ImageRenderer needs a scale/size.
                var viewToRender: AnyView = renderView
                
                if let boundsView = nsObject {
                     let size = boundsView.bounds.size
                     // Force the view to take the size of the hosting view
                     viewToRender = AnyView(renderView.frame(width: size.width, height: size.height))
                     
                     // Also set proposed size
                     renderer = ImageRenderer(content: viewToRender)
                     renderer.proposedSize = ProposedViewSize(size)
                } else {
                     renderer = ImageRenderer(content: renderView)
                }
                
                // renderer.scale = 1.0 // Default is usually fine, but consistent 1.0 is safer for PDF 72dpi logic
                
                renderer.render { size, context in
                    print("SwiftPDF Debug: ImageRenderer rendering with size: \(size)")
                    
                    var box = CGRect(origin: .zero, size: size)
                    guard let pdf = CGContext(URL(fileURLWithPath: path) as CFURL, mediaBox: &box, nil) else {
                        print("SwiftPDF Error: Could not create PDF context")
                        return
                    }
                    
                    pdf.beginPDFPage(nil)
                    context(pdf)
                    pdf.endPDFPage()
                    pdf.closePDF()
                    print("SwiftPDF: Saved with ImageRenderer to \(path)")
                }
                return
            }
            
            // Fallback to NSView.dataWithPDF
            guard let validView = nsObject else {
                print("SwiftPDF Error: View not found for id: \(id) in ViewRegistry")
                return
            }
            
            print("SwiftPDF Debug: Generating PDF (Fallback) for view bounds: \(validView.bounds)")
            
            // Ensure layout is updated
            validView.needsLayout = true
            validView.layoutSubtreeIfNeeded()
            
            let pdfData = validView.dataWithPDF(inside: validView.bounds)
            do {
                try pdfData.write(to: URL(fileURLWithPath: path))
            } catch {
                print("SwiftPDF Error saving PDF: \(error)")
            }
        }
    }
}
