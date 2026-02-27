//
// Copyright © 2023 Alexander Romanov
// MapCoordinateViewModel.swift
//

import MapKit
import Observation
import OversizeLocationService
import SwiftUI

@MainActor
@Observable
public final class MapCoordinateViewModel {
    public var cameraPosition: MapCameraPosition
    public var isShowRoutePickerSheet: Bool = false

    public let location: CLLocationCoordinate2D
    public let annotation: String?
    public let annotations: [MapPoint]

    private var region: MKCoordinateRegion

    public init(location: CLLocationCoordinate2D, annotation: String?) {
        self.location = location
        self.annotation = annotation
        annotations = [MapPoint(name: annotation.valueOrEmpty, coordinate: location)]
        let initialRegion = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        region = initialRegion
        cameraPosition = .region(initialRegion)
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
        cameraPosition = .region(region)
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
        cameraPosition = .region(region)
    }

    public func positionInLocation() {
        withAnimation {
            region.center = location
            region.span.latitudeDelta = 0.1
            region.span.longitudeDelta = 0.1
        }
        cameraPosition = .region(region)
    }
}
