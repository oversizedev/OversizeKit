//
// Copyright © 2023 Alexander Romanov
// AttachmentView.swift
//

import OversizeUI
import SwiftUI

public struct AttachmentView: View {
    public init() {}

    public var body: some View {
        PageView("Attachment") {
            SectionView {
                VStack(spacing: .zero) {
                    Row("Add investment") {
                        Image.Base.attach
                            .icon()
                    }

                    Row("Add link") {
                        Image.Base.link
                            .icon()
                    }
                }
            }
            .surfaceContentRowMargins()
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(.close)
        }
    }
}

struct AttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentView()
    }
}
