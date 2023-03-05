//
// Copyright © 2022 Alexander Romanov
// SaveForView.swift
//

import EventKit
import OversizeResources
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
                        Icon.Line.DateandTime.calendar05
                            .renderingMode(.template)
                            .foregroundColor(.onSurfaceHighEmphasis)
                    }

                    Row("Save for feature events") {
                        span = .futureEvents
                        dismiss()
                    } leading: {
                        Icon.Line.DateandTime.calendar03
                            .renderingMode(.template)
                            .foregroundColor(.onSurfaceHighEmphasis)
                    }
                }
            }
            .surfaceContentRowInsets()
        }
        .backgroundSecondary()
        .leadingBar {
            BarButton(.close)
        }
    }
}
