//
// Copyright © 2022 Alexander Romanov
// StoreFeaturesView.swift
//

import OversizeCore
import OversizeModules
import OversizeResources
import OversizeServices
import OversizeSettingsService
import OversizeUI
import SwiftUI

struct StoreFeaturesView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    @State var selection: StoreFeature?

    let features = AppInfo.store.features

    var body: some View {
        Surface {
            VStack {
                ForEach(features) { feature in
                    Row(feature.title.valueOrEmpty, subtitle: feature.subtitle.valueOrEmpty) {
                        selection = feature
                    }
                    .rowLeading(.imageOnSurface(feature.image != nil
                            ? Image(resourceImage: feature.image.valueOrEmpty)
                            : Icon.Solid.UserInterface.checkCrFr,
                        color: Color.onPrimaryHighEmphasis))
                    .rowTrailing(.arrowIcon)
                    .rowIconBackgroundColor(backgroundColor(feature: feature))
                    .controlPadding(horizontal: .medium, vertical: .small)
                }
            }
        }
        .surfaceBorderColor(Color.surfaceSecondary, width: 2)
        .controlPadding(horizontal: .zero, vertical: .xSmall)
        .sheet(item: $selection) {
            selection = nil
        } content: { feature in
            StoreFeatureDetailView(selection: feature)
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .systemServices()
        }
    }

    func backgroundColor(feature: StoreFeature) -> Color {
        if let color = feature.backgroundColor {
            return Color(hex: color)
        } else {
            return Color.accent
        }
    }
}

struct StoreFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        StoreFeaturesView()
    }
}
