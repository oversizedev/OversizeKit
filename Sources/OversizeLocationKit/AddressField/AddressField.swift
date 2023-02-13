//
// Copyright © 2023 Alexander Romanov
// AddressField.swift
//

import MapKit
import OversizeLocationService
import OversizeUI
import SwiftUI

public struct AddressField: View {
    @Environment(\.theme) private var theme: ThemeSettings
    @Binding private var seletedAddress: String?
    @Binding private var seletedLocation: CLLocationCoordinate2D?
    @Binding private var seletedPlace: LocationAddress?

    private let title: String
    @State var isShowPicker: Bool = false

    public init(
        _ title: String = "Address",
        address: Binding<String?> = .constant(nil),
        location: Binding<CLLocationCoordinate2D?> = .constant(nil),
        place: Binding<LocationAddress?> = .constant(nil)
    ) {
        self.title = title
        _seletedAddress = address
        _seletedLocation = location
        _seletedPlace = place
    }

    var addressText: String {
        if let seletedAddress, !seletedAddress.isEmpty {
            return seletedAddress
        } else if let seletedLocation {
            return "Сoordinates: \(seletedLocation.latitude), \(seletedLocation.longitude)"
        } else {
            return "Address"
        }
    }

    public var body: some View {
        Button {
            isShowPicker.toggle()
        } label: {
            HStack {
                Text(title)
                Spacer()
                Icon(.chevronDown, color: .onSurfaceHighEmphasis)
            }
            .contentShape(Rectangle())
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Radius.medium,
                             style: .continuous)
                .fill(Color.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.medium,
                                     style: .continuous)
                        .stroke(theme.borderTextFields
                            ? Color.border
                            : Color.surfaceSecondary, lineWidth: CGFloat(theme.borderSize))
                )
        )
        .headline()
        .foregroundColor(.onSurfaceHighEmphasis)
        .buttonStyle(.scale)
        .sheet(isPresented: $isShowPicker) {
            AddressPicker(address: $seletedAddress, location: $seletedLocation, place: $seletedPlace)
        }
    }
}
