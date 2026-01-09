//
// Copyright © 2022 Alexander Romanov
// FontSettingView.swift
//

import OversizeNavigation
import OversizeUI
import SwiftUI

public struct FontSettingView: View {
    private enum FontSetting: String, CaseIterable {
        case title, paragraph, other
    }

    @Environment(\.theme) private var theme: ThemeSettings

    @State private var activeTab: FontSetting = .title
    @State var offset = CGPoint(x: 0, y: 0)

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            previewText

            SegmentedPickerSelector(FontSetting.allCases, selection: $activeTab) { item, _ in
                Text(item.rawValue.capitalizingFirstLetter())
            } selectionView: {}
                .animation(.default, value: activeTab)

            getActiveTabContent(tab: activeTab)
                .padding(.top, .small)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .navigationBar("Fonts", style: .fixed($offset)) {
            BarButton(.back)
        } trailingBar: {} bottomBar: {}
    }

    @ViewBuilder
    private func getActiveTabContent(tab: FontSetting) -> some View {
        switch tab {
        case .title:
            titleSelector
        case .paragraph:
            paragraphSelector
        case .other:
            otherSelector
        }
    }

    private var titleSelector: some View {
        GridSelect(
            FontDesignType.allCases,
            selection: theme.$fontTitle,
            content: { fontStyle, _ in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Aa")
                            .font(.system(size: 34, weight: .heavy, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)

                        Text(fontStyle.rawValue.capitalizingFirstLetter())
                            .font(.system(size: 16, weight: .medium, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)
                    }
                    Spacer()
                }.padding()
            }
        ).gridSelectStyle(.default(selected: .graySurface))
    }

    private var paragraphSelector: some View {
        GridSelect(
            FontDesignType.allCases,
            selection: theme.$fontParagraph,
            content: { fontStyle, _ in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Aa")
                            .font(.system(size: 34, weight: .heavy, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)

                        Text(fontStyle.rawValue.capitalizingFirstLetter())
                            .font(.system(size: 16, weight: .medium, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)
                    }
                    Spacer()
                }.padding()
            }
        ).gridSelectStyle(.default(selected: .graySurface))
    }

    private var otherSelector: some View {
        VStack(alignment: .leading, spacing: .medium) {
            VStack(alignment: .leading, spacing: .small) {
                Text("Button".uppercased())
                    .bold()
                    .caption()
                    .onBackgroundSecondary()
                SegmentedPickerSelector(FontDesignType.allCases, selection: theme.$fontButton) { fontStyle, _ in
                    VStack(alignment: .center, spacing: 8) {
                        Text("Aa")
                            .font(.system(size: 28, weight: .heavy, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)

                        Text(fontStyle.rawValue.capitalizingFirstLetter())
                            .font(.system(size: 12, weight: .medium, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)
                    }
                }
                .segmentedControlStyle(.island(selected: .graySurface))
            }

            VStack(alignment: .leading, spacing: .small) {
                Text("Overline & caption".uppercased())
                    .bold()
                    .caption()
                    .onBackgroundSecondary()
                SegmentedPickerSelector(FontDesignType.allCases, selection: theme.$fontOverline) { fontStyle, _ in
                    VStack(alignment: .center, spacing: 8) {
                        Text("Aa")
                            .font(.system(size: 28, weight: .heavy, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)

                        Text(fontStyle.rawValue.capitalizingFirstLetter())
                            .font(.system(size: 12, weight: .medium, design: fontStyle.system))
                            .foregroundColor(.onSurfacePrimary)
                    }
                }
                .segmentedControlStyle(.island(selected: .graySurface))
            }
        }
    }
}

// swiftlint:disable all
extension FontSettingView {
    private var previewText: some View {
        ScrollViewOffset(offset: $offset) {
            HStack {
                VStack(alignment: .leading, spacing: .medium) {
                    VStack(alignment: .leading, spacing: .xxSmall) {
                        Text("Overline".uppercased())
                            .bold()
                            .caption()
                            .onBackgroundSecondary()

                        Text("Large title")
                            .largeTitle()
                            .onBackgroundPrimary()

                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                            .body()
                            .onBackgroundSecondary()
                    }

                    VStack(alignment: .leading, spacing: .xxSmall) {
                        Text("Title")
                            .title3()
                            .onBackgroundPrimary()

                        Text("Subtitle")
                            .headline()
                            .onBackgroundPrimary()

                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                            .bold()
                            .subheadline()
                            .onBackgroundPrimary()

                        Text("Button")
                            .body()
                            .onBackgroundPrimary()
                            .padding(.top, .xxxSmall)
                    }
                }
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct FontSettingView_Previews: PreviewProvider {
    static var previews: some View {
        FontSettingView()
    }
}
