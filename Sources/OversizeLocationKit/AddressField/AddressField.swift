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
            return true
        } else {
            return false
        }
    }

    var addressText: String {
        if isSlectedAddress {
            return seletedAddress ?? "Address selected"
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
            VStack(alignment: .leading, spacing: .xSmall) {
                if fieldPlaceholderPosition == .adjacent {
                    HStack {
                        Text(title)
                            .subheadline(.medium)
                            .foregroundColor(.onSurfaceHighEmphasis)
                        Spacer()
                    }
                }

                HStack {
                    ZStack(alignment: .leading) {
                        if fieldPlaceholderPosition == .overInput {
                            Text(title)
                                .font(!isSlectedAddress ? .headline : .subheadline)
                                .fontWeight(!isSlectedAddress ? .medium : .semibold)
                                .onSurfaceDisabledForegroundColor()
                                .offset(y: !isSlectedAddress ? 0 : -13)
                                .opacity(!isSlectedAddress ? 0 : 1)
                        }

                        Text(addressText)
                            .padding(.vertical, fieldPlaceholderPosition == .overInput ? .xxxSmall : .zero)
                            .offset(y: fieldOffset)
                            .lineLimit(1)
                    }
                    Spacer()
                    Icon(.chevronDown, color: .onSurfaceHighEmphasis)
                }
            }
            .contentShape(Rectangle())
        }
        .foregroundColor(.onSurfaceHighEmphasis)
        .buttonStyle(.field)
        .sheet(isPresented: $isShowPicker) {
            AddressPicker(address: $seletedAddress, location: $seletedLocation, place: $seletedPlace)
        }
    }

    private var fieldOffset: CGFloat {
        switch fieldPlaceholderPosition {
        case .default:
            return 0
        case .adjacent:
            return 0
        case .overInput:
            return !isSlectedAddress ? 0 : 10
        }
    }
}
