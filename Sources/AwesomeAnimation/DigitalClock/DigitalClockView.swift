import SwiftUI

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
            RollingDigitColumn(
                value: hours,
                previousValue: previousHours,
                digitCount: 2,
                digitColumnHeight: digitColumnHeight
            )

            Text(":")
                .font(_columnFont)
                .foregroundColor(separatorColor)
                .baselineOffset(-digitColumnHeight * 0.1)
                .frame(height: digitColumnHeight, alignment: .center)

            // Minutes
            RollingDigitColumn(
                value: minutes,
                previousValue: previousMinutes,
                digitCount: 2,
                digitColumnHeight: digitColumnHeight
            )

            Text(":")
                .font(_columnFont)
                .foregroundColor(separatorColor)
                .baselineOffset(-digitColumnHeight * 0.1)
                .frame(height: digitColumnHeight, alignment: .center)

            // Seconds
            RollingDigitColumn(
                value: seconds,
                previousValue: previousSeconds,
                digitCount: 2,
                digitColumnHeight: digitColumnHeight
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
        .onChange(of: value) { newValue in
            animateTo(newValue)
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

    private func animateTo(_ newValue: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            animatedValue = newValue
        }
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

    private var opacity: CGFloat {
        // Fade out as old digit moves up
        let progress = abs(oldDigitOffset) / digitHeight
        return max(0, 1 - progress)
    }

    private func rollTo() {
        // Reset positions
        newDigitOffset = digitHeight
        oldDigitOffset = 0

        // Animate both digits simultaneously
        withAnimation(.easeOut(duration: 0.2)) {
            newDigitOffset = 0  // New digit moves up to center
            oldDigitOffset = -digitHeight  // Old digit moves up and out
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        DigitalClockView()
            .foregroundColor(.red)

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
