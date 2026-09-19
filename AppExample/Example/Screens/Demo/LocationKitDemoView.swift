//
// Copyright © 2026 Alexander Romanov
// LocationKitDemoView.swift, created on 19.09.2026
//

import CoreLocation
import OversizeLocationKit
import OversizeUI
import SwiftUI

struct LocationKitDemoView: View {
    @State private var address: String?
    @State private var location: CLLocationCoordinate2D?
    @State private var isShowAddressPicker = false

    private let demoLocation = CLLocationCoordinate2D(latitude: 37.334_886, longitude: -122.008_988)

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Field") {
                    AddressField("Address", address: $address, location: $location)
                }

                SectionView("Screens") {
                    Row("Address picker", subtitle: address) {
                        isShowAddressPicker = true
                    } leading: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .navigatable()
                    .buttonStyle(.row)
                }
                .sectionContentCompactRowMargins()

                SectionView("Map") {
                    MapCoordinateView(location ?? demoLocation, annotation: address ?? "Apple Park")
                        .frame(height: 240)
                }
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Location")
        .sheet(isPresented: $isShowAddressPicker) {
            NavigationStack {
                AddressPicker(address: $address, location: $location)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LocationKitDemoView()
    }
    .appEnvironment()
}
