//
// Copyright © 2022 Alexander Romanov
// AddressPicker.swift
//

import Combine
import CoreLocation
import MapKit
import OversizeCore
import OversizeLocationService
import OversizeUI
import SwiftUI

#if !os(watchOS) && !os(tvOS)
public struct AddressPicker: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddressPickerViewModel()
    @State private var isFocusSearth = true

    @Binding private var seletedAddress: String?
    @Binding private var seletedLocation: CLLocationCoordinate2D?
    @Binding private var seletedPlace: LocationAddress?
    private let onSelect: ((String?, CLLocationCoordinate2D?, LocationAddress?) -> Void)?

    public init(
        address: Binding<String?> = .constant(nil),
        location: Binding<CLLocationCoordinate2D?> = .constant(nil),
        place: Binding<LocationAddress?> = .constant(nil),
        onSelect: ((String?, CLLocationCoordinate2D?, LocationAddress?) -> Void)? = nil
    ) {
        _seletedAddress = address
        _seletedLocation = location
        _seletedPlace = place
        self.onSelect = onSelect
    }

    public var body: some View {
        LayoutView("Location") {
            LazyVStack(spacing: .zero) {
                if viewModel.isSaveFromSearth {
                    searchPlaceholder
                }
                if viewModel.appError == nil {
                    currentLocation
                }

                if viewModel.searchTerm.isEmpty, !viewModel.lastSearchAddresses.isEmpty {
                    HStack(spacing: .zero) {
                        Text("Recent")
                        Spacer()
                    }
                    .title3()
                    .onSurfaceSecondary()
                    .padding(.vertical, .xxSmall)
                    .paddingContent(.horizontal)

                    recentResults
                } else {
                    results
                }
            }
        }
        #if os(iOS)
        .searchable(text: $viewModel.searchTerm, isPresented: $isFocusSearth, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search places or addresses")
        #else
        .searchable(text: $viewModel.searchTerm, isPresented: $isFocusSearth, placement: .toolbar, prompt: "Search places or addresses")
        #endif
        .onSubmit(of: .search) {
            if viewModel.searchTerm.count > 2 {
                viewModel.isSaveFromSearth = true
                seletedAddress = viewModel.searchTerm
                Task {
                    let coordinate = try? await viewModel.locationService.fetchCoordinateFromAddress(viewModel.searchTerm)
                    if let coordinate {
                        let address = try? await viewModel.locationService.fetchAddressFromLocation(coordinate)
                        onCompleteSearth(seletedAddress: viewModel.searchTerm, seletedLocation: coordinate, seletedPlace: address)
                    } else {
                        onCompleteSearth(seletedAddress: viewModel.searchTerm, seletedLocation: nil, seletedPlace: nil)
                    }
                    viewModel.isSaveFromSearth = false
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS) && !os(watchOS)
                .keyboardShortcut(.cancelAction)
                #endif
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .task {
            await viewModel.updateCurrentPosition()
            if viewModel.isSaveCurentPositon {
                onSaveCurrntPosition()
            }
        }
    }

    private var searchPlaceholder: some View {
        ForEach(0 ..< 3, id: \.self) { _ in
            Row("Address placeholder", subtitle: "City, Country") {} leading: {
                Image(systemName: "mappin")
                    .iconOnSurface()
            }
            .redacted(reason: .placeholder)
            .disabled(true)
        }
    }

    private var currentLocation: some View {
        Row("Current Location") {
            if viewModel.isFetchUpdatePositon {
                viewModel.isSaveCurentPositon = true
            } else {
                onSaveCurrntPosition()
            }
        } leading: {
            Image.Base.nearMe
                .icon
                .iconOnSurface()
        }
        .padding(.bottom, viewModel.searchTerm.isEmpty ? .small : .zero)
        .loading(viewModel.isSaveCurentPositon)
    }

    private var recentResults: some View {
        ForEach(viewModel.lastSearchAddresses.reversed()) { address in
            Row(address.address ?? address.place?.address ?? "Latitude: \(address.location?.latitude ?? 0), longitude:longitude \(address.location?.longitude ?? 0)") {
                if let latitude = address.location?.latitude, let longitude = address.location?.longitude {
                    onCompleteSearth(seletedAddress: address.address, seletedLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), seletedPlace: address.place, saveToHistory: false)
                } else {
                    onCompleteSearth(seletedAddress: address.address, seletedLocation: nil, seletedPlace: address.place, saveToHistory: false)
                }
            } leading: {
                Image.Base.location
                    .icon
                    .iconOnSurface()
            }
            .rowClearButton(style: .onSurface) {
                if let fooOffset = viewModel.lastSearchAddresses.firstIndex(where: { $0.id == address.id }) {
                    viewModel.lastSearchAddresses.remove(at: fooOffset)
                }
            }
        }
    }

    private var results: some View {
        ForEach(viewModel.locationResults, id: \.self) { location in
            Row(location.title, subtitle: location.subtitle) {
                reverseGeo(location: location)
            } leading: {
                Image.Base.location
                    .icon
                    .iconOnSurface()
            }
        }
    }

    func reverseGeo(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK: CLLocationCoordinate2D?
        search.start { response, error in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }

            if let c = coordinateK {
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode, \(errorString)")
                        return
                    }

                    let reversedGeoLocation = LocationAddress(with: placemark)

                    let address = "\(reversedGeoLocation.streetName) \(reversedGeoLocation.streetNumber)".capitalizingFirstLetter()
                    Task { @MainActor in
                        onCompleteSearth(seletedAddress: address, seletedLocation: c, seletedPlace: reversedGeoLocation)
                    }
                }
            }
        }
    }

    func onCompleteSearth(seletedAddress: String?, seletedLocation: CLLocationCoordinate2D?, seletedPlace: LocationAddress?, saveToHistory: Bool = true) {
        let selectedAddress = seletedAddress ?? seletedPlace?.address
        self.seletedAddress = selectedAddress
        self.seletedLocation = seletedLocation
        self.seletedPlace = seletedPlace
        if saveToHistory {
            self.saveToHistory()
        }
        onSelect?(selectedAddress, seletedLocation, seletedPlace)
        dismiss()
    }

    private func onSaveCurrntPosition() {
        Task {
            let address = try? await viewModel.locationService.fetchAddressFromLocation(viewModel.currentLocation)
            onCompleteSearth(
                seletedAddress: address?.address,
                seletedLocation: viewModel.currentLocation,
                seletedPlace: address
            )
        }
    }

    func saveToHistory() {
        let lastSearth = if let seletedLocation {
            SearchHistoryAddress(
                id: UUID().uuidString,
                address: seletedAddress,
                location: SearchHistoryLocationCoordinate(coordinate: seletedLocation),
                place: seletedPlace
            )
        } else {
            SearchHistoryAddress(
                id: UUID().uuidString,
                address: seletedAddress,
                location: nil,
                place: seletedPlace
            )
        }
        viewModel.lastSearchAddresses.append(lastSearth)
    }
}

#Preview {
    NavigationStack {
        AddressPicker()
    }
}
#endif
