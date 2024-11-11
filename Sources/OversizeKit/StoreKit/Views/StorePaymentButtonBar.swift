//
// Copyright © 2022 Alexander Romanov
// StorePaymentButtonBar.swift
//

import SwiftUI

struct StorePaymentButtonBar: View {
    @EnvironmentObject var viewModel: StoreViewModel

    let action: (() -> Void)?
    let trialNotification: Bool
    let showDescription: Bool

    init(trialNotification: Bool = false, showDescription: Bool = true, action: (() -> Void)? = nil) {
        self.trialNotification = trialNotification
        self.action = action
        self.showDescription = showDescription
    }

    var body: some View {
        VStack(spacing: .zero) {
            if showDescription {
                Text(viewModel.selectedProductButtonDescription)
                    .subheadline(.semibold)
                    .foregroundColor(.onSurfaceSecondary)
                    .padding(.vertical, 20)
            }

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
            .buttonStyle(.payment)
            .controlRadius(.medium)
            .padding(.horizontal, .xxSmall)
            .loading(viewModel.isBuyLoading)

            if let action {
                Button("View all plans") {
                    action()
                }
                .buttonStyle(.quaternary)
                .accent()
            }
        }
        .padding(.bottom, .xxSmall)
        .background {
            if showDescription {
                backgroundView
            }
        }
        .padding(.bottom, showDescription ? .small : .zero)
        .padding(.horizontal, showDescription ? .small : .zero)
    }

    var backgroundView: some View {
        Group {
            #if os(iOS)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.05), lineWidth: 0.5)
                    }
            #else
                EmptyView()
            #endif
        }
    }
}

struct StorePaymentButtonBar_Previews: PreviewProvider {
    static var previews: some View {
        StorePaymentButtonBar()
    }
}
