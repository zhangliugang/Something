import SwiftUI
import AwesomeAnimation

struct LetterFlowExampleView: View {
    @State private var word1 = "HELLO"
    @State private var word2 = "SwiftUI"
    @State private var word3 = "👋🌎"

    var body: some View {
        ScrollView {
                VStack(spacing: 12) {
                    Text("Drag letters to reorder")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    ZStack {
//                        Image(uiImage: UIImage(contentsOfFile: Bundle.main.path(forResource: "img", ofType: "avif")!)!)
//                            .resizable()
//                            .scaledToFill()


//                        LetterFlowViewRepresentable(text: $word1)
//                            .frame(height: 160)
//                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Image(uiImage: UIImage(contentsOfFile: Bundle.main.path(forResource: "img", ofType: "avif")!)!)
                            .resizable()
                            .scaledToFill()
//                            .blur(radius: 10)
//                            .mask {
//                                Text("Hello, World!")
//                                    .font(.largeTitle).bold()
//
////                                .layerEffect(ShaderLibrary.gooeyDistort(
////                                    .float2(400, 400), // 视图大小
////                                    .float(2) // 传入时间实现动态扭曲
////                                ), maxSampleOffset: CGSizeZero)
//                            }
                        LetterFlow(text: $word1)
                            .font(.largeTitle)
//                        Text("Hello, World!")
//                            .font(.title)
//                            .padding()
//                            .glassEffect(.clear, in: RoundedRectangle())



                    }
                }
                Text("Hello, World!")
                    .font(.largeTitle)
                    .foregroundStyle(.yellow)
                    .padding()
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 300))
                    .colorEffect(ShaderLibrary.checkerboard(.float(8), .color(.blue)))
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
