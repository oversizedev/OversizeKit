//
// Copyright © 2026 Alexander Romanov
// DocumentScanner.swift
//

import SwiftUI

#if os(iOS)
import VisionKit

struct DocumentScanner: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    let onDismiss: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedURL: $selectedURL, onDismiss: onDismiss)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_: VNDocumentCameraViewController, context _: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate, @unchecked Sendable {
        @Binding var selectedURL: URL?
        let onDismiss: () -> Void

        init(selectedURL: Binding<URL?>, onDismiss: @escaping () -> Void) {
            _selectedURL = selectedURL
            self.onDismiss = onDismiss
        }

        func documentCameraViewController(_: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            if let pdfData = scan.toPDFData() {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("pdf")
                try? pdfData.write(to: tempURL)
                selectedURL = tempURL
            }
            onDismiss()
        }

        func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            onDismiss()
        }

        func documentCameraViewController(_: VNDocumentCameraViewController, didFailWithError _: Error) {
            onDismiss()
        }
    }
}

private extension CGRect {
    func fitting(aspectRatio size: CGSize) -> CGRect {
        guard size.width > 0, size.height > 0 else { return self }
        let scale = min(width / size.width, height / size.height)
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(x: minX + (width - scaledSize.width) / 2, y: minY + (height - scaledSize.height) / 2)
        return CGRect(origin: origin, size: scaledSize)
    }
}

extension VNDocumentCameraScan {
    func toPDFData() -> Data? {
        let pageSize = CGSize(width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        return renderer.pdfData { context in
            for index in 0 ..< pageCount {
                context.beginPage()
                let image = imageOfPage(at: index)
                let imageRect = CGRect(origin: .zero, size: pageSize).fitting(aspectRatio: image.size)
                image.draw(in: imageRect)
            }
        }
    }
}

#Preview {
    DocumentScanner(selectedURL: .constant(nil), onDismiss: {})
}
#endif
