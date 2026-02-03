//
//  PhysioNavBarStyle.swift
//  Physio_Connect
//
//  Created by Codex on 29/01/26.
//

import UIKit

enum PhysioNavBarStyle {
    static func apply(to viewController: UIViewController,
                      title: String,
                      profileButton: UIButton,
                      profileAction: Selector) {
        viewController.navigationController?.setNavigationBarHidden(false, animated: false)
        viewController.navigationController?.navigationBar.prefersLargeTitles = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UITheme.Typography.screenTitle
        titleLabel.textColor = UIColor(hex: "0F172A")
        titleLabel.textAlignment = .center
        viewController.navigationItem.titleView = titleLabel

        configureProfileButton(profileButton, image: UIImage(systemName: "person.crop.circle"))
        profileButton.addTarget(viewController, action: profileAction, for: .touchUpInside)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }

    static func updateProfileButton(_ button: UIButton, urlString: String?) {
        let placeholder = UIImage(systemName: "person.crop.circle")
        configureProfileButton(button, image: placeholder)

        guard let raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return }

        let url: URL?
        if let absolute = URL(string: raw), absolute.scheme != nil {
            url = absolute
        } else if let built = PhysioService.shared.profileImageURL(pathOrUrl: raw, version: nil) {
            url = built
        } else {
            let normalized = raw.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            url = URL(string: "\(SupabaseConfig.url)/storage/v1/object/public/\(normalized)")
        }
        guard let finalURL = url else { return }

        ImageLoader.shared.load(finalURL) { image in
            let rounded = image?.withRenderingMode(.alwaysOriginal)
            DispatchQueue.main.async {
                configureProfileButton(button, image: rounded ?? placeholder)
            }
        }
    }

    private static func configureProfileButton(_ button: UIButton, image: UIImage?) {
        let size: CGFloat = 36
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = UIColor(hex: "1E6EF7")
        button.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        button.layer.cornerRadius = size / 2
        button.clipsToBounds = true
        button.adjustsImageWhenHighlighted = false
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.contentEdgeInsets = .zero
        button.imageEdgeInsets = .zero

        if button.constraints.isEmpty {
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: size),
                button.heightAnchor.constraint(equalToConstant: size)
            ])
        }
    }
}
