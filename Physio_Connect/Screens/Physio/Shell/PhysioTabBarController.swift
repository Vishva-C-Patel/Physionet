//
//  PhysioTabBarController.swift
//  Physio_Connect
//
//  Created by user@8 on 08/01/26.
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

        // Apply transparent scroll-edge and frosted glass standard appearance
        let standard = UITheme.makeGlassNavBarAppearance()
        let scrollEdge = UINavigationBarAppearance()
        scrollEdge.configureWithTransparentBackground()
        scrollEdge.shadowColor = .clear
        scrollEdge.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        for nav in [home, appointments, programs, reports] {
            nav.navigationBar.tintColor = UITheme.Colors.accent
            nav.navigationBar.standardAppearance = standard
            nav.navigationBar.scrollEdgeAppearance = scrollEdge
            nav.navigationBar.compactAppearance = standard
        }
    }

    private func styleTabBar() {
        // iOS 26 Liquid Glass — transparent + blur
        let appearance = UITheme.makeGlassTabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
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
        view.backgroundColor = .systemGroupedBackground
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
