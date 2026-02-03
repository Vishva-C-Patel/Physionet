//
//  MainTabBarController.swift
//  Physio_Connect
//
//  Created by user@8 on 02/01/26.
//
import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }

    private func setupTabs() {
        // Home
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Appointments
        let apptVC = AppointmentsViewController() // we will build next
        let apptNav = UINavigationController(rootViewController: apptVC)
        apptNav.tabBarItem = UITabBarItem(
            title: "Appointments",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.circle.fill")
        )

        // Videos
        let videosVC = VideosViewController() // placeholder if you already have
        let videosNav = UINavigationController(rootViewController: videosVC)
        videosNav.tabBarItem = UITabBarItem(
            title: "Videos",
            image: UIImage(systemName: "play.rectangle"),
            selectedImage: UIImage(systemName: "play.rectangle.fill")
        )

        // Articles
        let articlesVC = ArticlesViewController() // placeholder if you already have
        let articlesNav = UINavigationController(rootViewController: articlesVC)
        articlesNav.tabBarItem = UITabBarItem(
            title: "Articles",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )

        viewControllers = [homeNav, apptNav, videosNav, articlesNav]
        selectedIndex = 0
    }

    private func styleTabBar() {
        // Native appearance API (iOS 13+)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Background like your screenshot (soft grey)
        appearance.backgroundColor = UIColor(white: 0.92, alpha: 1.0)

        // Icon/text colors
        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = UIColor.black.withAlphaComponent(0.45)
        normal.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.45)]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = UIColor(hex: "1E6EF7")
        selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "1E6EF7")]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        // Slightly taller + rounded look (simple version)
        tabBar.layer.cornerRadius = 22
        tabBar.layer.masksToBounds = true

        // Optional: lift the bar a bit like a “floating” tab
        tabBar.itemPositioning = .automatic
    }
}

