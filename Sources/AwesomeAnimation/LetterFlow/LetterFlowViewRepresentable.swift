import SwiftUI

public struct LetterFlowViewRepresentable: UIViewRepresentable {
    @Binding public var text: String
    public var font: Font = .largeTitle
    public var foregroundColor: Color = .primary
    public var activeColor: Color = .blue
    public var spacing: CGFloat = 8

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
    }

    public func makeUIView(context: Context) -> LetterFlowView {
        let view = LetterFlowView()
        configureView(view)
        return view
    }

    public func updateUIView(_ uiView: LetterFlowView, context: Context) {
        configureView(uiView)
    }

    private func configureView(_ view: LetterFlowView) {
        view.text = text
        view.font = UIFont(from: font)
        view.textColor = UIColor(foregroundColor)
        view.activeColor = UIColor(activeColor)
        view.spacing = spacing
//        view.onTextChanged = { newText in
//            DispatchQueue.main.async {
//                self.text = newText
//            }
//        }
    }
}

extension UIFont {
    convenience init(from font: Font) {
        let uiFont: UIFont
        switch font {
        case .largeTitle:
            uiFont = .systemFont(ofSize: 60, weight: .bold)
        case .title:
            uiFont = .systemFont(ofSize: 48, weight: .bold)
        case .title2:
            uiFont = .systemFont(ofSize: 40, weight: .bold)
        case .title3:
            uiFont = .systemFont(ofSize: 34, weight: .bold)
        case .headline:
            uiFont = .systemFont(ofSize: 28, weight: .bold)
        case .body:
            uiFont = .systemFont(ofSize: 24, weight: .bold)
        case .callout:
            uiFont = .systemFont(ofSize: 20, weight: .bold)
        case .subheadline:
            uiFont = .systemFont(ofSize: 18, weight: .bold)
        case .caption:
            uiFont = .systemFont(ofSize: 16, weight: .bold)
        case .caption2:
            uiFont = .systemFont(ofSize: 14, weight: .bold)
        default:
            uiFont = .systemFont(ofSize: 34, weight: .bold)
        }
        self.init(descriptor: uiFont.fontDescriptor, size: uiFont.pointSize)
    }
}

#if DEBUG
struct LetterFlowViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LetterFlowViewRepresentable(text: .constant("HELLO"))
                .frame(height: 80)
                .padding()

            LetterFlowViewRepresentable(
                text: .constant("SwiftUI"),
                font: .system(size: 40, weight: .heavy, design: .rounded),
                foregroundColor: .purple,
                activeColor: .orange
            )
            .frame(height: 80)
            .padding()

            LetterFlowViewRepresentable(
                text: .constant("👋🌎"),
                font: .largeTitle,
                foregroundColor: .primary,
                activeColor: .pink
            )
            .frame(height: 80)
            .padding()
        }
    }
}
#endif
