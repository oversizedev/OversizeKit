//
// Copyright © 2022 Alexander Romanov
// SearchHistoryLocationCoordinate.swift
//

import Foundation
import MapKit

public struct SearchHistoryLocationCoordinate: Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    public enum CardKeys: CodingKey {
        case latitude
        case longitude
    }
}
