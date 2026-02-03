//
//  PaymentViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 01/01/26.
import UIKit

final class PaymentViewController: UIViewController {

    // Callbacks back to BookHomeVisitVC
    var onPaymentSuccess: (() -> Void)?
    var onRequireSignup: (() -> Void)?

    private let paymentView = PaymentView()
    private let model: PaymentModel

    init(draft: BookingDraft) {
        self.model = PaymentModel(draft: draft)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func loadView() { view = paymentView }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        paymentView.render(model: model)

        paymentView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        paymentView.payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func payTapped() {
        Task {
            do {
                // If user is not logged in → require signup/login
                _ = try await SupabaseManager.shared.client.auth.session
                await MainActor.run {
                    self.onPaymentSuccess?()  // payment success (simulated)
                }
            } catch {
                await MainActor.run {
                    self.onRequireSignup?()
                }
            }
        }
    }
}
