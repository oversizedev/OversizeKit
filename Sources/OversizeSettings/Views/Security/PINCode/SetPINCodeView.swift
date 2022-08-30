//
// Copyright © 2022 Alexander Romanov
// SetPINCodeView.swift
//

import OversizeCraft
import OversizeUI
import SwiftUI

public struct SetPINCodeView: View {
    @ObservedObject var viewModel: SetPINCodeViewModel
    @EnvironmentObject private var hud: HUD
    @Environment(\.presentationMode) var presentationMode

    public init(action: PINCodeAction) {
        viewModel = SetPINCodeViewModel(action: action)
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            stateView(state: viewModel.state)

            VStack(alignment: .leading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Icon(.xMini, color: .onSurfaceHighEmphasis)
                }
                .style(.secondary, size: .medium, rounded: .full, width: .round, shadow: true)

                Spacer()
            }.padding(20)
        }
    }

    @ViewBuilder
    private func stateView(state: SetPINCodeViewState) -> some View {
        switch state {
        case .oldPINField:
            PINCodeView(pinCode: $viewModel.oldCodeField,
                        state: $viewModel.authState,
                        maxCount: viewModel.maxCount,
                        title: L10n.Security.oldPINCode,
                        errorText: viewModel.errorText) {
                viewModel.chekOldPINCode()
            } biometricAction: {}

        case .newPINField:
            PINCodeView(pinCode: $viewModel.newPinCodeField,
                        state: $viewModel.authState,
                        maxCount: viewModel.maxCount,
                        title: L10n.Security.newPINCode,
                        errorText: viewModel.errorText) {
                viewModel.checkNewPINCode()
            } biometricAction: {}
        case .confirmNewPINField:
            PINCodeView(pinCode: $viewModel.confirmNewCodeField,
                        state: $viewModel.authState,
                        maxCount: viewModel.maxCount,
                        title: L10n.Security.confirmPINCode,
                        errorText: viewModel.errorText) {
                viewModel.checkConfirmNewPINCode { result in
                    switch result {
                    case true:
                        presentationMode.wrappedValue.dismiss()
                        switch viewModel.action {
                        case .set:
                            hud.show(title: L10n.Security.createPINCode, icon: .check)
                        case .update:
                            hud.show(title: L10n.Security.pinChanged, icon: .check)
                        }

                    case false:
                        break
                    }
                }
            } biometricAction: {}
        }
    }
}
