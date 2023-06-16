//
// Copyright © 2022 Alexander Romanov
// RadiusSettingView.swift
//

import OversizeUI
import SwiftUI

struct RadiusSettingView: View {
    @Environment(\.theme) private var theme: ThemeSettings

    public init() {}

    public var body: some View {
        PageView("Radius") {
            settings
                .surfaceContentRowInsets()
        }
        .leadingBar {
            BarButton(.back)
        }
        .backgroundSecondary()
    }

    private var settings: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionView {
                VStack(spacing: .zero) {
                    VStack(spacing: Space.small.rawValue) {
                        #if os(iOS) || os(macOS)
                            VStack(spacing: Space.xxSmall.rawValue) {
                                HStack {
                                    Text("Size")
                                        .subheadline()
                                        .foregroundColor(.onSurfaceHighEmphasis)

                                    Spacer()

                                    Text(String(format: "%.0f", theme.radius) + "  px")
                                        .subheadline()
                                        .foregroundColor(.onSurfaceHighEmphasis)
                                }

                                Slider(value: theme.$radius, in: 0 ... 12, step: 4)
                            }
                            .padding(.horizontal, Space.medium)
                            .padding(.bottom, Space.xxSmall)

                        #endif
                    }
                }
            }

            Spacer()
        }
//        .navigationBar("Radius", style: .fixed($offset)) {
//            BarButton(.back)
//        } trailingBar: {} bottomBar: {}
//        .background(Color.backgroundSecondary.ignoresSafeArea(.all))
//        .preferredColorScheme(theme.appearance.colorScheme)
//        .animation(.easeIn(duration: 0.2))
    }
}

struct RadiusSettingView_Previews: PreviewProvider {
    static var previews: some View {
        RadiusSettingView()
    }
}
