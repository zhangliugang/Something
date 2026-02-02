import SwiftUI
import AwesomeAnimation

struct LetterFlowExampleView: View {
    @State private var word1 = "HELLO"
    @State private var word2 = "SwiftUI"
    @State private var word3 = "👋🌎"

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(spacing: 12) {
                    Text("Drag letters to reorder")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    LetterFlow(text: $word1)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .padding()
                        .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()

                Divider()

                VStack(spacing: 12) {
                    Text("Custom Colors")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    LetterFlow(
                        text: $word2,
                        font: .system(size: 40, weight: .heavy, design: .monospaced),
                        foregroundColor: .purple,
                        activeColor: .orange
                    )
                    .padding()
                    .background(Color.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()

                Divider()

                VStack(spacing: 12) {
                    Text("Emojis")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    LetterFlow(
                        text: $word3,
                        font: .system(size: 50),
                        foregroundColor: .primary,
                        activeColor: .pink
                    )
                    .padding()
                    .background(Color.pink.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .padding()
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
