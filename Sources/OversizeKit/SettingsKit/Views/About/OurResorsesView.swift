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
                .surfaceContentRowMargins()
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
                        Row("GitHub Open Source") {
                            githubIcon
                        }
                    }
                    .buttonStyle(.row)
                }

                if let figmaUrl = URL(string: "https://www.figma.com/@oversizedesign") {
                    Link(destination: figmaUrl) {
                        Row("Figma Community") {
                            figmaIcon
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
            return Image.Brands.figma
        case .fill:
            return Image.Brands.figma
        case .twoTone:
            return Image.Brands.figma
        }
    }

    var githubIcon: Image {
        switch iconStyle {
        case .line:
            return Image.Brands.github
        case .fill:
            return Image.Brands.github
        case .twoTone:
            return Image.Brands.github
        }
    }
}
