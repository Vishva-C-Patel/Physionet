import UIKit

final class SplashViewController: UIViewController {
    private let onFinish: () -> Void
    private let logoView = UIImageView()
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

        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.image = UIImage(named: "LaunchMark")
        logoView.contentMode = .scaleAspectFit
        logoView.alpha = 0.0
        logoView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(logoView)

        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        brandLabel.text = "PHYSIONET"
        brandLabel.textAlignment = .center
        brandLabel.textColor = UIColor(red: 0.25098, green: 0.63137, blue: 0.90196, alpha: 1)
        brandLabel.font = UIFont(name: "TimesNewRomanPSMT", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .medium)
        brandLabel.alpha = 0.0
        brandLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(brandLabel)

        NSLayoutConstraint.activate([
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28),
            logoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.64),
            logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor),

            brandLabel.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 16),
            brandLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            brandLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
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
                self?.brandLabel.alpha = 1.0
                self?.brandLabel.transform = .identity
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
