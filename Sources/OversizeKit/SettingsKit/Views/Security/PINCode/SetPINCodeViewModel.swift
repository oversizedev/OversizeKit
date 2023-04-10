//
// Copyright © 2022 Alexander Romanov
// SetPINCodeViewModel.swift
//

import OversizeCore
import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

public enum PINCodeAction: Identifiable {
    case set, update
    public var id: Int {
        hashValue
    }
}

public enum SetPINCodeViewState {
    case oldPINField, newPINField, confirmNewPINField
}

public final class SetPINCodeViewModel: ObservableObject {
    @Published public var settingsStore: SettingsService

    @Published public var pinCodeField: String = ""

    @Published public var authState: LockscreenViewState = .locked

    @Published public var maxCount = 4

    @Published public var state: SetPINCodeViewState

    @Published public var errorText: String = ""

    private let curentPinCode: String
    @Published public var oldCodeField = ""
    @Published public var newPinCodeField = ""
    @Published public var confirmNewCodeField = ""
    public let action: PINCodeAction

    public init(action: PINCodeAction) {
        settingsStore = SettingsService()
        curentPinCode = SettingsService().getPINCode()
        self.action = action
        switch action {
        case .set:
            state = .newPINField
        case .update:
            state = .oldPINField
        }
    }

    public func chekOldPINCode() {
        if oldCodeField != curentPinCode {
            authState = .error
            errorText = L10n.Security.invalidCurrentPINCode
            oldCodeField = ""
            TapticEngine.error.vibrate()
        } else {
            state = .newPINField
            TapticEngine.soft.vibrate()
        }
    }

    public func checkNewPINCode() {
        state = .confirmNewPINField
        TapticEngine.soft.vibrate()
    }

    public func checkConfirmNewPINCode() async -> Bool {
        if newPinCodeField == confirmNewCodeField {
            let result = await settingsStore.updatePINCode(oldPIN: curentPinCode, newPIN: newPinCodeField)
            switch result {
            case true:
                settingsStore.pinCodeEnabend = true
                TapticEngine.success.vibrate()
                return true
            case false:
                errorText = "Save error"
                newPinCodeField = ""
                confirmNewCodeField = ""
                TapticEngine.error.vibrate()
                return false
            }

        } else {
            state = .newPINField
            authState = .error
            errorText = action == .update ? L10n.Security.newPINNotMatch : L10n.Security.pinNotMatch
            newPinCodeField = ""
            confirmNewCodeField = ""
            TapticEngine.error.vibrate()
            return false
        }
    }
}
