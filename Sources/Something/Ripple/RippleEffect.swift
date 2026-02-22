//
//  RippleEffect.swift
//  AwesomeAnimation
//
//  Created by liugang zhang on 2026/2/13.
//

import SwiftUI

public struct RippleEffectModifier<T: Equatable>: ViewModifier {
    var trigger: T
    var origin: CGPoint
    var duration: TimeInterval = 3

    var amplitude: Double
    var frequency: Double
    var decay: Double
    var speed: Double

    public init(at origin: CGPoint, trigger: T, amplitude: Double = 12, frequency: Double = 15, decay: Double = 8, speed: Double = 1200) {
        self.origin = origin
        self.trigger = trigger
        self.amplitude = amplitude
        self.frequency = frequency
        self.decay = decay
        self.speed = speed
    }

    public func body(content: Content) -> some View {
        content.keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, elapsedTime in
            let shader = ShaderLibrary.bundle(.module).Ripple(
                .float2(origin),
                .float(elapsedTime),
                .float(amplitude),
                .float(frequency),
                .float(decay),
                .float(speed),
                )
            view
                .visualEffect { view, _ in
                    view.layerEffect(
                        shader,
                        maxSampleOffset: maxSampleOffset,
                        isEnabled: 0 < elapsedTime && elapsedTime < duration
                    )
                }
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }

    }

    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }
}

#Preview {
    @Previewable @State var counter: Int = 0
    @Previewable @State var origin: CGPoint = .zero
    VStack {
        Circle().fill(Color.blue) // You can replace this with your view
            .modifier(RippleEffectModifier(at: origin, trigger: counter))
            .onTapGesture { location in
                origin = location
                counter += 1
            }
    }
    .padding()
}
