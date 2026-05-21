//
// Copyright © 2024 Alexander Romanov
// RichTextSelectionActionsView.swift, created on 20.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
struct RichTextSelectionActionsView: View {
    @Binding var text: AttributedString
    var viewModel: RichTextEditorViewModel
    var namespace: Namespace.ID
    @Environment(\.fontResolutionContext) var fontResolutionContext

    var body: some View {
        if !viewModel.hasSelection(in: text) {
            Button {
                withAnimation(.interactiveSpring) {
                    viewModel.isFontStyleSelection.toggle()
                }
            } label: {
                Icon(Image.Base.chevronLeft)
                    .padding(.xSmall)
                    .padding(.leading, .xxxSmall)
            }
            .barItem(namespace: namespace)
        }

        // MARK: - Style

        #if os(iOS) || os(macOS)
        Button {
            viewModel.present(.textStylePicker)
        } label: {
            Text(viewModel.selectedTextStyle.displayName)
                .headline(.bold)
                .foregroundStyle(Color.onSurfacePrimary)
                .padding(.horizontal, .xSmall)
        }
        #if os(iOS)
        .matchedTransitionSource(id: "textStylePicker", in: namespace)
        #endif
        .barItem(namespace: namespace)

        Separator(.vertical)
            .lineWidth(3)
            .frame(height: .regular)
        #endif

        // MARK: - Bold

        Button {
            text = applyingBoldToggle(to: text)
        } label: {
            Icon(Image.Editor.boldType)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(isSelectionBold ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Italic

        if viewModel.isItalicSupported {
            Button {
                text = applyingItalicToggle(to: text)
            } label: {
                Icon(Image.Editor.italic)
                    .padding(.xxSmall)
                    .background(Circle().fillSurfaceSecondary().opacity(viewModel.selectedIsItalic ? 1 : 0))
                    .padding(.xxxSmall)
            }
            .barItem(namespace: namespace)
        }

        // MARK: - Underline

        Button {
            var mutableText = text
            viewModel.toggleUnderline(text: &mutableText)
            text = mutableText
        } label: {
            Icon(Image.Editor.underline)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(viewModel.isSelectionUnderlined(in: text) ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Strikethrough

        Button {
            var mutableText = text
            viewModel.toggleStrikethrough(text: &mutableText)
            text = mutableText
        } label: {
            Icon(Image.Editor.strikethrough)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(viewModel.isSelectionStrikethrough(in: text) ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)

        // MARK: - Font Family

        #if os(iOS) || os(macOS)
        Button {
            viewModel.present(.fontPicker)
        } label: {
            Icon(Image.Editor.searchFont)
                .padding(.xSmall)
        }
        #if os(iOS)
        .matchedTransitionSource(id: "fontPicker", in: namespace)
        #endif
        .barItem(namespace: namespace)
        #endif

        // MARK: - Link

        #if os(iOS) || os(macOS)
        Button {
            viewModel.linkURLString = viewModel.selectionCurrentLink(in: text)?.absoluteString ?? ""
            viewModel.present(.link)
        } label: {
            Icon(Image.Base.link)
                .padding(.xxSmall)
                .background(Circle().fillSurfaceSecondary().opacity(viewModel.hasSelectionLink(in: text) ? 1 : 0))
                .padding(.xxxSmall)
        }
        .barItem(namespace: namespace)
        #endif
    }

    // MARK: - Font Helpers

    private var isSelectionBold: Bool {
        let font = viewModel.textSelection.typingAttributes(in: text).font
        return (font ?? .default).resolve(in: fontResolutionContext).isBold
    }

    private func applyingBoldToggle(to text: AttributedString) -> AttributedString {
        var mutableText = text
        guard case let .ranges(ranges) = viewModel.textSelection.indices(in: mutableText) else { return text }
        let newBold = !isSelectionBold
        let italic = viewModel.selectedIsItalic
        let design = viewModel.selectedDesign
        let fontName = viewModel.selectedFontName
        mutableText.transform(updating: &viewModel.textSelection) { mt in
            for range in ranges.ranges {
                let runs = mt[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                for item in runs {
                    let resolved = item.font.resolve(in: fontResolutionContext)
                    mt[item.run].font = if let fontName {
                        resolveCustomFont(name: fontName, size: resolved.pointSize, bold: newBold, italic: italic)
                    } else {
                        resolveSystemFont(size: resolved.pointSize, bold: newBold, italic: italic, design: design)
                    }
                }
            }
        }
        return mutableText
    }

    private func applyingItalicToggle(to text: AttributedString) -> AttributedString {
        var mutableText = text
        guard case let .ranges(ranges) = viewModel.textSelection.indices(in: mutableText) else { return text }
        let newItalic = !viewModel.selectedIsItalic
        viewModel.selectedIsItalic = newItalic
        let design = viewModel.selectedDesign
        let fontName = viewModel.selectedFontName
        mutableText.transform(updating: &viewModel.textSelection) { mt in
            for range in ranges.ranges {
                let runs = mt[range].runs.map { (run: $0.range, font: $0.font ?? .body) }
                for item in runs {
                    let resolved = item.font.resolve(in: fontResolutionContext)
                    mt[item.run].font = if let fontName {
                        resolveCustomFont(name: fontName, size: resolved.pointSize, bold: resolved.isBold, italic: newItalic)
                    } else {
                        resolveSystemFont(size: resolved.pointSize, bold: resolved.isBold, italic: newItalic, design: design)
                    }
                }
            }
        }
        return mutableText
    }

    #if os(iOS)
    private func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        let weight: UIFont.Weight = bold ? .bold : .regular
        let baseDescriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let designedDescriptor: UIFontDescriptor = switch design {
        case .serif:
            baseDescriptor.withDesign(.serif) ?? baseDescriptor
        case .rounded:
            baseDescriptor.withDesign(.rounded) ?? baseDescriptor
        case .monospaced:
            baseDescriptor.withDesign(.monospaced) ?? baseDescriptor
        default:
            baseDescriptor
        }
        var traits = designedDescriptor.symbolicTraits
        if italic { traits.insert(.traitItalic) }
        if let finalDescriptor = designedDescriptor.withSymbolicTraits(traits) {
            return Font(UIFont(descriptor: finalDescriptor, size: size))
        }
        return Font(UIFont(descriptor: designedDescriptor, size: size))
    }

    private func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        guard let uiFont = UIFont(name: name, size: size) else {
            return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
        }
        var traits: UIFontDescriptor.SymbolicTraits = []
        if bold { traits.insert(.traitBold) }
        if italic { traits.insert(.traitItalic) }
        if let descriptor = uiFont.fontDescriptor.withSymbolicTraits(traits) {
            return Font(UIFont(descriptor: descriptor, size: size))
        }
        return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
    }

    #elseif os(macOS)
    private func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        let weight: NSFont.Weight = bold ? .bold : .regular
        let baseDescriptor = NSFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let designedDescriptor: NSFontDescriptor = switch design {
        case .serif:
            baseDescriptor.withDesign(.serif) ?? baseDescriptor
        case .rounded:
            baseDescriptor.withDesign(.rounded) ?? baseDescriptor
        case .monospaced:
            baseDescriptor.withDesign(.monospaced) ?? baseDescriptor
        default:
            baseDescriptor
        }
        var traits = designedDescriptor.symbolicTraits
        if italic { traits.insert(.italic) }
        let finalDescriptor = designedDescriptor.withSymbolicTraits(traits)
        if let nsFont = NSFont(descriptor: finalDescriptor, size: size) {
            return Font(nsFont)
        }
        return Font(NSFont(descriptor: designedDescriptor, size: size) ?? NSFont.systemFont(ofSize: size, weight: weight))
    }

    private func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        guard let nsFont = NSFont(name: name, size: size) else {
            return fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
        }
        let manager = NSFontManager.shared
        var result = nsFont
        result = bold
            ? manager.convert(result, toHaveTrait: .boldFontMask)
            : manager.convert(result, toNotHaveTrait: .boldFontMask)
        result = italic
            ? manager.convert(result, toHaveTrait: .italicFontMask)
            : manager.convert(result, toNotHaveTrait: .italicFontMask)
        return Font(result)
    }
    #else
    private func resolveSystemFont(size: CGFloat, bold: Bool, italic: Bool, design: Font.Design) -> Font {
        var font = Font.system(size: size, weight: bold ? .bold : .regular, design: design)
        if italic { font = font.italic() }
        return font
    }

    private func resolveCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        fallbackCustomFont(name: name, size: size, bold: bold, italic: italic)
    }
    #endif

    private func fallbackCustomFont(name: String, size: CGFloat, bold: Bool, italic: Bool) -> Font {
        var font = Font.custom(name, size: size)
        if bold { font = font.bold() }
        if italic { font = font.italic() }
        return font
    }
}

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
#Preview {
    @Previewable @State var text: AttributedString = .init("Sample text for selection")
    @Previewable @Namespace var namespace
    let viewModel = RichTextEditorViewModel()
    NavigationStack {
        RichTextSelectionActionsView(text: $text, viewModel: viewModel, namespace: namespace)
    }
}
