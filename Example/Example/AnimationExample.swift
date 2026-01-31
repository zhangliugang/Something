//
//  AnimationExample.swift
//  Example
//
//  Created by liugang zhang on 2026/1/31.
//

import SwiftUI

/// Model representing an animation example in the list
struct AnimationExample: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    @ViewBuilder let preview: () -> AnyView

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AnimationExample, rhs: AnimationExample) -> Bool {
        lhs.id == rhs.id
    }
}

/// Available example categories
enum ExampleCategory: String, CaseIterable {
    case metal = "Metal"
    case swiftUI = "SwiftUI"

    var color: Color {
        switch self {
        case .metal: return .blue
        case .swiftUI: return .orange
        }
    }
}
