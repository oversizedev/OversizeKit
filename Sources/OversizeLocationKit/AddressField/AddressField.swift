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
    @Environment(\.fieldLabelPosition) private var fieldPlaceholderPosition: FieldLabelPosition
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

    var isSlectedAddress: Bool {
        if let seletedAddress, !seletedAddress.isEmpty {
            true
        } else {
            false
        }
    }

    var addressText: String {
        if isSlectedAddress {
            seletedAddress ?? "Address selected"
        } else if let seletedLocation {
            "Сoordinates: \(seletedLocation.latitude), \(seletedLocation.longitude)"
        } else {
            "Address"
        }
    }

    public var body: some View {
        Button {
            #if !os(watchOS)
            isShowPicker.toggle()
            #endif
        } label: {
            VStack(alignment: .leading, spacing: .xSmall) {
                if fieldPlaceholderPosition == .adjacent {
                    HStack {
                        Text(title)
                            .subheadline(.medium)
                            .foregroundColor(.onSurfacePrimary)
                        Spacer()
                    }
                }

                HStack {
                    ZStack(alignment: .leading) {
                        if fieldPlaceholderPosition == .overInput {
                            Text(title)
                                .font(!isSlectedAddress ? .headline : .subheadline)
                                .fontWeight(!isSlectedAddress ? .medium : .semibold)
                                .onSurfaceTertiaryForeground()
                                .offset(y: !isSlectedAddress ? 0 : -13)
                                .opacity(!isSlectedAddress ? 0 : 1)
                        }

                        Text(addressText)
                            .padding(.vertical, fieldPlaceholderPosition == .overInput ? .xxxSmall : .zero)
                            .offset(y: fieldOffset)
                            .lineLimit(1)
                    }
                    Spacer()
                    IconDeprecated(.chevronDown, color: .onSurfacePrimary)
                }
            }
            .contentShape(Rectangle())
        }
        .foregroundColor(.onSurfacePrimary)
        .buttonStyle(.field)
        #if !os(watchOS)
            .sheet(isPresented: $isShowPicker) {
                AddressPicker(address: $seletedAddress, location: $seletedLocation, place: $seletedPlace)
            }
        #endif
    }

    private var fieldOffset: CGFloat {
        switch fieldPlaceholderPosition {
        case .default:
            0
        case .adjacent:
            0
        case .overInput:
            !isSlectedAddress ? 0 : 10
        }
    }
}
