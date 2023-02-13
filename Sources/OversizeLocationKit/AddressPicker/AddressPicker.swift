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

public struct AddressPicker: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddressPickerViewModel()
    @FocusState private var isFocusSearth

    @Binding private var seletedAddress: String?
    @Binding private var seletedLocation: CLLocationCoordinate2D?
    @Binding private var seletedPlace: LocationAddress?

    public init(
        address: Binding<String?> = .constant(nil),
        location: Binding<CLLocationCoordinate2D?> = .constant(nil),
        place: Binding<LocationAddress?> = .constant(nil)
    ) {
        _seletedAddress = address
        _seletedLocation = location
        _seletedPlace = place
    }

    public var body: some View {
        PageView("Location") {
            LazyVStack(spacing: .zero) {
                if viewModel.appError != nil {
                    currentLocation
                }

                if viewModel.searchTerm.isEmpty, !viewModel.lastSearchAddresses.isEmpty {
                    HStack(spacing: .zero) {
                        Text("Recent")
                        Spacer()
                    }
                    .title3()
                    .onSurfaceMediumEmphasisForegroundColor()
                    .padding(.vertical, .xxSmall)
                    .paddingContent(.horizontal)

                    recentResults
                } else {
                    results
                }
            }
        }
        .leadingBar {
            BarButton(.close)
        }
        .topToolbar {
            TextField("Search places or addresses", text: $viewModel.searchTerm)
                .submitScope(viewModel.searchTerm.count < 2)
                .textFieldStyle(DefaultPlaceholderTextFieldStyle())
                .focused($isFocusSearth)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.searchTerm.count > 2 {
                        viewModel.isSaveFromSearth = true
                        seletedAddress = viewModel.searchTerm
                        Task {
                            let coordinate = try? await viewModel.locationService.fetchCoordinateFromAddress(viewModel.searchTerm)
                            if let coordinate {
                                let address = try? await viewModel.locationService.fetchAddressFromLocation(coordinate)
                                seletedLocation = coordinate
                                seletedPlace = address
                            } else {
                                seletedPlace = nil
                                seletedLocation = nil
                            }
                            viewModel.isSaveFromSearth = false
                            saveToHistory()
                            dismiss()
                        }
                    }
                }
                .overlay(alignment: .trailing) {
                    if viewModel.isSaveFromSearth {
                        ProgressView()
                            .padding(.trailing, .xSmall)
                    }
                }
        }
        // .scrollDismissesKeyboard(.immediately)
        .task(priority: .background) {
            do {
                try await viewModel.updateCurrentPosition()
                if viewModel.isSaveCurentPositon {
                    onSaveCurrntPosition()
                }
            } catch {}
        }
        .onAppear {
            isFocusSearth = true
        }
    }

    private var currentLocation: some View {
        Row("Current Location") {
            if viewModel.isFetchUpdatePositon {
                viewModel.isSaveCurentPositon = true
            } else {
                onSaveCurrntPosition()
            }
        }
        .rowLeading(.iconOnSurface(.navigation))
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
            }
            .rowLeading(.iconOnSurface(.mapPin))
            .rowClearButton {
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
            }
            .rowLeading(.iconOnSurface(.mapPin))
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
                    onCompleteSearth(seletedAddress: address, seletedLocation: c, seletedPlace: reversedGeoLocation)
                }
            }
        }
    }

    func onCompleteSearth(seletedAddress: String?, seletedLocation: CLLocationCoordinate2D?, seletedPlace: LocationAddress?, saveToHistory: Bool = true) {
        if let seletedAddress {
            self.seletedAddress = seletedAddress
        } else {
            self.seletedAddress = seletedPlace?.address
        }
        self.seletedLocation = seletedLocation
        self.seletedPlace = seletedPlace
        if saveToHistory {
            self.saveToHistory()
        }
        dismiss()
    }

    private func onSaveCurrntPosition() {
        Task {
            let address = try? await viewModel.locationService.fetchAddressFromLocation(viewModel.currentLocation)
            if let address {
                seletedAddress = address.address
                seletedPlace = address
            } else {
                seletedAddress = nil
                seletedPlace = nil
            }
            seletedLocation = viewModel.currentLocation
            saveToHistory()
            dismiss()
        }
    }

    func saveToHistory() {
        let lastSearth: SearchHistoryAddress
        if let seletedLocation {
            lastSearth = SearchHistoryAddress(
                id: UUID().uuidString,
                address: seletedAddress,
                location: SearchHistoryLocationCoordinate(coordinate: seletedLocation),
                place: seletedPlace
            )
        } else {
            lastSearth = SearchHistoryAddress(
                id: UUID().uuidString,
                address: seletedAddress,
                location: nil,
                place: seletedPlace
            )
        }
        viewModel.lastSearchAddresses.append(lastSearth)
    }

    private func onDoneAction() {
        dismiss()
    }
}
