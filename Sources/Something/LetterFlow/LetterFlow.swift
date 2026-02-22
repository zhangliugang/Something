import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
public struct LetterFlow: View {
    @Binding public var text: String

    @State private var cellWidth: Double = 10
    @State private var leadingSpace: Double = 0

    @State private var characters: [Character] = []
    @State private var initOffsets: [Double] = []
    @State private var offsets: [Double] = []
    @State private var size: CGSize = .zero

    @GestureState
    private var dragDelta: [Double] = []

    @Environment(\.fontResolutionContext) private var context
    @Environment(\.font) private var font

    @Namespace private var animation

    public init(text: Binding<String>) {
        self._text = text
    }

    public var body: some View {
        ZStack {
            GlassEffectContainer(spacing: cellWidth / 2) {
                ZStack {
                    ForEach(characters.indices, id: \.self) { index in
                        Capsule(style: .continuous)
                            .foregroundStyle(Color.clear)
                            .frame(width: cellWidth, height: cellWidth * 1.5)
                            .glassEffect(.clear)
                            .glassEffectID(index, in: animation)
                            .offset(x: dragOffset(for: index))
                    }
                }
            }
            ForEach(characters.indices, id: \.self) { index in
                Text(String(characters[index]))
                    .font(font ?? .largeTitle)
                    .foregroundStyle(Color.white)
                    .frame(width: cellWidth, height: cellWidth)
                    .offset(x: dragOffset(for: index))
            }
        }
        .frame(maxWidth: .infinity)
        .gesture(dragGesture())
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .task(id: proxy.size) {
                        self.size = proxy.size
                        self.cellWidth = (font ?? .largeTitle).resolve(in: context).pointSize * 1.5
                        self.leadingSpace = (self.size.width - cellWidth * Double(text.count)) / 2
                        self.initOffsets = initOffset(text.count, cellWidth)
                        self.characters = Array(text)
                        self.offsets = initOffsets
                    }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragDelta)
    }

    private func dragOffset(for index: Int) -> CGFloat {
        guard index >= 0 && index < offsets.count else {
            return 0
        }
        let baseOffset = offsets[index]
        if index < dragDelta.count {
            return baseOffset + dragDelta[index]
        }
        return baseOffset
    }

    private func dragIndex(_ location: Double) -> Int? {
        let dragged = Int((location - leadingSpace) / cellWidth)

        guard dragged >= 0, dragged < offsets.count else {
            return nil
        }
        return offsets.firstIndex(of: initOffsets[dragged])
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .updating($dragDelta, body: { value, state, _ in
                guard let index = dragIndex(value.startLocation.x) else {
                    return
                }
                state = onMove(index, value.translation.width)
            })
            .onEnded { value in
                guard let index = dragIndex(value.startLocation.x) else {
                    return
                }

                let delta = onMove(index, value.translation.width)

                for i in 0..<offsets.count where i != index {
                    offsets[i] += delta[i]
                }
                for value in initOffsets {
                    if !offsets.contains(value) {
                        offsets[index] = value
                    }
                }
            }
    }

    private func initOffset(_ count: Int, _ width: Double) -> [Double] {
        let mid = Double(count) / 2
        let offset = (0..<count).enumerated().map { index, _ in
            (Double(index) - mid + 0.5) * width
        }
        return offset
    }

    private func onMove(_ index: Int, _ translation: Double) -> [Double] {
        var res = Array<Double>(repeating: 0, count: offsets.count)
        res[index] = translation
        let draggedOffset = offsets[index] + translation
        let step = Int((abs(translation) + cellWidth * 0.5) / cellWidth)

        for (i, off) in offsets.enumerated() where index != i {
            if translation > 0 && off > offsets[index] && draggedOffset + cellWidth / 2 > off {
                res[i] = -cellWidth
            }
            if translation < 0 && off < offsets[index] && draggedOffset - cellWidth / 2 < off {
                res[i] = cellWidth
            }
        }

        return res
    }
}


// MARK: - Preview
@available(iOS 26.0, *)
struct LetterFlow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LetterFlow(text: .constant("HELLO"))
                .font(.largeTitle)
                .padding()

            LetterFlow(text: .constant("SwiftU"))
                .font(.headline)
                .padding()
        }
        .background(Color.indigo)
//        .previewInterfaceOrientation(.landscapeLeft)
    }
}
