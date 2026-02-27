//
// Copyright © 2023 Alexander Romanov
// MapCoordinateView.swift
//

import MapKit
import OversizeUI
import SwiftUI

#if !os(watchOS)
public struct MapCoordinateView: View {
    @Environment(\.screenSize) var screenSize
    @Environment(\.openURL) var openURL
    @State var viewModel: MapCoordinateViewModel

    public init(_ location: CLLocationCoordinate2D, annotation: String? = nil) {
        _viewModel = State(wrappedValue: MapCoordinateViewModel(location: location, annotation: annotation))
    }

    public var body: some View {
        mapView
            .ignoresSafeArea()
            .navigationTitle(viewModel.annotation ?? "")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.thickMaterial, for: .navigationBar)
        #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Route", systemImage: "map") {
                        viewModel.isShowRoutePickerSheet.toggle()
                    }
                    .labelStyle(.toolbar)
                }
            }
        #if os(iOS)
            .toolbar(.hidden, for: .tabBar)
        #endif
            .sheet(isPresented: $viewModel.isShowRoutePickerSheet) {
                routeSheetView
                    .presentationDetents([.height(260)])
            }
    }

    var mapView: some View {
        ZStack(alignment: .trailing) {
            Map(position: $viewModel.cameraPosition) {
                ForEach(viewModel.annotations) { point in
                    Marker(point.name, coordinate: point.coordinate)
                }
                UserAnnotation()
            }
            controlButtons
        }
    }

    var controlButtons: some View {
        VStack {
            Spacer()
            VStack(spacing: .zero) {
                Button {
                    viewModel.zoomIn()
                } label: {
                    Image(systemName: "plus")
                        .onSurfaceSecondary()
                        .padding(.xxSmall)
                }

                Button {
                    viewModel.zoomOut()
                } label: {
                    Image(systemName: "minus")
                        .onSurfaceSecondary()
                        .padding(.xxSmall)
                }
            }
            .background {
                Capsule()
                    .fillSurfacePrimary()
                    .shadowElevation(.z1)
            }
            Spacer()
        }
        .overlay(alignment: .bottomTrailing, content: {
            Button {
                viewModel.positionInLocation()
            } label: {
                Image(systemName: "location.fill")
                    .onSurfaceSecondary()
                    .padding(.xxSmall)
            }
            .background {
                Capsule()
                    .fillSurfacePrimary()
                    .shadowElevation(.z1)
            }
        })
        .padding(.trailing, 16)
        .padding(.bottom, screenSize.safeAreaBottom)
    }

    var routeSheetView: some View {
        NavigationStack {
            LayoutView("Route") {
                SectionView {
                    Row("Apple Maps") {
                        onTapAppleMaps()
                    }
                    Row("Google Maps") {
                        onTapGoogleMaps()
                    }
                }
            }
            .surfaceContentRowMargins()
            .backgroundSecondary()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        viewModel.isShowRoutePickerSheet = false
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                    #if !os(tvOS)
                        .keyboardShortcut(.cancelAction)
                    #endif
                }
            }
        }
    }

    func onTapAppleMaps() {
        #if !os(tvOS)
        let placemark = MKPlacemark(coordinate: viewModel.location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = viewModel.annotation
        mapItem.openInMaps()
        viewModel.isShowRoutePickerSheet.toggle()
        #endif
    }

    func onTapGoogleMaps() {
        guard let url = URL(string: "comgooglemaps://?saddr=\(viewModel.location.latitude),\(viewModel.location.longitude)") else { return }
        openURL(url)
    }
}

struct MapCoordinateView_Previews: PreviewProvider {
    static var previews: some View {
        MapCoordinateView(.init(latitude: 100, longitude: 100))
    }
}
#endif
