//
// Copyright © 2022 Alexander Romanov
// SearchHistoryAddress.swift
//

import Foundation
import OversizeLocationService

public struct SearchHistoryAddress: Identifiable, Codable {
    public let id: String
    public let address: String?
    public let location: SearchHistoryLocationCoordinate?
    public let place: LocationAddress?

    public enum CardKeys: CodingKey {
        case id
        case seletedAddress
        case seletedLocation
        case seletedPlace
    }

    public init(id: String, address: String?, location: SearchHistoryLocationCoordinate?, place: LocationAddress?) {
        self.id = id
        self.address = address
        self.location = location
        self.place = place
    }
}
