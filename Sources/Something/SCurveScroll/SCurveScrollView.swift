import SwiftUI

// MARK: - S-Curve Scroll View

/// A custom scroll view where content moves along an S-shaped Bezier curve when scrolling vertically
public struct SCurveScrollView<Content: View>: View {
    let content: Content
    let itemCount: Int
    let itemHeight: CGFloat
    let amplitude: CGFloat
    let frequency: CGFloat

    @State private var scrollOffset: CGFloat = 0

    public init(
        itemCount: Int,
        itemHeight: CGFloat = 80,
        amplitude: CGFloat = 50,
        frequency: CGFloat = 2,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.itemCount = itemCount
        self.itemHeight = itemHeight
        self.amplitude = amplitude
        self.frequency = frequency
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Top padding to allow first items to start from center
                    Spacer()
                        .frame(width: 300)
                        .frame(height: geometry.size.height / 2)

                    ForEach(0..<itemCount, id: \.self) { index in
                        SCurveItem(
                            index: index,
                            itemHeight: itemHeight,
                            amplitude: amplitude,
                            frequency: frequency
                        ) {
                            content
                        }
                    }

                    // Bottom padding to allow last items to end at center
                    Spacer()
                        .frame(height: geometry.size.height / 2)
                }

                .background(
                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .named("scroll")).minY
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - S-Curve Item

private struct SCurveItem<Content: View>: View {
    let index: Int
    let itemHeight: CGFloat
    let amplitude: CGFloat
    let frequency: CGFloat
    @ViewBuilder let content: () -> Content

    @State private var horizontalOffset: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        content()
            .frame(width: itemHeight, height: itemHeight)
            .offset(x: horizontalOffset)
            .rotationEffect(.degrees(rotation), anchor: .center)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ItemPositionPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).minY
                        )
                }
            )
            .onPreferenceChange(ItemPositionPreferenceKey.self) { minY in
                updateOffset(y: minY)
            }
    }

    private func updateOffset(y: CGFloat) {
        // Use a fixed scale factor for the curve period
        let curveScale: CGFloat = 200

        // Calculate horizontal offset using sine function based on actual Y position
        let phase = y / curveScale * .pi * frequency
        horizontalOffset = sin(phase) * amplitude

        // Calculate rotation angle based on curve's derivative
        // The slope of the curve is the derivative of sin(phase) with respect to y
        // d(sin(phase))/dy = cos(phase) * d(phase)/dy = cos(phase) * (pi * frequency / curveScale)
        let slope = cos(phase) * amplitude * .pi * frequency / curveScale

        // Convert slope to angle in radians, then convert to degrees
        // Add 90 degrees to make the X-axis perpendicular to the tangent
        let tangentAngle = atan(slope)
        rotation = tangentAngle * 180 / .pi + 90
    }
}

// MARK: - Item Position Preference Key

private struct ItemPositionPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - SCurve Scroll View with Data

/// A convenience wrapper to hold data and content builder
public struct SCurveDataScrollView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let itemHeight: CGFloat
    let amplitude: CGFloat
    let frequency: CGFloat
    let content: (Data.Element) -> Content

    public init(
        data: Data,
        itemHeight: CGFloat = 80,
        amplitude: CGFloat = 50,
        frequency: CGFloat = 2,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.itemHeight = itemHeight
        self.amplitude = amplitude
        self.frequency = frequency
        self.content = content
    }

    public var body: some View {
        SCurveScrollView(
            itemCount: data.count,
            itemHeight: itemHeight,
            amplitude: amplitude,
            frequency: frequency
        ) {
            ForEach(data) { item in
                content(item)
            }
        }
    }
}

// MARK: - Preview Item

private struct PreviewItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let color: Color
}

// MARK: - Preview

#Preview {
    let items = (0..<20).map { i in
        PreviewItem(title: "Item \(i)", color: Color(hue: Double(i) / 20, saturation: 0.7, brightness: 0.9))
    }

    return SCurveDataScrollView(
        data: items,
        itemHeight: 80,
        amplitude: 60,
        frequency: 2
    ) { item in
        RoundedRectangle(cornerRadius: 8)
            .fill(item.color.opacity(0.3))
            .overlay(
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(item.color)
                    Text(item.title)
                        .font(.headline)
                }
            )
            .frame(width: 80, height: 80)
    }
}
