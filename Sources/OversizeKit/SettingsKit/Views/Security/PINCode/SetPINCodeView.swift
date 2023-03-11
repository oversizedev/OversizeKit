//
// Copyright © 2022 Alexander Romanov
// SetPINCodeView.swift
//

import OversizeLocalizable

import OversizeUI
import SwiftUI

public struct SetPINCodeView: View {
    @ObservedObject var viewModel: SetPINCodeViewModel
    @EnvironmentObject private var hud: HUD
    @Environment(\.dismiss) var dismiss

    public init(action: PINCodeAction) {
        viewModel = SetPINCodeViewModel(action: action)
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            stateView(state: viewModel.state)

            VStack(alignment: .leading) {
                Button {
                    dismiss()
                } label: {
                    Icon(.xMini, color: .onSurfaceHighEmphasis)
                }
                .buttonStyle(.secondary)

                Spacer()
            }.padding(20)
        }
    }

    @ViewBuilder
    private func stateView(state: SetPINCodeViewState) -> some View {
        switch state {
        case .oldPINField:
            LockscreenView(pinCode: $viewModel.oldCodeField,
                           state: $viewModel.authState,
                           maxCount: viewModel.maxCount,
                           title: L10n.Security.oldPINCode,
                           errorText: viewModel.errorText)
            {
                viewModel.chekOldPINCode()
            } biometricAction: {}

        case .newPINField:
            LockscreenView(pinCode: $viewModel.newPinCodeField,
                           state: $viewModel.authState,
                           maxCount: viewModel.maxCount,
                           title: L10n.Security.newPINCode,
                           errorText: viewModel.errorText)
            {
                viewModel.checkNewPINCode()
            } biometricAction: {}
        case .confirmNewPINField:
            LockscreenView(pinCode: $viewModel.confirmNewCodeField,
                           state: $viewModel.authState,
                           maxCount: viewModel.maxCount,
                           title: L10n.Security.confirmPINCode,
                           errorText: viewModel.errorText)
            {
                Task {
                    let result = await viewModel.checkConfirmNewPINCode()
                    switch result {
                    case true:
                        dismiss()
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
