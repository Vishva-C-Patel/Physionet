//
//  RoleSelectionView.swift
//  Physio_Connect
//
//  Created by user@8 on 07/01/26.
//
import UIKit

final class RoleSelectionView: UIView {
    
    // MARK: - UI
    private let backgroundGlow = AppBackgroundTopGlowView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let container = UIView()
    private let recoveryPath = RecoveryPathHeroView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    let patientButton = UIButton(type: .system)
    let physioButton = UIButton(type: .system)
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        buildUI()
        layoutUI()
        styleUI()
        animateEntry()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup
    private func buildUI() {
        backgroundGlow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundGlow)
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(container)
        
        [recoveryPath, titleLabel, subtitleLabel, patientButton, physioButton].forEach { 
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0) 
        }
    }
    
    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundGlow.topAnchor.constraint(equalTo: topAnchor),
            backgroundGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundGlow.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundGlow.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            recoveryPath.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            recoveryPath.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            recoveryPath.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1.0),
            recoveryPath.heightAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: recoveryPath.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            patientButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 42),
            patientButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            patientButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            patientButton.heightAnchor.constraint(equalToConstant: 62),
            
            physioButton.topAnchor.constraint(equalTo: patientButton.bottomAnchor, constant: 16),
            physioButton.leadingAnchor.constraint(equalTo: patientButton.leadingAnchor),
            physioButton.trailingAnchor.constraint(equalTo: patientButton.trailingAnchor),
            physioButton.heightAnchor.constraint(equalToConstant: 62),
            
            physioButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    private func styleUI() {
        scrollView.showsVerticalScrollIndicator = false
        
        // Text
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = "The Path to Mobility"
        titleLabel.font = UITheme.Typography.screenTitle.withSize(34)
        titleLabel.textColor = .label
        
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "From recovery to peak performance, track your journey with advanced digital care."
        subtitleLabel.font = UITheme.Typography.bodySmallMedium.withSize(16)
        subtitleLabel.textColor = .secondaryLabel
        
        // Liquid Glass Buttons (icon-less)
        configureGlassButton(patientButton, title: "Continue as Patient", isPrimary: true)
        configureGlassButton(physioButton, title: "I am a Physiotherapist", isPrimary: false)
    }
    
    private func configureGlassButton(_ button: UIButton, title: String, isPrimary: Bool) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .capsule
        
        if isPrimary {
            config.baseBackgroundColor = UITheme.Colors.accent
            config.baseForegroundColor = .white
        } else {
            config.baseBackgroundColor = UITheme.Colors.neutralFill.withAlphaComponent(0.08)
            config.baseForegroundColor = UITheme.Colors.accent
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UITheme.Colors.accent.withAlphaComponent(0.2).cgColor
        }
        
        button.configuration = config
        button.titleLabel?.font = UITheme.Typography.button
        button.layer.cornerRadius = 31
        button.clipsToBounds = true
        
        if !isPrimary {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
            blur.isUserInteractionEnabled = false
            blur.translatesAutoresizingMaskIntoConstraints = false
            button.insertSubview(blur, at: 0)
            NSLayoutConstraint.activate([
                blur.topAnchor.constraint(equalTo: button.topAnchor),
                blur.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                blur.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
        }
    }
    
    private func animateEntry() {
        [recoveryPath, titleLabel, subtitleLabel, patientButton, physioButton].forEach { 
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 30) 
        }
        
        UIView.animate(withDuration: 1.0, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseOut) {
            [self.recoveryPath, self.titleLabel, self.subtitleLabel, self.patientButton, self.physioButton].enumerated().forEach { index, view in
                UIView.animate(withDuration: 0.7, delay: 0.1 * Double(index)) {
                    view.alpha = 1
                    view.transform = .identity
                }
            }
        }
    }
}

// MARK: - Procedural Recovery Path View

final class RecoveryPathHeroView: UIView {
    
    private let waveLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let beadLayer = CALayer()
    private var displayLink: CADisplayLink?
    private var phase: CGFloat = 0
    private var beadProgress: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        waveLayer.fillColor = nil
        waveLayer.strokeColor = UIColor.white.cgColor
        waveLayer.lineWidth = 2.5
        waveLayer.lineCap = .round
        
        let pathContainer = UIView(frame: bounds)
        pathContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(pathContainer)
        pathContainer.layer.addSublayer(waveLayer)
        
        // Gradient for the wave (Chaos Red -> Recovery Blue)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.mask = waveLayer
        pathContainer.layer.addSublayer(gradientLayer)
        
        // Bead representing the "Patient's Progress"
        beadLayer.backgroundColor = UIColor.white.cgColor
        beadLayer.cornerRadius = 6
        beadLayer.shadowRadius = 8
        beadLayer.shadowColor = UIColor.white.cgColor
        beadLayer.shadowOpacity = 0.8
        pathContainer.layer.addSublayer(beadLayer)
        
        updateColors()
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waveLayer.frame = bounds
        gradientLayer.frame = bounds
        updateColors()
    }
    
    private func updateColors() {
        gradientLayer.colors = [
            UITheme.Colors.accent.withAlphaComponent(0.2).cgColor,
            UITheme.Colors.accent.cgColor,
            UITheme.Colors.accent.withAlphaComponent(0.8).cgColor
        ]
    }
    
    @objc private func updateAnimation() {
        phase += 0.02
        beadProgress += 0.002
        if beadProgress > 1.0 { beadProgress = 0.0 }
        
        drawRecoveryPath()
    }
    
    private func drawRecoveryPath() {
        let width = bounds.width
        let centerY = bounds.midY
        let path = UIBezierPath()
        
        let resolution: CGFloat = 4
        
        for x in stride(from: 0, to: width, by: resolution) {
            let normalizedX = x / width
            let chaos = sin(phase * 4 + x * 0.1) * 20 * (1.0 - normalizedX)
            let harmony = sin(phase + x * 0.05) * 35 * normalizedX
            let y = centerY + chaos + harmony
            
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        waveLayer.path = path.cgPath
        
        // Precise bead point calculation for maximum smoothness
        let beadX = beadProgress * width
        let nx = beadProgress
        let beadChaos = sin(phase * 4 + beadX * 0.1) * 20 * (1.0 - nx)
        let beadHarmony = sin(phase + beadX * 0.05) * 35 * nx
        let beadY = centerY + beadChaos + beadHarmony
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        beadLayer.frame = CGRect(x: beadX - 6, y: beadY - 6, width: 12, height: 12)
        CATransaction.commit()
    }
}
