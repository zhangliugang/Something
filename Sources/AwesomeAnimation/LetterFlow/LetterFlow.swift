import SwiftUI

@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
public struct LetterFlow: View {
    @Binding public var text: String

    @State private var cellWidth: Double = 10
    @State private var leadingSpace: Double = 0

//    @State private var draggedIndex: Int?
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
//        let characters = Array(text.wrappedValue)
//
//        initOffsets = Self.layoutAllLabels(characters.count, 60)

//        self.characters = characters
//        self.offsets = initOffsets
//        self.$offsets = initOffsets
    }

    public var body: some View {
        ZStack {
            GlassEffectContainer(spacing: 40) {
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
                    .foregroundStyle(Color.white)
                    .frame(width: cellWidth, height: cellWidth)
                    .border(Color.red)
                    .offset(x: dragOffset(for: index))
            }
        }
        .frame(maxWidth: .infinity)
        .border(Color.purple)
        .gesture(dragGesture())
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .task(id: proxy.size) {
                        self.size = proxy.size
                    }
            }
        }
        .onAppear(perform: {
            self.cellWidth = Font.largeTitle.resolve(in: context).pointSize * 1.5
            self.leadingSpace = (self.size.width - cellWidth * Double(text.count)) / 2
            self.initOffsets = initOffset(text.count, cellWidth)
            self.characters = Array(text)
            self.offsets = initOffsets
        })
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragDelta)
    }

    private func dragOffset(for index: Int) -> CGFloat {
        guard index >= 0 && index < offsets.count && index < dragDelta.count else {
            return 0
        }
        return offsets[index] + dragDelta[index]
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .updating($dragDelta, body: { value, state, _ in
                let tx = value.translation.width
                let dragged = Int((value.startLocation.x - leadingSpace) / cellWidth)
                state = onMove(dragged, tx)
            })
            .onEnded { value in
                let dragged = Int((value.startLocation.x - leadingSpace) / cellWidth)

                guard let index = offsets.firstIndex(of: initOffsets[dragged]) else {
                    return
                }

                let tx = value.translation.width
                let dropThreshold = cellWidth / 2

                var newIndex = max(min(Int((value.location.x - leadingSpace) / cellWidth), 4), 0)

                let delta = onMove(dragged, value.translation.width)

                for i in 0..<offsets.count {
                    if i == index {
                        offsets[i] = initOffsets[newIndex]
                    } else {
                        offsets[i] += delta[i]
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

    private func onMove(_ dragged: Int, _ translation: Double) -> [Double] {

        var res = Array<Double>(repeating: 0, count: offsets.count)
//        let cellWidth = fontSize
        guard let index = offsets.firstIndex(of: initOffsets[dragged]) else {
            return res
        }

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
                .padding()
        }
        .background(Color.indigo)
//        .previewInterfaceOrientation(.landscapeLeft)
    }
}
