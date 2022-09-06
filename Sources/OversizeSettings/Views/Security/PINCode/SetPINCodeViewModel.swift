//
// Copyright © 2022 Alexander Romanov
// SetPINCodeViewModel.swift
//

import OversizeCore
import OversizeLocalizable
import OversizePINCode
import OversizeSecurityService
import OversizeServices
import OversizeSettingsService
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

    @Published public var authState: PINCodeViewState = .locked

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

    public func checkConfirmNewPINCode(completion: @escaping (Bool) -> Void) {
        if newPinCodeField == confirmNewCodeField {
            settingsStore.updatePINCode(oldPIN: curentPinCode, newPIN: newPinCodeField) { result in
                switch result {
                case true:
                    self.settingsStore.pinCodeEnabend = true
                    completion(true)
                    TapticEngine.success.vibrate()
                    log("PIN Code saved")
                    return
                case false:
                    self.errorText = "Save error"
                    completion(false)
                    self.newPinCodeField = ""
                    self.confirmNewCodeField = ""
                    TapticEngine.error.vibrate()
                    return
                }
            }

        } else {
            state = .newPINField
            authState = .error
            errorText = action == .update ? L10n.Security.newPINNotMatch : L10n.Security.pinNotMatch
            newPinCodeField = ""
            confirmNewCodeField = ""
            TapticEngine.error.vibrate()
            completion(false)
            return
        }
    }
}
