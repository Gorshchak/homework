//
//  ImageResolver.swift
//  meowle
//
//  Created by a.gorshchak on 19.02.2024.
//

import UIKit

final class ImageResolversFactory {
    
    // Dependencies
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession) {
        self.session = session
    }
    
    func buildImageResolver() -> ImageResolver {
        return ImageResolver(session: session)
    }
}

final class ImageResolver {

    // Private
    private static var cache: [String: UIImage] = [:]

    // Dependencies
    private let session: URLSession

    // MARK: - Initialization

    init(session: URLSession) {
        self.session = session
    }
}

// MARK: - IImageResolver

extension ImageResolver {

    func applyImage(
        by url: URL,
        completion: @escaping ((UIImage?) -> Void)
    ) {
        if let image = ImageResolver.cache[url.absoluteString] {
            completion(image)
            return
        }
        session.dataTask(with: url, completionHandler: { data, responce, error in
            if let error = error {
                return
            }
            guard let data = data,
                  let urlString = responce?.url?.absoluteString,
                  let image = UIImage(data: data) else { return }

            if ImageResolver.cache[urlString] == nil {
                ImageResolver.cache[urlString] = image
            }
            DispatchQueue.performOnMain {
                completion(image)
            }
        }).resume()
    }
}
