//
// Copyright © 2022 Alexander Romanov
// OurResorsesView.swift
//

#if canImport(MessageUI)
import MessageUI
#endif
import OversizeComponents
import OversizeLocalizable
import OversizeResources
import OversizeServices
import OversizeUI
import SwiftUI

public struct OurResorsesView: View {
    @Environment(\.iconStyle) var iconStyle: IconStyle
    public init() {}

    public var body: some View {
        Page("Our open resources") {
            links
                .surfaceContentRowMargins()
        }

        .backgroundSecondary()
    }

    private var links: some View {
        SectionView {
            VStack(alignment: .leading, spacing: .zero) {
                if let gitHubUrl = URL(string: "https://github.com/oversizedev") {
                    Link(destination: gitHubUrl) {
                        Row("GitHub Open Source") {
                            githubIcon.icon()
                        }
                    }
                    .buttonStyle(.row)
                }

                if let figmaUrl = URL(string: "https://www.figma.com/@oversizedesign") {
                    Link(destination: figmaUrl) {
                        Row("Figma Community") {
                            figmaIcon.icon()
                        }
                    }
                    .buttonStyle(.row)
                }
            }
        }
    }

    var figmaIcon: Image {
        switch iconStyle {
        case .line:
            Image.Brands.figma
        case .fill:
            Image.Brands.figma
        case .twoTone:
            Image.Brands.figma
        }
    }

    var githubIcon: Image {
        switch iconStyle {
        case .line:
            Image.Brands.github
        case .fill:
            Image.Brands.github
        case .twoTone:
            Image.Brands.github
        }
    }
}
