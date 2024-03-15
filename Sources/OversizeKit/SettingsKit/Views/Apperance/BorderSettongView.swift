//
// Copyright © 2022 Alexander Romanov
// BorderSettongView.swift
//

import OversizeUI
import SwiftUI

public struct BorderSettingView: View {
    @Environment(\.theme) private var theme: ThemeSettings

    public init() {}

    public var body: some View {
        PageView("Borders in app") {
            settings
                .surfaceContentRowMargins()
        }
        .leadingBar {
            // if !isPortrait, verticalSizeClass == .regular {
            //    EmptyView()
            // } else {
            BarButton(.back)
            // }
        }
        .backgroundSecondary()
    }

    private var settings: some View {
        VStack(alignment: .center, spacing: 0) {
            SectionView {
                VStack(spacing: .zero) {
                    Toggle("Borders in app", isOn: theme.$borderApp)
                        .onChange(of: theme.borderApp) { value in
                            theme.borderSurface = value
                            theme.borderButtons = value
                            theme.borderControls = value
                            theme.borderTextFields = value
                        }
                        .headline()
                        .foregroundColor(.onSurfaceHighEmphasis)
                        .padding(.horizontal, .medium)
                        .padding(.vertical, .small)

                    if theme.borderApp {
                        VStack(spacing: Space.small.rawValue) {
                            #if os(iOS) || os(macOS)
                                Surface {
                                    VStack(spacing: Space.xxSmall.rawValue) {
                                        HStack {
                                            Text("Size")
                                                .subheadline()
                                                .foregroundColor(.onSurfaceHighEmphasis)

                                            Spacer()

                                            Text(String(format: "%.1f", theme.borderSize) + " px")
                                                .subheadline()
                                                .foregroundColor(.onSurfaceHighEmphasis)
                                        }

                                        Slider(value: theme.$borderSize, in: 0.5 ... 2, step: 0.5)
                                    }
                                }
                                .surfaceStyle(.secondary)
                                .surfaceContentMargins(.small)
                                .padding(.horizontal, Space.medium)
                                .padding(.bottom, Space.xxSmall)

                            #endif

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.border)
                                .padding(.horizontal, theme.borderSurface ? 0 : Space.medium.rawValue)

                            VStack(spacing: .zero) {
                                Switch("Surface", isOn: theme.$borderSurface)

                                Switch("Buttons", isOn: theme.$borderSurface)

                                Switch("Text fields", isOn: theme.$borderSurface)

                                Switch("Other controls", isOn: theme.$borderSurface)

                            }.padding(.top, .xxxSmall)
                                .padding(.vertical, .xxxSmall)
                        }
                    }
                }
            }
        }
//        .navigationBar("Border", style: .fixed($offset)) {
//            BarButton(.back)
//        } trailingBar: {} bottomBar: {}
//        .background(Color.backgroundSecondary.ignoresSafeArea(.all))
//        .preferredColorScheme(theme.appearance.colorScheme)
//        .animation(.easeIn(duration: 0.2))
    }
}

struct BorderSettongView_Previews: PreviewProvider {
    static var previews: some View {
        BorderSettingView()
            .previewPhones()
    }
}
