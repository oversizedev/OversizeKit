//
// Copyright © 2023 Alexander Romanov
// SetPINCodeView.swift
//

import OversizeLocalizable
import OversizeRouter
import OversizeUI
import SwiftUI

public struct SetPINCodeView: View {
    @Environment(\.settingsNavigate) var settingsNavigate
    @EnvironmentObject private var hudRouter: HUDRouter
    @ObservedObject var viewModel: SetPINCodeViewModel
    @Environment(\.dismiss) var dismiss

    public init(action: PINCodeAction) {
        viewModel = SetPINCodeViewModel(action: action)
    }

    public var body: some View {
        stateView(state: viewModel.state)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        settingsNavigate(.dismiss)
                    } label: {
                        Image.Base.close.icon()
                    }
                }
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
                            hudRouter.present(L10n.Security.createPINCode)
                        case .update:
                            hudRouter.present(L10n.Security.pinChanged)
                        }

                    case false:
                        break
                    }
                }

            } biometricAction: {}
        }
    }
}
