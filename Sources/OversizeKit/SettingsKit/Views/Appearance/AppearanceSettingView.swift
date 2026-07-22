//
// Copyright © 2023 Alexander Romanov
// AppearanceSettingView.swift
//

import NavigatorUI
import OversizeCore
import OversizeLocalizable
import OversizeNavigation
import OversizeServices
import OversizeUI
import SwiftUI

public struct AppearanceSettingView: View {
    @Environment(\.navigator) var navigator
    @Environment(\.theme) private var theme: ThemeSettings
    @Environment(\.iconStyle) var iconStyle: IconStyle
    @Environment(\.isPremium) var isPremium: Bool

    @State var iconNameSelection = Info.App.alternateIconName ?? "AppIcon"

    private let columns = [
        GridItem(.adaptive(minimum: 78)),
    ]

    public init() {}

    public var body: some View {
        NavigationLayoutView(L10n.Settings.apperance) {
            settings
                .surfaceContentRowMargins()
        } background: {
            Color.backgroundSecondary
        }
    }

    private var settings: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            appearance
                .padding(.top, .xxxSmall)

            #if os(iOS)
            accentColor
            #endif

            advanded

            #if os(iOS)
            if UIApplication.shared.supportsAlternateIcons, Info.App.alternateIconNames.isEmpty == false {
                appIcon
            }
            #endif
        }
        .preferredColorScheme(theme.appearance.colorScheme)
        #if os(iOS)
            .accentColor(theme.accentColor)
        #elseif os(macOS)
        #endif
    }

    private var macSettings: some View {
        VStack(alignment: .center, spacing: 0) {
            advanded
        }
        .frame(width: 400, height: 300)
        .navigationTitle("Appearance")
        .preferredColorScheme(theme.appearance.colorScheme)
    }

    private var appearance: some View {
        SectionView {
            HStack {
                ForEach(Appearance.allCases, id: \.self) { appearance in
                    HStack {
                        Spacer()

                        VStack(spacing: .zero) {
                            Text(appearance.name)
                                .foregroundColor(.onSurfacePrimary)
                                .font(.subheadline)
                                .bold()

                            appearance.image
                                .padding(.vertical, .medium)

                            if appearance == theme.appearance {
                                Icon(Image.Base.Check.circle).iconColor(Color.accent)
                            } else {
                                Icon("circle").iconColor(.onSurfaceSecondary)
                            }
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        theme.appearance = appearance
                    }
                }
            }
            .padding(.vertical, .xSmall)
            .padding(.horizontal, .small)
        }
    }

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
                ForEach(Info.App.alternateIconNames, id: \.self) { iconName in
                    HStack {
                        Image(iconName)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 78, height: 78)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        iconName == iconNameSelection ? Color.accent : Color.clear,
                                        lineWidth: iconName == iconNameSelection ? 3 : 0
                                    )
                            )
                            .overlay(alignment: .bottomTrailing) {
                                if iconName == iconNameSelection {
                                    Image.Base.check.icon(.white, size: .small)
                                        .padding(4)
                                        .background {
                                            Circle().fillAccent()
                                        }
                                        .offset(x: 7, y: 7)
                                }
                            }
                            .onTapGesture {
                                if isPremium {
                                    iconNameSelection = iconName
                                    UIApplication.shared.setAlternateIconName(iconName) { error in
                                        if let error {
                                            Log.error("App icon change failed", error: error)
                                        } else {
                                            Log.info("App icon changed")
                                        }
                                    }
                                } else {
                                    navigator.navigate(to: SettingsDestinations.premium)
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
            VStack(spacing: .zero) {
                Row("Fonts") {
                    navigator.navigate(to: SettingsDestinations.font)
                } leading: {
                    textIcon.icon()
                }
                .premium()
                .navigatable()
                .onPremiumTap()

                Switch(isOn: theme.$borderApp) {
                    Row("Borders") {
                        navigator.navigate(to: SettingsDestinations.border)

                    } leading: {
                        borderIcon.icon()
                    }
                    .premium()
                }
                .onPremiumTap()
                .onChange(of: theme.borderApp) { _, value in
                    theme.borderSurface = value
                    theme.borderButtons = value
                    theme.borderControls = value
                    theme.borderTextFields = value
                }

                Row("Radius") {
                    navigator.navigate(to: SettingsDestinations.radius)

                } leading: {
                    radiusIcon.icon()
                }
                .premium()
                .navigatable()
                .onPremiumTap()
            }
        }
    }

    var textIcon: Image {
        switch iconStyle {
        case .line:
            Image.Editor.Font.square
        case .fill:
            Image.Editor.Font.Square.fill
        case .twoTone:
            Image.Editor.Font.Square.TwoTone.fill
        }
    }

    var borderIcon: Image {
        switch iconStyle {
        case .line:
            Image.Design.verticalMirror
        case .fill:
            Image.Editor.Font.Square.fill
        case .twoTone:
            Image.Editor.Font.Square.TwoTone.fill
        }
    }

    var radiusIcon: Image {
        switch iconStyle {
        case .line:
            Image.Design.path
        case .fill:
            Image.Design.Path.fill
        case .twoTone:
            Image.Design.Path.twoTone
        }
    }
}

struct SettingsThemeView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingView()
            .previewPhones()
    }
}
