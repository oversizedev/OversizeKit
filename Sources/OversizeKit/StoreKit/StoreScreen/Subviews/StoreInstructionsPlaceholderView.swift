import OversizeComponents
import OversizeUI
import SwiftUI

struct StoreInstructionsPlaceholderView: View {
    let offset: CGFloat
    let contentHeight: CGFloat

    private var heroHeight: CGFloat? {
        contentHeight > 0 ? contentHeight : nil
    }

    var body: some View {
        VStack(spacing: .medium) {
            VStack {
                VStack(spacing: .xSmall) {
                    Text("Free Trial")
                        .footnote(.semibold)
                        .onBackgroundSecondary()
                        .padding(.bottom, .xxxSmall)
                        .redacted(reason: .placeholder)

                    Text("How your free trial works")
                        .largeTitle()
                        .foregroundColor(.onSurfacePrimary)

                    Text("Save --% on subscription")
                        .foregroundColor(.onSurfaceSecondary)
                        .body(.semibold)
                        .redacted(reason: .placeholder)
                }
                .multilineTextAlignment(.center)

                Spacer()

                stepsPlaceholder
                    .padding(.bottom, .medium)

                Spacer()
            }
            .frame(height: heroHeight)
            .overlay(alignment: .bottom) {
                ScrollArrow(width: 30, offset: -5 + (offset * 0.05))
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .foregroundColor(.onSurfacePrimary.opacity(0.3))
                    .frame(width: 30, height: 30)
                    .padding(.bottom, .small)
                    .opacity(1 - (offset * 0.01))
            }

            StoreFeaturesPlaceholderView()
                .paddingContent(.horizontal)
                .opacity(0 + (offset * 0.01))
        }
    }

    private var stepsPlaceholder: some View {
        VStack(alignment: .leading, spacing: .xxxSmall) {
            ForEach(0 ..< 3, id: \.self) { _ in
                Row("Step", subtitle: "Description") {} leading: {
                    Circle()
                        .fillSurfaceSecondary()
                        .frame(width: 44, height: 44)
                }
                .navigatable()
            }
        }
        .redacted(reason: .placeholder)
        .disabled(true)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StoreInstructionsPlaceholderView(offset: .zero, contentHeight: 546)
}
