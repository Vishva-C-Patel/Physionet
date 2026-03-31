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
        let apptVC = AppointmentsViewController()
        let apptNav = UINavigationController(rootViewController: apptVC)
        apptNav.tabBarItem = UITabBarItem(
            title: "Appointments",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.circle.fill")
        )

        // Videos
        let videosVC = VideosViewController()
        let videosNav = UINavigationController(rootViewController: videosVC)
        videosNav.tabBarItem = UITabBarItem(
            title: "Videos",
            image: UIImage(systemName: "play.rectangle"),
            selectedImage: UIImage(systemName: "play.rectangle.fill")
        )

        // Articles
        let articlesVC = ArticlesViewController()
        let articlesNav = UINavigationController(rootViewController: articlesVC)
        articlesNav.tabBarItem = UITabBarItem(
            title: "Articles",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )

        viewControllers = [homeNav, apptNav, videosNav, articlesNav]
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
        
        for nav in [homeNav, apptNav, videosNav, articlesNav] {
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
