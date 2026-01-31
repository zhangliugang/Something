//
//  GridDissolveExampleView.swift
//  Example
//
//  Created by liugang zhang on 2026/1/31.
//

import SwiftUI
import AwesomeAnimation

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
    @State private var gridSize: Int = 30
    @State private var animationDuration: Double = 3

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Preview Section
                GroupBox("Preview") {
                    VStack {
                        ZStack {
                            if isPresented {
                                MetalGridViewRepresentable(
                                    isShowing: $showingAnimation,
                                    direction: selectedDirection,
                                    gridSize: gridSize,
                                    duration: animationDuration
                                ) {
                                    Image(uiImage: UIImage(contentsOfFile: Bundle.main.path(forResource: "img", ofType: "avif")!)!)
                                        .resizable()
                                        .scaledToFill()
                                } onDismissed: {
                                    showingAnimation = false
                                    isPresented = false
                                }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
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

                // Code Example Section
                GroupBox("Code Example") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Usage")
                            .font(.headline)

                        Text("""
                        let gridView = MetalGridView()
                        gridView.gridColumns = 10
                        gridView.gridRows = 10
                        gridView.dissolveDirection = .centerOut
                        gridView.dismiss(animated: true) {
                            print("Animation complete")
                        }
                        """)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Grid Dissolve Animation")
    }
}

// MARK: - Metal Grid View Representable

import SwiftUI
import UIKit

struct MetalGridViewRepresentable<Content: View>: UIViewRepresentable {
    @Binding var isShowing: Bool
    let direction: GridDissolveDirection
    let gridSize: Int
    let duration: Double
    @ViewBuilder let content: () -> Content
    let onDismissed: () -> Void

    init(
        isShowing: Binding<Bool>,
        direction: GridDissolveDirection,
        gridSize: Int,
        duration: Double,
        @ViewBuilder content: @escaping () -> Content,
        onDismissed: @escaping () -> Void
    ) {
        self._isShowing = isShowing
        self.direction = direction
        self.gridSize = gridSize
        self.duration = duration
        self.content = content
        self.onDismissed = onDismissed
    }

    func makeUIView(context: Context) -> MetalGridView {
        let view = MetalGridView()
        view.cellPixelSize = Double(gridSize)
        view.dissolveDirection = direction
        view.animationDuration = duration

        // Add subview from content
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.contentView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: MetalGridView, context: Context) {
        uiView.cellPixelSize = Double(gridSize)
        uiView.dissolveDirection = direction
        uiView.animationDuration = duration

        if isShowing {
            uiView.dismiss(animated: true) {
                onDismissed()
            }
        }
    }
}

// Convenience initializer without content
extension MetalGridViewRepresentable {
    init(
        isShowing: Binding<Bool>,
        direction: GridDissolveDirection,
        gridSize: Int,
        duration: Double,
        onDismissed: @escaping () -> Void
    ) where Content == EmptyView {
        self._isShowing = isShowing
        self.direction = direction
        self.gridSize = gridSize
        self.duration = duration
        self.content = { EmptyView() }
        self.onDismissed = onDismissed
    }
}

#Preview {
    GridDissolveExampleView()
}
