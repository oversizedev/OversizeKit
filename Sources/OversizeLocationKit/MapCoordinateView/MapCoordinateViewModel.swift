//
// Copyright © 2023 Alexander Romanov
// MapCoordinateViewModel.swift
//

import MapKit
import OversizeLocationService
import SwiftUI

@MainActor
public final class MapCoordinateViewModel: ObservableObject {
    @Published public var region: MKCoordinateRegion
    @Published public var userTrackingMode: MapUserTrackingMode = .follow
    @Published public var isShowRoutePickerSheet: Bool = false

    public let location: CLLocationCoordinate2D
    public let annotation: String?
    public let annotations: [MapPoint]

    public init(location: CLLocationCoordinate2D, annotation: String?) {
        self.location = location
        self.annotation = annotation
        annotations = [MapPoint(name: annotation.valueOrEmpty, coordinate: location)]
        region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    public func zoomIn() {
        if region.span.longitudeDelta / 2.5 > 0, region.span.latitudeDelta / 2.5 > 0 {
            withAnimation {
                region.span.latitudeDelta /= 2.5
                region.span.longitudeDelta /= 2.5
            }
        } else {
            withAnimation {
                region.span.latitudeDelta = 0.00033266201122472694
                region.span.longitudeDelta = 0.00059856596270435602
            }
        }
    }

    public func zoomOut() {
        if region.span.longitudeDelta * 2.5 < 134, region.span.latitudeDelta * 2.5 < 130 {
            withAnimation {
                region.span.latitudeDelta *= 2.5
                region.span.longitudeDelta *= 2.5
            }
        } else {
            withAnimation {
                region.span.latitudeDelta = 130
                region.span.longitudeDelta = 130
            }
        }
    }

    public func positionInLocation() {
        withAnimation {
            region.center = location
            region.span.latitudeDelta = 0.1
            region.span.longitudeDelta = 0.1
        }
    }
}
