import OversizeUI
import SwiftUI

struct AppUpdatesPlaceholderRow: View {
    var body: some View {
        Row("Version 1.0.0", subtitle: "What's new in this version") {}
            .rowArrow()
            .buttonStyle(.row)
    }
}

#Preview {
    AppUpdatesPlaceholderRow()
        .padding()
        .background(Color.backgroundSecondary)
}
