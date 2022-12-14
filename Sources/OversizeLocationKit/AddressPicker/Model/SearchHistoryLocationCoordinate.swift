//
// Copyright © 2022 Alexander Romanov
// SearchHistoryLocationCoordinate.swift
//

import Foundation
import MapKit

public struct SearchHistoryLocationCoordinate: Codable, Identifiable {
    public let id: String
    public let latitude: Double
    public let longitude: Double

    public init(id: String = UUID().uuidString, latitude: Double, longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(id: String = UUID().uuidString, coordinate: CLLocationCoordinate2D) {
        self.id = id
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    public enum CardKeys: CodingKey {
        case latitude
        case longitude
        case id
    }
}
