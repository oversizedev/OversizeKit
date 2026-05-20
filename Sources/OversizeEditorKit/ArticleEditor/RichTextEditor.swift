//
// Copyright © 2024 Alexander Romanov
// NoteEditor.swift, created on 03.03.2024
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct RichTextEditor: View {
    
    @Environment(\.fontResolutionContext) var fontResolutionContext

    @Namespace var unionNamespace
    
    @Environment(\.dismiss) private var dismiss

    @Binding private var text: AttributedString

    @FocusState var isFocus: Bool

    private let title: String?

    @State private var findNavigatorIsPresented = false

    @State private var textSelection: AttributedTextSelection = .init()
    @State private var selectedDesign: Font.Design = .default
    @State private var selectedIsItalic: Bool = false

    @State private var isFontStyleSelection: Bool = false
    @State private var isLinkAlertPresented: Bool = false
    @State private var linkURLString: String = ""

    public init(_ title: String? = nil, text: Binding<AttributedString>) {
        self.title = title
        _text = text
    }

    public var body: some View {
        ScrollView {
            TextEditor(text: $text, selection: $textSelection)
                .focused($isFocus)
                .findNavigator(isPresented: $findNavigatorIsPresented)
                .writingToolsBehavior(.complete)
                .contentMargins(.horizontal, .regular, for: .scrollContent)
                .textEditorStyle(.plain)
        }
        .background(Color.backgroundPrimary)
        .toolbar {
            if let title {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $findNavigatorIsPresented) {
                    Label("Find and replace", systemImage: "magnifyingglass")
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button(
                    "Close",
                    systemImage: "xmark",
                    role: .cancel,
                    action: {
                        dismiss()
                    }
                )
                .labelStyle(.toolbar)
                .buttonStyle(.toolbarSecondary)
                #if !os(tvOS)
                    .keyboardShortcut(.cancelAction)
                #endif
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom, content: {
            // if #available(iOS 26.0, *) {
            glassBottomBar
            // }
        })
        .onChange(of: text) { _, _ in
            if isFontStyleSelection {
                withAnimation(.interactiveSpring) {
                    isFontStyleSelection = false
                }
            }
        }
        .onAppear {
            isFocus = true
        }
        .animation(.default, value: isFocus)
        .alert("Link", isPresented: $isLinkAlertPresented) {
            TextField("https://", text: $linkURLString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
            Button("Apply") { applyLink(linkURLString) }
            if hasSelectionLink {
                Button("Remove", role: .destructive) { applyLink("") }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    var glassBottomBar: some View {
        GlassEffectContainer(spacing: .zero) {
            HStack(spacing: .zero) {
                ScrollView(.horizontal) {
                    HStack(spacing: .zero) {
                        if hasSelection || isFontStyleSelection {
                            selectionActions
                        } else {
                            textActions
                        }
                    }
                }
                .scrollIndicators(.hidden)

                Button {
                    isFocus.toggle()
                } label: {
                    Icon(isFocus ? Image.ComputerAndTV.keyboardCloseDown : Image.ComputerAndTV.keyboardOpenUp)
                        .padding(.xSmall)
                        .padding(.trailing, .xxxSmall)
//                        .background {
//                            Capsule()
//                                .fill(Color.surfacePrimary)
//
//                        }
                }

                .glassEffectUnion(id: "bar", namespace: unionNamespace)
            }
        }
        .glassEffect()
        .padding(.horizontal, .small)
        .padding(.vertical, .xSmall)
        .controlSize(.regular)
        .buttonStyle(.scale)
        .animation(.default, value: textSelection)
    }

    @ViewBuilder
    var textActions: some View {
        Button {
            withAnimation(.interactiveSpring) {
                isFontStyleSelection.toggle()
            }
        } label: {
            Icon(Image.Editor.titleCase)
                .padding(.xSmall)
                .padding(.leading, .xxxSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        Button {} label: {
            Icon(Image.Base.picture2)
                .padding(.xSmall)
                .padding(.leading, .xxxSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        Button {} label: {
            Icon(Image.Base.link)
                .padding(.xSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)
    }

    @ViewBuilder
    var selectionActions: some View {
        if !hasSelection {
            Button {
                withAnimation(.interactiveSpring) {
                    isFontStyleSelection.toggle()
                }
            } label: {
                Icon(Image.Base.chevronLeft)
                    .padding(.xSmall)
                    .padding(.leading, .xxxSmall)
            }
            // .glassEffect()
            .glassEffectUnion(id: "bar", namespace: unionNamespace)
        }

        // MARK: - Bold

        Button {
            toggleBold()
        } label: {
            Icon(Image.Editor.boldType)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionBold ? 1 : 0))
                .padding(.xxxSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        // MARK: - Italic

        if isItalicSupported {
            Button {
                toggleItalic()
            } label: {
                Icon(Image.Editor.italic)
                    .padding(.xxSmall)
                    .background(Circle().fillSurfaceSecondary().opacity(isSelectionItalic ? 1 : 0))
                    .padding(.xxxSmall)
            }
            .disabled(!isItalicSupported)
            // .glassEffect()
            .glassEffectUnion(id: "bar", namespace: unionNamespace)
        }

        // MARK: - Underline

        Button {
            toggleUnderline()
        } label: {
            Icon(Image.Editor.underline)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionUnderlined ? 1 : 0))
                .padding(.xxxSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        // MARK: - Strikethrough

        Button {
            toggleStrikethrough()
        } label: {
            Icon(Image.Editor.strikethrough)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionStrikethrough ? 1 : 0))
                .padding(.xxxSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        // MARK: - Size

        Menu {
            Picker("Size", selection: Binding(
                get: { Int(selectionFontSize) },
                set: { applySize(CGFloat($0)) }
            )) {
                ForEach([12, 14, 16, 17, 18, 20, 24, 28, 32, 40, 48, 64], id: \.self) {
                    Text("\($0)").tag($0)
                        .font(.headline)
                }
            }
        } label: {
            Icon(Image.Editor.uppercase)
                .padding(.xSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        // MARK: - Design

        Menu {
            Picker("Design", selection: Binding(
                get: { selectionFontDesign },
                set: { applyDesign($0) }
            )) {
                Text("Default").tag(Font.Design.default)
                Text("Serif").fontDesign(.serif).tag(Font.Design.serif)
                Text("Monospaced").fontDesign(.monospaced).tag(Font.Design.monospaced)
                Text("Rounded").fontDesign(.rounded).tag(Font.Design.rounded)
            }
        } label: {
            Icon(Image.Editor.font)
                .padding(.xSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)

        // MARK: - Color

        /*
          ColorPicker("", selection: Binding(
              get: { selectionColor },
              set: { applyColor($0) }
          ), supportsOpacity: false)
          .labelsHidden()
          .padding(.xSmall)
         // .glassEffect()
          .glassEffectUnion(id: "bar", namespace: unionNamespace)
          */

        // MARK: - Link

        Button {
            linkURLString = selectionCurrentLink?.absoluteString ?? ""
            isLinkAlertPresented = true
        } label: {
            Icon(Image.Base.link)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(hasSelectionLink ? 1 : 0))
                .padding(.xxxSmall)
        }
        // .glassEffect()
        .glassEffectUnion(id: "bar", namespace: unionNamespace)
    }

    private var hasSelection: Bool {
        switch textSelection.indices(in: text) {
        case .insertionPoint: false
        case let .ranges(ranges): !ranges.isEmpty
        }
    }

    // MARK: - Font state

    private var isSelectionBold: Bool {
        let font = textSelection.typingAttributes(in: text).font
        return (font ?? .default).resolve(in: fontResolutionContext).isBold
    }

    private var isSelectionItalic: Bool {
        selectedIsItalic
    }

    private var isItalicSupported: Bool {
        selectedDesign != .rounded
    }

    private var selectionFontSize: CGFloat {
        let font = textSelection.typingAttributes(in: text).font
        return (font ?? .default).resolve(in: fontResolutionContext).pointSize
    }

    private var selectionFontDesign: Font.Design {
        selectedDesign
    }

    private var selectionColor: Color {
        textSelection.typingAttributes(in: text).foregroundColor ?? .primary
    }

    private var hasSelectionLink: Bool {
        textSelection.typingAttributes(in: text).link != nil
    }

    private var selectionCurrentLink: URL? {
        textSelection.typingAttributes(in: text).link
    }

    private var isSelectionUnderlined: Bool {
        textSelection.typingAttributes(in: text).underlineStyle != nil
    }

    private var isSelectionStrikethrough: Bool {
        textSelection.typingAttributes(in: text).strikethroughStyle != nil
    }

    // MARK: - Font actions

    private func toggleBold() {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let newBold = !isSelectionBold
        let italic = selectedIsItalic
        let design = selectedDesign
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                let runs = mutableText[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                for item in runs {
                    let resolved = item.font.resolve(in: fontResolutionContext)
                    let base = Font.system(size: resolved.pointSize, weight: newBold ? .bold : .regular, design: design)
                    mutableText[item.run].font = italic ? base.italic() : base
                }
            }
        }
    }

    private func toggleItalic() {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let newItalic = !selectedIsItalic
        selectedIsItalic = newItalic
        let design = selectedDesign
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                let runs = mutableText[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                for item in runs {
                    let resolved = item.font.resolve(in: fontResolutionContext)
                    let base = Font.system(size: resolved.pointSize, weight: resolved.isBold ? .bold : .regular, design: design)
                    mutableText[item.run].font = newItalic ? base.italic() : base
                }
            }
        }
    }

    private func applySize(_ size: CGFloat) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let italic = selectedIsItalic
        let design = selectedDesign
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                let runs = mutableText[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                for item in runs {
                    let resolved = item.font.resolve(in: fontResolutionContext)
                    let base = Font.system(size: size, weight: resolved.isBold ? .bold : .regular, design: design)
                    mutableText[item.run].font = italic ? base.italic() : base
                }
            }
        }
    }

    private func applyDesign(_ design: Font.Design) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        selectedDesign = design
        let italic = selectedIsItalic
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                let runs = mutableText[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                for item in runs {
                    let resolved = item.font.resolve(in: fontResolutionContext)
                    let base = Font.system(size: resolved.pointSize, weight: resolved.isBold ? .bold : .regular, design: design)
                    mutableText[item.run].font = italic ? base.italic() : base
                }
            }
        }
    }

    // MARK: - Underline & Strikethrough actions

    private func toggleUnderline() {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let newStyle: Text.LineStyle? = isSelectionUnderlined ? nil : .init(pattern: .solid)
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].underlineStyle = newStyle
            }
        }
    }

    private func toggleStrikethrough() {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let newStyle: Text.LineStyle? = isSelectionStrikethrough ? nil : .init(pattern: .solid)
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].strikethroughStyle = newStyle
            }
        }
    }

    // MARK: - Color actions

    private func applyColor(_ color: Color) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].foregroundColor = color
            }
        }
    }

    // MARK: - Link actions

    private func applyLink(_ urlString: String) {
        guard case let .ranges(ranges) = textSelection.indices(in: text) else { return }
        let url: URL?
        if urlString.isEmpty {
            url = nil
        } else {
            let normalized = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
            url = URL(string: normalized)
        }
        text.transform(updating: &textSelection) { mutableText in
            for range in ranges.ranges {
                mutableText[range].link = url
            }
        }
    }
}

@available(iOS 26.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    @Previewable @State var text: AttributedString = .init("Pack sunscreen, water, and snacks for the hike. Check weather forecast the day before departure.")
    NavigationStack {
        RichTextEditor("New Article", text: $text)
    }
}
