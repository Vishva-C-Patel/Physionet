//
//  PhysiotherapistProfileViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 30/12/25.
//

import UIKit
import CoreLocation

final class PhysiotherapistProfileViewController: UIViewController {

    private let profileView = PhysiotherapistProfileView()
    private let physioID: UUID
    private let preloadCard: PhysiotherapistCardModel?
    private let isReschedule: Bool

    private var reviews: [PhysioReviewRow] = []

    init(physioID: UUID, preloadCard: PhysiotherapistCardModel? = nil, isReschedule: Bool = false) {
        self.physioID = physioID
        self.preloadCard = preloadCard
        self.isReschedule = isReschedule
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = profileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Remove automatic top inset (fixes unwanted gap)
        profileView.scrollView.contentInsetAdjustmentBehavior = .never

        // Targets
        profileView.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        profileView.bookButton.addTarget(self, action: #selector(bookAppointmentTapped), for: .touchUpInside)
        profileView.seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)

        // Reviews table
        profileView.reviewsTableView.dataSource = self
        profileView.reviewsTableView.delegate = self
        
        profileView.aboutMoreButton.addTarget(self, action: #selector(aboutMoreTapped), for: .touchUpInside)

        profileView.bookButton.addTarget(self, action: #selector(bookAppointmentTapped), for: .touchUpInside)


        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensures height stays correct after layout changes
        profileView.updateReviewsTableHeight()
    }

    private func loadData() {
        Task {
            do {
                async let physioTask = PhysioService.shared.fetchPhysiotherapist(by: physioID)
                async let specsTask  = PhysioService.shared.fetchSpecializationNames(for: physioID)
                async let reviewsTask = PhysioService.shared.fetchReviews(for: physioID, limit: 3)

                let physio = try await physioTask
                let specs  = (try? await specsTask) ?? []
                let fetchedReviews = (try? await reviewsTask) ?? []

                let model = PhysiotherapistProfileModel.build(
                    from: physio,
                    specializations: specs,
                    preloadDistanceText: preloadCard?.distanceText,
                    userLocation: LocationService.shared.lastLocation,
                    reviews: fetchedReviews
                )

                await MainActor.run {
                    // Configure top UI
                    self.profileView.configure(with: model)
                    self.loadAvatarImage(path: physio.profile_image_path, version: physio.updated_at)

                    // Configure reviews table
                    self.reviews = fetchedReviews
                    self.profileView.reviewsTableView.reloadData()
                    self.profileView.updateReviewsTableHeight()
                }
            } catch {
                print("❌ Profile load error:", error)
            }
        }
    }

    private func loadAvatarImage(path: String?, version: String?) {
        guard let path else {
            profileView.setAvatarImage(nil)
            return
        }
        PhysioService.shared.loadProfileImage(pathOrUrl: path, version: version) { [weak self] image in
            self?.profileView.setAvatarImage(image)
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func aboutMoreTapped() {
        profileView.toggleAbout()
        profileView.updateReviewsTableHeight() // keeps scroll layout stable
    }


    @objc private func bookAppointmentTapped() {
        // push next screen (home visit)
        let vc = BookHomeVisitViewController(physioID: physioID, isReschedule: isReschedule) // <-- use your stored physioID

        // If you're using a tab bar and want the next screen full-screen:
        vc.hidesBottomBarWhenPushed = true

        // Push
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            // fallback: present if not embedded in nav
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }


    @objc private func seeAllTapped() {
        // Later: push a full reviews screen
        let alert = UIAlertController(
            title: "Reviews",
            message: "Next step: open full reviews list.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource + UITableViewDelegate
extension PhysiotherapistProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: PhysioReviewCell.reuseID,
            for: indexPath
        ) as! PhysioReviewCell

        cell.configure(reviews[indexPath.row])
        return cell
    }
}
