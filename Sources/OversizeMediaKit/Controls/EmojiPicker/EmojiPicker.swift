//
// Copyright © 2025 Alexander Romanov
// EmojiPicker.swift, created on 11.08.2025
//

import OversizeUI
import SwiftUI

// MARK: - EmojiPicker

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct EmojiPicker: View {
    @Environment(\.dismiss) private var dismiss

    private let label: String
    private let groups: [EmojiGroup]
    private let flatEmojis: [String]
    @Binding private var selection: String
    @State private var scrolledGroup: EmojiGroup?

    public init(_ label: String = "Emoji", emojis: [String], selection: Binding<String>) {
        self.label = label
        groups = []
        flatEmojis = emojis.compactMap {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n", with: "")
        }
        _selection = selection
    }

    public init(_ label: String = "Emoji", emojis: String, selection: Binding<String>) {
        self.label = label
        groups = []
        flatEmojis = emojis.replacingOccurrences(of: "\n", with: "").map { String($0) }
        _selection = selection
    }

    public init(_ label: String = "Emoji", groups: [EmojiGroup], selection: Binding<String>) {
        self.label = label
        self.groups = groups
        flatEmojis = []
        _selection = selection
    }

    public init(_ label: String = "Emoji", selection: Binding<String>) {
        self.label = label
        groups = EmojiGroup.allCases
        flatEmojis = []
        _selection = selection
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: .regular) {
                    if groups.isEmpty {
                        SectionView {
                            EmojiGrid(emojis: flatEmojis, selection: $selection)
                        }
                        .surfaceContentMargins(.small)
                        .sectionViewStyle(.smallIndent)
                        .surfaceRadius(.regular)
                       
                    } else {
                        ForEach(groups) { group in
                            EmojiGroupSection(group: group, selection: $selection)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, .small)
            }
            .scrollPosition(id: $scrolledGroup, anchor: .top)
            .navigationTitle(label)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if groups.count > 1 {
                    EmojiTabBar(groups: groups, scrolledGroup: $scrolledGroup, proxy: proxy)
                }
            }
        }
        .background(Color.backgroundSecondary)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview {
    NavigationStack {
        EmojiPicker(selection: .constant("😀"))
    }
}
