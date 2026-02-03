//
//  ImageLoader.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url.absoluteString as NSString
        if let cached = cache.object(forKey: key) {
            completion(cached)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
}
