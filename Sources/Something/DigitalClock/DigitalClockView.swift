import SwiftUI

// MARK: - Environment Key for Animation Type

private struct ClockAnimationTypeKey: EnvironmentKey {
    static let defaultValue: DigitalClockAnimationType = .rolling
}

extension EnvironmentValues {
    var clockAnimationType: DigitalClockAnimationType {
        get { self[ClockAnimationTypeKey.self] }
        set { self[ClockAnimationTypeKey.self] = newValue }
    }
}

// MARK: - View Modifier for Animation Type

extension View {
    public func digitalClockAnimationType(_ type: DigitalClockAnimationType) -> some View {
        self.environment(\.clockAnimationType, type)
    }
}

/// Animation type for digit transitions
public enum DigitalClockAnimationType: String, CaseIterable, Identifiable, Sendable {
    case rolling = "Rolling"
    case flip = "Flip"

    public var id: String { rawValue }
}

/// A digital clock view that displays hours, minutes, and seconds with rolling animations
public struct DigitalClockView: View {
    @State private var currentTime = Date()
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    @State private var previousHours: Int = 0
    @State private var previousMinutes: Int = 0
    @State private var previousSeconds: Int = 0

    @Environment(\.font) var font: Font?
    @Environment(\.clockAnimationType) var animationType

    /// Background color of the clock
    public var backgroundColor: Color = .clear

    /// Whether to show background padding
    public var showBackground: Bool = false

    /// Separator color between time components
    public var separatorColor: Color = .primary.opacity(0.5)

    /// Height of each digit column
    public var digitColumnHeight: CGFloat = 80

    private var _columnFont: Font {
        font ?? .system(size: 60, weight: .bold, design: .monospaced).leading(.tight)
    }

    public init() {
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Hours
            digitColumn(
                value: hours,
                previousValue: previousHours
            )

            Text(":")
                .font(_columnFont)
                .foregroundColor(separatorColor)
                .baselineOffset(-digitColumnHeight * 0.1)
                .frame(height: digitColumnHeight, alignment: .center)

            // Minutes
            digitColumn(
                value: minutes,
                previousValue: previousMinutes
            )

            Text(":")
                .font(_columnFont)
                .foregroundColor(separatorColor)
                .baselineOffset(-digitColumnHeight * 0.1)
                .frame(height: digitColumnHeight, alignment: .center)

            // Seconds
            digitColumn(
                value: seconds,
                previousValue: previousSeconds
            )
        }
        .padding(showBackground ? 20 : 0)
        .background(backgroundColor)
        .cornerRadius(showBackground ? 12 : 0)
        .onAppear {
            updateTime()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateTime()
        }
    }

    @ViewBuilder
    private func digitColumn(value: Int, previousValue: Int) -> some View {
        switch animationType {
        case .rolling:
            RollingDigitColumn(
                value: value,
                previousValue: previousValue,
                digitCount: 2,
                digitColumnHeight: digitColumnHeight
            )
        case .flip:
            FlipDigitColumn(
                value: value,
                previousValue: previousValue,
                digitCount: 2,
                digitColumnHeight: digitColumnHeight
            )
        }
    }

    private func updateTime() {
        let calendar = Calendar.current
        let newHours = calendar.component(.hour, from: currentTime)
        let newMinutes = calendar.component(.minute, from: currentTime)
        let newSeconds = calendar.component(.second, from: currentTime)

        // Update previous values before they change
        if hours != newHours {
            previousHours = hours
        }
        if minutes != newMinutes {
            previousMinutes = minutes
        }
        if seconds != newSeconds {
            previousSeconds = seconds
        }

        // Update current values
        hours = newHours
        minutes = newMinutes
        seconds = newSeconds

        // Advance time
        currentTime = Date()
    }
}

// MARK: - Rolling Digit Column

/// A single digit column that animates rolling changes
struct RollingDigitColumn: View {
    let value: Int
    let previousValue: Int
    let digitCount: Int
    let digitColumnHeight: CGFloat

    @State private var animatedValue: Int = 0
    @State private var previousAnimatedValue: Int = 0
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(String(format: "%0\(digitCount)d", value).enumerated()), id: \.offset) { index, digit in
                RollingDigit(
                    digit: Int(String(digit)) ?? 0,
                    previousDigit: getPreviousDigit(for: index),
                    digitHeight: digitColumnHeight
                )
            }
        }
    }

    private func getPreviousDigit(for position: Int) -> Int {
        let previousString = String(format: "%0\(digitCount)d", previousValue)
        let previousDigits = Array(previousString).compactMap { Int(String($0)) }
        if position < previousDigits.count {
            return previousDigits[position]
        }
        return 0
    }
}

/// A single digit that rolls from bottom to top
struct RollingDigit: View {
    let digit: Int
    let previousDigit: Int
    let digitHeight: CGFloat

    @State private var newDigitOffset: CGFloat = 0
    @State private var oldDigitOffset: CGFloat = 0

    @Environment(\.font) var font: Font?

