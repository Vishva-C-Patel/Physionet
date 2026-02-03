import UIKit

final class PhysioRoleChoiceView: UIView {

    private let container = UIView()
    private let topBar = UIView()
    let backButton = UIButton(type: .system)

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    let loginButton = UIButton(type: .system)
    let signupButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "E3F0FF")
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        [topBar, container].forEach { addSubview($0) }
        [backButton].forEach { topBar.addSubview($0) }
        [titleLabel, subtitleLabel, loginButton, signupButton].forEach { container.addSubview($0) }

        topBar.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.translatesAutoresizingMaskIntoConstraints = false

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor.black.withAlphaComponent(0.8)

        titleLabel.text = "Physiotherapist Access"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center

        subtitleLabel.text = "Login to your account or create a new one to continue."
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        configurePrimaryButton(loginButton, title: "Login")
        configurePrimaryButton(signupButton, title: "Sign Up")

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6),
            topBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            topBar.heightAnchor.constraint(equalToConstant: 32),

            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            loginButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 52),

            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            signupButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            signupButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            signupButton.heightAnchor.constraint(equalToConstant: 52),
            signupButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func configurePrimaryButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(hex: "1E6EF7")
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.10
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
    }
}
