//
//  ContentView.swift
//  Example
//
//  Created by liugang zhang on 2026/1/22.
//

import SwiftUI
import Something

// MARK: - Example Data

let animationExamples: [AnimationExample] = [
    AnimationExample(
        title: "Grid Dissolve",
        description: "Metal-based grid dissolve animation with 11 direction options",
        category: ExampleCategory.metal.rawValue
    ) {
        AnyView(GridDissolveExampleView())
    },
    AnimationExample(
        title: "Digital Clock",
        description: "Rolling digit animation displaying current time",
        category: ExampleCategory.swiftUI.rawValue
    ) {
        AnyView(DigitalClockExampleView())
    },
    AnimationExample(
        title: "Letter Flow",
        description: "Draggable letter reordering with spring animations",
        category: ExampleCategory.swiftUI.rawValue
    ) {
        AnyView(LetterFlowExampleView())
    }
]

// MARK: - Main Content View

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(animationExamples) { example in
                NavigationLink(value: example) {
                    ExampleRowView(example: example)
                }
            }
            .navigationTitle("Animations")
            .navigationDestination(for: AnimationExample.self) { example in
                ExampleDetailView(example: example)
            }
        }
    }
}

// MARK: - Example Row View

struct ExampleRowView: View {
    let example: AnimationExample

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(example.title)
                .font(.headline)
            Text(example.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(example.category)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(categoryColor, in: Capsule())
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        switch example.category {
        case ExampleCategory.metal.rawValue: return .blue
        case ExampleCategory.swiftUI.rawValue: return .orange
        default: return .gray
        }
    }
}

// MARK: - Example Detail View

struct ExampleDetailView: View {
    let example: AnimationExample

    var body: some View {
        example.preview()
            .navigationTitle(example.title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
