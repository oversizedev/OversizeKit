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
    @StateObject var viewModel: MapCoordinateViewModel

    public init(_ location: CLLocationCoordinate2D, annotation: String? = nil) {
        _viewModel = StateObject(wrappedValue: MapCoordinateViewModel(location: location, annotation: annotation))
    }

    public var body: some View {
        VStack(spacing: 0) {
            if #available(iOS 16.0, *) {
                mapView
                    .ignoresSafeArea()
                    .safeAreaInset(edge: .top) {
                        ModalNavigationBar(title: viewModel.annotation ?? "", largeTitle: false, leadingBar: {
                            BarButton(.back)
                        }, trailingBar: {
                            BarButton(.icon(.map, action: {
                                viewModel.isShowRoutePickerSheet.toggle()
                            }))
                        })
                        .background(.thickMaterial, ignoresSafeAreaEdges: .top)
                    }
                #if os(iOS)
                    .toolbar(.hidden, for: .tabBar)
                #endif
            } else {
                mapView
                    .safeAreaInset(edge: .top) {
                        ModalNavigationBar(title: viewModel.annotation ?? "", largeTitle: false, leadingBar: {
                            BarButton(.back)
                        }, trailingBar: {
                            BarButton(.icon(.map, action: {
                                viewModel.isShowRoutePickerSheet.toggle()
                            }))
                        })
                    }
            }
        }
        .sheet(isPresented: $viewModel.isShowRoutePickerSheet) {
            routeSheetView
                .presentationDetents([.height(260)])
        }
    }

    var mapView: some View {
        ZStack(alignment: .trailing) {
            Map(coordinateRegion: region, showsUserLocation: true, userTrackingMode: $viewModel.userTrackingMode, annotationItems: viewModel.annotations) {
                MapMarker(coordinate: $0.coordinate)
            }
            controlButtons
        }
    }

    private var region: Binding<MKCoordinateRegion> {
        Binding {
            viewModel.region
        } set: { region in
            DispatchQueue.main.async {
                viewModel.region = region
            }
        }
    }

    var controlButtons: some View {
        VStack {
            Spacer()
            VStack(spacing: .zero) {
                Button {
                    viewModel.zoomIn()
                } label: {
                    IconDeprecated(.plus)
                        .onSurfaceSecondaryForeground()
                        .padding(.xxSmall)
                }

                Button {
                    viewModel.zoomOut()
                } label: {
                    IconDeprecated(.minus)
                        .onSurfaceSecondaryForeground()
                        .padding(.xxSmall)
                }
            }
            .background {
                Capsule()
                    .fillSurfacePrimary()
                    .shadowElevaton(.z1)
            }
            Spacer()
        }
        .overlay(alignment: .bottomTrailing, content: {
            Button {
                viewModel.positionInLocation()

            } label: {
                IconDeprecated(.navigation)
                    .onSurfaceSecondaryForeground()
                    .padding(.xxSmall)
            }
            .background {
                Capsule()
                    .fillSurfacePrimary()
                    .shadowElevaton(.z1)
            }
        })
        .padding(.trailing, 16)
        .padding(.bottom, screenSize.safeAreaBottom)
    }

    var routeSheetView: some View {
        PageView("Route") {
            SectionView {
                Row("Apple Maps") {
                    onTapAppleMaps()
                }
                Row("Google Maps") {
                    onTapGoogleMaps()
                }
            }
        }
        .leadingBar(leadingBar: {
            BarButton(.close)
        })
        .backgroundSecondary()
        .disableScrollShadow(true)
        .surfaceContentRowMargins()
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
