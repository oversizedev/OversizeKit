//
// Copyright © 2022 Alexander Romanov
// OnboardingView.swift
//

import OversizeUI
import SwiftUI

public struct OnboardingView<Content: View>: View {
    @Environment(\.screenSize) var screenSize

    @Binding private var selection: Int

    @Namespace private var onboardingItem

    @State private var slides: [OnboardingItem] = []

    private let finishAction: (() -> Void)?

    private var content: Content

    public init(selection: Binding<Int>, finishAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.finishAction = finishAction
        _selection = selection
    }

    public var body: some View {
        ZStack {
            VStack {
                PageIndexView($selection, maxIndex: slides.count)
                    .padding(.top, .large)
                Spacer()
            }

            TabView(selection: $selection) {
                //ForEach(Array(slides.enumerated()), id: \.offset) { index, element in

                tabItem(tabItem: OnboardingItem(title: "Title", subtitle: "Sub"), index: 0)
                        //.tag(index)
                //}
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
        .background(
            Color.backgroundSecondary.ignoresSafeArea()
        )
        .onPreferenceChange(OnboardingItemPreferenceKey.self) { value in
            self.slides = value
        }
    }

    private func tabItem(tabItem: OnboardingItem, index: Int) -> some View {
        VStack(spacing: .small) {
            
            if let image = tabItem.image {
                image
            }
            
            VStack {
                
                if let title = tabItem.title {
                    Text(title)
                        .largeTitle()
                        .foregroundColor(.onSurfaceHighEmphasis)
                        .padding(.bottom, .small)
                }

                if let subtitle = tabItem.subtitle {
                    Text(subtitle)
                        .foregroundColor(.onSurfaceMediumEmphasis)
                        .fontWeight(.regular)
                        .font(.system(size: 19))
                }
            }
            .offset(y: screenSize.height < 812 ? -50 : 0)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 320)
        .offset(y: -50)
        .padding(.bottom, .xLarge)
    }
}

//struct FloatingTabBarExample: View {
//    @State var selection = 0
//
//    var body: some View {
//        FloatingTabBar(selection: $selection, plusAction: { print("plus") }) {
//            Color.gray
//                .floatingTabItem {
//                    TabItem(icon: Image(systemName: "star"))
//                }
//                .opacity(selection == 0 ? 1 : 0)
//
//            Color.blue
//                .floatingTabItem {
//                    TabItem(icon: Image(systemName: "plus"))
//                }
//                .opacity(selection == 1 ? 1 : 0)
//        }
//    }
//}

//struct FloatingTabBar_Previews: PreviewProvider {
//    static var previews: some View {
//        FloatingTabBarExample()
//    }
//}
//
