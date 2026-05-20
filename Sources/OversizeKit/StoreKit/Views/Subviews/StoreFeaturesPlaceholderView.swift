//
// Copyright © 2025 Alexander Romanov
// StoreFeaturesPlaceholderView.swift
//

import OversizeUI
import SwiftUI

struct StoreFeaturesPlaceholderView: View {
    var body: some View {
        VStack(spacing: .zero) {
            ForEach(0 ..< 3, id: \.self) { _ in
                Row("Feature", subtitle: "Description") {} leading: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 24, height: 24)
                }
                .navigatable()
                .redacted(reason: .placeholder)
                .disabled(true)
            }
        }
    }
}

struct StoreFeaturesPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        StoreFeaturesPlaceholderView()
    }
}
