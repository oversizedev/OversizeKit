//
// Copyright © 2022 Alexander Romanov
// AppearanceSettingView.swift
//

import OversizeCore
import OversizeResources
import OversizeUI
import SwiftUI

#if os(iOS)
    public struct AppearanceSettingView: View {
        @Environment(\.verticalSizeClass) private var verticalSizeClass
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.theme) private var theme: ThemeSettings
        @Environment(\.isPortrait) var isPortrait
        @Environment(\.iconStyle) var iconStyle: IconStyle

        #if os(iOS)
            @StateObject var iconSettings = AppIconSettings()
        #endif

        // swiftlint:disable trailing_comma

        @State var offset = CGPoint(x: 0, y: 0)
        @State var pageDestenation: Destenation?
        private let columns = [
            GridItem(.adaptive(minimum: 78)),
        ]
        enum Destenation {
            case font
            case border
            case radius
        }

        public init() {}
        public var body: some View {
            #if os(iOS)
                PageView("App") {
                    iOSSettings
                }
                .leadingBar {
                    if !isPortrait, verticalSizeClass == .regular {
                        EmptyView()
                    } else {
                        BarButton(type: .back)
                    }
                }
                .backgroundSecondary()

            #else
                macSettings
            #endif
        }

        #if os(iOS)
            private var iOSSettings: some View {
                VStack(alignment: .center, spacing: 0) {
                    apperance

                    accentColor

                    advanded

                    if iconSettings.iconNames.count > 1 {
                        appIcon
                    }
                }
                .preferredColorScheme(theme.appearance.colorScheme)
                .accentColor(theme.accentColor)
            }
        #endif

        private var macSettings: some View {
            VStack(alignment: .center, spacing: 0) {
                advanded
            }
            .frame(width: 400, height: 300)
            // swiftlint:disable multiple_closures_with_trailing_closure superfluous_disable_command

            .navigationTitle("Appearance")

            .preferredColorScheme(theme.appearance.colorScheme)
        }

        #if os(iOS)
            private var apperance: some View {
                SectionView {
                    HStack {
                        ForEach(Appearance.allCases, id: \.self) { appearance in

                            HStack {
                                Spacer()

                                VStack(spacing: .zero) {
                                    Text(appearance.name)
                                        .foregroundColor(.onSurfaceHighEmphasis)
                                        .font(.subheadline)
                                        .bold()

                                    appearance.image
                                        .padding(.vertical, .medium)

                                    if appearance == theme.appearance {
                                        Icon(.checkCircle, color: Color.accent)
                                    } else {
                                        Icon(.circle, color: .onSurfaceMediumEmphasis)
                                    }
                                }
                                Spacer()
                            }
                            .onTapGesture {
                                theme.appearance = appearance
                            }
                        }
                    }.padding(.vertical, .xSmall)
                }
            }
        #endif

        #if os(iOS)
            private var accentColor: some View {
                SectionView("Accent color") {
                    ColorSelector(selection: theme.$accentColor)
                }
            }

        #endif

        #if os(iOS)
            private var appIcon: some View {
                SectionView("App icon") {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(0 ..< iconSettings.iconNames.count) { index in
                            HStack {
                                Image(uiImage: UIImage(named: iconSettings.iconNames[index]
                                        ?? "DefaultAppIcon") ?? UIImage())
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 78, height: 78)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.accent,
                                                    lineWidth: index == iconSettings.currentIndex ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        let defaultIconIndex = self.iconSettings.iconNames
                                            .firstIndex(of: UIApplication.shared.alternateIconName) ?? 0
                                        if defaultIconIndex != index {
                                            // swiftlint:disable line_length
                                            UIApplication.shared.setAlternateIconName(self.iconSettings.iconNames[index]) { error in
                                                if let error = error {
                                                    log(error.localizedDescription)
                                                } else {
                                                    log("Success! You have changed the app icon.")
                                                }
                                            }
                                        }
                                    }
                            }
                            .padding(3)
                        }
                    }
                    .padding()
                }
            }
        #endif

        private var advanded: some View {
            SectionView("Advanced settings") {
                ZStack {
                    NavigationLink(destination: FontSettingView(),
                                   tag: .font,
                                   selection: $pageDestenation) { EmptyView() }

                    NavigationLink(destination: BorderSettingView(),
                                   tag: .border,
                                   selection: $pageDestenation) { EmptyView() }

                    NavigationLink(destination: RadiusSettingView(),
                                   tag: .radius,
                                   selection: $pageDestenation) { EmptyView() }

                    VStack(spacing: .zero) {
                        Row("Fonts", leadingType: .image(textIcon), trallingType: .arrowIcon) {
                            pageDestenation = .font
                        }
                        .premium()

                        Row("Borders", leadingType: .image(borderIcon), trallingType: .toggleWithArrowButton(isOn: theme.$borderApp, action: {
                            pageDestenation = .border
                        })) {
                            pageDestenation = .border
                        }
                        .premium()
                        .onChange(of: theme.borderApp) { value in
                            theme.borderSurface = value
                            theme.borderButtons = value
                            theme.borderControls = value
                            theme.borderTextFields = value
                        }

                        Row("Radius", leadingType: .image(radiusIcon), trallingType: .arrowIcon) {
                            pageDestenation = .radius
                        }
                        .premium()
                    }
                }
            }
        }

        var textIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Design.text
            case .solid:
                return Icon.Solid.Design.text
            case .duotone:
                return Icon.Duotone.Design.text
            }
        }

        var borderIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Design.scale
            case .solid:
                return Icon.Solid.Design.scale
            case .duotone:
                return Icon.Duotone.Design.scale
            }
        }

        var radiusIcon: Image {
            switch iconStyle {
            case .line:
                return Icon.Line.Design.vectorEditCircle
            case .solid:
                return Icon.Solid.Design.vectorEditCircle
            case .duotone:
                return Icon.Duotone.Design.vectorEditCircle
            }
        }
    }

    struct SettingsThemeView_Previews: PreviewProvider {
        static var previews: some View {
            AppearanceSettingView()
                .previewPhones()
        }
    }
#endif