    var body: some View {
        ZStack {
            // Old digit (slides up and fades out)
            Text("\(previousDigit)")
                .font(font ?? .system(size: 60, weight: .bold, design: .monospaced))
                .frame(width: fontSize, height: digitHeight)
                .offset(y: oldDigitOffset)
                .clipped()

            // New digit (slides up from bottom)
            Text("\(digit)")
                .font(font ?? .system(size: 60, weight: .bold, design: .monospaced))
                .frame(width: fontSize, height: digitHeight)
                .offset(y: newDigitOffset)
        }
        .frame(width: fontSize, height: digitHeight * 2)
        .clipped()
        .onChange(of: digit) { _ in
            rollTo()
        }
    }

    private var fontSize: CGFloat {
        digitHeight * 0.6
    }

    private func rollTo() {
        // Reset positions
        newDigitOffset = digitHeight
        oldDigitOffset = 0

        // Animate both digits simultaneously
        withAnimation(.easeOut(duration: 0.2)) {
            newDigitOffset = 0
            oldDigitOffset = -digitHeight
        }
    }
}

// MARK: - Flip Digit Column

/// A single digit column that animates with 3D flip effect
struct FlipDigitColumn: View {
    let value: Int
    let previousValue: Int
    let digitCount: Int
    let digitColumnHeight: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(String(format: "%0\(digitCount)d", value).enumerated()), id: \.offset) { index, digit in
                FlipDigit(
                    digit: Int(String(digit)) ?? 0,
                    previousDigit: getPreviousDigit(for: index),
                    digitHeight: digitColumnHeight
                )
            }
        }
    }

    private func getPreviousDigit(for position: Int) -> Int {
        let previousString = String(format: "%0\(digitCount)d", previousValue)
        let previousDigits = Array(previousString).compactMap { Int(String($0)) }
        if position < previousDigits.count {
            return previousDigits[position]
        }
        return 0
    }
}

/// A single digit with 3D page flip animation
struct FlipDigit: View {
    let digit: Int
    let previousDigit: Int
    let digitHeight: CGFloat

    @State private var flipAngle: Double = 0
    @State private var flipAngle2: Double = 90

    @Environment(\.font) var font: Font?

    var body: some View {
        let halfHeight = digitHeight / 2
        let actualFont = font ?? .system(size: 60, weight: .bold, design: .monospaced)

        return ZStack {
            VStack(spacing: 0) {
                Text("\(previousDigit)")
                    .font(actualFont)
                    .frame(width: fontSize, height: digitHeight)
                    .offset(y: halfHeight / 2)
                    .frame(width: fontSize, height: halfHeight)
                    .clipped()
                    .background(Color.white)
                Text("\(digit)")
                    .font(actualFont)
                    .frame(width: fontSize, height: digitHeight)
                    .offset(y: -halfHeight / 2)
                    .frame(width: fontSize, height: halfHeight)
                    .clipped()
                    .background(Color.white)

            }
            .background(Color.white)

            VStack(spacing: 0) {
                Text("\(digit)")
                    .font(actualFont)
                    .frame(width: fontSize, height: digitHeight)
                    .offset(y: halfHeight / 2)
                    .background(Color.white)
                    .frame(width: fontSize, height: halfHeight)
                    .clipped()
                    .rotation3DEffect(
                        .degrees(flipAngle2),
                        axis: (x: -1, y: 0, z: 0),
                        anchor: .bottom,  // 绕底部轴心翻转
                        anchorZ: 0,
                        perspective: 0
                    )

                Text("\(previousDigit)")
                    .font(actualFont)
                    .frame(width: fontSize, height: digitHeight)
                    .offset(y: -halfHeight / 2)
                    .background(Color.white)
                    .frame(width: fontSize, height: halfHeight)
                    .clipped()
                    .rotation3DEffect(
                        .degrees(flipAngle),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,  // 绕顶部轴心翻转
                        anchorZ: 0,
                        perspective: 0
                    )
            }
            .frame(width: fontSize, height: digitHeight)
        }
        .frame(width: fontSize, height: digitHeight)
        .onChange(of: digit) { _ in
            performFlip()
        }
    }

    private var fontSize: CGFloat {
        digitHeight * 0.6
    }

    private func performFlip() {
        flipAngle = 0
        flipAngle2 = 90
        withAnimation(.linear(duration: 0.12)) {
            flipAngle = 90
        }
        withAnimation(.linear(duration: 0.12).delay(0.12)) {
            flipAngle2 = 0
        }
    }
}
// 定义上半部分的形状
struct TopHalfShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 矩形范围：从顶部开始，高度为总高度的一半
        path.addRect(CGRect(x: 0, y: 0, width: rect.width, height: rect.height / 2))
        return path
    }
}

// 定义下半部分的形状
struct BottomHalfShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 矩形范围：从中间开始，高度为剩下的另一半
        path.addRect(CGRect(x: 0, y: rect.height / 2, width: rect.width, height: rect.height / 2))
        return path
    }
}

#Preview {
    VStack(spacing: 30) {
        DigitalClockView()
            .foregroundColor(.red)
            .digitalClockAnimationType(.flip)

        DigitalClockView()
            .font(.system(size: 80, weight: .bold, design: .monospaced))
            .padding(20)

        DigitalClockView()
            .font(.system(size: 40, weight: .medium, design: .rounded))
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    .padding()
}
