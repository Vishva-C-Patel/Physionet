//
//  PhysioNavBarStyle.swift
//  Physio_Connect
//
//  Created by user@8 on 29/01/26.
//

import UIKit

enum PhysioNavBarStyle {
    private static let imageCache = NSCache<NSString, UIImage>()
    private static let stateLock = NSLock()
    private static var expectedAvatarByButton: [ObjectIdentifier: String] = [:]
    private static var signedURLCache: [String: (url: URL, expiry: Date)] = [:]

    static func apply(to viewController: UIViewController,
                      title: String,
                      profileButton: UIButton,
                      profileAction: Selector) {
        viewController.navigationController?.setNavigationBarHidden(false, animated: false)
        UITheme.applyNativeNavBar(to: viewController, title: title)

        configureProfileButton(profileButton, image: UIImage(systemName: "person.crop.circle"))
        profileButton.addTarget(viewController, action: profileAction, for: .touchUpInside)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }

    static func updateProfileButton(_ button: UIButton, urlString: String?) {
        let placeholder = UIImage(systemName: "person.crop.circle")
        let raw = urlString?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        stateLock.lock()
        expectedAvatarByButton[ObjectIdentifier(button)] = raw
        stateLock.unlock()

        guard !raw.isEmpty else {
            configureProfileButton(button, image: placeholder)
            return
        }

        if let cached = imageCache.object(forKey: raw as NSString) {
            configureProfileButton(button, image: cached.withRenderingMode(.alwaysOriginal))
            return
        }

        if button.currentImage == nil {
            configureProfileButton(button, image: placeholder)
        }

        if let cachedSigned = cachedSignedURL(for: raw) {
            ImageLoader.shared.load(cachedSigned) { image in
                applyLoadedImage(image, placeholder: placeholder, raw: raw, button: button)
            }
            return
        }

        let finalURL: URL?
        if let absolute = URL(string: raw), absolute.scheme != nil {
            finalURL = absolute
        } else if let built = PhysioService.shared.profileImageURL(pathOrUrl: raw, version: nil) {
            finalURL = built
        } else {
            let normalized = raw.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            finalURL = URL(string: "\(SupabaseConfig.url)/storage/v1/object/public/\(normalized)")
        }
        guard let finalURL else {
            loadFromSignedURLIfPossible(raw: raw, placeholder: placeholder, button: button)
            return
        }

        ImageLoader.shared.load(finalURL) { image in
            if let image {
                applyLoadedImage(image, placeholder: placeholder, raw: raw, button: button)
                return
            }
            loadFromSignedURLIfPossible(raw: raw, placeholder: placeholder, button: button)
        }
    }

    private static func configureProfileButton(_ button: UIButton, image: UIImage?) {
        let size: CGFloat = 36
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = UITheme.Colors.accent
        button.backgroundColor = UIColor.tertiarySystemFill
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

    private static func loadFromSignedURLIfPossible(raw: String, placeholder: UIImage?, button: UIButton) {
        guard let ref = storageReference(from: raw) else {
            DispatchQueue.main.async {
                if isExpected(raw: raw, button: button) {
                    configureProfileButton(button, image: placeholder)
                }
            }
            return
        }

        Task {
            guard let signed = try? await SupabaseManager.shared.client.storage
                .from(ref.bucket)
                .createSignedURL(path: ref.path, expiresIn: 3600)
            else {
                await MainActor.run {
                    if isExpected(raw: raw, button: button) {
                        configureProfileButton(button, image: placeholder)
                    }
                }
                return
            }

            cacheSignedURL(signed, for: raw)
            ImageLoader.shared.load(signed) { image in
                applyLoadedImage(image, placeholder: placeholder, raw: raw, button: button)
            }
        }
    }

    private static func applyLoadedImage(_ image: UIImage?, placeholder: UIImage?, raw: String, button: UIButton) {
        DispatchQueue.main.async {
            guard isExpected(raw: raw, button: button) else { return }
            if let image {
                let original = image.withRenderingMode(.alwaysOriginal)
                imageCache.setObject(original, forKey: raw as NSString)
                configureProfileButton(button, image: original)
            } else {
                configureProfileButton(button, image: placeholder)
            }
        }
    }

    private static func isExpected(raw: String, button: UIButton) -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return expectedAvatarByButton[ObjectIdentifier(button)] == raw
    }

    private static func cachedSignedURL(for raw: String) -> URL? {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard let cached = signedURLCache[raw], cached.expiry > Date() else {
            signedURLCache.removeValue(forKey: raw)
            return nil
        }
        return cached.url
    }

    private static func cacheSignedURL(_ url: URL, for raw: String) {
        stateLock.lock()
        signedURLCache[raw] = (url, Date().addingTimeInterval(55 * 60))
        stateLock.unlock()
    }

    private static func storageReference(from raw: String) -> (bucket: String, path: String)? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let range = trimmed.range(of: "/storage/v1/object/public/") {
            let tail = String(trimmed[range.upperBound...])
            let parts = tail.split(separator: "/", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return nil }
            return (bucket: parts[0], path: parts[1])
        }

        let parts = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            .split(separator: "/", maxSplits: 1)
            .map(String.init)
        guard parts.count == 2 else { return nil }
        return (bucket: parts[0], path: parts[1])
    }
}
