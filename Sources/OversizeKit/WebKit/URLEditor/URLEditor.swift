//
// Copyright © 2022 Alexander Romanov
// URLEditor.swift
//

import OversizeUI
import SwiftUI

#if os(iOS) || os(macOS)
public struct URLEditor<Action: View>: View {
    public let label: String
    public var placeholder: String
    @Binding public var url: URL?
    @FocusState private var isFocused: Bool
    @State private var linkSize: CGSize = .zero
    @State private var urlString: String = ""
    @State private var previewURL: URL? = nil
    @State private var textFieldHelper: FieldHelperStyle = .none

    @ViewBuilder private let action: Action

    @Environment(\.dismiss) var dismiss

    public init(
        _ label: String,
        placeholder: String = "URL",
        url: Binding<URL?>,
        @ViewBuilder action: () -> Action
    ) {
        self.label = label
        self.placeholder = placeholder
        _url = url
        self.action = action()
    }

    public var body: some View {
        VStack(spacing: .xxxSmall) {
            TextField(placeholder, text: $urlString, onEditingChanged: { isEditing in
                guard !isEditing else {
                    textFieldHelper = .none
                    return
                }
                commitURL()
            }, onCommit: {
                commitURL()
            })
            .focused($isFocused)
            #if os(iOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
            #endif
                .textContentType(.URL)
                .autocorrectionDisabled()
                .textFieldStyle(.placeholder(placeholder, text: $urlString))
                .fieldHelper(.constant("Invalid URL"), style: $textFieldHelper)
                .onChange(of: urlString) { _, newValue in
                    liveValidate(newValue)
                }
                .onChange(of: url) { _, newURL in
                    let expected = validatedURL(urlString.trimmingCharacters(in: .whitespacesAndNewlines))
                    guard newURL != expected else { return }
                    urlString = newURL?.absoluteString ?? ""
                    previewURL = newURL
                }
                .fieldPosition(previewURL == nil ? nil : .top)

            #if canImport(LinkPresentation)
            if let resolvedURL = previewURL {
                URLFieldPreview(url: resolvedURL)
                    .animation(.default, value: linkSize.height)
                    .id(resolvedURL)
                    .fieldPosition(.bottom)
            }
            #endif

            Spacer()
        }
        .paddingContent()
        .safeAreaBarBottom {
            action
                .buttonStyle(.primary)
                .accent()
                .paddingContent()
                .disabled(url == nil)
        }
        .navigationTitle(label)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                    .keyboardShortcut(.cancelAction)
                }
            }
            .onAppear {
                isFocused = true
                urlString = url?.absoluteString ?? ""
                previewURL = url
            }
    }

    // MARK: - Private

    private func validatedURL(_ trimmed: String) -> URL? {
        guard !trimmed.isEmpty,
              let url = URL(string: trimmed),
              url.scheme != nil
        else { return nil }
        return url
    }

    private func liveValidate(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            url = nil
            previewURL = nil
            textFieldHelper = .none
            return
        }
        let validated = validatedURL(trimmed)
        url = validated
        if validated != previewURL {
            previewURL = nil
        }
    }

    private func commitURL() {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            url = nil
            previewURL = nil
            textFieldHelper = .none
            return
        }
        if let validURL = validatedURL(trimmed) {
            url = validURL
            previewURL = validURL
            textFieldHelper = .none
        } else {
            textFieldHelper = .errorText
            url = nil
            previewURL = nil
        }
    }
}

#Preview {
    @Previewable @State var url: URL? = nil
    URLEditor("Link", url: $url) {
        Button("Save") {}
    }
}
#endif
