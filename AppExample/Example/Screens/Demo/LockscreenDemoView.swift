//
// Copyright © 2026 Alexander Romanov
// LockscreenDemoView.swift, created on 19.09.2026
//

import OversizeKit
import OversizeUI
import SwiftUI

struct LockscreenDemoView: View {
    @State private var pinCode: String = ""
    @State private var lockscreenState: LockscreenViewState = .locked
    @State private var isShowLockscreen = false
    @State private var isShowSetPINCode = false

    var body: some View {
        ScrollView {
            SectionView("Screens") {
                VStack(spacing: .zero) {
                    Row("Lockscreen") {
                        pinCode = ""
                        lockscreenState = .locked
                        isShowLockscreen = true
                    } leading: {
                        Image(systemName: "lock")
                    }
                    .navigatable()
                    .buttonStyle(.row)

                    Row("Set PIN code") {
                        isShowSetPINCode = true
                    } leading: {
                        Image(systemName: "number")
                    }
                    .navigatable()
                    .buttonStyle(.row)
                }
            }
            .sectionContentCompactRowMargins()
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Lockscreen")
        #if os(iOS)
        .fullScreenCover(isPresented: $isShowLockscreen) {
            lockscreen
        }
        #else
        .sheet(isPresented: $isShowLockscreen) {
            lockscreen
        }
        #endif
        .sheet(isPresented: $isShowSetPINCode) {
            NavigationStack {
                SetPINCodeView(action: .set)
            }
        }
    }

    private var lockscreen: some View {
        LockscreenView(
            pinCode: $pinCode,
            state: $lockscreenState,
            title: "Enter the code 1234",
            errorText: "Wrong code",
            pinCodeEnabled: true,
            biometricEnabled: true,
            action: {
                if pinCode == "1234" {
                    isShowLockscreen = false
                } else {
                    lockscreenState = .error
                    pinCode = ""
                }
            },
            biometricAction: {
                isShowLockscreen = false
            }
        )
        .overlay(alignment: .topTrailing) {
            Button("Close") {
                isShowLockscreen = false
            }
            .buttonStyle(.tertiary)
            .controlBorderShape(.capsule)
            .paddingContent()
        }
    }
}

#Preview {
    NavigationStack {
        LockscreenDemoView()
    }
    .appEnvironment()
}
