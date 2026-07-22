import OversizeNetwork
import OversizeUI
import SwiftUI

struct AppUpdatesVersionRow: View {
    let version: Components.Schemas.Version
    var showsConnector: Bool = true

    var body: some View {
        Surface {
            HStack(alignment: .top, spacing: .medium) {
                VStack(spacing: .xxSmall) {
                    Circle()
                        .fill(Color.onSurfaceTertiary)
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)

                    if showsConnector {
                        Separator(.vertical)
                            .frame(width: 10)
                    }
                }
                .frame(width: 16)

                VStack(alignment: .leading, spacing: .xSmall) {
                    Text(version.version)
                        .headline()
                        .onSurfacePrimary()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let whatsNew = version.whatsNew {
                        Text(whatsNew)
                            .body()
                            .onSurfaceSecondary()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.top, .xxxSmall)
            }
            .padding(.medium)
        }
        .surfaceRadius(.medium)
        .surfaceContentMargins(.zero)
        .elevation(.z1)
    }
}

#Preview {
    VStack(spacing: 12) {
        AppUpdatesVersionRow(version: .init(
            id: 1,
            version: "2.3.0",
            releasedAt: .now,
            whatsNew: "Added smarter reminders and improved performance across the app.",
            features: nil
        ))

        AppUpdatesVersionRow(
            version: .init(
                id: 2,
                version: "1.0.0",
                releasedAt: .now,
                whatsNew: nil,
                features: nil
            ),
            showsConnector: false
        )
    }
    .padding()
    .background(Color.backgroundSecondary)
}
