//
//  PhysioHomeViewController.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
//

import UIKit

final class PhysioHomeViewController: UIViewController {

    private let homeView = PhysioHomeView()
    private let profileModel = PhysioProfileModel()
    private let profileButton = UIButton(type: .system)
    private let dashboardModel = PhysioDashboardModel()
    private var isLoading = false

    override func loadView() { view = homeView }

    override func viewDidLoad() {
        super.viewDidLoad()
        PhysioNavBarStyle.apply(
            to: self,
            title: "Dashboard",
            largeTitle: true,
            profileButton: profileButton,
            profileAction: #selector(profileTapped)
        )
        loadProfileAvatar()
        Task { await loadDashboard() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileAvatar()
        Task { await loadDashboard() }
    }

    private func loadDashboard() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let physioID = try await dashboardModel.resolvePhysioID()

            async let summary = dashboardModel.fetchSummary(physioID: physioID)
            async let upcoming = dashboardModel.fetchUpcomingSessions(physioID: physioID)
            async let patients = dashboardModel.fetchPatients(physioID: physioID)

            let summaryValue = (try? await summary) ?? PhysioDashboardSummary(
                todaySessions: 0,
                upcomingAppointments: 0,
                activePrograms: 0
            )
            let upcomingValue = (try? await upcoming) ?? []
            let patientsValue = (try? await patients) ?? []

            await MainActor.run {
                self.homeView.setSummary(
                    todaySessions: summaryValue.todaySessions,
                    upcomingAppointments: summaryValue.upcomingAppointments,
                    activePrograms: summaryValue.activePrograms
                )
                let upcomingItems = upcomingValue.map {
                    PhysioHomeView.UpcomingItem(
                        title: $0.title,
                        patient: $0.patientName,
                        time: $0.timeText,
                        location: $0.locationText
                    )
                }
                self.homeView.setUpcoming(upcomingItems)

                let patientItems = patientsValue.map {
                    PhysioHomeView.PatientItem(
                        name: $0.name,
                        contact: $0.contactLine,
                        location: $0.locationLine
                    )
                }
                self.homeView.setPatients(patientItems)
            }
        } catch {
            // keep last known UI if refresh fails
        }
    }

    private func loadProfileAvatar() {
        Task {
            do {
                let data = try await profileModel.fetchProfile()
                await MainActor.run {
                    PhysioNavBarStyle.updateProfileButton(self.profileButton, urlString: data.avatarURL)
                }
            } catch {
                let fallback = PhysioProfileModel.cachedAvatarURL()
                await MainActor.run {
                    PhysioNavBarStyle.updateProfileButton(self.profileButton, urlString: fallback)
                }
            }
        }
    }

    @objc private func profileTapped() {
        let vc = PhysioProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}
