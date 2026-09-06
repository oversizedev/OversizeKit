//
// Copyright © 2022 Alexander Romanov
// RadiusSettingView.swift
//

import OversizeNavigation
import OversizeUI
import SwiftUI

public struct RadiusSettingView: View {
    @Environment(\.theme) private var theme: ThemeSettings

    public init() {}

    public var body: some View {
        NavigationLayoutView("Radius") {
            settings
                .surfaceContentRowMargins()
        } background: {
            Color.backgroundSecondary
        }
    }

    private var settings: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionView {
                VStack(spacing: .zero) {
                    VStack(spacing: .small) {
                        #if os(iOS) || os(macOS)
                        VStack(spacing: .xxSmall) {
                            HStack {
                                Text("Size")
                                    .subheadline()
                                    .foregroundColor(.onSurfacePrimary)

                                Spacer()

                                Text(String(format: "%.0f", theme.radius) + "  px")
                                    .subheadline()
                                    .foregroundColor(.onSurfacePrimary)
                            }

                            Slider(value: theme.$radius, in: 0 ... 12, step: 4)
                        }
                        .padding(.horizontal, Space.medium)
                        .padding(.bottom, .xxSmall)

                        #endif
                    }
                }
            }

            Spacer()
        }
    }
}

#Preview {
    RadiusSettingView()
}
