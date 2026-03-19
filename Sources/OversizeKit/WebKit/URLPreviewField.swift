//
// Copyright © 2023 Alexander Romanov
// URLPreviewField.swift
//

import OversizeUI
import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS 15.0, *)
@available(macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public struct URLPreviewField: View {
    @Binding private var url: URL?
    @State private var urlString: String = ""
    let title: String

    @State private var textFieldHelper: FieldHelperStyle = .none

    public init(_ title: String = "URL", url: Binding<URL?>) {
        self.title = title
        _url = url
        _urlString = .init(initialValue: url.wrappedValue?.absoluteString ?? "")
    }

    public var body: some View {
        VStack(spacing: 2) {
            if let url {
                URLFieldPreview(url: url)
                    .fieldPosition(.top)
            }

            TextField(title, text: $urlString, onEditingChanged: { state in
                guard !state else {
                    textFieldHelper = .none
                    return
                }

                validateURL()
            }, onCommit: {
                validateURL()
            })
            #if os(iOS)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            #endif
            .textContentType(.URL)
            .autocorrectionDisabled()
            .fieldHelper(.constant("Invalid URL"), style: $textFieldHelper)
            .fieldPosition(url == nil ? nil : .bottom)
            .onChange(of: url) { _, newValue in
                if let newValue {
                    if newValue.absoluteString != urlString {
                        urlString = newValue.absoluteString
                    }
                } else {
                    urlString = ""
                }
            }
        }
    }

    private func validateURL() {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            textFieldHelper = .none
            url = nil
            return
        }

        #if os(iOS)
        if let validURL = URL(string: trimmed), UIApplication.shared.canOpenURL(validURL) {
            textFieldHelper = .none
            url = validURL
        } else {
            textFieldHelper = .errorText
            url = nil
        }
        #else
        if let validURL = URL(string: trimmed) {
            textFieldHelper = .none
            url = validURL
        } else {
            textFieldHelper = .errorText
            url = nil
        }
        #endif
    }
}
#endif
