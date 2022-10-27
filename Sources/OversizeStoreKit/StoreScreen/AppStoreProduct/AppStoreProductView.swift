//
// Copyright © 2022 Alexander Romanov
// AppStoreProductView.swift
//

import SwiftUI

public struct AppStoreProductViewControllerRepresentable: UIViewControllerRepresentable {
    public typealias UIViewControllerType = AppStoreProductViewController

    private var isPresentStoreProduct: Binding<Bool>
    private let appId: String

    public init(isPresentStoreProduct: Binding<Bool>, appId: String) {
        self.isPresentStoreProduct = isPresentStoreProduct
        self.appId = appId
    }

    public func makeUIViewController(context _: Context) -> UIViewControllerType {
        let viewController = AppStoreProductViewController(isPresentStoreProduct: isPresentStoreProduct, appId: appId)
        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context _: Context) {
        if isPresentStoreProduct.wrappedValue {
            uiViewController.presentStoreProduct()
        }
    }
}

public extension View {
    func appStoreOverlay(isPresent: Binding<Bool>, appId: String) -> some View {
        background {
            AppStoreProductViewControllerRepresentable(isPresentStoreProduct: isPresent, appId: appId)
                .frame(width: 0, height: 0)
        }
    }
}
