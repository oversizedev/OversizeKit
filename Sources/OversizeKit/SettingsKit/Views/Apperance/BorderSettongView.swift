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
                        .fontStyle(.headline)
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
                                                .fontStyle(.subheadline)
                                                .foregroundColor(.onSurfaceHighEmphasis)
                                        }

                                        Slider(value: theme.$borderSize, in: 0.5 ... 2, step: 0.5)
                                    }
                                }
                                .surfaceStyle(.secondary)
                                .controlPadding(.small)
                                .padding(.horizontal, Space.medium)
                                .padding(.bottom, Space.xxSmall)

                            #endif

                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.border)
                                .padding(.horizontal, theme.borderSurface ? 0 : Space.medium.rawValue)

                            VStack(spacing: .zero) {
                                RowDeprecated("Surface",
                                              trallingType: .toggle(isOn: theme.$borderSurface),
                                              paddingVertical: .xSmall)
                                RowDeprecated("Buttons",
                                              trallingType: .toggle(isOn: theme.$borderSurface),
                                              paddingVertical: .xSmall)
                                RowDeprecated("Text fields",
                                              trallingType: .toggle(isOn: theme.$borderSurface),
                                              paddingVertical: .xSmall)
                                RowDeprecated("Other controls",
                                              trallingType: .toggle(isOn: theme.$borderSurface),
                                              paddingVertical: .xSmall)
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
