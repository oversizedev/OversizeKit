import OversizeNetwork
import OversizeUI
import SwiftUI

struct AppUpdatesLatestVersionCard: View {
    let version: Components.Schemas.Version

    var body: some View {
        Surface {
            HStack(alignment: .top, spacing: .medium) {
                ZStack {
                    Circle()
                        .fill(Color.success.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Icon(Image.Base.Check.Circle.fill)
                        .iconColor(.success)
                }

                VStack(alignment: .leading, spacing: .xSmall) {
                    HStack(alignment: .center, spacing: .xSmall) {
                        Text(version.version)
                            .title3(.bold)
                            .onSurfacePrimary()

                        Badge {
                            Text("Latest")
                        }
                    }

                    if let whatsNew = version.whatsNew {
                        Text(whatsNew)
                            .body()
                            .onSurfaceSecondary()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.medium)
        }
        .surfaceRadius(.medium)
        .surfaceContentMargins(.zero)
        .elevation(.z1)
    }
}

#Preview {
    AppUpdatesLatestVersionCard(version: .init(
        id: 1,
        version: "2.4.0",
        releasedAt: .now,
        whatsNew: "Faster sync, cleaner settings layout, and a few small fixes.",
        features: nil
    ))
    .padding()
    .background(Color.backgroundSecondary)
}
