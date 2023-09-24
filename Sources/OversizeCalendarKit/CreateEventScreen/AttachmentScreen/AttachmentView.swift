//
// Copyright © 2023 Alexander Romanov
// AttachmentView.swift
//

import OversizeResources
import OversizeUI
import SwiftUI

public struct AttachmentView: View {
    public init() {}

    public var body: some View {
        PageView("Attachment") {
            SectionView {
                VStack(spacing: .zero) {
                    Row("Add investment") {
                        IconDeprecated(.paperclip)
                            .iconColor(.onSurfaceHighEmphasis)
                    }

                    Row("Add link") {
                        IconDeprecated(.link)
                            .iconColor(.onSurfaceHighEmphasis)
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
