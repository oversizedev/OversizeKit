//
// Copyright © 2023 Alexander Romanov
// SaveForView.swift
//

import EventKit
import OversizeUI
import SwiftUI

public struct SaveForView: View {
    @Environment(\.dismiss) var dismiss
    @Binding private var span: EKSpan?

    public init(selection: Binding<EKSpan?>) {
        _span = selection
    }

    public var body: some View {
        PageView("This is repeating event") {
            SectionView {
                VStack(spacing: .zero) {
                    Row("Save for this event only") {
                        span = .thisEvent
                        dismiss()
                    } leading: {
                        Image.Date.calendar
                            .renderingMode(.template)
                            .foregroundColor(.onSurfaceHighEmphasis)
                    }

                    Row("Save for feature events") {
                        span = .futureEvents
                        dismiss()
                    } leading: {
                        Image.Base.calendar
                            .renderingMode(.template)
                            .foregroundColor(.onSurfaceHighEmphasis)
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
