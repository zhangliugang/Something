//
//  Metal.swift
//  Example
//
//  Created by liugang zhang on 2026/6/2.
//

import SwiftUI
import SwiftData

struct MetalExampleView: View {
    var body: some View {
        let start = Date().timeIntervalSince1970
        TimelineView(.animation) { context in
            let timestamp = context.date.timeIntervalSince1970 - start
            return Text("⭐ Animation ⭐")
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.blue.opacity(0.8)))
                .visualEffect { effect, proxy in
                    var factor = timestamp / 2
                    if factor > 1 {
                        factor = factor.truncatingRemainder(dividingBy: 1)
                    }

                    let maxHeightOffset = min(proxy.size.width / 1.5, proxy.size.width / 2.5 * factor)

                    let distortionShader = Shader(
                        function: ShaderFunction(library: .default, name: "rainbow"),
                        arguments: [.float(proxy.size.width), .float(maxHeightOffset)]
                    )

                    return effect
                        .distortionEffect(distortionShader, maxSampleOffset: .init(width: 0, height: maxHeightOffset))
                        .offset(y: maxHeightOffset)
                }
        }
    }
}

#Preview {
    MetalExampleView()
}
