//
//  PhysioTabBarController.swift
//  Physio_Connect
//
//  Created by Codex on 08/01/26.
//

import UIKit

final class PhysioTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    private func setupTabs() {
        let home = UINavigationController(rootViewController: PhysioHomeViewController())
        home.navigationBar.prefersLargeTitles = true
        home.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let appointments = UINavigationController(rootViewController: PhysioAppointmentsViewController())
        appointments.tabBarItem = UITabBarItem(
            title: "Appointments",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.circle.fill")
        )

        let programs = UINavigationController(rootViewController: PhysioProgramsViewController())
        programs.tabBarItem = UITabBarItem(
            title: "Programs",
            image: UIImage(systemName: "square.grid.2x2"),
            selectedImage: UIImage(systemName: "square.grid.2x2.fill")
        )

        let reports = UINavigationController(rootViewController: PhysioReportsViewController())
        reports.tabBarItem = UITabBarItem(
            title: "Reports",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )

        viewControllers = [home, appointments, programs, reports]
        selectedIndex = 0
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.6)

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor.black.withAlphaComponent(0.6)
        normal.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.6)]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = UIColor(hex: "1E6EF7")
        selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "1E6EF7")]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        tabBar.layer.cornerRadius = 22
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.08
        tabBar.layer.shadowRadius = 12
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.itemPositioning = .automatic
    }
}

// Simple placeholder until real screens are wired
private final class PlaceholderViewController: UIViewController {
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "E6F1FF")
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
