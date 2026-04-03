import Foundation
import SwiftUI
import AppKit
import HarbourMacro


@objc(SwiftPDF)
public class SwiftPDF: NSObject {
    
    @objc(saveViewWithIndex:to:)
    public static func saveView(index: Int, path: String) {
        saveView(id: String(index), path: path)
    }

    @objc(saveView:to:)
    public static func saveView(id: String, path: String) {
        
        DispatchQueue.main.async {
            // 1. Try generic NSView retrieval (Previous logical path)
            let nsObject = ViewRegistry.get(id) as? NSView
            
            // 2. Try SwiftUI View retrieval (For ImageRenderer)
            let swiftUIView = ViewRegistry.get(id)
            
            print("[SwiftPDF] Attempting PDF capture for ID: \(id)")
            
            if #available(macOS 13.0, *), let renderView = swiftUIView as? AnyView {
                print("[SwiftPDF] Found SwiftUI View for ID: \(id). Initializing ImageRenderer...")
                let renderer: ImageRenderer<AnyView>
                var viewToRender: AnyView = renderView
                
                if let boundsView = nsObject {
                     let size = boundsView.bounds.size
                     print("[SwiftPDF] Scaling PDF to size: \(size.width)x\(size.height)")
                     viewToRender = AnyView(renderView.frame(width: size.width, height: size.height))
                     renderer = ImageRenderer(content: viewToRender)
                     renderer.proposedSize = ProposedViewSize(size)
                } else {
                     renderer = ImageRenderer(content: viewToRender)
                }
                
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
@HarbourDirect
public func swift_pdf_save(id: String, path: String) {
    SwiftPDF.saveView(id: id, path: path)
}
