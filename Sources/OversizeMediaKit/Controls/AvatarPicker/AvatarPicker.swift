//
// Copyright © 2023 Alexander Romanov
// AvatarPicker.swift
//

import OversizeUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if os(iOS)
@available(iOS 17.0, *)
public struct AvatarPicker: View {
    @Binding private var avatar: UIImage?
    @State var isShowPicker: Bool = false

    public init(avatar: Binding<UIImage?>) {
        _avatar = avatar
    }

    public var body: some View {
        Button {
            isShowPicker.toggle()
        } label: {
            avatarLabel
        }
        .buttonStyle(.scale)
        .sheet(isPresented: $isShowPicker) {
            NavigationView {
                PhotoLibraryPicker(selection: $avatar)
            }
        }
    }

    @ViewBuilder
    private var avatarLabel: some View {
        if let avatar {
            Avatar(avatar: Image(uiImage: avatar))
                .controlSize(.large)
        } else {
            ZStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: Space.xxxLarge.rawValue, height: Space.xxxLarge.rawValue)

                Image.Base.Camera.fill
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.onSurfaceSecondary)
                    .frame(width: 48, height: 48)
            }
        }
    }
}

// MARK: - Deprecated

@available(iOS 17.0, *)
@available(*, deprecated, renamed: "AvatarPicker")
public typealias AvatarPickerView = AvatarPicker

@available(iOS 17.0, *)
#Preview {
    AvatarPicker(avatar: .constant(nil))
}
#endif
