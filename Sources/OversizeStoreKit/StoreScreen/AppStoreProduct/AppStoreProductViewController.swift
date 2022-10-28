//
// Copyright © 2022 Alexander Romanov
// StoreProductViewController.swift
//

#if os(iOS)
import StoreKit
import SwiftUI
import UIKit

public class AppStoreProductViewController: UIViewController {
    private var isPresentStoreProduct: Binding<Bool>
    private let appId: String

    public init(isPresentStoreProduct: Binding<Bool>, appId: String) {
        self.isPresentStoreProduct = isPresentStoreProduct
        self.appId = appId

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func presentStoreProduct() {
        let storeProductViewController = SKStoreProductViewController()
        storeProductViewController.delegate = self

        let parameters = [SKStoreProductParameterITunesItemIdentifier: appId]
        storeProductViewController.loadProduct(withParameters: parameters) { status, error in
            if status {
                self.present(storeProductViewController, animated: true, completion: nil)
            } else {
                if let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }

        DispatchQueue.main.async {
            self.isPresentStoreProduct.wrappedValue = false
        }
    }
}

extension AppStoreProductViewController: SKStoreProductViewControllerDelegate {
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true)
    }
}
#endif
