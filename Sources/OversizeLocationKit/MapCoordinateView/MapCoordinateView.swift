//
// Copyright © 2023 Alexander Romanov
// MapCoordinateView.swift
//

import MapKit
import OversizeUI
import SwiftUI

#if !os(watchOS)
public struct MapCoordinateView: View {
    @Environment(\.openURL) var openURL
    @State var viewModel: MapCoordinateViewModel
    @Namespace var unionNamespace

    public init(_ location: CLLocationCoordinate2D, annotation: String? = nil) {
        _viewModel = State(wrappedValue: MapCoordinateViewModel(location: location, annotation: annotation))
    }

    public var body: some View {
        Map(position: $viewModel.cameraPosition) {
            ForEach(viewModel.annotations) { point in
                Marker(point.name, coordinate: point.coordinate)
            }
            UserAnnotation()
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .trailing) {
            if #available(iOS 26.0, macOS 26.0, *) {
                zoomButtonsGlass.padding(.small)
            } else {
                zoomButtons.padding(.small)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if #available(iOS 26.0, macOS 26.0, *) {
                EmptyView()
            } else {
                locationButton
            }
        }
        .navigationTitle(viewModel.annotation ?? "")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Route", systemImage: "arrow.trianglehead.turn.up.right.diamond") {
                    viewModel.isShowRoutePickerSheet.toggle()
                }
                .labelStyle(.toolbar)
                .tint(Color.onSurfacePrimary)
            }

            #if os(iOS)
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.flexible, placement: .bottomBar)

                ToolbarItem(placement: .bottomBar) {
                    locationButtonGlass
                }
            }
            #endif
        }
        #if os(iOS)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $viewModel.isShowRoutePickerSheet) {
            NavigationStack {
                routeSheetView
                    .presentationDetents([.height(240)])
            }
        }
    }

    @available(iOS 26.0, macOS 26.0, *)
    var zoomButtonsGlass: some View {
        GlassEffectContainer {
            VStack {
                Button {
                    viewModel.zoomIn()
                } label: {
                    Label("Plus", systemImage: "plus")
                        .font(.system(size: 20))
                        .labelStyle(.iconOnly)
                        .padding(.top, 8)
                        .foregroundStyle(Color.onSurfacePrimary)
                }
                .buttonStyle(.glassProminent)
                .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)

                Button {
                    viewModel.zoomOut()
                } label: {
                    Label("Miuns", systemImage: "minus")
                        .font(.system(size: 20))
                        .labelStyle(.iconOnly)
                        .padding(.bottom, 14)
                        .foregroundStyle(Color.onSurfacePrimary)
                }
                .buttonStyle(.glassProminent)
                .glassEffectUnion(id: "mapOptions", namespace: unionNamespace)
            }
            .tint(Color.surfacePrimary.opacity(0.8))
        }
    }

    var zoomButtons: some View {
        VStack(spacing: .zero) {
            Button {
                viewModel.zoomIn()
            } label: {
                Image(systemName: "plus")
                    .onSurfaceSecondary()
                    .padding(.xSmall)
            }
            .buttonStyle(.scale)

            Button {
                viewModel.zoomOut()
            } label: {
                Image(systemName: "minus")
                    .onSurfaceSecondary()
                    .padding(.xSmall)
                    .padding(.bottom, 6)
            }
        }
        .background {
            Capsule()
                .fillSurfacePrimary()
                .shadowElevation(.z1)
        }
    }

    #if os(iOS)
    @available(iOS 26.0, *)
    var locationButtonGlass: some View {
        Button {
            viewModel.positionInLocation()
        } label: {
            Label("Location", systemImage: "location.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.onSurfacePrimary)
        }
        .buttonStyle(.glassProminent)
    }
    #endif

    var locationButton: some View {
        HStack {
            Spacer()

            Button {
                viewModel.positionInLocation()
            } label: {
                Image(systemName: "location.fill")
                    .onSurfaceSecondary()
                    .padding(.xxSmall)
                    .background {
                        Capsule()
                            .fillSurfacePrimary()
                            .shadowElevation(.z1)
                    }
            }
        }
        .padding(.horizontal, .small)
    }

    var routeSheetView: some View {
        ListLayoutView("Route") {
            ListSection {
                Button(action: onTapAppleMaps) {
                    ListRow("Apple Maps")
                }
                Button(action: onTapGoogleMaps) {
                    ListRow("Google Maps")
                }
            }
            .listRowSeparator(.hidden)
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
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

#Preview {
    NavigationStack {
        MapCoordinateView(
            .init(
                latitude: 100,
                longitude: 100
            ),
            annotation: "Point"
        )
    }
}
#endif
