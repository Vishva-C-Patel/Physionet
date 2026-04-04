import UIKit

final class SplashViewController: UIViewController {
    private let onFinish: () -> Void
    private let backgroundGlow = AppBackgroundTopGlowView()
    private let logoView = ZenithLogoView()
    private let brandLabel = UILabel()
    private let ringLayer = CAShapeLayer()
    private var didAnimate = false

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundGlow)

        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.alpha = 0.0
        logoView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(logoView)

        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        brandLabel.text = "PHYSIONET"
        brandLabel.textAlignment = .center
        brandLabel.textColor = UITheme.Colors.textPrimary
        brandLabel.font = UITheme.Fonts.title(34)
        brandLabel.alpha = 0.0
        brandLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(brandLabel)

        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            logoView.widthAnchor.constraint(equalToConstant: 180),
            logoView.heightAnchor.constraint(equalToConstant: 180),

            brandLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 28),
            brandLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            brandLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])

        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 1.5
        ringLayer.lineCap = .round
        ringLayer.opacity = 0.0
        view.layer.addSublayer(ringLayer)
        
        updateThemeColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateThemeColors()
        }
    }
    
    private func updateThemeColors() {
        ringLayer.strokeColor = UITheme.Colors.accent.withAlphaComponent(0.15).cgColor
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let center = view.center
        let radius: CGFloat = 100
        let ringRect = CGRect(
            x: center.x - radius,
            y: center.y - radius - 50,
            width: radius * 2.0,
            height: radius * 2.0
        )
        ringLayer.frame = view.bounds
        ringLayer.path = UIBezierPath(ovalIn: ringRect).cgPath
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !didAnimate else { return }
        didAnimate = true

        UIView.animate(
            withDuration: 1.2,
            delay: 0.2,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.logoView.alpha = 1.0
                self?.logoView.transform = .identity
                self?.brandLabel.alpha = 1.0
                self?.brandLabel.transform = .identity
            }
        )

        logoView.startAnimating()

        ringLayer.opacity = 1.0
        let ringDraw = CABasicAnimation(keyPath: "strokeEnd")
        ringDraw.fromValue = 0.0
        ringDraw.toValue = 1.0
        ringDraw.duration = 1.6
        ringDraw.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        ringLayer.add(ringDraw, forKey: "ringDraw")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.onFinish()
        }
    }
}

// MARK: - Zenith Logo View

final class ZenithLogoView: UIView {
    private let haloLayer = CAShapeLayer()
    private let coreNodes: [CALayer] = (0..<5).map { _ in CALayer() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        // Build Architectural Halo (The Protection Ring)
        haloLayer.fillColor = nil
        haloLayer.strokeColor = UITheme.Colors.accent.withAlphaComponent(0.4).cgColor
        haloLayer.lineWidth = 6.0
        haloLayer.lineCap = .round
        
        // Add halo glow
        haloLayer.shadowColor = UITheme.Colors.accent.cgColor
        haloLayer.shadowRadius = 16
        haloLayer.shadowOpacity = 0.4
        haloLayer.shadowOffset = .zero
        layer.addSublayer(haloLayer)
        
        // Build Core Spinal Nodes
        coreNodes.enumerated().forEach { index, node in
            node.backgroundColor = UITheme.Colors.accent.cgColor
            node.cornerRadius = 5.0
            
            // Individual node glow
            node.shadowColor = UITheme.Colors.accent.cgColor
            node.shadowRadius = 14
            node.shadowOpacity = 0.8
            node.shadowOffset = .zero
            node.opacity = 0.0 // Star hidden for 'charging' intro
            
            layer.addSublayer(node)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w = bounds.width
        let h = bounds.height
        let center = CGPoint(x: w/2, y: h/2)
        let radius = min(w, h) * 0.4
        
        // Halo Arc (C-shape or Horseshoe)
        let haloPath = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: -CGFloat.pi * 0.2,
                                    endAngle: CGFloat.pi * 1.2,
                                    clockwise: true)
        haloLayer.path = haloPath.cgPath
        haloLayer.frame = bounds
        
        // Position Spinal Core vertically in the center of the Halo
        let startY = center.y - radius * 0.7
        let endY = center.y + radius * 0.7
        let step = (endY - startY) / CGFloat(coreNodes.count - 1)
        
        coreNodes.enumerated().forEach { index, node in
            let nodeSize: CGFloat = (index == 2) ? 12.0 : (index == 1 || index == 3) ? 10.0 : 8.0
            node.cornerRadius = nodeSize / 2
            let yPos = startY + CGFloat(index) * step
            node.frame = CGRect(
                x: center.x - nodeSize/2,
                y: yPos - nodeSize/2,
                width: nodeSize,
                height: nodeSize
            )
        }
    }
    
    func startAnimating() {
        // Halo pulse
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.3
        pulse.toValue = 0.7
        pulse.duration = 2.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        haloLayer.add(pulse, forKey: "haloPulse")
        
        // Sequential 'Charging' Core Nodes
        coreNodes.enumerated().forEach { index, node in
            let reveal = CABasicAnimation(keyPath: "opacity")
            reveal.fromValue = 0.0
            reveal.toValue = 1.0
            reveal.duration = 0.6
            reveal.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            reveal.fillMode = .forwards
            reveal.isRemovedOnCompletion = false
            node.add(reveal, forKey: "reveal")
            
            // Staggered Breathing Pulse (after reveal)
            let breath = CABasicAnimation(keyPath: "transform.scale")
            breath.fromValue = 0.9
            breath.toValue = 1.15
            breath.duration = 1.8
            breath.beginTime = CACurrentMediaTime() + 1.0 + Double(index) * 0.1
            breath.autoreverses = true
            breath.repeatCount = .infinity
            breath.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            node.add(breath, forKey: "breath")
        }
    }
}
