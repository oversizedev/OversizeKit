//
// Copyright © 2022 Alexander Romanov
// FireworksBubbles.swift
//

import OversizeCore
import SwiftUI

struct FireworkParticlesGeometryEffect: GeometryEffect {
    var time: Double
    var speed = Double.random(in: 20 ... 100)
    var direction = Double.random(in: -Double.pi ... Double.pi)

    var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    func effectValue(size _: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation: CGAffineTransform = .init(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

struct ParticlesBubblesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.3
    let duration = Double.random(in: 3.0 ... 7.0)

    func body(content: Content) -> some View {
        ZStack {
            ForEach(0 ..< 5, id: \.self) { _ in
                content
                    .hueRotation(Angle(degrees: time * 80))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity((duration - time) / duration)
                    .animation(.easeOut(duration: duration).repeatForever(autoreverses: false), value: scale)
            }
        }
        .onAppear {
            time = duration
            scale = 1.0
        }
    }
}

struct FireworksBubbles: View {
    @State var scaling: Bool = false

    var body: some View {
        ZStack {
            ForEach(0 ..< Int.random(in: 2 ... 5), id: \.self) { _ in
                Circle()
                    .fill(Color.onPrimaryTertiary)
                    .frame(width: 30, height: 30)
                    .modifier(ParticlesBubblesModifier())
                    .offset(x: CGFloat.random(in: -200 ... 200), y: CGFloat.random(in: -200 ... 200))
            }
            .zIndex(2)
        }
        .onAppear {
            scaling.toggle()
        }
    }
}

struct Fireworks: View {
    @State var scaling: Bool = false

    var body: some View {
        ZStack {
            ForEach(0 ..< Int.random(in: 10 ... 20), id: \.self) { _ in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .modifier(ParticlesBubblesModifier())
                    .offset(x: CGFloat.random(in: -200 ... 200), y: CGFloat.random(in: -200 ... 200))
            }
        }
        .onAppear {
            scaling.toggle()
        }
    }
}
