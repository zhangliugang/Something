import SwiftUI

public struct LetterFlow: View {
    @Binding public var text: String
    public var font: Font = .largeTitle
    public var foregroundColor: Color = .primary
    public var activeColor: Color = .blue
    public var spacing: CGFloat = 8

    @State private var draggedIndex: Int?
    @State private var dragOffset: CGFloat = 0
    @State private var characters: [Character]

    public init(text: Binding<String>,
                font: Font = .largeTitle,
                foregroundColor: Color = .primary,
                activeColor: Color = .blue,
                spacing: CGFloat = 8) {
        self._text = text
        self.font = font
        self.foregroundColor = foregroundColor
        self.activeColor = activeColor
        self.spacing = spacing
        self._characters = State(initialValue: Array(text.wrappedValue))
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                LetterView(
                    character: character,
                    font: font,
                    foregroundColor: foregroundColor,
                    activeColor: activeColor,
                    isDragging: draggedIndex == index,
                    offset: dragOffset(for: index)
                )
                .frame(width: fontSize, height: fontSize)
                .border(Color.red)
                .gesture(dragGesture(for: index))
            }
        }
        .padding(.horizontal, spacing)
        .onChange(of: text) { newValue in
            characters = Array(newValue)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: draggedIndex)
    }

    private var fontSize: CGFloat {
        switch font {
        case .largeTitle: return 60
        case .title: return 48
        case .title2: return 40
        case .title3: return 34
        case .headline: return 28
        case .body: return 24
        case .callout: return 20
        case .subheadline: return 18
        case .caption: return 16
        case .caption2: return 14
        default: return 34
        }
    }

    private func dragOffset(for index: Int) -> CGFloat {
        guard let dragged = draggedIndex else { return 0 }

        if dragged == index {
            return dragOffset
        }

        let cellWidth = fontSize + spacing
        let threshold = (abs(CGFloat(index - dragged)) - 0.5) * cellWidth

        if dragged < index && dragOffset > threshold {
            return -cellWidth
        }

        if dragged > index && dragOffset < -threshold {
            return cellWidth
        }

        return 0
    }

    private func dragGesture(for index: Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if draggedIndex == nil {
                    draggedIndex = index
                }
                dragOffset = value.translation.width
            }
            .onEnded { value in
                guard let dragged = draggedIndex else { return }

                let cellWidth = fontSize + spacing
                let dragAmount = value.translation.width
                let dropThreshold = cellWidth / 2

                var newIndex = dragged

                if dragAmount > dropThreshold {
                    newIndex = min(dragged + Int((dragAmount - dropThreshold) / cellWidth) + 1, characters.count - 1)
                } else if dragAmount < -dropThreshold {
                    newIndex = max(dragged - Int((abs(dragAmount) - dropThreshold) / cellWidth) - 1, 0)
                }

                if newIndex != dragged {
                    let character = characters.remove(at: dragged)
                    characters.insert(character, at: newIndex)
                    text = String(characters)
                }

                draggedIndex = nil
                dragOffset = 0
            }
    }
}

private struct LetterView: View {
    let character: Character
    let font: Font
    let foregroundColor: Color
    let activeColor: Color
    let isDragging: Bool
    let offset: CGFloat

    var body: some View {
        Text(String(character))
            .font(font)
            .fontWeight(.bold)
            .foregroundColor(isDragging ? activeColor : foregroundColor)
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .offset(x: offset)
            .zIndex(isDragging ? 1 : 0)
    }
}

// MARK: - Preview
struct LetterFlow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LetterFlow(text: .constant("HELLO"))
                .padding()

            LetterFlow(text: .constant("SwiftUI"),
                       font: .system(size: 40, weight: .heavy, design: .rounded),
                       foregroundColor: .purple,
                       activeColor: .orange)
                .padding()

            LetterFlow(text: .constant("👋🌎"),
                       font: .largeTitle,
                       foregroundColor: .primary,
                       activeColor: .pink)
                .padding()
        }
    }
}
