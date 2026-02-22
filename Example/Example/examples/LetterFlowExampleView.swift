import SwiftUI
import Something

struct LetterFlowExampleView: View {
    @State private var word1 = "HELLO"

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Drag letters to reorder")
                    .font(.headline)
                    .foregroundColor(.secondary)

                ZStack {
                    Image(uiImage: UIImage(contentsOfFile: Bundle.main.path(forResource: "img", ofType: "avif")!)!)
                        .resizable()
                        .scaledToFill()

                    LetterFlow(text: $word1)
                        .font(.largeTitle.pointSize(50))
                        .bold()
                }
            }
            Divider()
        }
        .navigationTitle("Letter Flow")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LetterFlowExampleView()
    }
}
