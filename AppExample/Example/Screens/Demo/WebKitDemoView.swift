//
// Copyright © 2026 Alexander Romanov
// WebKitDemoView.swift, created on 19.09.2026
//

import OversizeKit
import OversizeUI
import SwiftUI

struct WebKitDemoView: View {
    @State private var url: URL? = URL(string: "https://oversize.app")
    @State private var previewSize: CGSize = .zero

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Field") {
                    URLPreviewField("Link", url: $url)
                }

                if let url {
                    SectionView("Row preview") {
                        URLFieldPreview(url: url)
                    }

                    #if os(iOS)
                    SectionView("Link preview") {
                        URLPreview(url: url, size: $previewSize)
                            .frame(height: previewSize.height)
                    }
                    #endif
                }
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Web")
    }
}

#Preview {
    NavigationStack {
        WebKitDemoView()
    }
    .appEnvironment()
}
