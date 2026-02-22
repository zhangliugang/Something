import Metal
import MetalKit
import UIKit
import Shared

/// Animation direction for the grid dissolve effect
public enum GridDissolveDirection: CaseIterable {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
    case topLeftToBottomRight
    case topRightToBottomLeft
    case bottomLeftToTopRight
    case bottomRightToTopLeft
    case centerOut
    case edgeIn
    case random

    var rawValue: Int32 {
        switch self {
        case .leftToRight: return 0
        case .rightToLeft: return 1
        case .topToBottom: return 2
        case .bottomToTop: return 3
        case .topLeftToBottomRight: return 4
        case .topRightToBottomLeft: return 5
        case .bottomLeftToTopRight: return 6
        case .bottomRightToTopLeft: return 7
        case .centerOut: return 8
        case .edgeIn: return 9
        case .random: return 10
        }
    }
}

/// A view subclass that uses Metal to render a grid-based dissolve animation
/// The view is divided into a grid of squares that scale down and fade out
/// in a specific pattern when dismissed.
public final class MetalGridView: UIView {

    // MARK: - Properties

    private var metalDevice: MTLDevice?
    private var metalCommandQueue: MTLCommandQueue?
    private var metalPipelineState: MTLRenderPipelineState?
    private var metalTexture: MTLTexture?
    private var displayLink: CADisplayLink?

    public let contentView = UIView()

    /// Cell size in pixels (width, height)
    public var cellPixelSize = 80.0

    /// Animation direction
    public var dissolveDirection: GridDissolveDirection = .centerOut

    /// Total animation duration in seconds
    public var animationDuration: TimeInterval = 3

    /// Per-cell animation duration in seconds (default 0.1)
    public var cellDuration: TimeInterval = 0.5

    /// Whether animation is currently running
    private(set) public var isAnimating: Bool = false

    /// Completion handler called when animation finishes
    private var completionHandler: (() -> Void)?

    private var startTime: CFTimeInterval = 0
    private var animationRandomSeed: Float = 0

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private var metalLayer: CAMetalLayer?

    private func commonInit() {
        setupMetal()
        setupPipeline()

        // Create a CAMetalLayer as a sublayer for rendering
        let ml = CAMetalLayer()
        ml.device = metalDevice
        ml.pixelFormat = .rgba8Unorm
        ml.framebufferOnly = false  // Allow transparent pixels
        ml.frame = bounds
        ml.contentsScale = UIScreen.main.scale
        ml.isOpaque = false  // Allow transparent background
        metalLayer = ml

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func updateMetalLayerSize() {
        guard let ml = metalLayer else { return }
        let scale = window?.screen.scale ?? UIScreen.main.scale
        ml.frame = bounds
        ml.contentsScale = scale
        ml.drawableSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
    }

    deinit {
        // Note: displayLink should be stopped before deallocation
        // The displayLink is automatically invalidated when the view is removed from window
    }

    // MARK: - Metal Setup

    private func setupMetal() {
        metalDevice = MTLCreateSystemDefaultDevice()
        guard let device = metalDevice else {
            print("Metal is not supported on this device")
            return
        }

        metalCommandQueue = device.makeCommandQueue()
    }

    private func setupPipeline() {
        guard let device = metalDevice,
              let library = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
            print("Failed to load Metal library")
            return
        }

        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba8Unorm

        // Enable blending for transparency
        pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

        do {
            metalPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }

    // MARK: - Texture Capture

    private func captureViewAsTexture() -> MTLTexture? {
        guard let device = metalDevice else { return nil }

        let img = UIGraphicsImageRenderer(bounds: bounds).image { context in
            contentView.layer.render(in: context.cgContext)
        }
        guard let cgImage = img.cgImage else { return nil }
        return try? MTKTextureLoader(device: device).newTexture(cgImage: cgImage)
    }

    // MARK: - Animation

    /// Starts the dismiss animation
    /// - Parameters:
    ///   - animated: Whether to animate (if false, immediately dismisses)
    ///   - completion: Called when animation completes
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard !isAnimating else { return }

        if !animated {
            self.isAnimating = false
            completion?()
            return
        }

        // Capture current view state as texture
        metalTexture = captureViewAsTexture()

        guard metalTexture != nil else {
            completion?()
            return
        }

        isAnimating = true
        completionHandler = completion

        startAnimation()
    }

    private func startAnimation() {
        guard let ml = metalLayer else {
            return
        }
        updateMetalLayerSize()
        layer.addSublayer(ml)
        contentView.isHidden = true

        startTime = CACurrentMediaTime()
        animationRandomSeed = Float.random(in: 0...1)
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateAnimation() {
        let elapsed = CACurrentMediaTime() - startTime
        // Render final frame when elapsed exceeds total animation time
        if elapsed >= animationDuration {
            renderAnimationFrame(elapsed: animationDuration)
            stopAnimation()
            return
        }

        renderAnimationFrame(elapsed: elapsed)
    }

    private func renderAnimationFrame(elapsed: TimeInterval) {
        guard let pipelineState = metalPipelineState,
              let commandQueue = metalCommandQueue,
              let texture = metalTexture else {
            stopAnimation()
            return
        }

        // Update uniforms with elapsed time in seconds
        var uniforms = Uniforms(
            time: Float(elapsed),
            gridSize: SIMD2(Float(cellPixelSize), Float(cellPixelSize)),
            duration: Float(animationDuration),
            cellDuration: Float(cellDuration),
            direction: dissolveDirection.rawValue,
            randomSeed: animationRandomSeed
        )

        // Get metal layer and drawable
        guard let ml = metalLayer, let currentDrawable = ml.nextDrawable() else {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 0)

        // Draw full-screen quad using triangle strip
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

    public func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
        completionHandler?()
        completionHandler = nil
        metalLayer?.removeFromSuperlayer()
        contentView.isHidden = false
    }
}
