import UIKit

public final class LetterFlowView: UIView {
    public var text: String = "" {
        didSet {
            createLabels()
        }
    }

    public var font: UIFont = .systemFont(ofSize: 34, weight: .bold) {
        didSet {
            labelViews.forEach { $0.font = font }
        }
    }

    public var textColor: UIColor = .label {
        didSet {
            labelViews.forEach { $0.textColor = textColor }
        }
    }

    public var activeColor: UIColor = .systemBlue {
        didSet {
            updateActiveLabel()
        }
    }

    public var spacing: CGFloat = 8 {
        didSet {
            layoutAllLabels()
        }
    }

    public var onTextChanged: ((String) -> Void)?

    private var labelViews: [UILabel] = []
    private var panGesture: UIPanGestureRecognizer!
    private var draggedIndex: Int?
    private var initialCenter: CGPoint = .zero
    private var originalCenters: [CGPoint] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGesture()
    }

    private func setupGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        layoutAllLabels()
    }

    private func createLabels() {
        labelViews.forEach { $0.removeFromSuperview() }
        labelViews = Array(text).map { character in
            let label = UILabel()
            label.text = String(character)
            label.font = font
            label.textColor = textColor
            label.textAlignment = .center
            addSubview(label)
            return label
        }
        originalCenters = labelViews.map { $0.center }
        layoutAllLabels()
    }

    private func layoutAllLabels() {
        let cellWidth = font.lineHeight
        let totalWidth = CGFloat(labelViews.count) * cellWidth + CGFloat(labelViews.count - 1) * spacing
        var xOffset = (bounds.width - totalWidth) / 2

        for label in labelViews {
            label.frame = CGRect(
                x: xOffset,
                y: (bounds.height - cellWidth) / 2,
                width: cellWidth,
                height: cellWidth
            )
            xOffset += cellWidth + spacing
        }

        originalCenters = labelViews.map { $0.center }
    }

    private func cellSize() -> CGFloat {
        return font.lineHeight + spacing
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            if let index = labelViews.firstIndex(where: { $0.frame.contains(location) }) {
                draggedIndex = index
                initialCenter = labelViews[index].center
                originalCenters = labelViews.map { $0.center }
                updateActiveLabel()
                bringSubviewToFront(labelViews[index])
            }

        case .changed:
            guard let dragged = draggedIndex else { return }

            let translation = gesture.translation(in: self).x
            let cellWidth = cellSize()

            // 移动被拖动的 label
            labelViews[dragged].center = CGPoint(x: initialCenter.x + translation, y: initialCenter.y)

            // 计算其他 label 的位置
            for (index, label) in labelViews.enumerated() {
                if index == dragged { continue }
                let originalX = originalCenters[index].x
                let threshold = (abs(CGFloat(index - dragged)) - 0.5) * cellWidth

                var moveOffset: Double = 0
                if dragged < index && translation > threshold {
                    moveOffset = -cellWidth
                } else if dragged > index && translation < -threshold {
                    moveOffset = cellWidth
                }
                let targetX = originalX + moveOffset

                if label.center.x != targetX {
                    UIView.animate(withDuration: 0.1) {
                        label.center.x = targetX
                    }
                }
            }

        case .ended, .cancelled:
            guard let dragged = draggedIndex else { return }

            let translation = gesture.translation(in: self).x
            let cellSize = cellSize()
            let halfCellSize = cellSize / 2

            // 计算新位置
            var newIndex = dragged
            if translation > halfCellSize {
                newIndex = min(dragged + Int((translation - halfCellSize) / cellSize) + 1, labelViews.count - 1)
            } else if translation < -halfCellSize {
                newIndex = max(dragged - Int((abs(translation) - halfCellSize) / cellSize) - 1, 0)
            }

            UIView.animate(withDuration: 0.1) {
                self.labelViews[dragged].center.x = self.position(for: newIndex)
            }

            draggedIndex = nil
            updateActiveLabel()
            labelViews.sort(by: { $0.center.x < $1.center.x })

            // 通知外部文本已变化
            let newText = labelViews.compactMap { $0.text }.joined()
            onTextChanged?(newText)

        default:
            break
        }
    }

    private func position(for index: Int) -> CGFloat {
        let cellWidth = font.lineHeight
        let cellSize = cellWidth + spacing
        let totalWidth = CGFloat(labelViews.count) * cellWidth + CGFloat(labelViews.count - 1) * spacing
        let startX = (bounds.width - totalWidth) / 2
        return startX + CGFloat(index) * cellSize + cellWidth / 2
    }

    private func updateActiveLabel() {
        guard let dragged = draggedIndex else {
            labelViews.forEach { $0.textColor = textColor }
            return
        }
        labelViews.enumerated().forEach { index, label in
            label.textColor = (index == dragged) ? activeColor : textColor
        }
    }

    public func setText(_ newText: String, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0
            } completion: { _ in
                self.text = newText
                UIView.animate(withDuration: 0.2) {
                    self.alpha = 1
                }
            }
        } else {
            text = newText
        }
    }
}
