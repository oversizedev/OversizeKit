//
// Copyright © 2022 Alexander Romanov
// StorePaymentButtonBar.swift
//

import SwiftUI

struct StorePaymentButtonBar: View {
    @EnvironmentObject var viewModel: StoreViewModel

    let action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
    }

    var body: some View {
        VStack(spacing: .zero) {
            Text(viewModel.selectedProductButtonDescription)
                .subheadline(.semibold)
                .foregroundColor(.onSurfaceMediumEmphasis)
                .padding(.vertical, 20)

            Button {
                if let selectedProduct = viewModel.selectedProduct {
                    Task {
                        await viewModel.buy(product: selectedProduct)
                    }
                }
            } label: {
                Text(viewModel.selectedProductButtonText)
            }
            .buttonStyle(.payment)
            .controlRadius(.medium)
            .padding(.horizontal, .xxSmall)

            if let action = action {
                Button("View all plans") {
                    action()
                }
                .buttonStyle(.tertiary)
                .accent()
            }
        }
        .padding(.bottom, .xxSmall)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.black.opacity(0.05), lineWidth: 0.5)
                }
        }
        .padding(.bottom, .small)
        .padding(.horizontal, .small)
    }
}

struct StorePaymentButtonBar_Previews: PreviewProvider {
    static var previews: some View {
        StorePaymentButtonBar()
    }
}
