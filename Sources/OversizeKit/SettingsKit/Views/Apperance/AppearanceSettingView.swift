//
// Copyright © 2023 Alexander Romanov
// AppearanceSettingView.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeRouter
import OversizeServices
import OversizeUI
import SwiftUI

public struct AppearanceSettingView: View {
    @Environment(Router<SettingsScreen>.self) var router
    @Environment(\.theme) private var theme: ThemeSettings
    @Environment(\.iconStyle) var iconStyle: IconStyle
    @Environment(\.isPremium) var isPremium: Bool

    #if os(iOS)
    @StateObject var iconSettings = AppIconSettings()
    #endif

    private let columns = [
        GridItem(.adaptive(minimum: 78)),
    ]

    public init() {}

    public var body: some View {
        Page(L10n.Settings.apperance) {
            settings
                .surfaceContentRowMargins()
        }
        .backgroundSecondary()
    }

    private var settings: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            apperance
                .padding(.top, .xxxSmall)

            #if os(iOS)
            accentColor
            #endif

            advanded

            #if os(iOS)
            if iconSettings.iconNames.count > 1 {
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
        // swiftlint:disable multiple_closures_with_trailing_closure superfluous_disable_command
        .navigationTitle("Appearance")
        .preferredColorScheme(theme.appearance.colorScheme)
    }

    private var apperance: some View {
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
                                IconDeprecated(.checkCircle, color: Color.accent)
                            } else {
                                IconDeprecated(.circle, color: .onSurfaceSecondary)
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
                ForEach(0 ..< iconSettings.iconNames.count, id: \.self) { index in
                    HStack {
                        Image(uiImage: UIImage(named: iconSettings.iconNames[index]
                                ?? "AppIcon") ?? UIImage())
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 78, height: 78)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        index == iconSettings.currentIndex ? Color.accent : Color.border,
                                        lineWidth: index == iconSettings.currentIndex ? 3 : 1
                                    )
                            )
                            .onTapGesture {
                                if index != 0, isPremium == false {
                                    router.present(.premium)
                                } else {
                                    let defaultIconIndex = iconSettings.iconNames
                                        .firstIndex(of: UIApplication.shared.alternateIconName) ?? 0
                                    if defaultIconIndex != index {
                                        // swiftlint:disable line_length
                                        UIApplication.shared.setAlternateIconName(iconSettings.iconNames[index]) { error in
                                            if let error {
                                                log(error.localizedDescription)
                                            } else {
                                                log("Success! You have changed the app icon.")
                                            }
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
            VStack(spacing: .zero) {
                Row("Fonts") {
                    router.move(.font)
                } leading: {
                    textIcon.icon()
                }
                .rowArrow()
                .premium()
                .onPremiumTap()

                Switch(isOn: theme.$borderApp) {
                    Row("Borders") {
                        router.move(.border)
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
                    router.move(.radius)
                } leading: {
                    radiusIcon.icon()
                }
                .rowArrow()
                .premium()
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

#if os(iOS)
@MainActor
public class AppIconSettings: ObservableObject {
    public var iconNames: [String?] = [nil]
    @Published public var currentIndex = 0

    public init() {
        getAlternateIconNames()

        if let currentIcon = UIApplication.shared.alternateIconName {
            currentIndex = iconNames.firstIndex(of: currentIcon) ?? 0
        }
    }

    private func getAlternateIconNames() {
        if let iconCount = FeatureFlags.app.alternateAppIcons, iconCount != 0 {
            for index in 1 ... iconCount {
                iconNames.append("AlternateAppIcon\(index)")
            }
        }
    }
}
#endif

struct SettingsThemeView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingView()
            .previewPhones()
    }
}
