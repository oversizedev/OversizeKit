//
// Copyright © 2022 Alexander Romanov
// AddressPickerViewModel.swift
//

import Combine
import CoreLocation
import Factory
import MapKit
import OversizeLocationService
import OversizeModels
import SwiftUI

#if !os(watchOS)
@MainActor
class AddressPickerViewModel: NSObject, ObservableObject {
    @Injected(\.locationService) var locationService: LocationServiceProtocol

    @Published var locationResults: [MKLocalSearchCompletion] = .init()
    @Published var searchTerm: String = .init()
    @AppStorage("AppState.LastSearchAddresses") var lastSearchAddresses: [SearchHistoryAddress] = .init()

    @Published var currentLocation: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)

    @Published var isFetchUpdatePositon: Bool = .init(false)
    @Published var isSaveCurentPositon: Bool = .init(false)
    @Published var isSaveFromSearth: Bool = .init(false)

    private var cancellables: Set<AnyCancellable> = []

    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise: ((Result<[MKLocalSearchCompletion], Error>) -> Void)?

    @State var appError: AppError?

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])

        $searchTerm
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { currentSearchTerm in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            }
            .sink(receiveCompletion: { _ in
                // Handle error
            }, receiveValue: { results in
                self.locationResults = results
            })
            .store(in: &cancellables)
    }

    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
}

extension AddressPickerViewModel: @preconcurrency MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        currentPromise?(.success(completer.results))
    }

    func completer(_: MKLocalSearchCompleter, didFailWithError _: Error) {}
}

extension AddressPickerViewModel {
    func updateCurrentPosition() async throws {
        let status = locationService.permissionsStatus()
        switch status {
        case .success:
            isFetchUpdatePositon = true
            let currentPosition = try await locationService.currentLocation()
            guard let newLocation = currentPosition else { return }
            currentLocation = newLocation
            print("📍 Location: \(newLocation.latitude), \(newLocation.longitude)")
            isFetchUpdatePositon = false
        case let .failure(error):
            appError = error
        }
    }
}
#endif
