//
// Copyright © 2025 Alexander Romanov
// EmojiTabBar.swift
//

import OversizeUI
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct EmojiTabBar: View {
    let groups: [EmojiGroup]
    @Binding var scrolledGroup: EmojiGroup?
    let proxy: ScrollViewProxy

    var body: some View {
        ScrollViewReader { tabProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .xSmall) {
                    ForEach(groups) { group in
                        Button {
                            scrolledGroup = group
                            withAnimation {
                                proxy.scrollTo(group, anchor: .top)
                            }
                        } label: {
                            Icon(group.sfSymbol)
                                .iconColor(Color.onSurfaceSecondary)
                                .padding(.xxSmall)
                                .background(
                                    Capsule()
                                        .fill(scrolledGroup == group ? Color.surfaceSecondary : Color.clear)
                                )
                        }
                        .buttonStyle(.scale)
                        .id(group)
                    }
                }
                .padding(.horizontal, .medium)
                .padding(.vertical, .xSmall)
            }
            .onChange(of: scrolledGroup) { _, newGroup in
                guard let newGroup else { return }
                withAnimation {
                    tabProxy.scrollTo(newGroup, anchor: .center)
                }
            }
        }
        .background {
            Color.surfacePrimary
                .ignoresSafeArea()
                .shadowElevation(.z1)
        }
    }
}
