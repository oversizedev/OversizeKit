//
// Copyright © 2022 Alexander Romanov
// StoreFeaturesView.swift
//

import OversizeCore
import OversizeResources
import OversizeServices
import OversizeUI
import SwiftUI

struct StoreFeaturesView: View {
    @EnvironmentObject var viewModel: StoreViewModel
    @State var selection: PlistConfiguration.Store.StoreFeature?

    let features = Info.store.features

    var body: some View {
        Surface {
            VStack {
                ForEach(features) { feature in
                    Row(feature.title.valueOrEmpty, subtitle: feature.subtitle.valueOrEmpty) {
                        selection = feature
                    } leading: {
                        Group {
                            if feature.image != nil {
                                Image(resourceImage: feature.image.valueOrEmpty)
                                    .renderingMode(.template)
                            } else {
                                Icon.Solid.UserInterface.checkCrFr
                                    .renderingMode(.template)
                            }
                        }
                        .onPrimaryHighEmphasisForegroundColor()
                        .iconOnSurface(surfaceSolor: backgroundColor(feature: feature))
                    }
                    .rowArrow()
                    .rowIconBackgroundColor(backgroundColor(feature: feature))
                }
            }
        }
        .surfaceBorderColor(Color.surfaceSecondary)
        .surfaceBorderWidth(2)
        .surfaceContentRowInsets()
        .sheet(item: $selection) {
            selection = nil
        } content: { feature in
            StoreFeatureDetailView(selection: feature)
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .systemServices()
        }
    }

    func backgroundColor(feature: PlistConfiguration.Store.StoreFeature) -> Color {
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
