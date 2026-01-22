import UIKit

final class SplashViewController: UIViewController {
    private let onFinish: () -> Void
    private let logoView = UIImageView()
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

        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.image = UIImage(named: "LaunchLogo")
        logoView.contentMode = .scaleAspectFit
        logoView.alpha = 0.0
        logoView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(logoView)

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.64),
            logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor)
        ])

        ringLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.35).cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 2.0
        ringLayer.lineCap = .round
        ringLayer.opacity = 0.0
        view.layer.addSublayer(ringLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let size = logoView.bounds.size
        guard size.width > 0, size.height > 0 else { return }

        let radius = min(size.width, size.height) * 0.42
        let center = view.convert(logoView.center, from: logoView.superview)
        let ringRect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
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
            withDuration: 0.6,
            delay: 0.0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.logoView.alpha = 1.0
                self?.logoView.transform = .identity
            }
        )

        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.04
        pulse.duration = 1.1
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        logoView.layer.add(pulse, forKey: "pulse")

        ringLayer.opacity = 1.0
        let ringDraw = CABasicAnimation(keyPath: "strokeEnd")
        ringDraw.fromValue = 0.0
        ringDraw.toValue = 1.0
        ringDraw.duration = 0.9
        ringDraw.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        ringLayer.add(ringDraw, forKey: "ringDraw")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.onFinish()
        }
    }
}
