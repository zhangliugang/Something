////
////  MetalGridViewRepresentable.swift
////  Example
////
////  Created by liugang zhang on 2026/1/31.
////
//
//import SwiftUI
//import UIKit
//import AwesomeAnimation
//
///// UIViewRepresentable wrapper for MetalGridView
//struct MetalGridViewRepresentable<Content: View>: UIViewRepresentable {
//    @Binding var isShowing: Bool
//    let direction: GridDissolveDirection
//    let gridSize: Int
//    let duration: Double
//    @ViewBuilder let content: () -> Content
//    let onDismissed: () -> Void
//
//    init(
//        isShowing: Binding<Bool>,
//        direction: GridDissolveDirection,
//        gridSize: Int,
//        duration: Double,
//        @ViewBuilder content: @escaping () -> Content,
//        onDismissed: @escaping () -> Void
//    ) {
//        self._isShowing = isShowing
//        self.direction = direction
//        self.gridSize = gridSize
//        self.duration = duration
//        self.content = content
//        self.onDismissed = onDismissed
//    }
//
//    func makeUIView(context: Context) -> MetalGridView {
//        let view = MetalGridView()
//        configureView(view)
//        return view
//    }
//
//    func updateUIView(_ uiView: MetalGridView, context: Context) {
//        configureView(uiView)
//
//        if isShowing {
//            uiView.dismiss(animated: true) {
//                onDismissed()
//            }
//        }
//    }
//
//    private func configureView(_ view: MetalGridView) {
//        view.cellPixelSize = Double(gridSize)
//        view.dissolveDirection = direction
//        view.animationDuration = duration
//    }
//}
//
//// MARK: - Convenience Initializer
//
//extension MetalGridViewRepresentable where Content == EmptyView {
//    init(
//        isShowing: Binding<Bool>,
//        direction: GridDissolveDirection,
//        gridSize: Int,
//        duration: Double,
//        onDismissed: @escaping () -> Void
//    ) {
//        self._isShowing = isShowing
//        self.direction = direction
//        self.gridSize = gridSize
//        self.duration = duration
//        self.content = { EmptyView() }
//        self.onDismissed = onDismissed
//    }
//}
