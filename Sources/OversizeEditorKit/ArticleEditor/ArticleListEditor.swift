//
// Copyright © 2024 Alexander Romanov
// ArticleListEditor.swift, created on 03.03.2024
//

import OversizeResources
import OversizeUI
import PhotosUI
import SwiftUI

// MARK: - Models

enum BlockType { case text, image, separator, quote, list }

struct ArticleBlock: Identifiable {
    let id: UUID
    var type: BlockType
    var text: String
    var imageData: Data?

    init(text: String = "") {
        id = UUID(); type = .text; self.text = text
    }

    init(imageData: Data) {
        id = UUID(); type = .image; text = ""; self.imageData = imageData
    }

    init(type: BlockType, text: String = "") {
        id = UUID(); self.type = type; self.text = text
    }
}

// MARK: - ArticleListEditor

@available(iOS 26.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
public struct ArticleListEditor: View {
    @Namespace private var unionNamespace
    @Environment(\.dismiss) private var dismiss

    @State private var blocks: [ArticleBlock] = [.init()]
    @FocusState private var focusedId: UUID?
    @State private var imagePickerPresented = false
    @State private var selectedImage: PhotosPickerItem?

    public init() {}

    public var body: some View {
        List {
            ForEach($blocks) { $block in
                Group {
                    switch block.type {
                    case .text: textBlockView(block: $block)
                    case .image: imageBlockView(block: $block)
                    case .separator: separatorBlockView
                    case .quote: quoteBlockView(block: $block)
                    case .list: listBlockView(block: $block)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: .medium, bottom: 0, trailing: .medium))
            }
            .onMove { blocks.move(fromOffsets: $0, toOffset: $1) }
            .onDelete { blocks.remove(atOffsets: $0) }
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            glassBottomBar
        }
        .toolbarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            focusedId = blocks.first?.id
        }
    }

    // MARK: - Helpers

    private func makeTextBinding(for blockId: UUID) -> Binding<String> {
        Binding<String>(
            get: { blocks.first(where: { $0.id == blockId })?.text ?? "" },
            set: { newValue in
                guard let idx = blocks.firstIndex(where: { $0.id == blockId }) else { return }
                if let nl = newValue.firstIndex(of: "\n") {
                    let before = String(newValue[..<nl])
                    let afterStart = newValue.index(after: nl)
                    let after = afterStart < newValue.endIndex ? String(newValue[afterStart...]) : ""
                    blocks[idx].text = before
                    let newBlock = ArticleBlock(text: after)
                    blocks.insert(newBlock, at: idx + 1)
                    focusedId = newBlock.id
                } else {
                    blocks[idx].text = newValue
                }
            }
        )
    }

    private func insertBlock(_ newBlock: ArticleBlock) {
        if let idx = blocks.firstIndex(where: { $0.id == focusedId }) {
            blocks.insert(newBlock, at: idx + 1)
        } else {
            blocks.append(newBlock)
        }
        if newBlock.type == .text || newBlock.type == .quote || newBlock.type == .list {
            focusedId = newBlock.id
        }
    }

    private func deleteKeyHandler(blockId: UUID) -> KeyPress.Result {
        guard let idx = blocks.firstIndex(where: { $0.id == blockId }),
              blocks[idx].text.isEmpty,
              idx > 0
        else { return .ignored }
        blocks.remove(at: idx)
        focusedId = blocks[..<idx].last(where: { $0.type == .text || $0.type == .quote || $0.type == .list })?.id
        return .handled
    }

    // MARK: - Block Views

    @ViewBuilder
    private func textBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.id
        TextEditor(text: makeTextBinding(for: blockId))
            .frame(minHeight: 44)
            .focused($focusedId, equals: blockId)
            .overlay(alignment: .trailing) {
                if focusedId == blockId {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.tertiary)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: focusedId)
            .onKeyPress(.delete) { deleteKeyHandler(blockId: blockId) }
    }

    @ViewBuilder
    private func quoteBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.id
        HStack(alignment: .top, spacing: .xSmall) {
            RoundedRectangle(cornerRadius: 2)
                .fill(.tint.opacity(0.7))
                .frame(width: 3)
                .padding(.vertical, .xxSmall)
            TextEditor(text: makeTextBinding(for: blockId))
                .frame(minHeight: 44)
                .italic()
                .foregroundStyle(.secondary)
                .focused($focusedId, equals: blockId)
                .onKeyPress(.delete) { deleteKeyHandler(blockId: blockId) }
        }
        .overlay(alignment: .trailing) {
            if focusedId == blockId {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: focusedId)
    }

    private func makeListTextBinding(for blockId: UUID) -> Binding<String> {
        Binding<String>(
            get: { blocks.first(where: { $0.id == blockId })?.text ?? "" },
            set: { newValue in
                guard let idx = blocks.firstIndex(where: { $0.id == blockId }) else { return }
                if let nl = newValue.firstIndex(of: "\n") {
                    let before = String(newValue[..<nl])
                    let afterStart = newValue.index(after: nl)
                    let after = afterStart < newValue.endIndex ? String(newValue[afterStart...]) : ""
                    blocks[idx].text = before
                    let newBlock = ArticleBlock(type: .list, text: after)
                    blocks.insert(newBlock, at: idx + 1)
                    focusedId = newBlock.id
                } else {
                    blocks[idx].text = newValue
                }
            }
        )
    }

    @ViewBuilder
    private func listBlockView(block: Binding<ArticleBlock>) -> some View {
        let blockId = block.id
        HStack(alignment: .top, spacing: .xSmall) {
            Text("•")
                .foregroundStyle(.primary)
                .padding(.top, 4)
            TextEditor(text: makeListTextBinding(for: blockId))
                .frame(minHeight: 44)
                .focused($focusedId, equals: blockId)
                .onKeyPress(.delete) { deleteKeyHandler(blockId: blockId) }
        }
        .overlay(alignment: .trailing) {
            if focusedId == blockId {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tertiary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: focusedId)
    }

    private var separatorBlockView: some View {
        Divider()
            .padding(.vertical, .small)
    }

    @ViewBuilder
    private func imageBlockView(block: Binding<ArticleBlock>) -> some View {
        if let data = block.imageData.wrappedValue, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.vertical, .xSmall)
                .overlay(alignment: .topTrailing) {
                    Button {
                        blocks.removeAll(where: { $0.id == block.id })
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.5))
                            .font(.title3)
                    }
                    .padding(.xSmall)
                }
        }
    }

    // MARK: - Bottom Bar

    var glassBottomBar: some View {
        GlassEffectContainer(spacing: .zero) {
            HStack(spacing: .zero) {
                Button { imagePickerPresented = true } label: {
                    Icon(Image.Base.picture2)
                        .padding(.xSmall)
                        .padding(.leading, .xxxSmall)
                }
                .glassEffect()
                .glassEffectUnion(id: "bar", namespace: unionNamespace)
                .photosPicker(isPresented: $imagePickerPresented, selection: $selectedImage, matching: .images)
                .onChange(of: selectedImage) { _, item in
                    Task {
                        guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                        let newBlock = ArticleBlock(imageData: data)
                        await MainActor.run {
                            insertBlock(newBlock)
                            selectedImage = nil
                        }
                    }
                }

                Button { insertBlock(ArticleBlock(type: .quote)) } label: {
                    Icon(Image(systemName: "text.quote"))
                        .padding(.xSmall)
                }
                .glassEffect()
                .glassEffectUnion(id: "bar", namespace: unionNamespace)

                Button { insertBlock(ArticleBlock(type: .list)) } label: {
                    Icon(Image(systemName: "list.bullet"))
                        .padding(.xSmall)
                }
                .glassEffect()
                .glassEffectUnion(id: "bar", namespace: unionNamespace)

                Button { insertBlock(ArticleBlock(type: .separator)) } label: {
                    Icon(Image.Base.attach)
                        .padding(.xSmall)
                }
                .glassEffect()
                .glassEffectUnion(id: "bar", namespace: unionNamespace)

                Button {} label: {
                    Icon(Image.Base.link)
                        .padding(.xSmall)
                }
                .glassEffect()
                .glassEffectUnion(id: "bar", namespace: unionNamespace)

                Spacer()
            }
        }
        .padding(.horizontal, .small)
        .padding(.vertical, .xSmall)
        .controlSize(.regular)
        .buttonStyle(.scale)
    }
}

// MARK: - Preview

@available(iOS 26.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
#Preview {
    NavigationStack {
        ArticleListEditor()
    }
}
