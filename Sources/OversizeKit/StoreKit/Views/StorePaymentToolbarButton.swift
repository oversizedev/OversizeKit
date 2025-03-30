//
// Copyright © 2025 Alexander Romanov
// StorePaymentToolbarButton.swift, created on 10.03.2025
//

import SwiftUI

public struct StorePaymentToolbarButton: View {
    @EnvironmentObject var viewModel: StoreViewModel

    let trialNotification: Bool

    public init(trialNotification: Bool = false) {
        self.trialNotification = trialNotification
    }

    public var body: some View {
        Button {
            if let selectedProduct = viewModel.selectedProduct {
                Task {
                    let status = await viewModel.buy(product: selectedProduct)
                    if trialNotification, status {
                        await viewModel.addTrialNotification(product: selectedProduct)
                    }
                }
            }
        } label: {
            Text(viewModel.selectedProductButtonText)
        }
        .loading(viewModel.isBuyLoading)
    }
}
