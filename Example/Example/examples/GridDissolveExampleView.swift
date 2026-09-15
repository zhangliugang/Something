//
//  GridDissolveExampleView.swift
//  Example
//
//  Created by liugang zhang on 2026/1/31.
//

import SwiftUI
import Something

extension GridDissolveDirection: @retroactive Identifiable, @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .leftToRight: "Left to Right"
        case .rightToLeft: "Right to Left"
        case .topToBottom: "Top to Bottom"
        case .bottomToTop: "Bottom to Top"
        case .topLeftToBottomRight: "Top-Left to Bottom-Right"
        case .topRightToBottomLeft: "Top-Right to Bottom-Left"
        case .bottomLeftToTopRight: "Bottom-Left to Top-Right"
        case .bottomRightToTopLeft: "Bottom-Right to Top-Left"
        case .centerOut: "Center Out"
        case .edgeIn: "Edge In"
        case .random: "Random"
        }
    }
    public var id: String {
        description
    }
}

struct GridDissolveExampleView: View {
    @State private var isPresented = true
    @State private var showingAnimation = false
    @State private var selectedDirection: GridDissolveDirection = .leftToRight
    @State private var gridSize: Int = 20
    @State private var animationDuration: Double = 3

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preview Section
                GroupBox("Preview") {
                    VStack {
                        ZStack {
                            GridDissolveView(
                                gridSize: CGSize(width: gridSize, height: gridSize),
                                duration: animationDuration,
                                cell_Duration: 1,
                                direction: selectedDirection) {
                                Image(uiImage: UIImage(contentsOfFile: Bundle.main.path(forResource: "img", ofType: "avif")!)!)
                                    .resizable()
                                    .scaledToFill()
                            }
                                .frame(height: 200)
                        }
                        .frame(height: 200)
                        HStack {
                            Button("Reset") {
                                isPresented = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(isPresented)

                            Button("Dismiss") {
                                showingAnimation = true
                            }
                            .buttonStyle(.bordered)
                            .disabled(showingAnimation)
                        }
                    }
                    .padding()
                }

                // Configuration Section
                GroupBox("Configuration") {
                    VStack(alignment: .leading, spacing: 15) {
                        // Direction Picker
                        HStack {
                            Text("Direction:")
                            Spacer()
                            Picker("Direction", selection: $selectedDirection) {
                                ForEach(GridDissolveDirection.allCases) { d in
                                    Text(d.description).tag(d)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 250)
                        }

                        // Grid Size Slider
                        HStack {
                            Text("Grid Size: \(gridSize)")
                            Spacer()
                            Slider(value: Binding(
                                get: { Double(gridSize) },
                                set: { gridSize = Int($0) }
                            ), in: 20...100, step: 1)
                            .frame(width: 150)
                        }

                        // Duration Slider
                        HStack {
                            Text("Duration: \(animationDuration, specifier: "%.1f")s")
                            Spacer()
                            Slider(value: $animationDuration, in: 0.2...20.0, step: 0.1)
                            .frame(width: 150)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Grid Dissolve Animation")
    }
}


#Preview {
    GridDissolveExampleView()
}
