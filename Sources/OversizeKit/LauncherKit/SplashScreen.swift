//
// Copyright © 2022 Alexander Romanov
// SplashScreen.swift
//

import OversizeServices
import OversizeUI
import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.accent

            #if os(iOS)
            if let appImage = Info.app.iconName {
                Image(uiImage: UIImage(named: appImage) ?? UIImage())
                    .resizable()
                    .frame(width: 128, height: 128)
                    .mask(RoundedRectangle(
                        cornerRadius: 28,
                        style: .continuous
                    ))
                    .padding(.top, Space.xxLarge)
            }

            #endif
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
