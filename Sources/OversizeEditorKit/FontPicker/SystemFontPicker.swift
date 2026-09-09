//
// Copyright © 2024 Alexander Romanov
// SystemFontPicker.swift, created on 21.05.2026
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct SystemFontPicker: View {
    @Binding var selectedDesign: Font.Design
    @Binding var selectedFontName: String?
    @Environment(\.dismiss) private var dismiss

    private let mode: Mode
    private let onApply: ((String?) -> Void)?
    @State private var isFontPickerPresented = false
    @Namespace private var namespace

    private static let allDesigns: [Font.Design] = [.default, .serif, .monospaced, .rounded]

    public init(
        selectedDesign: Binding<Font.Design>,
        selectedFontName: Binding<String?>,
        mode: Mode = .all,
        onApply: ((String?) -> Void)? = nil
    ) {
        _selectedDesign = selectedDesign
        _selectedFontName = selectedFontName
        self.mode = mode
        self.onApply = onApply
    }

    public var body: some View {
        ListLayoutView("Font") {
            // MARK: - System

            ListSection {
                ForEach(Self.allDesigns, id: \.self) { design in
                    Button {
                        selectedDesign = design
                        selectedFontName = nil
                        onApply?(nil)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Aa")
                                    .font(.system(.body, design: design))
                                    .foregroundStyle(Color.onSurfacePrimary)
                                Text(design.displayName)
                                    .font(.caption)
                                    .foregroundStyle(Color.onSurfaceSecondary)
                            }
                            Spacer()
                            if selectedFontName == nil, selectedDesign == design {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accent)
                            }
                        }
                        .foregroundStyle(Color.onSurfacePrimary)
                    }
                }
            }

            // MARK: - All Fonts

            #if os(iOS) || os(macOS)
            if mode == .all {
                ListSection {
                    Button {
                        isFontPickerPresented = true
                    } label: {
                        HStack {
                            Text("All Fonts")
                                .foregroundStyle(Color.onSurfacePrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.onSurfaceSecondary)
                        }
                    }
                    #if os(iOS)
                    .matchedTransitionSource(id: "allFonts", in: namespace)
                    #endif
                }
            }
            #endif
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS) && !os(watchOS)
                .keyboardShortcut(.cancelAction)
                #endif
            }
        }
        .scrollIndicators(.hidden)
        #if os(iOS) || os(macOS)
        .sheet(isPresented: $isFontPickerPresented) {
            NavigationStack {
                FontPicker(
                    selectedFontName: $selectedFontName,
                    onApply: { name in
                        onApply?(name)
                        dismiss()
                    }
                )
            }
            #if os(iOS)
            .presentationDetents([.large])
            .navigationTransitionZoom(sourceID: "allFonts", in: namespace)
            #endif
        }
        #endif
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension SystemFontPicker {
    enum Mode {
        case systemOnly
        case all
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Font.Design {
    var displayName: String {
        switch self {
        case .default: "Default"
        case .serif: "Serif"
        case .monospaced: "Monospaced"
        case .rounded: "Rounded"
        @unknown default: "Default"
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var design: Font.Design = .default
    @Previewable @State var fontName: String? = nil
    NavigationStack {
        SystemFontPicker(selectedDesign: $design, selectedFontName: $fontName)
    }
}
