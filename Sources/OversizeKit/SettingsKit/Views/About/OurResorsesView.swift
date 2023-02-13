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
    @State private var isShowMail = false
    public init() {}

    public var body: some View {
        PageView("Our open resources") {
            links
        }
        .leadingBar {
            BarButton(.back)
        }
        .backgroundSecondary()
    }

    private var links: some View {
        SectionView {
            VStack(alignment: .leading, spacing: .zero) {
                if let gitHubUrl = URL(string: "https://github.com/oversizedev") {
                    Link(destination: gitHubUrl) {
                        Row("GitHub Open Source")
                            .rowLeading(.image(githubIcon))
                    }
                    .buttonStyle(.row)
                }

                if let figmaUrl = URL(string: "https://www.figma.com/@oversizedesign") {
                    Link(destination: figmaUrl) {
                        Row("Figma Community")
                            .rowLeading(.image(figmaIcon))
                    }
                    .buttonStyle(.row)
                }
            }
        }
    }

    var figmaIcon: Image {
        switch iconStyle {
        case .line:
            return Icon.Line.SocialMediaandBrands.figma
        case .solid:
            return Icon.Solid.SocialMediaandBrands.figma
        case .duotone:
            return Icon.Duotone.SocialMediaandBrands.figma
        }
    }

    var githubIcon: Image {
        switch iconStyle {
        case .line:
            return Icon.Line.SocialMediaandBrands.github
        case .solid:
            return Icon.Solid.SocialMediaandBrands.github
        case .duotone:
            return Icon.Duotone.SocialMediaandBrands.github
        }
    }
}
