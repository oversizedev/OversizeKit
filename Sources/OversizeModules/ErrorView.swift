//
// Copyright © 2022 Alexander Romanov
// ErrorView.swift
//

import OversizeLocalizable
import OversizeServices
import OversizeUI
import SwiftUI

public enum ErrorButtnType {
    case locationSettings
    case tryAgain(action: () -> Void)
    case custum(_ text: String, action: () -> Void)
}

public struct ErrorView: View {
    private let error: AppError
    private let primaryButton: ErrorButtnType?

    public init(_ error: AppError, primaryButton: ErrorButtnType? = nil) {
        self.error = error
        self.primaryButton = primaryButton
    }

    public var body: some View {
        VStack {
            Spacer()
            ContentView(image: error.image,
                        title: error.title,
                        subtitle: error.subtitle,
                        primaryButton: contenButtonType)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .paddingContent()
    }

    private var contenButtonType: ContenButtonType? {
        if let primaryButton = primaryButton {
            switch primaryButton {
            case .locationSettings:
                return .accent(L10n.Button.goToSettings, action: {
                    #if os(iOS)
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    #endif
                })
            case let .tryAgain(action: action):
                return .accent(L10n.Common.tryLaterAgain, action: action)
            case let .custum(text, action: action):
                return .accent(text, action: action)
            }
        } else {
            switch error {
            case .network:
                return nil
            case let .cloudKit(type):
                if type == .notAccess || type == .noAccount {
                    return .accent(L10n.Button.goToSettings, action: {
                        #if os(iOS)
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        #endif
                    })
                } else {
                    return nil
                }
            case let .location(type):
                if type == .notAccess {
                    return .accent(L10n.Button.goToSettings, action: {
                        #if os(iOS)
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        #endif
                    })
                } else {
                    return nil
                }
            case .custom:
                return nil
            case .coreData:
                return nil
            }
        }
    }
}

struct ErorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(.network(type: .decode), primaryButton: .custum("Ouh", action: {
            print(#function)
        }))
    }
}
