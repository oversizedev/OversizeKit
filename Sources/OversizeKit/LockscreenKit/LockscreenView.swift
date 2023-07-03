//
// Copyright © 2022 Alexander Romanov
// LockscreenView.swift
//

import OversizeCore
import OversizeServices
import OversizeUI
import SwiftUI

public enum LockscreenViewState {
    case locked, loading, error, unlocked
}

public struct LockscreenView: View {
    #if os(iOS)
        @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
        @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    #endif
    @Environment(\.scenePhase) var scenePhase: ScenePhase

    @Binding private var pinCode: String

    @Binding private var state: LockscreenViewState

    @State private var shouldAnimate = false

    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    @State var leftOffset: CGFloat = 0
    @State var rightOffset: CGFloat = 50

    private var maxCount: Int

    private var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 0), count: 3)

    private let action: (() -> Void)?
    private let biometricAction: (() -> Void)?

    private let title: String?

    private let errorText: String?

    private let pinCodeEnabled: Bool
    private let biometricEnabled: Bool
    private let biometricType: BiometricType

    private var isShowTitle: Bool {
        #if os(iOS)
            if horizontalSizeClass == .compact, verticalSizeClass == .regular {
                return true
            } else if horizontalSizeClass == .regular, verticalSizeClass == .compact {
                return false
            } else if horizontalSizeClass == .regular, verticalSizeClass == .regular {
                return true
            } else {
                return true
            }
        #else
            return true
        #endif
    }

    public init(pinCode: Binding<String>,
                state: Binding<LockscreenViewState> = .constant(.locked),
                maxCount: Int = 4,
                title: String? = nil,
                errorText: String? = nil,
                pinCodeEnabled: Bool = true,
                biometricEnabled: Bool = false,
                biometricType: BiometricType = .faceID,
                action: (() -> Void)? = nil,
                biometricAction: (() -> Void)? = nil)
    {
        _pinCode = pinCode
        _state = state
        self.maxCount = maxCount
        self.title = title
        self.errorText = errorText
        self.pinCodeEnabled = pinCodeEnabled
        self.biometricEnabled = biometricEnabled
        self.biometricType = biometricType
        self.action = action
        self.biometricAction = biometricAction
    }

    public var body: some View {
        content()
            .background(Color.surfacePrimary.ignoresSafeArea(.all))
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    if state == .locked, biometricEnabled {
                        biometricAction?()
                    }
                default:
                    break
                }
            }
    }

    @ViewBuilder
    func content() -> some View {
        switch pinCodeEnabled {
        case true:
            pinCodeView
        case false:
            biometricView
        }
    }

    var biometricView: some View {
        VStack {
            Spacer()

            if let appImage = Info.app.iconName {
                #if os(iOS)

                    Image(uiImage: UIImage(named: appImage) ?? UIImage())
                        .resizable()
                        .frame(width: 96, height: 96)
                        .mask(RoundedRectangle(cornerRadius: 26,
                                               style: .continuous))

                #else
                    Text(biometricType.rawValue)
                        .title2(.bold)
                        .foregroundColor(.onSurfaceHighEmphasis)

                #endif

            } else {
                Text(biometricType.rawValue)
                    .title2(.semibold)
                    .foregroundColor(.onSurfaceHighEmphasis)
            }

            Spacer()

            #if os(iOS)

                Button { biometricAction?() } label: {
                    HStack(spacing: .xSmall) {
                        biometricImage()
                            .padding(.leading, 2)

                        Text("Open with \(biometricType.rawValue)")
                    }
                    .padding(.horizontal, .xxxSmall)
                }
                .buttonStyle(.tertiary(infinityWidth: false))
                .controlBorderShape(.capsule)
                .controlSize(.small)
            #endif

            Spacer()
        }
        .hCenter()
    }

    var pinCodeView: some View {
        VStack {
            if isShowTitle {
                Spacer()

                Text(title ?? "")
                    .title2(.bold)
                    .foregroundColor(.onSurfaceHighEmphasis)
                    .opacity(title != nil ? 1 : 0)

                Spacer()
            }

            pinCounter(state: state)
                .padding()

            if isShowTitle {
                Spacer()
            }

            Text(errorText ?? "")
                .subheadline()
                .errorForegroundColor()
                .opacity(state == .error ? 1 : 0)

            if isShowTitle {
                Spacer()
            }

            numpad
        }
    }

    var numpad: some View {
        LazyVGrid(columns: gridItemLayout, spacing: isShowTitle ? 20 : 4) {
            ForEach(1 ... 9, id: \.self) { number in

                let stringNumber: String = .init(number)

                Button {
                    appendNumber(number: Character(stringNumber))

                } label: {
                    Text(stringNumber)
                }
                .buttonStyle(NumpadButtonStyle())
                .disabled(state == .loading)
            }

            Button {} label: {
                Text("...")
            }.opacity(0)

            Button {
                appendNumber(number: Character("0"))
            } label: {
                Text("0")
            }
            .buttonStyle(NumpadButtonStyle())
            .disabled(state == .loading)

            Button {
                if pinCode.isEmpty, biometricEnabled {
                    biometricAction?()
                } else if pinCode.isEmpty, !biometricEnabled {
                } else {
                    deleteLastNumber()
                }
            } label: {
                if pinCode.isEmpty, biometricEnabled {
                    biometricImage()
                } else if pinCode.isEmpty, !biometricEnabled {
                    EmptyView()
                } else {
                    IconDeprecated(.delete)
                }
            } // .opacity(pinCode.isEmpty && biometricEnabled ? 1 : 0)
        }
        .paddingContent(isShowTitle ? .all : .horizontal)
        .padding(.bottom, isShowTitle ? .xLarge : .zero)
    }

    @ViewBuilder
    private func biometricImage() -> some View {
        switch biometricType {
        case .none:
            EmptyView()
        case .touchID:
            Image(systemName: "touchid")
                .foregroundColor(Color.onBackgroundHighEmphasis)
                .font(.system(size: 26))
                .frame(width: 24, height: 24, alignment: .center)
        case .faceID:
            Image(systemName: "faceid")
                .font(.system(size: 26))
                .foregroundColor(Color.onBackgroundHighEmphasis)
                .frame(width: 24, height: 24, alignment: .center)
        }
    }

    @ViewBuilder
    private func pinCounter(state: LockscreenViewState) -> some View {
        switch state {
        case .locked, .error, .unlocked:
            HStack(spacing: .xSmall) {
                ForEach(0 ..< maxCount, id: \.self) { number in
                    Circle()
                        .fill(pinCode.count <= number ? Color.surfaceTertiary
                            : Color.accent)
                        .frame(width: 12, height: 12)
                }
            }
        case .loading:
            HStack(spacing: .xSmall) {
                ForEach(0 ..< maxCount, id: \.self) { number in
                    Circle()
                        .fill(pinCode.count <= number ? Color.surfaceTertiary
                            : Color.accent)
                        .frame(width: 12, height: 12)
                        .offset(x: leftOffset)
                        // .animation(Animation.easeInOut(duration: 1).delay(0.2 * Double(number)))

                        .scaleEffect(shouldAnimate ? 0.5 : 1)
                        .animation(Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(number == 0 ? 0 : 0.5 * Double(number)), value: shouldAnimate)
                }
            }
            .onReceive(timer) { _ in
                shouldAnimate.toggle()
            }
        }
    }

    func appendNumber(number: Character) {
        state = .locked

        if pinCode.count > (maxCount - 1) {
            log("return")
            return
        }

        if pinCode.count >= (maxCount - 1) {
            pinCode.append(number)
            enterAction()
        } else {
            pinCode.append(number)
        }
    }

    func deleteLastNumber() {
        state = .locked

        if pinCode.count <= maxCount {
            // isDisabledNumpad = false
        }
        pinCode.removeLast()
        log(pinCode)
    }

    func enterAction() {
        action?()
    }
}

public struct NumpadButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .title2()
            .foregroundColor(.onSurfaceHighEmphasis)
            .frame(width: 72, height: 72, alignment: .center)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.surfaceTertiary : Color.surfaceSecondary)
            )
    }
}

struct PINCodeView_Previews: PreviewProvider {
    static var previews: some View {
        LockscreenView(pinCode: .constant("123"), state: .constant(.locked))
    }
}
