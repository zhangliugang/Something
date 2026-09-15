//
//  Clock.swift
//  Example
//
//  Created by liugang zhang on 2026/9/14.
//

import SwiftUI

struct ClockView: View {
    @State private var radius: CGFloat = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let comp = Calendar.current.dateComponents([.hour, .minute, .second], from: context.date)

            let seconds = Double(comp.second ?? 0)
            let minutes = Double(comp.minute ?? 0) + seconds / 60.0
            let hours = Double((comp.hour ?? 0) % 12) + minutes / 60.0

            let h_degree = (hours / 12.0) * .pi * 2 - .pi / 2
            let m_degree = (minutes / 60.0) * .pi * 2 - .pi / 2
            let s_degree = (context.date.timeIntervalSince1970 / 60.0) * .pi * 2 - .pi / 2
            ZStack {
                Circle()
                    .foregroundStyle(.cyan)
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        min(proxy.size.width, proxy.size.height)
                    } action: { newValue in
                        self.radius = newValue
                    }

                ClockLayout(inset: 10) {
                    ForEach(0..<60, id: \.self) { i in
                        Rectangle()
                            .frame(width: i % 5 == 0 ? 3 : 1, height: i % 5 == 0 ? 20 : 12)
                            .rotationEffect(.radians(Double(i) * .pi * 2 / 60))
                            .foregroundStyle(.white)
                    }
                }

                ClockLayout(inset: 30) {
                    ForEach(0...11, id: \.self) { i in
                        Text("\(i == 0 ? 12 : i)")
                    }
                }
                .font(.title)
                .fontWidth(.expanded)
                .fontWeight(.bold)

                Rectangle()
                    .frame(width: radius * 0.2, height: 7)
                    .rotationEffect(.radians(h_degree), anchor: .leading)
                    .visualEffect { content, proxy in
                        content.offset(x: proxy.size.width / 2)
                    }

                Rectangle()
                    .frame(width: radius * 0.3, height: 4)
                    .rotationEffect(.radians(m_degree), anchor: .leading)
                    .visualEffect { content, proxy in
                        content.offset(x: proxy.size.width / 2)
                    }

                Rectangle()
                    .fill(.red)
                    .frame(width: radius * 0.4, height: 2)
                    .animation(.linear(duration: 1)) { content in
                        content.rotationEffect(.radians(s_degree), anchor: .leading)
                    }
                    .visualEffect { content, proxy in
                        content.offset(x: proxy.size.width / 2)
                    }
            }
        }

    }
}

struct ClockLayout: Layout {
    var inset: Double = 10
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        if let w = proposal.width, let h = proposal.height {
            let min = min(w, h)
            return CGSize(width: min, height: min)
        }
        return .zero
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let radius = min(bounds.width, bounds.height) / 2 - inset
        let d = Double.pi / Double(subviews.count) * 2

        for (index, view) in subviews.enumerated() {
            let x = radius * sin(d * Double(index))
            let y = radius * cos(d * Double(index))

            view.place(at: .init(x: x + bounds.midX, y: -y + bounds.midY), anchor: .center, proposal: .unspecified)
        }
    }
}


#Preview {
    ClockView()
}
