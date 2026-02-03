import UIKit

final class PhysioRoleChoiceViewController: UIViewController {

    private let choiceView = PhysioRoleChoiceView()

    override func loadView() { view = choiceView }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        choiceView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        choiceView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        choiceView.signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
    }

    @objc private func backTapped() {
        AppLogout.backToRoleSelection(from: view, signOut: false)
    }

    @objc private func loginTapped() {
        let vc = PhysioAuthViewController(startOnSignup: false)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func signupTapped() {
        let vc = PhysioAuthViewController(startOnSignup: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
